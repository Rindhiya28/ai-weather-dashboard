// lib/main.dart — Professional SaaS Weather Intelligence Platform

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'services/weather_service.dart';
import 'screens/prediction_screen.dart';

void main() => runApp(const MyApp());

// ── Design System ─────────────────────────────────────────────────────────────
const kBg       = Color(0xFF03080F);
const kSurface  = Color(0xFF080F1C);
const kCard     = Color(0xFF0B1525);
const kCard2    = Color(0xFF0E1B2E);
const kAccent   = Color(0xFF00FFD1);   // mint/teal
const kAccent2  = Color(0xFF6366F1);   // indigo
const kAccent3  = Color(0xFFFF6B35);   // coral
const kGreen    = Color(0xFF22C55E);
const kOrange   = Color(0xFFF97316);
const kRed      = Color(0xFFEF4444);
const kTextPri  = Color(0xFFF1F5F9);
const kTextSec  = Color(0xFF475569);
const kTextMid  = Color(0xFF94A3B8);
const kBorder   = Color(0xFF142035);
const kBorder2  = Color(0xFF1E3050);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'WeatherAI',
    theme: ThemeData(
      scaffoldBackgroundColor: kBg,
      colorScheme: const ColorScheme.dark(primary: kAccent),
    ),
    home: const AppShell(),
  );
}

////////////////////////////////////////////////////
/// APP SHELL
////////////////////////////////////////////////////

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _idx = 0;

  final _pages = const [
    DashboardPage(),
    PredictionScreen(),
    AnalyticsPage(),
    ChatPage(),
    AlertsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Row(children: [
        _Sidebar(selected: _idx, onSelect: (i) => setState(() => _idx = i)),
        Expanded(
          child: Column(children: [
            _TopNav(pageIndex: _idx),
            Expanded(child: _pages[_idx]),
          ]),
        ),
      ]),
    );
  }
}

////////////////////////////////////////////////////
/// SIDEBAR — wide with labels
////////////////////////////////////////////////////

class _Sidebar extends StatelessWidget {
  final int selected;
  final void Function(int) onSelect;
  const _Sidebar({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final nav = [
      (Icons.grid_view_rounded,        'Dashboard'),
      (Icons.auto_graph_rounded,       'Prediction'),
      (Icons.analytics_rounded,        'Analytics'),
      (Icons.smart_toy_rounded,        'AI Chat'),
      (Icons.notification_important_rounded, 'Alerts'),
    ];

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: kSurface,
        border: const Border(right: BorderSide(color: kBorder, width: 1)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Logo
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kAccent, kAccent2],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(
                    color: kAccent.withOpacity(0.3), blurRadius: 12)],
              ),
              child: const Icon(Icons.thunderstorm_rounded,
                  color: Colors.white, size: 20)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('WeatherAI',
                  style: TextStyle(color: kTextPri, fontSize: 16,
                      fontWeight: FontWeight.w800, letterSpacing: -0.5)),
              Text('Intelligence Platform',
                  style: TextStyle(color: kTextSec, fontSize: 10,
                      letterSpacing: 0.3)),
            ]),
          ]),
        ),

        const SizedBox(height: 32),

        // Section label
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('NAVIGATION',
              style: TextStyle(color: kTextSec, fontSize: 10,
                  fontWeight: FontWeight.w600, letterSpacing: 1.5)),
        ),
        const SizedBox(height: 10),

        // Nav items
        ...nav.asMap().entries.map((e) {
          final sel = selected == e.key;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: GestureDetector(
              onTap: () => onSelect(e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 11),
                decoration: BoxDecoration(
                  color: sel ? kAccent.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: sel
                      ? Border.all(color: kAccent.withOpacity(0.25))
                      : Border.all(color: Colors.transparent),
                ),
                child: Row(children: [
                  Icon(e.value.$1,
                      color: sel ? kAccent : kTextSec,
                      size: 18),
                  const SizedBox(width: 12),
                  Text(e.value.$2,
                      style: TextStyle(
                        color: sel ? kAccent : kTextMid,
                        fontSize: 14,
                        fontWeight: sel
                            ? FontWeight.w600 : FontWeight.w400,
                      )),
                  if (sel) ...[
                    const Spacer(),
                    Container(width: 6, height: 6,
                        decoration: BoxDecoration(
                            color: kAccent, shape: BoxShape.circle,
                            boxShadow: [BoxShadow(
                                color: kAccent.withOpacity(0.6),
                                blurRadius: 6)])),
                  ],
                ]),
              ),
            ),
          );
        }),

        const Spacer(),
        const Divider(color: kBorder, height: 1, indent: 10, endIndent: 10),

        // User
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [kAccent2, kAccent2.withOpacity(0.5)]),
                border: Border.all(color: kAccent2.withOpacity(0.4)),
              ),
              child: const Center(child: Text('AW',
                  style: TextStyle(color: kTextPri, fontSize: 11,
                      fontWeight: FontWeight.bold)))),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Admin User',
                  style: TextStyle(color: kTextPri, fontSize: 13,
                      fontWeight: FontWeight.w600)),
              Text('Weather Analyst',
                  style: TextStyle(color: kTextSec, fontSize: 11)),
            ]),
          ]),
        ),
      ]),
    );
  }
}

////////////////////////////////////////////////////
/// TOP NAV BAR
////////////////////////////////////////////////////

class _TopNav extends StatefulWidget {
  final int pageIndex;
  const _TopNav({required this.pageIndex});
  @override
  State<_TopNav> createState() => _TopNavState();
}

class _TopNavState extends State<_TopNav> {
  late String _time;
  late String _date;

