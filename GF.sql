----------------------------------------------------------------------------------------------------------
--  ____  ____  _        ____           _   /\/|         _____ _                           
-- |  _ \|  _ \| |      / ___| ___  ___| |_|/\/_  ___   |  ___(_)_ __   __ _  ___ __ _ ___ 
-- | | | | | | | |     | |  _ / _ \/ __| __/ _` |/ _ \  | |_  | | '_ \ / _` |/ __/ _` / __|
-- | |_| | |_| | |___  | |_| |  __/\__ \ || (_| | (_) | |  _| | | | | | (_| | (_| (_| \__ \
-- |____/|____/|_____|  \____|\___||___/\__\__,_|\___/  |_|   |_|_| |_|\__,_|\___\__,_|___/
--                                                                            )_)          
----------------------------------------------------------------------------------------------------------
--gf_xxxxxx_xxxxx
--São tabelas destinadas á gestão de finanças, nela existem cadastros de fornecedor, contas a pagar, 
--contas a receber, plano de contas e etc.
--PRE-REQUISITOS: ga_usuarios, rh_pessoa_fisica, rh_pessoa_juridica
---------------------------------------NOVOS----------------------------------------------------
--gestão de vendas não vai ter mais: São tabelas destinadas a gestão de vendas, com cadastro de cartões, tipos de pagamento, efetivação de parcelas
--fara parte da gestão de finanças
--adicionar: cadastro de bancos, agências e contas correntes
--PRE-REQUISITOS: RH (rh_pessoa_fisica, rh_pessoa_juridica), GA(ga_usuario)

--tabela de cadastro de cliente (antes de inserir verificar se existe a pessoa fisica ou juridica)
CREATE TABLE gf_cliente(
id SERIAL NOT NULL UNIQUE,
id_rh_pessoa_fis INTEGER UNIQUE, --id da tabela rh_pessoa_fisica
id_rh_pessoa_jur INTEGER UNIQUE, --id da tabela rh_pessoa_juridica
limite_credito NUMERIC(10,2) NOT NULL, --limite de crédito do cliente
credito NUMERIC(10,2), --credito do cliente, proveniente de estornos devoluções e etc.
criado TIMESTAMP NOT NULL, --data de criação
editado TIMESTAMP, --data de edição
PRIMARY KEY(id),
FOREIGN KEY (id_rh_pessoa_fis) REFERENCES rh_pessoa_fisica(id),
FOREIGN KEY (id_rh_pessoa_jur) REFERENCES rh_pessoa_juridica(id)
);

--tabela de cadastro de fornecedor, verificar possibilidade de deixar assim ou alterar para rh_pessoa_juridica
CREATE TABLE gf_fornecedor(
id SERIAL NOT NULL UNIQUE,
razao_social VARCHAR(255) NOT NULL,
nome_fantasia VARCHAR(255) NOT NULL,
telefone VARCHAR(20), --telefone do fornecedor
email VARCHAR(255) UNIQUE, --email para contato do fornecedor
end_logr VARCHAR(255), --logradouro
end_num INTEGER, --número
end_cep VARCHAR(10), --cep
end_compl VARCHAR(255), --complemento
end_bairro VARCHAR(255), --bairro
end_localid VARCHAR(255), --localidade, cidade
end_uf VARCHAR(2), --UF PR, SC e etc
cnpj VARCHAR(14) UNIQUE, --cnpj do fornecedor
ie VARCHAR(9) UNIQUE, --inscrição estadual do fornecedor
isento_icms BOOLEAN, --fornecedor isento do icms ?
opt_simpl_nacional BOOLEAN, --fornecedor optante pelo simples nacional ?
ativo BOOLEAN NOT NULL, --se tal fornecedor esta ativo ou não
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY KEY(id)
);

--tabela de credores, onde existem os credores para contas a pagar
CREATE TABLE gf_credor(
id SERIAL NOT NULL UNIQUE,
id_gf_fornecedor INTEGER NOT NULL UNIQUE, --id do fornecedor
credito NUMERIC(10,2), --credito do credor, proveniente de estornos e etc.
criado TIMESTAMP NOT NULL, --data de criação
editado TIMESTAMP, --data de edição
PRIMARY KEY(id),
FOREIGN KEY (id_gf_fornecedor) REFERENCES gf_fornecedor(id)
);

--plano de contas, será vinculado na conta a receber ou a pagar, dessa forma caso fo
CREATE TABLE gf_plano_contas(
id_plano VARCHAR(16) NOT NULL UNIQUE, --id do plano de contas, ex: 1, 1-01, 1-01-001
descricao VARCHAR(100) NOT NULL, --descrição do plano de contas ex:Ativo, Ativo circulante e etc.
tipo_conta CHAR NOT NULL, --tipo da conta, analitica (A) ou sintetica(S)
debito NUMERIC(10,2),
credito NUMERIC(10,2),
criado TIMESTAMP NOT NULL, --data de criação
editado TIMESTAMP, --data de edição
PRIMARY KEY(id_plano)
);

CREATE TABLE gf_cartao(
id SERIAL NOT NULL UNIQUE,
tipo VARCHAR(7) CHECK (tipo IN ('Credito', 'Debito')) NOT NULL,
nome VARCHAR(255), -- Nubank, Inter, e tudo mais
bandeira VARCHAR(30) NOT NULL, -- Mastercard, Visa
max_parcelas SMALLINT, --máximo de parcelas por cartão, 6, 12, 24
taxa_deb NUMERIC(10,2), --% de taxa na venda
taxa_cred NUMERIC(10,2), --% de taxa de crédito a vista
taxa_cred_parcela NUMERIC (10,2), --% de taxa de crédito por a mais por parcela 
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY KEY(id)
);

--tipos de pagamento da venda
--Dinheiro, Débito, Crédito, Crédito Parcelado, Alimentação/Refeição, Boleto, Fiado(gera um --credito(nesse caso precisa colocar o cliente nao deixar ser consumidor final))
--verificar possibilidade de adicionar a um plano de contas especifico, verificar plano de contas do lançamento de conta a pagar e a receber
CREATE TABLE gf_tipo_pagamento(
id SERIAL NOT NULL UNIQUE,
descricao VARCHAR(20) CHECK (descricao IN ('Dinheiro', 'Debito', 'Credito', 'Credito Parcelado', 'Alimentacao/Refeicao', 'Boleto', 'Fiado')) NOT NULL,
id_gf_cartao INTEGER, --id do cartão de crédito/debito, caso possua
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY KEY(id),
FOREIGN KEY(id_gf_cartao) REFERENCES gf_cartao(id)
);

--tabelas onde estão as contas a receber, geradas automaticamente ou manualmente
--verificar a possibilidade de substituir o num doc para serial
CREATE TABLE gf_conta_receber(
id SERIAL NOT NULL UNIQUE,
num_doc VARCHAR(30) NOT NULL UNIQUE, --número do documento gerado na conta a receber
id_gf_plan_contas VARCHAR(16) NOT NULL, -- id do plano de contas, ex: duplicatas a receber, que o lançamento será vinculado, ex: Caixa (verificar analitico ou sintetico agrupar por grupo, ex: 1.01.001)
val_tot_conta NUMERIC(10,2) NOT NULL, --valor total da conta a receber
id_gf_cliente_devedor INTEGER NOT NULL, --id do cliente devedor
criado TIMESTAMP NOT NULL, --data de criação
editado TIMESTAMP, --data de edição
PRIMARY KEY(id),
FOREIGN KEY (id_gf_plan_contas) REFERENCES gf_plano_contas(id_plano),--plano de contas(id)
FOREIGN KEY (id_gf_cliente_devedor) REFERENCES gf_cliente(id)
);

--tabelas onde estão as contas a pagar, geradas automaticamente ou manualmente
--verificar a possibilidade de substituir o num doc para serial
CREATE TABLE gf_conta_pagar(
id SERIAL NOT NULL UNIQUE,
num_doc VARCHAR(30) NOT NULL UNIQUE, --número do documento gerado na conta a pagar
id_gf_plan_contas VARCHAR(16) NOT NULL, -- id do plano de contas que o lançamento será vinculado, ex: Caixa
val_tot_conta NUMERIC(10,2) NOT NULL, --valor total da conta a pagar
id_gf_credor INTEGER NOT NULL, --id do credor(fornecedor)
criado TIMESTAMP NOT NULL, --data de criação
editado TIMESTAMP, --data de edição
PRIMARY KEY(id),
FOREIGN KEY (id_gf_plan_contas) REFERENCES gf_plano_contas(id_plano), --plano de contas(id)
FOREIGN KEY (id_gf_credor) REFERENCES gf_credor(id)
);

--tabela onde estão as parcelas das contas a receber
CREATE TABLE gf_parcela_receber(
id SERIAL NOT NULL UNIQUE,
id_gf_conta_receber INTEGER NOT NULL, --id da conta a receber
id_gf_tipo_pagamento INTEGER NOT NULL, --tipo do pagamento Dinheiro, cartão e etc
data_venc DATE NOT NULL, --data de vencimento da parcela
data_pagamento DATE NOT NULL, --data de pagamento da parcela
valor_bruto NUMERIC(10,2) NOT NULL, --valor bruto da parcela
valor_liquido NUMERIC(10,2) NOT NULL, --valor líquido da parcela
acrescimo_desconto NUMERIC(10,2), --valor de acrescimo ou de desconto
situacao VARCHAR(10) CHECK (situacao IN ('Aberta', 'Vencida', 'Quitada', 'Cancelada')) NOT NULL,
criado TIMESTAMP NOT NULL, --data de criação
editado TIMESTAMP, --data de edição
PRIMARY KEY(id),
FOREIGN KEY (id_gf_conta_receber) REFERENCES gf_conta_receber(id),
FOREIGN KEY (id_gf_tipo_pagamento) REFERENCES gf_tipo_pagamento(id)
);

--tabela onde estão as parcelas das contas a pagar
CREATE TABLE gf_parcela_pagar(
id SERIAL NOT NULL UNIQUE,
id_gf_conta_pagar INTEGER NOT NULL, --id da conta a receber
id_gf_tipo_pagamento INTEGER NOT NULL, --tipo do pagamento Dinheiro, cartão e etc
data_venc DATE NOT NULL, --data de vencimento da parcela
data_pagamento DATE NOT NULL, --data de pagamento da parcela
valor_bruto NUMERIC(10,2) NOT NULL, --valor bruto da parcela
valor_liquido NUMERIC(10,2) NOT NULL, --valor líquido da parcela
acrescimo_desconto NUMERIC(10,2), --valor de acrescimo ou de desconto
situacao VARCHAR(10) CHECK (situacao IN ('Aberta', 'Vencida', 'Quitada', 'Cancelada')) NOT NULL,
criado TIMESTAMP NOT NULL, --data de criação
editado TIMESTAMP, --data de edição
PRIMARY KEY(id),
FOREIGN KEY (id_gf_conta_pagar) REFERENCES gf_conta_pagar(id),
FOREIGN KEY (id_gf_tipo_pagamento) REFERENCES gf_tipo_pagamento(id)
);

--abaixo são tabelas em teste para as contas onde serão realizadas as movimentações, tanto de caixa
--como para pagamento de duplicatas e fornecedores.
CREATE TABLE gf_banco(
cod_banco VARCHAR(5) NOT NULL UNIQUE, --codigo do banco, ex: 260
nome_banco VARCHAR(100) NOT NULL, --nome do banco, ex: Nubank
observacao VARCHAR(255), --observações, ex: local de pagamento e etc
criado TIMESTAMP NOT NULL, --data de criação
editado TIMESTAMP, --data de edição
PRIMARY KEY(cod_banco)
);

CREATE TABLE gf_agencia_bancaria(
id SERIAL NOT NULL UNIQUE,
id_cod_banco VARCHAR(5) NOT NULL, --codigo do banco
numero_agencia VARCHAR(4) NOT NULL, --numero da agencia, ex: 0001
nome_agencia VARCHAR(100), --nome da agencia, ex: matrix
telefone VARCHAR(20), --telefone da agencia
end_logr VARCHAR(255), --logradouro
end_num INTEGER, --número
end_cep VARCHAR(10), --cep
end_compl VARCHAR(255), --complemento
end_bairro VARCHAR(255), --bairro
end_localid VARCHAR(255), --localidade, cidade
end_uf VARCHAR(2), --UF PR, SC e etc
criado TIMESTAMP NOT NULL, --data de criação
editado TIMESTAMP, --data de edição
PRIMARY KEY(id),
FOREIGN KEY(id_cod_banco) REFERENCES gf_banco(cod_banco)
);

--verificar a possibilidade de utilizar a conta como Caixa (plano de contas especifico)
CREATE TABLE gf_conta_bancaria(
id SERIAL NOT NULL UNIQUE,
conta VARCHAR(15) NOT NULL, --numero da conta
id_gf_agencia_bancaria INTEGER NOT NULL, --id da agencia a qual a conta bancaria pertence
id_pf_titular INTEGER, --pessoa fisica titular
id_pj_titular INTEGER, --pessoa juridica titular
modalidade VARCHAR(14) CHECK (modalidade in('conta-corrente', 'conta poupança', 'conta-salário')) NOT NULL, --modalidade da conta
nome_gerente VARCHAR(255), --nome do gerente da conta
email_gerente VARCHAR(255), --email para contato com o gerente
telefone_gerente VARCHAR(20), --telefone para contato com o gerente
id_gf_plan_contas VARCHAR(16) NOT NULL, -- id do plano de contas (conta contábil)
ativo BOOLEAN NOT NULL, --conta bancaria ativa ?
data_encerramento DATE, --data de encerramento da conta
motivo_encerramento VARCHAR(100), --motivo do encerramento da conta
criado TIMESTAMP NOT NULL, --data de criação
editado TIMESTAMP, --data de edição
PRIMARY KEY(id),
FOREIGN KEY(id_gf_agencia_bancaria) REFERENCES gf_agencia_bancaria(id),
FOREIGN KEY(id_gf_plan_contas) REFERENCES gf_plano_contas(id_plano),
FOREIGN KEY(id_pf_titular) REFERENCES rh_pessoa_fisica(id),
FOREIGN KEY(id_pj_titular) REFERENCES rh_pessoa_juridica(id)
);

--no relatorio de fluxo de caixa o saldo é o valor das entradas diminuindo as saidas
--ao fazer um lançamento é necessário selecionar a conta bancária (que possui o plano de contas que pode ser de caixa, cartão e etc)
