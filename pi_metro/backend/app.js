require('dotenv').config({ path: 'variaveis.env' });
const express = require('express');
const mysql = require('mysql2');
const cors = require('cors'); // Deve estar aqui apenas uma vez
const bcrypt = require('bcrypt');
const crypto = require('crypto');
const nodemailer = require('nodemailer');
const schedule = require('node-schedule');
const fileUpload = require('express-fileupload');
const fs = require('fs');
const path = require('path');
const QRCode = require('qrcode');
const moment = require('moment');
const PDFDocument = require('pdfkit');
const bodyParser = require('body-parser');
const { check, validationResult } = require('express-validator');

const app = express();
const port = 3000;


app.use(cors({
    origin: '*',
    methods: 'GET, POST, PUT, DELETE',
    allowedHeaders: 'Content-Type, Authorization',
}));

// Middleware
app.use(express.json()); // Processa JSON do body
app.use(express.urlencoded({ extended: true })); // Processa dados de formulário (opcional)
app.use(fileUpload());


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

app.get('/usuario', (req, res) => {
    const email = req.query.email; // Obtém o email da query string
    if (!email) {
        return res.status(400).json({ success: false, message: 'Email é obrigatório' });
    }

    const query = `
    SELECT usuarios.*, cargos.nome AS cargo
    FROM usuarios
    LEFT JOIN cargos ON usuarios.cargo_id = cargos.id
    WHERE usuarios.email = ?`;

    db.query(query, [email], (err, results) => {
        if (err) {
            console.error('Erro ao buscar usuário:', err);
            return res.status(500).json({ success: false, message: 'Erro ao buscar usuário' });
        }

        if (results.length === 0) {
            return res.status(404).json({ success: false, message: 'Usuário não encontrado' });
        }

        const usuario = results[0];
        // Corrigir a construção da URL da imagem
            ? `${req.protocol}://${req.get('host')}/${usuario.foto_perfil.replace(/\\/g, '/')}`
            : null; // Se não houver foto, defina como null

        res.json({ success: true, ...usuario, foto_perfil: urlImagem }); // Retorna a URL da imagem
    });
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



app.get('/patrimonio', (req, res) => {
    const query = 'SELECT patrimonio FROM extintores';
    db.query(query, (err, results) => {
        if (err) {
            console.error('Erro na consulta SQL:', err);
            res.status(500).json({ success: false, message: 'Erro na consulta ao banco de dados' });
            return;
        }

        const patrimônios = results.map(row => row.patrimonio);
        res.json({
            success: true,
            patrimônios: patrimônios,
        });
    });
});

app.get('/extintor/:patrimonio', (req, res) => {
    const patrimonio = req.params.patrimonio;
    console.log(`Recebendo requisição para buscar extintor com patrimônio: ${patrimonio}`);

    const query = `
    SELECT 
        e.Patrimonio, 
        e.Codigo_Fabricante, 
        e.Data_Fabricacao, 
        e.Data_Validade, 
        e.Ultima_Recarga, 
        e.Proxima_Inspecao, 
        e.QR_Code, 
        e.Observacoes AS Observacoes_Extintor,
        s.nome AS Status, 
        t.tipo AS Tipo, 
        c.descricao AS Capacidade, 
        l.Estacao AS Localizacao_Area,
        l.Descricao_Local AS Localizacao_Subarea,
        l.Observacoes AS Observacoes_Local,
        ln.nome AS Linha_Nome, 
        ln.codigo AS Linha_Codigo, 
        ln.descricao AS Linha_Descricao,
        hm.Data_Manutencao, 
        hm.Descricao AS Manutencao_Descricao, 
        hm.Responsavel_Manutencao, 
        hm.Observacoes AS Manutencao_Observacoes
    FROM extintores e
    JOIN status_extintor s ON e.status_id = s.id
    JOIN tipos_extintores t ON e.Tipo_ID = t.id
    JOIN capacidades c ON e.Capacidade_ID = c.id
    JOIN localizacoes l ON e.ID_Localizacao = l.ID_Localizacao
    LEFT JOIN linhas ln ON e.Linha_ID = ln.id
    LEFT JOIN historico_manutencao hm ON e.Patrimonio = hm.ID_Extintor
    WHERE e.Patrimonio = ?
    `;

    db.query(query, [patrimonio], (err, results) => {
        if (err) {
            console.error('Erro ao buscar extintor:', err);
            return res.status(500).json({ success: false, message: 'Erro ao buscar extintor' });
        }

        if (results.length === 0) {
            return res.status(404).json({ success: false, message: 'Extintor não encontrado' });
        }

        const extintor = results[0];
        extintor.QR_Code = `http://localhost:3000/uploads/${patrimonio}-qrcode.png`;
        console.log('Dados do extintor:', extintor);
        res.status(200).json({ success: true, extintor });
    });
});


app.get('/extintores', (req, res) => {
    const query = 'SELECT Patrimonio, Tipo_ID FROM Extintores';
    db.query(query, (err, results) => {
        if (err) {
            console.error('Erro ao buscar extintores: ' + err.stack);
            return res.status(500).json({ success: false, message: 'Erro ao buscar extintores' });
        }

        res.status(200).json({ success: true, extintores: results });
    });
});

app.get('/status', (req, res) => {
    const query = 'SELECT id, nome FROM Status_Extintor';

    db.query(query, (err, results) => {
        if (err) {
            console.error('Erro ao consultar status:', err);
            return res.status(500).json({ success: false, message: 'Erro ao buscar status' });
        }

        res.json({ success: true, data: results });
    });
});

app.get('/problemas', (req, res) => {
    const query = `
        SELECT 
            p.ID_Extintor AS patrimonio, 
            p.Problema, 
            p.Local, 
            p.Observacoes,
            e.status_id,
            s.nome AS Status
        FROM Problemas_Extintores p
        JOIN extintores e ON p.ID_Extintor = e.Patrimonio
        LEFT JOIN status_extintor s ON e.status_id = s.id
    `;

    db.query(query, (err, results) => {
        if (err) {
            console.error('Erro ao buscar problemas:', err);
            return res.status(500).json({ success: false, message: 'Erro ao buscar problemas' });
        }
        res.status(200).json({ success: true, problemas: results });
    });
});

app.get('/extintores-com-problemas', (req, res) => {
    const query = `
        SELECT DISTINCT e.Patrimonio, e.Tipo_ID 
        FROM Extintores e
        JOIN Problemas_Extintores p ON e.Patrimonio = p.ID_Extintor
    `;

    db.query(query, (err, results) => {
        if (err) {
            console.error('Erro ao buscar extintores com problemas:', err);
            return res.status(500).json({ success: false, message: 'Erro ao buscar extintores com problemas' });
        }

        res.status(200).json({ success: true, extintores: results });
    });
});

app.post('/excluir_problema', (req, res) => {
    const { patrimonio } = req.body;

    if (!patrimonio) {
        return res.status(400).json({ success: false, message: 'Patrimônio é obrigatório' });
    }

    const query = `
        DELETE FROM Problemas_Extintores 
        WHERE ID_Extintor = ?
    `;

    db.query(query, [patrimonio], (err) => {
        if (err) {
            console.error('Erro ao excluir problema:', err);
            return res.status(500).json({ success: false, message: 'Erro ao excluir problema' });
        }

        res.status(200).json({ success: true, message: 'Problema excluído com sucesso!' });
    });
});

app.get('/tipos-extintores', (req, res) => {
    const query = 'SELECT id, tipo AS nome FROM Tipos_Extintores';

    db.query(query, (err, results) => {
        if (err) {
            console.error('Erro ao consultar tipos de extintores:', err);
            return res.status(500).json({ success: false, message: 'Erro ao buscar tipos de extintores' });
        }

        res.json({ success: true, data: results });
    });
});

app.get('/localizacoes', (req, res) => {
    const linhaId = req.query.linhaId;
    if (!linhaId) {
        return res.status(400).json({ success: false, message: 'Linha ID é obrigatório' });
    }

    const query = `
    SELECT 
        ID_Localizacao AS id,
        Estacao AS nome,           -- Use 'Estacao' em vez de 'Area'
        Descricao_Local AS subarea, -- Use 'Descricao_Local' em vez de 'Subarea'
        Observacoes AS local_detalhado -- Use 'Observacoes' em vez de 'Local_Detalhado'
    FROM localizacoes
    WHERE Linha_ID = ?
`;
    db.query(query, [linhaId], (err, results) => {
        if (err) {
            console.error('Erro ao consultar localizações:', err);
            return res.status(500).json({ success: false, message: 'Erro ao buscar localizações' });
        }

        res.json({ success: true, data: results });
    });
});

app.get('/linhas', (req, res) => {
    const query = 'SELECT * FROM Linhas';

    db.query(query, (err, results) => {
        if (err) {
            console.error('Erro ao buscar linhas:', err);
            return res.status(500).json({ success: false, message: 'Erro ao buscar linhas' });
        }
        res.json({ success: true, data: results });
    });
});

app.get('/capacidades', (req, res) => {
    const query = 'SELECT id, descricao FROM capacidades';
    db.query(query, (err, results) => {
        if (err) {
            console.error('Erro ao consultar capacidades:', err);
            return res.status(500).json({ success: false, message: 'Erro ao buscar capacidades' });
        }

        res.json({ success: true, data: results });
    });
});

// Endpoint para buscar a localização do extintor
app.get('/extintor/localizacao/:patrimonio', (req, res) => {
    const patrimonio = req.params.patrimonio;

    const query = `
        SELECT 
            l.Estacao,
            l.Descricao_Local,
            l.Observacoes,
            ln.nome AS Linha
        FROM extintores e
        JOIN localizacoes l ON e.ID_Localizacao = l.ID_Localizacao
        JOIN linhas ln ON l.Linha_ID = ln.id
        WHERE e.Patrimonio = ?
    `;

    db.query(query, [patrimonio], (err, results) => {
        if (err) {
            console.error('Erro ao buscar localização do extintor:', err);
            return res.status(500).json({ success: false, message: 'Erro ao buscar localização do extintor' });
        }

        if (results.length === 0) {
            return res.status(404).json({ success: false, message: 'Extintor não encontrado' });
        }

        const localizacao = results[0];
        res.status(200).json({ success: true, localizacao });
    });
});

//Certifique-se de que a pasta "uploads" exista
const uploadsDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadsDir)) {
    fs.mkdirSync(uploadsDir);
}

