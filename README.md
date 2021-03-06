# PostgreSQL ERP
>  Estrutura SQL para controle de usuários, estoque, vendas e etc.


![](https://img.shields.io/github/license/ozebe/sql.svg)
![](https://img.shields.io/github/issues/ozebe/sql.svg)
![](https://img.shields.io/github/commit-activity/m/ozebe/sql.svg)
![](https://img.shields.io/github/repo-size/ozebe/sql.svg)

Estrutura de banco de dados composta por módulos, como módulos de gestão de acesso, gestão de RH, gestão de vendas e etc.

![](header.png)
## Pré requisitos

*Servidor PostgreSQL configurado.*

## Configuração/Instalação

Cada arquivo possui tudo que é necessário para a configuração inicial, tanto suas views e seus triggers.
Caso queira algum módulo especifico, como gestão de acesso, RH ou algo do tipo, é necessário abrir cada módulo e verificar a parte de "requisitos" e executar os arquivos ou módulos dos requisitos. Lembrando que marcações de commit betas ou alfas não devem ser utilizados em produção, apenas para testes e adequações.

#### Nomenclatura de tabelas, views, triggers funções e etc.

- **Views são identificadas por vw_xxxxxx_xxxxx**
- **Triggers são identificados por trg_xxxxxx_xxxxx**
- **Funções são identificadas por fn_xxxxxx_xxxxx**

**Nomes das Tabelas**

**rh_xxxxxx_xxxxx** : *São tabelas destinadas á recursos humanos, nelas possuem pessoas físicas, funcionários, dependentes, jornadas de trabalho, profissões e etc.*

**ge_xxxxxx_xxxxx** : *São tabelas destinadas á gestão do estoque, contendo, estoque, grupo de produto, lote, movimentação de estoque, operação de estoque, produto, unidade de medida e etc.*

**ga_xxxxxx_xxxxx** :  *São tabelas destinadas á gestão de acesso, contendo tabelas como usuario, nivel de acesso e etc.*

**gf_xxxxxx_xxxxx** :  *São tabelas destinadas á gestão de finanças., contendo tabelas como cadastro de fornecedores, clientes, lista de credores, planos de contas, cartões, tipos de pagamentos, contas a receber, contas a pagar, parcelas das respectivas contas a pagar e receber, bancos, agências bancárias,  contas bancárias

**gv_xxxxxx_xxxxx** : *São tabelas destinadas a gestão de vendas.

**ma_xxxxxx_xxxxx** :  *São tabelas de miscelanea como agenda e etc*

## Exemplos de uso e cadastros

_Para mais informações visualize a [Wiki][wiki]._

## Meta

Wesley Ozebe – Criador

Distribuído sob a licença MIT. Veja ``LICENSE`` para mais informações.

[https://github.com/ozebe/sql/blob/master/LICENSE](https://github.com/ozebe/sql/blob/master/LICENSE)

## Contribuindo

1. Realize o Fork (<https://github.com/ozebe/sql/fork>)
2. Crie a sua branch (`git checkout -b feature/fooBar`)
3. Realize o commit (`git commit -am 'Add some fooBar'`)
4. Push para a branch (`git push origin feature/fooBar`)
5. Crie um novo pull request.

[wiki]: https://github.com/ozebe/sql/wiki
