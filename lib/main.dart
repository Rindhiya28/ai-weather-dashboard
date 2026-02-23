// lib/main.dart — Modern Dark Weather Dashboard

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'services/weather_service.dart';
import 'screens/prediction_screen.dart';

void main() {
  runApp(const MyApp());
}

// ── Design Tokens ────────────────────────────────────────────────────────────
const kBg        = Color(0xFF050D1A);
const kSurface   = Color(0xFF0D1F35);
const kCard      = Color(0xFF102040);
const kAccent    = Color(0xFF00D4FF);
const kAccent2   = Color(0xFF7C3AED);
const kGreen     = Color(0xFF10B981);
const kOrange    = Color(0xFFF59E0B);
const kRed       = Color(0xFFEF4444);
const kTextPri   = Color(0xFFE2E8F0);
const kTextSec   = Color(0xFF64748B);
const kBorder    = Color(0xFF1E3A5F);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Weather Intelligence',
      theme: ThemeData(
        scaffoldBackgroundColor: kBg,
        fontFamily: 'Georgia',
        colorScheme: const ColorScheme.dark(
          primary: kAccent,
          surface: kSurface,
        ),
      ),
      home: const DashboardPage(),
    );
  }
}

////////////////////////////////////////////////////
/// MAIN DASHBOARD CONTROLLER
////////////////////////////////////////////////////

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedIndex = 0;
  final pages = const [
    DashboardHome(),
    PredictionScreen(),
    AnalyticsScreen(),
    ChatbotScreen(),
    AlertsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Row(
        children: [
          Sidebar(
            selectedIndex: selectedIndex,
            onItemSelected: (i) => setState(() => selectedIndex = i),
          ),
          Expanded(child: pages[selectedIndex]),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////
/// SIDEBAR
////////////////////////////////////////////////////

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  const Sidebar({super.key, required this.selectedIndex, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.dashboard_rounded,     'Dashboard'),
      (Icons.auto_graph_rounded,    'Prediction'),
      (Icons.bar_chart_rounded,     'Analytics'),
      (Icons.chat_bubble_rounded,   'AI Chat'),
      (Icons.notifications_rounded, 'Alerts'),
    ];

    return Container(
      width: 72,
      decoration: const BoxDecoration(
        color: kSurface,
        border: Border(right: BorderSide(color: kBorder, width: 1)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Logo
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kAccent, kAccent2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.cloud_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 32),
          const Divider(color: kBorder, height: 1),
          const SizedBox(height: 16),
          ...items.asMap().entries.map((e) {
            final isSelected = selectedIndex == e.key;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
              child: Tooltip(
                message: e.value.$2,
                preferBelow: false,
                child: GestureDetector(
                  onTap: () => onItemSelected(e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isSelected ? kAccent.withOpacity(0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: isSelected
                          ? Border.all(color: kAccent.withOpacity(0.4), width: 1)
                          : null,
                    ),
                    child: Icon(
                      e.value.$1,
                      color: isSelected ? kAccent : kTextSec,
                      size: 22,
                    ),
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: kAccent2.withOpacity(0.3),
              child: const Text('AW', style: TextStyle(color: kAccent, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////
/// TOP BAR
////////////////////////////////////////////////////

class TopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  const TopBar({super.key, required this.title, this.subtitle = 'Chennai, Tamil Nadu'});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kBorder, width: 1)),
      ),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(
                  color: kTextPri, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
              Text(subtitle, style: const TextStyle(color: kTextSec, fontSize: 13)),
            ],
          ),
          const Spacer(),
          // Search
          Container(
            width: 220,
            height: 38,
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kBorder),
            ),
            child: const TextField(
              style: TextStyle(color: kTextPri, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search city...',
                hintStyle: TextStyle(color: kTextSec, fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded, color: kTextSec, size: 18),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Live badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: kGreen.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kGreen.withOpacity(0.3)),
            ),
            child: Row(children: [
              Container(width: 6, height: 6,
                  decoration: const BoxDecoration(color: kGreen, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              const Text('LIVE', style: TextStyle(color: kGreen, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
            ]),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////
/// DASHBOARD HOME
////////////////////////////////////////////////////

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});
  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> with TickerProviderStateMixin {
  String _currentTemp = '--';
  bool _isAnomaly = false;
  List<double>? _forecast;
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _loadData();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        WeatherService.getAnomalyStatus(),
        WeatherService.get7DayForecast(),
      ]);
      if (!mounted) return;
      final anomaly  = results[0] as Map<String, dynamic>;
      final forecast = results[1] as List<double>;
      setState(() {
        _currentTemp = "${anomaly['current_temp_celsius']}";
        _isAnomaly   = anomaly['is_anomaly'];
        _forecast    = forecast;
      });
      _fadeCtrl.forward();
    } catch (_) {
      if (!mounted) return;
      setState(() => _currentTemp = 'N/A');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TopBar(title: 'Dashboard'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero weather card ─────────────────────────────────
                _HeroCard(temp: _currentTemp, isAnomaly: _isAnomaly),
                const SizedBox(height: 20),
                // ── Metric cards row ──────────────────────────────────
                Row(children: [
                  Expanded(child: _MetricCard('Humidity',   '70%',      Icons.water_drop_rounded,  kAccent)),
                  const SizedBox(width: 16),
                  Expanded(child: _MetricCard('Wind',       '12 km/h',  Icons.air_rounded,          kAccent2)),
                  const SizedBox(width: 16),
                  Expanded(child: _MetricCard('Condition',  'Cloudy',   Icons.cloud_rounded,        kOrange)),
                  const SizedBox(width: 16),
                  Expanded(child: _MetricCard('UV Index',   '6 - High', Icons.wb_sunny_rounded,     kRed)),
                ]),
                const SizedBox(height: 24),
                // ── Forecast chart ────────────────────────────────────
                FadeTransition(
                  opacity: _fade,
                  child: _GlassCard(
                    title: '7-Day Forecast',
                    subtitle: 'ML Model prediction',
                    icon: Icons.auto_graph_rounded,
                    height: 260,
                    child: _forecast == null
                        ? const Center(child: CircularProgressIndicator(color: kAccent))
                        : TemperatureChart(forecast: _forecast),
                  ),
                ),
                const SizedBox(height: 20),
                // ── Alert strip ───────────────────────────────────────
                _AlertStrip(isAnomaly: _isAnomaly, temp: _currentTemp),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Hero card with big temperature display
class _HeroCard extends StatelessWidget {
  final String temp;
  final bool isAnomaly;
  const _HeroCard({required this.temp, required this.isAnomaly});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isAnomaly
              ? [const Color(0xFF3B0000), const Color(0xFF1A0A00)]
              : [const Color(0xFF001A3A), const Color(0xFF050D1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAnomaly ? kRed.withOpacity(0.4) : kAccent.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Temperature',
                  style: TextStyle(color: kTextSec, fontSize: 13, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(temp,
                      style: TextStyle(
                        color: isAnomaly ? kRed : kAccent,
                        fontSize: 72,
                        fontWeight: FontWeight.w800,
                        height: 1,
                        letterSpacing: -3,
                      )),
                  const Text('°C',
                      style: TextStyle(color: kAccent, fontSize: 28, fontWeight: FontWeight.w300)),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: (isAnomaly ? kRed : kGreen).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: (isAnomaly ? kRed : kGreen).withOpacity(0.3)),
                ),
                child: Text(
                  isAnomaly ? '⚠  Anomaly Detected' : '✓  Temperature Normal',
                  style: TextStyle(
                    color: isAnomaly ? kRed : kGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Icon(
            Icons.wb_sunny_rounded,
            size: 90,
            color: (isAnomaly ? kRed : kOrange).withOpacity(0.3),
          ),
        ],
      ),
    );
  }
}

// Small metric card
class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _MetricCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 14),
          Text(value,
              style: const TextStyle(color: kTextPri, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: kTextSec, fontSize: 12)),
        ],
      ),
    );
  }
}

// Alert strip
class _AlertStrip extends StatelessWidget {
  final bool isAnomaly;
  final String temp;
  const _AlertStrip({required this.isAnomaly, required this.temp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.notifications_active_rounded, color: kOrange, size: 18),
            SizedBox(width: 8),
            Text('Active Alerts', style: TextStyle(color: kTextPri, fontSize: 15, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 14),
          _AlertRow(
            color: isAnomaly ? kRed : kGreen,
            icon: isAnomaly ? Icons.warning_rounded : Icons.check_circle_rounded,
            text: isAnomaly ? 'Temperature anomaly detected at ${temp}°C' : 'Temperature within normal range',
          ),
          const SizedBox(height: 8),
          const _AlertRow(color: kOrange, icon: Icons.water_drop_rounded, text: 'Humidity increase detected — possible rainfall'),
          const SizedBox(height: 8),
          const _AlertRow(color: kAccent, icon: Icons.info_rounded, text: 'Wind conditions stable, no storm warnings'),
        ],
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  const _AlertRow({required this.color, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 36, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 12),
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(color: kTextSec, fontSize: 13))),
      ],
    );
  }
}