const gerarSalvarQRCode = async (patrimonio) => {
    const qrCodeData = `http://localhost:3000/pdf/${patrimonio}`; // Link para o PDF do extintor
    const qrCodePath = path.join(uploadsDir, `${patrimonio}-qrcode.png`);

    await QRCode.toFile(qrCodePath, qrCodeData);
    console.log(`QR Code gerado e salvo em: ${qrCodePath}`);
    return qrCodePath; // Retorna o caminho do arquivo
};

app.post('/registrar_extintor', async (req, res) => {
    const {
        patrimonio,
        tipo_id,
        capacidade_id,
        codigo_fabricante,
        data_fabricacao,
        data_validade,
        ultima_recarga,
        proxima_inspecao,
        linha_id,
        estacao,
        descricao_local,
        observacoes_local,
        observacoes, // Observação do extintor
        status,
    } = req.body;

    try {
        // Primeiro, verifique se o extintor já existe
        const [extintorResult] = await db.promise().query('SELECT * FROM Extintores WHERE Patrimonio = ?', [patrimonio]);

        if (extintorResult.length > 0) {
            // Se o extintor já existe, faça a atualização
            const query = `
                UPDATE Extintores 
                SET 
                    Tipo_ID = ?, 
                    Capacidade_ID = ?, 
                    Codigo_Fabricante = ?, 
                    Data_Fabricacao = ?, 
                    Data_Validade = ?, 
                    Ultima_Recarga = ?, 
                    Proxima_Inspecao = ?, 
                    Linha_ID = ?, 
                    Observacoes = ? 
                WHERE Patrimonio = ?
            `;
            await db.promise().query(query, [
                tipo_id,
                capacidade_id,
                codigo_fabricante,
                moment(data_fabricacao, 'DD/MM/YYYY').format('YYYY-MM-DD'),
                moment(data_validade, 'DD/MM/YYYY').format('YYYY-MM-DD'),
                moment(ultima_recarga, 'DD/MM/YYYY').format('YYYY-MM-DD'),
                moment(proxima_inspecao, 'DD/MM/YYYY').format('YYYY-MM-DD'),
                linha_id,
                observacoes,
                patrimonio
            ]);

            res.json({ success: true, message: 'Extintor atualizado com sucesso!' });
        } else {
            // Se o extintor não existe, faça a inserção
            const localizacaoQuery = `
                INSERT INTO localizacoes (Linha_ID, Estacao, Descricao_Local, Observacoes)
                VALUES (?, ?, ?, ?)
            `;
            const localizacaoParams = [linha_id, estacao, descricao_local, observacoes_local];
            const [localizacaoResult] = await db.promise().query(localizacaoQuery, localizacaoParams);

            const id_localizacao = localizacaoResult.insertId; // Obter o ID da nova localização

            const query = `
                INSERT INTO Extintores 
                (Patrimonio, Tipo_ID, Capacidade_ID, Codigo_Fabricante, Data_Fabricacao, Data_Validade, Ultima_Recarga, Proxima_Inspecao, ID_Localizacao, Linha_ID, Status_ID, Observacoes) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            `;
            await db.promise().query(query, [
                patrimonio, tipo_id, capacidade_id, codigo_fabricante,
                moment(data_fabricacao, 'DD/MM/YYYY').format('YYYY-MM-DD'),
                moment(data_validade, 'DD/MM/YYYY').format('YYYY-MM-DD'),
                moment(ultima_recarga, 'DD/MM/YYYY').format('YYYY-MM-DD'),
                moment(proxima_inspecao, 'DD/MM/YYYY').format('YYYY-MM-DD'),
                id_localizacao, linha_id, status, observacoes // Observação do extintor
            ]);

            res.json({ success: true, message: 'Extintor registrado com sucesso!' });
        }
    } catch (err) {
        console.error('Erro ao registrar ou atualizar extintor:', err);
        res.status(500).json({ success: false, message: 'Erro ao registrar ou atualizar o extintor.' });
    }
});

