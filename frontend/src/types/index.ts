export interface Transaction {
    data: string;
    categoria: string;
    tipo: 'receita' | 'despesa'
    valor: number;
}

export interface MonthlyAnalytics {
    mes: string;
    receita: number;
    despesa: number;
    saldo: number;
}

export interface CategoryTotal {
    categoria: string;
    total: number;
    percentual: number;
}