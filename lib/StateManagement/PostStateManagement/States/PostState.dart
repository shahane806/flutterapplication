import 'package:equatable/equatable.dart';

class UploadVideoPostState extends Equatable {
  final bool isUploaded;
  UploadVideoPostState({required this.isUploaded});
  
  factory UploadVideoPostState.initial() =>  UploadVideoPostState(isUploaded:false);
  
  UploadVideoPostState copyWith(bool iu) {
    return UploadVideoPostState(isUploaded:iu);
  }
  @override
  List<Object> get props => [isUploaded];
}
class UploadImagePostState extends Equatable {
  final bool isUploaded;
  UploadImagePostState({required this.isUploaded});
  
  factory UploadImagePostState.initial() =>  UploadImagePostState(isUploaded:false);
  
  UploadImagePostState copyWith(bool iu) {
    return UploadImagePostState(isUploaded:iu);
  }
  @override
  List<Object> get props => [isUploaded];
}

class UploadTextPostState extends Equatable {
  final bool isUploaded;
  UploadTextPostState({required this.isUploaded});
  
  factory UploadTextPostState.initial() =>  UploadTextPostState(isUploaded:false);
  
  UploadTextPostState copyWith(bool iu) {
    return UploadTextPostState(isUploaded:iu);
  }
  @override
  List<Object> get props => [isUploaded];
}

