import 'package:mobile_camsme_sana_project/core/models/analytic_model.dart';

class AnalyticsService {
  static Future<AnalyticsSummary> fetchSummary(String period) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return AnalyticsSummary(
      inStock: period == "Week" ? 100 : 420,
      outOfStock: period == "Week" ? 20 : 60,
    );
  }

  static Future<List<SalesChartData>> fetchSalesChart(String period) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (period == "Week") {
      return [
        SalesChartData(label: "Sun", value: 450),
        SalesChartData(label: "Mon", value: 300),
        SalesChartData(label: "Tue", value: 350),
        SalesChartData(label: "Wed", value: 380),
        SalesChartData(label: "Thu", value: 460),
        SalesChartData(label: "Fri", value: 200),
        SalesChartData(label: "Sat", value: 400),
      ];
    } else {
      return [
        SalesChartData(label: "W1", value: 1200),
        SalesChartData(label: "W2", value: 1800),
        SalesChartData(label: "W3", value: 1500),
        SalesChartData(label: "W4", value: 2100),
      ];
    }
  }

  static Future<List<TrendingItem>> fetchTrending(String period) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      TrendingItem(name: "Pizza", sold: 120),
      TrendingItem(name: "Burger", sold: 100),
      TrendingItem(name: "Soup", sold: 80),
      TrendingItem(name: "Coca", sold: 70),
    ];
  }
}