  @override
  void initState() {
    super.initState();
    _update();
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      _update();
      return true;
    });
  }

  void _update() {
    final n = DateTime.now();
    final months = ['Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'];
    final days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    setState(() {
      final h = n.hour > 12 ? n.hour - 12 : (n.hour == 0 ? 12 : n.hour);
      final ap = n.hour >= 12 ? 'PM' : 'AM';
      _time = '${h.toString().padLeft(2,'0')}:${n.minute.toString().padLeft(2,'0')}:${n.second.toString().padLeft(2,'0')} $ap';
      _date = '${days[n.weekday-1]}, ${months[n.month-1]} ${n.day}';
    });
  }

  final _titles = [
    'Dashboard Overview',
    'AI Prediction',
    'Weather Analytics',
    'AI Weather Chat',
    'Risk Alerts',
  ];

  final _subs = [
    'Real-time weather intelligence for Chennai',
    'ML-powered 7-day temperature forecast',
    'Historical trends & pattern analysis',
    'Ask anything about weather & disasters',
    'Anomaly detection & risk monitoring',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: kSurface.withOpacity(0.8),
        border: const Border(bottom: BorderSide(color: kBorder, width: 1)),
      ),
      child: Row(children: [
        Column(mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_titles[widget.pageIndex],
              style: const TextStyle(color: kTextPri, fontSize: 17,
                  fontWeight: FontWeight.w700, letterSpacing: -0.3)),
          Text(_subs[widget.pageIndex],
              style: TextStyle(color: kTextSec, fontSize: 12)),
        ]),
        const Spacer(),
        // Date
        Text(_date, style: TextStyle(color: kTextSec, fontSize: 12)),
        const SizedBox(width: 16),
        // Clock
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: kCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kBorder2)),
          child: Row(children: [
            Icon(Icons.access_time_rounded, color: kAccent, size: 12),
            const SizedBox(width: 6),
            Text(_time, style: const TextStyle(
                color: kTextPri, fontSize: 12, fontWeight: FontWeight.w600,
                letterSpacing: 0.5)),
          ]),
        ),
        const SizedBox(width: 10),
        // Live
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: kGreen.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kGreen.withOpacity(0.3)),
          ),
          child: Row(children: [
            Container(width: 5, height: 5,
                decoration: const BoxDecoration(
                    color: kGreen, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            const Text('LIVE', style: TextStyle(color: kGreen, fontSize: 10,
                fontWeight: FontWeight.w700, letterSpacing: 1.2)),
          ]),
        ),
      ]),
    );
  }
}

////////////////////////////////////////////////////
/// DASHBOARD PAGE
////////////////////////////////////////////////////

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  String _temp = '--';
  bool _isAnomaly = false;
  List<double>? _forecast;
  double _risk = 0;
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _load();
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  double _calcRisk(double t, bool a, List<double> fc) {
    double s = 0;
    if (a) s += 40;
    if (t >= 38) s += 25; else if (t >= 34) s += 10;
    final trend = fc.last - fc.first;
    if (trend > 3) s += 20; else if (trend > 1) s += 10;
    if (fc.reduce(math.max) >= 40) s += 15;
    return s.clamp(0, 100);
  }

  Future<void> _load() async {
    try {
      final r = await Future.wait([
        WeatherService.getAnomalyStatus(),
        WeatherService.get7DayForecast(),
      ]);
      if (!mounted) return;
      final a  = r[0] as Map<String, dynamic>;
      final fc = r[1] as List<double>;
      final t  = (a['current_temp_celsius'] as num).toDouble();
      setState(() {
        _temp = '${a['current_temp_celsius']}';
        _isAnomaly = a['is_anomaly'];
        _forecast  = fc;
        _risk = _calcRisk(t, a['is_anomaly'], fc);
      });
      _fadeCtrl.forward();
    } catch (_) {
      if (!mounted) return;
      setState(() => _temp = 'N/A');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── KPI Strip ────────────────────────────────────────────────
        Row(children: [
          _KpiCard('Temperature', '$_temp°C',
              Icons.thermostat_rounded, kAccent,
              sub: _isAnomaly ? '⚠ Anomaly' : '✓ Normal',
              subColor: _isAnomaly ? kRed : kGreen),
          const SizedBox(width: 16),
          _KpiCard('Humidity', '70%',
              Icons.water_drop_rounded, kAccent2, sub: '↑ 5% today'),
          const SizedBox(width: 16),
          _KpiCard('Wind Speed', '12 km/h',
              Icons.air_rounded, kOrange, sub: 'Stable'),
          const SizedBox(width: 16),
          _KpiCard('UV Index', '6 · High',
              Icons.wb_sunny_rounded, kRed, sub: 'Protection needed'),
          const SizedBox(width: 16),
          _KpiCard('Risk Score', '${_risk.toInt()}/100',
              Icons.shield_rounded,
              _risk >= 70 ? kRed : _risk >= 40 ? kOrange : kGreen,
              sub: _risk >= 70 ? 'HIGH RISK'
                  : _risk >= 40 ? 'MEDIUM' : 'LOW RISK',
              subColor: _risk >= 70 ? kRed
                  : _risk >= 40 ? kOrange : kGreen),
        ]),
        const SizedBox(height: 24),

        // ── Main grid row ─────────────────────────────────────────────
        FadeTransition(
          opacity: _fade,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Left: big chart
            Expanded(flex: 5, child: _Panel(
              title: '7-Day Temperature Forecast',
              subtitle: 'Random Forest ML Model',
              accent: kAccent,
              height: 320,
              child: _forecast == null
                  ? const Center(child: CircularProgressIndicator(color: kAccent))
                  : TemperatureLineChart(forecast: _forecast!),
            )),
            const SizedBox(width: 20),
            // Right: forecast cards + risk
            Expanded(flex: 2, child: Column(children: [
              _RiskGauge(score: _risk),
              const SizedBox(height: 16),
              _WeatherStatCard(isAnomaly: _isAnomaly, temp: _temp),
            ])),
          ]),
        ),
        const SizedBox(height: 20),

        // ── Forecast cards ────────────────────────────────────────────
        FadeTransition(
          opacity: _fade,
          child: _forecast == null
              ? const SizedBox()
              : _Panel(
                  title: 'Daily Breakdown',
                  subtitle: 'Scroll to see all 7 days',
                  accent: kAccent2,
                  child: ForecastRow(forecast: _forecast!)),
        ),
        const SizedBox(height: 20),

        // ── Alert strip ───────────────────────────────────────────────
        _AlertBanner(isAnomaly: _isAnomaly, temp: _temp),
      ]),
    );
  }
}