////////////////////////////////////////////////////
/// GLASS CARD CONTAINER
////////////////////////////////////////////////////

class _GlassCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final double? height;
  const _GlassCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                  color: kAccent.withOpacity(0.12), borderRadius: BorderRadius.circular(9)),
              child: Icon(icon, color: kAccent, size: 17),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: kTextPri, fontSize: 15, fontWeight: FontWeight.w600)),
                Text(subtitle, style: const TextStyle(color: kTextSec, fontSize: 12)),
              ],
            ),
          ]),
          const SizedBox(height: 20),
          Expanded(child: child),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////
/// TEMPERATURE CHART
////////////////////////////////////////////////////

class TemperatureChart extends StatelessWidget {
  final List<double>? forecast;
  const TemperatureChart({super.key, this.forecast});

  @override
  Widget build(BuildContext context) {
    final data = forecast ?? [28.0, 29.0, 30.0, 31.0, 32.0, 33.0, 32.0];
    final spots = data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();
    final minY = data.reduce((a, b) => a < b ? a : b) - 2;
    final maxY = data.reduce((a, b) => a > b ? a : b) + 2;

    return LineChart(LineChartData(
      minY: minY, maxY: maxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) => const FlLine(color: kBorder, strokeWidth: 1),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (v, _) {
            const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
            final i = v.toInt();
            if (i < 0 || i >= days.length) return const SizedBox();
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(days[i], style: const TextStyle(color: kTextSec, fontSize: 11)),
            );
          },
        )),
        leftTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true, reservedSize: 42,
          getTitlesWidget: (v, _) =>
              Text('${v.toInt()}°', style: const TextStyle(color: kTextSec, fontSize: 11)),
        )),
        topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (spots) => spots.map((s) =>
            LineTooltipItem('${s.y.toStringAsFixed(1)}°C',
                const TextStyle(color: kBg, fontWeight: FontWeight.bold, fontSize: 13))
          ).toList(),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          isCurved: true,
          curveSmoothness: 0.4,
          spots: spots,
          barWidth: 2.5,
          color: kAccent,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
              radius: 4, color: kBg,
              strokeWidth: 2, strokeColor: kAccent,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [kAccent.withOpacity(0.25), kAccent.withOpacity(0.0)],
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    ));
  }
}

