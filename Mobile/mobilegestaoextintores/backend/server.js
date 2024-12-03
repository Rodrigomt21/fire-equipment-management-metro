const fs = require('fs');
const mysql = require('mysql2');
const cors = require('cors');
const PDFDocument = require('pdfkit');
const express = require('express');
const bodyParser = require('body-parser');
const QRCode = require('qrcode');
const path = require('path');
const moment = require('moment');
const { check, validationResult } = require('express-validator');
const bcrypt = require('bcrypt');
const crypto = require('crypto');
const nodemailer = require('nodemailer'); // Importação única
const fileUpload = require('express-fileupload');
require('dotenv').config(); // Importa dotenv
const app = express();

// Middleware para manipulação de arquivos

// Configuração do banco de dados
const db = mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
});


async function inserirUsuario(nome, email, senha, matricula, cargo_id) {
    try {
        // Criptografar a senha
        const hashedPassword = await bcrypt.hash(senha, 10);

        // Inserir o usuário na tabela
        const query = `
            INSERT INTO usuarios (nome, email, senha, matricula, cargo_id) 
            VALUES (?, ?, ?, ?, ?)
        `;
        const params = [nome, email, hashedPassword, matricula, cargo_id];

        db.query(query, params, (err, results) => {
            if (err) {
                console.error('Erro ao inserir usuário:', err);
                return;
            }
            console.log('Usuário inserido com sucesso:', results.insertId);
        });
    } catch (error) {
        console.error('Erro ao criptografar a senha:', error);
    }
}

db.connect((err) => {
    if (err) {
        console.error('Erro ao conectar ao banco de dados:', err);
        return;
    }
    console.log('Conectado ao banco de dados MySQL');
    inserirUsuario('Lucas Silva', 'lucasbarboza299@gmail.com', 'senha123', 'MT00077', 2);
    inserirUsuario('Fernanda Beatriz', 'febiatx@gmail.com', 'senha123', 'MT00018', 2); // Altere os parâmetros conforme necessário

});

// Middleware
app.use(cors({
    origin: '*',
    methods: 'GET, POST, PUT, DELETE',
    allowedHeaders: 'Content-Type, Authorization',
}));
app.use(bodyParser.urlencoded({ extended: true })); // Para dados de formulários
app.use(bodyParser.json()); // Para JSON
app.use(fileUpload());


// Certifique-se de que a pasta "uploads" exista
const uploadsDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadsDir)) {
    fs.mkdirSync(uploadsDir);
}

const gerarSalvarQRCode = async (patrimonio) => {
    const qrCodeData = `http://localhost:3001/pdf/${patrimonio}`; // Link para o PDF do extintor
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
        // Primeiro, insira a localização na tabela localizacoes
        const localizacaoQuery = `
    INSERT INTO localizacoes (Linha_ID, Estacao, Descricao_Local, Observacoes)
    VALUES (?, ?, ?, ?)
`;
        const localizacaoParams = [linha_id, estacao, descricao_local, observacoes_local];
        const [localizacaoResult] = await db.promise().query(localizacaoQuery, localizacaoParams);

        const id_localizacao = localizacaoResult.insertId; // Obter o ID da nova localização

        // Agora, insira o extintor na tabela extintores
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

        // Gerar e salvar o QR Code
        const qrCodePath = await gerarSalvarQRCode(patrimonio);

        // Atualizar o caminho do QR Code no extintor
        const qrCodeUrl = `${req.protocol}://${req.get('host')}/uploads/${patrimonio}-qrcode.png`;
        await db.promise().query('UPDATE Extintores SET QR_Code = ? WHERE Patrimonio = ?', [qrCodeUrl, patrimonio]);

        res.json({ success: true, message: 'Extintor registrado com sucesso!', qrCodeUrl: qrCodeUrl });
    } catch (err) {
        console.error('Erro ao registrar extintor:', err);
        res.status(500).json({ success: false, message: 'Erro ao registrar o extintor.' });
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

app.post('/login', (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({ success: false, message: 'Campos obrigatórios faltando' });
    }

    const query = `
        SELECT usuarios.id, usuarios.nome, usuarios.senha, cargos.nome AS cargo
        FROM usuarios
        JOIN cargos ON usuarios.cargo_id = cargos.id
        WHERE usuarios.email = ?`;

    db.query(query, [email], async (err, results) => {
        if (err) {
            console.error('Erro ao consultar o banco de dados:', err);
            return res.status(500).json({ success: false, message: 'Erro no servidor' });
        }

        if (results.length === 0) {
            return res.status(401).json({ success: false, message: 'Email ou senha incorretos' });
        }

        const usuario = results[0];

        // Verifica a senha usando bcrypt
        const match = await bcrypt.compare(password, usuario.senha);
        if (!match) {
            return res.status(401).json({ success: false, message: 'Email ou senha incorretos' });
        }

        return res.json({ success: true, nome: usuario.nome, cargo: usuario.cargo });
    });
});

