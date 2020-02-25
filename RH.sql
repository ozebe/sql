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

CREATE TABLE rh_situacao_escolar(
id SERIAL NOT NULL UNIQUE,
descricao VARCHAR(255),
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY key(id)
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
rh_area_prof_id INTEGER NOT NULL,
descricao VARCHAR(255) NOT NULL,
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY KEY(id),
FOREIGN KEY (rh_area_prof_id) REFERENCES rh_area_profissao(id)
);

CREATE TABLE rh_profissao(
id SERIAL NOT NULL UNIQUE,
rh_tp_prof_id INTEGER NOT NULL,
salario NUMERIC(10,2), --verificar caso o cadastro de pessoa fisica seja apenas para um cliente e etc
admissao DATE,
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY KEY(id),
FOREIGN KEY (rh_tp_prof_id) REFERENCES rh_tipo_profissao(id)
);

CREATE TABLE rh_pessoa_fisica(
id SERIAL NOT NULL UNIQUE,
nome VARCHAR(255) NOT NULL,
cpf VARCHAR(11) NOT NULL UNIQUE,
data_nasc DATE NOT NULL,
sexo CHAR NOT NULL,
telefone VARCHAR(20) NOT NULL,
email VARCHAR(255) UNIQUE,
end_logr VARCHAR(255) NOT NULL, --logradouro
end_num INTEGER NOT NULL, --número
end_cep VARCHAR(10) NOT NULL, --cep
end_compl VARCHAR(255), --complemento
end_bairro VARCHAR(255) NOT NULL, --bairro
end_localid VARCHAR(255) NOT NULL, --localidade
end_uf VARCHAR(2), --UF PR, SC e etc
id_rh_sit_escol INTEGER, --para cadastro de funcionario
id_rh_escol INTEGER, --para cadastro de funcionario
id_profissao INTEGER, --informação complementar no cadastro do cliente
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY KEY(id),
FOREIGN KEY (id_profissao) REFERENCES rh_profissao(id), --dados para analise de credito, como analista de sistema, salario tal, admissão tal.
FOREIGN KEY (id_rh_sit_escol) REFERENCES rh_situacao_escolar(id),
FOREIGN KEY (id_rh_escol) REFERENCES rh_escolaridade(id)
);
