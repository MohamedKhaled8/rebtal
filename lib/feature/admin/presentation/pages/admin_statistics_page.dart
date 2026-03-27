import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/admin/presentation/cubit/admin_cubit.dart';
import 'package:rebtal/feature/admin/presentation/cubit/admin_state.dart';
import 'package:rebtal/feature/admin/presentation/widgets/admin_statistics_line_chart.dart';
import 'package:rebtal/feature/admin/presentation/widgets/admin_statistics_pie_charts.dart';

class AdminStatisticsPage extends StatefulWidget {
  const AdminStatisticsPage({super.key});

  @override
  State<AdminStatisticsPage> createState() => _AdminStatisticsPageState();
}

class _AdminStatisticsPageState extends State<AdminStatisticsPage> {
  Map<String, bool> _chartVisibility = {
    'Users': true,
    'Chalets': true,
    'Bookings': true,
    'Revenue': true,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        if (state is AdminLoading || state is AdminInitial) {
          return Center(child: CircularProgressIndicator(color: ColorsManager.chaletAccent));
        }

        if (state is AdminDataLoaded) {
          return _buildContent(context, state, isDark);
        }

        return const Center(child: Text('حدث خطأ'));
      },
    );
  }

  Widget _buildContent(BuildContext context, AdminDataLoaded state, bool isDark) {
    // Users Data
    int totalUsers = state.users.length + state.owners.length + state.admins.length;
    Map<int, int> usersByDay = {};
    for (var doc in [...state.users, ...state.owners, ...state.admins]) {
      final timestamp = doc.data()['createdAt'] as Timestamp? ?? Timestamp.now();
      final day = timestamp.toDate().day;
      usersByDay[day] = (usersByDay[day] ?? 0) + 1;
    }

    // Chalets Data
    int activeChalets = 0, pendingChalets = 0;
    Map<int, int> chaletsByDay = {};
    for (var doc in state.chalets) {
      final data = doc.data();
      if (data['status'] == 'approved') activeChalets++;
      else pendingChalets++;

      final timestamp = data['createdAt'] as Timestamp? ?? Timestamp.now();
      final day = timestamp.toDate().day;
      chaletsByDay[day] = (chaletsByDay[day] ?? 0) + 1;
    }
    int totalChalets = state.chalets.length;
    Map<String, int> chaletStatusDist = {'Active': activeChalets, 'Pending': pendingChalets};

    // Bookings Data
    int totalBookings = state.bookings.length;
    double revenue = 0;
    Map<String, int> bookingStatusDist = {'Completed': 0, 'Accepted': 0, 'Pending': 0, 'Cancelled': 0};
    Map<int, int> bookingsByDay = {};
    Map<int, double> revenueByDay = {};

    for (var doc in state.bookings) {
      final data = doc.data();
      final status = data['status'] ?? 'pending';
      final double price = (data['totalPrice'] ?? data['price'] ?? 0).toDouble();

      if (status == 'completed') bookingStatusDist['Completed'] = (bookingStatusDist['Completed'] ?? 0) + 1;
      else if (status == 'accepted' || status == 'confirmed') bookingStatusDist['Accepted'] = (bookingStatusDist['Accepted'] ?? 0) + 1;
      else if (status == 'cancelled' || status == 'refused') bookingStatusDist['Cancelled'] = (bookingStatusDist['Cancelled'] ?? 0) + 1;
      else bookingStatusDist['Pending'] = (bookingStatusDist['Pending'] ?? 0) + 1;

      if (status == 'completed' || status == 'accepted' || status == 'confirmed') {
        revenue += price;
      }

      final timestamp = data['createdAt'] as Timestamp? ?? Timestamp.now();
      final day = timestamp.toDate().day;
      bookingsByDay[day] = (bookingsByDay[day] ?? 0) + 1;

      if (status == 'completed' || status == 'accepted' || status == 'confirmed') {
        revenueByDay[day] = (revenueByDay[day] ?? 0) + price;
      }
    }

    double revenueScaleFactor = 1000.0;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('التحليلات الشاملة', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87, fontFamily: 'Tajawal')),
                    const Text('نظرة عامة على أداء التطبيق', style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600, fontFamily: 'Tajawal')),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    context.read<AdminCubit>().startListeningToAll(); // Refresh
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: ColorsManager.chaletAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: ColorsManager.chaletAccent.withOpacity(0.5))),
                    child: const Row(
                      children: [
                        Icon(Icons.refresh, color: ColorsManager.chaletAccent, size: 16),
                        SizedBox(width: 6),
                        Text('تحديث', style: TextStyle(color: ColorsManager.chaletAccent, fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : (MediaQuery.of(context).size.width > 800 ? 2 : 1),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              childAspectRatio: 1.5,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatCard(context, title: 'المستخدمين', value: totalUsers.toString(), icon: Icons.people_alt_rounded, color: const Color(0xFF3B82F6), isDark: isDark, isSelected: _chartVisibility['Users']!, onTap: () => setState(() => _chartVisibility['Users'] = !_chartVisibility['Users']!)),
                _buildStatCard(context, title: 'الشاليهات', value: totalChalets.toString(), icon: Icons.holiday_village_rounded, color: const Color(0xFF10B981), isDark: isDark, isSelected: _chartVisibility['Chalets']!, onTap: () => setState(() => _chartVisibility['Chalets'] = !_chartVisibility['Chalets']!)),
                _buildStatCard(context, title: 'الحجوزات', value: totalBookings.toString(), icon: Icons.book_online_rounded, color: const Color(0xFFF59E0B), isDark: isDark, isSelected: _chartVisibility['Bookings']!, onTap: () => setState(() => _chartVisibility['Bookings'] = !_chartVisibility['Bookings']!)),
                _buildStatCard(context, title: 'الإيرادات', value: '${(revenue / 1000).toStringAsFixed(1)}k EGP', icon: Icons.monetization_on_rounded, color: const Color(0xFFEC4899), isDark: isDark, isSelected: _chartVisibility['Revenue']!, onTap: () => setState(() => _chartVisibility['Revenue'] = !_chartVisibility['Revenue']!)),
              ],
            ),
            const SizedBox(height: 32),
            AdminStatisticsLineChart(
              isDark: isDark,
              chartVisibility: _chartVisibility,
              usersSpots: _generateSpots(usersByDay),
              chaletsSpots: _generateSpots(chaletsByDay),
              bookingsSpots: _generateSpots(bookingsByDay),
              revenueSpots: _generateSpots(revenueByDay.map((k, v) => MapEntry(k, (v / revenueScaleFactor).toInt()))),
              revenueScaleFactor: revenueScaleFactor,
              onToggleLegend: (key) => setState(() => _chartVisibility[key] = !_chartVisibility[key]!),
            ),
            const SizedBox(height: 32),
            AdminStatisticsPieCharts(
              isDark: isDark,
              chaletStatusDistribution: chaletStatusDist,
              bookingStatusDistribution: bookingStatusDist,
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateSpots(Map<int, int> dataMap) {
    if (dataMap.isEmpty) return List.generate(31, (i) => FlSpot((i + 1).toDouble(), 0));
    List<FlSpot> spots = [];
    for (int i = 1; i <= 31; i++) {
      spots.add(FlSpot(i.toDouble(), (dataMap[i] ?? 0).toDouble()));
    }
    return spots;
  }

  Widget _buildStatCard(BuildContext context, {required String title, required String value, required IconData icon, required Color color, required bool isDark, VoidCallback? onTap, bool isSelected = false}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: isSelected ? Border.all(color: color, width: 2) : Border.all(color: Colors.transparent, width: 2),
          boxShadow: [BoxShadow(color: isSelected ? color.withOpacity(0.2) : Colors.black.withOpacity(0.05), blurRadius: isSelected ? 20 : 15, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color, size: 24)),
                if (isSelected) Icon(Icons.check_circle_rounded, color: color, size: 20),
              ],
            ),
            const Spacer(),
            FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87, fontFamily: 'Tajawal'))),
            const SizedBox(height: 4),
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[500], fontWeight: FontWeight.w600, fontFamily: 'Tajawal')),
          ],
        ),
      ),
    );
  }
}
