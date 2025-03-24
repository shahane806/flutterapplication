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

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc() : super(PostState(posts: [])) {
    on<FetchPostsEvent>(_onFetchPosts);
    on<UpdatePostLikeEvent>(_onUpdatePostLike);
  }

  Future<void> _onFetchPosts(
      FetchPostsEvent event, Emitter<PostState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final posts = await fetchPosts();
      emit(state.copyWith(posts: posts, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void _onUpdatePostLike(UpdatePostLikeEvent event, Emitter<PostState> emit) {
    final updatedPosts = state.posts.map((post) {
      if (post['id'] == event.postId) {
        return {
          ...post,
          'likeCount': event.likeCount,
          'isLiked': event.isLiked,
        };
      }
      return post;
    }).toList();

    emit(state.copyWith(posts: updatedPosts));
  }
}
