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

--localizações de estoque
CREATE TABLE ge_estoque(
id SERIAL NOT NULL UNIQUE,
descricao VARCHAR(255) NOT NULL,
ativo BOOLEAN NOT NULL,
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY KEY(id)
);

--lotes de produtos
CREATE TABLE ge_lote(
id SERIAL NOT NULL UNIQUE,
num_lote VARCHAR(255) NOT NULL UNIQUE, --número do lote
descricao VARCHAR(255), --descrição do lote
data_val DATE NOT NULL, --data de validade do lote
criado TIMESTAMP NOT NULL, --data de inserção no sistema
editado TIMESTAMP, --data de edição no sistema
PRIMARY KEY(id)
);

CREATE TABLE ge_produto(
id SERIAL NOT NULL UNIQUE,
codigo VARCHAR(30) NOT NULL UNIQUE, --código de controle interno do produto
descricao VARCHAR(255), --descrição do produto
id_unid_medida INTEGER NOT NULL, --unidade de medida, KG, GRAMAS.
id_unid_massa INTEGER, --unidade de medida de massa para o peso bruto e liquido
id_ge_sub_grupo_prod INTEGER NOT NULL,  --Sub grupo do produto ex: banana, frutas, alimentos.
id_ge_estoque INTEGER, --id do estoque a qual o produto se encontra
cod_barras VARCHAR(255), --código de barras do produto
NCM VARCHAR(255), --para tributação
ativo BOOLEAN NOT NULL, --ativo ou não
peso_bruto NUMERIC(10,3), --peso bruto do produto
peso_liquido NUMERIC(10,3), --peso líquido do produto
id_ge_lote INTEGER, --id do lote
valor_custo NUMERIC(10,2), --valor de custo do produto
valor_venda NUMERIC(10,2), --valor de venda do produto
min_estoque NUMERIC(10,3) CHECK (min_estoque >= 0) NOT NULL, --mínimo em estoque do produto
max_estoque NUMERIC(10,3) CHECK (max_estoque >= min_estoque), --máximo em estoque para o produto
estoque_atual NUMERIC(10,2), --quantia em estoque atual
criado TIMESTAMP NOT NULL, --data de inserção
editado TIMESTAMP, --data de edição do produto
PRIMARY KEY(id),
FOREIGN KEY(id_unid_medida) REFERENCES ge_unidade_medida(id),
FOREIGN KEY(id_unid_massa) REFERENCES ge_unidade_massa(id),
FOREIGN KEY(id_ge_estoque) REFERENCES ge_estoque(id),
FOREIGN KEY(id_ge_lote) REFERENCES ge_lote(id),
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

--também cria-se um registo quando a movimentação de estoque é do tipo entrada e é selecionado o fornecedor
CREATE TABLE ge_produto_fornecedor(
id SERIAL NOT NULL UNIQUE,
id_ge_prod INTEGER NOT NULL, --id do produto em questão
id_ge_fornecedor INTEGER NOT NULL, --id do fornecedor de tal produto
quantia_estoque NUMERIC(10,3) CHECK (quantia_estoque >= 0) NOT NULL, --quantia em estoque atual do produto de tal fornecedor
valor_custo NUMERIC(10,2), --valor de custo do produto, caso não tenha pegará o val_total/quantia na entrada de movimentação de estoque
valor_venda NUMERIC(10,2), --valor de venda do produto
id_ge_lote INTEGER, --id do lote
id_ge_estoque INTEGER NOT NULL, --id do estoque a qual o produto se encontra
id_ga_usuario INTEGER NOT NULL, --id do usuário que realizou a inserção no sistema
criado TIMESTAMP NOT NULL, --data da inserção no sistema
editado TIMESTAMP, --data da edição no sistema
--info a mais
PRIMARY KEY(id),
FOREIGN KEY(id_ge_lote) REFERENCES ge_lote(id),
FOREIGN KEY(id_ge_prod) REFERENCES ge_produto(id),
FOREIGN KEY(id_ge_fornecedor) REFERENCES ge_fornecedor(id),
FOREIGN KEY(id_ge_estoque) REFERENCES ge_estoque(id),
FOREIGN KEY(id_ga_usuario) REFERENCES ga_usuario(id)
);

--Operações de estoque (Ajuste e etc) movimentações-------------------
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
CREATE OR REPLACE VIEW public.vw_ge_fornecedores
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
CREATE OR REPLACE VIEW public.vw_ge_movs_estoque
AS SELECT ge_mov_estoque.id AS id_mov_estoque,
	p.codigo AS cod_produto,
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
     LEFT JOIN ge_lote ON ge_mov_estoque.id_ge_lote = ge_lote.id
     LEFT JOIN ge_fornecedor ON ge_mov_estoque.id_ge_fornecedor = ge_fornecedor.id
     JOIN ga_usuario ON ge_mov_estoque.id_ga_usuario = ga_usuario.id; 
-------------------------------------------------------------------------------
--corrigir views e triggers
--VIEW PRODUTOS E RESPECTIVOS FORNECEDORES
 CREATE OR REPLACE VIEW public.vw_ge_produto_fornecedor
AS SELECT ge_fornecedor.id AS id_fornecedor,
	ge_fornecedor.razao_social AS razao_social_fornecedor,
    ge_fornecedor.cnpj,
	p.codigo AS cod_produto,
    p.descricao AS desc_produto,
    p.cod_barras AS cod_barras_produto,
	um.descricao AS unid_medida,
    ge_produto_fornecedor.valor_custo,
	ge_produto_fornecedor.valor_venda,
    ge_produto_fornecedor.quantia_estoque AS quantidade_em_estoque,
	p.min_estoque AS minimo_estoque,
	p.max_estoque AS maximo_estoque,
    ge_lote.num_lote AS numero_lote_prod,
    ga_usuario.nome AS usuario_que_movimentou,
    ge_produto_fornecedor.criado,
    ge_produto_fornecedor.editado
   FROM ge_produto_fornecedor
     JOIN ge_produto p ON ge_produto_fornecedor.id_ge_prod = p.id
     JOIN ge_unidade_medida um ON p.id_unid_medida = um.id
     LEFT JOIN ge_lote ON ge_produto_fornecedor.id_ge_lote = ge_lote.id
     JOIN ge_fornecedor ON ge_produto_fornecedor.id_ge_fornecedor = ge_fornecedor.id
     JOIN ga_usuario ON ge_produto_fornecedor.id_ga_usuario = ga_usuario.id; 
-------------------------------------------------------------------------------
--VIEW PRODUTOS
CREATE OR REPLACE VIEW public.vw_ge_produtos
AS SELECT p.codigo AS cod_produto,
        CASE
            WHEN p.ativo = true THEN 'Sim'::text
            ELSE 'Não'::text
        END AS ativo,
    p.descricao,
	p.quantia_estoque AS qtd_em_estoque,
    p.valor_venda,
    p.valor_custo,
    u.descricao AS unid_medida,
    um.descricao as unid_massa,
    g.descricao AS grupo_produto,
    gs.descricao AS sub_grupo_produto,
    l.num_lote AS num_lote_produto,
    e.descricao AS desc_estoque_produto,
    p.ncm,
    p.peso_bruto,
    p.peso_liquido,
    p.min_estoque,
    p.max_estoque,
    p.criado,
    p.editado
   FROM ge_produto p
     JOIN ge_sub_grupo_prod gs ON p.id_ge_sub_grupo_prod = gs.id
     JOIN ge_grupo_prod g ON gs.id_ge_grupo_prod = g.id
     LEFT JOIN ge_lote l ON p.id_ge_lote = l.id
     JOIN ge_estoque e ON p.id_ge_estoque = e.id
     JOIN ge_unidade_medida u ON p.id_unid_medida = u.id
     JOIN ge_unidade_massa um ON p.id_unid_massa = um.id;
	
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

--função responsável por verificar o tipo de movimentação de estoque
CREATE OR REPLACE FUNCTION fn_verifica_ge_movs_estoque() RETURNS TRIGGER AS $fn_verifica_ge_movs_estoque$
DECLARE
	ge_produto_ativo BOOLEAN := (SELECT p.ativo FROM ge_produto p WHERE p.id = NEW.id_ge_prod); --produto ativo ?
	ge_op_estoque_ativo BOOLEAN := (SELECT op.ativo FROM ge_op_estoque op WHERE op.id = NEW.id_ge_op_estoque); --operação de estoque ativa?
	ge_estoque_ativo BOOLEAN := (SELECT e.ativo FROM ge_estoque e WHERE e.id = NEW.id_ge_estoque); --estoque ativo ?
	validade_lote DATE := (SELECT l.data_val FROM ge_lote l WHERE l.id = NEW.id_ge_lote); --data de validade do lote inserido 
	ge_fornecedor_ativo BOOLEAN := (SELECT f.ativo FROM ge_fornecedor f WHERE f.id = NEW.id_ge_fornecedor); --fornecedor ativo ?
	tp_ge_op_estoque VARCHAR := (SELECT o.tipo FROM ge_op_estoque o WHERE o.id = NEW.id_ge_op_estoque); --verifica o tipo da operação de estoque
	
	qtd_atual_prod_f NUMERIC(10,3) := (SELECT pf.quantia_estoque FROM ge_produto_fornecedor AS pf WHERE id_ge_prod = NEW.id_ge_prod AND id_ge_fornecedor = NEW.id_ge_fornecedor);
	--quantia atual do produto por tal fornecedor, sem lote.
	qtd_atual_prod_f_l NUMERIC(10,3) := (SELECT pf.quantia_estoque FROM ge_produto_fornecedor AS pf WHERE id_ge_prod = NEW.id_ge_prod AND id_ge_fornecedor = NEW.id_ge_fornecedor AND id_ge_lote = NEW.id_ge_lote);
	--quantia atual do produto de tal fornecedor por tal lote
	qtd_atual_prod_f_l_e NUMERIC(10,3) := (SELECT pf.quantia_estoque FROM ge_produto_fornecedor AS pf WHERE id_ge_prod = NEW.id_ge_prod AND id_ge_fornecedor = NEW.id_ge_fornecedor AND id_ge_lote = NEW.id_ge_lote);
	--quantia atual do produto de tal fornecedor por tal lote e tal estoque
	qtd_atual_prod NUMERIC(10,3) := (SELECT p.quantia_estoque FROM ge_produto p WHERE p.id = NEW.id_ge_prod);
	--quantia atual do produto, ignorando lote, fornecedor e estoque
	qtd_atual_prod_l NUMERIC(10,3) := (SELECT p.quantia_estoque FROM ge_produto p WHERE p.id = NEW.id_ge_prod AND p.id_ge_lote = NEW.id_ge_lote);
	--quantia atual do produto por lote, sem fornecedor.
	
	valorAtual NUMERIC(10,2) := (SELECT pf.valor_custo FROM ge_produto_fornecedor AS pf WHERE id_ge_prod = NEW.id_ge_prod AND id_ge_fornecedor = NEW.id_ge_fornecedor AND id_ge_lote = NEW.id_ge_lote);
BEGIN
IF ge_produto_ativo = true THEN --se o produto estiver ativo
	IF ge_op_estoque_ativo = true THEN --se a operação de estoque estiver ativa
		IF ge_estoque_ativo = true THEN --se o estoque estiver ativo
			IF tp_ge_op_estoque = 'Entrada' THEN --se a operaçao de estoque for de entrada
				IF NEW.id_ge_lote IS NULL THEN --caso não foi informado o lote do produto
					IF NEW.id_ge_fornecedor IS NULL THEN --caso não foi informado o fornecedor
						IF EXISTS (SELECT 1 FROM ge_produto p WHERE p.id = NEW.id_ge_prod) THEN --caso o produto informado já esteja cadastrado, sem lote
							UPDATE ge_produto
							SET id_ge_estoque = NEW.id_ge_estoque, quantia_estoque = (qtd_atual_prod + NEW.quantidade), editado = CURRENT_TIMESTAMP
							WHERE id = NEW.id_ge_prod;
							RETURN NEW;
						ELSE --caso o produto informado não esteja cadastrado
							RAISE EXCEPTION 'Não foi possível encontrar o produto'
							USING HINT = 'Realize o cadastro do produto para realizar movimentação de estoque';
						END IF;
					ELSE --caso foi informado o fornecedor, sem lote
						IF EXISTS (SELECT 1 FROM ge_produto_fornecedor WHERE id_ge_prod = NEW.id_ge_prod AND id_ge_fornecedor = NEW.id_ge_fornecedor) THEN
							UPDATE ge_produto_fornecedor
							SET quantia_estoque = (qtd_atual_prod_f + NEW.quantidade), editado = CURRENT_TIMESTAMP, id_ge_estoque = NEW.id_ge_estoque, id_ga_usuario = NEW.id_ga_usuario
							WHERE id_ge_prod = NEW.id_ge_prod AND id_ge_fornecedor = NEW.id_ge_fornecedor;
							RETURN NEW;
						ELSE --caso ainda não exista registro na tabela ge_produto_fornecedor, e o lote não tenha sido informado
							INSERT INTO ge_produto_fornecedor
							(id_ge_prod, id_ge_fornecedor, quantia_estoque, valor_custo, valor_venda, id_ge_estoque, id_ga_usuario, criado)
							VALUES
							(NEW.id_ge_prod, NEW.id_ge_fornecedor, NEW.quantidade, (SELECT p.valor_custo FROM ge_produto p WHERE p.id = NEW.id_ge_prod), 
							(SELECT p.valor_venda FROM ge_produto p WHERE p.id = NEW.id_ge_prod), NEW.id_ge_estoque, NEW.id_ga_usuario, CURRENT_TIMESTAMP);
							RAISE NOTICE 'Inserido produto e fornecedor na tabela ge_produto_fornecedor, utilizando valor de custo e venda previamente cadastrado!)';
							RETURN NEW;
						END IF;
					END IF;
				ELSE --caso foi informado o lote do produto
					IF validade_lote >= CURRENT_DATE THEN --se o lote estiver dentro do prazo de validade
						IF NEW.id_ge_fornecedor IS NULL THEN --caso não foi informado o fornecedor
							IF EXISTS (SELECT 1 FROM ge_produto p WHERE p.id = NEW.id_ge_prod AND p.id_ge_lote = NEW.id_ge_lote) THEN --caso o produto informado já esteja cadastrado, com lote
								UPDATE ge_produto
								SET id_ge_estoque = NEW.id_ge_estoque, id_ge_lote = NEW.id_ge_lote, quantia_estoque = (qtd_atual_prod_l + NEW.quantidade), editado = CURRENT_TIMESTAMP
								WHERE id = NEW.id_ge_prod;
								RETURN NEW;
							ELSE --caso o produto informado não esteja cadastrado
								RAISE EXCEPTION 'Não foi possível encontrar o produto'
								USING HINT = 'Verifique o cadastro do produto!';
							END IF;
						ELSE --caso foi informado o fornecedor, com lote
							IF EXISTS (SELECT 1 FROM ge_produto_fornecedor WHERE id_ge_prod = NEW.id_ge_prod AND id_ge_fornecedor = NEW.id_ge_fornecedor AND id_ge_lote = NEW.id_ge_lote) THEN
								UPDATE ge_produto_fornecedor
								SET quantia_estoque = (qtd_atual_prod_f_l + NEW.quantidade), editado = CURRENT_TIMESTAMP, id_ge_estoque = NEW.id_ge_estoque, id_ga_usuario = NEW.id_ga_usuario
								WHERE id_ge_prod = NEW.id_ge_prod AND id_ge_fornecedor = NEW.id_ge_fornecedor;
								RETURN NEW;
							ELSE --caso ainda não exista registro na tabela ge_produto_fornecedor, e o lote tenha sido informado
								INSERT INTO ge_produto_fornecedor
								(id_ge_prod, id_ge_fornecedor, quantia_estoque, valor_custo, valor_venda, id_ge_lote, id_ge_estoque, id_ga_usuario, criado)
								VALUES
								(NEW.id_ge_prod, NEW.id_ge_fornecedor, NEW.quantidade, (SELECT p.valor_custo FROM ge_produto p WHERE p.id = NEW.id_ge_prod AND p.id_ge_lote = NEW.id_ge_lote), 
								(SELECT p.valor_venda FROM ge_produto p WHERE p.id = NEW.id_ge_prod AND p.id_ge_lote = NEW.id_ge_lote), NEW.id_ge_lote, NEW.id_ge_estoque, NEW.id_ga_usuario, CURRENT_TIMESTAMP);
								RAISE NOTICE 'Inserido produto e fornecedor na tabela ge_produto_fornecedor, utilizando valor de custo e venda e lote previamente cadastrado!)';
								RETURN NEW;
							END IF;
						END IF;
					ELSE --caso o lote esteja vencido
						RAISE EXCEPTION 'O lote com numero % esta vencido, data de vencimento: % data atual: %', (SELECT l.num_lote FROM ge_lote l WHERE l.id = NEW.id_ge_lote), (SELECT l.data_val FROM ge_lote l WHERE l.id = NEW.id_ge_lote), CURRENT_DATE
						USING HINT = 'Não é possível movimentar o estoque com um lote vencido.';
					END IF;
				END IF;
			ELSIF tp_ge_op_estoque = 'Saida' THEN --caso a movimentação seja de saida
			
			ELSE --caso a movimentação não seja de entrada ou de saida
				
			END IF; 
		ELSE --caso o estoque esteja desativado
					RAISE EXCEPTION 'O estoque % esta desativado', (SELECT e.descricao FROM ge_estoque e WHERE e.id = NEW.id_ge_estoque)
					USING HINT = 'Não é possível movimentar o estoque em um estoque desativado.';
		END IF;
	
	ELSE --caso a operação de estoque não esteja ativa
			RAISE EXCEPTION 'A operação de estoque % esta desativada', (SELECT op.descricao FROM ge_op_estoque op WHERE op.id = NEW.id_ge_op_estoque)
			USING HINT = 'Não é possível movimentar o estoque com uma operação desativada.';
	END IF;
ELSE --caso o produto não esteja ativo 
		RAISE EXCEPTION 'O produto com código % esta desativado', (SELECT p.codigo FROM ge_produto p WHERE p.id = NEW.id_ge_prod)
        USING HINT = 'Não é possível movimentar o estoque de um produto desativado.';
END IF;
RETURN NEW;
END;
$fn_verifica_ge_movs_estoque$ LANGUAGE plpgsql;

CREATE TRIGGER trg_verif_movs_entra
	BEFORE INSERT ON ge_mov_estoque 
		FOR EACH ROW EXECUTE PROCEDURE fn_verifica_ge_movs_estoque();
----------------------------------------------------------------------------------------------
