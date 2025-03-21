import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

import '../AlertHandler/alertHandler.dart';
import '../Handlers/BaseUrl.dart';
import '../Handlers/UserData.dart';
import '../StateManagement/PostStateManagement/Blocs/PostBloc.dart';
import '../StateManagement/PostStateManagement/Events/PostEvents.dart';

Future<List<dynamic>> fetchPosts() async {
  var response = await http.post(
    Uri.parse(Apis.BaseUrl + "SocialMediaApis/getImagePost.php"),
    headers: {"Content-Type": "application/x-www-form-urlencoded"},
    body: {
      "MOBILE": UserData.phone,
    },
  );

  if (response.statusCode == 200) {
    print("Response: ${response.body}");
    final jsonResponse = jsonDecode(response.body);
    if (jsonResponse['status'] == 200 && jsonResponse['data'] != null) {
      return jsonResponse['data'];
    } else {
      throw Exception('No posts found in response');
    }
  } else {
    throw Exception('Failed to load posts: ${response.statusCode}');
  }
}

Future<void> createVideoPost(BuildContext context, File? videoFile) async {
  if (videoFile == null) return;
  var request = http.MultipartRequest(
      "POST", Uri.parse(Apis.BaseUrl + "SocialMediaApis/post.php"));
  request.fields['MOBILE'] = UserData.phone;
  request.fields['POST_TYPE'] = "video";

  String? mimeType = lookupMimeType(videoFile!.path) ?? "video/mp4";
  var mimeParts = mimeType.split('/');
  MediaType mediaType = MediaType(mimeParts[0], mimeParts[1]);

  request.files.add(http.MultipartFile(
    'file',
    videoFile!.readAsBytes().asStream(),
    videoFile!.lengthSync(),
    filename: basename(videoFile!.path),
    contentType: mediaType,
  ));

  try {
    var response = await request.send();
    if (response.statusCode == 200) {
      AlertHandler.showSuccessSnackBar(context, "Upload Successfully");
      Navigator.pop(context);
      context
          .read<UploadVideoPostBloc>()
          .add(UploadVideoPostEvent(isUploaded: false));
    } else {
      if (response.statusCode == 413) {
        AlertHandler.showErrorSnackBar(
            context, "Upload Failed Payload is too large");
      } else {
        AlertHandler.showErrorSnackBar(context, "Upload Failed ");
      }
      Navigator.pop(context);
    }
  } catch (e) {
    AlertHandler.showErrorSnackBar(context, "Upload Failed");
    Navigator.pop(context);
  }
}

Future<void> createTextPost(
    BuildContext context, String title, String message) async {
  try {
    var response = await http.post(
      Uri.parse(Apis.BaseUrl + "SocialMediaApis/post.php"),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        "MOBILE": UserData.phone,
        "POST_TYPE": "textPost",
        "POST_TITLE": title,
        "POST_MESSAGE": message,
      },
    );

    if (response.statusCode == 200 && response.body.contains("success")) {
      AlertHandler.showSuccessSnackBar(context, "Upload Successfully");
      context
          .read<UploadTextPostBloc>()
          .add(UploadTextPostEvent(isUploaded: true));
    } else {
      AlertHandler.showErrorSnackBar(
          context, "Upload Failed: ${response.body}");
      context
          .read<UploadTextPostBloc>()
          .add(UploadTextPostEvent(isUploaded: false));
    }
  } catch (e) {
    AlertHandler.showErrorSnackBar(context, "Network Error: $e");
    context
        .read<UploadTextPostBloc>()
        .add(UploadTextPostEvent(isUploaded: false));
  } finally {
    Navigator.pop(context);
  }
}

Future<void> createImagePost(BuildContext context, File? ImageFile) async {
  if (ImageFile == null) return;
  var request = http.MultipartRequest(
      "POST", Uri.parse(Apis.BaseUrl + "SocialMediaApis/post.php"));
  request.fields['MOBILE'] = UserData.phone;
  request.fields['POST_TYPE'] = "image";

  String? mimeType = lookupMimeType(ImageFile!.path) ?? "image/jpg";
  var mimeParts = mimeType.split('/');
  MediaType mediaType = MediaType(mimeParts[0], mimeParts[1]);

  request.files.add(http.MultipartFile(
    'file',
    ImageFile!.readAsBytes().asStream(),
    ImageFile!.lengthSync(),
    filename: basename(ImageFile!.path),
    contentType: mediaType,
  ));

  try {
    var response = await request.send();
    if (response.statusCode == 200) {
      AlertHandler.showSuccessSnackBar(context, "Upload Successfully");
      Navigator.pop(context);
      context
          .read<UploadImagePostBloc>()
          .add(UploadImagePostEvent(isUploaded: false));
    } else {
      AlertHandler.showErrorSnackBar(context, "Upload Failed");
      Navigator.pop(context);
    }
  } catch (e) {
    AlertHandler.showErrorSnackBar(context, "Upload Failed");
    Navigator.pop(context);
  }
}