// ── KPI Card ──────────────────────────────────────────────────────────────────
class _KpiCard extends StatelessWidget {
  final String label, value, sub;
  final IconData icon;
  final Color color;
  final Color? subColor;
  const _KpiCard(this.label, this.value, this.icon, this.color,
      {required this.sub, this.subColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder2),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label, style: TextStyle(
                color: kTextSec, fontSize: 12, letterSpacing: 0.3)),
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 15)),
          ]),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(
              color: color, fontSize: 22,
              fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          const SizedBox(height: 6),
          Text(sub, style: TextStyle(
              color: subColor ?? kTextSec,
              fontSize: 11, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}

// ── Panel ─────────────────────────────────────────────────────────────────────
class _Panel extends StatelessWidget {
  final String title, subtitle;
  final Color accent;
  final Widget child;
  final double? height;
  const _Panel({required this.title, required this.subtitle,
      required this.accent, required this.child, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder2),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 4, height: 16,
              decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [BoxShadow(
                      color: accent.withOpacity(0.5), blurRadius: 8)])),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(
              color: kTextPri, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Text(subtitle, style: TextStyle(color: kTextSec, fontSize: 11)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: accent.withOpacity(0.2)),
            ),
            child: Text('Live', style: TextStyle(
                color: accent, fontSize: 10, fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 20),
        Expanded(child: child),
      ]),
    );
  }
}

// ── Risk Gauge ────────────────────────────────────────────────────────────────
class _RiskGauge extends StatefulWidget {
  final double score;
  const _RiskGauge({required this.score});
  @override
  State<_RiskGauge> createState() => _RiskGaugeState();
}

class _RiskGaugeState extends State<_RiskGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1800));
    _anim = Tween<double>(begin: 0, end: widget.score / 100)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Color get _c => widget.score >= 70 ? kRed
      : widget.score >= 40 ? kOrange : kGreen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCard, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder2),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Disaster Risk',
              style: TextStyle(color: kTextPri, fontSize: 14,
                  fontWeight: FontWeight.w700)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _c.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _c.withOpacity(0.3)),
            ),
            child: Text(
              widget.score >= 70 ? 'HIGH'
                  : widget.score >= 40 ? 'MED' : 'LOW',
              style: TextStyle(color: _c, fontSize: 10,
                  fontWeight: FontWeight.w800, letterSpacing: 1))),
        ]),
        const SizedBox(height: 16),
        AnimatedBuilder(
          animation: _anim,
          builder: (_, __) => SizedBox(
            height: 100,
            child: Stack(alignment: Alignment.center, children: [
              CustomPaint(
                size: const Size(double.infinity, 100),
                painter: _GaugePainter(_anim.value, _c)),
              Positioned(bottom: 4, child: Column(children: [
                Text('${(widget.score * _anim.value).toInt()}',
                    style: TextStyle(color: _c, fontSize: 30,
                        fontWeight: FontWeight.w900, height: 1)),
                Text('/100', style: TextStyle(
                    color: kTextSec, fontSize: 11)),
              ])),
            ]),
          ),
        ),
        const SizedBox(height: 14),
        _GaugeRow('Temperature', widget.score > 50 ? 'Elevated' : 'Normal',
            widget.score > 50 ? kOrange : kGreen),
        const SizedBox(height: 6),
        _GaugeRow('Anomaly', widget.score > 70 ? 'Detected' : 'Clear',
            widget.score > 70 ? kRed : kGreen),
        const SizedBox(height: 6),
        _GaugeRow('Trend', widget.score > 60 ? 'Rising' : 'Stable',
            widget.score > 60 ? kOrange : kGreen),
      ]),
    );
  }
}

class _GaugeRow extends StatelessWidget {
  final String l, v;
  final Color c;
  const _GaugeRow(this.l, this.v, this.c);
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(l, style: TextStyle(color: kTextSec, fontSize: 12)),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(color: c.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4)),
        child: Text(v, style: TextStyle(
            color: c, fontSize: 10, fontWeight: FontWeight.w600))),
    ]);
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  _GaugePainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height - 8.0;
    final r  = (size.width * 0.4).clamp(40.0, 120.0);

    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r),
        math.pi, math.pi, false,
        Paint()..color = kBorder2..style = PaintingStyle.stroke
            ..strokeWidth = 8..strokeCap = StrokeCap.round);

    if (progress > 0) {
      canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r),
          math.pi, math.pi * progress, false,
          Paint()
            ..shader = SweepGradient(
              startAngle: math.pi, endAngle: math.pi * 2,
              colors: [kGreen, kOrange, color],
            ).createShader(Rect.fromCircle(
                center: Offset(cx, cy), radius: r))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 8..strokeCap = StrokeCap.round);
    }

    if (progress > 0.01) {
      final ang = math.pi + math.pi * progress;
      final dx = cx + r * math.cos(ang);
      final dy = cy + r * math.sin(ang);
      canvas.drawCircle(Offset(dx, dy), 5,
          Paint()..color = color);
      canvas.drawCircle(Offset(dx, dy), 5,
          Paint()..color = color.withOpacity(0.3)
              ..style = PaintingStyle.stroke..strokeWidth = 3);
    }
  }

  @override
  bool shouldRepaint(_GaugePainter o) => o.progress != progress;
}

