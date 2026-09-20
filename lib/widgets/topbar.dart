import 'package:flutter/material.dart';

class Topbar extends StatelessWidget {
  const Topbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Right Icons (Only User Profile remaining)
          Row(
            children: [
              // User Profile
              Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      Text('Admin User', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF333335))),
                      Text('Super Admin', style: TextStyle(color: Color(0xFF8c9097), fontSize: 11)),
                    ],
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFF845adf),
                    child: const Text('A', style: TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
