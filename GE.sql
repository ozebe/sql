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

--unidade de medida, ex: UN, KG, GR, TON
CREATE TABLE ge_unidade_medida(
id SERIAL NOT NULL UNIQUE,
descricao VARCHAR(255) NOT NULL UNIQUE,
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY KEY(id)
);

--unidade de massa, ex: KG, GR, ex: tal produto possui 1kg e é vendido por un
CREATE TABLE ge_unidade_massa(
id SERIAL NOT NULL UNIQUE,
descricao VARCHAR(255) NOT NULL UNIQUE,
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY KEY(id)
);

--grupos dos produtos
CREATE TABLE ge_grupo_prod(
id SERIAL NOT NULL UNIQUE,
codigo VARCHAR(255) NOT NULL UNIQUE, --IM001
descricao VARCHAR(255), --Ativo Imobilizado
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY KEY(id)
);

--sub grupo de produto
CREATE TABLE ge_sub_grupo_prod(
id SERIAL NOT NULL UNIQUE,
id_ge_grupo_prod INTEGER NOT NULL,
codigo VARCHAR(255) NOT NULL UNIQUE, --LAN
descricao VARCHAR(255), --Lanches
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
FOREIGN KEY(id_ge_grupo_prod) REFERENCES ge_grupo_prod(id),
PRIMARY KEY(id)
);

CREATE TABLE ge_produto(
id SERIAL NOT NULL UNIQUE,
codigo INTEGER NOT NULL UNIQUE, --código de controle interno do produto
descricao VARCHAR(255), --descrição do produto
id_unid_medida INTEGER NOT NULL, --unidade de medida, KG, GRAMAS.
id_unid_massa INTEGER, --unidade de medida de massa para o peso bruto e liquido
id_ge_sub_grupo_prod INTEGER NOT NULL,  --Sub grupo do produto ex: banana, frutas, alimentos.
cod_barras VARCHAR(255), --código de barras do produto
NCM VARCHAR(255), --para tributação
ativo BOOLEAN NOT NULL, --ativo ou não
peso_bruto NUMERIC(10,3), --peso bruto do produto
peso_liquido NUMERIC(10,3), --peso líquido do produto
valor_custo NUMERIC(10,2), --valor de custo do produto
valor_venda NUMERIC(10,2), --valor de venda do produto
min_estoque NUMERIC(10,3) CHECK (min_estoque >= 0) NOT NULL, --mínimo em estoque do produto
max_estoque NUMERIC(10,3), --máximo em estoque para o produto
estoque_atual NUMERIC(10,2), --quantia em estoque atual
criado TIMESTAMP NOT NULL, --data de inserção
editado TIMESTAMP, --data de edição do produto
PRIMARY KEY(id),
FOREIGN KEY(id_unid_medida) REFERENCES ge_unidade_medida(id),
FOREIGN KEY(id_unid_massa) REFERENCES ge_unidade_massa(id),
FOREIGN KEY(id_ge_sub_grupo_prod) REFERENCES ge_sub_grupo_prod(id)
);

