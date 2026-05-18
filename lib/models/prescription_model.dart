import 'package:cloud_firestore/cloud_firestore.dart';

enum PrescriptionStatus { pending, approved, rejected }

class PrescriptionModel {
  final String id;
  final String customerId;
  final String customerName;
  final String imageUrl;
  final PrescriptionStatus status;
  final Timestamp timestamp;
  final String? pharmacistNote;

  PrescriptionModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.imageUrl,
    required this.status,
    required this.timestamp,
    this.pharmacistNote,
  });

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'imageUrl': imageUrl,
      'status': status.toString().split('.').last,
      'timestamp': timestamp,
      'pharmacistNote': pharmacistNote,
    };
  }

  factory PrescriptionModel.fromMap(Map<String, dynamic> map, String id) {
    return PrescriptionModel(
      id: id,
      customerId: map['customerId'],
      customerName: map['customerName'],
      imageUrl: map['imageUrl'],
      status: PrescriptionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => PrescriptionStatus.pending,
      ),
      timestamp: map['timestamp'],
      pharmacistNote: map['pharmacistNote'],
    );
  }
}
