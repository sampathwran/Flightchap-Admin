import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: const Color(0xFF111c43),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Area
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF007bff), Color(0xFF23b7e5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: const Text('H', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Flightchap',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                ),
              ],
            ),
          ),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildMenuCategory('MAIN'),
                _buildMenuItem(0, Icons.dashboard_outlined, 'Dashboard'),
                
                const SizedBox(height: 12),
                _buildMenuCategory('APP MANAGER'),
                _buildMenuItem(1, Icons.public, 'Popular Destinations'),
                _buildMenuItem(2, Icons.local_fire_department_outlined, 'Flash Deals'),
                _buildMenuItem(13, Icons.star_border, 'Member Deals'),
                _buildMenuItem(14, Icons.tag, 'Promo Codes'),
                _buildMenuItem(3, Icons.article_outlined, 'Travel Blog'),
                _buildMenuItem(9, Icons.notifications_active, 'Subscribers'),
                const SizedBox(height: 12),
                                ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCategory(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 8, top: 8),
      child: Text(
        title,
        style: const TextStyle(color: Color(0xFF5c678f), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String title, {String? badge}) {
    bool isActive = selectedIndex == index;
    return InkWell(
      onTap: () => onItemSelected(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isActive ? Colors.white : const Color(0xFFa8b2cc)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: TextStyle(color: isActive ? Colors.white : const Color(0xFFa8b2cc), fontSize: 14)),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFf5b849), borderRadius: BorderRadius.circular(4)),
                child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}
