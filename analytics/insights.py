import pandas as pd
from pathlib import Path

CSV_PATH = Path(__file__).parent.parent / "database" / "transacoes.csv"
RELATORIO_PATH = Path(__file__).parent / "relatorio.txt"

df = pd.read_csv(CSV_PATH, parse_dates=["data"])

# --- KPIs gerais ---
receitas = df[df["tipo"] == "receita"]["valor"].sum()
despesas = df[df["tipo"] == "despesa"]["valor"].sum()
saldo = receitas - despesas

# --- Maior gasto individual ---
maior_gasto = df[df["tipo"] == "despesa"].nlargest(1, "valor").iloc[0]

# --- Categoria que mais cresceu (Month-over-Month) ---
df["mes"] = df["data"].dt.to_period("M")
despesas_df = df[df["tipo"] == "despesa"]

por_mes_cat = (
    despesas_df.groupby(["mes", "categoria"])["valor"]
    .sum()
    .reset_index()
    .sort_values("mes")
)

meses = sorted(por_mes_cat["mes"].unique())
if len(meses) >= 2:
    penultimo, ultimo = meses[-2], meses[-1]
    pivot = por_mes_cat[por_mes_cat["mes"].isin([penultimo, ultimo])].pivot(
        index="categoria", columns="mes", values="valor"
    ).fillna(0)
    pivot["variacao_pct"] = ((pivot[ultimo] - pivot[penultimo]) / pivot[penultimo].replace(0, 1)) * 100
    categoria_top = pivot["variacao_pct"].idxmax()
    variacao_top = pivot.loc[categoria_top, "variacao_pct"]
else:
    categoria_top = "N/A"
    variacao_top = 0

# --- Categoria com maior gasto total ---
top_categoria = despesas_df.groupby("categoria")["valor"].sum().idxmax()
top_categoria_valor = despesas_df.groupby("categoria")["valor"].sum().max()
top_categoria_pct = (top_categoria_valor / despesas) * 100 if despesas > 0 else 0

# --- Saldo médio mensal ---
saldo_mensal = (
    df.groupby(["mes", "tipo"] )["valor"]
    .sum()
    .unstack(fill_value=0)
)
saldo_mensal["saldo"] = saldo_mensal.get("receita", 0) - saldo_mensal.get("despesa", 0)
saldo_medio = saldo_mensal["saldo"].mean()

# --- Projeção de reserva em 6 meses ---
reserva_6m = saldo_medio * 6

#---Montar relatório---

linhas = [
    "=" * 50,
    "  FINANCE INSIGHTS — RELATÓRIO ANALÍTICO",
    "=" * 50,
    "",
    "[ VISÃO GERAL ]",
    f"  Receita total : R$ {receitas:,.2f}",
    f"  Despesa total : R$ {despesas:,.2f}",
    f"  Saldo         : R$ {saldo:,.2f}",
    "",
    "[ INSIGHTS ]",
    f"  Maior gasto individual           : R$ {maior_gasto['valor']:,.2f} ({maior_gasto['categoria']} em {maior_gasto['data'].strftime('%d/%m/%Y')})",
    f"  Categoria que mais cresceu (MoM) : {categoria_top} ({variacao_top:+.1f}%)",
    f"  Categoria com maior gasto total  : {top_categoria} — R$ {top_categoria_valor:,.2f} ({top_categoria_pct:.1f}% das despesas)",
    f"  Saldo médio mensal               : R$ {saldo_medio:,.2f}",
    f"  Projeção de reserva em 6 meses   : R$ {reserva_6m:,.2f}",
    "",
    "=" * 50,
]

relatorio = "\n".join(linhas)

print(relatorio)

RELATORIO_PATH.write_text(relatorio, encoding="utf-8")
print(f"\nRelatório salvo em: {RELATORIO_PATH}")