import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';

class AdminStatisticsPieCharts extends StatelessWidget {
  final bool isDark;
  final Map<String, int> chaletStatusDistribution;
  final Map<String, int> bookingStatusDistribution;

  const AdminStatisticsPieCharts({
    super.key,
    required this.isDark,
    required this.chaletStatusDistribution,
    required this.bookingStatusDistribution,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return Row(
            children: [
              Expanded(child: _buildChaletStatusChart(context)),
              const SizedBox(width: 24),
              Expanded(child: _buildBookingStatusChart(context)),
            ],
          );
        } else {
          return Column(
            children: [
              _buildChaletStatusChart(context),
              const SizedBox(height: 24),
              _buildBookingStatusChart(context),
            ],
          );
        }
      },
    );
  }

  Widget _buildChaletStatusChart(BuildContext context) {
    int total = (chaletStatusDistribution['Active'] ?? 0) + (chaletStatusDistribution['Pending'] ?? 0);
    return _buildPieChartCard(
      context,
      title: context.tr('admin_chalet_status'),
      centerText: '${context.tr('admin_pie_center_total')}\n$total',
      sections: [
        PieChartSectionData(color: const Color(0xFF10B981), value: (chaletStatusDistribution['Active'] ?? 0).toDouble(), title: '${_getPercentage(chaletStatusDistribution['Active'] ?? 0, total)}%', radius: 25, titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
        PieChartSectionData(color: const Color(0xFFEF4444), value: (chaletStatusDistribution['Pending'] ?? 0).toDouble(), title: '${_getPercentage(chaletStatusDistribution['Pending'] ?? 0, total)}%', radius: 25, titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
      ],
      legendItems: [
        _buildLegendItem(const Color(0xFF10B981), context.tr('admin_chalet_active'), '${chaletStatusDistribution['Active'] ?? 0}'),
        _buildLegendItem(const Color(0xFFEF4444), context.tr('admin_pending_review'), '${chaletStatusDistribution['Pending'] ?? 0}'),
      ],
    );
  }

  Widget _buildBookingStatusChart(BuildContext context) {
    int total = bookingStatusDistribution.values.fold(0, (a, b) => a + b);
    return _buildPieChartCard(
      context,
      title: context.tr('admin_booking_distribution'),
      centerText: '${context.tr('admin_pie_center_bookings')}\n$total',
      sections: [
        PieChartSectionData(color: const Color(0xFF10B981), value: (bookingStatusDistribution['Completed'] ?? 0).toDouble(), radius: 30, title: ''),
        PieChartSectionData(color: const Color(0xFF3B82F6), value: (bookingStatusDistribution['Accepted'] ?? 0).toDouble(), radius: 25, title: ''),
        PieChartSectionData(color: const Color(0xFFF59E0B), value: (bookingStatusDistribution['Pending'] ?? 0).toDouble(), radius: 25, title: ''),
        PieChartSectionData(color: const Color(0xFFEF4444), value: (bookingStatusDistribution['Cancelled'] ?? 0).toDouble(), radius: 25, title: ''),
      ],
      legendItems: [
        _buildLegendItem(const Color(0xFF10B981), context.tr('booking_status_completed'), '${bookingStatusDistribution['Completed'] ?? 0}'),
        _buildLegendItem(const Color(0xFF3B82F6), context.tr('booking_status_accepted'), '${bookingStatusDistribution['Accepted'] ?? 0}'),
        _buildLegendItem(const Color(0xFFF59E0B), context.tr('booking_status_pending'), '${bookingStatusDistribution['Pending'] ?? 0}'),
        _buildLegendItem(const Color(0xFFEF4444), context.tr('booking_status_cancelled'), '${bookingStatusDistribution['Cancelled'] ?? 0}'),
      ],
    );
  }

  String _getPercentage(int value, int total) {
    if (total == 0) return '0';
    return ((value / total) * 100).toStringAsFixed(0);
  }

  Widget _buildPieChartCard(
    BuildContext context, {
    required String title,
    required List<PieChartSectionData> sections,
    required List<Widget> legendItems,
    required String centerText,
  }) {
    bool isEmpty = sections.every((s) => s.value == 0);
    List<PieChartSectionData> finalSections = isEmpty ? [PieChartSectionData(value: 1, color: isDark ? Colors.white10 : Colors.grey[200]!, title: '', radius: 25)] : sections;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87, fontFamily: 'Tajawal')),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(PieChartData(sections: finalSections, centerSpaceRadius: 60, sectionsSpace: 4, startDegreeOffset: -90)),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(isEmpty ? '0' : centerText.split('\n').last, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black87, height: 1)),
                          Text(
                            isEmpty ? context.tr('admin_none') : centerText.split('\n').first,
                            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[500], height: 1.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: legendItems)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.2), width: 2))),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w500, fontFamily: 'Tajawal'))),
          Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Tajawal')),
        ],
      ),
    );
  }
}
