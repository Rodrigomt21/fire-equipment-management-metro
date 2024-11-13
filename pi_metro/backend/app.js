require('dotenv').config({ path: 'variaveis.env' }); // Importa variáveis de ambiente
const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const cors = require('cors');
const bcrypt = require('bcrypt'); // Para hashing de senhas
const rateLimit = require('express-rate-limit'); // Limite de tentativas de login
const { check, validationResult } = require('express-validator'); // Validação de entrada
const crypto = require('crypto'); // Para geração de tokens seguros
const nodemailer = require('nodemailer'); // Para envio de emails

const app = express();
const port = 3000;

// Middleware para interpretar JSON e habilitar CORS
app.use(cors());
app.use(bodyParser.json());

// Configuração do limitador de tentativas de login
const loginLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutos
    max: 5, // Limita a 5 tentativas
    message: "Muitas tentativas de login. Tente novamente após 15 minutos."
});

// Conexão com o MySQL usando variáveis de ambiente
const db = mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
});

db.connect(err => {
    if (err) {
        console.error('Erro ao conectar ao MySQL:', err);
    } else {
        console.log('Conectado ao MySQL!');
    }
});

// Configuração do Nodemailer para envio de email
const transporter = nodemailer.createTransport({
    host: process.env.EMAIL_HOST,
    port: process.env.EMAIL_PORT,
    secure: false, // true para 465, false para outras portas
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
    },
});

// Rota para registrar usuários com validação de entrada
app.post('/cadastro', [
    check('nomeCompleto').not().isEmpty().withMessage('Nome completo é obrigatório'),
    check('email').isEmail().withMessage('Email inválido'),
    check('senha').isLength({ min: 6 }).withMessage('Senha precisa ter ao menos 6 caracteres')
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }

    const { nomeCompleto, email, senha } = req.body;

    try {
        // Hash da senha antes de armazenar
        const hashedPassword = await bcrypt.hash(senha, 10);

        // Inserindo nomeCompleto, email e senha no banco
        const sql = 'INSERT INTO users (nomeCompleto, email, senha) VALUES (?, ?, ?)';
        
        db.query(sql, [nomeCompleto, email, hashedPassword], (err, result) => {
            if (err) {
                console.error('Erro ao inserir usuário:', err);
                res.status(500).json({ error: 'Erro ao registrar usuário' });
            } else {
                res.status(200).send('Usuário registrado com sucesso');
            }
        });
    } catch (err) {
        console.error('Erro ao registrar usuário:', err);
        res.status(500).json({ error: 'Erro no servidor ao registrar usuário' });
    }
});

// Rota para verificar login e senha com limitador
app.post('/login', loginLimiter, (req, res) => {
    const { email, senha } = req.body;

    const sql = 'SELECT * FROM users WHERE email = ?';
    
    db.query(sql, [email], (err, result) => {
        if (err) {
            console.error('Erro ao buscar usuário:', err);
            res.status(500).json({ error: 'Erro no servidor ao buscar usuário' });
            return;
        }

        if (result.length > 0) {
            // Comparar senha fornecida com a senha armazenada no banco de dados
            bcrypt.compare(senha, result[0].senha, (err, isMatch) => {
                if (isMatch) {
                    res.status(200).send('Login bem-sucedido.');
                } else {
                    res.status(401).json({ error: 'Credenciais inválidas.' });
                }
            });
        } else {
            res.status(401).json({ error: 'Credenciais inválidas.' });
        }
    });
});

