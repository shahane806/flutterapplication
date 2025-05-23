import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../ApiServices/ApiServices.dart';
import '../Events/PostEvents.dart';
import '../States/PostState.dart';

class UploadVideoPostBloc
    extends Bloc<UploadVideoPostEvent, UploadVideoPostState> {
  UploadVideoPostBloc() : super(UploadVideoPostState.initial()) {
    on<UploadVideoPostEvent>(uploadVideo);
  }
  void uploadVideo(
      UploadVideoPostEvent events, Emitter<UploadVideoPostState> emit) async {
    emit(state.copyWith(events.isUploaded));
  }
}

class UploadImagePostBloc
    extends Bloc<UploadImagePostEvent, UploadImagePostState> {
  UploadImagePostBloc() : super(UploadImagePostState.initial()) {
    on<UploadImagePostEvent>(uploadImage);
  }
  void uploadImage(
      UploadImagePostEvent events, Emitter<UploadImagePostState> emit) async {
    emit(state.copyWith(events.isUploaded));
  }
}

class UploadTextPostBloc
    extends Bloc<UploadTextPostEvent, UploadTextPostState> {
  UploadTextPostBloc() : super(UploadTextPostState.initial()) {
    on<UploadTextPostEvent>(uploadText);
  }
  void uploadText(
      UploadTextPostEvent events, Emitter<UploadTextPostState> emit) async {
    emit(state.copyWith(events.isUploaded));
  }
}
