import { Header } from './components/layout/Header'
import { KpiCard } from './components/metrics/KpiCard'
import { monthlyAnalytics, categoryTotals } from './data/mockData'
import { MonthlyBarChart } from './components/charts/MonthlyBarChart'
import { CategoryPieChart } from './components/charts/CategoryPieChart'

const totalReceita = monthlyAnalytics.reduce((acc, m) => acc + m.receita, 0)
const totalDespesa = monthlyAnalytics.reduce((acc, m) => acc + m.despesa, 0)
const totalSaldo = totalReceita - totalDespesa

export default function App() {
  return (
    <div className="min-h-screen bg-gray-950 text-gray-100">
      <Header />
      <main className="max-w-7xl mx-auto p-6 flex flex-col gap-6">

        {/* KPIs */}
        <section className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <KpiCard titulo="Receita Total" valor={totalReceita} cor="verde" />
          <KpiCard titulo="Despesa Total" valor={totalDespesa} cor="vermelho" />
          <KpiCard titulo="Saldo" valor={totalSaldo} cor="azul" />
        </section>
        <section className="bg-gray-900 rounded-xl p-6 border border-gray-800">
          <h2 className="text-lg font-semibold mb-4">Receita x Despesa</h2>
          <MonthlyBarChart dados={monthlyAnalytics} />
        </section>
        <section className="bg-gray-900 rounded-xl p-6 border border-gray-800">
          <h2 className="text-lg font-semibold mb-4">Despesas por Categoria</h2>
          <CategoryPieChart dados={categoryTotals} />
        </section>
      </main>
    </div>
  )
}