app.get('/usuario', (req, res) => {
    const email = req.query.email;
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
        const urlImagem = usuario.foto_perfil
            ? `${req.protocol}://${req.get('host')}/${usuario.foto_perfil.replace(/\\/g, '/')}`
            : null; // Se não houver foto, defina como null

        res.json({ success: true, ...usuario, foto_perfil: urlImagem }); // Retorna a URL da imagem
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
        extintor.QR_Code = `http://localhost:3001/uploads/${patrimonio}-qrcode.png`;
        console.log('Dados do extintor:', extintor);
        res.status(200).json({ success: true, extintor });
    });
});
//======================= ENDPOINTS PARA CONSULTA ====================================

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

const verificarValidadeExtintores = async () => {
    const hoje = moment();
    const diasParaAviso = 7; // Número de dias antes da validade para enviar a notificação
    const dataLimite = hoje.add(diasParaAviso, 'days').format('YYYY-MM-DD');

    const query = `
        SELECT Patrimonio, DATEDIFF(Data_Validade, ?) AS DiasRestantes, TokenDispositivo
        FROM Extintores
        WHERE Data_Validade BETWEEN ? AND ?
    `;

    try {
        const [resultados] = await db.promise().query(query, [hoje.format('YYYY-MM-DD'), hoje.format('YYYY-MM-DD'), dataLimite]);

        for (const extintor of resultados) {
            await enviarNotificacao(extintor.TokenDispositivo, extintor.Patrimonio, extintor.DiasRestantes);
        }
    } catch (error) {
        console.error('Erro ao verificar validade dos extintores:', error);
    }
};

async function atualizarStatusExtintores() {
    const hoje = moment().format('YYYY-MM-DD'); // Data atual formatada

    const query = `
        UPDATE Extintores
        SET status_id = (SELECT id FROM Status_Extintor WHERE nome = 'Vencido')
        WHERE Data_Validade <= ?
    `;

    try {
        await db.promise().query(query, [hoje]);
        console.log('Status dos extintores atualizados para vencido, se aplicável.');
    } catch (error) {
        console.error('Erro ao atualizar status dos extintores:', error);
    }
}

app.put('/atualizar_status_extintor', (req, res) => {
    const { patrimonio, status } = req.body;

    if (!patrimonio || !status) {
        return res.status(400).json({ success: false, message: 'Patrimônio e status são obrigatórios' });
    }

    const query = `
        UPDATE extintores 
        SET status_id = (SELECT id FROM status_extintor WHERE nome = ?) 
        WHERE patrimonio = ?
    `;

    db.query(query, [status, patrimonio], (err) => {
        if (err) {
            console.error('Erro ao atualizar status do extintor:', err);
            return res.status(500).json({ success: false, message: 'Erro ao atualizar status do extintor' });
        }

        res.status(200).json({ success: true, message: 'Status do extintor atualizado com sucesso!' });
    });
});


