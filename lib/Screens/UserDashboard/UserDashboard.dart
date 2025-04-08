import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import '../../AlertHandler/alertHandler.dart';
import '../../ApiServices/ApiServices.dart';
import '../../Handlers/BaseUrl.dart';
import '../../Handlers/UserData.dart';
import '../../StateManagement/PostStateManagement/Blocs/PostBloc.dart';
import '../../StateManagement/PostStateManagement/Events/PostEvents.dart';
import '../../StateManagement/PostStateManagement/States/PostState.dart';
import '../ImageViewerScreen/ImageViewerScreen.dart';
import '../VideoPlayerScreen/Components/VideoPlayerScreen.dart';
import 'Components/ExitDialogBox.dart';
import 'Components/LikeButton.dart';
import 'Components/ShowActivity.dart';
import 'ProfileScreen.dart';
import 'package:image_picker/image_picker.dart';

// For Android gallery scanning
import 'package:path/path.dart' as path;

// Frontend API for fetching posts
Future<List<dynamic>> fetchPosts({int page = 1, int limit = 10}) async {
  try {
    var response = await http.post(
      Uri.parse("${Apis.BaseUrl}SocialMediaApis/getImagePost.php"),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        "MOBILE": UserData.phone ?? "",
        "PAGE": page.toString(),
        "PAGE_SIZE": limit.toString(),
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      if (jsonResponse['status'] == 200 && jsonResponse['data'] is List) {
        return jsonResponse['data'];
      } else {
        throw Exception(
            'Invalid response: ${jsonResponse['message'] ?? 'No posts found'}');
      }
    } else {
      throw Exception('HTTP Error: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('FetchPosts Error: $e');
    rethrow;
  }
}

// Updated search API call with better error handling and debug logging
Future<Map<String, dynamic>> searchContent(String query,
    {int page = 1, int pageSize = 10}) async {
  print(
      'Search Content called with query: $query, page: $page, pageSize: $pageSize');
  try {
    if (UserData.phone == null || UserData.phone!.isEmpty) {
      throw Exception('User phone number is not available');
    }
    print('Searching for: $query, Page: $page, PageSize: $pageSize');
    var response = await http.post(
      Uri.parse("${Apis.BaseUrl}SocialMediaApis/searchUser.php"),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        "MOBILE": UserData.phone!,
        "QUERY": query,
        "PAGE": page.toString(),
        "PAGE_SIZE": pageSize.toString(),
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      print('Decoded response: $jsonResponse');
      if (jsonResponse['status'] == 200) {
        return {
          'users': jsonResponse['data']['users'] ?? [],
          'posts': jsonResponse['data']['posts'] ?? [],
          'debug': jsonResponse['debug'],
          'pagination': jsonResponse['pagination'],
        };
      } else {
        throw Exception('API error: ${jsonResponse['message']}');
      }
    } else {
      throw Exception('HTTP error: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('Search Error: $e');
    return {
      'users': [],
      'posts': [],
      'debug': {'error': e.toString()}
    };
  }
}

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  List<dynamic> searchResults = [];
  File? _videoFile;
  File? _imageFile;
  String? _postContent;
  int _selectedIndex = 0;
  final List<Map<String, String>> allUsers = List.generate(
    20,
    (index) => {
      'username': 'user_$index',
      'image': '',
    },
  );

  final Map<String, String> _userProfilePics = {};
  final String _apiUrl =
      "${Apis.BaseUrl}/SocialMediaApis/updateUserProfile.php";

  List<dynamic> _posts = [];
  int _currentPage = 1;
  final int _limit = 5;
  bool _isFetching = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  bool _isSearching = false; // Added for loading state
  int _searchPage = 1; // Added for pagination

  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child('posts');

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isFetching &&
          _hasMore) {
        _fetchMorePosts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _commentController.dispose();
    _searchController.dispose();
    titleController.dispose();
    messageController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await _fetchPosts();
  }

  Future<void> _fetchUserProfilePic(String phone) async {
    if (_userProfilePics.containsKey(phone)) return;

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        body: {
          'MOBILE': phone,
          'FUNCTION_TYPE': 'getUserProfileData',
        },
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 200 && data['data']['profilePicturePath'] != null) {
        setState(() {
          _userProfilePics[phone] =
              "${Apis.BaseUrl}/SocialMediaApis/${data['data']['profilePicturePath']}";
        });
      }
    } catch (e) {
      print('Error fetching profile pic for $phone: $e');
    }
  }

  Future<void> _fetchPosts() async {
    if (_isFetching || !mounted) return;
    setState(() {
      _isFetching = true;
    });
    try {
      final newPosts = await fetchPosts(page: _currentPage, limit: _limit);
      final response = await http.post(
        Uri.parse("${Apis.BaseUrl}SocialMediaApis/getImagePost.php"),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "MOBILE": UserData.phone ?? "",
          "PAGE": _currentPage.toString(),
          "PAGE_SIZE": _limit.toString(),
        },
      );
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final totalPages = jsonResponse['pagination']?['totalPages'] ?? 1;

      for (var post in newPosts) {
        if (post['id'] == null) continue;
        final postRef = _database.child(post['id'].toString());
        final snapshot = await postRef.child('likeCount').once();
        if (!snapshot.snapshot.exists) {
          await postRef.child('likeCount').set(0);
        }
      }

      if (mounted) {
        setState(() {
          _posts.addAll(newPosts);
          _currentPage++;
          _hasMore = _currentPage <= totalPages && newPosts.isNotEmpty;
        });
      }
    } catch (e) {
      print('Error fetching posts: $e');
      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Failed to load posts: $e')),
        // );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetching = false;
        });
      }
    }
  }

  Future<void> _fetchMorePosts() async {
    await _fetchPosts();
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _posts.clear();
      _currentPage = 1;
      _hasMore = true;
    });
    await _fetchPosts();
  }

  Future<void> _shareToWhatsApp(int postIndex, BuildContext context) async {
    final String postUrl = 'https://socialgreet.com/post/$postIndex';
    final String message =
        'Check out this awesome post on Social Greet!\n$postUrl';
    final String whatsappUrl =
        'whatsapp://send?text=${Uri.encodeComponent(message)}';

    try {
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('WhatsApp not installed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing: $e')),
      );
    }
  }

  Future<void> pickVideo(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      final tempDir = await getTemporaryDirectory();
      final originalFile = File(pickedFile.path);
      final newFilePath =
          '${tempDir.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      _videoFile = await originalFile.copy(newFilePath);

      setState(() {
        _videoFile = _videoFile;
      });
      _showContentDialog(context, isVideo: true);
    }
  }

  Future<void> pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _showContentDialog(context, isVideo: false);
    }
  }

  void _showContentDialog(BuildContext context, {required bool isVideo}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isVideo ? 'Add Video Content' : 'Add Image Content'),
        content: TextField(
          controller: _contentController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter content here',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                if (isVideo)
                  _videoFile = null;
                else
                  _imageFile = null;
                _postContent = null;
              });
              _contentController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_contentController.text.isNotEmpty) {
                setState(() {
                  _postContent = _contentController.text;
                  if (isVideo) {
                    context
                        .read<UploadVideoPostBloc>()
                        .add(UploadVideoPostEvent(isUploaded: true));
                  } else {
                    context
                        .read<UploadImagePostBloc>()
                        .add(UploadImagePostEvent(isUploaded: true));
                  }
                });
                _contentController.clear();
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter content')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> createImagePost(
      BuildContext context, File? imageFile, String? username) async {
    if (imageFile == null || _postContent == null) {
      AlertHandler.showErrorSnackBar(context, "Image or content missing");
      return;
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("${Apis.BaseUrl}SocialMediaApis/post.php"),
      );

      request.fields['POST_TYPE'] = 'image';
      request.fields['MOBILE'] = UserData.phone ?? '';
      request.fields['POST_CONTENT'] = _postContent!;
      request.fields['USERNAME'] = username ?? '';
      request.files
          .add(await http.MultipartFile.fromPath('file', imageFile.path));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200 && jsonResponse['status'] == 200) {
        AlertHandler.showSuccessSnackBar(
            context, "Image post uploaded successfully");
        setState(() {
          _imageFile = null;
          _postContent = null;
          context
              .read<UploadImagePostBloc>()
              .add(UploadImagePostEvent(isUploaded: false));
        });
        _refreshPosts();
        Navigator.of(context).pop();
      } else {
        AlertHandler.showErrorSnackBar(context,
            "Failed to upload image post: ${jsonResponse['message'] ?? 'Unknown error'}");
      }
    } catch (e) {
      print('Error uploading image post: $e');
      AlertHandler.showErrorSnackBar(context, "Error uploading image post: $e");
    }
  }

  Future<void> createVideoPost(
      BuildContext context, File? videoFile, String? username) async {
    if (videoFile == null || _postContent == null) {
      AlertHandler.showErrorSnackBar(context, "Video or content missing");
      return;
    }

    try {
      if (!await videoFile.exists()) {
        throw Exception("Video file not found at ${videoFile.path}");
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("${Apis.BaseUrl}SocialMediaApis/post.php"),
      );

      request.fields['POST_TYPE'] = 'video';
      request.fields['MOBILE'] = UserData.phone ?? '';
      request.fields['POST_CONTENT'] = _postContent!;
      request.fields['USERNAME'] = username ?? '';
      request.files
          .add(await http.MultipartFile.fromPath('file', videoFile.path));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200 && jsonResponse['status'] == 200) {
        AlertHandler.showSuccessSnackBar(
            context, "Video post uploaded successfully");
        setState(() {
          _videoFile = null;
          _postContent = null;
          context
              .read<UploadVideoPostBloc>()
              .add(UploadVideoPostEvent(isUploaded: false));
        });
        _refreshPosts();
        Navigator.of(context).pop();
      } else {
        print("${jsonResponse['message']}");
        AlertHandler.showErrorSnackBar(context,
            "Failed to upload video post: ${jsonResponse['message'] ?? 'Unknown error'}");
      }
    } catch (e) {
      print('Error uploading video post: $e');
      AlertHandler.showErrorSnackBar(context, "Error uploading video post: $e");
    }
  }

  // Updated _handleSearch for immediate reflection
  Future<void> _handleSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      searchResults = []; // Clear results immediately
    });

    final results = await searchContent(query, page: _searchPage);

    if (mounted) {
      setState(() {
        searchResults = [
          ...results['users'].map((user) => {'type': 'user', 'data': user}),
          ...results['posts'].map((post) => {'type': 'post', 'data': post})
        ];
        _isSearching = false;
      });
    }
  }

  // Updated _showSearchBottomSheet to reflect changes instantly
  void _showSearchBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext modalContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search posts or users...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _handleSearch('');
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    onChanged: (value) async {
                      await _handleSearch(value);
                      setModalState(() {}); // Force bottom sheet rebuild
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _isSearching
                        ? const Center(child: CircularProgressIndicator())
                        : searchResults.isEmpty &&
                                _searchController.text.isEmpty
                            ? const Center(
                                child: Text('Start typing to search'))
                            : searchResults.isEmpty
                                ? const Center(child: Text('No results found'))
                                : ListView.builder(
                                    itemCount: searchResults.length,
                                    itemBuilder: (context, index) {
                                      final result = searchResults[index];
                                      if (result['type'] == 'user') {
                                        return ListTile(
                                          leading: CircleAvatar(
                                            backgroundImage: result['data'][
                                                        'profilePicturePath'] !=
                                                    null
                                                ? NetworkImage(
                                                    "${Apis.BaseUrl}/SocialMediaApis/${result['data']['profilePicturePath']}")
                                                : null,
                                            child: result['data'][
                                                        'profilePicturePath'] ==
                                                    null
                                                ? const Icon(Icons.person)
                                                : null,
                                          ),
                                          title: Text(result['data']
                                                  ['userName'] ??
                                              'Unknown'),
                                          subtitle: const Text('User'),
                                          onTap: () {
                                            Navigator.pop(modalContext);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ProfileScreen(
                                                  username: result['data']
                                                          ['userName'] ??
                                                      '',
                                                  mobile: result['data']
                                                          ['phone'] ??
                                                      '',
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      } else {
                                        return ListTile(
                                          leading: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                "${Apis.BaseUrl}SocialMediaApis/${result['data']['postPath'] ?? ''}"),
                                          ),
                                          title: Text(result['data']
                                                  ['content'] ??
                                              'No content'),
                                          subtitle: Text(
                                              'Post by ${result['data']['username'] ?? 'Unknown'}'),
                                          onTap: () {
                                            _viewMedia(
                                              context,
                                              "${Apis.BaseUrl}SocialMediaApis/${result['data']['postPath'] ?? ''}",
                                              result['data']['postType'] ==
                                                  'video',
                                            );
                                          },
                                        );
                                      }
                                    },
                                  ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _viewMedia(BuildContext context, String url, bool isVideo) {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid media URL')),
      );
      return;
    }
    if (isVideo) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(url: url),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageViewerScreen(url: url),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => await showExitDialog(context),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Social Greet',
              style: TextStyle(fontFamily: 'Billabong', fontSize: 20)),
        ),
        body: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshPosts,
                child: _posts.isEmpty && _isFetching
                    ? Center(child: CircularProgressIndicator())
                    : _posts.isEmpty
                        ? Center(child: Text('No posts yet'))
                        : ListView.builder(
                            controller: _scrollController,
                            cacheExtent: MediaQuery.of(context).size.height,
                            itemCount: _posts.length + (_hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _posts.length) {
                                return Center(
                                    child: CircularProgressIndicator());
                              }
                              return VisibilityDetector(
                                key: Key('post_$index'),
                                onVisibilityChanged: (info) {
                                  if (info.visibleFraction > 0.5) {
                                    _fetchUserProfilePic(
                                        _posts[index]['phone']);
                                  }
                                },
                                child: _buildPostItem(context, index, _posts),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            if (index == 1) {
              _showSearchBottomSheet(context);
            } else if (index == 2) {
              _showPostOptions(context);
            } else if (index == 3) {
              showActivityBottomSheet(context);
            } else if (index == 4) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                      username: UserData.username, mobile: UserData.phone),
                ),
              ).then((_) => _loadInitialData());
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
            BottomNavigationBarItem(
                icon: Icon(Icons.add_box_outlined), label: ''),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border), label: ''),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline), label: ''),
          ],
        ),
      ),
    );
  }

  Widget _buildPostItem(BuildContext context, int index, List<dynamic> posts) {
    final post = posts[index];
    final String mediaUrl =
        Apis.BaseUrl + "SocialMediaApis/" + post['postPath'];
    final bool isVideo = post['postType'] == 'video';
    final String phone = post['phone'] ?? 'user_$index';
    final String username = post['username'] ?? '';

    final List<String> reportOptions = [
      'Abusive or Harmful Behavior',
      'Spam',
      'Impersonation',
      'Hate Speech',
      'Violent or Graphic Content',
      'Sensitive Media',
      'Self-Harm',
      'Misinformation',
      'Other'
    ];

    String? selectedReportReason;
    TextEditingController reportController = TextEditingController();

    Future<void> submitReport(
        String postId, String postPath, String message) async {
      try {
        final response = await http.post(
          Uri.parse("${Apis.BaseUrl}SocialMediaApis/reportPost.php"),
          headers: {"Content-Type": "application/x-www-form-urlencoded"},
          body: {
            "MOBILE": UserData.phone ?? "",
            "postId": postId,
            "postPath": postPath,
            "reportedUser": UserData.username ?? "",
            "reportedMessage": message,
          },
        );

        final jsonResponse = jsonDecode(response.body);
        if (response.statusCode == 200 && jsonResponse['status'] == 200) {
          AlertHandler.showSuccessSnackBar(
              context, "Post reported successfully");
        } else {
          AlertHandler.showErrorSnackBar(context,
              "Failed to report post: ${jsonResponse['message'] ?? 'Unknown error'}");
        }
      } catch (e) {
        AlertHandler.showErrorSnackBar(context, "Error reporting post: $e");
      }
    }

    Future<void> _downloadPost(String url, bool isVideo) async {
      try {
        // Determine the Downloads directory
        Directory? downloadsDir;
        if (Platform.isAndroid) {
          downloadsDir = Directory('/storage/emulated/0/Download');
        } else if (Platform.isIOS) {
          downloadsDir = await getApplicationDocumentsDirectory();
        } else {
          throw Exception('Unsupported platform');
        }

        // Define the base SocialMediaApp directory within Downloads
        final baseDir = Directory('${downloadsDir.path}/SocialMediaApp');
        if (!await baseDir.exists()) {
          await baseDir.create();
        }

        // Define the subfolder based on post type
        final subFolder = isVideo ? 'Videos' : 'Images';
        final mediaDir = Directory('${baseDir.path}/$subFolder');
        if (!await mediaDir.exists()) {
          await mediaDir.create();
        }

        // Generate a unique filename
        final fileExtension = isVideo ? '.mp4' : '.jpg';
        final fileName =
            'post_${post['id']}_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
        final filePath = '${mediaDir.path}/$fileName';

        // Download the file
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          // On Android, notify the media scanner to make the file visible in the gallery
          if (Platform.isAndroid) {
            try {
              await Process.run('am', [
                'broadcast',
                '-a',
                'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
                '-d',
                'file://${file.path}'
              ]);
            } catch (e) {
              print('Error notifying media scanner: $e');
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$subFolder post saved to Downloads')),
          );
        } else {
          throw Exception('Failed to download file: ${response.statusCode}');
        }
      } catch (e) {
        print('Error downloading post: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving post: $e')),
        );
      }
    }

    void showReportDialog() {
      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text('Report Post'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...reportOptions.map((option) => RadioListTile<String>(
                        title: Text(option),
                        value: option,
                        groupValue: selectedReportReason,
                        onChanged: (value) {
                          setState(() {
                            selectedReportReason = value;
                          });
                        },
                      )),
                  if (selectedReportReason == 'Other')
                    TextField(
                      controller: reportController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Please specify your reason',
                        border: OutlineInputBorder(),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  reportController.clear();
                  Navigator.pop(context);
                },
                child: Text('Discard'),
              ),
              TextButton(
                onPressed: () async {
                  if (selectedReportReason != null) {
                    String message = selectedReportReason == 'Other'
                        ? reportController.text
                        : selectedReportReason!;
                    if (message.isNotEmpty) {
                      await submitReport(
                          post['id'].toString(), post['postPath'], message);
                      reportController.clear();
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Please provide a reason for reporting')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please select a reason')),
                    );
                  }
                },
                child: Text('Report'),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.01,
        horizontal: MediaQuery.of(context).size.width * 0.03,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              spreadRadius: 0,
              blurRadius: 6,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.purple, Colors.blue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: MediaQuery.of(context).size.width * 0.06,
                      backgroundImage: _userProfilePics[phone] != null
                          ? NetworkImage(_userProfilePics[phone]!)
                          : null,
                      backgroundColor: Colors.grey[200],
                      child: _userProfilePics[phone] == null
                          ? Icon(Icons.person, size: 30)
                          : null,
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                  Expanded(
                    child: Text(
                      username,
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.045,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_horiz,
                        size: MediaQuery.of(context).size.width * 0.06,
                        color: Colors.grey[600]),
                    onSelected: (value) {
                      if (value == 'report') {
                        showReportDialog();
                      } else if (value == 'save') {
                        _downloadPost(mediaUrl, isVideo);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'report', child: Text('Report')),
                      PopupMenuItem(value: 'save', child: Text('Save')),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _viewMedia(context, mediaUrl, isVideo),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.4,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    isVideo
                        ? VideoThumbnailWidget(videoUrl: mediaUrl)
                        : Image.network(
                            mediaUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(child: CircularProgressIndicator());
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.error),
                          ),
                    if (isVideo)
                      Icon(Icons.play_circle_outline,
                          size: 60, color: Colors.white.withOpacity(0.8)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          LikeButton(
                              postId: post['id'],
                              postPath: post['postPath'],
                              postType: post['postType'],
                              phone: post['phone']),
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [Colors.purple, Colors.blue],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: IconButton(
                              icon: Icon(Icons.chat_bubble_outline,
                                  size:
                                      MediaQuery.of(context).size.width * 0.06,
                                  color: Colors.white),
                              onPressed: () => _showCommentsBottomSheet(
                                  context,
                                  index,
                                  post['id'],
                                  post['postPath'],
                                  post['postType'],
                                  post['phone']),
                            ),
                          ),
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [Colors.purple, Colors.blue],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: IconButton(
                              icon: Icon(Icons.share_outlined,
                                  size:
                                      MediaQuery.of(context).size.width * 0.06,
                                  color: Colors.white),
                              onPressed: () => _shareToWhatsApp(index, context),
                            ),
                          ),
                        ],
                      ),
                      StreamBuilder<DatabaseEvent>(
                        stream: _database
                            .child(post['id'].toString())
                            .child('likeCount')
                            .onValue,
                        builder: (context, snapshot) {
                          if (snapshot.hasData &&
                              snapshot.data!.snapshot.value != null) {
                            return Text(
                              "${snapshot.data!.snapshot.value} Likes",
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.035,
                                  fontWeight: FontWeight.w600),
                            );
                          }
                          return Text(
                            "0 Likes",
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.035,
                                fontWeight: FontWeight.w600),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Text(
                    post['content'] ??
                        'Dropping heat on Social Greet! #Colossal',
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                        color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCommentsBottomSheet(BuildContext context, int postIndex, int postId,
      String postPath, String postType, String phone) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsBottomSheet(
        postId: postId,
        postPath: postPath,
        postType: postType,
        phone: phone,
        userProfilePics: _userProfilePics,
      ),
    );
  }

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocBuilder<UploadImagePostBloc, UploadImagePostState>(
              builder: (context, state) => ListTile(
                leading: const Icon(Icons.photo),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (state.isUploaded)
                      const Icon(Icons.verified, color: Colors.blue),
                    IconButton(
                        onPressed: () => createImagePost(
                            context, _imageFile, UserData.username),
                        icon: const Icon(Icons.upload)),
                  ],
                ),
                title: const Text('Create Photo Post'),
                onTap: () => pickImage(context),
              ),
            ),
            BlocBuilder<UploadVideoPostBloc, UploadVideoPostState>(
              builder: (context, state) => ListTile(
                leading: const Icon(Icons.video_call),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (state.isUploaded)
                      const Icon(Icons.verified, color: Colors.blue),
                    IconButton(
                        onPressed: () => createVideoPost(
                            context, _videoFile, UserData.username),
                        icon: const Icon(Icons.upload)),
                  ],
                ),
                title: const Text('Create Video Post'),
                onTap: () => pickVideo(context),
              ),
            ),
            BlocBuilder<UploadTextPostBloc, UploadTextPostState>(
              builder: (context, state) => ListTile(
                leading: const Icon(Icons.text_fields),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (state.isUploaded)
                      const Icon(Icons.verified, color: Colors.blue),
                    IconButton(
                        onPressed: () => createTextPost(
                            context,
                            titleController.text,
                            messageController.text,
                            UserData.username),
                        icon: const Icon(Icons.upload)),
                  ],
                ),
                title: const Text('Create Text Post'),
                onTap: () => showCreateTextPostDialog(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showCreateTextPostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.5,
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Create Text Post',
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.06,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                    labelText: 'Title', border: OutlineInputBorder()),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Expanded(
                child: TextField(
                  controller: messageController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                      labelText: 'Message', border: OutlineInputBorder()),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      titleController.clear();
                      messageController.clear();
                      context
                          .read<UploadTextPostBloc>()
                          .add(UploadTextPostEvent(isUploaded: false));
                      Navigator.pop(context);
                    },
                    child: const Text('Discard'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isNotEmpty &&
                          messageController.text.isNotEmpty) {
                        context
                            .read<UploadTextPostBloc>()
                            .add(UploadTextPostEvent(isUploaded: true));
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Please fill all fields")));
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> createTextPost(BuildContext context, String title,
      String message, String? username) async {
    if (title.isEmpty || message.isEmpty) {
      AlertHandler.showErrorSnackBar(context, "Title or message missing");
      return;
    }

    try {
      var response = await http.post(
        Uri.parse("${Apis.BaseUrl}SocialMediaApis/post.php"),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          'POST_TYPE': 'text',
          'Mobile': UserData.phone ?? '',
          'POST_CONTENT': '$title\n$message',
          'USERNAME': username ?? '',
        },
      );

      var jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonResponse['status'] == 200) {
        AlertHandler.showSuccessSnackBar(
            context, "Text post uploaded successfully");
        setState(() {
          context
              .read<UploadTextPostBloc>()
              .add(UploadTextPostEvent(isUploaded: false));
        });
        _refreshPosts();
        Navigator.of(context).pop();
      } else {
        AlertHandler.showErrorSnackBar(context,
            "Failed to upload text post: ${jsonResponse['message'] ?? 'Unknown error'}");
      }
    } catch (e) {
      print('Error uploading text post: $e');
      AlertHandler.showErrorSnackBar(context, "Error uploading text post: $e");
    }
  }
}

