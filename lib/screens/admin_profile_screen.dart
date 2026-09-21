import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  late TextEditingController _nameController;
  bool _isLoading = false;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: user?.displayName ?? '');
  }

  Future<void> _updateProfile() async {
    if (user == null) return;
    setState(() {
      _isLoading = true;
      _message = '';
    });
    try {
      await user!.updateDisplayName(_nameController.text.trim());
      await user!.reload();
      setState(() {
        _message = 'Profile updated successfully!';
      });
    } catch (e) {
      setState(() {
        _message = 'Error updating profile.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    if (user?.email == null) return;
    setState(() {
      _isLoading = true;
      _message = '';
    });
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);
      setState(() {
        _message = 'Password reset email sent to \${user!.email}';
      });
    } catch (e) {
      setState(() {
        _message = 'Error sending password reset email.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    if (user == null) return;
    
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
      if (image == null) return;

      setState(() {
        _isLoading = true;
        _message = 'Uploading image...';
      });

      final storageRef = FirebaseStorage.instance.ref().child('admin_profiles').child('\${user!.uid}.jpg');
      
      if (kIsWeb) {
        await storageRef.putData(await image.readAsBytes());
      } else {
        await storageRef.putFile(File(image.path));
      }

      final String downloadUrl = await storageRef.getDownloadURL();
      await user!.updatePhotoURL(downloadUrl);
      await user!.reload();
      
      setState(() {
        _message = 'Profile picture updated successfully!';
      });
    } catch (e) {
      setState(() {
        _message = 'Error uploading image: \$e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFf0f1f7),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            children: [
              const Icon(Icons.manage_accounts, size: 32, color: Color(0xFF007bff)),
              const SizedBox(width: 12),
              const Text('Admin Profile Settings', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF111c43))),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Manage your account details, security, and preferences.', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 32),
          
          if (_message.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: _message.contains('Error') ? Colors.red.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _message.contains('Error') ? Colors.red.shade200 : Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(_message.contains('Error') ? Icons.error_outline : Icons.check_circle_outline, 
                       color: _message.contains('Error') ? Colors.red.shade700 : Colors.green.shade700),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_message, style: TextStyle(color: _message.contains('Error') ? Colors.red.shade700 : Colors.green.shade700, fontWeight: FontWeight.w500))),
                ],
              ),
            ),

          Container(
            width: 600,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 8))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar & Upload
                Row(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                          child: user?.photoURL == null ? const Icon(Icons.person, size: 50, color: Colors.blue) : null,
                        ),
                        InkWell(
                          onTap: _isLoading ? null : _pickAndUploadImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: Color(0xFF007bff), shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user?.displayName?.isNotEmpty == true ? user!.displayName! : 'Admin User', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF111c43))),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(20)),
                            child: const Text('Super Admin', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600, fontSize: 12)),
                          ),
                          const SizedBox(height: 8),
                          Text(user?.email ?? 'No Email', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                    )
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Divider(color: Color(0xFFe2e8f0)),
                ),
                
                // Form
                const Text('Display Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFe2e8f0))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFe2e8f0))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF007bff))),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    filled: true,
                    fillColor: const Color(0xFFf8f9fa),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Actions
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _isLoading ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007bff),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : _resetPassword,
                      icon: const Icon(Icons.lock_reset, size: 18),
                      label: const Text('Reset Password'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF5c678f),
                        side: const BorderSide(color: Color(0xFFe2e8f0)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 64),
          ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Log Out of Admin Panel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          )
        ],
      ),
      ),
    );
  }
}
