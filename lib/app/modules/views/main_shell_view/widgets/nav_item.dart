import 'package:flutter/material.dart';

import '../../../../utils/design_system/app_colors.dart';
import '../../../../utils/design_system/app_spacing.dart';
import '../../../../utils/design_system/app_text_styles.dart';

class NavItem extends StatelessWidget {
  const NavItem({
    super.key,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final color = selected ? c.primary : c.outline;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              height: 56,
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    width: selected ? 18 : 4,
                    height: 2,
                    decoration: BoxDecoration(
                      color: selected ? c.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  AnimatedSlide(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    offset:
                        selected ? const Offset(0, -0.06) : Offset.zero,
                    child: Icon(
                      selected ? selectedIcon : icon,
                      size: selected ? 23 : 21,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  ExcludeSemantics(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelSm.copyWith(
                        color: color,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
