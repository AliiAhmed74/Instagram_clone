import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/controller/FeedPost/feed_post_state.dart';
import 'package:instagram_clone/services/notification_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedPostCubit extends Cubit<FeedPostState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;
  final NotificationService _notificationService = NotificationService();
  StreamSubscription? _notificationSubscription;

  FeedPostCubit() : super(const FeedPostState()) {
    _init();
  }

  void _init() async {
    emit(state.copyWith(isLoading: true));
    try {
      await Future.wait([
        _fetchProfileImage(),
        _fetchPosts(),
        _fetchStories(),
        _fetchSavedPosts(),
        _fetchUserLikes(),
      ]);
      _listenForNewNotifications();
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _listenForNewNotifications() {
    _notificationSubscription = _notificationService.getLatestNotification().listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final notificationDoc = snapshot.docs.first;
        final notification = notificationDoc.data() as Map<String, dynamic>;

        // Only show banner if we're not already showing this notification
        if (state.currentNotification == null ||
            state.currentNotification!['id'] != notificationDoc.id) {
          emit(state.copyWith(
            currentNotification: {'id': notificationDoc.id, ...notification},
            showNotificationBanner: true,
          ));
        }
      }
    });
  }

  void dismissNotificationBanner() {
    emit(state.copyWith(
      showNotificationBanner: false,
      currentNotification: null,
    ));
  }

  void handleNotificationTap(BuildContext context) {
    if (state.currentNotification != null) {
      // Mark notification as read
      _notificationService.markNotificationAsRead(state.currentNotification!['id']);
      
      dismissNotificationBanner();
    }
  }

  Future<void> _fetchUserData(String userId) async {
    if (state.userDataCache.containsKey(userId)) {
      return; // Return if data is already cached
    }

    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final updatedCache = Map<String, Map<String, dynamic>>.from(state.userDataCache);
        updatedCache[userId] = {
          'username': doc.data()?['username'] ?? 'Unknown User',
          'profileImage': doc.data()?['profileImage'] ?? '',
        };
        emit(state.copyWith(userDataCache: updatedCache));
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _fetchProfileImage() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        emit(state.copyWith(profileImageUrl: doc.data()?['profileImage']));
      }
    } catch (e) {
      print('Error fetching profile image: $e');
    }
  }

  Future<void> _fetchPosts() async {
    try {
      final response = await _supabase
          .from('posts')
          .select('*, likes')
          .order('created_at', ascending: false);

      List<Map<String, dynamic>> fetchedPosts =
          List<Map<String, dynamic>>.from(response);

      for (var post in fetchedPosts) {
        final userId = post['user_id'] as String;
        await _fetchUserData(userId);

        post['username'] = state.userDataCache[userId]?['username'];
        post['profileImage'] = state.userDataCache[userId]?['profileImage'];
      }

      emit(state.copyWith(posts: fetchedPosts));
    } catch (e) {
      emit(state.copyWith(error: 'Error fetching posts: $e'));
    }
  }

  Future<void> _fetchSavedPosts() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    try {
      final response = await _supabase
          .from('saved_posts')
          .select('post_id')
          .eq('user_id', user.uid);

      final savedPostIds = List<String>.from(
          response.map((item) => item['post_id'].toString()));
      
      emit(state.copyWith(savedPosts: savedPostIds));
    } catch (e) {
      print('Error fetching saved posts: $e');
    }
  }

  Future<void> _fetchUserLikes() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    try {
      final response = await _supabase
          .from('likes')
          .select('post_id')
          .eq('user_id', user.uid);

      final userLikesMap = Map.fromEntries((response as List)
          .map((like) => MapEntry(like['post_id'].toString(), true)));
      
      emit(state.copyWith(userLikes: userLikesMap));
    } catch (e) {
      print('Error fetching user likes: $e');
    }
  }

  Future<void> toggleSavePost(String postId, BuildContext context, Function(String) showMessage) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    try {
      List<String> updatedSavedPosts = List.from(state.savedPosts);
      
      if (state.savedPosts.contains(postId)) {
        // Unsave the post
        await _supabase
            .from('saved_posts')
            .delete()
            .eq('user_id', user.uid)
            .eq('post_id', postId);

        updatedSavedPosts.remove(postId);
        emit(state.copyWith(savedPosts: updatedSavedPosts));
        showMessage("Post removed from saved");
      } else {
        // Save the post
        await _supabase.from('saved_posts').insert({
          'user_id': user.uid,
          'post_id': postId,
          'created_at': DateTime.now().toIso8601String(),
        });

        updatedSavedPosts.add(postId);
        emit(state.copyWith(savedPosts: updatedSavedPosts));
        showMessage("Post saved successfully");
      }
    } catch (e) {
      print('Error toggling save post: $e');
      showMessage("Failed to update saved posts. Please try again.");
    }
  }

  Future<void> toggleLike(String postId, BuildContext context, Function(String) showMessage) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    try {
      final isLiked = state.userLikes[postId] ?? false;
      Map<String, bool> updatedUserLikes = Map.from(state.userLikes);

      if (isLiked) {
        // Remove like
        await _supabase
            .from('likes')
            .delete()
            .eq('user_id', user.uid)
            .eq('post_id', postId);

        // Decrease likes count in posts table
        await _supabase
            .rpc('decrement_likes', params: {'post_id_param': postId});
            
        updatedUserLikes.remove(postId);
      } else {
        // Add like
        await _supabase.from('likes').insert({
          'user_id': user.uid,
          'post_id': postId,
          'created_at': DateTime.now().toIso8601String(),
        });

        // Increase likes count in posts table
        await _supabase
            .rpc('increment_likes', params: {'post_id_param': postId});
            
        updatedUserLikes[postId] = true;
      }

      // Update local state
      emit(state.copyWith(userLikes: updatedUserLikes));

      // Refresh posts to get updated likes count
      await _fetchPosts();
    } catch (e) {
      print('Error toggling like: $e');
      showMessage("Failed to update like. Please try again.");
    }
  }

  Future<void> _fetchStories() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    try {
      // First, get the list of users that the current user follows
      final followingResponse = await _supabase
          .from('follows')
          .select('following_id')
          .eq('follower_id', user.uid);

      // Extract the following_ids into a list
      List<String> followingIds = List<String>.from(
          followingResponse.map((item) => item['following_id']));

      // Add current user's ID to see their own stories too
      followingIds.add(user.uid);

      // Then fetch stories only from these users
      final response = await _supabase
          .from('stories')
          .select('*')
          .inFilter('userid', followingIds)
          .order('timestamp', ascending: false);

      List<Map<String, dynamic>> fetchedStories =
          List<Map<String, dynamic>>.from(response);

      // Group stories by user and fetch user data
      Map<String, List<Map<String, dynamic>>> storiesByUser = {};
      Map<String, Map<String, dynamic>> updatedStoryUserData = Map.from(state.storyUserData);
      
      for (var story in fetchedStories) {
        String userId = story['userid'];
        if (!storiesByUser.containsKey(userId)) {
          storiesByUser[userId] = [];
          // Fetch user data from Firebase
          try {
            final userDoc = await _firestore.collection('users').doc(userId).get();
            if (userDoc.exists) {
              updatedStoryUserData[userId] = {
                'username': userDoc.data()?['username'] ?? 'Unknown User',
                'profileImage': userDoc.data()?['profileImage'] ?? '',
              };
            }
          } catch (e) {
            print('Error fetching user data for story: $e');
          }
        }
        storiesByUser[userId]!.add(story);
      }

      // Convert back to list, keeping only the latest story for each user
      List<Map<String, dynamic>> uniqueUserStories =
          storiesByUser.entries.map((entry) => entry.value.first).toList();

      emit(state.copyWith(
        stories: uniqueUserStories,
        storyUserData: updatedStoryUserData,
      ));
    } catch (e) {
      print('Error fetching stories: $e');
    }
  }

  Future<void> uploadStory(String imagePath, String storyType) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    emit(state.copyWith(isLoading: true));

    final file = File(imagePath);
    final fileName = 'stories/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    try {
      await _supabase.storage.from('stories').upload(fileName, file);
      final imageUrl = _supabase.storage.from('stories').getPublicUrl(fileName);
      await _supabase.from('stories').insert({
        'userid': user.uid,
        'storyurl': imageUrl,
        'storytype': storyType,
        'timestamp': DateTime.now().toIso8601String(),
      });
      await _fetchStories();
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Error uploading story: $e'));
    }
  }

  Future<void> pickAndUploadStory() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      await uploadStory(pickedFile.path, 'image');
    }
  }

  Future<void> saveTextStory(String text) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    emit(state.copyWith(isLoading: true));
    
    try {
      await _supabase.from('stories').insert({
        'userid': user.uid,
        'storyurl': '',
        'storytype': 'text',
        'text': text,
        'timestamp': DateTime.now().toIso8601String(),
      });
      await _fetchStories();
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Error saving text story: $e'));
    }
  }
  
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      emit(state.copyWith(error: 'Error signing out: $e'));
    }
  }
  
  @override
  Future<void> close() {
    _notificationSubscription?.cancel();
    return super.close();
  }
}