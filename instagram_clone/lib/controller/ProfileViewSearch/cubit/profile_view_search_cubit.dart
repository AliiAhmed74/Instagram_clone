import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram_clone/controller/ProfileViewSearch/cubit/profile_view_search_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileViewSearchCubit extends Cubit<ProfileViewSearchState> {
  final supabase = Supabase.instance.client;
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  ProfileViewSearchCubit(Map<String, dynamic> userData)
      : super(ProfileViewSearchState.initial(userData)) {
    // Initialize the profile data
    initialize();
  }

  Future<void> initialize() async {
    await checkFollowStatus();
    await fetchFollowerCount();
    await fetchFollowingCount();
    await fetchUserPosts();
  }

  Future<void> checkFollowStatus() async {
    if (currentUserId == null) return;

    try {
      final response = await supabase
          .from('follows')
          .select()
          .eq('follower_id', currentUserId!)
          .eq('following_id', state.userData['uid']);

      emit(state.copyWith(isFollowing: response.isNotEmpty));
    } catch (e) {
      emit(state.copyWith(
        isFollowing: false,
        error: 'Error checking follow status: $e',
      ));
    }
  }

  Future<void> fetchFollowerCount() async {
    try {
      final response = await supabase
          .from('follows')
          .select()
          .eq('following_id', state.userData['uid']);

      emit(state.copyWith(followerCount: response.length));
    } catch (e) {
      emit(state.copyWith(error: 'Error fetching follower count: $e'));
    }
  }

  Future<void> fetchFollowingCount() async {
    try {
      final response = await supabase
          .from('follows')
          .select()
          .eq('follower_id', state.userData['uid']);

      emit(state.copyWith(followingCount: response.length));
    } catch (e) {
      emit(state.copyWith(error: 'Error fetching following count: $e'));
    }
  }

  Future<void> toggleFollow() async {
    if (currentUserId == null) {
      emit(state.copyWith(error: 'Please login to follow users'));
      return;
    }

    try {
      if (state.isFollowing) {
        // Unfollow
        await supabase
            .from('follows')
            .delete()
            .eq('follower_id', currentUserId!)
            .eq('following_id', state.userData['uid']);

        emit(state.copyWith(
          isFollowing: false,
          followerCount: state.followerCount - 1,
        ));
      } else {
        // Follow
        await supabase.from('follows').insert({
          'follower_id': currentUserId,
          'following_id': state.userData['uid'],
        });

        emit(state.copyWith(
          isFollowing: true,
          followerCount: state.followerCount + 1,
        ));
      }
    } catch (e) {
      emit(state.copyWith(error: 'Error toggling follow status: $e'));
    }
  }

  Future<void> fetchUserPosts() async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await supabase
          .from('posts')
          .select()
          .eq('user_id', state.userData['uid'])
          .order('created_at', ascending: false);

      emit(state.copyWith(
        userPosts: List<Map<String, dynamic>>.from(response),
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Error fetching user posts: $e',
      ));
    }
  }

  Future<void> fetchUserReels() async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await supabase
          .from('reels')
          .select()
          .eq('user_id', state.userData['uid'])
          .order('created_at', ascending: false);

      emit(state.copyWith(
        userReels: List<Map<String, dynamic>>.from(response),
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Error fetching user reels: $e',
      ));
    }
  }

  Future<void> fetchSavedPosts() async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await supabase
          .from('saved_posts')
          .select('posts(*)')
          .eq('user_id', state.userData['uid'])
          .order('created_at', ascending: false);

      emit(state.copyWith(
        savedPosts: List<Map<String, dynamic>>.from(response),
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Error fetching saved posts: $e',
      ));
    }
  }

  void changeTab(int index) {
    emit(state.copyWith(selectedTabIndex: index));
    if (index == 0) {
      fetchUserPosts();
    } else if (index == 1) {
      fetchUserReels();
    } else {
      fetchSavedPosts();
    }
  }
}