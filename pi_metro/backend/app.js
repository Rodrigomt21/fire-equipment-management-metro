require('dotenv').config({ path: 'variaveis.env' });
const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const bcrypt = require('bcrypt'); // Para hashing de senhas
const crypto = require('crypto'); // Para geração de tokens seguros
const nodemailer = require('nodemailer'); // Para envio de emails
const schedule = require('node-schedule');

const app = express();
const port = 3000;

// Middleware
app.use(cors());
app.use(express.json()); // Processa JSON do body
app.use(express.urlencoded({ extended: true })); // Processa dados de formulário (opcional)

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

const transporter = nodemailer.createTransport({
    host: process.env.EMAIL_HOST,
    port: parseInt(process.env.EMAIL_PORT, 10),
    secure: false, // true para 465, false para outras portas
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
    },
});

transporter.verify((error, success) => {
    if (error) {
        console.error('Erro ao conectar ao servidor SMTP:', error);
    } else {
        console.log('Conexão SMTP estabelecida com sucesso!');
    }
});


app.post('/cadastro', async (req, res) => {
    console.log('Dados recebidos no cadastro:', req.body); // Log para verificar o corpo da requisição

    const { nome, email, senha } = req.body;
    const matricula = req.body.matricula || null;
    const cargo_id = req.body.cargo_id || null;

    if (!nome || !email || !senha || senha.length < 6) {
        console.error('Erro: Dados inválidos ou incompletos.');
        return res.status(400).json({ error: 'Nome, email e senha são obrigatórios e a senha deve ter pelo menos 6 caracteres.' });
    }

    try {
        const hashedPassword = await bcrypt.hash(senha, 10);
        const sql = `
            INSERT INTO usuarios (nome, email, senha, matricula, cargo_id) 
            VALUES (?, ?, ?, ?, ?)`;

        db.query(sql, [nome, email, hashedPassword, matricula, cargo_id], (err, result) => {
            if (err) {
                console.error('Erro ao registrar usuário:', err.message);
                if (err.code === 'ER_DUP_ENTRY') {
                    const campo = err.sqlMessage.includes('email') ? 'email' : 'matricula';
                    return res.status(400).json({ error: `O ${campo} já está em uso.` });
                }
                return res.status(500).json({ error: 'Erro ao registrar usuário.' });
            }

            console.log('Usuário registrado com sucesso:', result);
            res.status(200).json({ message: 'Usuário registrado com sucesso.' });
        });
    } catch (err) {
        console.error('Erro no servidor:', err.message);
        res.status(500).json({ error: 'Erro no servidor.' });
    }
});




// Buscar usuário
app.post('/login', (req, res) => {
    const { email, senha } = req.body;

    if (!email || !senha) {
        return res.status(400).json({ message: 'Email e senha são obrigatórios.' });
    }

    const sql = 'SELECT * FROM usuarios WHERE email = ?';
    db.query(sql, [email], async (err, results) => {
        if (err) {
            console.error('Erro ao buscar usuário:', err);
            return res.status(500).json({ message: 'Erro no servidor.' });
        }

        if (results.length === 0) {
            return res.status(401).json({ message: 'Email ou senha incorretos.' });
        }

        const user = results[0];
        const isPasswordMatch = await bcrypt.compare(senha, user.senha);

        if (!isPasswordMatch) {
            return res.status(401).json({ message: 'Email ou senha incorretos.' });
        }

        res.status(200).json({ nomeCompleto: user.nome });
    });
});


// Atualizar notificações
app.get('/notificacoes', (req, res) => {
    const sql = `
        SELECT n.id, n.mensagem, n.data_criacao, n.status
        FROM notificacoes n
        JOIN extintores e ON n.equipamento_id = e.Patrimonio
        ORDER BY n.data_criacao DESC;
    `;

    db.query(sql, [], (err, resultados) => {
        if (err) {
            console.error('Erro ao buscar notificações:', err);
            return res.status(500).json({ error: 'Erro ao buscar notificações.' });
        }
        res.status(200).json(resultados);
    });
});

// Agendamento de notificações
schedule.scheduleJob('0 8 * * *', () => {
    const hoje = new Date();
    const trintaDias = new Date();
    const dezDias = new Date();
    trintaDias.setDate(hoje.getDate() + 30);
    dezDias.setDate(hoje.getDate() + 10);

    const sql = `
        SELECT e.Patrimonio, e.Tipo_ID, e.Data_Validade, l.nome AS Linha_Nome, u.email
        FROM extintores e
        LEFT JOIN localizacoes l ON e.ID_Localizacao = l.ID_Localizacao
        LEFT JOIN usuarios u ON l.Linha_ID = u.id
        WHERE e.Data_Validade BETWEEN ? AND ?
    `;

    db.query(sql, [hoje, trintaDias], (err, resultados) => {
        if (err) {
            return console.error('Erro ao buscar equipamentos:', err);
        }

        resultados.forEach(extintor => {
            const mensagem = `Extintor ${extintor.Patrimonio} em ${extintor.Linha_Nome} está próximo do vencimento.`;
            const inserirNotificacaoSql = `
                INSERT INTO notificacoes (equipamento_id, mensagem)
                VALUES (?, ?)`;
            db.query(inserirNotificacaoSql, [extintor.Patrimonio, mensagem], (err) => {
                if (err) return console.error('Erro ao inserir notificação:', err);
            });
        });
    });
});