// ── Weather Stat Card ─────────────────────────────────────────────────────────
class _WeatherStatCard extends StatelessWidget {
  final bool isAnomaly;
  final String temp;
  const _WeatherStatCard({required this.isAnomaly, required this.temp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: isAnomaly
              ? [const Color(0xFF2A0808), const Color(0xFF160404)]
              : [const Color(0xFF031820), const Color(0xFF050E14)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: (isAnomaly ? kRed : kAccent).withOpacity(0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Current Status',
            style: TextStyle(color: kTextSec, fontSize: 11,
                letterSpacing: 0.5)),
        const SizedBox(height: 10),
        Row(children: [
          Text('$temp°C', style: TextStyle(
              color: isAnomaly ? kRed : kAccent,
              fontSize: 28, fontWeight: FontWeight.w800)),
          const Spacer(),
          Icon(isAnomaly ? Icons.warning_rounded : Icons.check_circle_rounded,
              color: isAnomaly ? kRed : kGreen, size: 22),
        ]),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: (isAnomaly ? kRed : kGreen).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: (isAnomaly ? kRed : kGreen).withOpacity(0.25)),
          ),
          child: Text(
            isAnomaly ? '⚠ Anomaly Detected' : '✓ Temperature Normal',
            style: TextStyle(
                color: isAnomaly ? kRed : kGreen,
                fontSize: 11, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 10),
        Text('Chennai, Tamil Nadu · India',
            style: TextStyle(color: kTextSec, fontSize: 10)),
      ]),
    );
  }
}

// ── Forecast Row ──────────────────────────────────────────────────────────────
class ForecastRow extends StatelessWidget {
  final List<double> forecast;
  const ForecastRow({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    const labels = ['Today','Tomorrow','Wed','Thu','Fri','Sat','Sun'];
    final icons  = forecast.map((t) {
      if (t >= 38) return Icons.wb_sunny_rounded;
      if (t >= 34) return Icons.wb_cloudy_rounded;
      if (t >= 30) return Icons.cloud_rounded;
      return Icons.water_rounded;
    }).toList();
    final colors = forecast.map((t) {
      if (t >= 38) return kRed;
      if (t >= 34) return kOrange;
      return kAccent;
    }).toList();

    return SizedBox(
      height: 115,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: forecast.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final isToday = i == 0;
          return _FCard(
            delay: i * 65,
            child: Container(
              width: 85,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
              decoration: BoxDecoration(
                gradient: isToday ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [kAccent.withOpacity(0.15),
                      kAccent.withOpacity(0.03)]) : null,
                color: isToday ? null : kCard2,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: isToday
                        ? kAccent.withOpacity(0.4) : kBorder2,
                    width: isToday ? 1.5 : 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(i < labels.length ? labels[i] : 'D${i+1}',
                      style: TextStyle(
                          color: isToday ? kAccent : kTextSec,
                          fontSize: 10,
                          fontWeight: isToday
                              ? FontWeight.w700 : FontWeight.normal)),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: colors[i].withOpacity(0.1),
                        shape: BoxShape.circle),
                    child: Icon(icons[i], color: colors[i], size: 20)),
                  Text('${forecast[i].toStringAsFixed(1)}°',
                      style: TextStyle(color: colors[i],
                          fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FCard extends StatefulWidget {
  final Widget child;
  final int delay;
  const _FCard({required this.child, required this.delay});
  @override
  State<_FCard> createState() => _FCardState();
}

class _FCardState extends State<_FCard> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 420));
    _fade  = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0,.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child));
}

// ── Alert Banner ──────────────────────────────────────────────────────────────
class _AlertBanner extends StatelessWidget {
  final bool isAnomaly;
  final String temp;
  const _AlertBanner({required this.isAnomaly, required this.temp});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCard, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder2),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 12),
          child: Row(children: [
            Container(width: 4, height: 16,
                decoration: BoxDecoration(
                    color: kOrange, borderRadius: BorderRadius.circular(2),
                    boxShadow: [BoxShadow(
                        color: kOrange.withOpacity(0.5), blurRadius: 8)])),
            const SizedBox(width: 10),
            const Text('Active Alerts',
                style: TextStyle(color: kTextPri, fontSize: 15,
                    fontWeight: FontWeight.w700)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: kOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: kOrange.withOpacity(0.3))),
              child: const Text('3 Active', style: TextStyle(
                  color: kOrange, fontSize: 10, fontWeight: FontWeight.w700))),
          ]),
        ),
        const Divider(color: kBorder, height: 1),
        _AlertRow2(
          color: isAnomaly ? kRed : kGreen,
          icon: isAnomaly ? Icons.thermostat_rounded : Icons.check_circle_rounded,
          title: isAnomaly ? 'Temperature Anomaly' : 'Temperature Normal',
          desc: isAnomaly
              ? 'Current ${temp}°C exceeds expected range for Chennai'
              : 'Current ${temp}°C is within the normal range',
          badge: isAnomaly ? 'CRITICAL' : 'NORMAL',
          time: 'Just now',
        ),
        const Divider(color: kBorder, height: 1, indent: 20, endIndent: 20),
        const _AlertRow2(
          color: kOrange, icon: Icons.water_drop_rounded,
          title: 'Elevated Humidity',
          desc: 'Humidity at 70% — above 65% threshold, rainfall possible',
          badge: 'MEDIUM', time: '5m ago',
        ),
        const Divider(color: kBorder, height: 1, indent: 20, endIndent: 20),
        const _AlertRow2(
          color: kAccent2, icon: Icons.air_rounded,
          title: 'Wind Stable',
          desc: 'Wind speed at 12 km/h — no storm warnings active',
          badge: 'INFO', time: '12m ago',
        ),
        const SizedBox(height: 8),
      ]),
    );
  }
}

