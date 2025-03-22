import 'dart:math';

import 'package:flutter/material.dart';

import 'Components/BuildGridItem.dart';

class LikedPostsTab extends StatelessWidget {
  // Sample liked posts data - in a real app, this would come from user-specific data
  final List<Map<String, dynamic>> likedPosts = List.generate(
    12, // Increased count for better grid demonstration
    (index) => {
      'image': '',
      'username': 'user_${Random().nextInt(20)}',
      'likes': Random().nextInt(1000),
    },
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200, // Maximum width of each grid item
          childAspectRatio: 1, // Square aspect ratio
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: likedPosts.length,
        itemBuilder: (context, index) {
          return buildGridItem(context, likedPosts[index], true);
        },
      ),
    );
  }

 
}
