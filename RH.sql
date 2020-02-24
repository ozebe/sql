--------------------------------------------------------------------------
--  ____  ____  _       ____    _   _ 
-- |  _ \|  _ \| |     |  _ \  | | | |
-- | | | | | | | |     | |_) | | |_| |
-- | |_| | |_| | |___  |  _ <  |  _  |
-- |____/|____/|_____| |_| \_\ |_| |_|
                                                                 
--------------------------------------------------------------------------
--rh_xxxxxx_xxxxx
--são tabelas destinadas á recursos humanos, nelas possuem contatos, endereços, pessoas físicas, fornecedores e etc.
--PRE-REQUISITOS: Nenhum

CREATE TABLE rh_escolaridade(
id SERIAL NOT NULL UNIQUE,
descricao VARCHAR(255) NOT NULL,
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY KEY(id)
);


CREATE TABLE rh_area_profissao(
id SERIAL NOT NULL UNIQUE,
descricao VARCHAR(255) NOT NULL,
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY KEY(id)
);

CREATE TABLE rh_tipo_profissao(
id SERIAL NOT NULL UNIQUE,
areaId INTEGER NOT NULL,
descricao VARCHAR(255) NOT NULL,
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY KEY(id),
FOREIGN KEY (areaId) REFERENCES rh_area_profissao(id)
);

CREATE TABLE rh_profissao(
id SERIAL NOT NULL UNIQUE,
tipoProfissaoId INTEGER NOT NULL,
salario INTEGER NOT NULL,
admissao DATE,
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY KEY(id),
FOREIGN KEY (tipoProfissaoId) REFERENCES rh_tipo_profissao(id)
);

CREATE TABLE rh_contato(
id SERIAL NOT NULL UNIQUE,
ddd  VARCHAR(10),
telefone VARCHAR(255) NOT NULL,
email VARCHAR(255) UNIQUE,
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY KEY(id)
);

CREATE TABLE rh_endereco(
id SERIAL NOT NULL UNIQUE,
logradouro VARCHAR(255) NOT NULL,
numero INTEGER NOT NULL,
cep VARCHAR(10) NOT NULL,
complemento VARCHAR(255),
bairro VARCHAR(255) NOT NULL,
localidade VARCHAR(255) NOT NULL,
uf VARCHAR(2),
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY KEY(id)
);

CREATE TABLE rh_situacao_escolar(
id SERIAL NOT NULL UNIQUE,
descricao VARCHAR(255),
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY key(id)
);

CREATE TABLE rh_escolaridade_situacao(
id SERIAL NOT NULL UNIQUE,
idEscolaridade INTEGER NOT NULL,
idSituacao INTEGER NOT NULL,
FOREIGN KEY(idEscolaridade) REFERENCES rh_escolaridade(id),
FOREIGN KEY(idSituacao) REFERENCES rh_situacao_escolar(id),
PRIMARY key(id)
);

CREATE TABLE rh_pessoa_fisica(
id SERIAL NOT NULL UNIQUE,
nome VARCHAR(255) NOT NULL,
cpf VARCHAR(11) NOT NULL UNIQUE,
dataNascimento DATE NOT NULL,
sexo CHAR NOT NULL,
contatoId INTEGER NOT NULL,
enderecoId INTEGER NOT NULL,
escolaridade_situacao INTEGER,
profissaoId INTEGER,
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY KEY(id),
FOREIGN KEY (contatoId) REFERENCES rh_contato(id),
FOREIGN KEY (enderecoId) REFERENCES rh_endereco(id),
FOREIGN KEY (profissaoId) REFERENCES rh_profissao(id),
FOREIGN KEY (escolaridade_situacao) REFERENCES rh_escolaridade_situacao(id)
);
