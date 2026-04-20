import 'package:flutter/material.dart';
import 'package:orsocook/services/profile/profile_controller.dart';
import 'package:orsocook/utils/responsive_utils.dart';

class ProfileErrorWidget extends StatelessWidget {
  final ProfileController controller;

  const ProfileErrorWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ResponsiveValues.screenPadding(context),
      margin: ResponsiveValues.horizontalPadding(context),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  controller.error!,
                  style: TextStyle(color: Colors.red[700]),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveValues.gapMedium(context)),
          ElevatedButton(
            onPressed: controller.retry,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
              minimumSize: Size(100, ResponsiveValues.buttonHeight(context)),
            ),
            child: const Text('Riprova'),
          ),
        ],
      ),
    );
  }
}
