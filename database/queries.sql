-- ============================================================
-- QUERIES ANALÍTICAS — Finance Insights
-- Banco: PostgreSQL 16
-- ============================================================


-- ── 1. TOTAL GASTO POR CATEGORIA ──────────────────────────────────────────────
-- Ranking de despesas + participação percentual sobre o total.
SELECT
    dc.nome                                                         AS categoria,
    dc.grupo,
    SUM(fl.valor)                                                   AS total,
    ROUND(SUM(fl.valor) * 100.0 / SUM(SUM(fl.valor)) OVER (), 2)   AS participacao_pct
FROM fato_lancamentos fl
JOIN dim_categoria dc ON dc.id_categoria = fl.id_categoria
WHERE fl.tipo = 'despesa'
GROUP BY dc.nome, dc.grupo
ORDER BY total DESC;


-- ── 2. RECEITA, DESPESA E SALDO POR MÊS ──────────────────────────────────────
-- Fluxo de caixa mensal consolidado.
SELECT
    dt.ano,
    dt.mes,
    dt.nome_mes,
    SUM(CASE WHEN fl.tipo = 'receita' THEN fl.valor ELSE 0 END)            AS receita,
    SUM(CASE WHEN fl.tipo = 'despesa' THEN fl.valor ELSE 0 END)            AS despesa,
    SUM(CASE WHEN fl.tipo = 'receita' THEN fl.valor ELSE -fl.valor END)    AS saldo
FROM fato_lancamentos fl
JOIN dim_tempo dt ON dt.id_tempo = fl.id_tempo
GROUP BY dt.ano, dt.mes, dt.nome_mes
ORDER BY dt.ano, dt.mes;


-- ── 3. MAIOR GASTO INDIVIDUAL ─────────────────────────────────────────────────
SELECT
    dt.data,
    dc.nome     AS categoria,
    fl.valor
FROM fato_lancamentos fl
JOIN dim_categoria dc ON dc.id_categoria = fl.id_categoria
JOIN dim_tempo     dt ON dt.id_tempo     = fl.id_tempo
WHERE fl.tipo = 'despesa'
ORDER BY fl.valor DESC
LIMIT 1;


-- ── 4. TOP 5 MAIORES DESPESAS ─────────────────────────────────────────────────
SELECT
    dt.data,
    dc.nome     AS categoria,
    fl.valor
FROM fato_lancamentos fl
JOIN dim_categoria dc ON dc.id_categoria = fl.id_categoria
JOIN dim_tempo     dt ON dt.id_tempo     = fl.id_tempo
WHERE fl.tipo = 'despesa'
ORDER BY fl.valor DESC
LIMIT 5;


-- ── 5. VARIAÇÃO MÊS A MÊS POR CATEGORIA (CTE + LAG) ─────────────────────────
-- Crescimento percentual de cada categoria entre meses consecutivos.
WITH gastos_mensais AS (
    SELECT
        dc.nome           AS categoria,
        dt.ano,
        dt.mes,
        SUM(fl.valor)     AS total_mes
    FROM fato_lancamentos fl
    JOIN dim_categoria dc ON dc.id_categoria = fl.id_categoria
    JOIN dim_tempo     dt ON dt.id_tempo     = fl.id_tempo
    WHERE fl.tipo = 'despesa'
    GROUP BY dc.nome, dt.ano, dt.mes
),
com_variacao AS (
    SELECT
        categoria,
        ano,
        mes,
        total_mes,
        LAG(total_mes) OVER (PARTITION BY categoria ORDER BY ano, mes)  AS total_mes_anterior,
        ROUND(
            (total_mes - LAG(total_mes) OVER (PARTITION BY categoria ORDER BY ano, mes))
            / NULLIF(LAG(total_mes) OVER (PARTITION BY categoria ORDER BY ano, mes), 0)
            * 100,
        2) AS variacao_pct
    FROM gastos_mensais
)
SELECT *
FROM com_variacao
WHERE total_mes_anterior IS NOT NULL
ORDER BY variacao_pct DESC;


-- ── 6. SALDO CUMULATIVO (WINDOW FUNCTION) ────────────────────────────────────
-- Evolução do patrimônio acumulado lançamento a lançamento.
SELECT
    dt.data,
    dc.nome     AS categoria,
    fl.tipo,
    fl.valor,
    SUM(
        CASE WHEN fl.tipo = 'receita' THEN fl.valor ELSE -fl.valor END
    ) OVER (
        ORDER BY dt.data, fl.id_lancamento
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS saldo_cumulativo
FROM fato_lancamentos fl
JOIN dim_tempo     dt ON dt.id_tempo     = fl.id_tempo
JOIN dim_categoria dc ON dc.id_categoria = fl.id_categoria
ORDER BY dt.data, fl.id_lancamento;


-- ── 7. DESVIO ORÇAMENTÁRIO — BUDGET VS ACTUAL (CTE) ──────────────────────────
-- Compara o gasto real do último mês com a mediana histórica (proxy de budget).
WITH historico AS (
    SELECT
        dc.nome           AS categoria,
        dt.ano,
        dt.mes,
        SUM(fl.valor)     AS gasto_mes
    FROM fato_lancamentos fl
    JOIN dim_categoria dc ON dc.id_categoria = fl.id_categoria
    JOIN dim_tempo     dt ON dt.id_tempo     = fl.id_tempo
    WHERE fl.tipo = 'despesa'
    GROUP BY dc.nome, dt.ano, dt.mes
),
ultimo_periodo AS (
    SELECT MAX(ano * 100 + mes) AS periodo FROM historico
),
budget AS (
    -- mediana dos meses anteriores ao último como referência de orçamento
    SELECT
        h.categoria,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY h.gasto_mes) AS budget_mediano
    FROM historico h
    CROSS JOIN ultimo_periodo u
    WHERE h.ano * 100 + h.mes < u.periodo
    GROUP BY h.categoria
),
actual AS (
    SELECT h.categoria, h.gasto_mes AS actual
    FROM historico h
    CROSS JOIN ultimo_periodo u
    WHERE h.ano * 100 + h.mes = u.periodo
)
SELECT
    a.categoria,
    ROUND(b.budget_mediano, 2)                                          AS budget,
    a.actual,
    ROUND(a.actual - b.budget_mediano, 2)                               AS desvio,
    ROUND((a.actual - b.budget_mediano) / NULLIF(b.budget_mediano, 0) * 100, 2) AS desvio_pct
FROM actual a
JOIN budget b ON b.categoria = a.categoria
ORDER BY desvio DESC;
