import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Topbar extends StatelessWidget {
  final VoidCallback onProfileTap;
  
  const Topbar({super.key, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String displayName = user?.displayName ?? 'Admin User';
    
    return Container(
      height: 64,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              InkWell(
                onTap: onProfileTap,
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            displayName.isNotEmpty ? displayName : 'Admin User', 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF333335))
                          ),
                          const Text('Super Admin', style: TextStyle(color: Color(0xFF8c9097), fontSize: 11)),
                        ],
                      ),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                        child: user?.photoURL == null ? const Icon(Icons.person, size: 20, color: Colors.blue) : null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
