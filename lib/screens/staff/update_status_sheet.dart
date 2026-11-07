import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/status_update/status_update_cubit.dart';
import '../../cubits/status_update/status_update_state.dart';
import '../../models/incident.dart';
import '../../repositories/incident_repository.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/status_chip.dart';

class UpdateStatusSheet extends StatefulWidget {
  const UpdateStatusSheet({super.key, required this.incident});

  final Incident incident;

  static Future<void> show(BuildContext context, Incident incident) {
    final staff = context.read<AuthCubit>().state.user!;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => BlocProvider(
        create: (context) => StatusUpdateCubit(
          incidentRepository: context.read<IncidentRepository>(),
          staff: staff,
        ),
        child: UpdateStatusSheet(incident: incident),
      ),
    );
  }

  @override
  State<UpdateStatusSheet> createState() => _UpdateStatusSheetState();
}

class _UpdateStatusSheetState extends State<UpdateStatusSheet> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onStateChanged(BuildContext context, StatusUpdateState state) {
    if (state.status == StatusUpdateStatus.success) {
      final newLabel = widget.incident.status.next!.label;
      showAppSnackBar(context, 'Status changed to $newLabel');
      Navigator.of(context).pop();
    } else if (state.status == StatusUpdateStatus.failure) {
      showAppSnackBar(context, state.errorMessage!, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final incident = widget.incident;
    final nextStatus = incident.status.next!;
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<StatusUpdateCubit, StatusUpdateState>(
      listener: _onStateChanged,
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            20 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Update status',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                incident.title,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  StatusChip(status: incident.status),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward, semanticLabel: 'to'),
                  ),
                  StatusChip(status: nextStatus),
                ],
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _noteController,
                label: 'Note for the reporter (optional)',
                maxLines: 3,
                maxLength: 300,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Mark as ${nextStatus.label}',
                isLoading: state.isSaving,
                onPressed: () => context
                    .read<StatusUpdateCubit>()
                    .moveToNextStatus(incident, _noteController.text),
              ),
            ],
          ),
        );
      },
    );
  }
}
