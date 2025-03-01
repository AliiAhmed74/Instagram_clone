import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileSaveCards extends StatefulWidget {
  const ProfileSaveCards({super.key});

  @override
  State<ProfileSaveCards> createState() => _ProfileSaveCardsState();
}

class _ProfileSaveCardsState extends State<ProfileSaveCards> {
  final _supabase = Supabase.instance.client;
  final _firebaseAuth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _savedPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSavedPosts();
  }

  Future<void> _fetchSavedPosts() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    try {
      final response = await _supabase
          .from('saved_posts')
          .select('posts(*)')
          .eq('user_id', user.uid);

      setState(() {
        _savedPosts = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return GridView.builder(
      itemCount: _savedPosts.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2.0,
        mainAxisSpacing: 2.0,
      ),
      itemBuilder: (context, index) {
        final post = _savedPosts[index]['posts'];
        return Image.network(
          post['image_url'],
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        );
      },
    );
  }
}