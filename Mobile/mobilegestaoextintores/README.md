create DATABASE fire_equipment_management_metro;
USE fire_equipment_management_metro;

CREATE TABLE cargos (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome VARCHAR(50) NOT NULL UNIQUE,
    PRIMARY KEY (id)
);

CREATE TABLE tipos_extintores (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    tipo VARCHAR(50) NOT NULL UNIQUE,
    PRIMARY KEY (id)
);

CREATE TABLE status_extintor (
    id INT NOT NULL AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE linhas (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome VARCHAR(50) NOT NULL UNIQUE,
    codigo VARCHAR(10) UNIQUE,
    descricao TEXT,
    PRIMARY KEY (id)
);

CREATE TABLE localizacoes (
    ID_Localizacao INT NOT NULL AUTO_INCREMENT,
    Linha_ID INT UNSIGNED,
    Estacao VARCHAR(100) NOT NULL,  -- Nome da estação
    Descricao_Local VARCHAR(255),     -- Descrição detalhada do local onde o extintor está
    Observacoes TEXT,
    PRIMARY KEY (ID_Localizacao),
    FOREIGN KEY (Linha_ID) REFERENCES linhas(id)
);

CREATE TABLE capacidades (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    descricao VARCHAR(10) NOT NULL UNIQUE,
    PRIMARY KEY (id)
);

CREATE TABLE extintores (
    Patrimonio INT NOT NULL,
    Tipo_ID INT UNSIGNED NOT NULL,
    Capacidade_ID INT UNSIGNED, 
    Codigo_Fabricante VARCHAR(50),
    Data_Fabricacao DATE,
    Data_Validade DATE,
    Ultima_Recarga DATE,
    Proxima_Inspecao DATE,
    ID_Localizacao INT,
    QR_Code VARCHAR(100),
    Observacoes TEXT,
    Linha_ID INT UNSIGNED,
    status_id INT,
    PRIMARY KEY (Patrimonio),
    FOREIGN KEY (Tipo_ID) REFERENCES tipos_extintores(id),
    FOREIGN KEY (Capacidade_ID) REFERENCES capacidades(id),
    FOREIGN KEY (ID_Localizacao) REFERENCES localizacoes(ID_Localizacao),
    FOREIGN KEY (Linha_ID) REFERENCES linhas(id),
    FOREIGN KEY (status_id) REFERENCES status_extintor(id)
);

CREATE TABLE historico_manutencao (
    ID_Manutencao INT NOT NULL AUTO_INCREMENT,
    ID_Extintor INT,  -- Alterado para INT para coincidir com o tipo de Patrimonio
    Data_Manutencao DATE NOT NULL,
    Descricao TEXT,
    Responsavel_Manutencao VARCHAR(100),
    Observacoes TEXT,
    PRIMARY KEY (ID_Manutencao),
    FOREIGN KEY (ID_Extintor) REFERENCES extintores(Patrimonio)
);

CREATE TABLE notificacoes (
    id INT NOT NULL AUTO_INCREMENT,
    equipamento_id INT NOT NULL,
    mensagem VARCHAR(255) NOT NULL,
    data_criacao DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('não lida', 'lida') DEFAULT 'não lida',
    PRIMARY KEY (id),
    FOREIGN KEY (equipamento_id) REFERENCES extintores(Patrimonio)
);

CREATE TABLE usuarios (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    matricula VARCHAR(20) UNIQUE,
    foto_perfil VARCHAR(255),
    cargo_id INT UNSIGNED,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    reset_password_expires DATETIME,
    reset_password_token VARCHAR(255),
    PRIMARY KEY (id),
    FOREIGN KEY (cargo_id) REFERENCES cargos(id)
);



-- Inserir cargos
INSERT INTO cargos (nome) VALUES ('Operador');
INSERT INTO cargos (nome) VALUES ('Supervisor');
INSERT INTO cargos (nome) VALUES ('Gerente');

-- Inserir tipos de extintores
INSERT INTO tipos_extintores (tipo) VALUES ('Água');
INSERT INTO tipos_extintores (tipo) VALUES ('Pó Químico');
INSERT INTO tipos_extintores (tipo) VALUES ('CO2');
INSERT INTO tipos_extintores (tipo) VALUES ('Espuma');

-- Inserir status dos extintores
INSERT INTO status_extintor (nome) VALUES ('Ativo');
INSERT INTO status_extintor (nome) VALUES ('Em Manutenção');
INSERT INTO status_extintor (nome) VALUES ('Expirado');
INSERT INTO status_extintor (nome) VALUES ('Extraviado');

-- Inserir linhas
INSERT INTO linhas (nome, codigo, descricao) VALUES ('Linha 1', 'L1', 'Descrição da Linha 1');
INSERT INTO linhas (nome, codigo, descricao) VALUES ('Linha 2', 'L2', 'Descrição da Linha 2');
INSERT INTO linhas (nome, codigo, descricao) VALUES ('Linha 3', 'L3', 'Descrição da Linha 3');

-- Inserir localizações
INSERT INTO localizacoes (Linha_ID, Estacao, Descricao_Local, Observacoes) VALUES (1, 'Estação A', 'Plataforma 1', 'Observação A');
INSERT INTO localizacoes (Linha_ID, Estacao, Descricao_Local, Observacoes) VALUES (2, 'Estação B', 'Plataforma 2', 'Observação B');
INSERT INTO localizacoes (Linha_ID, Estacao, Descricao_Local, Observacoes) VALUES (3, 'Estação C', 'Plataforma 3', 'Observação C');

-- Inserir capacidades
INSERT INTO capacidades (descricao) VALUES ('5 kg');
INSERT INTO capacidades (descricao) VALUES ('10 kg');
INSERT INTO capacidades (descricao) VALUES ('20 kg');
-- Inserir extintores
INSERT INTO extintores (Patrimonio, Tipo_ID, Capacidade_ID, Codigo_Fabricante, Data_Fabricacao, Data_Validade, Ultima_Recarga, Proxima_Inspecao, ID_Localizacao, QR_Code, Observacoes, Linha_ID, status_id) 
VALUES (1001, 1, 1, 'FAB123', '2020-01-01', '2025-01-01', '2023-01-01', '2024-01-01', 1, 'QR1001', 'Extintor de água', 1, 1);
INSERT INTO extintores (Patrimonio, Tipo_ID, Capacidade_ID, Codigo_Fabricante, Data_Fabricacao, Data_Validade, Ultima_Recarga, Proxima_Inspecao, ID_Localizacao, QR_Code, Observacoes, Linha_ID, status_id) 
VALUES (1002, 2, 2, 'FAB124', '2021-02-01', '2026-02-01', '2023-02-01', '2024-02-01', 2, 'QR1002', 'Extintor de pó químico', 2, 1);
INSERT INTO extintores (Patrimonio, Tipo_ID, Capacidade_ID, Codigo_Fabricante, Data_Fabricacao, Data_Validade, Ultima_Recarga, Proxima_Inspecao, ID_Localizacao, QR_Code, Observacoes, Linha_ID, status_id) 
VALUES (1003, 3, 3, 'FAB125', '2022-03-01', '2027-03-01', '2023-03-01', '2024-03-01', 3, 'QR1003', 'Extintor de CO2', 3, 1);

-- Inserir notificações
INSERT INTO notificacoes (equipamento_id, mensagem, status) VALUES (1001, 'Extintor precisa de inspeção', 'não lida');
INSERT INTO notificacoes (equipamento_id, mensagem, status) VALUES (1002, 'Extintor expirado', 'não lida');
INSERT INTO notificacoes (equipamento_id, mensagem, status) VALUES (1003, 'Extintor em manutenção', 'lida');

-- Inserir usuários
INSERT INTO usuarios (nome, email, senha, matricula, cargo_id) VALUES ('João Silva', 'joao.silva@example.com', 'senha123', '123456', 1);
INSERT INTO usuarios (nome, email, senha, matricula, cargo_id) VALUES ('Maria Oliveira', 'maria.oliveira@example.com', 'senha456', '654321', 2);
INSERT INTO usuarios (nome, email, senha, matricula, cargo_id) VALUES ('Carlos Pereira', 'carlos.pereira@example.com', 'senha789', '789012', 3);