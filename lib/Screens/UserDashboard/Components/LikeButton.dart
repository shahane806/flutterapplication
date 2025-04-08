import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import '../../../AlertHandler/alertHandler.dart';
import '../../../Handlers/BaseUrl.dart';
import '../../../Handlers/UserData.dart'; // Import UserData to access current user's phone

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
  bool isLiked = false;
  late DatabaseReference _postRef;

  @override
  void initState() {
    super.initState();
    _postRef = FirebaseDatabase.instance
        .ref()
        .child('posts')
        .child(widget.postId.toString());
    checkLikeStatus();
  }

  Future<void> checkLikeStatus() async {
    try {
      // Use current logged-in user's phone from UserData instead of widget.phone
      final currentUserPhone = UserData.phone ?? '';
      if (currentUserPhone.isEmpty) {
        print("Error: Current user phone not available in UserData");
        return;
      }

      // Check if the current user has liked the post in Firebase
      final likeSnapshot =
          await _postRef.child('likes').child(currentUserPhone).once();
      final likeCountSnapshot = await _postRef.child('likeCount').once();

      setState(() {
        isLiked = likeSnapshot.snapshot.value == true;
        // Update like count from Firebase
        if (likeCountSnapshot.snapshot.value != null) {
          likeCount = likeCountSnapshot.snapshot.value as int;
        } else {
          likeCount = 0; // Default to 0 if not set
          _postRef.child('likeCount').set(0); // Initialize in Firebase
        }
      });

      // Sync with your existing API using the current user's phone
      var response = await http.post(
        Uri.parse("${Apis.BaseUrl}/SocialMediaApis/getLikedPost.php"),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "MOBILE": currentUserPhone, // Use current user's phone
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("GetLikedPost Response: $data");
        if (data.containsKey('data') && data['data'] is List) {
          List likedPosts = data['data'];
          bool apiLiked = likedPosts.any(
              (post) => post['postId'].toString() == widget.postId.toString());
          if (apiLiked != isLiked) {
            // Sync Firebase with API if there's a discrepancy
            await _postRef.child('likes').child(currentUserPhone).set(apiLiked);
            setState(() {
              isLiked = apiLiked;
            });
          }
        }
      } else {
        print("Status Code Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching status: $e");
      AlertHandler.showErrorSnackBar(context, "Error: $e");
    }
  }

  Future<void> toggleLike() async {
    bool previousLikeState = isLiked;
    int previousLikeCount = likeCount;

    // Optimistically update UI
    setState(() {
      isLiked = !isLiked;
      likeCount = isLiked ? likeCount + 1 : likeCount - 1;
    });

    try {
      // Use current logged-in user's phone from UserData
      final currentUserPhone = UserData.phone ?? '';
      if (currentUserPhone.isEmpty) {
        throw Exception("Current user phone not available in UserData");
      }

      // Update Firebase with current user's phone
      await _postRef.child('likes').child(currentUserPhone).set(isLiked);
      await _postRef.child('likeCount').set(likeCount);

      // Sync with your existing API
      if (isLiked) {
        await likePost();
      } else {
        await dislikePost();
      }
    } catch (e) {
      // Rollback if Firebase or API fails
      setState(() {
        isLiked = previousLikeState;
        likeCount = previousLikeCount;
      });
      print("Toggle Error: $e");
      AlertHandler.showErrorSnackBar(
          context, "Failed to update like status: $e");
    }
  }

  Future<void> likePost() async {
    var response = await http.post(
      Uri.parse("${Apis.BaseUrl}SocialMediaApis/post.php"),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        "API_TYPE": "liked",
        "POST_ID": widget.postId.toString(),
        "POST_TYPE": widget.postType,
        "POST_PATH": widget.postPath,
        "MOBILE": UserData.phone ?? '', // Use current user's phone
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
          "Failed to like post: ${response.statusCode} - ${response.body}");
    }
  }

  Future<void> dislikePost() async {
    var response = await http.post(
      Uri.parse("${Apis.BaseUrl}SocialMediaApis/post.php"),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        "API_TYPE": "DisLikedPost",
        "POST_ID": widget.postId.toString(),
        "MOBILE": UserData.phone ?? '', // Use current user's phone
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
          "Failed to dislike post: ${response.statusCode} - ${response.body}");
    }
  }

  int likeCount = 0;

  @override
  Widget build(BuildContext context) {
    print("Building - isLiked: $isLiked, likeCount: $likeCount");
    return Row(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: isLiked
                ? [Colors.red, Colors.redAccent]
                : [Colors.purple, Colors.blue],
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