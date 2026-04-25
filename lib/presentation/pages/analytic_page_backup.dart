import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile_camsme_sana_project/core/constants/app_color.dart';
import 'package:mobile_camsme_sana_project/core/services/api_service.dart';
import 'package:mobile_camsme_sana_project/core/services/session.dart';

class AnalyticPage extends StatefulWidget {
  final VoidCallback? onLoadingComplete;

  const AnalyticPage({super.key, this.onLoadingComplete});

  @override
  State<AnalyticPage> createState() => _AnalyticPageState();
}

class _AnalyticPageState extends State<AnalyticPage> {
  String selectedPeriod = "week";
  Map<String, dynamic> summary = {
    'in_stock': 0,
    'out_of_stock': 0,
    'low_stock': 0,
  };
  Map<String, dynamic> metrics = {};
  List<Map<String, dynamic>> chartData = [];
  List<Map<String, dynamic>> trending = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    if (Session.token == null) {
      debugPrint('No session token available');
      setState(() => isLoading = false);
      widget.onLoadingComplete?.call();
      return;
    }
    setState(() => isLoading = true);

    try {
      debugPrint('Fetching analytics for period: $selectedPeriod');
      debugPrint('Session.warehouseId: ${Session.warehouseId}');

      // Fetch all data in parallel for better performance
      final results = await Future.wait([
        ApiService.fetchAnalyticsSummary(selectedPeriod),
        ApiService.fetchSalesChart(selectedPeriod),
        ApiService.fetchTrendingProducts(selectedPeriod),
      ]);

      final summaryData = results[0] as Map<String, dynamic>;
      final chartDataList = results[1] as List<Map<String, dynamic>>;
      final trendingList = results[2] as List<Map<String, dynamic>>;

      debugPrint('Summary data received: $summaryData');
      debugPrint('Chart data received: ${chartDataList.length} items');
      debugPrint('Trending data received: ${trendingList.length} items');

      setState(() {
        summary = summaryData;
        chartData = chartDataList;
        trending = trendingList;
        isLoading = false;
      });
      widget.onLoadingComplete?.call();
    } catch (e) {
      debugPrint('Analytics error: $e');
      setState(() => isLoading = false);
      widget.onLoadingComplete?.call();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load analytics: $e')));
      }
    }
  }

  double get _maxChartValue {
    if (chartData.isEmpty) return 10.0;
    final maxVal = chartData
        .map((e) {
          final value = e['value'];
          if (value is String) {
            return double.tryParse(value) ?? 0.0;
          } else {
            return (value ?? 0).toDouble();
          }
        })
        .fold(0.0, (prev, element) => element > prev ? element : prev);
    return maxVal == 0 ? 10.0 : maxVal * 1.3;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F0),
      body: RefreshIndicator(
        onRefresh: _loadAnalytics,
        color: AppColors.primary,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else ...[
                _stockSummaryCard(),
                const SizedBox(height: 25),
                _acceptPurchaseChart(),
                const SizedBox(height: 25),
                _trendingItems(),
                const SizedBox(height: 30),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _stockSummaryCard() {
    final int inStock = summary['in_stock'] ?? 0;
    final int outStock = summary['out_of_stock'] ?? 0;
    final int total = inStock + outStock;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 130,
              child: Stack(
                children: [
                  _stockPieChart(),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "$total",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "Total",
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _indicator(AppColors.primary, "In Stock", "$inStock"),
                const SizedBox(height: 12),
                _indicator(Colors.redAccent, "Out of Stock", "$outStock"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _acceptPurchaseChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Sales Activity",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              _dropdown(),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 220,
            child: chartData.isEmpty
                ? const Center(child: Text("No data found"))
                : BarChart(
                    BarChartData(
                      maxY: _maxChartValue,
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              int index = value.toInt();
                              if (index < 0 || index >= chartData.length) {
                                return const SizedBox();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  chartData[index]['label'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: List.generate(chartData.length, (index) {
                        final value = chartData[index]['value'];
                        double yValue;
                        if (value is String) {
                          yValue = double.tryParse(value) ?? 0.0;
                        } else {
                          yValue = (value ?? 0).toDouble();
                        }
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: yValue,
                              width: 16,
                              color: AppColors.primary,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: _maxChartValue,
                                color: AppColors.primary.withValues(
                                  alpha: 0.05,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _stockPieChart() {
    double inS = (summary['in_stock'] ?? 0).toDouble();
    double outS = (summary['out_of_stock'] ?? 0).toDouble();

    return PieChart(
      PieChartData(
        centerSpaceRadius: 42,
        sectionsSpace: 4,
        sections: [
          PieChartSectionData(
            value: inS == 0 && outS == 0 ? 1 : inS,
            color: inS == 0 && outS == 0
                ? Colors.grey.shade200
                : AppColors.primary,
            radius: 14,
            showTitle: false,
          ),
          if (outS > 0)
            PieChartSectionData(
              value: outS,
              color: Colors.redAccent.withValues(alpha: 0.4),
              radius: 14,
              showTitle: false,
            ),
        ],
      ),
    );
  }

  Widget _trendingItems() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Trending Items",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          if (trending.isEmpty)
            const Center(child: Text("No items recorded yet"))
          else
            ...trending.asMap().entries.map((e) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildTrendingRow(
                  e.key + 1,
                  e.value['name'] ?? 'Unknown',
                  "${e.value['sold'] ?? 0} sold",
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildTrendingRow(int index, String name, String sold) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              "$index",
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Text(
            sold,
            style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.primary, width: 2),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _indicator(Color color, String label, String value) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _dropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedPeriod,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
          items: const [
            DropdownMenuItem(value: "week", child: Text("Weekly")),
            DropdownMenuItem(value: "month", child: Text("Monthly")),
          ],
          onChanged: (v) {
            if (v == null) return;
            setState(() => selectedPeriod = v);
            _loadAnalytics();
          },
        ),
      ),
    );
  }
}
