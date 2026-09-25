import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SocialMediaScreen extends StatefulWidget {
  const SocialMediaScreen({super.key});

  @override
  State<SocialMediaScreen> createState() => _SocialMediaScreenState();
}

class _SocialMediaScreenState extends State<SocialMediaScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _youtubeController = TextEditingController();
  final TextEditingController _tiktokController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('settings').doc('social_media').get();
      if (doc.exists) {
        final data = doc.data()!;
        _facebookController.text = data['facebook'] ?? '';
        _instagramController.text = data['instagram'] ?? '';
        _youtubeController.text = data['youtube'] ?? '';
        _tiktokController.text = data['tiktok'] ?? '';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading links: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance.collection('settings').doc('social_media').set({
        'facebook': _facebookController.text.trim(),
        'instagram': _instagramController.text.trim(),
        'youtube': _youtubeController.text.trim(),
        'tiktok': _tiktokController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Social media links updated successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving links: $e')));
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Media Links', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Update the links for your website footer icons here.', style: TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 30),
              
              _buildTextField('Facebook URL', _facebookController, Icons.facebook, 'https://facebook.com/yourpage'),
              const SizedBox(height: 20),
              _buildTextField('Instagram URL', _instagramController, Icons.camera_alt, 'https://instagram.com/yourpage'),
              const SizedBox(height: 20),
              _buildTextField('YouTube URL', _youtubeController, Icons.play_circle_filled, 'https://youtube.com/c/yourchannel'),
              const SizedBox(height: 20),
              _buildTextField('TikTok URL', _tiktokController, Icons.music_note, 'https://tiktok.com/@yourprofile'),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF673AB7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isSaving 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Links', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, String hint) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF673AB7)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty && !value.startsWith('http')) {
          return 'Please enter a valid URL starting with http:// or https://';
        }
        return null;
      },
    );
  }
}