class _AlertRow2 extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title, desc, badge, time;
  const _AlertRow2({required this.color, required this.icon,
      required this.title, required this.desc,
      required this.badge, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      child: Row(children: [
        Container(width: 38, height: 38,
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18)),
        const SizedBox(width: 14),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(title, style: const TextStyle(
                color: kTextPri, fontSize: 13, fontWeight: FontWeight.w600)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4)),
              child: Text(badge, style: TextStyle(
                  color: color, fontSize: 9,
                  fontWeight: FontWeight.w800, letterSpacing: 0.8))),
          ]),
          const SizedBox(height: 3),
          Row(children: [
            Expanded(child: Text(desc,
                style: TextStyle(color: kTextSec, fontSize: 12))),
            Text(time, style: TextStyle(
                color: kTextSec.withOpacity(0.6), fontSize: 10)),
          ]),
        ])),
      ]),
    );
  }
}

////////////////////////////////////////////////////
/// ANALYTICS PAGE  — data-heavy layout
////////////////////////////////////////////////////

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});
  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  List<double>? _forecast;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final d = await WeatherService.get7DayForecast();
      if (!mounted) return;
      setState(() { _forecast = d; _loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(children: [
        // Stat row
        Row(children: [
          _StatTile('Max Forecast',
              _forecast == null ? '--'
                  : '${_forecast!.reduce(math.max).toStringAsFixed(1)}°C',
              kRed),
          const SizedBox(width: 14),
          _StatTile('Min Forecast',
              _forecast == null ? '--'
                  : '${_forecast!.reduce(math.min).toStringAsFixed(1)}°C',
              kAccent),
          const SizedBox(width: 14),
          _StatTile('Avg Forecast',
              _forecast == null ? '--'
                  : '${(_forecast!.reduce((a,b)=>a+b)/_forecast!.length).toStringAsFixed(1)}°C',
              kAccent2),
          const SizedBox(width: 14),
          _StatTile('Trend',
              _forecast == null ? '--'
                  : _forecast!.last > _forecast!.first ? '↑ Rising' : '↓ Falling',
              kOrange),
        ]),
        const SizedBox(height: 22),

        // Big temperature chart
        _Panel(
          title: 'Temperature Forecast Curve',
          subtitle: 'Random Forest Ensemble · 7 days',
          accent: kAccent,
          height: 300,
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: kAccent))
              : TemperatureLineChart(forecast: _forecast ?? []),
        ),
        const SizedBox(height: 22),

        // 2-col charts
        Row(children: [
          Expanded(child: _Panel(
            title: 'Rainfall Probability',
            subtitle: 'Historical weekly pattern',
            accent: kAccent2,
            height: 240,
            child: _RainfallBarChart(),
          )),
          const SizedBox(width: 20),
          Expanded(child: _Panel(
            title: 'Humidity Levels',
            subtitle: '7-day trend',
            accent: kOrange,
            height: 240,
            child: _HumidityLineChart(),
          )),
        ]),
        const SizedBox(height: 22),

        // Forecast cards
        if (_forecast != null) Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: kCard, borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kBorder2)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 4, height: 16,
                  decoration: BoxDecoration(color: kAccent3,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [BoxShadow(
                          color: kAccent3.withOpacity(0.5), blurRadius: 8)])),
              const SizedBox(width: 10),
              const Text('Daily Forecast Cards',
                  style: TextStyle(color: kTextPri, fontSize: 15,
                      fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 16),
            ForecastRow(forecast: _forecast!),
          ]),
        ),
      ]),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatTile(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: kCard, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder2),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: kTextSec, fontSize: 12)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(
              color: color, fontSize: 22,
              fontWeight: FontWeight.w800)),
        ]),
      ),
    );
  }
}

////////////////////////////////////////////////////
/// CHARTS
////////////////////////////////////////////////////

class TemperatureLineChart extends StatelessWidget {
  final List<double> forecast;
  const TemperatureLineChart({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    if (forecast.isEmpty) return const SizedBox();
    final spots = forecast.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value)).toList();
    final minY = forecast.reduce((a, b) => a < b ? a : b) - 2;
    final maxY = forecast.reduce((a, b) => a > b ? a : b) + 2;

    return LineChart(LineChartData(
      minY: minY, maxY: maxY,
      gridData: FlGridData(show: true, drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: kBorder2, strokeWidth: 1)),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (v, _) {
            const d = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
            final i = v.toInt();
            if (i < 0 || i >= d.length) return const SizedBox();
            return Padding(padding: const EdgeInsets.only(top: 8),
                child: Text(d[i], style: TextStyle(
                    color: kTextSec, fontSize: 11)));
          },
        )),
        leftTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true, reservedSize: 40,
          getTitlesWidget: (v, _) => Text('${v.toInt()}°',
              style: TextStyle(color: kTextSec, fontSize: 10)),
        )),
        topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (s) => s.map((sp) => LineTooltipItem(
            '${sp.y.toStringAsFixed(1)}°C',
            const TextStyle(color: kBg,
                fontWeight: FontWeight.bold, fontSize: 12))).toList(),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          isCurved: true, curveSmoothness: 0.35,
          spots: spots, barWidth: 2.5, color: kAccent,
          dotData: FlDotData(show: true,
            getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 3.5, color: kBg,
                strokeWidth: 2, strokeColor: kAccent)),
          belowBarData: BarAreaData(show: true,
            gradient: LinearGradient(
              colors: [kAccent.withOpacity(0.2), kAccent.withOpacity(0.0)],
              begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        ),
      ],
    ));
  }
}

