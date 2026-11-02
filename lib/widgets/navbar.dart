import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    const Color selectedColor = Color(0xFF2563EB);
    const Color unselectedColor = Color(0xFF686B73);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(80),
          bottomRight: Radius.circular(80),
        ),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
          width: 1,
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    selected: true,
                    selectedColor: selectedColor,
                    unselectedColor: unselectedColor,
                  ),
                  _navItem(
                    icon: Icons.map_outlined,
                    label: 'Explore',
                    selected: false,
                    selectedColor: selectedColor,
                    unselectedColor: unselectedColor,
                  ),
                  _navItem(
                    icon: Icons.assignment_outlined,
                    label: 'My reports',
                    selected: false,
                    selectedColor: selectedColor,
                    unselectedColor: unselectedColor,
                  ),
                  _navItem(
                    icon: Icons.account_circle_outlined,
                    label: 'Profile',
                    selected: false,
                    selectedColor: selectedColor,
                    unselectedColor: unselectedColor,
                  ),
                ],
              ),
            ),

            // Bottom system-style indicator
            Container(
              width: 274,
              height: 10,
              margin: const EdgeInsets.only(
                top: 14,
                bottom: 22,
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required bool selected,
    required Color selectedColor,
    required Color unselectedColor,
  }) {
    final color = selected ? selectedColor : unselectedColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 39,
          color: color,
          //strokeWidth: 1.5,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 20,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: color,
          ),
        ),
      ],
    );
  }
}
