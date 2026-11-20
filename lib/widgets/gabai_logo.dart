import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

import '../theme/app_theme.dart';

/// Rounded-square Gabai mark (scales of justice).
/// [inverted] = white tile with blue icon, for use on a blue background.
class GabaiLogo extends StatelessWidget {
  final double size;
  final bool inverted;
  const GabaiLogo({super.key, this.size = 40, this.inverted = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: inverted ? AppColors.white : AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: inverted ? AppShadows.medium : null,
      ),
      child: Center(
        child: HeroIcon(
          HeroIcons.scale,
          style: HeroIconStyle.solid,
          size: size * 0.55,
          color: inverted ? AppColors.primary : AppColors.white,
        ),
      ),
    );
  }
}
