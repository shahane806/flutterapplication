import 'dart:math';


import 'package:flutter/material.dart';

import 'Components/BuildGridItem.dart';

class BookmarkedPostsTab extends StatelessWidget {
  // Sample bookmarked posts data - in a real app, this would come from user-specific data
  final List<Map<String, dynamic>> bookmarkedPosts = List.generate(
    10,
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
          maxCrossAxisExtent: 200,
          childAspectRatio: 1,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: bookmarkedPosts.length,
        itemBuilder: (context, index) {
          return buildGridItem(context, bookmarkedPosts[index], false);
        },
      ),
    );
  }
}

