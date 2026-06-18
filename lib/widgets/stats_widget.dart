import 'package:flutter/material.dart';

import '../models/publication_stats.dart';
import '../services/api_service.dart';

class StatsWidget extends StatefulWidget {
  const StatsWidget({super.key, required this.apiService});

  final ApiService apiService;

  @override
  State<StatsWidget> createState() => _StatsWidgetState();
}

class _StatsWidgetState extends State<StatsWidget> {
  PublicationStats? _stats;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final stats = await widget.apiService.fetchMyStats();
      if (!mounted) return;
      setState(() {
        _stats = stats;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: _loadStats, child: const Text('Reintentar')),
        ],
      );
    }

    final stats = _stats!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Dashboard de Publicaciones',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Resumen de oportunidades activas y cerradas',
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _StatCard(label: 'Activas', value: stats.active, color: const Color(0xFF10B981))),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(label: 'Cerradas', value: stats.closed, color: const Color(0xFFEF4444))),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _PieChart(active: stats.active, closed: stats.closed),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Por tipo', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _TypeRow(label: 'Becas', value: stats.byType['scholarship'] ?? 0, color: const Color(0xFF3B82F6)),
                    _TypeRow(label: 'Estancias', value: stats.byType['internship'] ?? 0, color: const Color(0xFF10B981)),
                    _TypeRow(label: 'Proyectos', value: stats.byType['project'] ?? 0, color: const Color(0xFFF59E0B)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
          ),
          Text(label, style: const TextStyle(color: Color(0xFF6B7280))),
        ],
      ),
    );
  }
}

class _TypeRow extends StatelessWidget {
  const _TypeRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text('$value', style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _PieChart extends StatelessWidget {
  const _PieChart({required this.active, required this.closed});

  final int active;
  final int closed;

  @override
  Widget build(BuildContext context) {
    final total = active + closed;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 120,
            width: 120,
            child: CustomPaint(
              painter: _PieChartPainter(active: active, closed: closed),
              child: Center(
                child: Text(
                  '$total',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Total publicaciones'),
        ],
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  _PieChartPainter({required this.active, required this.closed});

  final int active;
  final int closed;

  @override
  void paint(Canvas canvas, Size size) {
    final total = active + closed;
    if (total == 0) {
      final paint = Paint()
        ..color = const Color(0xFFE5E7EB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2 - 8),
        0,
        6.28318,
        false,
        paint,
      );
      return;
    }

    final rect = Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2 - 8);
    var startAngle = -1.5708;

    if (active > 0) {
      final sweep = (active / total) * 6.28318;
      final paint = Paint()
        ..color = const Color(0xFF10B981)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }

    if (closed > 0) {
      final sweep = (closed / total) * 6.28318;
      final paint = Paint()
        ..color = const Color(0xFFEF4444)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.active != active || oldDelegate.closed != closed;
  }
}
