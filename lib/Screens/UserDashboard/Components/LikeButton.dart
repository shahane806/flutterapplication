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
  bool isLiked = false;  // Track like status
  int likeCount = 0;      // Track like count

  @override
  void initState() {
    super.initState();
    checkLikeStatus();
  }

  // ✅ Check Like Status and Count
  Future<void> checkLikeStatus() async {
    try {
      var response = await http.post(
        Uri.parse("${Apis.BaseUrl}SocialMediaApis/checkLikeStatus.php"),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "POST_ID": widget.postId.toString(),
          "MOBILE": widget.phone,
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        setState(() {
          isLiked = data['isLiked'] ?? false;   // Null safety check
          likeCount = data['likeCount'] ?? 0;   // Default to 0 if null
        });
      } else {
        AlertHandler.showErrorSnackBar(context, "Failed to fetch like status");
      }
    } catch (e) {
      AlertHandler.showErrorSnackBar(context, "Error: ${e.toString()}");
    }
  }

  // ✅ Toggle Like/Dislike
  Future<void> toggleLike() async {
    // Optimistically update UI before the API response
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });

    try {
      if (isLiked) {
        await likePost();
      } else {
        await dislikePost();
      }
    } catch (e) {
      // Rollback the UI update if the API fails
      setState(() {
        isLiked = !isLiked;
        likeCount += isLiked ? 1 : -1;
      });

      AlertHandler.showErrorSnackBar(context, "Failed to update like status");
    }
  }

  // ✅ Like the post
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
      throw Exception("Failed to like post");
    }
  }

  // ✅ Dislike the post
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
      throw Exception("Failed to dislike post");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: isLiked ? [Colors.red, Colors.redAccent] : [Colors.purple, Colors.blue],
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
        Text(
          '$likeCount likes',
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.035,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
