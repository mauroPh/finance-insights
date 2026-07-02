import {
    Cell, Legend, Pie, PieChart,
    ResponsiveContainer, Tooltip,
} from 'recharts'
import type { PieLabelRenderProps } from 'recharts'
import type { CategoryTotal } from '../../types'

interface CategoryPieChartProps {
    dados: CategoryTotal[]
}

// Ordem fixa por categoria — nunca gerada/ciclada, para manter a mesma cor por categoria entre renders
const CORES: Record<string, string> = {
    Moradia: '#3987e5',
    Alimentacao: '#199e70',
    Investimentos: '#c98500',
    Saude: '#008300',
    Educacao: '#9085e9',
    Lazer: '#e66767',
    Assinaturas: '#d55181',
    Transporte: '#d95926',
}

const COR_PADRAO = '#898781'

export function CategoryPieChart({ dados }: CategoryPieChartProps) {
    return (
        <ResponsiveContainer width="100%" height={288}>
            <PieChart>
                <Pie
                    data={dados}
                    dataKey="total"
                    nameKey="categoria"
                    innerRadius={70}
                    outerRadius={110}
                    paddingAngle={2}
                    label={(props: PieLabelRenderProps) => {
                        const { categoria, percentual } = props.payload as CategoryTotal
                        return `${categoria} ${percentual.toFixed(1)}%`
                    }}
                >
                    {dados.map((item) => (
                        <Cell key={item.categoria} fill={CORES[item.categoria] ?? COR_PADRAO} />
                    ))}
                </Pie>
                <Tooltip
                    formatter={(valor) => {
                        if (typeof valor !== 'number') return valor
                        return valor.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' })
                    }}
                />
                <Legend />
            </PieChart>
        </ResponsiveContainer>
    )
}
