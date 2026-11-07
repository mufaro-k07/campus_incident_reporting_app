import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/theme/app_colors.dart';

class PhotoField extends StatelessWidget {
  const PhotoField({
    super.key,
    required this.photo,
    required this.onAddPhoto,
    required this.onRemovePhoto,
  });

  final XFile? photo;
  final VoidCallback onAddPhoto;
  final VoidCallback onRemovePhoto;

  @override
  Widget build(BuildContext context) {
    final selectedPhoto = photo;
    if (selectedPhoto == null) return _AddPhotoButton(onTap: onAddPhoto);

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            File(selectedPhoto.path),
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            semanticLabel: 'Selected photo',
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton.filled(
            tooltip: 'Remove photo',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.black.withValues(alpha: 0.6),
            ),
            onPressed: onRemovePhoto,
            icon: const Icon(Icons.close),
          ),
        ),
      ],
    );
  }
}

class _AddPhotoButton extends StatelessWidget {
  const _AddPhotoButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          height: 120,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_a_photo_outlined,
                color: AppColors.primary,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'Add a photo',
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: AppColors.primary),
              ),
              Text(
                'Optional, up to 5 MB',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