class _RainfallBarChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BarChart(BarChartData(
      borderData: FlBorderData(show: false),
      gridData: FlGridData(show: true, drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: kBorder2, strokeWidth: 1)),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (v, _) {
            const d = ['M','T','W','T','F'];
            final i = v.toInt();
            if (i < 0 || i >= d.length) return const SizedBox();
            return Padding(padding: const EdgeInsets.only(top: 5),
                child: Text(d[i], style: TextStyle(
                    color: kTextSec, fontSize: 10)));
          },
        )),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      barGroups: List.generate(5, (i) {
        final vals = [3.0, 5.0, 2.0, 6.0, 4.0];
        return BarChartGroupData(x: i, barRods: [
          BarChartRodData(
            toY: vals[i],
            gradient: LinearGradient(
              colors: [kAccent2, kAccent2.withOpacity(0.4)],
              begin: Alignment.topCenter, end: Alignment.bottomCenter),
            width: 18, borderRadius: BorderRadius.circular(4)),
        ]);
      }),
    ));
  }
}

class _HumidityLineChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LineChart(LineChartData(
      gridData: FlGridData(show: true, drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: kBorder2, strokeWidth: 1)),
      borderData: FlBorderData(show: false),
      titlesData: const FlTitlesData(show: false),
      lineBarsData: [
        LineChartBarData(
          isCurved: true, color: kOrange,
          spots: const [FlSpot(0,60),FlSpot(1,62),FlSpot(2,65),
            FlSpot(3,68),FlSpot(4,70),FlSpot(5,72),FlSpot(6,69)],
          barWidth: 2.5,
          dotData: FlDotData(show: true,
            getDotPainter: (_,__,___,____) => FlDotCirclePainter(
                radius: 3, color: kBg,
                strokeWidth: 2, strokeColor: kOrange)),
          belowBarData: BarAreaData(show: true,
            gradient: LinearGradient(
              colors: [kOrange.withOpacity(0.2), kOrange.withOpacity(0.0)],
              begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        ),
      ],
    ));
  }
}

////////////////////////////////////////////////////
/// CHAT PAGE — full screen Slack-style
////////////////////////////////////////////////////

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();
  bool _typing  = false;

  List<Map<String, String>> _msgs = [
    {"role": "ai", "text":
      "👋 Hello! I'm WeatherAI, powered by LLaMA 3.3 70B.\n\n"
      "I analyze Chennai's real-time ML forecast and can:\n"
      "• Detect disaster risks (floods, cyclones, heatwaves)\n"
      "• Answer weather questions\n"
      "• Explain anomalies\n\n"
      "What would you like to know?"}
  ];

  final _suggestions = [
    'Will it flood this week?',
    'Is there a heatwave risk?',
    'Explain the temperature forecast',
    'Compare with historical disasters',
  ];

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut);
    });
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty || _typing) return;
    _ctrl.clear();
    setState(() {
      _msgs.add({"role": "user", "text": text.trim()});
      _typing = true;
    });
    _scrollToBottom();
    try {
      final r = await WeatherService.sendChatMessage(text.trim());
      if (!mounted) return;
      setState(() { _msgs.add({"role": "ai", "text": r}); _typing = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _msgs.add({"role": "ai",
            "text": "⚠️ Backend unreachable. Make sure uvicorn is running."});
        _typing = false;
      });
    }
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      // Chat area
      Expanded(
        flex: 3,
        child: Column(children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(28),
              itemCount: _msgs.length + (_typing ? 1 : 0),
              itemBuilder: (_, i) {
                if (_typing && i == _msgs.length) {
                  return _AIBubble(
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const SizedBox(width: 36, height: 10,
                          child: _TypingDots()),
                      const SizedBox(width: 8),
                      Text('Analyzing forecast...',
                          style: TextStyle(
                              color: kTextSec, fontSize: 12)),
                    ]),
                  );
                }
                final m = _msgs[i];
                final isUser = m['role'] == 'user';
                return isUser
                    ? _UserBubble(text: m['text']!)
                    : _AIBubble(child: _FormattedAIText(text: m['text']!));
              },
            ),
          ),

          // Suggestions (only show if few messages)
          if (_msgs.length <= 2)
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 10),
              child: Wrap(spacing: 8, runSpacing: 8,
                children: _suggestions.map((s) => GestureDetector(
                  onTap: () => _send(s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: kCard2,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kBorder2),
                    ),
                    child: Text(s, style: TextStyle(
                        color: kTextMid, fontSize: 12))),
                )).toList()),
            ),

          // Input
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kSurface,
              border: const Border(top: BorderSide(color: kBorder)),
            ),
            child: Row(children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: kCard, borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kBorder2),
                  ),
                  child: TextField(
                    controller: _ctrl,
                    style: const TextStyle(color: kTextPri, fontSize: 14),
                    maxLines: null,
                    onSubmitted: _send,
                    decoration: const InputDecoration(
                      hintText: 'Ask about floods, heatwaves, forecasts...',
                      hintStyle: TextStyle(color: kTextSec, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _send(_ctrl.text),
                child: Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [kAccent, Color(0xFF00B894)]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(
                        color: kAccent.withOpacity(0.3), blurRadius: 12)],
                  ),
                  child: const Icon(Icons.send_rounded,
                      color: kBg, size: 20)),
              ),
            ]),
          ),
        ]),
      ),

      // Right info panel
      Container(
        width: 260,
        decoration: BoxDecoration(
          color: kSurface,
          border: const Border(left: BorderSide(color: kBorder)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('AI Capabilities',
              style: TextStyle(color: kTextPri, fontSize: 14,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          ...[
            (Icons.flood_rounded,      kAccent,  'Flood Risk Analysis'),
            (Icons.thermostat_rounded, kRed,     'Heatwave Detection'),
            (Icons.cyclone_rounded,    kAccent2, 'Cyclone Assessment'),
            (Icons.bolt_rounded,       kOrange,  'Storm Prediction'),
            (Icons.history_rounded,    kGreen,   'Historical Comparison'),
          ].map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              Container(width: 32, height: 32,
                  decoration: BoxDecoration(
                      color: c.$2.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(c.$1, color: c.$2, size: 16)),
              const SizedBox(width: 10),
              Text(c.$3, style: TextStyle(
                  color: kTextMid, fontSize: 13)),
            ]),
          )),
          const Divider(color: kBorder, height: 24),
          Text('Powered By',
              style: TextStyle(color: kTextSec, fontSize: 11,
                  letterSpacing: 0.8)),
          const SizedBox(height: 10),
          _TechBadge('LLaMA 3.3 70B', kAccent2),
          const SizedBox(height: 6),
          _TechBadge('Random Forest ML', kAccent),
          const SizedBox(height: 6),
          _TechBadge('Isolation Forest', kOrange),
          const SizedBox(height: 6),
          _TechBadge('Groq API', kGreen),
        ]),
      ),
    ]);
  }
}

