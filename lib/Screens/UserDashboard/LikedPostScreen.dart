import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socialmedia/Handlers/UserData.dart';

import 'Components/BuildGridItem.dart'; // Assuming this is your custom widget

class LikedPostsTab extends StatefulWidget {
  @override
  _LikedPostsTabState createState() => _LikedPostsTabState();
}

class _LikedPostsTabState extends State<LikedPostsTab> {
  List<Map<String, dynamic>> likedPosts = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchLikedPosts();
  }

  Future<void> fetchLikedPosts() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.180:9003/SocialMediaApis/getLikedPost.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'MOBILE': UserData
              .phone, // Replace with actual phone number variable if needed
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 200) {
          setState(() {
            likedPosts =
                List<Map<String, dynamic>>.from(jsonData['data']).map((post) {
              return {
                'image':
                    'http://192.168.1.180:9003/SocialMediaApis/${post['postPath']}', // Complete URL
                'username': post['likeCount'] > 1
                    ? post['likeCount'].toString() + " Likes"
                    : post['likeCount'].toString() +
                        " Like", // Using phone as username

                'postId': post['postId'],
                'postType': post['postType'],
              };
            }).toList();
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = jsonData['message'];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load posts: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : GridView.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 1,
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