// Endpoint para gerar o PDF
app.get('/pdf/:patrimonio', async (req, res) => {
    const patrimonio = req.params.patrimonio;

    try {
        // Recuperar os dados do extintor
        const [extintorResult] = await db.promise().query('SELECT * FROM Extintores WHERE Patrimonio = ?', [patrimonio]);
        if (extintorResult.length === 0) {
            return res.status(404).send('Extintor não encontrado.');
        }
        const data = extintorResult[0];

        // Recuperar informações adicionais
        const [tipoResult] = await db.promise().query('SELECT tipo FROM tipos_extintores WHERE id = ?', [data.Tipo_ID]);
        const tipoNome = tipoResult.length > 0 ? tipoResult[0].tipo : 'Tipo não encontrado';

        const [capacidadeResult] = await db.promise().query('SELECT descricao FROM capacidades WHERE id = ?', [data.Capacidade_ID]);
        const capacidadeDescricao = capacidadeResult.length > 0 ? capacidadeResult[0].descricao : 'Capacidade não encontrada';

        const [statusResult] = await db.promise().query('SELECT nome FROM status_extintor WHERE id = ?', [data.status_id]);
        const statusNome = statusResult.length > 0 ? statusResult[0].nome : 'Status não encontrado';

        const [linhaResult] = await db.promise().query('SELECT nome FROM linhas WHERE id = ?', [data.Linha_ID]);
        const linhaNome = linhaResult.length > 0 ? linhaResult[0].nome : 'Linha não encontrada';

        const [localizacaoResult] = await db.promise().query('SELECT Estacao, Descricao_Local, Observacoes FROM localizacoes WHERE ID_Localizacao = ?', [data.ID_Localizacao]);
        const localizacao = localizacaoResult.length > 0 ? localizacaoResult[0] : null;

        const localizacaoNome = localizacao ? `${localizacao.Estacao}, ${localizacao.Descricao_Local}` : 'Localização não encontrada';

        const dataFabricacaoFormatada = moment(data.Data_Fabricacao).format('DD/MM/YYYY');
        const dataValidadeFormatada = moment(data.Data_Validade).format('DD/MM/YYYY');
        const ultimaRecargaFormatada = moment(data.Ultima_Recarga).format('DD/MM/YYYY');
        const proximaInspecaoFormatada = moment(data.Proxima_Inspecao).format('DD/MM/YYYY');

        // Criar o PDF
        const doc = new PDFDocument();
        res.setHeader('Content-Type', 'application/pdf');
        doc.pipe(res);

        // Adicionando um título
        doc.fontSize(20).text('Relatório do Extintor', { align: 'center' }).moveDown();
        doc.moveTo(50, 50).lineTo(550, 50).stroke(); // Linha horizontal

        // Adicionando as informações do extintor
        doc.fontSize(12)
            .text(`Patrimônio: ${data.Patrimonio}`)
            .text(`Tipo: ${tipoNome}`)
            .text(`Capacidade: ${capacidadeDescricao}`)
            .text(`Código Fabricante: ${data.Codigo_Fabricante}`)
            .text(`Data de Fabricação: ${dataFabricacaoFormatada}`)
            .text(`Data de Validade: ${dataValidadeFormatada}`)
            .text(`Última Recarga: ${ultimaRecargaFormatada}`)
            .text(`Próxima Inspeção: ${proximaInspecaoFormatada}`)
            .text(`Linha: ${linhaNome}`)
            .text(`Localização: ${localizacaoNome}`)
            .text(`Status: ${statusNome}`)
            .text(`Observações: ${data.Observacoes}`)
            .moveDown();

        // Adicionando o histórico de manutenção
        doc.fontSize(14).text('Histórico de Manutenção:', { underline: true }).moveDown();
        const [historicoResult] = await db.promise().query('SELECT * FROM historico_manutencao WHERE ID_Extintor = ?', [data.Patrimonio]);
        if (historicoResult.length > 0) {
            historicoResult.forEach(h => {
                doc.text(`Data: ${moment(h.Data_Manutencao).format('DD/MM/YYYY')}, Descrição: ${h.Descricao}, Responsável: ${h.Responsavel_Manutencao}, Observações: ${h.Observacoes}`);
            });
        } else {
            doc.text('Nenhum histórico encontrado.');
        }

        doc.end();
    } catch (error) {
        console.error('Erro ao gerar PDF:', error);
        res.status(500).send('Erro ao gerar o PDF.');
    }
});

