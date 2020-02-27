----------------------------------------------------------------------------------------------------------
--  ____  ____  _        ____           _   /\/|            _                           
-- |  _ \|  _ \| |      / ___| ___  ___| |_|/\/_  ___      / \   ___ ___  ___ ___  ___  
-- | | | | | | | |     | |  _ / _ \/ __| __/ _` |/ _ \    / _ \ / __/ _ \/ __/ __|/ _ \ 
-- | |_| | |_| | |___  | |_| |  __/\__ \ || (_| | (_) |  / ___ \ (_|  __/\__ \__ \ (_) |
-- |____/|____/|_____|  \____|\___||___/\__\__,_|\___/  /_/   \_\___\___||___/___/\___/ 

----------------------------------------------------------------------------------------------------------                                                       --ga_xxxxxx_xxxxx
--São tabelas destinadas á gestão de acesso, contendo tabelas como usuario, nivel de acesso e nível por usuário.                            
--PRE-REQUISITOS: Nenhum

CREATE TABLE ga_nivel_acesso(
id SERIAL NOT NULL UNIQUE,
sigla VARCHAR(3) NOT NULL UNIQUE,
descricao VARCHAR(255),
PRIMARY KEY(id)
);
   
CREATE TABLE ga_usuario(
id SERIAL NOT NULL UNIQUE,
nome VARCHAR(255) NOT NULL,
usuario VARCHAR(255) NOT NULL UNIQUE,
senha VARCHAR(255) NOT NULL,
bloqueado BOOLEAN NOT NULL,
ativo BOOLEAN NOT NULL,
tentativas INTEGER CHECK(tentativas <= 3),
criado TIMESTAMP NOT NULL,
editado TIMESTAMP,
PRIMARY KEY(id)
);

CREATE TABLE ga_nivel_usuario(
id SERIAL NOT NULL UNIQUE,
id_usuario INTEGER NOT NULL,
id_nivel_acesso INTEGER NOT NULL,
PRIMARY KEY(id),
FOREIGN KEY(id_usuario) REFERENCES ga_usuario(id),
FOREIGN KEY(id_nivel_acesso) REFERENCES ga_nivel_acesso(id)
);
