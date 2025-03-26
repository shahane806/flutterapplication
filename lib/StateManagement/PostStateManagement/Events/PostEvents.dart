import 'package:equatable/equatable.dart';

abstract class PostEvents extends Equatable {}

class UploadVideoPostEvent extends PostEvents {
  final bool isUploaded;
  UploadVideoPostEvent({required this.isUploaded});
  @override
  List<Object?> get props => [isUploaded];
}

class UploadImagePostEvent extends PostEvents {
  final bool isUploaded;
  UploadImagePostEvent({required this.isUploaded});
  @override
  List<Object?> get props => [isUploaded];
}

class UploadTextPostEvent extends PostEvents {
  final bool isUploaded;
  UploadTextPostEvent({required this.isUploaded});
  @override
  List<Object?> get props => [isUploaded];
}

abstract class PostEvent {}

class FetchPostsEvent extends PostEvent {}

class UpdatePostLikeEvent extends PostEvent {
  final int postId;
  final bool isLiked;
  final int likeCount;

  UpdatePostLikeEvent({
    required this.postId,
    required this.isLiked,
    required this.likeCount,
  });
}