class _TechBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _TechBadge(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.07),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withOpacity(0.2))),
    child: Text(label, style: TextStyle(
        color: color, fontSize: 11, fontWeight: FontWeight.w600)));
}

class _UserBubble extends StatelessWidget {
  final String text;
  const _UserBubble({required this.text});
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerRight,
    child: Container(
      margin: const EdgeInsets.only(bottom: 14, left: 80),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [kAccent, Color(0xFF00B894)]),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16), topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16), bottomRight: Radius.circular(4)),
      ),
      child: Text(text, style: const TextStyle(
          color: kBg, fontSize: 14, height: 1.5))),
  );
}

class _AIBubble extends StatelessWidget {
  final Widget child;
  const _AIBubble({required this.child});
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Row(crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 32, height: 32, margin: const EdgeInsets.only(right: 10, top: 2),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [kAccent, kAccent2]),
          borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.smart_toy_rounded,
            color: Colors.white, size: 16)),
      Flexible(child: Container(
        margin: const EdgeInsets.only(bottom: 14, right: 80),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kCard2, borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4), topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16)),
          border: Border.all(color: kBorder2)),
        child: child)),
    ]),
  );
}

class _FormattedAIText extends StatelessWidget {
  final String text;
  const _FormattedAIText({required this.text});
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          color: kTextPri, fontSize: 14, height: 1.6));
}

////////////////////////////////////////////////////
/// ALERTS PAGE — timeline style
////////////////////////////////////////////////////

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});
  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  Map<String, dynamic>? _anomaly;
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = null; });
    try {
      final d = await WeatherService.getAnomalyStatus();
      if (!mounted) return;
      setState(() { _anomaly = d; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(
        child: CircularProgressIndicator(color: kAccent));
    if (_error != null) return Center(child: Column(
        mainAxisSize: MainAxisSize.min, children: [
      Container(width: 70, height: 70,
          decoration: BoxDecoration(
              color: kRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kRed.withOpacity(0.3))),
          child: const Icon(Icons.wifi_off_rounded, color: kRed, size: 30)),
      const SizedBox(height: 16),
      const Text('Backend unreachable',
          style: TextStyle(color: kTextPri, fontSize: 16,
              fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: kAccent, foregroundColor: kBg),
          onPressed: _load, child: const Text('Retry')),
    ]));

    final isAnomaly = _anomaly!['is_anomaly'] as bool;
    final temp      = '${_anomaly!['current_temp_celsius']}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Timeline
        Expanded(flex: 3, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Alert Timeline',
                style: TextStyle(color: kTextPri, fontSize: 18,
                    fontWeight: FontWeight.w800)),
            Row(children: [
              _FilterChip('All', kAccent, true),
              const SizedBox(width: 8),
              _FilterChip('Critical', kRed, false),
              const SizedBox(width: 8),
              _FilterChip('Medium', kOrange, false),
            ]),
          ]),
          const SizedBox(height: 22),
          _TimelineAlert(
            color: isAnomaly ? kRed : kGreen,
            icon: isAnomaly ? Icons.warning_rounded : Icons.check_circle_rounded,
            level: isAnomaly ? 'CRITICAL' : 'NORMAL',
            title: isAnomaly ? 'Temperature Anomaly Detected'
                : 'All Systems Normal',
            desc: 'ML Model: Current temperature ${temp}°C — '
                '${isAnomaly ? "exceeds expected range" : "within normal parameters"}',
            source: 'Isolation Forest Model',
            time: 'Just now',
            isFirst: true,
          ),
          _TimelineAlert(
            color: kOrange,
            icon: Icons.water_drop_rounded,
            level: 'MEDIUM',
            title: 'Elevated Humidity Warning',
            desc: 'Humidity levels at 70%, above the 65% safety threshold. '
                'Increased rainfall probability for the next 24 hours.',
            source: 'OpenWeather API',
            time: '5 minutes ago',
          ),
          _TimelineAlert(
            color: kAccent2,
            icon: Icons.cloud_rounded,
            level: 'LOW',
            title: 'Rainfall Probability Increase',
            desc: 'Based on humidity trend analysis, there is a moderate '
                'chance of rainfall tomorrow afternoon.',
            source: 'Humidity Analysis',
            time: '12 minutes ago',
          ),
          _TimelineAlert(
            color: kGreen,
            icon: Icons.air_rounded,
            level: 'INFO',
            title: 'Wind Conditions Stable',
            desc: 'Wind speed at 12 km/h. No cyclone or storm warnings '
                'active for Chennai region.',
            source: 'Weather Station',
            time: '18 minutes ago',
            isLast: true,
          ),
        ])),
        const SizedBox(width: 24),

        // Right panel — summary
        SizedBox(width: 280, child: Column(children: [
          _SummaryCard(isAnomaly: isAnomaly, temp: temp),
          const SizedBox(height: 16),
          _SourcesCard(),
        ])),
      ]),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool active;
  const _FilterChip(this.label, this.color, this.active);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: active ? color.withOpacity(0.12) : kCard,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
          color: active ? color.withOpacity(0.4) : kBorder2)),
    child: Text(label, style: TextStyle(
        color: active ? color : kTextSec,
        fontSize: 11, fontWeight: FontWeight.w600)));
}

