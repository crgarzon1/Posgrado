export class BoxPlotItem {
  q1: number;
  q3: number;
  whiskerMin?: number;
  whiskerMax?: number;
  outliers?: number[];
  min: number;
  median: number;
  max: number;
  items?: number[];

  constructor(
    q1: number,
    median: number,
    q3: number,
    whiskerMin: number,
    whiskerMax: number,
    min: number,
    max: number,
    outliers: number[]
  ) {
    this.q1 = q1;
    this.median = median;
    this.q3 = q3;
    this.whiskerMin = whiskerMin;
    this.whiskerMax = whiskerMax;
    this.min = min;
    this.max = max;
    this.outliers = outliers;
  }
}
