part of 'search_cubit.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<Map<String, dynamic>> allUsers;
  final List<Map<String, dynamic>> filteredUsers;
  final List<Map<String, String>> filteredTags;
  final List<Map<String, dynamic>> recentSearches;

  SearchLoaded({
    required this.allUsers,
    required this.filteredUsers,
    required this.filteredTags,
    required this.recentSearches,
  });
}

class SearchError extends SearchState {
  final String message;

  SearchError(this.message);
}