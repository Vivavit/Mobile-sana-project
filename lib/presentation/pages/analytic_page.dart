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
  String selectedPeriod = 'week';
  bool isLoading = true;
  String? error;

  Map<String, dynamic> summary = {
    'total_items': 0,
    'low_stock': 0,
    'out_of_stock': 0,
    'total_value': 0,
  };
  List<Map<String, dynamic>> stockMovements = [];
  List<Map<String, dynamic>> alerts = [];
  List<Map<String, dynamic>> topCategories = [];
  List<Map<String, dynamic>> topProducts = [];

  final List<String> _periods = ['week', 'month', 'quarter', 'custom'];
  final Map<String, String> _periodLabels = {
    'week': 'Week',
    'month': 'Month',
    'quarter': 'Quarter',
    'custom': 'Custom',
  };

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics({bool isRefresh = false}) async {
    if (!isRefresh) setState(() { isLoading = true; error = null; });

    try {
      final results = await Future.wait([
        ApiService.fetchAnalyticsSummary(selectedPeriod),
        ApiService.fetchSalesChart(selectedPeriod),
        ApiService.fetchTrendingProducts(selectedPeriod),
      ]);

      final summaryData = results[0] as Map<String, dynamic>;
      final chartList = results[1] as List<Map<String, dynamic>>;
      final trendingList = results[2] as List<Map<String, dynamic>>;

      setState(() {
        summary = {
          'total_items': (summaryData['in_stock'] ?? 0) + (summaryData['out_of_stock'] ?? 0),
          'low_stock': summaryData['low_stock'] ?? 0,
          'out_of_stock': summaryData['out_of_stock'] ?? 0,
          'total_value': summaryData['revenue'] ?? 0,
        };
        stockMovements = chartList;
        topProducts = trendingList;
        // Mock alerts — replace with real API
        alerts = [
          {'name': 'Mechanical Keyboard MX', 'stock': 3, 'severity': 'low'},
          {'name': 'USB-C Hub Pro', 'stock': 1, 'severity': 'critical'},
        ];
        // Mock categories — replace with real API
        topCategories = [
          {'name': 'Electronics', 'percent': 78},
          {'name': 'Accessories', 'percent': 54},
          {'name': 'Peripherals', 'percent': 38},
          {'name': 'Storage', 'percent': 22},
        ];
        isLoading = false;
      });
      widget.onLoadingComplete?.call();
    } catch (e) {
      setState(() { isLoading = false; error = e.toString(); });
      widget.onLoadingComplete?.call();
    }
  }

  Future<void> _pickCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => selectedPeriod = 'custom');
      _loadAnalytics();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF4F6F4),
      body: RefreshIndicator(
        onRefresh: () => _loadAnalytics(isRefresh: true),
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildHeader(),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (isLoading)
                    _buildLoading()
                  else if (error != null)
                    _buildError()
                  else ...[
                    _buildPeriodFilter(),
                    const SizedBox(height: 16),
                    _buildStatCards(),
                    const SizedBox(height: 16),
                    _buildStockMovementChart(),
                    const SizedBox(height: 16),
                    if (alerts.isNotEmpty) ...[
                      _buildAlerts(),
                      const SizedBox(height: 16),
                    ],
                    _buildTopCategories(),
                    const SizedBox(height: 16),
                    _buildTopProducts(),
                    const SizedBox(height: 100),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Analytics',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              Text('Last updated just now',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ],
          ),
        ),
        // Calendar button
        _IconBtn(
          icon: Icons.calendar_today_outlined,
          onTap: _pickCustomDateRange,
        ),
        const SizedBox(width: 8),
        // Filter button
        _IconBtn(
          icon: Icons.tune_rounded,
          filled: true,
          onTap: _showFilterSheet,
        ),
      ],
    );
  }

  Widget _buildPeriodFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _periods.map((p) {
          final isActive = selectedPeriod == p;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                if (p == 'custom') {
                  _pickCustomDateRange();
                } else {
                  setState(() => selectedPeriod = p);
                  _loadAnalytics();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: isActive ? AppColors.primary : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  _periodLabels[p]!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isActive ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatCards() {
    final cards = [
      _StatData('Total Items', '${summary['total_items']}', '+12 this week',
          Icons.inventory_2_outlined, AppColors.primary, const Color(0xFFE8F5EE)),
      _StatData('Low Stock', '${summary['low_stock']}', 'Needs reorder',
          Icons.warning_amber_outlined, Colors.orange, const Color(0xFFFEF3C7)),
      _StatData('Out of Stock', '${summary['out_of_stock']}', 'Action needed',
          Icons.remove_circle_outline, Colors.red, const Color(0xFFFEE2E2)),
      _StatData('Total Value', '\$${summary['total_value']}', 'Inventory worth',
          Icons.attach_money, Colors.purple, const Color(0xFFEDE9FE)),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: cards.map((d) => _StatCard(data: d)).toList(),
    );
  }

  Widget _buildStockMovementChart() {
    final maxY = stockMovements.isEmpty
        ? 100.0
        : stockMovements
                .map((e) => ((e['value'] ?? 0) as num).toDouble())
                .fold(0.0, (a, b) => b > a ? b : a) *
            1.3;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Stock movements',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              Row(children: [
                _Legend(color: AppColors.primary, label: 'In'),
                const SizedBox(width: 12),
                _Legend(color: Colors.red, label: 'Out'),
              ]),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: stockMovements.isEmpty
                ? Center(
                    child: Text('No data available',
                        style: TextStyle(color: Colors.grey[500])))
                : BarChart(BarChartData(
                    maxY: maxY,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (v) =>
                          FlLine(color: Colors.grey[200]!, strokeWidth: 1),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i < 0 || i >= stockMovements.length) {
                              return const SizedBox();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                stockMovements[i]['label'] ?? '',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.grey[500]),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(stockMovements.length, (i) {
                      final val = ((stockMovements[i]['value'] ?? 0) as num)
                          .toDouble();
                      return BarChartGroupData(x: i, barRods: [
                        BarChartRodData(
                          toY: val,
                          width: 14,
                          color: AppColors.primary,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxY,
                            color: AppColors.primary.withOpacity(0.06),
                          ),
                        ),
                      ]);
                    }),
                  )),
          ),
        ],
      ),
    );
  }

  Widget _buildAlerts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Alerts',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        ...alerts.map((a) {
          final isCritical = a['severity'] == 'critical';
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(
                  color: isCritical ? Colors.red : Colors.orange,
                  width: 3,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    size: 18,
                    color: isCritical ? Colors.red : Colors.orange),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a['name'],
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500)),
                      Text('Only ${a['stock']} unit(s) left',
                          style: TextStyle(
                              fontSize: 11, color: Colors.orange[700])),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isCritical
                        ? Colors.red[50]
                        : Colors.orange[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isCritical ? 'Critical' : 'Low',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color:
                            isCritical ? Colors.red[700] : Colors.orange[700]),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTopCategories() {
    final colors = [
      AppColors.primary,
      Colors.purple,
      Colors.orange,
      Colors.red,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top categories',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          ...topCategories.asMap().entries.map((entry) {
            final i = entry.key;
            final cat = entry.value;
            final color = colors[i % colors.length];
            final pct = (cat['percent'] as num).toDouble();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 90,
                    child: Text(cat['name'],
                        style: const TextStyle(fontSize: 13)),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct / 100,
                        backgroundColor: Colors.grey[200],
                        color: color,
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 36,
                    child: Text('${pct.toInt()}%',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: color)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTopProducts() {
    final rankColors = [AppColors.primary, Colors.purple, Colors.orange];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Top moving products',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        ...topProducts.asMap().entries.take(5).map((entry) {
          final i = entry.key;
          final p = entry.value;
          final color = rankColors[i % rankColors.length];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: _cardDecoration(),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text('${i + 1}',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: color)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['name'] ?? 'Unknown',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500)),
                      Text('${p['sold'] ?? 0} units sold',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey[500])),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('+${p['growth'] ?? 0}%',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLoading() {
    return const SizedBox(
      height: 300,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildError() {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 12),
            Text('Failed to load', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadAnalytics,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Filter',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            const Text('Stock status',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: ['All', 'In Stock', 'Low Stock', 'Out of Stock']
                  .map((s) => FilterChip(
                        label: Text(s),
                        selected: s == 'All',
                        onSelected: (_) {},
                        selectedColor: AppColors.primary.withOpacity(0.15),
                        checkmarkColor: AppColors.primary,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            const Text('Category',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: ['All', 'Electronics', 'Accessories', 'Peripherals']
                  .map((s) => FilterChip(
                        label: Text(s),
                        selected: s == 'All',
                        onSelected: (_) {},
                        selectedColor: AppColors.primary.withOpacity(0.15),
                        checkmarkColor: AppColors.primary,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Apply filters',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      );
}

// ── Helper widgets ──────────────────────────────────────────

class _StatData {
  final String label, value, sub;
  final IconData icon;
  final Color color, bgColor;
  const _StatData(this.label, this.value, this.sub, this.icon, this.color, this.bgColor);
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
                color: data.bgColor,
                borderRadius: BorderRadius.circular(8)),
            child: Icon(data.icon, color: data.color, size: 16),
          ),
          const Spacer(),
          Text(data.label,
              style:
                  TextStyle(fontSize: 11, color: Colors.grey[500])),
          const SizedBox(height: 2),
          Text(data.value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: data.color)),
          const SizedBox(height: 2),
          Text(data.sub,
              style: TextStyle(
                  fontSize: 11,
                  color: data.color == Colors.red ||
                          data.color == Colors.orange
                      ? data.color
                      : Colors.grey[500])),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  const _IconBtn({required this.icon, required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: filled
              ? null
              : Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon,
            size: 18, color: filled ? Colors.white : Colors.grey[700]),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
          width: 8,
          height: 8,
          decoration:
              BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
    ]);
  }
}