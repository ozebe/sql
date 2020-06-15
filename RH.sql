--------------------------------------------------------------------------
--  ____  ____  _       ____    _   _ 
-- |  _ \|  _ \| |     |  _ \  | | | |
-- | | | | | | | |     | |_) | | |_| |
-- | |_| | |_| | |___  |  _ <  |  _  |
-- |____/|____/|_____| |_| \_\ |_| |_|
                                                                 
--------------------------------------------------------------------------
--rh_xxxxxx_xxxxx
--são tabelas destinadas á recursos humanos, nelas possuem pessoas físicas, níveis de escolaridade e situações escolares, areas de profissão,
-- funcionários e etc.
--PRE-REQUISITOS: Nenhum

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
situacao_escolar VARCHAR(10) CHECK (situacao_escolar IN ('Completo', 'Incompleto', 'Cursando')),--para cadastro de funcionario
escolaridade VARCHAR(255) CHECK (escolaridade IN ('Ensino Fundamental','Ensino Médio','Ensino superior', 'Pós-graduação')), --para cadastro de funcionario
id_profissao INTEGER, --informação complementar no cadastro do cliente
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY KEY(id),
FOREIGN KEY (id_profissao) REFERENCES rh_profissao(id) --dados para analise de credito, como analista de sistema, salario tal, admissão tal.
);

CREATE TABLE rh_pessoa_juridica(
id SERIAL NOT NULL UNIQUE,
razao_social VARCHAR(255) NOT NULL,
nome_fantasia VARCHAR(255) NOT NULL,
telefone VARCHAR(20), --telefone da pessoa juridica
email VARCHAR(255) UNIQUE, --email para contato da pessoa juridica
end_logr VARCHAR(255), --logradouro
end_num INTEGER, --número
end_cep VARCHAR(10), --cep
end_compl VARCHAR(255), --complemento
end_bairro VARCHAR(255), --bairro
end_localid VARCHAR(255), --localidade, cidade
end_uf VARCHAR(2), --UF PR, SC e etc
cnpj VARCHAR(14) UNIQUE, --cnpj da pessoa juridica
ie VARCHAR(9) UNIQUE, --inscrição estadual da pessoa juridica
isento_icms BOOLEAN, --pessoa juridica isento do icms ?
opt_simpl_nacional BOOLEAN, --pessoa juridica optante pelo simples nacional ?
ativo BOOLEAN NOT NULL, --pessoa juridica esta ativo ou não
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY KEY(id)
);

CREATE TABLE rh_jornada_trabalho(
id SERIAL NOT NULL UNIQUE,
descricao VARCHAR(255) NOT NULL,
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY KEY(id)
);

CREATE TABLE rh_funcionario(
id SERIAL NOT NULL UNIQUE,
id_rh_pessoa_fis INTEGER NOT NULL UNIQUE, --id da tabela rh_pessoa_fisica
natur VARCHAR(255) NOT NULL, --naturalidade ex: TOLEDO/PR
est_civ VARCHAR(30) CHECK (est_civ IN ('SOLTEIRO(A)', 'CASADO(A)', 'DIVORCIADO(A)', 'DIVORCIADO(A)', 'VIÚVO(A)', 'SEPARADO JUDICIALMENTE')) NOT NULL, --estadocivil
nome_pai VARCHAR(255) NOT NULL, --nome do pai
nome_mae VARCHAR(255) NOT NULL, --nome da mãe ambos como consta no RG
prim_emprego BOOLEAN NOT NULL, --primeiro emprego?
pis_pasep VARCHAR(255) NOT NULL, --pis-pasep da carteira de trabalho
ctps VARCHAR(255), --carteira de trabalho
ctps_serie VARCHAR(255), --carteira de trabalho serie
ctps_emissao DATE, --carteira de trabalho emissao
rg VARCHAR(9) NOT NULL, --rg
rg_uf VARCHAR(2),
rg_emissao DATE,
tit_eleitor VARCHAR(12), --numero do titulo de eleitor
tit_eleitor_secao VARCHAR(6), --secao do titulo de eleitor
tit_eleitor_zona VARCHAR(3), --zona do titulo de eleitor
tit_eleitor_emissao DATE,
num_habilit VARCHAR(11), --numero da habilitação, se houver
cat_habilit VARCHAR(5), --categoria da habilitacao EX: AB
venc_habilit DATE, --data de vencimento da habilitação
cert_reservista VARCHAR(10), --numero do certificado de reservista
s_cert_reservista VARCHAR(1),--serie do certificado de reservista
banco VARCHAR(255) NOT NULL, --dados bancários, banco, ex: Nubank
agencia VARCHAR(4) NOT NULL, --dados bancários, agencia, ex: 0001
conta  VARCHAR(20) NOT NULL, --dados bancárias, conta.
data_admissao DATE NOT NULL, --data de admissão do funcionario
salario NUMERIC(10,2) NOT NULL, --salário mensal do funcionario
adicionais NUMERIC(10,2), --adicionais como adicionais noturnos e etc
obs_adicionais VARCHAR(255), --observações dos adicionais, ex: adicional noturno
rh_tp_prof_id INTEGER NOT NULL, --profissão do funcionário, nessa tabela tem o tipo e área da profissão, ex: ANALISTA I, TI
--verificar se o id passado da rh_pessoa_fisica já tem um id_profissao, caso tenha, não pode ser adicionado dois ao cadastrar o funcionário.
id_jornada_trabalho INTEGER NOT NULL, --jornada de trabalho, ex: 8h diárias, seg a sex.
experiencia VARCHAR(255), --experiencia de trabalho e etc
desconto_vr BOOLEAN,
desctonto_vt BOOLEAN,
desconto_p_saude BOOLEAN,
desconto_p_odonto BOOLEAN, 
val_tot_desco NUMERIC(10,2),
obs VARCHAR(255), --observações adicionais do funcionario
PRIMARY KEY(id),
FOREIGN KEY (rh_tp_prof_id) REFERENCES rh_tipo_profissao(id),
FOREIGN KEY (id_rh_pessoa_fis) REFERENCES rh_pessoa_fisica(id),
FOREIGN KEY (id_jornada_trabalho) REFERENCES rh_jornada_trabalho(id)
);

CREATE TABLE rh_dependente(
id SERIAL NOT NULL UNIQUE,
nome VARCHAR(255),
cpf VARCHAR(11) NOT NULL,
data_nasc DATE NOT NULL,
grau_parentesco VARCHAR(255),
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY KEY(id)
);

CREATE TABLE rh_funcionario_dependente(
id SERIAL NOT NULL UNIQUE,
id_rh_funcionario INTEGER NOT NULL,
id_rh_dependente INTEGER NOT NULL,
obs_adicionais VARCHAR(255),
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY KEY(id),
FOREIGN KEY(id_rh_dependente) REFERENCES rh_dependente(id),
FOREIGN KEY(id_rh_funcionario) REFERENCES rh_funcionario(id)
);