// Servir arquivos estáticos
app.use('/uploads', express.static(uploadsDir));

app.post('/salvar_manutencao', (req, res) => {
    const {
        patrimonio,
        descricao,
        responsavel,
        observacoes,
        data_manutencao,
        ultima_recarga,
        proxima_inspecao,
        data_vencimento,
        revisar_status
    } = req.body;

    if (!patrimonio || !descricao || !responsavel || !data_manutencao || !ultima_recarga || !proxima_inspecao || !data_vencimento) {
        return res.status(400).json({ success: false, message: 'Todos os campos são obrigatórios' });
    }

    const queryManutencao = `
        INSERT INTO Historico_Manutencao (ID_Extintor, Data_Manutencao, Descricao, Responsavel_Manutencao, Observacoes)
        VALUES (?, ?, ?, ?, ?)
    `;

    db.query(queryManutencao, [
        patrimonio,
        data_manutencao,
        descricao,
        responsavel,
        observacoes || '',
    ], (err) => {
        if (err) {
            console.error('Erro ao salvar manutenção: ' + err.stack);
            return res.status(500).json({ success: false, message: 'Erro ao salvar manutenção' });
        }

        const queryExtintores = `
            UPDATE Extintores
            SET Ultima_Recarga = ?, Proxima_Inspecao = ?, Data_Validade = ?
            WHERE Patrimonio = ?
        `;

        db.query(queryExtintores, [
            ultima_recarga,
            proxima_inspecao,
            data_vencimento,
            patrimonio
        ], (err2) => {
            if (err2) {
                console.error('Erro ao atualizar extintores: ' + err2.stack);
                return res.status(500).json({ success: false, message: 'Erro ao atualizar extintores' });
            }

            if (revisar_status) {
                const queryStatus = `
                    SELECT id FROM Status_Extintor WHERE nome = 'Ativo'
                `;

                db.query(queryStatus, [], (err3, result3) => {
                    if (err3) {
                        console.error('Erro ao buscar status: ' + err3.stack);
                        return res.status(500).json({ success: false, message: 'Erro ao buscar status' });
                    }

                    if (result3.length > 0) {
                        const status_id = result3[0].id;

                        const queryUpdateStatus = `
                            UPDATE Extintores
                            SET status_id = ?
                            WHERE Patrimonio = ?
                                `;

                        db.query(queryUpdateStatus, [status_id, patrimonio], (err4) => {
                            if (err4) {
                                console.error('Erro ao atualizar status do extintor: ' + err4.stack);
                                return res.status(500).json({ success: false, message: 'Erro ao atualizar status' });
                            }

                            res.status(200).json({ success: true, message: 'Manutenção salva, dados atualizados e status alterado com sucesso!' });
                        });
                    } else {
                        console.error('Status "Ativo" não encontrado na tabela Status_Extintor');
                        return res.status(500).json({ success: false, message: 'Status "Ativo" não encontrado' });
                    }
                });
            } else {
                res.status(200).json({ success: true, message: 'Manutenção salva e dados atualizados com sucesso!' });
            }
        });
    });
});

