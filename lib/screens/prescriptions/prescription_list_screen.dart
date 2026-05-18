import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/prescription_service.dart';
import '../../services/firebase_auth_service.dart';
import '../../models/prescription_model.dart';
import '../../models/user_model.dart';
import 'package:intl/intl.dart';

class PrescriptionListScreen extends StatefulWidget {
  @override
  _PrescriptionListScreenState createState() => _PrescriptionListScreenState();
}

class _PrescriptionListScreenState extends State<PrescriptionListScreen> {
  final PrescriptionService _prescriptionService = PrescriptionService();
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  UserModel? _currentUserData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final authService = Provider.of<FirebaseAuthService>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final data = await authService.getUserData(user.uid);
      setState(() => _currentUserData = data);
    }
  }

  Future<void> _pickAndUpload() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => _isUploading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await _prescriptionService.uploadPrescription(
        imageFile: File(image.path),
        customerId: user.uid,
        customerName: _currentUserData?.name ?? 'Customer',
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Prescription uploaded successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _updateStatus(PrescriptionModel prescription, PrescriptionStatus status) async {
    String? note;
    final noteController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Status to ${status.toString().split('.').last}'),
        content: TextField(
          controller: noteController,
          decoration: InputDecoration(hintText: 'Add a note (optional)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              note = noteController.text;
              Navigator.pop(context);
            },
            child: Text('Update'),
          ),
        ],
      ),
    );

    if (note != null || status != prescription.status) {
      await _prescriptionService.updatePrescriptionStatus(prescription.id, status, note);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserData == null) return Center(child: CircularProgressIndicator());

    bool isPharmacist = _currentUserData!.role == UserRole.pharmacist;

    return Scaffold(
      body: StreamBuilder<List<PrescriptionModel>>(
        stream: isPharmacist
            ? _prescriptionService.getAllPrescriptions()
            : _prescriptionService.getCustomerPrescriptions(_currentUserData!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());

          final prescriptions = snapshot.data ?? [];

          if (prescriptions.isEmpty) {
            return Center(child: Text('No prescriptions found.'));
          }

          return ListView.builder(
            itemCount: prescriptions.length,
            itemBuilder: (context, index) {
              final item = prescriptions[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: Image.network(item.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                  title: Text(isPharmacist ? 'Customer: ${item.customerName}' : 'Status: ${item.status.toString().split('.').last.toUpperCase()}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DateFormat('MMM dd, yyyy - hh:mm a').format(item.timestamp.toDate())),
                      if (item.pharmacistNote != null)
                        Text('Note: ${item.pharmacistNote}', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey)),
                    ],
                  ),
                  trailing: isPharmacist
                      ? PopupMenuButton<PrescriptionStatus>(
                          onSelected: (status) => _updateStatus(item, status),
                          itemBuilder: (context) => PrescriptionStatus.values
                              .map((s) => PopupMenuItem(value: s, child: Text(s.toString().split('.').last)))
                              .toList(),
                        )
                      : Icon(_getStatusIcon(item.status), color: _getStatusColor(item.status)),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: !isPharmacist
          ? FloatingActionButton(
              onPressed: _isUploading ? null : _pickAndUpload,
              child: _isUploading ? CircularProgressIndicator(color: Colors.white) : Icon(Icons.add_a_photo),
            )
          : null,
    );
  }

  Color _getStatusColor(PrescriptionStatus status) {
    switch (status) {
      case PrescriptionStatus.approved: return Colors.green;
      case PrescriptionStatus.rejected: return Colors.red;
      case PrescriptionStatus.pending: return Colors.orange;
    }
  }

  IconData _getStatusIcon(PrescriptionStatus status) {
    switch (status) {
      case PrescriptionStatus.approved: return Icons.check_circle;
      case PrescriptionStatus.rejected: return Icons.cancel;
      case PrescriptionStatus.pending: return Icons.hourglass_empty;
    }
  }
}