////////////////////////////////////////////////////
/// ANALYTICS SCREEN
////////////////////////////////////////////////////

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<double>? _forecast;
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadForecast(); }

  Future<void> _loadForecast() async {
    try {
      final data = await WeatherService.get7DayForecast();
      if (!mounted) return;
      setState(() { _forecast = data; _loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TopBar(title: 'Analytics', subtitle: 'Historical & Forecast Analysis'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              SizedBox(
                height: 280,
                child: _GlassCard(
                  title: 'Temperature Forecast',
                  subtitle: 'Random Forest ML Model · 7 days',
                  icon: Icons.thermostat_rounded,
                  child: _loading
                      ? const Center(child: CircularProgressIndicator(color: kAccent))
                      : TemperatureChart(forecast: _forecast),
                ),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: SizedBox(
                  height: 240,
                  child: _GlassCard(
                    title: 'Rainfall Analysis',
                    subtitle: 'Weekly distribution',
                    icon: Icons.water_drop_rounded,
                    child: _RainfallChart(),
                  ),
                )),
                const SizedBox(width: 20),
                Expanded(child: SizedBox(
                  height: 240,
                  child: _GlassCard(
                    title: 'Humidity Trend',
                    subtitle: '7-day pattern',
                    icon: Icons.opacity_rounded,
                    child: _HumidityChart(),
                  ),
                )),
              ]),
            ]),
          ),
        ),
      ],
    );
  }
}

