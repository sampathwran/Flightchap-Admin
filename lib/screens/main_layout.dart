import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/topbar.dart';
import 'dashboard_screen.dart';
import 'customers_screen.dart';
import 'flash_deals_screen.dart';
import 'member_deals_screen.dart';
import 'popular_destinations_screen.dart';

import 'blog_screen.dart';
import 'fare_alerts_subscribers_screen.dart';
import 'popular_vehicles_screen.dart';
import 'transfer_vehicles_screen.dart';
import 'special_offers_screen.dart';
import 'admin_profile_screen.dart';
import '../helpers/url_helper.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final Map<int, String> _routes = {
    0: '/dashboard',
    1: '/popular-destinations',
    2: '/flash-deals',
    3: '/blog',
    6: '/customers',
    9: '/fare-alerts',
    10: '/popular-vehicles',
    11: '/transfer-vehicles',
    12: '/special-offers',
    13: '/member-deals',
    99: '/profile',
  };

  @override
  void initState() {
    super.initState();
    listenToUrlChanges((newUrl) {
      if (newUrl != '/' && newUrl.isNotEmpty) {
        int initialIndex = _routes.entries
            .firstWhere((entry) => entry.value == newUrl, orElse: () => const MapEntry(0, '/dashboard'))
            .key;
        setState(() {
          _selectedIndex = initialIndex;
        });
      }
    });
    String currentUrl = getUrl();
    if (currentUrl != '/' && currentUrl.isNotEmpty) {
      int initialIndex = _routes.entries
          .firstWhere((entry) => entry.value == currentUrl, orElse: () => const MapEntry(0, '/dashboard'))
          .key;
      _selectedIndex = initialIndex;
    }
  }


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
                if (_routes.containsKey(index)) {
                  setUrl('/#' + _routes[index]!);
                }
              });
            },
          ),
          Expanded(
            child: Column(
              children: [
                Topbar(onProfileTap: () {
                  setState(() {
                    _selectedIndex = 99;
                    setUrl('/#profile');
                  });
                }),
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
    } else if (_selectedIndex == 6) {
      return const CustomersScreen();
    } else if (_selectedIndex == 9) {
      return const FareAlertsSubscribersScreen();
    } else if (_selectedIndex == 10) {
      return const PopularVehiclesScreen();
    } else if (_selectedIndex == 11) {
      return const TransferVehiclesScreen();
    } else if (_selectedIndex == 12) {
      return const SpecialOffersScreen();
    } else if (_selectedIndex == 99) {
      return const AdminProfileScreen();
    } else {
      return Center(child: Text('Module Under Construction', style: TextStyle(fontSize: 24, color: Colors.grey)));
    }
  }
}
