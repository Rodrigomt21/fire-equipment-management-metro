require('dotenv').config({ path: 'variaveis.env' });
const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const bcrypt = require('bcrypt'); // Para hashing de senhas
const crypto = require('crypto'); // Para geração de tokens seguros
const nodemailer = require('nodemailer'); // Para envio de emails

const app = express();
const port = 3000;

// Middleware
app.use(cors());
app.use(express.json()); // Processa JSON do body
app.use(express.urlencoded({ extended: true })); // Processa dados de formulário (opcional)

// Conexão com o banco de dados MySQL
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

// Configuração do Nodemailer
const transporter = nodemailer.createTransport({
    host: process.env.EMAIL_HOST,
    port: process.env.EMAIL_PORT,
    secure: false, // true para 465, false para outras portas
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
    },
});

// Registro de usuário
app.post('/cadastro', async (req, res) => {
    const { nomeCompleto, email, senha } = req.body;

    if (!nomeCompleto || !email || !senha || senha.length < 6) {
        return res.status(400).json({ error: 'Dados inválidos ou senha muito curta.' });
    }

    try {
        const hashedPassword = await bcrypt.hash(senha, 10);
        const sql = 'INSERT INTO users (nomeCompleto, email, senha) VALUES (?, ?, ?)';

        db.query(sql, [nomeCompleto, email, hashedPassword], (err, result) => {
            if (err) {
                console.error('Erro ao registrar usuário:', err);
                return res.status(500).json({ error: 'Erro ao registrar usuário' });
            }
            res.status(200).send('Usuário registrado com sucesso.');
        });
    } catch (err) {
        console.error('Erro no servidor:', err);
        res.status(500).json({ error: 'Erro no servidor' });
    }
});

// Buscar dados do usuário por email
app.get('/usuario', (req, res) => {
    const { email } = req.query;

    if (!email) {
        return res.status(400).json({ error: 'Email é obrigatório.' });
    }

    const sql = 'SELECT nomeCompleto FROM users WHERE email = ?';
    db.query(sql, [email], (err, results) => {
        if (err) {
            console.error('Erro ao buscar usuário:', err);
            return res.status(500).json({ error: 'Erro ao buscar usuário.' });
        }

        if (results.length === 0) {
            return res.status(404).json({ error: 'Usuário não encontrado.' });
        }

        res.status(200).json({ nomeCompleto: results[0].nomeCompleto });
    });
});


// Login
app.post('/login', (req, res) => {
    const { email, senha } = req.body;

    if (!email || !senha) {
        return res.status(400).json({ status: false, message: 'Email e senha são obrigatórios.' });
    }

    const sql = 'SELECT * FROM users WHERE email = ?';
    db.query(sql, [email], (err, results) => {
        if (err) {
            console.error('Erro ao buscar usuário:', err);
            return res.status(500).json({ status: false, message: 'Erro no servidor ao buscar usuário' });
        }

        if (results.length === 0) {
            return res.status(401).json({ status: false, message: 'Credenciais inválidas.' });
        }

        const user = results[0];
        bcrypt.compare(senha, user.senha, (err, isMatch) => {
            if (err || !isMatch) {
                return res.status(401).json({ status: false, message: 'Credenciais inválidas.' });
            }
            res.status(200).json({ status: true, message: 'Login bem-sucedido.', nomeCompleto: user.nomeCompleto });
        });
    });
});

