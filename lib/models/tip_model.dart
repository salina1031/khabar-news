import 'package:cloud_firestore/cloud_firestore.dart';

// Status of a community news tip as it moves through moderation.
enum TipStatus { pending, approved, rejected }

TipStatus tipStatusFromString(String value) {
  switch (value) {
    case 'approved':
      return TipStatus.approved;
    case 'rejected':
      return TipStatus.rejected;
    default:
      return TipStatus.pending;
  }
}

String tipStatusToString(TipStatus status) {
  switch (status) {
    case TipStatus.approved:
      return 'approved';
    case TipStatus.rejected:
      return 'rejected';
    case TipStatus.pending:
      return 'pending';
  }
}

// TipModel - a news tip submitted by a resident, reviewed by an admin.
class TipModel {
  final String id;
  final String userId;
  final String title;
  final String location;
  final String description;
  final String imageUrl;
  final String submittedByName;
  final String contactPhone;
  final TipStatus status;
  final DateTime timestamp;

  TipModel({
    required this.id,
    required this.userId,
    required this.title,
    this.location = '',
    required this.description,
    this.imageUrl = '',
    this.submittedByName = '',
    this.contactPhone = '',
    this.status = TipStatus.pending,
    required this.timestamp,
  });

  factory TipModel.fromMap(Map<String, dynamic> map, String id) {
    return TipModel(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      submittedByName: map['submittedByName'] ?? '',
      contactPhone: map['contactPhone'] ?? '',
      status: tipStatusFromString(map['status'] ?? 'pending'),
      timestamp: map['submittedAt'] is Timestamp
          ? (map['submittedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'location': location,
      'description': description,
      'imageUrl': imageUrl,
      'submittedByName': submittedByName,
      'contactPhone': contactPhone,
      'status': tipStatusToString(status),
      'submittedAt': Timestamp.fromDate(timestamp),
    };
  }
}
