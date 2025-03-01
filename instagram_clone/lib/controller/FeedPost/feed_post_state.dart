import 'package:equatable/equatable.dart';

class FeedPostState extends Equatable {
  final Map<String, Map<String, dynamic>> storyUserData;
  final List<Map<String, dynamic>> posts;
  final List<String> savedPosts;
  final Map<String, bool> userLikes;
  final Map<String, Map<String, dynamic>> userDataCache;
  final String? profileImageUrl;
  final List<Map<String, dynamic>> stories;
  final Map<String, dynamic>? currentNotification;
  final bool showNotificationBanner;
  final bool isLoading;
  final String? error;

  const FeedPostState({
    this.storyUserData = const {},
    this.posts = const [],
    this.savedPosts = const [],
    this.userLikes = const {},
    this.userDataCache = const {},
    this.profileImageUrl,
    this.stories = const [],
    this.currentNotification,
    this.showNotificationBanner = false,
    this.isLoading = false,
    this.error,
  });

  FeedPostState copyWith({
    Map<String, Map<String, dynamic>>? storyUserData,
    List<Map<String, dynamic>>? posts,
    List<String>? savedPosts,
    Map<String, bool>? userLikes,
    Map<String, Map<String, dynamic>>? userDataCache,
    String? profileImageUrl,
    List<Map<String, dynamic>>? stories,
    Map<String, dynamic>? currentNotification,
    bool? showNotificationBanner,
    bool? isLoading,
    String? error,
  }) {
    return FeedPostState(
      storyUserData: storyUserData ?? this.storyUserData,
      posts: posts ?? this.posts,
      savedPosts: savedPosts ?? this.savedPosts,
      userLikes: userLikes ?? this.userLikes,
      userDataCache: userDataCache ?? this.userDataCache,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      stories: stories ?? this.stories,
      currentNotification: currentNotification ?? this.currentNotification,
      showNotificationBanner: showNotificationBanner ?? this.showNotificationBanner,
      isLoading: isLoading ?? this.isLoading,
      error: error,  // Pass null to clear the error
    );
  }

  @override
  List<Object?> get props => [
    storyUserData,
    posts,
    savedPosts,
    userLikes,
    userDataCache,
    profileImageUrl,
    stories,
    currentNotification,
    showNotificationBanner,
    isLoading,
    error,
  ];
}
