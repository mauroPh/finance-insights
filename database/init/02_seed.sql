-- ============================================================
-- SEED: carrega transacoes.csv via tabela staging
-- ============================================================

CREATE TEMP TABLE staging (
    data       DATE           NOT NULL,
    categoria  VARCHAR(50)    NOT NULL,
    tipo       VARCHAR(10)    NOT NULL,
    valor      NUMERIC(12, 2) NOT NULL
);

COPY staging (data, categoria, tipo, valor)
FROM '/tmp/transacoes.csv'
WITH (FORMAT CSV, HEADER true, DELIMITER ',');

-- Dim_Categoria: categorias distintas com classificação de grupo
INSERT INTO dim_categoria (nome, grupo)
SELECT DISTINCT
    categoria,
    CASE categoria
        WHEN 'Salario'       THEN 'Receita'
        WHEN 'Moradia'       THEN 'Essencial'
        WHEN 'Alimentacao'   THEN 'Essencial'
        WHEN 'Transporte'    THEN 'Essencial'
        WHEN 'Saude'         THEN 'Essencial'
        WHEN 'Assinaturas'   THEN 'Essencial'
        WHEN 'Educacao'      THEN 'Educacao'
        WHEN 'Lazer'         THEN 'Lazer'
        WHEN 'Investimentos' THEN 'Investimento'
        ELSE 'Outros'
    END
FROM staging
ORDER BY categoria;

-- Dim_Tempo: datas distintas com granularidade temporal extraída
INSERT INTO dim_tempo (data, ano, mes, dia, nome_mes, trimestre)
SELECT DISTINCT
    data,
    EXTRACT(YEAR    FROM data)::INTEGER,
    EXTRACT(MONTH   FROM data)::INTEGER,
    EXTRACT(DAY     FROM data)::INTEGER,
    TO_CHAR(data, 'TMMonth'),
    EXTRACT(QUARTER FROM data)::INTEGER
FROM staging
ORDER BY data;

-- Fato_Lancamentos: lançamentos ligados às dimensões
INSERT INTO fato_lancamentos (id_categoria, id_tempo, tipo, valor)
SELECT
    dc.id_categoria,
    dt.id_tempo,
    s.tipo,
    s.valor
FROM staging s
JOIN dim_categoria dc ON dc.nome  = s.categoria
JOIN dim_tempo     dt ON dt.data  = s.data;
