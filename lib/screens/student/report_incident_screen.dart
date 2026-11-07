import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants.dart';
import '../../core/utils/validators.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/report_form/report_form_cubit.dart';
import '../../cubits/report_form/report_form_state.dart';
import '../../models/incident_category.dart';
import '../../repositories/image_upload_service.dart';
import '../../repositories/incident_repository.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/category_selector.dart';
import '../../widgets/photo_field.dart';

class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({super.key});

  static Future<void> open(BuildContext context) {
    final reporter = context.read<AuthCubit>().state.user!;
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) => ReportFormCubit(
            incidentRepository: context.read<IncidentRepository>(),
            imageUploadService: context.read<ImageUploadService>(),
            reporter: reporter,
          ),
          child: const ReportIncidentScreen(),
        ),
      ),
    );
  }

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  IncidentCategory? _category;
  String? _location;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => const _PhotoSourceSheet(),
    );
    if (source == null || !mounted) return;

    try {
      final photo = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1280,
        imageQuality: 70,
      );
      if (photo != null && mounted) {
        await context.read<ReportFormCubit>().setPhoto(photo);
      }
    } on PlatformException {
      if (mounted) {
        showAppSnackBar(context, 'Could not open the photo.', isError: true);
      }
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<ReportFormCubit>().submit(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category!,
      location: _location!,
    );
  }

  void _onFormStateChanged(BuildContext context, ReportFormState state) {
    if (state.status == ReportFormStatus.success) {
      showAppSnackBar(context, 'Report submitted. Thank you!');
      Navigator.of(context).pop();
    } else if (state.status == ReportFormStatus.failure) {
      showAppSnackBar(context, state.errorMessage!, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReportFormCubit, ReportFormState>(
      listener: _onFormStateChanged,
      child: Scaffold(
        appBar: AppBar(title: const Text('Report an Issue')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const _SectionLabel('What kind of issue is it?'),
              FormField<IncidentCategory>(
                validator: (_) =>
                    _category == null ? 'Choose a category' : null,
                builder: (field) => CategorySelector(
                  selected: _category,
                  errorText: field.errorText,
                  onSelected: (category) {
                    setState(() => _category = category);
                    field.didChange(category);
                  },
                ),
              ),
              const SizedBox(height: 24),
              AppTextField(
                controller: _titleController,
                label: 'Title',
                maxLength: 80,
                textCapitalization: TextCapitalization.sentences,
                validator: validateTitle,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 5,
                maxLength: 1000,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
                validator: validateDescription,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _location,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
                items: [
                  for (final location in campusLocations)
                    DropdownMenuItem(value: location, child: Text(location)),
                ],
                onChanged: (location) => _location = location,
                validator: (location) =>
                    location == null ? 'Choose a location' : null,
              ),
              const SizedBox(height: 24),
              const _SectionLabel('Photo'),
              BlocBuilder<ReportFormCubit, ReportFormState>(
                buildWhen: (previous, current) =>
                    previous.photo != current.photo,
                builder: (context, state) => PhotoField(
                  photo: state.photo,
                  onAddPhoto: _addPhoto,
                  onRemovePhoto: context.read<ReportFormCubit>().removePhoto,
                ),
              ),
              const SizedBox(height: 28),
              BlocBuilder<ReportFormCubit, ReportFormState>(
                builder: (context, state) => AppButton(
                  label: 'Submit Report',
                  isLoading: state.isSubmitting,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _PhotoSourceSheet extends StatelessWidget {
  const _PhotoSourceSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Take a photo'),
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose from gallery'),
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
        ],
      ),
    );
  }
}
