import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../AlertHandler/alertHandler.dart';
import '../../../Handlers/BaseUrl.dart';

class LikeButton extends StatefulWidget {
  final int postId;
  final String postPath;
  final String postType;
  final String phone;

  const LikeButton({
    Key? key,
    required this.postId,
    required this.postPath,
    required this.postType,
    required this.phone,
  }) : super(key: key);

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool isLiked = false; // Track like status
  int likeCount = 0; // Track like count

  @override
  void initState() {
    super.initState();
    checkLikeStatus(); // Fetch initial status
  }

  // Fetch Like Status from new API
  Future<void> checkLikeStatus() async {
    try {
      var response = await http.post(
        Uri.parse("http://192.168.1.180:9003/SocialMediaApis/getLikedPost.php"),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "MOBILE": widget.phone,
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("GetLikedPost Response: $data"); // Debug server response
        setState(() {
          // Check if the response contains 'data' and it's a list
          if (data.containsKey('data') && data['data'] is List) {
            List likedPosts = data['data'];
            // Check if the current postId exists in the liked posts
            isLiked = likedPosts.any((post) =>
                post['postId'].toString() == widget.postId.toString());
          } else {
            isLiked = false; // Default to false if no data or unexpected format
          }
          // likeCount is not provided by this API, so it remains 0 unless updated elsewhere
        });
        print(
            "Updated State - isLiked: $isLiked, likeCount: $likeCount"); // Debug state
      } else {
        print("Status Code Error: ${response.statusCode}");
        AlertHandler.showErrorSnackBar(
            context, "Failed to fetch like status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching status: $e");
      AlertHandler.showErrorSnackBar(context, "Error: $e");
    }
  }

  // Toggle Like/Dislike
  Future<void> toggleLike() async {
    bool previousLikeState = isLiked;

    // Optimistically update UI
    setState(() {
      isLiked = !isLiked;
      likeCount =
          isLiked ? likeCount + 1 : likeCount - 1; // Update count locally
    });

    try {
      if (isLiked) {
        await likePost();
      } else {
        await dislikePost();
      }
      // Refresh status from server after toggle
      await checkLikeStatus();
    } catch (e) {
      // Rollback if API fails
      setState(() {
        isLiked = previousLikeState;
        likeCount = isLiked ? likeCount + 1 : likeCount - 1;
      });
      print("Toggle Error: $e");
      AlertHandler.showErrorSnackBar(
          context, "Failed to update like status: $e");
    }
  }

  // Like the post
  Future<void> likePost() async {
    var response = await http.post(
      Uri.parse("${Apis.BaseUrl}SocialMediaApis/post.php"),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        "API_TYPE": "liked",
        "POST_ID": widget.postId.toString(),
        "POST_TYPE": widget.postType,
        "POST_PATH": widget.postPath,
        "MOBILE": widget.phone,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
          "Failed to like post: ${response.statusCode} - ${response.body}");
    }
  }

  // Dislike the post
  Future<void> dislikePost() async {
    var response = await http.post(
      Uri.parse("${Apis.BaseUrl}SocialMediaApis/post.php"),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        "API_TYPE": "DisLikedPost",
        "POST_ID": widget.postId.toString(),
        "MOBILE": widget.phone,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
          "Failed to dislike post: ${response.statusCode} - ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Building - isLiked: $isLiked, likeCount: $likeCount"); // Debug build
    return Row(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: isLiked
                ? [Colors.red, Colors.redAccent] // Red when liked
                : [Colors.purple, Colors.blue], // Normal when not liked
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: IconButton(
            icon: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              size: MediaQuery.of(context).size.width * 0.06,
              color: Colors.white,
            ),
            onPressed: toggleLike,
          ),
        ),
      ],
    );
  }
}
