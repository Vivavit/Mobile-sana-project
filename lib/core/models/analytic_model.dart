class AnalyticsSummary {
  final int inStock;
  final int outOfStock;

  AnalyticsSummary({required this.inStock, required this.outOfStock});
}

class SalesChartData {
  final String label;
  final double value;

  SalesChartData({required this.label, required this.value});
}

class TrendingItem {
  final String name;
  final int sold;

  TrendingItem({required this.name, required this.sold});
}
