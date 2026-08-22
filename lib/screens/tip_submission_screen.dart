import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/tip_model.dart';
import '../providers/auth_provider.dart';
import '../providers/news_provider.dart';

// Community News Tip submission form: title, location, description and an
// optional photo. Saved to Firestore with status 'pending' for an admin
// to review from the Admin Dashboard.
class TipSubmissionScreen extends StatefulWidget {
  const TipSubmissionScreen({super.key});

  @override
  State<TipSubmissionScreen> createState() => _TipSubmissionScreenState();
}

class _TipSubmissionScreenState extends State<TipSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();

  XFile? _pickedImage;
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) setState(() => _pickedImage = image);
  }

  Future<String> _uploadImageIfAny(String tipId) async {
    if (_pickedImage == null) return '';
    final ref = FirebaseStorage.instance.ref('tips/$tipId.jpg');
    await ref.putFile(File(_pickedImage!.path));
    return ref.getDownloadURL();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final news = context.read<NewsProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    setState(() => _submitting = true);
    try {
      // Firestore auto-generates the doc id when we call submitTip, but we
      // need an id up-front for the storage path, so use a timestamp-based
      // placeholder id for the image file name.
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      final imageUrl = await _uploadImageIfAny(tempId);

      final tip = TipModel(
        id: '',
        userId: user.id,
        title: _titleController.text.trim(),
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: imageUrl,
        submittedByName: user.name,
        contactPhone: _phoneController.text.trim(),
        status: TipStatus.pending,
        timestamp: DateTime.now(),
      );

      await news.submitTip(tip);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thanks! Your tip was sent for review.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not submit tip: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit a News Tip')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g. Waterlogging near Mechi bridge',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Enter a title' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'e.g. Ward 5, Birtamode',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'What happened? When did you notice it?',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Enter a description' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Contact Phone (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: Text(_pickedImage == null ? 'Add Photo (optional)' : 'Photo Selected'),
                ),
                if (_pickedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(_pickedImage!.path), height: 160, fit: BoxFit.cover),
                    ),
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Submit Tip'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
