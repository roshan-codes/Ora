import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class PhoneStatusBar extends StatelessWidget {
  const PhoneStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Time
          const Text(
            '12:41',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
              letterSpacing: -0.2,
            ),
          ),
          // Status Icons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cellular signal
              _buildCellularIcon(),
              const SizedBox(width: 5),
              // Wi-Fi
              const Icon(
                Icons.wifi,
                size: 15,
                color: AppColors.textDark,
              ),
              const SizedBox(width: 5),
              // Battery
              _buildBatteryIcon(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCellularIcon() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildBar(4),
        const SizedBox(width: 1.5),
        _buildBar(6),
        const SizedBox(width: 1.5),
        _buildBar(8),
        const SizedBox(width: 1.5),
        _buildBar(10),
      ],
    );
  }

  Widget _buildBar(double height) {
    return Container(
      width: 2.5,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.textDark,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildBatteryIcon() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 10,
          padding: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.textDark, width: 1.2),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.textDark,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
        Container(
          width: 1.5,
          height: 4,
          decoration: const BoxDecoration(
            color: AppColors.textDark,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(1),
              bottomRight: Radius.circular(1),
            ),
          ),
        ),
      ],
    );
  }
}

