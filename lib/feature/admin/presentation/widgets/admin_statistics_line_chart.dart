import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';

class AdminStatisticsLineChart extends StatelessWidget {
  final bool isDark;
  final Map<String, bool> chartVisibility;
  final List<FlSpot> usersSpots;
  final List<FlSpot> chaletsSpots;
  final List<FlSpot> bookingsSpots;
  final List<FlSpot> revenueSpots;
  final double revenueScaleFactor;
  final Function(String) onToggleLegend;

  const AdminStatisticsLineChart({
    super.key,
    required this.isDark,
    required this.chartVisibility,
    required this.usersSpots,
    required this.chaletsSpots,
    required this.bookingsSpots,
    required this.revenueSpots,
    required this.revenueScaleFactor,
    required this.onToggleLegend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        gradient: isDark
            ? const LinearGradient(colors: [Color(0xFF1F2937), Color(0xFF111827)], begin: Alignment.topLeft, end: Alignment.bottomRight)
            : const LinearGradient(colors: [Colors.white, Color(0xFFF9FAFB)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 1, offset: const Offset(0, 0)),
        ],
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.analytics_rounded, color: Colors.blueAccent, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            context.tr('admin_unified_growth'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87, fontFamily: 'Tajawal'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr('admin_growth_comparison'),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[500], fontFamily: 'Tajawal'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 350,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) => FlLine(color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.05), strokeWidth: 1),
                  getDrawingVerticalLine: (value) => FlLine(color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.05), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 5,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('${value.toInt()}', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 11, fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: null,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text(value.toInt().toString(), style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 10, fontWeight: FontWeight.bold));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  if (chartVisibility['Revenue']!) _buildLineBarData(revenueSpots, const Color(0xFFEC4899), isShadow: true),
                  if (chartVisibility['Users']!) _buildLineBarData(usersSpots, const Color(0xFF3B82F6), isShadow: true),
                  if (chartVisibility['Chalets']!) _buildLineBarData(chaletsSpots, const Color(0xFF10B981), isShadow: true),
                  if (chartVisibility['Bookings']!) _buildLineBarData(bookingsSpots, const Color(0xFFF59E0B), isShadow: true),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => isDark ? const Color(0xFF1F2937).withOpacity(0.9) : Colors.white.withOpacity(0.9),
                    tooltipPadding: const EdgeInsets.all(16),
                    tooltipBorder: BorderSide(color: Colors.grey.withOpacity(0.1)),
                    getTooltipItems: (touchedSpots) {
                      touchedSpots.sort((a, b) => b.y.compareTo(a.y));
                      return touchedSpots.map((spot) {
                        Color color = spot.bar.color ?? Colors.black;
                        String label = '';
                        String value = spot.y.toInt().toString();

                        if (color == const Color(0xFF3B82F6)) label = '👤 ${context.tr('admin_users')}';
                        else if (color == const Color(0xFF10B981)) label = '🏡 ${context.tr('admin_chalets')}';
                        else if (color == const Color(0xFFF59E0B)) label = '📅 ${context.tr('nav_bookings')}';
                        else if (color == const Color(0xFFEC4899)) {
                          label = '💰 ${context.tr('admin_revenue')}';
                          value = '${(spot.y * revenueScaleFactor).toInt()}';
                        }

                        return LineTooltipItem('$label   $value\n', TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Tajawal'), textAlign: TextAlign.right);
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),
          Center(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildLegendToggle(context, context.tr('admin_users'), const Color(0xFF3B82F6), 'Users'),
                _buildLegendToggle(context, context.tr('admin_chalets'), const Color(0xFF10B981), 'Chalets'),
                _buildLegendToggle(context, context.tr('nav_bookings'), const Color(0xFFF59E0B), 'Bookings'),
                _buildLegendToggle(context, context.tr('admin_legend_revenue_k'), const Color(0xFFEC4899), 'Revenue'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _buildLineBarData(List<FlSpot> spots, Color color, {bool isShadow = true}) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.35,
      preventCurveOverShooting: true,
      color: color,
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(
        show: isShadow,
        gradient: LinearGradient(colors: [color.withOpacity(0.2), color.withOpacity(0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
      ),
    );
  }

  Widget _buildLegendToggle(
    BuildContext context,
    String text,
    Color color,
    String key,
  ) {
    bool isActive = chartVisibility[key]!;
    return GestureDetector(
      onTap: () => onToggleLegend(key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? color : (isDark ? Colors.white10 : Colors.grey[100]),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isActive ? color : (isDark ? Colors.white24 : Colors.grey[300]!), width: 1),
          boxShadow: isActive ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive) const Icon(Icons.check_rounded, color: Colors.white, size: 16)
            else Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            if (isActive) const SizedBox(width: 6) else const SizedBox(width: 8),
            Text(text, style: TextStyle(color: isActive ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]), fontSize: 13, fontWeight: isActive ? FontWeight.bold : FontWeight.w600, fontFamily: 'Tajawal')),
          ],
        ),
      ),
    );
  }
}
