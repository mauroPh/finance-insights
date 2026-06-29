interface KpiCardProps {
    titulo: string;
    valor: number;
    cor?: 'verde' | 'vermelho' | 'azul';
}

const bordas = {
    verde: 'border-emerald-500',
    vermelho: 'border-red-500',
    azul: 'border-blue-500'
}

const textos = {
    verde: 'text-emerald-400',
    vermelho: 'text-red-400',
    azul: 'text-blue-400'
}

export function KpiCard({ titulo, valor, cor = 'azul' }: KpiCardProps) {
    const formatado = valor.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' })

    return (
        <div className={`bg-gray-900 rounded-xl p-6 border-2 ${bordas[cor]} flex flex-col gap-2`}>
            <span className="text-sm text-gray-400 uppercase tracking-wide">{titulo}</span>
            <span className={`text-3xl font-bold ${textos[cor]}`}>{formatado}</span>
        </div>
    )
}