class VideoThumbnailWidget extends StatefulWidget {
  final String videoUrl;

  const VideoThumbnailWidget({required this.videoUrl});

  @override
  _VideoThumbnailWidgetState createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller.seekTo(Duration(seconds: 2));
        }
      }).catchError((error) {
        print('Error initializing video for thumbnail: $error');
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isInitialized
        ? Container(
            height: MediaQuery.of(context).size.height * 0.4,
            width: double.infinity,
            child: ClipRect(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),
          )
        : Container(
            height: MediaQuery.of(context).size.height * 0.4,
            width: double.infinity,
            color: Colors.grey[300],
            child: Center(child: CircularProgressIndicator()),
          );
  }
}

class CommentsBottomSheet extends StatefulWidget {
  final int postId;
  final String postPath;
  final String postType;
  final String phone;
  final Map<String, String> userProfilePics;

  const CommentsBottomSheet({
    required this.postId,
    required this.postPath,
    required this.postType,
    required this.phone,
    required this.userProfilePics,
  });

  @override
  _CommentsBottomSheetState createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final DatabaseReference _commentsRef =
      FirebaseDatabase.instance.ref().child('posts');

  Future<void> _addComment() async {
    if (_commentController.text.isNotEmpty) {
      final newCommentRef =
          _commentsRef.child(widget.postId.toString()).child('comments').push();
      await newCommentRef.set({
        'username': UserData.username,
        'comment': _commentController.text,
        'phone': UserData.phone,
        'timestamp': ServerValue.timestamp,
      });
      _commentController.clear();
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8 +
          MediaQuery.of(context).viewInsets.bottom,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.015,
              horizontal: MediaQuery.of(context).size.width * 0.04,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Comments',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.grey[600]),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: _commentsRef
                  .child(widget.postId.toString())
                  .child('comments')
                  .orderByChild('timestamp')
                  .onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData &&
                    snapshot.data!.snapshot.value != null) {
                  final commentsData = Map<String, dynamic>.from(
                      snapshot.data!.snapshot.value as Map);
                  final commentsList = commentsData.entries.map((entry) {
                    final comment = Map<String, dynamic>.from(entry.value);
                    return {
                      'id': entry.key,
                      'username': comment['username'] ?? UserData.username,
                      'comment': comment['comment'] ?? '',
                      'phone': comment['phone'] ?? '',
                      'timestamp': comment['timestamp'] ?? 0,
                    };
                  }).toList()
                    ..sort((a, b) => (a['timestamp'] as int)
                        .compareTo(b['timestamp'] as int));

                  if (commentsList.isEmpty) {
                    return Center(child: Text('Be the first to comment!'));
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    itemCount: commentsList.length,
                    itemBuilder: (context, index) {
                      final comment = commentsList[index];
                      return AnimatedCommentItem(
                        username: comment['username'],
                        comment: comment['comment'],
                        index: index,
                        profilePicUrl: widget.userProfilePics[comment['phone']],
                      );
                    },
                  );
                }
                return Center(child: Text('Be the first to comment!'));
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 15,
              left: 15,
              right: 15,
              top: 10,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: widget.userProfilePics[UserData.phone] !=
                          null
                      ? NetworkImage(widget.userProfilePics[UserData.phone]!)
                      : null,
                  backgroundColor: Colors.grey[200],
                  child: widget.userProfilePics[UserData.phone] == null
                      ? Icon(Icons.person, size: 20)
                      : null,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedCommentItem extends StatelessWidget {
  final String username;
  final String comment;
  final int index;
  final String? profilePicUrl;

  const AnimatedCommentItem({
    required this.username,
    required this.comment,
    required this.index,
    this.profilePicUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage:
                  profilePicUrl != null ? NetworkImage(profilePicUrl!) : null,
              backgroundColor: Colors.grey[200],
              child:
                  profilePicUrl == null ? Icon(Icons.person, size: 25) : null,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(username,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  SizedBox(height: 4),
                  Text(comment, style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
