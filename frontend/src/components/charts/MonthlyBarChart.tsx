import {
    Bar, BarChart, CartesianGrid, Legend,
    ResponsiveContainer, Tooltip, XAxis, YAxis,
} from 'recharts'
import type { MonthlyAnalytics } from '../../types'

interface MonthlyBarChartProps {
    dados: MonthlyAnalytics[]
}

export function MonthlyBarChart({ dados }: MonthlyBarChartProps) {
    return (
        <ResponsiveContainer width="100%" height={288}>
            <BarChart data={dados}>
                <CartesianGrid strokeDasharray="3 3" stroke="#1f2937" vertical={false} />
                <XAxis dataKey="mes" stroke="#9ca3af" />
                <YAxis stroke="#9ca3af" />
                <Tooltip />
                <Legend />
                <Bar dataKey="receita" name="Receita" fill="#34d399" radius={[4, 4, 0, 0]} />
                <Bar dataKey="despesa" name="Despesa" fill="#f87171" radius={[4, 4, 0, 0]} />
            </BarChart>
        </ResponsiveContainer>
    )
}