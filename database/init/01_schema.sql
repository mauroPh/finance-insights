-- ============================================================
-- SCHEMA: Finance Insights
-- Modelo estrela: 1 tabela fato + 2 dimensões
-- ============================================================

CREATE TABLE dim_categoria (
    id_categoria  SERIAL      PRIMARY KEY,
    nome          VARCHAR(50) NOT NULL UNIQUE,
    grupo         VARCHAR(30) NOT NULL
);

CREATE TABLE dim_tempo (
    id_tempo   SERIAL      PRIMARY KEY,
    data       DATE        NOT NULL UNIQUE,
    ano        INTEGER     NOT NULL,
    mes        INTEGER     NOT NULL,
    dia        INTEGER     NOT NULL,
    nome_mes   VARCHAR(20) NOT NULL,
    trimestre  INTEGER     NOT NULL
);

CREATE TABLE fato_lancamentos (
    id_lancamento  SERIAL          PRIMARY KEY,
    id_categoria   INTEGER         NOT NULL REFERENCES dim_categoria(id_categoria),
    id_tempo       INTEGER         NOT NULL REFERENCES dim_tempo(id_tempo),
    tipo           VARCHAR(10)     NOT NULL CHECK (tipo IN ('receita', 'despesa')),
    valor          NUMERIC(12, 2)  NOT NULL CHECK (valor > 0)
);

CREATE INDEX idx_fato_categoria ON fato_lancamentos(id_categoria);
CREATE INDEX idx_fato_tempo     ON fato_lancamentos(id_tempo);
CREATE INDEX idx_fato_tipo      ON fato_lancamentos(tipo);
