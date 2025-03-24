import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
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
  File? _ImageFile;
  int _selectedIndex = 0;
  final List<Map<String, String>> allUsers = List.generate(
    20,
    (index) => {
      'username': 'user_$index',
      'image': '',
    },
  );
  @override
  void initState() {
    super.initState();
  }

  final Map<String, VideoPlayerController> _videoControllers = {};

  @override
  void dispose() {
    _videoControllers.values.forEach((controller) => controller.dispose());
    _videoControllers.clear();
    super.dispose();
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
        _ImageFile = File(pickedFile.path);
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
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
                                '',
                                fit: BoxFit.cover,
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
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: fetchPosts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No posts yet'));
                  }

                  final posts = snapshot.data!;
                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return _buildPostItem(context, index, posts);
                    },
                  );
                },
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
              if (index == 1)
                _showSearchBottomSheet(context);
              else if (index == 2)
                _showPostOptions(context);
              else if (index == 3)
                showActivityBottomSheet(context);
              else if (index == 4) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfileScreen(
                              username: UserData.username,
                            )));
              }
            });
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

  void _viewMedia(BuildContext context, String url, bool isVideo) {
    if (url.isEmpty) {
      print('Empty media URL');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid media URL')),
      );
      return;
    }
    print('Attempting to view media - URL: $url, IsVideo: $isVideo');
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

  Widget _buildPostItem(BuildContext context, int index, List<dynamic> posts) {
    final post = posts[index];
    final String mediaUrl =
        Apis.BaseUrl + "SocialMediaApis/" + post['postPath'];
    final bool isVideo = post['postType'] == 'video';

    if (isVideo && !_videoControllers.containsKey(mediaUrl)) {
      final controller = VideoPlayerController.networkUrl(Uri.parse(mediaUrl))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
          }
        }).catchError((error) {
          print('Error initializing video for $mediaUrl: $error');
        });
      _videoControllers[mediaUrl] = controller;
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
                      backgroundImage: NetworkImage(''),
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                  Expanded(
                    child: Text(
                      post['phone'] ?? 'user_$index',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.045,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_horiz,
                      size: MediaQuery.of(context).size.width * 0.06,
                      color: Colors.grey[600],
                    ),
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
                        ? (_videoControllers[mediaUrl]?.value.isInitialized ??
                                false)
                            ? VideoPlayer(_videoControllers[mediaUrl]!)
                            : Container(
                                color: Colors.grey[300],
                                child:
                                    Center(child: CircularProgressIndicator()),
                              )
                        : Image.network(
                            mediaUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                    if (isVideo)
                      Icon(
                        Icons.play_circle_outline,
                        size: 60,
                        color: Colors.white.withOpacity(0.8),
                      ),
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
                              icon: Icon(
                                Icons.chat_bubble_outline,
                                size: MediaQuery.of(context).size.width * 0.06,
                                color: Colors.white,
                              ),
                              onPressed: () =>
                                  _showCommentsBottomSheet(context, index),
                            ),
                          ),
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [Colors.purple, Colors.blue],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: IconButton(
                              icon: Icon(
                                Icons.share_outlined,
                                size: MediaQuery.of(context).size.width * 0.06,
                                color: Colors.white,
                              ),
                              onPressed: () => _shareToWhatsApp(index, context),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        post['likeCount'].toString() + " Likes",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.035,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Text(
                    post['content'] ??
                        'Dropping heat on Social Greet! #Colossal',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCommentsBottomSheet(BuildContext context, int postIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8 +
            MediaQuery.of(context).viewInsets.bottom,
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.01,
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
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildCommentItem('friend_1', 'Great post! 😍', context),
                    _buildCommentItem(
                        'friend_2', 'Looking awesome! 🔥', context),
                    _buildCommentItem('user_3', 'Nice one! 👏', context),
                    _buildCommentItem('friend_4', 'Love this! ❤️', context),
                  ],
                ),
              ),
            ),
            Divider(height: 1, color: Colors.grey[300]),
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom +
                    MediaQuery.of(context).size.height * 0.02,
                left: MediaQuery.of(context).size.width * 0.02,
                right: MediaQuery.of(context).size.width * 0.02,
                top: MediaQuery.of(context).size.height * 0.015,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.04,
                    backgroundImage: NetworkImage(''),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.04,
                          vertical: MediaQuery.of(context).size.height * 0.02,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.blue),
                    onPressed: () {
                      if (_commentController.text.isNotEmpty)
                        _commentController.clear();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
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
                        onPressed: () => createImagePost(context, _ImageFile),
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
                  fontWeight: FontWeight.bold,
                ),
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
                              content: Text("Please fill all fields")),
                        );
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

  Widget _buildCommentItem(
      String username, String comment, BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: MediaQuery.of(context).size.width * 0.045,
            backgroundImage:
                NetworkImage('https://via.placeholder.com/150?text=$username'),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.03),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                  Text(
                    comment,
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.035),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          IconButton(
            icon: Icon(
              Icons.favorite_border,
              size: MediaQuery.of(context).size.width * 0.05,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