app.put('/extintor/:patrimonio', async (req, res) => {
    const patrimonio = req.params.patrimonio;
    const {
        codigo_fabricante,
        data_fabricacao,
        data_validade,
        ultima_recarga,
        proxima_inspecao,
        tipo_id,
        linha_id,
        status_id,
        observacoes,
    } = req.body;

    try {
        const query = `
            UPDATE Extintores
            SET 
                Codigo_Fabricante = ?,
                Data_Fabricacao = ?,
                Data_Validade = ?,
                Ultima_Recarga = ?,
                Proxima_Inspecao = ?,
                Tipo_ID = ?,
                Linha_ID = ?,
                Status_ID = ?,
                Observacoes = ?
            WHERE Patrimonio = ?
        `;

        await db.promise().query(query, [
            codigo_fabricante,
            moment(data_fabricacao, 'DD/MM/YYYY').format('YYYY-MM-DD'),
            moment(data_validade, 'DD/MM/YYYY').format('YYYY-MM-DD'),
            moment(ultima_recarga, 'DD/MM/YYYY').format('YYYY-MM-DD'),
            moment(proxima_inspecao, 'DD/MM/YYYY').format('YYYY-MM-DD'),
            tipo_id,
            linha_id,
            status_id,
            observacoes,
            patrimonio
        ]);

        // Após a atualização do extintor, obtenha a Descricao_Local
        const [localizacaoResult] = await db.promise().query('SELECT Descricao_Local FROM localizacoes WHERE ID_Localizacao = (SELECT ID_Localizacao FROM Extintores WHERE Patrimonio = ?)', [patrimonio]);
        const descricaoLocal = localizacaoResult.length > 0 ? localizacaoResult[0].Descricao_Local : 'Descrição não encontrada';

        console.log('Descrição do Local:', descricaoLocal); // Você pode usar essa descrição conforme necessário

        res.json({ success: true, message: 'Extintor atualizado com sucesso!', descricaoLocal: descricaoLocal });
    } catch (error) {
        console.error('Erro ao atualizar extintor:', error);
        res.status(500).json({ success: false, message: 'Erro ao atualizar o extintor.' });
    }
});