class _RainfallChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BarChart(BarChartData(
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: true, drawVerticalLine: false,
        getDrawingHorizontalLine: (_) => const FlLine(color: kBorder, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (v, _) {
            const days = ['M','T','W','T','F'];
            final i = v.toInt();
            if (i < 0 || i >= days.length) return const SizedBox();
            return Padding(padding: const EdgeInsets.only(top: 6),
                child: Text(days[i], style: const TextStyle(color: kTextSec, fontSize: 11)));
          },
        )),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      barGroups: [
        BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 3, color: kAccent, width: 18, borderRadius: BorderRadius.circular(4))]),
        BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 5, color: kAccent, width: 18, borderRadius: BorderRadius.circular(4))]),
        BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 2, color: kAccent, width: 18, borderRadius: BorderRadius.circular(4))]),
        BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 6, color: kAccent2, width: 18, borderRadius: BorderRadius.circular(4))]),
        BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 4, color: kAccent, width: 18, borderRadius: BorderRadius.circular(4))]),
      ],
    ));
  }
}

class _HumidityChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LineChart(LineChartData(
      gridData: FlGridData(
        show: true, drawVerticalLine: false,
        getDrawingHorizontalLine: (_) => const FlLine(color: kBorder, strokeWidth: 1),
      ),
      borderData: FlBorderData(show: false),
      titlesData: const FlTitlesData(show: false),
      lineBarsData: [
        LineChartBarData(
          isCurved: true,
          color: kAccent2,
          spots: const [
            FlSpot(0, 60), FlSpot(1, 62), FlSpot(2, 65),
            FlSpot(3, 68), FlSpot(4, 70), FlSpot(5, 72), FlSpot(6, 69),
          ],
          barWidth: 2.5,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [kAccent2.withOpacity(0.3), kAccent2.withOpacity(0.0)],
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    ));
  }
}

////////////////////////////////////////////////////
/// CHATBOT SCREEN
////////////////////////////////////////////////////

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});
  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  List<Map<String, String>> messages = [
    {"role": "ai", "text": "Hello! I'm your AI weather assistant. Ask me anything about weather predictions, forecasts, or climate patterns for Chennai. 🌦️"}
  ];

  bool _isTyping = false;

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> sendMessage() async {
    if (_ctrl.text.trim().isEmpty || _isTyping) return;
    final userMsg = _ctrl.text.trim();
    _ctrl.clear();
    setState(() {
      messages.add({"role": "user", "text": userMsg});
      _isTyping = true;
    });
    _scrollToBottom();
    try {
      final reply = await WeatherService.sendChatMessage(userMsg);
      if (!mounted) return;
      setState(() {
        messages.add({"role": "ai", "text": reply});
        _isTyping = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        messages.add({"role": "ai", "text": "Could not reach AI backend. Make sure the server is running."});
        _isTyping = false;
      });
    }
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TopBar(title: 'AI Chat', subtitle: 'Weather Intelligence Assistant'),
        Expanded(
          child: Column(children: [
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(24),
                itemCount: messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (_, i) {
                  // Show typing indicator as last item
                  if (_isTyping && i == messages.length) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: kCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: kBorder),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const SizedBox(
                            width: 40, height: 10,
                            child: _TypingDots(),
                          ),
                          const SizedBox(width: 8),
                          Text('AI is thinking...', style: TextStyle(color: kTextSec, fontSize: 12)),
                        ]),
                      ),
                    );
                  }
                  final msg = messages[i];
                  final isUser = msg["role"] == "user";
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.55),
                      decoration: BoxDecoration(
                        gradient: isUser
                            ? const LinearGradient(colors: [kAccent, Color(0xFF0099CC)])
                            : null,
                        color: isUser ? null : kCard,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isUser ? 16 : 4),
                          bottomRight: Radius.circular(isUser ? 4 : 16),
                        ),
                        border: isUser ? null : Border.all(color: kBorder),
                      ),
                      child: Text(msg["text"]!,
                          style: TextStyle(
                            color: isUser ? kBg : kTextPri,
                            fontSize: 14, height: 1.5,
                          )),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: kBorder)),
                color: kSurface,
              ),
              child: Row(children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: kCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kBorder),
                    ),
                    child: TextField(
                      controller: _ctrl,
                      style: const TextStyle(color: kTextPri, fontSize: 14),
                      onSubmitted: (_) => sendMessage(),
                      decoration: const InputDecoration(
                        hintText: 'Ask about weather, forecasts, anomalies...',
                        hintStyle: TextStyle(color: kTextSec, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: sendMessage,
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [kAccent, Color(0xFF0099CC)]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.send_rounded, color: kBg, size: 18),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ],
    );
  }
}

