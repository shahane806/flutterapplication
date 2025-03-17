import 'package:equatable/equatable.dart';

abstract class PostEvents extends Equatable{}

class UploadVideoPostEvent extends PostEvents{
  final bool isUploaded;
  UploadVideoPostEvent({required this.isUploaded});
  @override
  List<Object?> get props => [isUploaded];
}

class UploadImagePostEvent extends PostEvents{
  final bool isUploaded;
  UploadImagePostEvent({required this.isUploaded});
  @override
  List<Object?> get props => [isUploaded];
}

class UploadTextPostEvent extends PostEvents{
  final bool isUploaded;
  UploadTextPostEvent({required this.isUploaded});
  @override
  List<Object?> get props => [isUploaded];
}