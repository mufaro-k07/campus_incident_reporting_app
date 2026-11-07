import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/incidents/incidents_cubit.dart';
import '../cubits/incidents/incidents_state.dart';
import '../models/incident_category.dart';
import '../models/incident_status.dart';

class IncidentFilterBar extends StatefulWidget {
  const IncidentFilterBar({super.key});

  @override
  State<IncidentFilterBar> createState() => _IncidentFilterBarState();
}

class _IncidentFilterBarState extends State<IncidentFilterBar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final searchText = context.read<IncidentsCubit>().state.searchText;
    _searchController = TextEditingController(text: searchText);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<IncidentsCubit>().search('');
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<IncidentsCubit>();
    final state = context.watch<IncidentsCubit>().state;

    return BlocListener<IncidentsCubit, IncidentsState>(
      // Staff see this bar on two tabs, so keep both search boxes in step.
      listenWhen: (previous, current) =>
          current.searchText != _searchController.text,
      listener: (context, state) => _searchController.text = state.searchText,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _searchController,
            onChanged: cubit.search,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search title, place or category',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: state.searchText.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close),
                      onPressed: _clearSearch,
                    ),
            ),
          ),
          const SizedBox(height: 12),
          _ChipRow(
            children: [
              _FilterChip(
                label: 'All',
                isSelected: state.statusFilter == null,
                onSelected: () => cubit.filterByStatus(null),
              ),
              for (final status in IncidentStatus.values)
                _FilterChip(
                  label: status.label,
                  isSelected: state.statusFilter == status,
                  onSelected: () => cubit.filterByStatus(status),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _ChipRow(
            children: [
              _FilterChip(
                label: 'All categories',
                isSelected: state.categoryFilter == null,
                onSelected: () => cubit.filterByCategory(null),
              ),
              for (final category in IncidentCategory.values)
                _FilterChip(
                  label: category.label,
                  icon: category.icon,
                  isSelected: state.categoryFilter == category,
                  onSelected: () => cubit.filterByCategory(category),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final child in children)
            Padding(padding: const EdgeInsets.only(right: 8), child: child),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      avatar: icon == null ? null : Icon(icon, size: 18),
      selected: isSelected,
      onSelected: (_) => onSelected(),
    );
  }
}
