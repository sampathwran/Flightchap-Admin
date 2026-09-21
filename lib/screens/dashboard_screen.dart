import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedFilter = 'This Week';
  final List<String> _filters = ['Today', 'This Week', 'This Month', 'Custom Range'];
  DateTimeRange? _customDateRange;

  bool _isLoading = true;

  // Real data state variables
  int totalVisits = 0;
  int totalRegistered = 0;
  int totalClicks = 0;
  int totalSearches = 0;
  int totalWishlist = 0;

  List<FlSpot> visitsSpots = [];
  List<FlSpot> clicksSpots = [];
  List<String> dateLabels = [];
  double maxY = 10.0;

  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  Future<void> _fetchAnalytics() async {
    setState(() => _isLoading = true);

    DateTime endDate = DateTime.now();
    DateTime startDate;

    if (_selectedFilter == 'Today') {
      startDate = endDate;
    } else if (_selectedFilter == 'This Week') {
      startDate = endDate.subtract(const Duration(days: 6));
    } else if (_selectedFilter == 'This Month') {
      startDate = endDate.subtract(const Duration(days: 29));
    } else if (_selectedFilter == 'Custom Range' && _customDateRange != null) {
      startDate = _customDateRange!.start;
      endDate = _customDateRange!.end;
    } else {
      startDate = endDate.subtract(const Duration(days: 6));
    }

    String startStr = DateFormat('yyyy-MM-dd').format(startDate);
    String endStr = DateFormat('yyyy-MM-dd').format(endDate);

    try {
      // Fetch all-time totals
      final allTimeSnapshot = await FirebaseFirestore.instance.collection('all_time_analytics').doc('totals').get();
      int allTimeVisits = 0;
      int allTimeReg = 0;
      int allTimeClicks = 0;
      int allTimeSearch = 0;
      int allTimeWish = 0;
      
      if (allTimeSnapshot.exists && allTimeSnapshot.data() != null) {
        var data = allTimeSnapshot.data()!;
        allTimeVisits = (data['visits'] as num?)?.toInt() ?? 0;
        allTimeClicks = (data['clicks'] as num?)?.toInt() ?? 0;
        allTimeSearch = (data['searches'] as num?)?.toInt() ?? 0;
        allTimeWish = (data['wishlist'] as num?)?.toInt() ?? 0;
      }

      // Fetch actual registered users count from the users collection
      final usersCountSnapshot = await FirebaseFirestore.instance.collection('users').count().get();
      allTimeReg = usersCountSnapshot.count ?? 0;

      // Fetch actual wishlist count
      final wishCountSnapshot = await FirebaseFirestore.instance.collection('wishlists').count().get();
      allTimeWish = wishCountSnapshot.count ?? 0;

      // FALLBACK: If all-time is 0 (maybe the new code hasn't fired yet), calculate from daily_analytics
      if (allTimeVisits == 0 && allTimeClicks == 0) {
        final allDailySnapshot = await FirebaseFirestore.instance.collection('daily_analytics').get();
        for (var doc in allDailySnapshot.docs) {
          var data = doc.data();
          allTimeVisits += (data['visits'] as num?)?.toInt() ?? 0;
          allTimeReg += (data['registered'] as num?)?.toInt() ?? 0;
          allTimeClicks += (data['clicks'] as num?)?.toInt() ?? 0;
          allTimeSearch += (data['searches'] as num?)?.toInt() ?? 0;
          allTimeWish += (data['wishlist'] as num?)?.toInt() ?? 0;
        }
      }

      // Fetch daily analytics for the chart
      final snapshot = await FirebaseFirestore.instance
          .collection('daily_analytics')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: startStr)
          .where(FieldPath.documentId, isLessThanOrEqualTo: endStr)
          .get();

      List<FlSpot> vSpots = [];
      List<FlSpot> cSpots = [];
      List<String> dLabels = [];
      double highestValue = 10.0; // minimum scale

      Map<String, Map<String, dynamic>> dataMap = {};
      for (var doc in snapshot.docs) {
        dataMap[doc.id] = doc.data();
      }

      int daysDiff = endDate.difference(startDate).inDays;
      for (int i = 0; i <= daysDiff; i++) {
        DateTime current = startDate.add(Duration(days: i));
        String dateKey = DateFormat('yyyy-MM-dd').format(current);
        dLabels.add(DateFormat('MMM d').format(current));

        int v = 0;
        int c = 0;
        if (dataMap.containsKey(dateKey)) {
          var data = dataMap[dateKey]!;
          v = (data['visits'] as num?)?.toInt() ?? 0;
          c = (data['clicks'] as num?)?.toInt() ?? 0;
        }

        vSpots.add(FlSpot(i.toDouble(), v.toDouble()));
        cSpots.add(FlSpot(i.toDouble(), c.toDouble()));

        if (v > highestValue) highestValue = v.toDouble();
        if (c > highestValue) highestValue = c.toDouble();
      }

      setState(() {
        totalVisits = allTimeVisits;
        totalRegistered = allTimeReg;
        totalClicks = allTimeClicks;
        totalSearches = allTimeSearch;
        totalWishlist = allTimeWish;
        visitsSpots = vSpots;
        clicksSpots = cSpots;
        dateLabels = dLabels;
        maxY = (highestValue * 1.2).ceilToDouble(); // Add 20% padding to top
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching analytics: $e");
      setState(() => _isLoading = false);
    }
  }

  void _showCustomDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: _customDateRange ?? DateTimeRange(start: DateTime.now().subtract(const Duration(days: 7)), end: DateTime.now()),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF007bff),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _customDateRange = picked;
        _selectedFilter = 'Custom Range';
      });
      _fetchAnalytics();
    } else if (_selectedFilter == 'Custom Range' && _customDateRange == null) {
      setState(() {
        _selectedFilter = 'This Week';
      });
    }
  }

  void _onFilterChanged(String newValue) {
    if (newValue == 'Custom Range') {
      _showCustomDateRangePicker();
    } else {
      setState(() {
        _selectedFilter = newValue;
      });
      _fetchAnalytics();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Filter Dropdown
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 16,
            spacing: 16,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Platform Analytics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF333335))),
                  SizedBox(height: 4),
                  Text('Real-time overview of your platform performance.', style: TextStyle(color: Color(0xFF8c9097), fontSize: 14)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedFilter,
                    icon: const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.calendar_month, color: Color(0xFF007bff), size: 20),
                    ),
                    style: const TextStyle(color: Color(0xFF333335), fontWeight: FontWeight.w600, fontSize: 14),
                    items: _filters.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value == 'Custom Range' && _customDateRange != null 
                            ? '${DateFormat('MMM d').format(_customDateRange!.start)} - ${DateFormat('MMM d').format(_customDateRange!.end)}' 
                            : value),
                      );
                    }).toList(),
                    onChanged: (val) => _onFilterChanged(val!),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // Stat Cards
          _isLoading 
            ? const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: Color(0xFF007bff))))
            : Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  _buildStatCard('Total Visits', NumberFormat.compact().format(totalVisits), '', const Color(0xFF007bff), Icons.visibility),
                  _buildStatCard('Total Registered', NumberFormat.compact().format(totalRegistered), '', const Color(0xFF23b7e5), Icons.person_add),
                  _buildStatCard('Total Clicks', NumberFormat.compact().format(totalClicks), '', const Color(0xFFf5b849), Icons.touch_app),
                  _buildStatCard('Total Searches', NumberFormat.compact().format(totalSearches), '', const Color(0xFFe6533c), Icons.search),
                  _buildStatCard('Wishlist Saves', NumberFormat.compact().format(totalWishlist), '', const Color(0xFF26bf94), Icons.favorite),
                ],
              ),

          const SizedBox(height: 30),

          // Chart Section
          Container(
            height: 450,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text('Traffic & Engagement Trends', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF333335))),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLegendItem('Visits', const Color(0xFF007bff)),
                        const SizedBox(width: 16),
                        _buildLegendItem('Clicks', const Color(0xFF23b7e5)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF007bff)))
                    : LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true, 
                            drawVerticalLine: false,
                            horizontalInterval: maxY / 5,
                            getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: (dateLabels.length > 7) ? (dateLabels.length / 5).ceilToDouble() : 1,
                                getTitlesWidget: (value, meta) {
                                  int index = value.toInt();
                                  if (index < 0 || index >= dateLabels.length) return const SizedBox.shrink();
                                  const style = TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600);
                                  return SideTitleWidget(meta: meta, child: Text(dateLabels[index], style: style));
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                interval: maxY / 5,
                                getTitlesWidget: (value, meta) {
                                  if (value == 0) return const SizedBox.shrink();
                                  return Text(NumberFormat.compact().format(value), style: const TextStyle(color: Colors.grey, fontSize: 11));
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: 0, maxX: (dateLabels.length - 1).toDouble(), minY: 0, maxY: maxY,
                          lineBarsData: [
                            LineChartBarData(
                              spots: visitsSpots.isEmpty ? const [FlSpot(0,0)] : visitsSpots,
                              isCurved: true,
                              color: const Color(0xFF007bff),
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: const Color(0xFF007bff).withOpacity(0.1),
                              ),
                            ),
                            LineChartBarData(
                              spots: clicksSpots.isEmpty ? const [FlSpot(0,0)] : clicksSpots,
                              isCurved: true,
                              color: const Color(0xFF23b7e5),
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                            ),
                          ],
                        ),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String percent, Color color, IconData icon, {bool isNegative = false}) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 18),
              ),
              if (percent.isNotEmpty)
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isNegative ? Colors.red.shade50 : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12)
                    ),
                    child: Text(percent, style: TextStyle(color: isNegative ? Colors.red : Colors.green, fontSize: 11, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                  ),
                )
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF333335))),
          ),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(color: Color(0xFF8c9097), fontSize: 12, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
