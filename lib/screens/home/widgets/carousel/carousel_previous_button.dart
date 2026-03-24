import 'package:flutter/material.dart';

class CarouselPreviousButton extends StatelessWidget {
  final VoidCallback onTap;

  const CarouselPreviousButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(180),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(80),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.chevron_left,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}