app.post('/registrar_problema', (req, res) => {
    const { patrimonio, Problema, local, observacoes } = req.body;

    if (!patrimonio || !Problema || !local) {
        return res.status(400).json({ success: false, message: 'Todos os campos são obrigatórios' });
    }

    // Verifica se já existe um problema registrado para o patrimônio
    const checkQuery = `
        SELECT COUNT(*) AS count FROM Problemas_Extintores WHERE ID_Extintor = ?
    `;

    db.query(checkQuery, [patrimonio], (err, results) => {
        if (err) {
            console.error('Erro ao verificar problemas registrados:', err);
            return res.status(500).json({ success: false, message: 'Erro ao verificar problemas registrados' });
        }

        if (results[0].count > 0) {
            return res.status(400).json({ success: false, message: 'Já existe um problema registrado para este patrimônio.' });
        }

        // Se não houver problemas registrados, insira o novo problema
        const query = `
            INSERT INTO Problemas_Extintores (ID_Extintor, Problema, Local, Observacoes)
            VALUES (?, ?, ?, ?)
        `;

        db.query(query, [patrimonio, Problema, local, observacoes], (err) => {
            if (err) {
                console.error('Erro ao registrar problema:', err);
                return res.status(500).json({ success: false, message: 'Erro ao registrar problema' });
            }

            res.status(200).json({ success: true, message: 'Problema registrado com sucesso!' });
        });
    });
});