class _TimelineAlert extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String level, title, desc, source, time;
  final bool isFirst, isLast;
  const _TimelineAlert({
    required this.color, required this.icon,
    required this.level, required this.title,
    required this.desc, required this.source, required this.time,
    this.isFirst = false, this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Timeline spine
      SizedBox(width: 50, child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Icon(icon, color: color, size: 18)),
        if (!isLast) Container(
          width: 2, height: 60,
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [color.withOpacity(0.3), Colors.transparent]),
            borderRadius: BorderRadius.circular(1))),
      ])),

      // Content
      Expanded(child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isFirst
              ? color.withOpacity(0.3) : kBorder2),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4)),
              child: Text(level, style: TextStyle(
                  color: color, fontSize: 9,
                  fontWeight: FontWeight.w800, letterSpacing: 1))),
            const Spacer(),
            Text(time, style: TextStyle(
                color: kTextSec, fontSize: 11)),
          ]),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(
              color: kTextPri, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(desc, style: TextStyle(
              color: kTextSec, fontSize: 12, height: 1.5)),
          const SizedBox(height: 8),
          Row(children: [
            Icon(Icons.source_rounded, color: kTextSec, size: 11),
            const SizedBox(width: 4),
            Text(source, style: TextStyle(
                color: kTextSec, fontSize: 10)),
          ]),
        ]),
      )),
    ]);
  }
}

class _SummaryCard extends StatelessWidget {
  final bool isAnomaly;
  final String temp;
  const _SummaryCard({required this.isAnomaly, required this.temp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCard, borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: (isAnomaly ? kRed : kGreen).withOpacity(0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(isAnomaly ? Icons.warning_rounded : Icons.verified_rounded,
              color: isAnomaly ? kRed : kGreen, size: 20),
          const SizedBox(width: 8),
          Text(isAnomaly ? 'Anomaly Active' : 'Status Normal',
              style: TextStyle(
                  color: isAnomaly ? kRed : kGreen,
                  fontSize: 14, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 14),
        Text('$temp°C', style: TextStyle(
            color: isAnomaly ? kRed : kAccent,
            fontSize: 32, fontWeight: FontWeight.w900)),
        Text('Current Temperature',
            style: TextStyle(color: kTextSec, fontSize: 11)),
        const SizedBox(height: 14),
        const Divider(color: kBorder),
        const SizedBox(height: 10),
        _SumRow('Model', 'Isolation Forest'),
        const SizedBox(height: 6),
        _SumRow('City', 'Chennai, TN'),
        const SizedBox(height: 6),
        _SumRow('Updated', 'Just now'),
      ]),
    );
  }
}

class _SumRow extends StatelessWidget {
  final String l, v;
  const _SumRow(this.l, this.v);
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(l, style: TextStyle(color: kTextSec, fontSize: 12)),
      Text(v, style: TextStyle(
          color: kTextMid, fontSize: 12, fontWeight: FontWeight.w500)),
    ]);
}

class _SourcesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kCard, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder2)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Data Sources',
            style: TextStyle(color: kTextPri, fontSize: 13,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...[
          ('ML Models', '.pkl files', kAccent),
          ('OpenWeather', 'Real-time API', kGreen),
          ('Groq AI', 'LLaMA 3.3 70B', kAccent2),
        ].map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            Container(width: 6, height: 6,
                decoration: BoxDecoration(
                    color: s.$3, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(s.$1, style: TextStyle(
                color: kTextMid, fontSize: 12,
                fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(s.$2, style: TextStyle(
                color: kTextSec, fontSize: 11)),
          ]),
        )),
      ]),
    );
  }
}

////////////////////////////////////////////////////
/// TYPING DOTS
////////////////////////////////////////////////////

class _TypingDots extends StatefulWidget {
  const _TypingDots();
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 900))..repeat();
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, __) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final o = ((_c.value * 3 - i) % 1.0).clamp(0.2, 1.0);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 6, height: 6,
          decoration: BoxDecoration(
              color: kAccent.withOpacity(o),
              shape: BoxShape.circle));
      }),
    ),
  );
}