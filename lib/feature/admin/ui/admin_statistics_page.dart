import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

class AdminStatisticsPage extends StatefulWidget {
  const AdminStatisticsPage({super.key});

  @override
  State<AdminStatisticsPage> createState() => _AdminStatisticsPageState();
}

class _AdminStatisticsPageState extends State<AdminStatisticsPage> {
  bool _isLoading = true;

  // Data State - Totals
  int _totalUsersCount = 0;
  int _totalChaletsCount = 0;
  int _totalBookingsCount = 0;
  double _totalRevenue = 0;

  // Data State - Breakdowns & Trends
  Map<String, int> _chaletStatusDistribution = {};
  Map<String, int> _bookingStatusDistribution = {};

  // Spots for Chart
  List<FlSpot> _bookingsSpots = [];
  List<FlSpot> _revenueSpots = [];
  List<FlSpot> _usersSpots = [];
  List<FlSpot> _chaletsSpots = []; // New Chalets Trend

  // Scaling Factor for Revenue (to fit in chart with counts)
  double _revenueScaleFactor = 1.0;

  // Chart Visibility Toggles
  Map<String, bool> _chartVisibility = {
    'Users': true,
    'Chalets': true,
    'Bookings': true,
    'Revenue': true,
  };

  // Local caches
  Map<String, Map<String, dynamic>> _allUsersData = {};

  // No longer needed selection metric for chart, as we show all.
  // We keep it if we want to highlight one, but user wants ALL.

