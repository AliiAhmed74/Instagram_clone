import 'package:equatable/equatable.dart';

class ProfileViewSearchState extends Equatable {
  final List<Map<String, dynamic>> userPosts;
  final List<Map<String, dynamic>> userReels;
  final List<Map<String, dynamic>> savedPosts;
  final bool isLoading;
  final bool isFollowing;
  final int followerCount;
  final int followingCount;
  final int selectedTabIndex;
  final Map<String, dynamic> userData;
  final String? error;

  const ProfileViewSearchState({
    required this.userPosts,
    required this.userReels,
    required this.savedPosts,
    required this.isLoading,
    required this.isFollowing,
    required this.followerCount,
    required this.followingCount,
    required this.selectedTabIndex,
    required this.userData,
    this.error,
  });

  // Initial state factory constructor
  factory ProfileViewSearchState.initial(Map<String, dynamic> userData) {
    return ProfileViewSearchState(
      userPosts: [],
      userReels: [],
      savedPosts: [],
      isLoading: true,
      isFollowing: false,
      followerCount: 0,
      followingCount: 0,
      selectedTabIndex: 0,
      userData: userData,
      error: null,
    );
  }

  // Copy with method for state immutability
  ProfileViewSearchState copyWith({
    List<Map<String, dynamic>>? userPosts,
    List<Map<String, dynamic>>? userReels,
    List<Map<String, dynamic>>? savedPosts,
    bool? isLoading,
    bool? isFollowing,
    int? followerCount,
    int? followingCount,
    int? selectedTabIndex,
    Map<String, dynamic>? userData,
    String? error,
  }) {
    return ProfileViewSearchState(
      userPosts: userPosts ?? this.userPosts,
      userReels: userReels ?? this.userReels,
      savedPosts: savedPosts ?? this.savedPosts,
      isLoading: isLoading ?? this.isLoading,
      isFollowing: isFollowing ?? this.isFollowing,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      userData: userData ?? this.userData,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        userPosts,
        userReels,
        savedPosts,
        isLoading,
        isFollowing,
        followerCount,
        followingCount,
        selectedTabIndex,
        userData,
        error,
      ];
}