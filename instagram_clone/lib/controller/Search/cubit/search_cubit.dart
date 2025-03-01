import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchInitial()) {
    _fetchAllUsers();
  }

  final List<Map<String, String>> tags = [
    {
      'name': '#Freepalestine🇵🇸',
      'subtitle': '6.2M posts',
      'image': 'assets/hash3.png'
    },
    {'name': '#muslim', 'subtitle': '4M posts', 'image': 'assets/hash3.png'},
    {
      'name': '#egyptfashion',
      'subtitle': '450K posts',
      'image': 'assets/hash3.png'
    },
    {'name': '#mosalah', 'subtitle': '5M posts', 'image': 'assets/hash3.png'},
    {'name': '#quran', 'subtitle': '712K posts', 'image': 'assets/hash3.png'},
    {'name': '#Weather', 'subtitle': '2M posts', 'image': 'assets/hash3.png'},
  ];

  List<Map<String, dynamic>> allUsers = [];
  List<Map<String, dynamic>> filteredUsers = [];
  List<Map<String, String>> filteredTags = [];
  List<Map<String, dynamic>> recentSearches = [];

  void filterItems(String query) {
    if (state is SearchLoaded) {
      final currentState = state as SearchLoaded;
      filteredUsers = allUsers
          .where((user) =>
              user['username'].toLowerCase().contains(query.toLowerCase()))
          .toList();
      filteredTags = tags
          .where(
              (tag) => tag['name']!.toLowerCase().contains(query.toLowerCase()))
          .toList();

      emit(SearchLoaded(
        allUsers: currentState.allUsers,
        filteredUsers: filteredUsers,
        filteredTags: filteredTags,
        recentSearches: currentState.recentSearches,
      ));
    }
  }

  Future<void> _fetchAllUsers() async {
    emit(SearchLoading());
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final querySnapshot = await FirebaseFirestore.instance.collection('users').get();
      allUsers = querySnapshot.docs
          .map((doc) => doc.data())
          .where((userData) => userData['uid'] != user.uid)
          .toList();
      filteredUsers = allUsers;
      filteredTags = tags;

      emit(SearchLoaded(
        allUsers: allUsers,
        filteredUsers: filteredUsers,
        filteredTags: filteredTags,
        recentSearches: recentSearches,
      ));
    } catch (e) {
      emit(SearchError('Error fetching users: $e'));
    }
  }

  void addToRecentSearches(Map<String, dynamic> user) {
    if (state is SearchLoaded) {
      final currentState = state as SearchLoaded;
      if (!recentSearches.any((element) => element['username'] == user['username'])) {
        recentSearches.insert(0, user);
      }

      emit(SearchLoaded(
        allUsers: currentState.allUsers,
        filteredUsers: currentState.filteredUsers,
        filteredTags: currentState.filteredTags,
        recentSearches: recentSearches,
      ));
    }
  }
}