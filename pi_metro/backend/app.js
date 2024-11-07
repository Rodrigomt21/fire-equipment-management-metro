require('dotenv').config({path: 'variaveis.env'}); // Importa variáveis de ambiente
const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const cors = require('cors');
const bcrypt = require('bcrypt'); // Para hashing de senhas
const rateLimit = require('express-rate-limit'); // Limite de tentativas de login
const { check, validationResult } = require('express-validator'); // Validação de entrada

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

// Rota para registrar usuários com validação de entrada
app.post('/cadastro', [
    check('email').isEmail().withMessage('Email inválido'),
    check('senha').isLength({ min: 6 }).withMessage('Senha precisa ter ao menos 6 caracteres')
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }

    const { email, senha } = req.body;

    try {
        // Hash da senha antes de armazenar
        const hashedPassword = await bcrypt.hash(senha, 10);

        const sql = 'INSERT INTO users (email, senha) VALUES (?, ?)';
        
        db.query(sql, [email, hashedPassword], (err, result) => {
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

// Iniciar o servidor
app.listen(port, () => {
    console.log(`Servidor rodando em http://localhost:${port}`);
});
