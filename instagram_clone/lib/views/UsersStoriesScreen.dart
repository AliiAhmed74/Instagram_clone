import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class UserStoriesScreen extends StatefulWidget {
  final String userId;
  final String? username;
  final String? profileImage;

  const UserStoriesScreen({
    Key? key, 
    required this.userId,
    this.username,
    this.profileImage,
  }) : super(key: key);

  @override
  State<UserStoriesScreen> createState() => _UserStoriesScreenState();
}

class _UserStoriesScreenState extends State<UserStoriesScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _userStories = [];
  bool _isLoading = true;
  int _currentStoryIndex = 0;
  final PageController _pageController = PageController();
  String? _username;
  String? _profileImage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchUserStories();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    if (widget.username != null && widget.profileImage != null) {
      setState(() {
        _username = widget.username;
        _profileImage = widget.profileImage;
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      
      if (doc.exists) {
        setState(() {
          _username = doc.data()?['username'] ?? 'Unknown User';
          _profileImage = doc.data()?['profileImage'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _fetchUserStories() async {
    try {
      final response = await _supabase
          .from('stories')
          .select()
          .eq('userid', widget.userId)
          .order('timestamp', ascending: true);

      setState(() {
        _userStories = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching user stories: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildStoryView(Map<String, dynamic> story) {
    return GestureDetector(
      onTapDown: (details) {
        final screenWidth = MediaQuery.of(context).size.width;
        if (details.globalPosition.dx < screenWidth / 2) {
          if (_currentStoryIndex > 0) {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        } else {
          if (_currentStoryIndex < _userStories.length - 1) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        }
      },
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            // Story Content
            Center(
              child: story['storytype'] == 'text' 
                ? Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple.shade400, Colors.blue.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        story['text'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : Image.network(
                    story['storyurl'],
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Center(child: CircularProgressIndicator());
                    },
                  ),
            ),

            // Top Bar
            SafeArea(
              child: Column(
                children: [
                  // Progress Bars
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: List.generate(
                        _userStories.length,
                        (index) => Expanded(
                          child: Container(
                            height: 2,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: index <= _currentStoryIndex 
                                ? Colors.white 
                                : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: _profileImage != null 
                              ? NetworkImage(_profileImage!)
                              : const AssetImage('assets/profile-icon-design-free-vector.jpg') as ImageProvider,
                          backgroundColor: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _username ?? 'User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            DateFormat('MMM d, y • h:mm a').format(
                              DateTime.parse(story['timestamp']),
                            ),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_userStories.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_username ?? 'User Stories'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: const Center(
          child: Text('No stories available'),
        ),
      );
    }

    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: _userStories.length,
        onPageChanged: (index) {
          setState(() {
            _currentStoryIndex = index;
          });
        },
        itemBuilder: (context, index) => _buildStoryView(_userStories[index]),
      ),
    );
  }
}