// Rota para recuperação de senha
app.post('/forgot-password', (req, res) => {
    const { email } = req.body;

    // Verifica se o email existe no banco de dados
    const sql = 'SELECT * FROM users WHERE email = ?';
    db.query(sql, [email], (err, results) => {
        if (err) {
            console.error('Erro ao buscar usuário:', err);
            return res.status(500).json({ error: 'Erro no servidor ao buscar usuário' });
        }

        if (results.length === 0) {
            return res.status(404).json({ error: 'Email não encontrado' });
        }

        // Gera um token para redefinição de senha
        const token = crypto.randomBytes(20).toString('hex');

        // Define o token e a validade (1 hora) no banco de dados
        const tokenExpiration = new Date(Date.now() + 3600000); // 1 hora a partir de agora
        const updateTokenSql = 'UPDATE users SET reset_password_token = ?, reset_password_expires = ? WHERE email = ?';

        db.query(updateTokenSql, [token, tokenExpiration, email], (err) => {
            if (err) {
                console.error('Erro ao salvar o token no banco de dados:', err);
                return res.status(500).json({ error: 'Erro no servidor ao salvar token de recuperação' });
            }

            // Link de recuperação HTTP para o navegador
            const resetUrl = `${process.env.FRONTEND_URL}/reset-password?token=${token}`;
            const mailOptions = {
                from: process.env.EMAIL_USER,
                to: email,
                subject: 'Recuperação de senha',
                text: `Você solicitou a recuperação de senha. Clique no link a seguir para redefinir sua senha: ${resetUrl}`,
                html: `<p>Você solicitou a recuperação de senha. Clique no link a seguir para redefinir sua senha:</p><p><a href="${resetUrl}">Redefinir senha</a></p>`,
            };

            transporter.sendMail(mailOptions, (err, info) => {
                if (err) {
                    console.error('Erro ao enviar email:', err);
                    return res.status(500).json({ error: 'Erro ao enviar email de recuperação' });
                }
                res.status(200).json({ message: 'Email de recuperação enviado com sucesso' });
            });
        });
    });
});

// Rota GET para exibir o formulário de redefinição de senha
app.get('/reset-password', (req, res) => {
    const { token } = req.query;
    if (!token) {
        return res.status(400).send('Token inválido ou ausente.');
    }

    // Retorna uma página HTML mais completa com o formulário de redefinição de senha
    res.send(`
        <!DOCTYPE html>
        <html lang="pt-BR">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Redefinir Senha</title>
            <style>
                body { font-family: Arial, sans-serif; display: flex; align-items: center; justify-content: center; height: 100vh; margin: 0; }
                .container { width: 100%; max-width: 400px; padding: 20px; border: 1px solid #ccc; border-radius: 5px; box-shadow: 0 0 10px rgba(0, 0, 0, 0.1); }
                h2 { text-align: center; }
                label { display: block; margin-top: 10px; }
                input[type="password"], button { width: 100%; padding: 10px; margin-top: 10px; }
                button { background-color: #007bff; color: white; border: none; cursor: pointer; }
                button:hover { background-color: #0056b3; }
            </style>
        </head>
        <body>
            <div class="container">
                <h2>Redefinir Senha</h2>
                <form action="/reset-password" method="POST">
                    <input type="hidden" name="token" value="${token}" />
                    <label for="newPassword">Nova Senha:</label>
                    <input type="password" name="newPassword" id="newPassword" required minlength="6" />
                    <button type="submit">Redefinir Senha</button>
                </form>
            </div>
        </body>
        </html>
    `);
});

// Rota POST para processar a nova senha
app.post('/reset-password', [
    check('token').not().isEmpty().withMessage('Token é obrigatório'),
    check('newPassword').isLength({ min: 6 }).withMessage('A nova senha deve ter pelo menos 6 caracteres')
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }

    const { token, newPassword } = req.body;

    // Verifica se o token é válido e se não expirou
    const sql = 'SELECT * FROM users WHERE reset_password_token = ? AND reset_password_expires > NOW()';
    db.query(sql, [token], async (err, results) => {
        if (err) {
            console.error('Erro ao buscar token no banco de dados:', err);
            return res.status(500).json({ error: 'Erro no servidor ao verificar token' });
        }

        if (results.length === 0) {
            return res.status(400).json({ error: 'Token inválido ou expirado' });
        }

        // Hash da nova senha e atualização no banco de dados
        const hashedPassword = await bcrypt.hash(newPassword, 10);
        const updatePasswordSql = 'UPDATE users SET senha = ?, reset_password_token = NULL, reset_password_expires = NULL WHERE reset_password_token = ?';

        db.query(updatePasswordSql, [hashedPassword, token], (err) => {
            if (err) {
                console.error('Erro ao atualizar senha no banco de dados:', err);
                return res.status(500).json({ error: 'Erro ao atualizar senha' });
            }

            res.status(200).json({ message: 'Senha atualizada com sucesso' });
        });
    });
});

// Iniciar o servidor
app.listen(port, () => {
    console.log(`Servidor rodando em http://localhost:${port}`);
});
