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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Icons
          Row(
            children: [
              IconButton(icon: const Icon(Icons.menu, color: Color(0xFF5c678f)), onPressed: () {}),
            ],
          ),
          // Right Icons
          Row(
            children: [
              IconButton(icon: const Icon(Icons.search, color: Color(0xFF5c678f)), onPressed: () {}),
              const SizedBox(width: 8),
              Container(
                width: 24, height: 24,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
                alignment: Alignment.center,
                child: const Text('LK', style: TextStyle(color: Colors.white, fontSize: 10)),
              ),
              const SizedBox(width: 8),
              IconButton(icon: const Icon(Icons.dark_mode_outlined, color: Color(0xFF5c678f)), onPressed: () {}),
              IconButton(icon: const Icon(Icons.notifications_none_outlined, color: Color(0xFF5c678f)), onPressed: () {}),
              IconButton(icon: const Icon(Icons.fullscreen_outlined, color: Color(0xFF5c678f)), onPressed: () {}),
              const SizedBox(width: 12),
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
              )
            ],
          )
        ],
      ),
    );
  }
}
