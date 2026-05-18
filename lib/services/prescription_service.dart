import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/prescription_model.dart';

class PrescriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload Prescription
  Future<void> uploadPrescription({
    required File imageFile,
    required String customerId,
    required String customerName,
  }) async {
    // 1. Upload image to Storage
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = _storage.ref().child('prescriptions/$fileName');
    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();

    // 2. Save metadata to Firestore
    await _firestore.collection('prescriptions').add({
      'customerId': customerId,
      'customerName': customerName,
      'imageUrl': downloadUrl,
      'status': PrescriptionStatus.pending.toString().split('.').last,
      'timestamp': FieldValue.serverTimestamp(),
      'pharmacistNote': null,
    });
  }

  // Get Prescriptions for Customer
  Stream<List<PrescriptionModel>> getCustomerPrescriptions(String customerId) {
    return _firestore
        .collection('prescriptions')
        .where('customerId', isEqualTo: customerId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PrescriptionModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get All Prescriptions for Pharmacist
  Stream<List<PrescriptionModel>> getAllPrescriptions() {
    return _firestore
        .collection('prescriptions')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PrescriptionModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Update Prescription Status
  Future<void> updatePrescriptionStatus(String id, PrescriptionStatus status, String? note) async {
    await _firestore.collection('prescriptions').doc(id).update({
      'status': status.toString().split('.').last,
      'pharmacistNote': note,
    });
  }
}
