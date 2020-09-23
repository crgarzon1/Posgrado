import { BoxPlotItem } from './box-plot-item';

describe('BoxPlotItem', () => {
  it('should create an instance', () => {
    expect(new BoxPlotItem(0, 0, 0, 0, 0, 0, 0, [])).toBeTruthy();
  });
});