////////////////////////////////////////////////////
/// TYPING DOTS ANIMATION
////////////////////////////////////////////////////

class _TypingDots extends StatefulWidget {
  const _TypingDots();
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          final opacity = ((_ctrl.value * 3 - i) % 1.0).clamp(0.2, 1.0);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 6, height: 6,
            decoration: BoxDecoration(color: kAccent.withOpacity(opacity), shape: BoxShape.circle),
          );
        }),
      ),
    );
  }
}

////////////////////////////////////////////////////
/// ALERTS SCREEN
////////////////////////////////////////////////////

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});
  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  Map<String, dynamic>? _anomaly;
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _loadAnomaly(); }

  Future<void> _loadAnomaly() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = null; });
    try {
      final data = await WeatherService.getAnomalyStatus();
      if (!mounted) return;
      setState(() { _anomaly = data; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TopBar(title: 'Alerts', subtitle: 'Real-time Risk Detection'),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: kAccent))
              : _error != null
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          color: kRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: kRed.withOpacity(0.3)),
                        ),
                        child: const Icon(Icons.wifi_off_rounded, color: kRed, size: 32),
                      ),
                      const SizedBox(height: 16),
                      const Text('Cannot reach backend', style: TextStyle(color: kTextPri, fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      const Text('Make sure uvicorn is running on port 8000',
                          style: TextStyle(color: kTextSec, fontSize: 13)),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: kAccent, foregroundColor: kBg),
                        onPressed: _loadAnomaly,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                      ),
                    ]))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(children: [
                        // ML Anomaly card
                        if (_anomaly != null) _BigAlertCard(
                          level: _anomaly!['is_anomaly'] ? 'ANOMALY DETECTED' : 'ALL CLEAR',
                          message: 'Current temperature: ${_anomaly!['current_temp_celsius']}°C',
                          sub: _anomaly!['message'],
                          color: _anomaly!['is_anomaly'] ? kRed : kGreen,
                          icon: _anomaly!['is_anomaly'] ? Icons.warning_rounded : Icons.check_circle_rounded,
                          isHighlighted: true,
                        ),
                        const SizedBox(height: 16),
                        _AlertCardItem(level: 'MEDIUM', message: 'Humidity above normal range', sub: 'Levels at 70% — threshold is 65%', color: kOrange, icon: Icons.water_drop_rounded),
                        const SizedBox(height: 12),
                        _AlertCardItem(level: 'LOW', message: 'Possible rainfall tomorrow', sub: 'Based on humidity trend analysis', color: kAccent, icon: Icons.cloud_rounded),
                        const SizedBox(height: 12),
                        _AlertCardItem(level: 'INFO', message: 'Wind conditions stable', sub: '12 km/h — No storm warnings active', color: kGreen, icon: Icons.air_rounded),
                        const SizedBox(height: 20),
                        Center(child: TextButton.icon(
                          onPressed: _loadAnomaly,
                          icon: const Icon(Icons.refresh_rounded, color: kAccent),
                          label: const Text('Refresh Detection', style: TextStyle(color: kAccent)),
                        )),
                      ]),
                    ),
        ),
      ],
    );
  }
}

class _BigAlertCard extends StatelessWidget {
  final String level, message, sub;
  final Color color;
  final IconData icon;
  final bool isHighlighted;
  const _BigAlertCard({
    required this.level, required this.message, required this.sub,
    required this.color, required this.icon, this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(level, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          ),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: kTextPri, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(color: kTextSec, fontSize: 13)),
        ])),
      ]),
    );
  }
}

class _AlertCardItem extends StatelessWidget {
  final String level, message, sub;
  final Color color;
  final IconData icon;
  const _AlertCardItem({required this.level, required this.message, required this.sub, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Row(children: [
        Container(width: 3, height: 44, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 14),
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(message, style: const TextStyle(color: kTextPri, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text(sub, style: const TextStyle(color: kTextSec, fontSize: 12)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(level, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
        ),
      ]),
    );
  }
}