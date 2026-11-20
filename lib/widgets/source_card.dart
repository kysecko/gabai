import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

import '../models/legal_source.dart';
import '../theme/app_theme.dart';

class SourceCard extends StatelessWidget {
  final LegalSource source;
  const SourceCard({super.key, required this.source});

  @override
  Widget build(BuildContext context) {
    final isStatute = source.type == 'Statute';
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeroIcon(
            isStatute ? HeroIcons.documentText : HeroIcons.buildingLibrary,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  source.title,
                  style: AppText.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(source.citation,
                    style: AppText.caption.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
