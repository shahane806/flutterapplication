import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_frontend/Handlers/AuthStatus.dart';
import 'package:flutter_application_frontend/Handlers/UserData.dart';
import 'package:flutter_application_frontend/StateManagement/LoginStateManagement/Blocs/LoginBloc.dart';
import 'package:flutter_application_frontend/StateManagement/LoginStateManagement/Events/LoginEvent.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'UserDashboard.dart'; // Assuming this is the file containing UserDashboard

class ProfileScreen extends StatefulWidget {
  final String username; // Username passed from UserDashboard or elsewhere

  ProfileScreen({super.key, required this.username});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // User data - replace with actual backend data or fetch dynamically
  late String _username;
  String _bio = 'Living life one adventure at a time | Travel Enthusiast | Foodie';
  File? _profileImage; // For the main profile picture
  String _profilePicUrl = ''; // Network URL or empty initially
  int _likedCount = 12;
  int _bookmarkedCount = 10;
  int _postsCount = 25;

  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _username = widget.username; // Use passed username (e.g., post['userName'])
    _bioController.text = _bio; // Initialize bio controller
    // Optionally fetch initial user data from backend here
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  Future<File?> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  void _showEditProfileDialog() {
    File? tempProfileImage = _profileImage; // Temporary image for dialog
    String tempBio = _bio; // Temporary bio for dialog

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                        tempProfileImage = newImage; // Update temp image in dialog
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
                        ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _bioController,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onChanged: (value) {
                    tempBio = value; // Update temp bio as user types
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Discard changes
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _bio = tempBio; // Apply bio changes
                          _profileImage = tempProfileImage; // Apply image changes
                          _bioController.text = _bio; // Sync controller
                        });
                        // TODO: Add backend API call to save _profileImage and _bio
                        // Example:
                        // if (_profileImage != null) {
                        //   uploadProfileImage(_profileImage!).then((url) {
                        //     setState(() => _profilePicUrl = url);
                        //   });
                        // }
                        // updateUserBio(_bio);
                        Navigator.pop(context); // Save changes
                      },
                      child: const Text('Save'),
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
  

    // Show logout confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out')),
    );

    // Optionally navigate to a login screen
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
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
        appBar: AppBar(
          automaticallyImplyLeading: false, // Removes the back arrow
          title: Text(
            _username,
            style: const TextStyle(fontFamily: 'Billabong', fontSize: 32),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // Add settings navigation or functionality here
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : (_profilePicUrl.isNotEmpty
                              ? NetworkImage(_profilePicUrl)
                              : null) as ImageProvider?,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatColumn('Posts', _postsCount.toString()),
                            _buildStatColumn('Liked', _likedCount.toString()),
                            _buildStatColumn(
                                'Bookmarked', _bookmarkedCount.toString()),
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
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
              ),
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
                        onPressed: _logout, // Call the async logout function
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
              // Optional: Add user's posts or other content below
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