export class BarChart {
  public label: string;
  public xAxisLabel: string;
  public yAxisLabel: string;
  public barChartItems: BarChartItem[];
}

export class BarChartItem {
  public label: string;
  public key: string;
  public value: string;
}
