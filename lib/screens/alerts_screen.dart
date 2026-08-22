import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/alert_model.dart';
import '../providers/news_provider.dart';

// Emergency Alerts screen: lists all active alerts, most severe first.
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  Color _severityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return Colors.red.shade700;
      case AlertSeverity.medium:
        return Colors.orange.shade700;
      case AlertSeverity.low:
        return Colors.amber.shade700;
    }
  }

  String _severityLabel(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return 'CRITICAL';
      case AlertSeverity.medium:
        return 'MEDIUM';
      case AlertSeverity.low:
        return 'LOW';
    }
  }

  @override
  Widget build(BuildContext context) {
    final news = context.watch<NewsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Alerts')),
      body: news.alerts.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No active emergency alerts right now.\nStay safe!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: news.alerts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final alert = news.alerts[index];
                final color = _severityColor(alert.severity);
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: color.withValues(alpha: 0.4)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _severityLabel(alert.severity),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(alert.area,
                                  style: TextStyle(
                                      color: Colors.grey.shade600, fontSize: 12)),
                            ),
                            Text(
                              timeago.format(alert.timestamp),
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(alert.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(alert.description),
                        const SizedBox(height: 6),
                        Text('Posted by ${alert.postedByName}',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
