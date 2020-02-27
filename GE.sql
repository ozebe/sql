--------------------------------------------------------------------------

--  ____  ____  _        ____           _                _____     _                         
-- |  _ \|  _ \| |      / ___| ___  ___| |_ __ _  ___   | ____|___| |_ ___   __ _ _   _  ___ 
-- | | | | | | | |     | |  _ / _ \/ __| __/ _` |/ _ \  |  _| / __| __/ _ \ / _` | | | |/ _ \
-- | |_| | |_| | |___  | |_| |  __/\__ \ || (_| | (_) | | |___\__ \ || (_) | (_| | |_| |  __/
-- |____/|____/|_____|  \____|\___||___/\__\__,_|\___/  |_____|___/\__\___/ \__, |\__,_|\___|
--                                                                             |_|                             
--------------------------------------------------------------------------

--ge_xxxxxx_xxxxx
--São tabelas destinadas á gestão do estoque, contendo, estoque, grupo de produto, lote, movimentação de estoque, operação de estoque, produto, unidade de --medida e etc
--PRE-REQUISITOS: GA, RH
--ga_nivel_acesso, ga_usuario, rh_endereco, rh_contato

CREATE TABLE ge_unidade_medida(
id SERIAL NOT NULL UNIQUE,
descricao VARCHAR(255) NOT NULL UNIQUE,
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY KEY(id)
);

CREATE TABLE ge_unidade_massa(
id SERIAL NOT NULL UNIQUE,
descricao VARCHAR(255) NOT NULL UNIQUE,
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY KEY(id)
);
--grupos dos produtos
CREATE TABLE ge_grupo_produto(
id SERIAL NOT NULL UNIQUE,
codigo VARCHAR(255) NOT NULL UNIQUE, --IM001
descricao VARCHAR(255), --Ativo Imobilizado
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY KEY(id)
);


CREATE TABLE ge_produto(
id SERIAL NOT NULL UNIQUE,
codigo INTEGER NOT NULL UNIQUE,
descricao VARCHAR(255),
id_unid_medida INTEGER NOT NULL, --unidade de medida, KG, GRAMAS.
id_unid_massa INTEGER, --unidade de medida de massa para o peso bruto e liquido
id_grupo INTEGER NOT NULL,  --grupo do produto
cod_barras VARCHAR(255),
NCM VARCHAR(255), --para tributação
ativo BOOLEAN NOT NULL, --ativo ou não
peso_bruto NUMERIC(10,3),
peso_liquido NUMERIC(10,3),
min_estoque NUMERIC(10,3) CHECK (min_estoque >= 0) NOT NULL, 
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY KEY(id),
FOREIGN KEY(id_unid_medida) REFERENCES ge_unidade_medida(id),
FOREIGN KEY(id_unid_massa) REFERENCES ge_unidade_massa(id),
FOREIGN KEY(id_grupo) REFERENCES ge_grupo_produto(id)
);

CREATE TABLE rh_fornecedor(
id SERIAL NOT NULL UNIQUE,
razaoS VARCHAR(255) NOT NULL,
nomeF VARCHAR(255) NOT NULL,
contatoId INTEGER NOT NULL,
enderecoId INTEGER NOT NULL,
cnpj VARCHAR(14) NOT NULL UNIQUE,
ie VARCHAR(9),
ativo BOOLEAN NOT NULL,
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY KEY(id),
FOREIGN KEY (contatoId) REFERENCES rh_contato(id),
FOREIGN KEY (enderecoId) REFERENCES rh_endereco(id)
);

CREATE TABLE ge_lote(
id SERIAL NOT NULL UNIQUE,
numLote VARCHAR(255) NOT NULL UNIQUE,
descricao VARCHAR(255),
dataValidade DATE NOT NULL,
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY KEY(id)
);

--automatizar a inserção de dados nesse tabela
--pega o tipo de movimentacao de estoque, caso seja entrada, ele coloca o id do produto que ta entrando
--o id do fornecedor, o lote, o usuario que deu entrada, o criado é current_timestamp e o valor, ele divide a quantidade pelo valor na insercao
--do movEstoque e coloca em valor, a quantiaEstoque ele coloca do movEstoque
CREATE TABLE ge_produto_fornecedor(
id SERIAL NOT NULL UNIQUE,
idProduto INTEGER NOT NULL,
idFornecedor INTEGER NOT NULL,
quantiaEstoque NUMERIC(10,3) NOT NULL,
valor_custo NUMERIC(10,2),
valor_venda NUMERIC(10,2),
idLote INTEGER NOT NULL,
idUsuario INTEGER NOT NULL,
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
--info a mais
PRIMARY KEY(id),
FOREIGN KEY(idLote) REFERENCES ge_lote(id),
FOREIGN KEY(idProduto) REFERENCES ge_produto(id),
FOREIGN KEY(idFornecedor) REFERENCES rh_fornecedor(id),
FOREIGN KEY(idUsuario) REFERENCES ga_usuario(id)
);

--Operações de estoque (Ajuste e etc) movimentações-------------------
CREATE TABLE ge_estoque(
id SERIAL NOT NULL UNIQUE,
descricao VARCHAR(255) NOT NULL,
ativo BOOLEAN NOT NULL,
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY KEY(id)
);


CREATE TABLE ge_op_estoque(
id SERIAL NOT NULL UNIQUE,
descricao VARCHAR(255) NOT NULL,
tipo VARCHAR(7) CHECK (tipo IN ('Entrada', 'Saida', 'Ajuste')) NOT NULL, 
ativo BOOLEAN NOT NULL,
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY KEY(id)
);


CREATE TABLE ge_mov_estoque(
id SERIAL NOT NULL UNIQUE,
idProduto INTEGER NOT NULL,
idOpEstoque INTEGER NOT NULL,
idEstoque INTEGER NOT NULL,
idLote INTEGER,
nNotaF VARCHAR(255),
idFornecedor INTEGER NOT NULL,
dataMov TIMESTAMP NOT NULL,
quantidade NUMERIC(10,3) NOT NULL,
valorTotal NUMERIC(10,2),
idUsuario INTEGER NOT NULL,
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY KEY(id),
FOREIGN KEY(idProduto) REFERENCES ge_produto(id),
FOREIGN KEY(idLote) REFERENCES ge_lote(id),
FOREIGN KEY(idUsuario) REFERENCES ga_usuario(id),
FOREIGN KEY(idOpEstoque) REFERENCES ge_op_estoque(id),
FOREIGN KEY(idEstoque) REFERENCES ge_estoque(id),
FOREIGN KEY(idFornecedor) REFERENCES rh_fornecedor(id)
);

--Big Money-sw
--------------------------------------------------------------------------
 --__      __  _____   ______  __          __   _____ 
 --\ \    / / |_   _| |  ____| \ \        / /  / ____|
 -- \ \  / /    | |   | |__     \ \  /\  / /  | (___  
 --  \ \/ /     | |   |  __|     \ \/  \/ /    \___ \ 
 --   \  /     _| |_  | |____     \  /\  /     ____) |
 --    \/     |_____| |______|     \/  \/     |_____/ 
--------------------------------------------------------------------------
--VIEW FORNECEDORES
CREATE OR REPLACE VIEW public.vw_fornecedores
AS SELECT f.razaos AS razao_social,
    f.nomef AS nome_fantasia,
    concat(c.ddd, c.telefone) AS telefone,
    c.email,
    e.logradouro AS rua,
    e.numero,
    e.cep,
    e.bairro,
    e.localidade AS cidade,
    e.uf AS estado,
    f.cnpj,
    f.ie,
        CASE
            WHEN f.ativo = true THEN 'Sim'::text
            ELSE 'Não'::text
        END AS ativo,
    f.criado,
    f.editado
   FROM rh_fornecedor f
     JOIN rh_contato c ON f.contatoid = c.id
     JOIN rh_endereco e ON f.enderecoid = e.id;
-------------------------------------------------------------------------------
--VIEW MOVIMENTACOES DE ESTOQUE quantiade, valor
CREATE OR REPLACE VIEW public.vw_movs_estoque
AS SELECT ge_mov_estoque.id AS id_mov_estoque,
	p.descricao AS desc_produto,
    ope.tipo AS tipo_op_estoque,
	ope.descricao AS operacao_estoque,
	ge_mov_estoque.quantidade,
	um.descricao AS unid_medida,
    ge_mov_estoque.valorTotal,
	p.cod_barras AS cod_barras_produto,
    ge_estoque.descricao AS nome_estoque,
    ge_lote.numlote AS numero_lote_prod,
    ge_mov_estoque.nnotaf AS num_nota_fiscal,
    rh_fornecedor.razaos AS razao_social_fornecedor,
    ge_mov_estoque.datamov AS data_da_movimentacao,
    ga_usuario.nome AS usuario_que_movimentou
   FROM ge_mov_estoque
     JOIN ge_produto p ON ge_mov_estoque.idproduto = p.id
	 JOIN ge_unidade_medida um ON p.id_unid_medida = um.id
     JOIN ge_op_estoque ope ON ge_mov_estoque.idopestoque = ope.id
     JOIN ge_estoque ON ge_mov_estoque.idestoque = ge_estoque.id
     JOIN ge_lote ON ge_mov_estoque.idlote = ge_lote.id
     JOIN rh_fornecedor ON ge_mov_estoque.idfornecedor = rh_fornecedor.id
     JOIN ga_usuario ON ge_mov_estoque.idusuario = ga_usuario.id;	 
-------------------------------------------------------------------------------
--VIEW PRODUTOS E RESPECTIVOS FORNECEDORES
 CREATE OR REPLACE VIEW public.vw_produto_fornecedor
AS SELECT rh_fornecedor.id AS id_fornecedor,
	rh_fornecedor.razaos AS razao_social_fornecedor,
    rh_fornecedor.cnpj,
	p.id AS id_produto,
    p.descricao AS desc_produto,
    p.cod_barras AS cod_barras_produto,
	um.descricao AS unid_medida,
    ge_produto_fornecedor.valor_custo,
	ge_produto_fornecedor.valor_venda,
    ge_produto_fornecedor.quantiaestoque AS quantidade_em_estoque,
	p.min_estoque AS minimo_estoque,
    ge_lote.numlote AS numero_lote_prod,
    ga_usuario.nome AS usuario_que_movimentou,
    ge_produto_fornecedor.criado,
    ge_produto_fornecedor.editado
   FROM ge_produto_fornecedor
     JOIN ge_produto p ON ge_produto_fornecedor.idproduto = p.id
     JOIN ge_unidade_medida um ON p.id_unid_medida = um.id
     JOIN ge_lote ON ge_produto_fornecedor.idlote = ge_lote.id
     JOIN rh_fornecedor ON ge_produto_fornecedor.idfornecedor = rh_fornecedor.id
     JOIN ga_usuario ON ge_produto_fornecedor.idusuario = ga_usuario.id; 
-------------------------------------------------------------------------------
--VIEW PRODUTOS
CREATE OR REPLACE VIEW public.vw_produtos
AS SELECT p.codigo AS cod_produto,
    p.descricao,
    u.descricao AS unid_medida,
    g.descricao AS grupo_produto,
    p.ncm,
        CASE
            WHEN p.ativo = true THEN 'Sim'::text
            ELSE 'Não'::text
        END AS ativo,
    p.peso_bruto,
    p.peso_liquido,
    p.min_estoque,
    p.criado,
    p.editado
   FROM ge_produto p
     JOIN ge_grupo_produto g ON p.id_grupo = g.id
     JOIN ge_unidade_medida u ON p.id_unid_medida = u.id;
	
--------------------------------------------------------------------------
--  _______   _                           
-- |__   __| (_)                          
--    | |_ __ _  __ _  __ _  ___ _ __ ___ 
--    | | '__| |/ _` |/ _` |/ _ \ '__/ __|
--    | | |  | | (_| | (_| |  __/ |  \__ \
--    |_|_|  |_|\__, |\__, |\___|_|  |___/
--               __/ | __/ |              
--              |___/ |___/               
--------------------------------------------------------------------------
                  
--ao movimentar estoque do tipo 'Saida' verificar o min_estoque do produto
--se quantia movimentada for maior que o que tem no estoque ou ficar maior que o mínimo que precisa ter em estoque
--lançar um erro.
--se nao tiver problema, dar um update no produto com lote especifico retirando do estoque disponivel
-----------TRIGGER VERIFICA QUANTIA DISPONIVEL DE PRODUTO NA OP SAIDA
CREATE OR REPLACE FUNCTION verifica_quantidade_disp_produto() RETURNS TRIGGER AS $verifica_quantidade_disp_produto$
DECLARE
	tOpEstoque VARCHAR(7) :=  (SELECT o.tipo FROM ge_op_estoque o WHERE o.id = NEW.idOpEstoque);
	minEstoqueProd NUMERIC(10,3) := (SELECT p.min_estoque FROM ge_produto AS p WHERE p.id = NEW.idProduto);
	quantidadeEmEstoque NUMERIC(10,3) := (SELECT pf.quantiaEstoque FROM ge_produto_fornecedor AS pf WHERE pf.idproduto = NEW.idProduto AND pf.idFornecedor = NEW.idFornecedor AND pf.idlote = NEW.idLote);
BEGIN
IF tOpEstoque = 'Saida' THEN
	IF NEW.quantidade > (quantidadeEmEstoque - minEstoqueProd) THEN
	  RAISE EXCEPTION 'Quantia de saida superior a quantia em estoque - estoque minimo.'
      USING HINT = 'Favor verificar a quantia minima de estoque e a quantia em estoque dc produto.';
	  RETURN NEW;
	ELSE 
	--UPDATE SQL
		UPDATE ge_produto_fornecedor
		SET quantiaEstoque = (quantidadeEmEstoque - NEW.quantidade), editado = CURRENT_TIMESTAMP
		WHERE idproduto = NEW.idProduto AND idfornecedor = NEW.idFornecedor AND idlote = NEW.idLote;
		RETURN NEW;
	END IF;
RETURN NEW;
END IF;
RETURN NEW;
END;
$verifica_quantidade_disp_produto$ LANGUAGE plpgsql;

CREATE TRIGGER verifica_quantidade_disp_produto 
	BEFORE INSERT ON ge_mov_estoque 
		FOR EACH ROW EXECUTE PROCEDURE verifica_quantidade_disp_produto();
----------------------------------------------------------------------------------------------

-----------TRIGGER OP DE ESTOQUE DE ENTRADA--------------------------------------------------------
--na entrada de produtos, se existir um produto com mesmo fornecedor e lote já cadastrado apenas 
--atualizar o usuario que mudou, data e somar a quantia de old e new
CREATE OR REPLACE FUNCTION insere_produto_fornecedor() RETURNS TRIGGER AS $insere_produto_fornecedor$
DECLARE
	tOpEstoque VARCHAR(7) :=  (SELECT o.tipo FROM ge_op_estoque o WHERE o.id = NEW.idOpEstoque);
	quantiaEstoqueAtual NUMERIC(10,3) := (SELECT pf.quantiaEstoque FROM ge_produto_fornecedor AS pf WHERE idproduto = NEW.idProduto AND idfornecedor = NEW.idFornecedor AND idlote = NEW.idLote);
	valorAtual NUMERIC(10,2) := (SELECT pf.valor_custo FROM ge_produto_fornecedor AS pf WHERE idproduto = NEW.idProduto AND idfornecedor = NEW.idFornecedor AND idlote = NEW.idLote);
BEGIN
IF tOpEstoque = 'Entrada' THEN
	IF (NEW.valorTotal / NEW.quantidade) != valorAtual THEN
		RAISE EXCEPTION 'Valor % por item é diferente do valor antigo % por item', (NEW.valorTotal / NEW.quantidade), valorAtual
        USING HINT = 'Não é possível alterar o valor de produto de mesmo lote';
		RETURN NEW;
	ELSE 
			IF EXISTS (SELECT 1 FROM ge_produto_fornecedor WHERE idProduto = NEW.idProduto AND idFornecedor = NEW.idFornecedor AND idLote = NEW.idLote) THEN
				UPDATE ge_produto_fornecedor
				SET quantiaEstoque = (quantiaEstoqueAtual + NEW.quantidade), editado = CURRENT_TIMESTAMP, idUsuario = NEW.idusuario
				WHERE idproduto = NEW.idProduto AND idfornecedor = NEW.idFornecedor AND idlote = NEW.idLote;
				RETURN NEW;
			ELSE
				INSERT INTO ge_produto_fornecedor
				(idProduto, idFornecedor, quantiaEstoque, valor_custo, idLote, idUsuario, criado)
				VALUES
				(NEW.idProduto, NEW.idfornecedor, NEW.quantidade, NEW.valorTotal / NEW.quantidade, NEW.idLote, NEW.idUsuario, CURRENT_TIMESTAMP);
				RETURN NEW;
	
		END IF;
	END IF;
END IF;
RETURN NEW;
END;
$insere_produto_fornecedor$ LANGUAGE plpgsql;

CREATE TRIGGER insere_produto_fornecedor 
	BEFORE INSERT ON ge_mov_estoque 
		FOR EACH ROW EXECUTE PROCEDURE insere_produto_fornecedor();
----------------------------------------------------------------------------------------------