import 'package:flutter/material.dart';

import '../BookMarkedScreen.dart';
import '../LikedPostScreen.dart';

void showActivityBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the bottom sheet to take more space
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'Liked Posts'),
                        Tab(text: 'Bookmarked Posts'),
                      ],
                      labelColor: Colors.black,
                      indicatorColor: Colors.blue,
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Liked Posts Tab
                          LikedPostsTab(),
                          // Bookmarked Posts Tab
                          BookmarkedPostsTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