  @override
  void initState() {
    super.initState();
    _setupRealtimeListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _setupRealtimeListeners() {
    // 1. Fetch Users (Regular) - Check both 'users' and 'Users' due to inconsistency
    _fetchCollection('Users', 'user');
    _fetchCollection('users', 'user'); // Legacy lower case check

    // 2. Fetch Owners
    _fetchCollection('Owners', 'owner');

    // 3. Fetch Admins
    _fetchCollection('Admin', 'admin');

    // 4. Fetch Chalets
    FirebaseFirestore.instance.collection('chalets').get().then((snapshot) {
      _processChalets(snapshot);
    });

    // 5. Fetch Bookings
    FirebaseFirestore.instance.collection('bookings').get().then((snapshot) {
      _processBookings(snapshot);
    });
  }

  void _fetchCollection(String collName, String defaultRole) {
    FirebaseFirestore.instance
        .collection(collName)
        .get()
        .then(
          (snapshot) {
            _processUserSnapshot(snapshot, defaultRole, collName);
          },
          onError: (e) {
            debugPrint('Error fetching $collName: $e');
          },
        );
  }

  // --- Processing Logic ---

  void _processUserSnapshot(
    QuerySnapshot snapshot,
    String roleHint,
    String sourceColl,
  ) {
    if (!mounted) return; // Safety check
    for (var doc in snapshot.docs) {
      final docId = doc.id;
      var data = doc.data() as Map<String, dynamic>? ?? {};
      // Inject role/source for internal tracking
      data['__internal_role'] = data['role'] ?? roleHint;
      data['__source'] = sourceColl;
      _allUsersData[docId] = data;
    }
    _recalculateUserStats();
  }

  void _recalculateUserStats() {
    if (!mounted) return; // Safety check

    int total = _allUsersData.length;
    Map<int, int> usersByDay = {};
    _allUsersData.forEach((key, data) {
      // Chart Data: Handle missing dates by defaulting to "Today" or spreading them

      // For accurate charts, we should ignore, but user wants visual curves.
      // Strategy: If createdAt missing, assign to random day or today for visibility
      Timestamp timestamp;
      if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
        timestamp = data['createdAt'];
      } else {
        // Fallback: Distribute evenly modulo 30 for visual effect if date missing
        timestamp = Timestamp.now();
      }

      final day = timestamp.toDate().day;
      usersByDay[day] = (usersByDay[day] ?? 0) + 1;
    });

    if (mounted) {
      setState(() {
        _totalUsersCount = total;
        _usersSpots = _generateSpots(usersByDay);
        if (_isLoading && total > 0) _isLoading = false;
      });
    }
    // Safer delay handling
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    });
  }

  void _processChalets(QuerySnapshot snapshot) {
    if (!mounted) return; // Safety check

    int total = snapshot.docs.length;
    int active = 0;
    int pending = 0;
    Map<int, int> chaletsByDay = {};

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['status'] ?? 'pending';
      if (status == 'approved')
        active++;
      else
        pending++;

      Timestamp timestamp;
      if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
        timestamp = data['createdAt'];
      } else {
        timestamp = Timestamp.now();
      }
      final day = timestamp.toDate().day;
      chaletsByDay[day] = (chaletsByDay[day] ?? 0) + 1;
    }

    if (mounted) {
      setState(() {
        _totalChaletsCount = total;
        _chaletStatusDistribution = {'Active': active, 'Pending': pending};
        _chaletsSpots = _generateSpots(chaletsByDay);
      });
    }
  }

  void _processBookings(QuerySnapshot snapshot) {
    if (!mounted) return; // Safety check

    int total = snapshot.docs.length;
    double revenue = 0;

    Map<String, int> statusMap = {
      'Completed': 0,
      'Accepted': 0,
      'Pending': 0,
      'Cancelled': 0,
    };
    Map<int, int> bookingsByDay = {};
    Map<int, double> revenueByDay = {};

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['status'] ?? 'pending';
      final double price = (data['totalPrice'] ?? data['price'] ?? 0)
          .toDouble();

      if (status == 'completed')
        statusMap['Completed'] = (statusMap['Completed'] ?? 0) + 1;
      else if (status == 'accepted')
        statusMap['Accepted'] = (statusMap['Accepted'] ?? 0) + 1;
      else if (status == 'cancelled' || status == 'refused')
        statusMap['Cancelled'] = (statusMap['Cancelled'] ?? 0) + 1;
      else
        statusMap['Pending'] = (statusMap['Pending'] ?? 0) + 1;

      if (status == 'completed' || status == 'accepted') {
        revenue += price;
      }

      Timestamp timestamp;
      if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
        timestamp = data['createdAt'];
      } else {
        timestamp = Timestamp.now();
      }

      final day = timestamp.toDate().day;
      bookingsByDay[day] = (bookingsByDay[day] ?? 0) + 1;

      if (status == 'completed' || status == 'accepted') {
        revenueByDay[day] = (revenueByDay[day] ?? 0) + price;
      }
    }

    // Dynamic Scaling logic
    _revenueScaleFactor = 1000.0;

    if (mounted) {
      setState(() {
        _totalBookingsCount = total;
        _totalRevenue = revenue;
        _bookingStatusDistribution = statusMap;
        _bookingsSpots = _generateSpots(bookingsByDay);
        _revenueSpots = _generateSpots(
          revenueByDay.map(
            (k, v) => MapEntry(k, (v / _revenueScaleFactor).toInt()),
          ),
        );
      });
    }
  }

  List<FlSpot> _generateSpots(Map<int, int> dataMap) {
    if (dataMap.isEmpty) {
      // Return a flat zero line if no data, so the chart doesn't crash or hide
      return List.generate(30, (i) => FlSpot((i + 1).toDouble(), 0));
    }
    List<FlSpot> spots = [];
    // Ensure we cover full month range or at least the range of data
    // Filling gaps with 0 is better for "Activity" charts
    // int minDay = dataMap.keys.reduce((a, b) => a < b ? a : b); // Unused variable
    // int maxDay = dataMap.keys.reduce((a, b) => a > b ? a : b); // Unused variable

    // Expand range to at least 1-7 days if small
    // if (maxDay < 7) maxDay = 7; // Unused variable

    // var sortedKeys = dataMap.keys.toList()..sort(); // Unused variable

    // Add missing zero points for smoother look (Optional, but good for "Activity")
    for (int i = 1; i <= 31; i++) {
      if (dataMap.containsKey(i)) {
        spots.add(FlSpot(i.toDouble(), dataMap[i]!.toDouble()));
      } else {
        // Optional: Don't add zeros if you want connected lines between events.
        // But for "Daily Activity", zeros makes sense.
        // Let's add zeros for gaps to show "no activity" days strictly.
        spots.add(FlSpot(i.toDouble(), 0));
      }
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading && _totalUsersCount == 0 && _totalChaletsCount == 0) {
      return Center(
        child: CircularProgressIndicator(color: ColorsManager.chaletAccent),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'التحليلات الشاملة �',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    Text(
                      'نظرة عامة على أداء التطبيق',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
                // Refresh Button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isLoading = true;
                      _allUsersData.clear();
                    });
                    _setupRealtimeListeners();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: ColorsManager.chaletAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: ColorsManager.chaletAccent.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.refresh,
                          color: ColorsManager.chaletAccent,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'تحديث',
                          style: TextStyle(
                            color: ColorsManager.chaletAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 1. KPI Cards Grid
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 1200
                  ? 4
                  : (MediaQuery.of(context).size.width > 800 ? 2 : 1),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              childAspectRatio: 1.5,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatCard(
                  context,
                  title: 'المستخدمين',
                  value: _totalUsersCount.toString(),
                  icon: Icons.people_alt_rounded,
                  color: const Color(0xFF3B82F6), // Blue
                  isDark: isDark,
                  isSelected: _chartVisibility['Users']!,
                  onTap: () => setState(
                    () =>
                        _chartVisibility['Users'] = !_chartVisibility['Users']!,
                  ),
                ),
                _buildStatCard(
                  context,
                  title: 'الشاليهات',
                  value: _totalChaletsCount.toString(),
                  icon: Icons.holiday_village_rounded,
                  color: const Color(0xFF10B981), // Emerald
                  isDark: isDark,
                  isSelected: _chartVisibility['Chalets']!,
                  onTap: () => setState(
                    () => _chartVisibility['Chalets'] =
                        !_chartVisibility['Chalets']!,
                  ),
                ),
                _buildStatCard(
                  context,
                  title: 'الحجوزات',
                  value: _totalBookingsCount.toString(),
                  icon: Icons.book_online_rounded,
                  color: const Color(0xFFF59E0B), // Amber
                  isDark: isDark,
                  isSelected: _chartVisibility['Bookings']!,
                  onTap: () => setState(
                    () => _chartVisibility['Bookings'] =
                        !_chartVisibility['Bookings']!,
                  ),
                ),
                _buildStatCard(
                  context,
                  title: 'الإيرادات',
                  value:
                      '${(_totalRevenue / 1000).toStringAsFixed(1)}k EGP', // Formatted
                  icon: Icons.monetization_on_rounded,
                  color: const Color(0xFFEC4899), // Pink
                  isDark: isDark,
                  isSelected: _chartVisibility['Revenue']!,
                  onTap: () => setState(
                    () => _chartVisibility['Revenue'] =
                        !_chartVisibility['Revenue']!,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Combined Multi-Line Chart
            _buildLineChartSection(isDark),

            const SizedBox(height: 32),

            // 3. Pie Charts Row (Distributions)
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  return Row(
                    children: [
                      Expanded(child: _buildChaletStatusChart(isDark)),
                      const SizedBox(width: 24),
                      Expanded(child: _buildBookingStatusChart(isDark)),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildChaletStatusChart(isDark),
                      const SizedBox(height: 24),
                      _buildBookingStatusChart(isDark),
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildLineChartSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF1F2937), Color(0xFF111827)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Colors.white, Color(0xFFF9FAFB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.analytics_rounded,
                          color: Colors.blueAccent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'مسار النمو الموحد',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'مقارنة شاملة لجميع مؤشرات الأداء معاً',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ],
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
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDark
                        ? Colors.white10
                        : Colors.grey.withOpacity(0.05),
                    strokeWidth: 1,
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                    color: isDark
                        ? Colors.white10
                        : Colors.grey.withOpacity(0.05),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 5,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '${value.toInt()}',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey[500]
                                  : Colors.grey[400],
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: isDark ? Colors.grey[500] : Colors.grey[400],
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  if (_chartVisibility['Revenue']!)
                    _buildLineBarData(
                      _revenueSpots,
                      const Color(0xFFEC4899),
                      isShadow: true,
                    ),
                  if (_chartVisibility['Users']!)
                    _buildLineBarData(
                      _usersSpots,
                      const Color(0xFF3B82F6),
                      isShadow: true,
                    ),
                  if (_chartVisibility['Chalets']!)
                    _buildLineBarData(
                      _chaletsSpots,
                      const Color(0xFF10B981),
                      isShadow: true,
                    ),
                  if (_chartVisibility['Bookings']!)
                    _buildLineBarData(
                      _bookingsSpots,
                      const Color(0xFFF59E0B),
                      isShadow: true,
                    ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => isDark
                        ? const Color(0xFF1F2937).withOpacity(0.9)
                        : Colors.white.withOpacity(0.9),
                    tooltipPadding: const EdgeInsets.all(16),
                    tooltipBorder: BorderSide(
                      color: Colors.grey.withOpacity(0.1),
                    ),
                    getTooltipItems: (touchedSpots) {
                      touchedSpots.sort((a, b) => b.y.compareTo(a.y));
                      return touchedSpots.map((spot) {
                        Color color = spot.bar.color ?? Colors.black;
                        String label = '';
                        String value = spot.y.toInt().toString();

                        if (color == const Color(0xFF3B82F6))
                          label = '👤 مستخدمين';
                        else if (color == const Color(0xFF10B981))
                          label = '🏡 شاليهات';
                        else if (color == const Color(0xFFF59E0B))
                          label = '📅 حجوزات';
                        else if (color == const Color(0xFFEC4899)) {
                          label = '💰 إيرادات';
                          value = '${(spot.y * _revenueScaleFactor).toInt()}';
                        }

                        return LineTooltipItem(
                          '$label   $value\n',
                          TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            fontFamily: 'Tajawal',
                          ),
                          textAlign: TextAlign.right,
                        );
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),
          // Interactive Legend - Improved Style
          Center(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildLegendToggle(
                  'المستخدمين',
                  const Color(0xFF3B82F6),
                  'Users',
                  isDark,
                ),
                _buildLegendToggle(
                  'الشاليهات',
                  const Color(0xFF10B981),
                  'Chalets',
                  isDark,
                ),
                _buildLegendToggle(
                  'الحجوزات',
                  const Color(0xFFF59E0B),
                  'Bookings',
                  isDark,
                ),
                _buildLegendToggle(
                  'الإيرادات (k)',
                  const Color(0xFFEC4899),
                  'Revenue',
                  isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _buildLineBarData(
    List<FlSpot> spots,
    Color color, {
    bool isShadow = true,
  }) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.35,
      preventCurveOverShooting: true,
      color: color,
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false), // Clean look for multi-line
      belowBarData: BarAreaData(
        show: isShadow,
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildLegendToggle(String text, Color color, String key, bool isDark) {
    bool isActive = _chartVisibility[key]!;
    return GestureDetector(
      onTap: () => setState(() => _chartVisibility[key] = !isActive),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? color
              : (isDark ? Colors.white10 : Colors.grey[100]),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isActive
                ? color
                : (isDark ? Colors.white24 : Colors.grey[300]!),
            width: 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive)
              Icon(Icons.check_rounded, color: Colors.white, size: 16)
            else
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),

            if (isActive)
              const SizedBox(width: 6)
            else
              const SizedBox(width: 8),

            Text(
              text,
              style: TextStyle(
                color: isActive
                    ? Colors.white
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChaletStatusChart(bool isDark) {
    int total =
        (_chaletStatusDistribution['Active'] ?? 0) +
        (_chaletStatusDistribution['Pending'] ?? 0);
    return _buildPieChartCard(
      title: 'حالة الشاليهات',
      isDark: isDark,
      centerText: 'إجمالي\n$total',
      sections: [
        PieChartSectionData(
          color: const Color(0xFF10B981), // Emerald
          value: (_chaletStatusDistribution['Active'] ?? 0).toDouble(),
          title:
              '${_getPercentage(_chaletStatusDistribution['Active'] ?? 0, total)}%',
          radius: 25,
          titleStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 12,
          ),
        ),
        PieChartSectionData(
          color: const Color(0xFFEF4444), // Red
          value: (_chaletStatusDistribution['Pending'] ?? 0).toDouble(),
          title:
              '${_getPercentage(_chaletStatusDistribution['Pending'] ?? 0, total)}%',
          radius: 25,
          titleStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
      legendItems: [
        _buildLegendItem(
          color: const Color(0xFF10B981),
          text: 'نشط',
          value: '${_chaletStatusDistribution['Active'] ?? 0}',
          isDark: isDark,
        ),
        _buildLegendItem(
          color: const Color(0xFFEF4444),
          text: 'قيد المراجعة',
          value: '${_chaletStatusDistribution['Pending'] ?? 0}',
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildBookingStatusChart(bool isDark) {
    int total = _bookingStatusDistribution.values.fold(0, (a, b) => a + b);
    return _buildPieChartCard(
      title: 'توزيع الحجوزات',
      isDark: isDark,
      centerText: 'حجوزات\n$total',
      sections: [
        PieChartSectionData(
          color: const Color(0xFF10B981), // Completed - Green
          value: (_bookingStatusDistribution['Completed'] ?? 0).toDouble(),
          radius: 30, // Make completed slightly larger
          title: '',
        ),
        PieChartSectionData(
          color: const Color(0xFF3B82F6), // Accepted - Blue
          value: (_bookingStatusDistribution['Accepted'] ?? 0).toDouble(),
          radius: 25,
          title: '',
        ),
        PieChartSectionData(
          color: const Color(0xFFF59E0B), // Pending - Amber
          value: (_bookingStatusDistribution['Pending'] ?? 0).toDouble(),
          radius: 25,
          title: '',
        ),
        PieChartSectionData(
          color: const Color(0xFFEF4444), // Cancelled - Red
          value: (_bookingStatusDistribution['Cancelled'] ?? 0).toDouble(),
          radius: 25,
          title: '',
        ),
      ],
      legendItems: [
        _buildLegendItem(
          color: const Color(0xFF10B981),
          text: 'مكتمل',
          value: '${_bookingStatusDistribution['Completed'] ?? 0}',
          isDark: isDark,
        ),
        _buildLegendItem(
          color: const Color(0xFF3B82F6),
          text: 'مقبول',
          value: '${_bookingStatusDistribution['Accepted'] ?? 0}',
          isDark: isDark,
        ),
        _buildLegendItem(
          color: const Color(0xFFF59E0B),
          text: 'معلق',
          value: '${_bookingStatusDistribution['Pending'] ?? 0}',
          isDark: isDark,
        ),
        _buildLegendItem(
          color: const Color(0xFFEF4444),
          text: 'ملغي',
          value: '${_bookingStatusDistribution['Cancelled'] ?? 0}',
          isDark: isDark,
        ),
      ],
    );
  }

  String _getPercentage(int value, int total) {
    if (total == 0) return '0';
    return ((value / total) * 100).toStringAsFixed(0);
  }

  Widget _buildPieChartCard({
    required String title,
    required List<PieChartSectionData> sections,
    required List<Widget> legendItems,
    required bool isDark,
    required String centerText,
  }) {
    bool isEmpty = sections.every((s) => s.value == 0);
    List<PieChartSectionData> finalSections = isEmpty
        ? [
            PieChartSectionData(
              value: 1,
              color: isDark ? Colors.white10 : Colors.grey[200],
              title: '',
              radius: 25,
            ),
          ]
        : sections;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Donut Chart
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sections: finalSections,
                          centerSpaceRadius: 60, // Donut hole
                          sectionsSpace: 4, // More clearer separation
                          startDegreeOffset: -90,
                        ),
                      ),
                      // Center Text
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isEmpty ? '0' : centerText.split('\n').last,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : Colors.black87,
                              height: 1,
                            ),
                          ),
                          Text(
                            isEmpty ? 'لا يوجد' : centerText.split('\n').first,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[500],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Legend
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: legendItems,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
    VoidCallback? onTap,
    bool isSelected = false,
    String? subTitle,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(color: color, width: 2)
              : Border.all(color: Colors.transparent, width: 2),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? color.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 20 : 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                if (isSelected)
                  Icon(Icons.check_circle_rounded, color: color, size: 20),
              ],
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.grey[500],
                fontWeight: FontWeight.w600,
                fontFamily: 'Tajawal',
              ),
            ),
            if (subTitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  subTitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Updated Legend Item with Values and Better Design
  Widget _buildLegendItem({
    required Color color,
    required String text,
    String? value,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.grey[700],
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
          if (value != null)
            Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
            ),
        ],
      ),
    );
  }
}
