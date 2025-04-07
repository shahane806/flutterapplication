import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:socialmedia/Handlers/BaseUrl.dart';
import 'package:socialmedia/Handlers/UserData.dart';
import '../../StateManagement/LoginStateManagement/Blocs/LoginBloc.dart';
import '../../StateManagement/LoginStateManagement/Events/LoginEvent.dart';
import '../LoginScreen/LoginScreen.dart';
import 'UserDashboard.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  final String username;
  final String mobile;

  ProfileScreen({super.key, required this.username, required this.mobile});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _username;
  String _bio =
      'Living life one adventure at a time | Travel Enthusiast | Foodie';
  File? _profileImage;
  String _profilePicUrl = '';
  int _likedCount = 0;
  // int _bookmarkedCount = 0;
  int _postsCount = 0;
  bool _isLoading = false;
  bool _isProfilePicLoading = false;
  bool _isOwnProfile =
      false; // Flag to check if it's the logged-in user's profile

  final TextEditingController _bioController = TextEditingController();
  final String _profileApiUrl =
      "${Apis.BaseUrl}/SocialMediaApis/updateUserProfile.php";
  final String _activityCountsApiUrl =
      "${Apis.BaseUrl}/SocialMediaApis/getUserActivityCounts.php";

  // Add a GlobalKey for the Scaffold to ensure correct context
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _username = widget.username;
    _bioController.text = _bio;
    // Check if this is the logged-in user's profile by comparing with UserData.phone
    _isOwnProfile = UserData.phone == widget.mobile;
    print('ProfileScreen initState:');
    print('UserData.phone: ${UserData.phone}');
    print('widget.mobile: ${widget.mobile}');
    print('isOwnProfile: $_isOwnProfile');
    _fetchProfileData();
    _fetchActivityCounts();
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfileData() async {
    setState(() => _isProfilePicLoading = true);
    try {
      final response = await http.post(
        Uri.parse(_profileApiUrl),
        body: {
          'MOBILE': widget.mobile,
          'FUNCTION_TYPE': 'getUserProfileData',
        },
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        setState(() {
          _username = data['data']['userName'] ?? widget.username;
          _bio = data['data']['bio'] ?? _bio;
          _profilePicUrl = data['data']['profilePicturePath'] != null &&
                  data['data']['profilePicturePath'].isNotEmpty
              ? "${Apis.BaseUrl}/SocialMediaApis/${data['data']['profilePicturePath']}"
              : '';
          _bioController.text = _bio;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to fetch profile: ${data['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching profile: $e')),
      );
    } finally {
      setState(() => _isProfilePicLoading = false);
    }
  }

  Future<void> _fetchActivityCounts() async {
    try {
      final response = await http.post(
        Uri.parse(_activityCountsApiUrl),
        body: {
          'phone': widget.mobile,
        },
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        setState(() {
          // _bookmarkedCount = data['data']['bookmarked_count'] ?? 0;
          _likedCount = data['data']['liked_count'] ?? 0;
          _postsCount = data['data']['posts_count'] ?? 0;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to fetch activity counts: ${data['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching activity counts: $e')),
      );
    }
  }

  Future<File?> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<void> _updateProfile(File? image, String bio, String username) async {
    setState(() => _isLoading = true);
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_profileApiUrl));
      request.fields['USER_BIO'] = bio;
      request.fields['USERNAME'] = username;
      request.fields['MOBILE'] = widget.mobile;
      request.fields['FUNCTION_TYPE'] = _profilePicUrl.isEmpty
          ? 'insertUserProfileData'
          : 'updateUserProfileData';

      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'PROFILE_PICTURE',
          image.path,
        ));
      } // If image is null and profilePicUrl exists, API will use existing picture

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);
      final result = jsonDecode(responseData.body);

      if (result['status'] == 200) {
        setState(() {
          _bio = bio;
          _username = username;
          _profileImage = image;
          _profilePicUrl =
              result['file_path']; // Update with returned file path
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showEditProfileDialog() {
    File? tempProfileImage = _profileImage;
    String tempBio = _bio;
    String tempUsername = _username;
    final TextEditingController _usernameController =
        TextEditingController(text: _username);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    File? newImage = await _pickProfileImage();
                    if (newImage != null) {
                      setDialogState(() {
                        tempProfileImage = newImage;
                      });
                    }
                  },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: tempProfileImage != null
                        ? FileImage(tempProfileImage!)
                        : (_profilePicUrl.isNotEmpty
                            ? NetworkImage(_profilePicUrl)
                            : null) as ImageProvider?,
                    child: tempProfileImage == null && _profilePicUrl.isEmpty
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => tempUsername = value,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _bioController,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onChanged: (value) => tempBio = value,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              Navigator.pop(context);
                              await _updateProfile(
                                  tempProfileImage, tempBio, tempUsername);
                            },
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logout')),
    );
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    UserData.phone = '';
    UserData.role = 'user';
    UserData.username = '';
    context.read<LoginBloc>().add(Logout());
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  Future<void> _deleteAccount() async {
    // Placeholder for delete account logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Delete Account functionality TBD')),
    );
    // Add your API call or logic to delete the account here
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserDashboard()),
        );
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey, // Assign the GlobalKey to the Scaffold
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            _username,
            style: const TextStyle(fontFamily: 'Billabong', fontSize: 32),
          ),
          actions: [
            if (_isOwnProfile) // Show settings only for logged-in user's profile
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  print('Settings icon clicked');
                  _scaffoldKey.currentState
                      ?.openEndDrawer(); // Use the key to open the drawer
                },
              ),
          ],
        ),
        endDrawer: _isOwnProfile
            ? Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                      ),
                      child: const Text(
                        'Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.edit),
                      title: const Text('Edit Profile'),
                      onTap: () {
                        Navigator.pop(context); // Close the drawer
                        _showEditProfileDialog();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Logout'),
                      onTap: () {
                        Navigator.pop(context); // Close the drawer
                        _logout();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete),
                      title: const Text('Delete Account'),
                      onTap: () {
                        Navigator.pop(context); // Close the drawer
                        _deleteAccount();
                      },
                    ),
                  ],
                ),
              )
            : null,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          _isProfilePicLoading
                              ? const SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                )
                              : CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: _profileImage != null
                                      ? FileImage(_profileImage!)
                                      : (_profilePicUrl.isNotEmpty
                                          ? NetworkImage(_profilePicUrl)
                                          : null) as ImageProvider?,
                                  child: _profileImage == null &&
                                          _profilePicUrl.isEmpty
                                      ? const Icon(Icons.person,
                                          size: 50, color: Colors.grey)
                                      : null,
                                ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildStatColumn(
                                      'Posts', _postsCount.toString()),
                                  _buildStatColumn(
                                      'Liked', _likedCount.toString()),
                                  // _buildStatColumn('Bookmarked',
                                  //     _bookmarkedCount.toString()),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _username,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _bio,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    if (_isOwnProfile) // Show buttons only for logged-in user's profile
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _showEditProfileDialog,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Edit Profile'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _logout,
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Logout'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Divider(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}
