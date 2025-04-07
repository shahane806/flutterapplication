import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socialmedia/Handlers/BaseUrl.dart';
import 'package:socialmedia/Handlers/UserData.dart';
import 'package:socialmedia/Screens/ImageViewerScreen/ImageViewerScreen.dart';
import 'package:socialmedia/Screens/VideoPlayerScreen/Components/VideoPlayerScreen.dart';
import 'package:video_player/video_player.dart'; // Added video_player import
import 'package:firebase_database/firebase_database.dart';
import '../../ApiServices/ApiServices.dart'; // Added ApiServices import
import '../../../AlertHandler/alertHandler.dart'; // Added AlertHandler import

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
    print('Initializing LikedPostsTab');
    fetchLikedPosts();
  }

  Future<void> fetchLikedPosts() async {
    print('Starting fetchLikedPosts');
    try {
      print(
          'Sending request to ${Apis.BaseUrl}/SocialMediaApis/getLikedPost.php with MOBILE: ${UserData.phone}');
      final response = await http.post(
        Uri.parse('${Apis.BaseUrl}/SocialMediaApis/getLikedPost.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'MOBILE': UserData
              .phone, // Replace with actual phone number variable if needed
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('Decoded JSON: $jsonData');
        if (jsonData['status'] == 200) {
          // Fetch liked posts from API
          List<Map<String, dynamic>> tempPosts =
              List<Map<String, dynamic>>.from(jsonData['data']).map((post) {
            String mediaUrl =
                '${Apis.BaseUrl}SocialMediaApis/${post['postPath'] ?? ''}'; // Fallback to empty string
            print(
                'Processing postId ${post['postId']} - Media URL: $mediaUrl, postType: ${post['postType']}');
            return {
              'image': mediaUrl,
              'username':
                  post['likeCount']?.toString() ?? '0', // Fallback to '0'
              'postId':
                  post['postId']?.toString() ?? '', // Fallback to empty string
              'postType':
                  post['postType'] ?? 'unknown', // Fallback to 'unknown'
              'likeCount': post['likeCount'] ?? 0, // Fallback to 0
              'thumbnail': null, // Placeholder for thumbnail widget
              'postPath': post['postPath'] ?? '', // Fallback to empty string
            };
          }).toList();

          print('Fetched ${tempPosts.length} posts');
          setState(() {
            likedPosts = tempPosts;
            isLoading = false;
          });
        } else {
          print('API status not 200: ${jsonData['message']}');
          setState(() {
            errorMessage = jsonData['message'] ?? 'Unknown error';
            isLoading = false;
          });
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        setState(() {
          errorMessage = 'Failed to load posts: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error in fetchLikedPosts: $e');
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> dislikePost(BuildContext context, String postId,
      String? postPath, String? postType) async {
    print('Starting dislikePost for postId: $postId');
    try {
      final currentUserPhone = UserData.phone ?? '';
      if (currentUserPhone.isEmpty) {
        throw Exception("Current user phone not available in UserData");
      }

      // Reference to Firebase post
      final postRef =
          FirebaseDatabase.instance.ref().child('posts').child(postId);
      print('Firebase ref set to: posts/$postId');

      // Remove the entire post from Firebase
      await postRef.remove();
      print('Firebase: Entire post removed for postId: $postId');

      // Sync with server using your provided dislike API
      print("Post ID: $postId, Phone: $currentUserPhone");
      var response = await http.post(
        Uri.parse(Apis.BaseUrl + "SocialMediaApis/post.php"),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "API_TYPE": "DisLikedPost",
          "POST_ID": postId,
          "MOBILE": currentUserPhone,
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        AlertHandler.showSuccessSnackBar(context, "DisLiked Post");
        // Remove post from likedPosts after successful server response
        setState(() {
          likedPosts.removeWhere((p) => p['postId'] == postId);
        });
        print('Post removed from likedPosts list: $postId');
      } else {
        AlertHandler.showErrorSnackBar(context, "DisLiked Post Failed");
      }
    } catch (e) {
      print('Error in dislikePost: $e');
      AlertHandler.showErrorSnackBar(context, "Error disliking post: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
        'Building LikedPostsTab - isLoading: $isLoading, likedPosts length: ${likedPosts.length}');
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
                    final post = likedPosts[index];
                    print(
                        'Building item $index - postId: ${post['postId']}, postType: ${post['postType']}, URL: ${post['image']}');
                    if (post['postType'] == 'video') {
                      print('Rendering video for postId: ${post['postId']}');
                      // Use VideoThumbnailWidget with play button overlay like UserDashboard
                      post['displayImage'] = Stack(
                        alignment: Alignment.center,
                        children: [
                          VideoThumbnailWidget(videoUrl: post['image']),
                          Icon(
                            Icons.play_circle_outline,
                            size: 60,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ],
                      );
                    } else {
                      print('Rendering image for postId: ${post['postId']}');
                      // Use Image.network for image posts with enhanced error handling
                      print('Loading image from: ${post['image']}');
                      post['displayImage'] = Image.network(
                        post['image'],
                        fit: BoxFit.cover,
                        width: 200,
                        height: 200,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            print(
                                'Image loaded successfully: ${post['image']}');
                            return child;
                          }
                          return Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print(
                              'Image load failed for ${post['image']}: $error');
                          return Container(
                            width: 200,
                            height: 200,
                            color: Colors.grey[300],
                            child: Center(
                              child: Text(
                                'Invalid image: ${error.toString().split(':').last.trim()}',
                                style:
                                    TextStyle(color: Colors.red, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      );
                    }
                    return buildGridItem(context, post);
                  },
                ),
    );
  }
}

// Custom widget for video thumbnail generation (aligned with UserDashboard)
class VideoThumbnailWidget extends StatefulWidget {
  final String videoUrl;

  const VideoThumbnailWidget({required this.videoUrl});

  @override
  _VideoThumbnailWidgetState createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    print('Initializing VideoThumbnailWidget with URL: ${widget.videoUrl}');
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        if (mounted) {
          print('Video initialized successfully for ${widget.videoUrl}');
          setState(() {
            _isInitialized = true;
          });
          _controller.seekTo(Duration(seconds: 2)).then((_) {
            print('Seeked to 2 seconds for ${widget.videoUrl}');
            _controller.pause().then((_) {
              print('Video paused for ${widget.videoUrl}');
            });
          });
        }
      }).catchError((error) {
        print('Error initializing video for thumbnail: $error');
        if (mounted) {
          setState(() {
            _isInitialized = false;
            _errorMessage = error.toString();
          });
        }
      });
  }

  @override
  void dispose() {
    print('Disposing VideoThumbnailWidget for ${widget.videoUrl}');
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(
        'Building VideoThumbnailWidget - isInitialized: $_isInitialized, error: $_errorMessage');
    if (_isInitialized) {
      return Container(
        width: 200, // Adjusted for grid
        height: 200, // Adjusted for grid
        child: ClipRect(
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
        ),
      );
    } else if (_errorMessage.isNotEmpty) {
      return Container(
        width: 200,
        height: 200,
        color: Colors.grey[300],
        child: Center(
          child: Text(
            'Video error: $_errorMessage',
            style: TextStyle(color: Colors.red, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      return Container(
        width: 200,
        height: 200,
        color: Colors.grey[300],
        child: Center(child: CircularProgressIndicator()),
      );
    }
  }
}

// Updated buildGridItem function to handle both video and image widgets with Firebase likeCount and dustbin button
Widget buildGridItem(BuildContext context, Map<String, dynamic> post) {
  print(
      'Rendering buildGridItem for postId: ${post['postId']}, type: ${post['postType']}');
  return GestureDetector(
    onTap: () {
      if (post['postType'] == 'video') {
        print(
            'Tapped on video postId: ${post['postId']} - URL: ${post['image']}');
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    VideoPlayerScreen(url: '${post['image']}')));
        // Handle video post tap (e.g., navigate to video player screen)
      } else if (post['postType'] == 'image') {
        // Handle image post tap (e.g., navigate to image viewer screen)
        print('Tapped on image postId: ${post['postId']}');
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ImageViewerScreen(url: '${post['image']}')));
      }
    },
    child: Container(
      width: 200,
      height: 200,
      child: Stack(
        children: [
          // Media content (image or video thumbnail)
          Container(
            width: 200,
            height: 200,
            child: post['displayImage'], // Render the image or video thumbnail
          ),
          // Like count overlay in bottom-left corner
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black
                    .withOpacity(0.5), // Semi-transparent background
                borderRadius: BorderRadius.circular(12),
              ),
              child: StreamBuilder<DatabaseEvent>(
                stream: FirebaseDatabase.instance
                    .ref()
                    .child('posts')
                    .child(post['postId'].toString())
                    .child('likeCount')
                    .onValue,
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data!.snapshot.value != null) {
                    return Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 16, // Smaller icon for better fit
                        ),
                        SizedBox(width: 4),
                        Text(
                          "${snapshot.data!.snapshot.value}",
                          style: TextStyle(
                            fontSize: 12, // Smaller text for aesthetics
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "0",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          // Dustbin button overlay in bottom-right corner
          Positioned(
            bottom: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                print('Dustbin tapped for postId: ${post['postId']}');
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Confirm Dislike'),
                      content:
                          Text('Are you sure you want to dislike this post?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close dialog
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await dislikePost(
                              context,
                              post['postId'].toString(),
                              UserData.phone,
                            );
                            Navigator.of(context).pop(); // Close dialog
                          },
                          child: Text('Dislike'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