CREATE TABLE ge_fornecedor(
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

CREATE TABLE ge_lote(
id SERIAL NOT NULL UNIQUE,
id_ge_produto INTEGER NOT NULL UNIQUE, --id do produto a qual o lote referencia
num_lote VARCHAR(255) NOT NULL UNIQUE, --número do lote
descricao VARCHAR(255), --descrição do lote
data_val DATE NOT NULL, --data de validade do lote
criado TIMESTAMP NOT NULL, --data de inserção no sistema
editado TIMESTAMP, --data de edição no sistema
FOREIGN KEY (id_ge_produto) REFERENCES ge_produto(id),
PRIMARY KEY(id)
);

--também cria-se um registo quando a movimentação de estoque é do tipo entrada e é selecionado o fornecedor
CREATE TABLE ge_produto_fornecedor(
id SERIAL NOT NULL UNIQUE,
id_ge_prod INTEGER NOT NULL, --id do produto em questão
id_ge_fornecedor INTEGER NOT NULL, --id do fornecedor de tal produto
quantia_estoque NUMERIC(10,3) CHECK (quantia_estoque >= 0) NOT NULL, --quantia em estoque atual do produto de tal fornecedor
valor_custo NUMERIC(10,2), --valor de custo do produto, caso não tenha pegará o val_total/quantia na entrada de movimentação de estoque
valor_venda NUMERIC(10,2), --valor de venda do produto
id_ge_lote INTEGER NOT NULL, --id do lote, apenas obrigatório o controle quando vem de um fornecedor especifico
id_ga_usuario INTEGER NOT NULL, --id do usuário que realizou a inserção no sistema
criado TIMESTAMP NOT NULL, --data da inserção no sistema
editado TIMESTAMP, --data da edição no sistema
--info a mais
PRIMARY KEY(id),
FOREIGN KEY(id_ge_lote) REFERENCES ge_lote(id),
FOREIGN KEY(id_ge_prod) REFERENCES ge_produto(id),
FOREIGN KEY(id_ge_fornecedor) REFERENCES ge_fornecedor(id),
FOREIGN KEY(id_ga_usuario) REFERENCES ga_usuario(id)
);

--Operações de estoque (Ajuste e etc) movimentações-------------------
--localizações de estoque
CREATE TABLE ge_estoque(
id SERIAL NOT NULL UNIQUE,
descricao VARCHAR(255) NOT NULL,
ativo BOOLEAN NOT NULL,
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY KEY(id)
);

--operações de estoque, ex: Entrada, compra de produtos
CREATE TABLE ge_op_estoque(
id SERIAL NOT NULL UNIQUE,
descricao VARCHAR(255) NOT NULL, --descrição da operação de estoque, ex: compra de produtos
tipo VARCHAR(7) CHECK (tipo IN ('Entrada', 'Saida', 'Ajuste')) NOT NULL, 
ativo BOOLEAN NOT NULL, --produto ativo ?
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY KEY(id)
);

--alterar essa tabela para deixar incluir um produto sem os dados do fornecedor
CREATE TABLE ge_mov_estoque(
id SERIAL NOT NULL UNIQUE,
id_ge_prod INTEGER NOT NULL, --id do produto
id_ge_op_estoque INTEGER NOT NULL, --id do tipo de movimentação de estoque
id_ge_estoque INTEGER NOT NULL, --id do estoque 
id_ge_lote INTEGER, --id do lote, opcional, pois pode-se dar entrada manualmente em produtos
num_nota_fiscal VARCHAR(255), --numero da nota fiscal, também opcional
id_ge_fornecedor INTEGER, --id do fornecedor, caso colocado, a movimentação de estoque ira colocar tal produto em ge_produto_fornecedor
data_mov DATE NOT NULL, --data de realização da movimentação
quantidade NUMERIC(10,3) NOT NULL, --quantia movimentada, lembrando que é da unidade de medida especifica do produto em questão
val_total NUMERIC(10,2), --valor total da movimentação do estoque
id_ga_usuario INTEGER NOT NULL, --id do usuario que realizou a movimentação de estoque
criado TIMESTAMP NOT NULL, --data de criação da movimentação
editado TIMESTAMP, --data de edição da movimentação
PRIMARY KEY(id),
FOREIGN KEY(id_ge_prod) REFERENCES ge_produto(id),
FOREIGN KEY(id_ge_lote) REFERENCES ge_lote(id),
FOREIGN KEY(id_ga_usuario) REFERENCES ga_usuario(id),
FOREIGN KEY(id_ge_op_estoque) REFERENCES ge_op_estoque(id),
FOREIGN KEY(id_ge_estoque) REFERENCES ge_estoque(id),
FOREIGN KEY(id_ge_fornecedor) REFERENCES ge_fornecedor(id)
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
AS SELECT f.razao_social,
    f.nome_fantasia,
    f.telefone,
    f.email,
    f.end_logr AS rua,
    f.end_num AS num_rua,
    f.end_cep AS cep,
    f.end_bairro AS bairro,
    f.end_localid AS cidade,
    f.end_compl as complemento,
    f.end_uf AS estado,
    f.cnpj,
    f.ie,
        CASE
            WHEN f.ativo = true THEN 'Sim'::text
            ELSE 'Não'::text
        END AS ativo,
        CASE
        	WHEN f.isento_icms = true THEN 'Sim'::text
        	ELSE 'Não'::text
        END AS isento_icms,
                case
        	WHEN f.opt_simpl_nacional = true THEN 'Sim'::text
        	ELSE 'Não'::text
        END AS opt_simpl_nacional,
    f.criado,
    f.editado
   FROM ge_fornecedor f
-------------------------------------------------------------------------------
--VIEW MOVIMENTACOES DE ESTOQUE quantiade, valor
CREATE OR REPLACE VIEW public.vw_movs_estoque
AS SELECT ge_mov_estoque.id AS id_mov_estoque,
	p.descricao AS desc_produto,
    ope.tipo AS tipo_op_estoque,
	ope.descricao AS operacao_estoque,
	ge_mov_estoque.quantidade,
	um.descricao AS unid_medida,
    ge_mov_estoque.val_total,
	p.cod_barras AS cod_barras_produto,
    ge_estoque.descricao AS nome_estoque,
    ge_lote.num_lote AS numero_lote_prod,
    ge_mov_estoque.num_nota_fiscal AS num_nota_fiscal,
    ge_fornecedor.razao_social AS razao_social_fornecedor,
    ge_mov_estoque.data_mov  AS data_da_movimentacao,
    ga_usuario.nome AS usuario_que_movimentou
   FROM ge_mov_estoque
     JOIN ge_produto p ON ge_mov_estoque.id_ge_prod = p.id
	 JOIN ge_unidade_medida um ON p.id_unid_medida = um.id
     JOIN ge_op_estoque ope ON ge_mov_estoque.id_ge_op_estoque = ope.id
     JOIN ge_estoque ON ge_mov_estoque.id_ge_estoque = ge_estoque.id
     JOIN ge_lote ON ge_mov_estoque.id_ge_lote = ge_lote.id
     JOIN ge_fornecedor ON ge_mov_estoque.id_ge_fornecedor = ge_fornecedor.id
     JOIN ga_usuario ON ge_mov_estoque.id_ga_usuario = ga_usuario.id; 
-------------------------------------------------------------------------------
--corrigir views e triggers
--VIEW PRODUTOS E RESPECTIVOS FORNECEDORES
 CREATE OR REPLACE VIEW public.vw_produto_fornecedor
AS SELECT ge_fornecedor.id AS id_fornecedor,
	ge_fornecedor.razaos AS razao_social_fornecedor,
    ge_fornecedor.cnpj,
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
     JOIN ge_fornecedor ON ge_produto_fornecedor.idfornecedor = ge_fornecedor.id
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
     JOIN ge_grupo_prod g ON p.id_grupo = g.id
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
