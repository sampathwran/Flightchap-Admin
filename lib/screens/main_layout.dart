import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/topbar.dart';
import 'dashboard_screen.dart';
import 'customers_screen.dart';
import 'wishlist_screen.dart';
import 'flash_deals_screen.dart';
import 'popular_destinations_screen.dart';

import 'blog_screen.dart';
import 'flight_offers_screen.dart';
import 'popular_flight_routes_screen.dart';
import 'fare_alerts_subscribers_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          Expanded(
            child: Column(
              children: [
                const Topbar(),
                Expanded(
                  child: _buildBody(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBody() {
    // Return different screens based on _selectedIndex
    if (_selectedIndex == 0) {
      return const DashboardScreen();
    } else if (_selectedIndex == 1) {
      return const PopularDestinationsScreen();
    } else if (_selectedIndex == 2) {
      return const FlashDealsScreen();
    } else if (_selectedIndex == 3) {
      return const BlogScreen();
    } else if (_selectedIndex == 4) {
      return const WishlistScreen();
    } else if (_selectedIndex == 6) {
      return const CustomersScreen();
    } else if (_selectedIndex == 7) {
      return const FlightOffersScreen();
    } else if (_selectedIndex == 8) {
      return const PopularFlightRoutesScreen();
    } else if (_selectedIndex == 9) {
      return const FareAlertsSubscribersScreen();
    } else {
      return Center(child: Text('Module Under Construction', style: TextStyle(fontSize: 24, color: Colors.grey)));
    }
  }
}
