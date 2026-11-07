import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../shared/profile_screen.dart';
import '../shared/reports_screen.dart';
import 'alerts_screen.dart';
import 'home_screen.dart';
import 'report_incident_screen.dart';

// The order must match the pages in the IndexedStack below, because
// `tab.index` is used to pick the page.
enum StudentTab { home, reports, alerts, profile }

class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  StudentTab _selectedTab = StudentTab.home;

  void _selectTab(StudentTab tab) {
    setState(() => _selectedTab = tab);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedTab.index,
        children: [
          HomeScreen(onSeeAllReports: () => _selectTab(StudentTab.reports)),
          const ReportsScreen(),
          const AlertsScreen(),
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

  final StudentTab selectedTab;
  final ValueChanged<StudentTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppColors.surface,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavPair(
            children: [
              _navItem(
                StudentTab.home,
                Icons.home_outlined,
                Icons.home,
                'Home',
              ),
              _navItem(
                StudentTab.reports,
                Icons.list_alt_outlined,
                Icons.list_alt,
                'Reports',
              ),
            ],
          ),
          const _ReportLabel(),
          _NavPair(
            children: [
              _navItem(
                StudentTab.alerts,
                Icons.notifications_outlined,
                Icons.notifications,
                'Alerts',
              ),
              _navItem(
                StudentTab.profile,
                Icons.person_outline,
                Icons.person,
                'Profile',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    StudentTab tab,
    IconData icon,
    IconData selectedIcon,
    String label,
  ) {
    return _NavItem(
      icon: icon,
      selectedIcon: selectedIcon,
      label: label,
      isSelected: selectedTab == tab,
      onTap: () => onTabSelected(tab),
    );
  }
}

class _NavPair extends StatelessWidget {
  const _NavPair({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}

class _ReportLabel extends StatelessWidget {
  const _ReportLabel();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Wide enough for the 56 dp button plus the notch around it.
      width: 80,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ExcludeSemantics(
            child: Text(
              'Report',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.royalBlue,
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

  // Every item has the same width, so both pairs are the same size and
  // the Report button stays exactly in the centre. 4 x 64 + 80 fits a
  // 360 dp wide phone.
  static const double width = 64;

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.royalBlue : AppColors.textSecondary;
    return Semantics(
      selected: isSelected,
      button: true,
      child: InkResponse(
        onTap: onTap,
        child: SizedBox(
          width: width,
          height: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isSelected ? selectedIcon : icon, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
