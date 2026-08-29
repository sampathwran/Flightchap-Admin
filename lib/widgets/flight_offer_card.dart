import 'package:flutter/material.dart';

class FlightOfferCardWidget extends StatelessWidget {
  final String title;
  final String badgeText;
  final String description;
  final String buttonText;
  final int designId;
  final double width;

  const FlightOfferCardWidget({
    super.key,
    required this.title,
    required this.badgeText,
    required this.description,
    required this.buttonText,
    required this.designId,
    this.width = 350,
  });

  Map<String, dynamic> _getDesign(int id) {
    switch (id) {
      case 1:
        return {
          'gradient': const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF4338CA)]), // blue-600 to indigo-700
          'icon': Icons.flight_takeoff,
          'iconColor': Colors.white.withOpacity(0.1),
          'textColor': Colors.white,
          'subTextColor': const Color(0xFFDBEAFE), // blue-100
          'buttonBg': Colors.white,
          'buttonText': const Color(0xFF4338CA), // indigo-700
        };
      case 2:
        return {
          'gradient': const LinearGradient(colors: [Color(0xFFF97316), Color(0xFFEF4444)]), // orange-500 to red-500
          'icon': Icons.verified_user,
          'iconColor': Colors.white.withOpacity(0.1),
          'textColor': Colors.white,
          'subTextColor': const Color(0xFFFEE2E2), // red-100
          'buttonBg': Colors.white,
          'buttonText': const Color(0xFFEF4444), // red-500
        };
      case 3:
        return {
          'gradient': const LinearGradient(colors: [Color(0xFF14B8A6), Color(0xFF059669)]), // teal-500 to emerald-600
          'icon': Icons.public,
          'iconColor': Colors.white.withOpacity(0.1),
          'textColor': Colors.white,
          'subTextColor': const Color(0xFFCCFBF1), // teal-100
          'buttonBg': Colors.white,
          'buttonText': const Color(0xFF047857), // emerald-700
        };
      case 4:
        return {
          'gradient': const LinearGradient(colors: [Color(0xFFA855F7), Color(0xFFEC4899)]), // purple-500 to pink-500
          'icon': Icons.star,
          'iconColor': Colors.white.withOpacity(0.1),
          'textColor': Colors.white,
          'subTextColor': const Color(0xFFF3E8FF), // purple-100
          'buttonBg': Colors.white,
          'buttonText': const Color(0xFF7E22CE), // purple-700
        };
      case 5:
        return {
          'gradient': const LinearGradient(colors: [Color(0xFF111827), Color(0xFF000000)]), // gray-900 to black
          'icon': Icons.bolt,
          'iconColor': const Color(0xFF22C55E).withOpacity(0.1), // green-500
          'textColor': Colors.white,
          'subTextColor': const Color(0xFF9CA3AF), // gray-400
          'buttonBg': const Color(0xFF22C55E), // green-500
          'buttonText': Colors.black,
        };
      case 6:
        return {
          'gradient': const LinearGradient(colors: [Color(0xFFFACC15), Color(0xFFF59E0B)]), // yellow-400 to amber-500
          'icon': Icons.wb_sunny,
          'iconColor': const Color(0xFFEA580C).withOpacity(0.1), // orange-600
          'textColor': const Color(0xFF111827), // gray-900
          'subTextColor': const Color(0xFF1F2937), // gray-800
          'buttonBg': const Color(0xFF111827), // gray-900
          'buttonText': Colors.white,
        };
      case 7:
        return {
          'gradient': const LinearGradient(colors: [Color(0xFF22D3EE), Color(0xFF3B82F6)]), // cyan-400 to blue-500
          'icon': Icons.beach_access,
          'iconColor': Colors.white.withOpacity(0.1),
          'textColor': Colors.white,
          'subTextColor': const Color(0xFFCFFAFE), // cyan-100
          'buttonBg': Colors.white,
          'buttonText': const Color(0xFF2563EB), // blue-600
        };
      case 8:
        return {
          'gradient': const LinearGradient(colors: [Color(0xFFF43F5E), Color(0xFFFB923C)]), // rose-500 to orange-400
          'icon': Icons.favorite,
          'iconColor': Colors.white.withOpacity(0.1),
          'textColor': Colors.white,
          'subTextColor': const Color(0xFFFFE4E6), // rose-100
          'buttonBg': Colors.white,
          'buttonText': const Color(0xFFE11D48), // rose-600
        };
      case 9:
        return {
          'gradient': const LinearGradient(colors: [Color(0xFF3730A3), Color(0xFF581C87)]), // indigo-800 to purple-900
          'icon': Icons.map,
          'iconColor': Colors.white.withOpacity(0.05),
          'textColor': Colors.white,
          'subTextColor': const Color(0xFFC7D2FE), // indigo-200
          'buttonBg': Colors.white,
          'buttonText': const Color(0xFF312E81), // indigo-900
        };
      case 10:
        return {
          'gradient': const LinearGradient(colors: [Color(0xFF334155), Color(0xFF1F2937)]), // slate-700 to gray-800
          'icon': Icons.access_time_filled,
          'iconColor': Colors.white.withOpacity(0.05),
          'textColor': Colors.white,
          'subTextColor': const Color(0xFFD1D5DB), // gray-300
          'buttonBg': Colors.white,
          'buttonText': const Color(0xFF111827), // gray-900
        };
      default:
        return _getDesign(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final design = _getDesign(designId);

    return Container(
      width: width,
      height: 250,
      decoration: BoxDecoration(
        gradient: design['gradient'],
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Icon(
              design['icon'],
              size: 160,
              color: design['iconColor'],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: design['textColor'] == Colors.white 
                            ? Colors.white.withOpacity(0.2) 
                            : Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badgeText.toUpperCase(),
                        style: TextStyle(
                          color: design['textColor'],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: TextStyle(
                        color: design['textColor'],
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        color: design['subTextColor'],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: design['buttonBg'],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      color: design['buttonText'],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
