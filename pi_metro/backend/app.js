const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const cors = require('cors');
const bcrypt = require('bcrypt'); // Para hashing de senhas

const app = express();
const port = 3000;

// Middleware para interpretar JSON e habilitar CORS
app.use(cors());
app.use(bodyParser.json());

// Conexão com o MySQL
const db = mysql.createConnection({
    host: 'localhost',
    user: 'rodrigo_pi',
    password: 'PiMetro123', // Coloque sua senha
    database: 'fire_equipment_management_metro', // Coloque o nome correto do banco de dados
});

db.connect(err => {
    if (err) {
        console.error('Erro ao conectar ao MySQL:', err);
    } else {
        console.log('Conectado ao MySQL!');
    }
});

// Rota para registrar usuários
app.post('/cadastro', async (req, res) => {
    const {email, senha } = req.body;

    try {
        // Hash da senha antes de armazenar
        const hashedPassword = await bcrypt.hash(senha, 10);

        const sql = 'INSERT INTO users (email, senha) VALUES (?, ?)';
        
        db.query(sql, [email, hashedPassword], (err, result) => {
            if (err) {
                console.error('Erro ao inserir usuário:', err);
                res.status(500).send('Erro ao registrar usuário');
            } else {
                res.status(200).send('Usuário registrado com sucesso');
            }
        });
    } catch (err) {
        console.error('Erro ao registrar usuário:', err);
        res.status(500).send('Erro no servidor ao registrar usuário');
    }
});

// Rota para verificar login e senha
app.post('/login', (req, res) => {
    const { email, senha } = req.body;

    const sql = 'SELECT * FROM users WHERE email = ?';
    
    db.query(sql, [email, email], (err, result) => {
        if (err) {
            console.error('Erro ao buscar usuário:', err);
            res.status(500).send('Erro no servidor.');
            return;
        }

        if (result.length > 0) {
            // Comparar senha fornecida com a senha armazenada no banco de dados
            bcrypt.compare(senha, result[0].senha, (err, isMatch) => {
                if (isMatch) {
                    res.status(200).send('Login bem-sucedido.');
                } else {
                    res.status(401).send('Credenciais inválidas.');
                }
            });
        } else {
            res.status(401).send('Credenciais inválidas.');
        }
    });
});

// Iniciar o servidor
app.listen(port, () => {
    console.log(`Servidor rodando em http://localhost:${port}`);
});
