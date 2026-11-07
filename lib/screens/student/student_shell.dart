import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../shared/profile_screen.dart';
import '../shared/reports_screen.dart';
import 'home_screen.dart';
import 'report_incident_screen.dart';

class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _selectedTab = 0;

  void _selectTab(int index) {
    setState(() => _selectedTab = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedTab,
        children: [
          HomeScreen(onSeeAllReports: () => _selectTab(1)),
          const ReportsScreen(),
          const ProfileScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Report an incident',
        onPressed: () => ReportIncidentScreen.open(context),
        child: const Icon(Icons.add, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _StudentNavigationBar(
        selectedTab: _selectedTab,
        onTabSelected: _selectTab,
      ),
    );
  }
}

class _StudentNavigationBar extends StatelessWidget {
  const _StudentNavigationBar({
    required this.selectedTab,
    required this.onTabSelected,
  });

  final int selectedTab;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppColors.surface,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                _navItem(0, Icons.home_outlined, Icons.home, 'Home'),
                _navItem(1, Icons.list_alt_outlined, Icons.list_alt, 'Reports'),
              ],
            ),
          ),
          const _ReportLabel(),
          Expanded(
            child: Row(
              children: [
                _navItem(2, Icons.person_outline, Icons.person, 'Profile'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    int index,
    IconData icon,
    IconData selectedIcon,
    String label,
  ) {
    return Expanded(
      child: _NavItem(
        icon: icon,
        selectedIcon: selectedIcon,
        label: label,
        isSelected: selectedTab == index,
        onTap: () => onTabSelected(index),
      ),
    );
  }
}

class _ReportLabel extends StatelessWidget {
  const _ReportLabel();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ExcludeSemantics(
            child: Text(
              'Report',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.accentDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.textSecondary;
    return Semantics(
      selected: isSelected,
      button: true,
      child: InkResponse(
        onTap: onTap,
        child: SizedBox(
          height: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isSelected ? selectedIcon : icon, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
