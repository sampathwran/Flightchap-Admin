import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    _nameController = TextEditingController(text: user?.displayName ?? 'Admin User');
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

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Admin Profile Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF111c43))),
          const SizedBox(height: 32),
          
          if (_message.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: _message.contains('Error') ? Colors.red.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _message,
                style: TextStyle(color: _message.contains('Error') ? Colors.red.shade700 : Colors.green.shade700),
              ),
            ),

          Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: const Icon(Icons.person, size: 40, color: Colors.blue),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.email ?? 'No Email', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Super Admin', style: TextStyle(color: Colors.grey)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 32),
                
                const Text('Display Name', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 24),
                
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _isLoading ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF845adf),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                      child: const Text('Save Changes'),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: _isLoading ? null : _resetPassword,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                      child: const Text('Reset Password'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          )
        ],
      ),
    );
  }
}