app.post('/forgot-password', (req, res) => {
    const { email } = req.body;

    if (!email) {
        return res.status(400).json({ error: 'Email é obrigatório.' });
    }

    const sql = 'SELECT * FROM users WHERE email = ?';
    db.query(sql, [email], (err, results) => {
        if (err) {
            console.error('Erro ao buscar email:', err);
            return res.status(500).json({ error: 'Erro no servidor' });
        }

        if (results.length === 0) {
            return res.status(404).json({ error: 'Email não encontrado.' });
        }

        const token = crypto.randomBytes(20).toString('hex');
        const tokenExpiration = new Date(Date.now() + 3600000); // 1 hora

        const updateTokenSql = `
            UPDATE users SET reset_password_token = ?, reset_password_expires = ? WHERE email = ?`;
        db.query(updateTokenSql, [token, tokenExpiration, email], (err) => {
            if (err) {
                console.error('Erro ao salvar token:', err);
                return res.status(500).json({ error: 'Erro ao salvar token de recuperação' });
            }

            const resetUrl = `${process.env.FRONTEND_URL}/reset-password?token=${token}`;
            const mailOptions = {
                from: process.env.EMAIL_USER,
                to: email,
                subject: 'Recuperação de senha',
                text: `Clique no link para redefinir sua senha: ${resetUrl}`,
                html: `<p>Clique no link para redefinir sua senha:</p><p><a href="${resetUrl}">Redefinir senha</a></p>`,
            };

            transporter.sendMail(mailOptions, (err) => {
                if (err) {
                    console.error('Erro ao enviar email:', err);
                    return res.status(500).json({ error: 'Erro ao enviar email' });
                }
                res.status(200).json({ message: 'Email de recuperação enviado.' });
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

    res.send(`
        <!DOCTYPE html>
        <html lang="pt-BR">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Redefinir Senha</title>
            <style>
                body { font-family: Arial, sans-serif; display: flex; align-items: center; justify-content: center; height: 100vh; margin: 0; background-color: #f4f4f4; }
                .container { width: 100%; max-width: 400px; padding: 20px; border: 1px solid #ccc; border-radius: 5px; box-shadow: 0 0 10px rgba(0, 0, 0, 0.1); background: #fff; }
                h2 { text-align: center; color: #333; }
                label { display: block; margin-top: 10px; font-size: 14px; color: #333; }
                input[type="password"], button { width: 100%; padding: 10px; margin-top: 10px; border-radius: 5px; border: 1px solid #ddd; }
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

app.post('/reset-password', async (req, res) => {
    const { token, newPassword } = req.body;

    if (!token || !newPassword || newPassword.length < 6) {
        return res.send(`
            <!DOCTYPE html>
            <html lang="pt-BR">
            <head>
                <meta charset="UTF-8">
                <title>Erro na Redefinição de Senha</title>
                <style>
                    body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }
                    .error { color: red; }
                </style>
            </head>
            <body>
                <h2 class="error">Token inválido ou senha muito curta.</h2>
                <a href="/reset-password?token=${token}">Tente novamente</a>
            </body>
            </html>
        `);
    }

    const sql = 'SELECT * FROM users WHERE reset_password_token = ? AND reset_password_expires > NOW()';
    db.query(sql, [token], async (err, results) => {
        if (err) {
            console.error('Erro ao buscar token:', err);
            return res.send(`
                <!DOCTYPE html>
                <html lang="pt-BR">
                <head>
                    <meta charset="UTF-8">
                    <title>Erro no Servidor</title>
                    <style>
                        body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }
                        .error { color: red; }
                    </style>
                </head>
                <body>
                    <h2 class="error">Erro no servidor. Por favor, tente novamente mais tarde.</h2>
                </body>
                </html>
            `);
        }

        if (results.length === 0) {
            return res.send(`
                <!DOCTYPE html>
                <html lang="pt-BR">
                <head>
                    <meta charset="UTF-8">
                    <title>Token Inválido ou Expirado</title>
                    <style>
                        body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }
                        .error { color: red; }
                    </style>
                </head>
                <body>
                    <h2 class="error">Token inválido ou expirado.</h2>
                    <a href="/forgot-password">Solicitar novo token</a>
                </body>
                </html>
            `);
        }

        const hashedPassword = await bcrypt.hash(newPassword, 10);
        const updatePasswordSql = `
            UPDATE users SET senha = ?, reset_password_token = NULL, reset_password_expires = NULL WHERE reset_password_token = ?`;
        db.query(updatePasswordSql, [hashedPassword, token], (err) => {
            if (err) {
                console.error('Erro ao atualizar senha:', err);
                return res.send(`
                    <!DOCTYPE html>
                    <html lang="pt-BR">
                    <head>
                        <meta charset="UTF-8">
                        <title>Erro ao Atualizar Senha</title>
                        <style>
                            body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }
                            .error { color: red; }
                        </style>
                    </head>
                    <body>
                        <h2 class="error">Erro ao atualizar senha. Tente novamente mais tarde.</h2>
                    </body>
                    </html>
                `);
            }

            res.send(`
                <!DOCTYPE html>
                <html lang="pt-BR">
                <head>
                    <meta charset="UTF-8">
                    <title>Senha Atualizada</title>
                    <style>
                        body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }
                        .success { color: green; }
                    </style>
                </head>
                <body>
                    <h2 class="success">Senha atualizada com sucesso!</h2>
                </body>
                </html>
            `);
        });
    });
});


// Inicia o servidor
app.listen(port, () => {
    console.log(`Servidor rodando em http://localhost:${port}`);
});
