import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/views/FeedPost.dart';
import 'package:instagram_clone/views/MyProfile.dart';
import 'package:instagram_clone/views/SearchScreen.dart';
import 'package:instagram_clone/views/UploadScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';

class VideosScreen1 extends StatefulWidget {
  const VideosScreen1({super.key});

  @override
  State<VideosScreen1> createState() => _VideosScreen1State();
}

class _VideosScreen1State extends State<VideosScreen1> {
  final _supabase = Supabase.instance.client;
  final _firebaseAuth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String? _profileImageUrl;
  int selectedIndex = 3;
  
  /// Fetch user's profile image from Firestore
  Future<void> _fetchProfileImage() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _profileImageUrl = doc.data()?['profileImage']; // Ensure this key matches Firestore
        });
      }
    } catch (e) {
      print('Error fetching profile image: $e');
    }
  }
  
  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });

    // Navigate to ProfileScreen when the profile item is selected
    if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileView()),
      );
    }
    else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SearchScreen()),
      );
    }
    else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  UploadScreen()),
      );
    }
    else if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FeedPost()),
      );
    }
  }
  
  late PageController _pageController;
  int _currentPage = 0;
  
  // Updated with properly formatted public video URLs that should work
  List<String> videoUrls = [
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-portrait-of-a-fashion-woman-with-a-yellow-background-39700-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-young-woman-taking-a-selfie-in-the-city-43072-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-tree-with-yellow-flowers-1173-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-waves-in-the-water-1164-large.mp4',
  ];
  
  List<VideoPlayerController> _controllers = [];
  List<bool> _isPlaying = [];
  List<bool> _isInitialized = [];

  @override
  void initState() {
    super.initState();
    _fetchProfileImage();
    _pageController = PageController(initialPage: 0);
    
    // Initialize the state tracking for initialization
    for (var i = 0; i < videoUrls.length; i++) {
      _isPlaying.add(false);
      _isInitialized.add(false);
    }
    
    // Initialize video controllers
    for (var i = 0; i < videoUrls.length; i++) {
      final controller = VideoPlayerController.network(videoUrls[i]);
      _controllers.add(controller);
      
      // Initialize the controller and set it to loop
      controller.initialize().then((_) {
        // Only if the widget is still mounted
        if (mounted) {
          setState(() {
            _isInitialized[i] = true;
            // Auto-play the first video only
            if (i == 0) {
              controller.play();
              _isPlaying[0] = true;
            }
          });
          controller.setLooping(true);
        }
      }).catchError((error) {
        print('Error initializing video $i: $error');
      });
    }

    // Add listener to page controller to play/pause videos when page changes
    _pageController.addListener(() {
      if (!mounted) return;
      
      final newPage = _pageController.page!.round();
      if (newPage != _currentPage && newPage < _controllers.length) {
        // Pause the old video
        if (_currentPage < _controllers.length) {
          _controllers[_currentPage].pause();
          setState(() {
            _isPlaying[_currentPage] = false;
          });
        }
        
        // Play the new video if it's initialized
        if (_isInitialized[newPage]) {
          _controllers[newPage].play();
          setState(() {
            _isPlaying[newPage] = true;
          });
        }
        
        _currentPage = newPage;
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: selectedIndex == 0 ? Colors.black : Colors.grey),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, color: selectedIndex == 1 ? Colors.black : Colors.grey),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_rounded, color: selectedIndex == 2 ? Colors.black : Colors.grey),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_collection_sharp, color: selectedIndex == 3 ? Colors.black : Colors.grey),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 15,
              backgroundColor: selectedIndex == 4 ? Colors.black : Colors.grey,
              backgroundImage: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                  ? NetworkImage(_profileImageUrl!) // Use uploaded image
                  : const AssetImage('assets/default_avatar.png') as ImageProvider, // Fallback avatar
            ),
            label: '',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: onItemTapped,
      ),
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: videoUrls.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Toggle play/pause when tapped
              if (!_isInitialized[index]) return;
              
              setState(() {
                if (_isPlaying[index]) {
                  _controllers[index].pause();
                  _isPlaying[index] = false;
                } else {
                  _controllers[index].play();
                  _isPlaying[index] = true;
                }
              });
            },
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.black,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Show video or loading indicator
                  _isInitialized[index]
                      ? FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _controllers[index].value.size.width,
                            height: _controllers[index].value.size.height,
                            child: VideoPlayer(_controllers[index]),
                          ),
                        )
                      : const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                  
                  // Debug info text - you can remove this later
                  Positioned(
                    top: 50,
                    left: 10,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      color: Colors.black.withOpacity(0.5),
                      child: Text(
                        'Video ${index+1}: ${_isInitialized[index] ? "Ready" : "Loading"}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  
                  // Overlay play/pause icon when video is paused
                  if (_isInitialized[index] && !_isPlaying[index])
                    Icon(
                      Icons.play_arrow,
                      size: 80,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    
                  // Add user profile, likes and other UI elements here
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Column(
                      children: [
                        Icon(Icons.favorite, color: Colors.white, size: 30),
                        const SizedBox(height: 5),
                        const Text('241K', style: TextStyle(color: Colors.white)),
                        const SizedBox(height: 15),
                        Icon(Icons.comment, color: Colors.white, size: 30),
                        const SizedBox(height: 5),
                        const Text('1.2K', style: TextStyle(color: Colors.white)),
                        const SizedBox(height: 15),
                        Icon(Icons.share, color: Colors.white, size: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}