// Certifique-se de que a pasta "image_perfil" exista
const profileImagesDir = path.join(__dirname, 'image_perfil');
if (!fs.existsSync(profileImagesDir)) {
    fs.mkdirSync(profileImagesDir);
}
app.use('/image_perfil', express.static(profileImagesDir));
app.post('/upload', async (req, res) => {
    const { usuario_id } = req.body; // ID do usuário

    if (!usuario_id) {
        return res.status(400).json({ success: false, message: 'ID do usuário é obrigatório' });
    }

    const file = req.files.image; // A imagem enviada

    if (!file) {
        return res.status(400).json({ success: false, message: 'Imagem é obrigatória' });
    }

    try {
        // Primeiro, busque a imagem anterior do usuário
        const [usuarioResult] = await db.promise().query('SELECT foto_perfil FROM usuarios WHERE id = ?', [usuario_id]);
        if (usuarioResult.length > 0) {
            const fotoPerfilAnterior = usuarioResult[0].foto_perfil;
            if (fotoPerfilAnterior) {
                // Exclua a imagem anterior
                const caminhoAnterior = path.join(__dirname, fotoPerfilAnterior);
                if (fs.existsSync(caminhoAnterior)) {
                    fs.unlinkSync(caminhoAnterior); // Exclui a imagem anterior
                }
            }
        }

        // Salvar a nova imagem no diretório 'image_perfil'
        const fileName = `${Date.now()}-${file.name}`;
        const filePath = path.join(profileImagesDir, fileName);
        await fs.promises.writeFile(filePath, file.data); // Salva o arquivo

        // Atualizar o caminho da nova imagem no banco de dados
        const relativePath = path.join('image_perfil', fileName); // Caminho relativo
        const query = 'UPDATE usuarios SET foto_perfil = ? WHERE id = ?';
        await db.promise().query(query, [relativePath, usuario_id]);

        res.json({ success: true, message: 'Imagem salva com sucesso!', filePath: relativePath });
    } catch (error) {
        console.error('Erro ao fazer upload da imagem:', error);
        res.status(500).json({ success: false, message: 'Erro ao fazer upload da imagem' });
    }
});



app.post('/reportar-erro', async (req, res) => {
    const { usuarioEmail, erroDescricao } = req.body;

    if (!usuarioEmail || !erroDescricao) {
        return res.status(400).json({ success: false, message: 'E-mail do usuário e descrição do erro são obrigatórios.' });
    }

    try {
        // Configura os detalhes do e-mail
        const mailOptions = {
            from: usuarioEmail, // E-mail do usuário logado
            to: 'suporte.redefinir.senha.imt.pi@gmail.com', // e-mail de destino (suporte ou outro)
            subject: 'Relato de Erro - Aplicativo',
            text: `Erro reportado por: ${usuarioEmail}\n\nDescrição do erro: ${erroDescricao}`
        };

        // Envia o e-mail
        await transporter.sendMail(mailOptions);
        res.status(200).json({ success: true, message: 'Erro reportado com sucesso!' });
    } catch (error) {
        console.error('Erro ao reportar erro:', error);
        res.status(500).json({ success: false, message: 'Falha ao reportar erro.' });
    }
});

// Inicia o servidor
app.listen(port, () => {
    console.log(`Servidor rodando em http://localhost:${port}`);
});
