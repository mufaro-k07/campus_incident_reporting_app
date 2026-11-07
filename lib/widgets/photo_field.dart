import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/theme/app_colors.dart';

class PhotoField extends StatelessWidget {
  const PhotoField({
    super.key,
    required this.photo,
    required this.photoUrl,
    required this.onAddPhoto,
    required this.onRemovePhoto,
  });

  final XFile? photo;
  final String? photoUrl;
  final VoidCallback onAddPhoto;
  final VoidCallback onRemovePhoto;

  @override
  Widget build(BuildContext context) {
    final newPhoto = photo;
    final savedPhotoUrl = photoUrl;

    final Widget preview;
    if (newPhoto != null) {
      preview = Image.file(
        File(newPhoto.path),
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        semanticLabel: 'Selected photo',
      );
    } else if (savedPhotoUrl != null) {
      preview = Image.network(
        savedPhotoUrl,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        semanticLabel: 'Current photo',
      );
    } else {
      return _AddPhotoButton(onTap: onAddPhoto);
    }

    return Stack(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(16), child: preview),
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
    final textTheme = Theme.of(context).textTheme;
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
                color: AppColors.royalBlue,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'Add a photo',
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.royalBlue,
                ),
              ),
              Text(
                'Optional, up to 5 MB',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
