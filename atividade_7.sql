/* =========================================================
   1. LISTAR AS TABELAS DO SCHEMA
   ========================================================= */

SELECT table_name
FROM user_tables
ORDER BY table_name;


/* =========================================================
   2. CONFERIR AS COLUNAS DE PRODUTO E VENDA
   ========================================================= */

SELECT
    table_name,
    column_name,
    data_type,
    data_length
FROM user_tab_columns
WHERE table_name IN ('TB_PRODUTO', 'TB_VENDAS')
ORDER BY table_name, column_id;


/* =========================================================
   3. CONFERIR AS COLUNAS DAS TABELAS RELACIONADAS À VENDA
   ========================================================= */

SELECT
    table_name,
    column_name,
    data_type,
    data_length
FROM user_tab_columns
WHERE table_name IN (
    'TB_VENDA',
    'TB_VENDA_ITEM',
    'TB_CATEGORIA',
    'TB_CATEGORIAS'
)
ORDER BY table_name, column_id;


/* =========================================================
   4. CONFERIR A ESTRUTURA DE TB_VENDA_ITEM
   ========================================================= */

SELECT
    column_id,
    column_name,
    data_type,
    data_length,
    nullable
FROM user_tab_columns
WHERE table_name = 'TB_VENDA_ITEM'
ORDER BY column_id;


/* =========================================================
   5. CONSULTA DE AGREGAÇÃO ANTES DA MATERIALIZED VIEW
   Mostra quantidade e faturamento agrupados por produto.
   ========================================================= */

SELECT
    ID_PRODUTO,
    COUNT(*) AS TOTAL_TRANSACOES,
    SUM(QUANTIDADE) AS QTD_TOTAL_VENDIDA,
    SUM(VALOR_TOTAL) AS FATURAMENTO_TOTAL,
    COUNT(VALOR_TOTAL) AS COUNT_FATURAMENTO
FROM TB_VENDA_ITEM
GROUP BY ID_PRODUTO;


/* =========================================================
   6. CRIAR O MATERIALIZED VIEW LOG
   Executar uma única vez, se ainda não existir.
   ========================================================= */

CREATE MATERIALIZED VIEW LOG ON TB_VENDA_ITEM
WITH ROWID, SEQUENCE
(ID_PRODUTO, QUANTIDADE, VALOR_TOTAL)
INCLUDING NEW VALUES;


/* =========================================================
   7. CRIAR A MATERIALIZED VIEW
   Executar uma única vez, se ainda não existir.
   ========================================================= */

CREATE MATERIALIZED VIEW MV_VENDAS_POR_PRODUTO
BUILD IMMEDIATE
REFRESH FAST ON DEMAND
ENABLE QUERY REWRITE
AS
SELECT
    ID_PRODUTO,
    COUNT(*) AS TOTAL_TRANSACOES,
    SUM(QUANTIDADE) AS QTD_TOTAL_VENDIDA,
    SUM(VALOR_TOTAL) AS FATURAMENTO_TOTAL,
    COUNT(VALOR_TOTAL) AS COUNT_FATURAMENTO
FROM TB_VENDA_ITEM
GROUP BY ID_PRODUTO;


/* =========================================================
   8. CONSULTAR A MATERIALIZED VIEW
   ========================================================= */

SELECT *
FROM MV_VENDAS_POR_PRODUTO
ORDER BY FATURAMENTO_TOTAL DESC;


/* =========================================================
   9. CONSULTAR OS DADOS DO PRODUTO 5 ANTES DO TESTE
   No laboratório, o resultado registrado foi:
   27 transações, 63 unidades e R$ 185.920.
   ========================================================= */

SELECT *
FROM MV_VENDAS_POR_PRODUTO
WHERE ID_PRODUTO = 5;


/* =========================================================
   10. VERIFICAR O MAIOR ID_ITEM ANTES DO INSERT DE TESTE
   No laboratório, o resultado foi 375.
   ========================================================= */

SELECT MAX(ID_ITEM) AS MAIOR_ID_ITEM
FROM TB_VENDA_ITEM;


/* =========================================================
   11. INSERT DE TESTE — JÁ EXECUTADO NESTE LABORATÓRIO
   NÃO EXECUTAR NOVAMENTE.
   Foi inserido o ID_ITEM 376 para o produto 5.
   ========================================================= */

/*
INSERT INTO TB_VENDA_ITEM (
    ID_ITEM,
    ID_VENDA,
    ID_PRODUTO,
    QUANTIDADE,
    PRECO_UNIT,
    DESCONTO_ITEM,
    VALOR_TOTAL
)
VALUES (
    376,
    (SELECT MAX(ID_VENDA) FROM TB_VENDA),
    5,
    2,
    100,
    0,
    200
);
*/


/* =========================================================
   12. CONSULTAR A MATERIALIZED VIEW ANTES DO REFRESH
   Após o INSERT e antes do refresh, espera-se que a MV
   ainda mostre os valores anteriores.
   ========================================================= */

SELECT *
FROM MV_VENDAS_POR_PRODUTO
WHERE ID_PRODUTO = 5;


/* =========================================================
   13. EXECUTAR O FAST REFRESH
   ========================================================= */

BEGIN
    DBMS_MVIEW.REFRESH(
        LIST => 'MV_VENDAS_POR_PRODUTO',
        METHOD => 'F'
    );
END;
/


/* =========================================================
   14. CONSULTAR A MATERIALIZED VIEW DEPOIS DO REFRESH
   Resultado observado no laboratório:
   28 transações, 65 unidades e R$ 186.120.
   ========================================================= */

SELECT *
FROM MV_VENDAS_POR_PRODUTO
WHERE ID_PRODUTO = 5;


/* =========================================================
   15. VERIFICAR OS METADADOS DA MATERIALIZED VIEW
   ========================================================= */

SELECT
    MVIEW_NAME,
    REFRESH_MODE,
    REFRESH_METHOD,
    LAST_REFRESH_DATE,
    STALENESS
FROM USER_MVIEWS
WHERE MVIEW_NAME = 'MV_VENDAS_POR_PRODUTO';


/* =========================================================
   16. VERIFICAR O MATERIALIZED VIEW LOG
   ========================================================= */

SELECT
    MASTER,
    LOG_TABLE
FROM USER_MVIEW_LOGS
WHERE MASTER = 'TB_VENDA_ITEM';

