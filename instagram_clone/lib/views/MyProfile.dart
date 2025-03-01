import 'package:flutter/material.dart';
import 'package:instagram_clone/views/FeedPost.dart';
import 'package:instagram_clone/views/ReelsScreen.dart';
import 'package:instagram_clone/views/SearchScreen.dart';
import 'package:instagram_clone/views/UploadScreen.dart';
import 'package:instagram_clone/views/VediosScreen1.dart';
import 'package:instagram_clone/views/widgets/Profile_Save_Card.dart';
import 'package:instagram_clone/views/widgets/Profile_Post_Card.dart';
import 'package:instagram_clone/views/widgets/Profile_reels_Card.dart';
import 'package:instagram_clone/views/widgets/profile_header_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  int selectedIndex = 4;
  final _supabase = Supabase.instance.client;
  final _firebaseAuth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _fetchProfileImage();
  }

  /// Fetch user's profile image from Firestore
  Future<void> _fetchProfileImage() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _profileImageUrl =
              doc.data()?['profileImage']; // Ensure this key matches Firestore
        });
      }
    } catch (e) {
      print('Error fetching profile image: $e');
    }
  }

  /// Fetch user posts from Supabase
  Future<void> _fetchPosts() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    try {
      final response = await _supabase
          .from('posts')
          .select()
          .eq('user_id', user.uid)
          .order('created_at', ascending: false);

      setState(() {
        _posts = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching posts: $e')),
      );
    }
  }

  /// Handle navigation on bottom bar tap
  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });

    if (index == 0) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => FeedPost()));
    } else if (index == 1) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const SearchScreen()));
    } else if (index == 2) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => UploadScreen()));
    } else if (index == 3) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => VideosScreen1()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home,
                  color: selectedIndex == 0
                      ? Theme.of(context).primaryColor
                      : Colors.grey),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search,
                  color: selectedIndex == 1
                      ? Theme.of(context).primaryColor
                      : Colors.grey),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_rounded,
                  color: selectedIndex == 2
                      ? Theme.of(context).primaryColor
                      : Colors.grey),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_collection_sharp,
                  color: selectedIndex == 3
                      ? Theme.of(context).primaryColor
                      : Colors.grey),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: CircleAvatar(
                backgroundImage: _profileImageUrl != null
                    ? NetworkImage(_profileImageUrl!)
                    : const AssetImage(
                            'assets/profile-icon-design-free-vector.jpg')
                        as ImageProvider,
                radius: 15,
              ),
              label: '',
            ),
          ],
          currentIndex: selectedIndex,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          onTap: onItemTapped,
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, value) {
            return [ProfileHeaderCard()];
          },
          body: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.add_a_photo)),
                  Tab(icon: Icon(Icons.play_circle_outline)),
                  Tab(icon: Icon(Icons.bookmark_outline)),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : ProfilePostCards(posts: _posts),
                    ProfileReelsCards(),
                    ProfileSaveCards(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