// Configuração do transporte do Nodemailer
const transporter = nodemailer.createTransport({
    service: 'gmail', // ou outro serviço de e-mail
    auth: {
        user: 'suporte.redefinir.senha.imt.pi@gmail.com', // seu e-mail
        pass: 'eioj nzcm dcpp xjgd' // sua senha (use senha de aplicativo se necessário)
    }
});

// Rota para recuperação de senha
app.post('/forgot-password', (req, res) => {
    const { email } = req.body;

    const sql = 'SELECT * FROM usuarios WHERE email = ?';
    db.query(sql, [email], (err, results) => {
        if (err) {
            console.error('Erro ao buscar usuário:', err);
            return res.status(500).json({ error: 'Erro no servidor ao buscar usuário' });
        }

        if (results.length === 0) {
            return res.status(404).json({ error: 'Email não encontrado' });
        }

        const token = crypto.randomBytes(20).toString('hex');
        const tokenExpiration = new Date(Date.now() + 3600000); // 1 hora a partir de agora
        const updateTokenSql = 'UPDATE usuarios SET reset_password_token = ?, reset_password_expires = ? WHERE email = ?';

        db.query(updateTokenSql, [token, tokenExpiration, email], (err) => {
            if (err) {
                console.error('Erro ao salvar o token no banco de dados:', err);
                return res.status(500).json({ error: 'Erro no servidor ao salvar token de recuperação' });
            }

            const resetUrl = `http://localhost:3001/reset-password?token=${token}`; const mailOptions = {
                from: 'suporte.redefinir.senha.imt.pi@gmail.com',
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
                console.log('Email enviado:', info.response);
                res.status(200).json({ message: 'Email de recuperação enviado com sucesso' });
            });
        });
    });
});

// Rota para redefinir a senha
app.post('/reset-password', [
    check('token').not().isEmpty().withMessage('Token é obrigatório'),
    check('newPassword').isLength({ min: 6 }).withMessage('A nova senha deve ter pelo menos 6 caracteres')
], async (req, res) => {
    console.log('Dados recebidos:', req.body); // Adicione este log

    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        console.log('Erros de validação:', errors.array());
        return res.status(400).json({ errors: errors.array() });
    }

    const { token, newPassword } = req.body;
    console.log('Token recebido:', token); // Log para verificar o token

    const sql = 'SELECT * FROM usuarios WHERE reset_password_token = ? AND reset_password_expires > NOW()';
    db.query(sql, [token], async (err, results) => {
        if (err) {
            console.error('Erro ao buscar token no banco de dados:', err);
            return res.status(500).json({ error: 'Erro no servidor ao verificar token' });
        }

        if (results.length === 0) {
            return res.status(400).json({ error: 'Token inválido ou expirado' });
        }

        const hashedPassword = await bcrypt.hash(newPassword, 10);
        const updatePasswordSql = 'UPDATE usuarios SET senha = ?, reset_password_token = NULL, reset_password_expires = NULL WHERE reset_password_token = ?';

        db.query(updatePasswordSql, [hashedPassword, token], (err) => {
            if (err) {
                console.error('Erro ao atualizar senha no banco de dados:', err);
                return res.status(500).json({ error: 'Erro ao atualizar senha' });
            }

            res.status(200).json({ message: 'Senha atualizada com sucesso' });
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


const PORT = 3001;
app.listen(PORT, '0.0.0.0', async () => {
    console.log(`Servidor rodando na porta ${PORT}`);
    await atualizarStatusExtintores(); // Atualiza o status ao iniciar o servidor
});

// Agendar a verificação diária de status
const cron = require('node-cron');
cron.schedule('0 0 * * *', async () => {
    await atualizarStatusExtintores();
    console.log('Verificação diária de status de extintores realizada.');
});
