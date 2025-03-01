import 'package:flutter/material.dart';
import 'package:instagram_clone/generated/l10n.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostComments extends StatefulWidget {
  final String postId;
  
  const PostComments({
    Key? key,
    required this.postId,
  }) : super(key: key);

  @override
  State<PostComments> createState() => _PostCommentsState();
}

class _PostCommentsState extends State<PostComments> {
  final TextEditingController _commentController = TextEditingController();
  final SupabaseClient _supabase = Supabase.instance.client;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> comments = [];
  bool _isLoading = false;
  Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    _fetchComments();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _userData = doc.data() ?? {};
          });
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  Future<void> _fetchComments() async {
    try {
      setState(() => _isLoading = true);
      
      // First, fetch comments for the specific post
      final response = await _supabase
          .from('comments')
          .select()
          .eq('post_id', widget.postId)
          .order('created_at', ascending: true);

      if (response == null) {
        setState(() {
          comments = [];
          _isLoading = false;
        });
        return;
      }

      List<Map<String, dynamic>> commentsList = List<Map<String, dynamic>>.from(response);

      // Fetch user data for each comment
      List<Map<String, dynamic>> enrichedComments = [];
      for (var comment in commentsList) {
        try {
          final userDoc = await _firestore
              .collection('users')
              .doc(comment['user_id'])
              .get();
          
          if (userDoc.exists) {
            comment['user_data'] = userDoc.data();
            enrichedComments.add(comment);
          }
        } catch (e) {
          print('Error fetching user data for comment: $e');
          // Add the comment even without user data
          comment['user_data'] = {'username': 'Unknown User'};
          enrichedComments.add(comment);
        }
      }

      setState(() {
        comments = enrichedComments;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching comments: $e');
      setState(() {
        _isLoading = false;
        comments = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading comments. Please try again.')),
      );
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      // Insert comment
      await _supabase.from('comments').insert({
        'post_id': widget.postId,
        'user_id': user.uid,
        'comment_text': _commentController.text.trim(),
      });

      _commentController.clear();
      await _fetchComments(); // Refresh comments after adding new one
    } catch (e) {
      print('Error adding comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add comment. Please try again.')),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          S.of(context).Comments,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : comments.isEmpty
                    ? Center(
                        child: Text(
                          S.of(context).No_Comments_yet,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          final userData = comment['user_data'];
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 15,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundImage: userData?['profileImage'] != null
                                      ? NetworkImage(userData['profileImage'])
                                      : AssetImage('assets/profile-icon-design-free-vector.jpg')
                                          as ImageProvider,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: userData?['username'] ?? 'Unknown User',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: Theme.of(context).primaryColor
                                                
                                              ),
                                            ),
                                            TextSpan(
                                              text: ' ${comment['comment_text']}',
                                              style: TextStyle(color: Theme.of(context).primaryColor),
                                              
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        timeago.format(
                                          DateTime.parse(comment['created_at']),
                                        ),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: _userData['profileImage'] != null
                      ? NetworkImage(_userData['profileImage'])
                      : AssetImage('assets/profile-icon-design-free-vector.jpg')
                          as ImageProvider,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: S.of(context).Add_a_Commment,
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey[400]),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                  ),
                ),
                TextButton(
                  onPressed: _addComment,
                  child: Text(
                    S.of(context).Post,
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}