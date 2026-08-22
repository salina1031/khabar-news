import 'package:flutter/material.dart';
import '../models/alert_model.dart';

// Pinned red banner shown at the top of the Home feed when there is an
// active emergency alert. Tapping it opens the full Alerts screen.
class AlertBanner extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback onTap;

  const AlertBanner({super.key, required this.alert, required this.onTap});

  Color _severityColor() {
    switch (alert.severity) {
      case AlertSeverity.critical:
        return Colors.red.shade700;
      case AlertSeverity.medium:
        return Colors.orange.shade700;
      case AlertSeverity.low:
        return Colors.amber.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: _severityColor(),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${alert.area} • Tap for details',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
