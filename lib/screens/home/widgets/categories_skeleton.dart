import 'package:flutter/material.dart';

class CategoriesSkeleton extends StatelessWidget {
  const CategoriesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 16 : 8,
              right: index == 5 ? 16 : 0,
            ),
            child: _buildSkeletonItem(),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonItem() {
    return Container(
      width: 90,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Text(
          '______',
          style: TextStyle(color: Colors.transparent),
        ),
      ),
    );
  }
}
