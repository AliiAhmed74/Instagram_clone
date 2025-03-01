import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_clone/generated/l10n.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class MyStoriesScreen extends StatefulWidget {
  final String? profileImageUrl;

  const MyStoriesScreen({Key? key, this.profileImageUrl}) : super(key: key);

  @override
  State<MyStoriesScreen> createState() => _MyStoriesScreenState();
}

class _MyStoriesScreenState extends State<MyStoriesScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _myStories = [];
  bool _isLoading = true;
  int _currentStoryIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _fetchMyStories();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchMyStories() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('stories')
          .select()
          .eq('userid', user.uid)
          .order('timestamp', ascending: true);

      setState(() {
        _myStories = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching my stories: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteStory(Map<String, dynamic> story) async {
    try {
      if (story['storytype'] == 'image' && story['storyurl'] != null) {
        final Uri uri = Uri.parse(story['storyurl']);
        final String path = uri.path.replaceFirst('/storage/v1/object/public/stories/', '');
        await _supabase.storage.from('stories').remove([path]);
      }

      await _supabase
          .from('stories')
          .delete()
          .match({
            'userid': story['userid'],
            'timestamp': story['timestamp']
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Story deleted'), duration: Duration(seconds: 1))
      );

      await _fetchMyStories();
      if (_myStories.isEmpty) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting story: $e'))
      );
    }
  }

  Widget _buildStoryView(Map<String, dynamic> story) {
    return GestureDetector(
      onTapDown: (details) {
        final screenWidth = MediaQuery.of(context).size.width;
        if (details.globalPosition.dx < screenWidth / 2) {
          // Tap on left side - go to previous story
          if (_currentStoryIndex > 0) {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        } else {
          // Tap on right side - go to next story
          if (_currentStoryIndex < _myStories.length - 1) {
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
                        _myStories.length,
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
                          backgroundImage: NetworkImage(widget.profileImageUrl ?? ''),
                          backgroundColor: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          S.of(context).Your_Story,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('MMM d, y • h:mm a').format(
                                  DateTime.parse(story['timestamp']),
                                ),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert, color: Colors.white),
                          onPressed: () => _showStoryOptions(story),
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

  void _showStoryOptions(Map<String, dynamic> story) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title:  Text(S.of(context).Delete_Story, style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteStory(story);
              },
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

    if (_myStories.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title:  Text(S.of(context).My_Stories),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body:  Center(
          child: Text(S.of(context).No_Stories_yet),
        ),
      );
    }

    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: _myStories.length,
        onPageChanged: (index) {
          setState(() {
            _currentStoryIndex = index;
          });
        },
        itemBuilder: (context, index) => _buildStoryView(_myStories[index]),
      ),
    );
  }
}