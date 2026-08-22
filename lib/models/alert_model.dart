import 'package:cloud_firestore/cloud_firestore.dart';

// Severity levels for an emergency alert, ordered low -> critical.
enum AlertSeverity { low, medium, critical }

AlertSeverity severityFromString(String value) {
  switch (value) {
    case 'critical':
      return AlertSeverity.critical;
    case 'medium':
      return AlertSeverity.medium;
    default:
      return AlertSeverity.low;
  }
}

String severityToString(AlertSeverity severity) {
  switch (severity) {
    case AlertSeverity.critical:
      return 'critical';
    case AlertSeverity.medium:
      return 'medium';
    case AlertSeverity.low:
      return 'low';
  }
}

// AlertModel - an emergency alert (flood, fire, power outage, etc.)
class AlertModel {
  final String id;
  final String title;
  final String description;
  final AlertSeverity severity;
  final String area;
  final String postedByName;
  final DateTime timestamp;
  final bool isActive;

  AlertModel({
    required this.id,
    required this.title,
    required this.description,
    this.severity = AlertSeverity.low,
    this.area = 'Birtamode',
    this.postedByName = 'Admin',
    required this.timestamp,
    this.isActive = true,
  });

  factory AlertModel.fromMap(Map<String, dynamic> map, String id) {
    return AlertModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      severity: severityFromString(map['severity'] ?? 'low'),
      area: map['area'] ?? 'Birtamode',
      postedByName: map['postedByName'] ?? 'Admin',
      timestamp: map['postedAt'] is Timestamp
          ? (map['postedAt'] as Timestamp).toDate()
          : DateTime.now(),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'severity': severityToString(severity),
      'area': area,
      'postedByName': postedByName,
      'postedAt': Timestamp.fromDate(timestamp),
      'isActive': isActive,
    };
  }
}