Future<void> likedPost(BuildContext context, String postId, String postPath,
    String postType, String phone) async {
      print("IN Liked Post");
  var responce = await http
      .post(Uri.parse(Apis.BaseUrl + "SocialMediaApis/post.php"), headers: {
    "Content-Type": "application/x-www-form-urlencoded"
  }, body: {
    "API_TYPE": "liked",
    "POST_ID": postId,
    "POST_TYPE": postType,
    "POST_PATH": postPath,
    "MOBILE": phone,
  });
  if (responce.statusCode == 200) {
    AlertHandler.showSuccessSnackBar(context, "Liked Post");
  } else {
    AlertHandler.showErrorSnackBar(context, "Liked Failed");
  }
}

Future<void> dislikePost(
    BuildContext context, String postId, String phone) async {
  var responce = await http
      .post(Uri.parse(Apis.BaseUrl + "SpcialMediaApis/post.php"), headers: {
    "Content-Type": "application/x-www-form-urlencoded"
  }, body: {
    "API_TYPE": "DisLikedPost",
    "POST_ID": postId,
    "MOBILE": phone,
  });
  if (responce.statusCode == 200) {
    AlertHandler.showSuccessSnackBar(context, "DisLiked Post");
  } else {
    AlertHandler.showErrorSnackBar(context, "DisLiked Post Failed");
  }
}

Future<void> bookmarkedPost(BuildContext context, String postId,
    String postPath, String postType, String phone) async {
  var responce = await http
      .post(Uri.parse(Apis.BaseUrl + "SocialMediaApis/post.php"), headers: {
    "Content-Type": "application/x-www-form-urlencoded"
  }, body: {
    "API_TYPE": "bookedMarked",
    "postId": postId,
    "postType": postType,
    "postPath": postPath,
    "MOBILE": phone,
  });
  if (responce.statusCode == 200) {
    AlertHandler.showSuccessSnackBar(context, "Booked Marked Post");
  } else {
    AlertHandler.showErrorSnackBar(context, "Booked Marked Failed");
  }
}

Future<void> removebookmarkedPost(BuildContext context, String postId,
    String postPath, String postType, String phone) async {
  var responce = await http
      .post(Uri.parse(Apis.BaseUrl + "SocialMediaApis/post.php"), headers: {
    "Content-Type": "application/x-www-form-urlencoded"
  }, body: {
    "API_TYPE": "deletebookedMarked",
    "POST_ID": postId,
    "MOBILE": phone,
  });
  if (responce.statusCode == 200) {
    AlertHandler.showSuccessSnackBar(context, "Booked Marked Post");
  } else {
    AlertHandler.showErrorSnackBar(context, "Booked Marked Failed");
  }
}

Future<void> commentOnPost(BuildContext context, String comment, String postId,
    String postPath, String phone, String postType) async {
  var responce = await http
      .post(Uri.parse(Apis.BaseUrl + "SocialMediaApis/post.php"), headers: {
    "Content-Type": "application/x-www-form-urlencoded"
  }, body: {
    "API_TYPE": "comment",
    "comment": comment,
    "POST_ID": postId,
    "POST_TYPE": postType,
    "POST_PATH": postPath,
    "MOBILE": phone,
  });
  if (responce.statusCode == 200) {
    AlertHandler.showSuccessSnackBar(context, "Commented");
  } else {
    AlertHandler.showErrorSnackBar(context, "Comment Failed");
  }
}



   Future<int> getLikeCount(BuildContext context, String postId) async {
    try {
      var response = await http.post(
        Uri.parse("${Apis.BaseUrl}SocialMediaApis/getLikeCount.php"),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: {
          "POST_ID": postId,
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data['status'] == 200) {
          return await data['data']['likeCount'] ?? 0;
        } else {
          AlertHandler.showErrorSnackBar(context, "Failed to get like count");
          return 0;
        }
      } else {
        AlertHandler.showErrorSnackBar(context, "Server Error: ${response.statusCode}");
        return 0;
      }
    } catch (e) {
      print("Error: $e");
      AlertHandler.showErrorSnackBar(context, "Failed to fetch like count");
      return 0;
    }
  }

