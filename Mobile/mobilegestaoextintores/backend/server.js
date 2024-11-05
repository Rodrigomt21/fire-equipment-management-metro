const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const PORT = 3001;

app.use(bodyParser.json());

app.use(cors());

// Configuração do banco de dados
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'imtdb',
    database: 'metro_ext',
});

// Conectar ao banco de dados
db.connect((err) => {
    if (err) {
        console.error('Erro ao conectar ao banco de dados:', err);
        return;
    }
    console.log('Conectado ao banco de dados MySQL');
});

// Rota de login
app.post('/login', (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({ success: false, message: 'Campos obrigatórios faltando' });
    }

    // Consulta ao banco de dados para verificar se o usuário existe
    const query = 'SELECT nome FROM usuarios WHERE email = ? AND senha = ?'; 
    db.query(query, [email, password], (err, results) => {
        if (err) {
            console.error('Erro ao consultar o banco de dados:', err);
            return res.status(500).json({ success: false, message: 'Erro ao consultar o banco de dados' });
        }

        if (results.length > 0) {
            const nomeUsuario = results[0].nome;
            return res.status(200).json({ success: true, message: 'Login bem-sucedido', nome: nomeUsuario }); 
            return res.status(401).json({ success: false, message: 'Credenciais inválidas' });
        }
    });
});

app.get('/usuario', (req, res) => {
    const email = req.query.email; 

    if (!email) {
        return res.status(400).json({ success: false, message: 'Email é obrigatório' });
    }

    const query = 'SELECT nome, matricula, cargo FROM usuarios WHERE email = ?'; 
    db.query(query, [email], (err, results) => {
        if (err) {
            console.error('Erro ao consultar o banco de dados:', err);
            return res.status(500).json({ success: false, message: 'Erro ao consultar o banco de dados' });
        }

        if (results.length > 0) {
            return res.status(200).json({ 
                success: true, 
                nome: results[0].nome, 
                matricula: results[0].matricula,
                cargo: results[0].cargo 
            }); 
        } else {
            return res.status(404).json({ success: false, message: 'Usuário não encontrado' });
        }
    });
});


// Iniciar o servidor
app.listen(PORT, () => {
    console.log(`Servidor rodando em http://localhost:${PORT}`);
});
