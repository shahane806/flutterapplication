import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:visibility_detector/visibility_detector.dart';
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

  List<Map<String, String>> searchResults = [];
  File? _videoFile;
  File? _imageFile;
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load posts: $e')),
        );
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
      setState(() {
        _videoFile = File(pickedFile.path);
        context
            .read<UploadVideoPostBloc>()
            .add(UploadVideoPostEvent(isUploaded: true));
      });
    }
  }

  Future<void> pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        context
            .read<UploadImagePostBloc>()
            .add(UploadImagePostEvent(isUploaded: true));
      });
    }
  }

  void _handleSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        searchResults = [];
      } else {
        searchResults = allUsers
            .where((user) =>
                user['username']!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _showSearchBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _handleSearch('');
                        setModalState(() {});
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  onChanged: (value) {
                    _handleSearch(value);
                    setModalState(() {});
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: searchResults.isEmpty && _searchController.text.isEmpty
                      ? const Center(child: Text('Start typing to search'))
                      : searchResults.isEmpty
                          ? const Center(child: Text('No users found'))
                          : ListView.builder(
                              itemCount: searchResults.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        searchResults[index]['image']!),
                                  ),
                                  title:
                                      Text(searchResults[index]['username']!),
                                  onTap: () => Navigator.pop(context),
                                );
                              },
                            ),
                ),
              ],
            ),
          );
        },
      ),
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
            Container(
              height: MediaQuery.of(context).size.height * 0.18,
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.015),
              color: Colors.grey[200],
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.02),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [
                                const Color.fromARGB(197, 135, 51, 150),
                                const Color.fromARGB(112, 68, 167, 249)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.16,
                            height: MediaQuery.of(context).size.height * 0.10,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                _userProfilePics['user_$index'] ?? '',
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                      child: CircularProgressIndicator());
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.person, size: 40),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01),
                        Text(
                          'User$index',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.035,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
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
                      phone,
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
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('Reported')));
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
                        ? Container(
                            color: Colors.grey[300],
                            child: Center(child: Text('Video Placeholder')),
                          )
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
                        onPressed: () => createImagePost(context, _imageFile),
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
                        onPressed: () => createVideoPost(context, _videoFile),
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
                        onPressed: () => createTextPost(context,
                            titleController.text, messageController.text),
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

  Future<void> createImagePost(BuildContext context, File? imageFile) async {
    if (imageFile == null) return;
    final uri = Uri.parse("${Apis.BaseUrl}SocialMediaApis/uploadImagePost.php");
    var request = http.MultipartRequest('POST', uri)
      ..fields['MOBILE'] = UserData.phone ?? ""
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    final response = await request.send();
    if (response.statusCode == 200) {
      _refreshPosts();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Upload failed')));
    }
  }

  Future<void> createVideoPost(BuildContext context, File? videoFile) async {
    if (videoFile == null) return;
    final uri = Uri.parse("${Apis.BaseUrl}SocialMediaApis/post.php");
    var request = http.MultipartRequest('POST', uri)
      ..fields['MOBILE'] = UserData.phone ?? ""
      ..fields['POST_TYPE'] = 'video'
      ..files.add(await http.MultipartFile.fromPath('file', videoFile.path));
    final response = await request.send();
    print("${response.statusCode}");
    if (response.statusCode == 200) {
      _refreshPosts();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Upload failed')));
    }
  }

  Future<void> createTextPost(
      BuildContext context, String title, String message) async {
    final uri = Uri.parse("${Apis.BaseUrl}SocialMediaApis/uploadTextPost.php");
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        "MOBILE": UserData.phone ?? "",
        "TITLE": title,
        "MESSAGE": message,
      },
    );
    if (response.statusCode == 200) {
      _refreshPosts();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Upload failed')));
    }
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
