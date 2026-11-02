import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'phone_status_bar.dart';

class PhoneFrame extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final bool showFrame;

  const PhoneFrame({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.showFrame = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!showFrame) {
      return Container(
        color: AppColors.screenBackground,
        child: SafeArea(
          child: child,
        ),
      );
    }

    return Container(
      width: width ?? 360,
      height: height ?? 740,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.screenBackground,
        borderRadius: BorderRadius.circular(42),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 32,
            spreadRadius: 2,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.8),
          width: 3,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(39),
        child: Column(
          children: [
            const PhoneStatusBar(),
            Expanded(child: child),
            // Home Indicator Bar
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 4),
              child: Container(
                width: 130,
                height: 4.5,
                decoration: BoxDecoration(
                  color: AppColors.textDark.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

