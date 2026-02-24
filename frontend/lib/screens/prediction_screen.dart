// lib/screens/prediction_screen.dart

import 'package:flutter/material.dart';
import '../services/weather_service.dart';

const kBg       = Color(0xFF050D1A);
const kSurface  = Color(0xFF0D1F35);
const kCard     = Color(0xFF102040);
const kAccent   = Color(0xFF00D4FF);
const kAccent2  = Color(0xFF7C3AED);
const kGreen    = Color(0xFF10B981);
const kOrange   = Color(0xFFF59E0B);
const kRed      = Color(0xFFEF4444);
const kTextPri  = Color(0xFFE2E8F0);
const kTextSec  = Color(0xFF64748B);
const kBorder   = Color(0xFF1E3A5F);

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});
  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  List<double>? _forecast;
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _loadForecast(); }

  Future<void> _loadForecast() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = null; });
    try {
      final data = await WeatherService.get7DayForecast();
      if (!mounted) return;
      setState(() { _forecast = data; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  String _buildExplanation() {
    if (_forecast == null) return '';
    final max = _forecast!.reduce((a, b) => a > b ? a : b);
    final min = _forecast!.reduce((a, b) => a < b ? a : b);
    final trend = _forecast!.last > _forecast!.first ? 'rising' : 'falling';
    return 'The Random Forest ensemble model predicts temperatures ranging from '
        '${min.toStringAsFixed(1)}°C to ${max.toStringAsFixed(1)}°C over the next 7 days, '
        'with a generally $trend trend. Trained on Chennai\'s historical data from 1990–2022.';
  }

  @override
  Widget build(BuildContext context) {
    final days = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];

    return Column(
      children: [
        // Top bar
        Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: kBorder, width: 1)),
          ),
          child: Row(children: [
            const Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('AI Prediction', style: TextStyle(color: kTextPri, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
              Text('Machine Learning Forecast', style: TextStyle(color: kTextSec, fontSize: 13)),
            ]),
            const Spacer(),
            GestureDetector(
              onTap: _loadForecast,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kBorder),
                ),
                child: const Row(children: [
                  Icon(Icons.refresh_rounded, color: kAccent, size: 15),
                  SizedBox(width: 6),
                  Text('Refresh', style: TextStyle(color: kAccent, fontSize: 13)),
                ]),
              ),
            ),
          ]),
        ),

        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: kAccent))
              : _error != null
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.wifi_off_rounded, color: kRed, size: 48),
                      const SizedBox(height: 12),
                      const Text('Backend not reachable', style: TextStyle(color: kTextPri, fontSize: 16)),
                      const SizedBox(height: 6),
                      const Text('Make sure uvicorn is running', style: TextStyle(color: kTextSec, fontSize: 13)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: kAccent, foregroundColor: kBg),
                        onPressed: _loadForecast,
                        child: const Text('Retry'),
                      ),
                    ]))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(children: [
                        const SizedBox(height: 24),

                        // 7-day forecast list
                        Container(
                          decoration: BoxDecoration(
                            color: kCard,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: kBorder),
                          ),
                          child: Column(children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(children: [
                                Container(
                                  width: 34, height: 34,
                                  decoration: BoxDecoration(
                                    color: kAccent.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: const Icon(Icons.calendar_today_rounded, color: kAccent, size: 16),
                                ),
                                const SizedBox(width: 12),
                                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('7-Day Forecast', style: TextStyle(color: kTextPri, fontSize: 16, fontWeight: FontWeight.w600)),
                                  Text('Predicted temperatures', style: TextStyle(color: kTextSec, fontSize: 12)),
                                ]),
                              ]),
                            ),
                            const Divider(color: kBorder, height: 1),
                            ...(_forecast ?? []).asMap().entries.map((e) {
                              final temp = e.value;
                              Color tempColor = kGreen;
                              if (temp >= 38) tempColor = kRed;
                              else if (temp >= 34) tempColor = kOrange;

                              final isLast = e.key == (_forecast!.length - 1);
                              return Column(children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                  child: Row(children: [
                                    // Day label
                                    SizedBox(
                                      width: 90,
                                      child: Text(
                                        e.key == 0 ? 'Today' : e.key == 1 ? 'Tomorrow' : days[e.key],
                                        style: TextStyle(
                                          color: e.key == 0 ? kAccent : kTextSec,
                                          fontSize: 14,
                                          fontWeight: e.key == 0 ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    // Temp bar
                                    Expanded(
                                      child: Stack(children: [
                                        Container(height: 6, decoration: BoxDecoration(
                                          color: kBorder, borderRadius: BorderRadius.circular(3))),
                                        FractionallySizedBox(
                                          widthFactor: ((temp - 25) / 20).clamp(0.1, 1.0),
                                          child: Container(height: 6, decoration: BoxDecoration(
                                            gradient: LinearGradient(colors: [tempColor.withOpacity(0.6), tempColor]),
                                            borderRadius: BorderRadius.circular(3),
                                          )),
                                        ),
                                      ]),
                                    ),
                                    const SizedBox(width: 16),
                                    // Temp value
                                    Text('${temp.toStringAsFixed(1)}°C',
                                        style: TextStyle(color: tempColor, fontSize: 16, fontWeight: FontWeight.w700)),
                                  ]),
                                ),
                                if (!isLast) const Divider(color: kBorder, height: 1, indent: 20, endIndent: 20),
                              ]);
                            }),
                            const SizedBox(height: 8),
                          ]),
                        ),

                        const SizedBox(height: 20),

                        // AI Explanation card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: kCard,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: kAccent.withOpacity(0.2)),
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Container(
                                width: 34, height: 34,
                                decoration: BoxDecoration(
                                  color: kAccent2.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: const Icon(Icons.psychology_rounded, color: kAccent2, size: 18),
                              ),
                              const SizedBox(width: 12),
                              const Text('Model Explanation', style: TextStyle(color: kTextPri, fontSize: 16, fontWeight: FontWeight.w600)),
                            ]),
                            const SizedBox(height: 14),
                            Text(_buildExplanation(),
                                style: const TextStyle(color: kTextSec, fontSize: 14, height: 1.7)),
                          ]),
                        ),
                      ]),
                    ),
        ),
      ],
    );
  }
}

class _ModelBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _ModelBadge(this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}