app.post('/forgot-password', (req, res) => {
    const { email } = req.body;

    if (!email) {
        return res.status(400).json({ error: 'Email é obrigatório.' });
    }

    const sql = 'SELECT * FROM usuarios WHERE email = ?';
    db.query(sql, [email], (err, results) => {
        if (err) {
            console.error('Erro ao buscar email:', err);
            return res.status(500).json({ error: 'Erro no servidor.' });
        }

        if (results.length === 0) {
            return res.status(404).json({ error: 'Email não encontrado.' });
        }

        const token = crypto.randomBytes(20).toString('hex');
        const tokenExpiration = new Date(Date.now() + 3600000); // Expira em 1 hora

        const updateTokenSql = `
            UPDATE usuarios SET reset_password_token = ?, reset_password_expires = ? WHERE email = ?`;
        db.query(updateTokenSql, [token, tokenExpiration, email], (err) => {
            if (err) {
                console.error('Erro ao salvar token:', err);
                return res.status(500).json({ error: 'Erro ao salvar token de recuperação.' });
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
                    return res.status(500).json({ error: 'Erro ao enviar email.' });
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
        return res.status(400).json({ error: 'Token inválido ou senha muito curta.' });
    }

    const sql = `
        SELECT * FROM usuarios 
        WHERE reset_password_token = ? 
        AND reset_password_expires > NOW()`;
    db.query(sql, [token], async (err, results) => {
        if (err) {
            console.error('Erro ao buscar token:', err);
            return res.status(500).json({ error: 'Erro no servidor ao validar token.' });
        }

        if (results.length === 0) {
            return res.status(400).json({ error: 'Token inválido ou expirado.' });
        }

        const hashedPassword = await bcrypt.hash(newPassword, 10);
        const updatePasswordSql = `
            UPDATE usuarios 
            SET senha = ?, reset_password_token = NULL, reset_password_expires = NULL 
            WHERE reset_password_token = ?`;
        db.query(updatePasswordSql, [hashedPassword, token], (err) => {
            if (err) {
                console.error('Erro ao atualizar senha:', err);
                return res.status(500).json({ error: 'Erro ao atualizar senha.' });
            }

            // Sempre retornando JSON
            res.status(200).json({
                message: 'Sua senha foi atualizada com sucesso. Faça login novamente.',
            });
        });
    });
});



app.get('/notificacoes', (req, res) => {
    const { userId } = req.query;

    const sql = `
    SELECT n.id, n.mensagem, n.data_criacao, n.status
        FROM notificacoes n
        JOIN equipamentequipamentos e ON n.equipamento_id = e.id
        ORDER BY n.data_criacao DESC;
    `;


    db.query(sql, [userId], (err, resultados) => {
        if (err) {
            console.error('Erro ao buscar notificações:', err);
            return res.status(500).json({ error: 'Erro ao buscar notificações.' });
        }
        res.status(200).json(resultados);
    });
});


schedule.scheduleJob('0 8 * * *', () => {
    const hoje = new Date();
    const trintaDias = new Date();
    const dezDias = new Date();
    trintaDias.setDate(hoje.getDate() + 30);
    dezDias.setDate(hoje.getDate() + 10);

    const sql = `
        SELECT e.id AS equipamento_id, e.nome AS equipamento_nome, e.proprietario_email, 
               e.proxRecManut, e.proxRetEXT
        FROM equipamentequipamentos e
        WHERE e.proxRecManut BETWEEN ? AND ? 
           OR e.proxRetEXT BETWEEN ? AND ?`;

    db.query(sql, [hoje, trintaDias, hoje, dezDias], (err, resultados) => {
        if (err) {
            return console.error('Erro ao buscar equipamentos:', err);
        }

        resultados.forEach(equipamento => {
            const { equipamento_id, equipamento_nome, proxRecManut, proxRetEXT, proprietario_email } = equipamento;

            const mensagens = [];
            if (proxRecManut && proxRecManut <= trintaDias) {
                mensagens.push(`Manutenção do equipamento ${equipamento_nome} está prevista em 30 dias.`);
            }
            if (proxRetEXT && proxRetEXT <= dezDias) {
                mensagens.push(`Equipamento ${equipamento_nome} está prestes a vencer.`);
            }

            mensagens.forEach(mensagem => {
                // Inserir notificação no banco
                const inserirNotificacaoSql = `
                    INSERT INTO notificacoes (equipamento_id, mensagem)
                    VALUES (?, ?)`;
                db.query(inserirNotificacaoSql, [equipamento_id, mensagem], (err) => {
                    if (err) return console.error('Erro ao inserir notificação:', err);
                });

                // Enviar e-mail
                const mailOptions = {
                    from: process.env.EMAIL_USER,
                    to: proprietario_email,
                    subject: 'Notificação de Equipamento',
                    text: mensagem,
                };

                transporter.sendMail(mailOptions, (err) => {
                    if (err) return console.error('Erro ao enviar email:', err);
                });
            });
        });
    });
});

app.post('/notificacoes/:id/markAsRead', (req, res) => {
    const { id } = req.params;
    const sql = `UPDATE notificacoes SET status = 'lida' WHERE id = ?`;

    db.query(sql, [id], (err, result) => {
        if (err) {
            console.error('Erro ao marcar notificação como lida:', err);
            return res.status(500).json({ error: 'Erro ao marcar notificação como lida.' });
        }
        res.status(200).json({ message: 'Notificação marcada como lida.' });
    });
});

app.post('/notificacoes/:id/markAsUnread', (req, res) => {
    const { id } = req.params;
    const sql = `UPDATE notificacoes SET status = 'não lida' WHERE id = ?`;

    db.query(sql, [id], (err, result) => {
        if (err) {
            console.error('Erro ao marcar notificação como não lida:', err);
            return res.status(500).json({ error: 'Erro ao marcar notificação como não lida.' });
        }
        res.status(200).json({ message: 'Notificação marcada como não lida.' });
    });
});


// Inicia o servidor
app.listen(port, () => {
    console.log(`Servidor rodando em http://localhost:${port}`);
});
