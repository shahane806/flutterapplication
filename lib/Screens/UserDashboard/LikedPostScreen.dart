import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socialmedia/Handlers/BaseUrl.dart';
import 'package:socialmedia/Handlers/UserData.dart';
import 'package:firebase_database/firebase_database.dart'; // Added Firebase import

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
          // Initialize Firebase reference
          final DatabaseReference postsRef =
              FirebaseDatabase.instance.ref().child('posts');

          // Fetch liked posts from API
          List<Map<String, dynamic>> tempPosts =
              List<Map<String, dynamic>>.from(jsonData['data']).map((post) {
            return {
              'image': '${Apis.BaseUrl}/SocialMediaApis/${post['postPath']}',
              'username': '0', // Initialize username with 0, will update with likeCount
              'postId': post['postId'],
              'postType': post['postType'],
              'likeCount':
                  0, // Initialize likeCount, to be updated from Firebase
            };
          }).toList();

          // Fetch like counts from Firebase for each post
          for (var post in tempPosts) {
            final postId = post['postId'].toString();
            final likeCountSnapshot =
                await postsRef.child(postId).child('likeCount').once();
            if (likeCountSnapshot.snapshot.value != null) {
              int firebaseLikeCount = likeCountSnapshot.snapshot.value as int;
              print(
                  "Fetched likeCount for postId $postId from Firebase: $firebaseLikeCount");
              post['likeCount'] =
                  firebaseLikeCount; // Assign Firebase value to likeCount
              post['username'] =
                  firebaseLikeCount.toString(); // Assign likeCount to username for display
            } else {
              // If no likeCount exists in Firebase, initialize it to 0
              print(
                  "No likeCount found for postId $postId in Firebase, setting to 0");
              await postsRef.child(postId).child('likeCount').set(0);
              post['likeCount'] = 0;
              post['username'] = '0'; // Set username to 0 for display
            }
          }

          setState(() {
            likedPosts = tempPosts;
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