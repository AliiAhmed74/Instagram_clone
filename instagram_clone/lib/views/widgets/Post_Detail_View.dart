import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:instagram_clone/generated/l10n.dart';
import 'package:instagram_clone/views/widgets/Post_Comments.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostDetailView extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostDetailView({required this.post, super.key});

  @override
  State<PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<PostDetailView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? postUserData;  // Data of the user who created the post
  final _supabase = Supabase.instance.client;
  final _firebaseAuth = FirebaseAuth.instance;
  bool _isLiked = false;
  bool _isSaved = false;
  int _likesCount = 0;
  int _commentsCount = 0;
  bool _isExpanded = false;
  bool _isCurrentUser = false;  // Flag to check if the current user is the post owner

  @override
  void initState() {
    super.initState();
    _likesCount = widget.post['likes'] ?? 0;
    _checkIfLiked();
    _checkIfSaved();
    fetchPostUserData();
    _checkIfCurrentUser();
  }

  // Check if the current user is the post owner
  void _checkIfCurrentUser() {
    final user = _firebaseAuth.currentUser;
    if (user != null && widget.post['user_id'] != null) {
      setState(() {
        _isCurrentUser = user.uid == widget.post['user_id'];
      });
    }
  }

  Future<void> fetchPostUserData() async {
    final postUserId = widget.post['user_id'];  // Get the post creator's ID
    if (postUserId != null) {
      try {
        // Fetch user data from Supabase
        final response = await _supabase
            .from('users')
            .select()
            .eq('uid', postUserId)
            .single();
            
        setState(() {
          postUserData = response;
        });
      } catch (e) {
        print('Error fetching post user data: $e');
        // Fallback to Firestore if needed
        final doc = await _firestore.collection('users').doc(postUserId).get();
        if (doc.exists) {
          setState(() {
            postUserData = doc.data()!;
          });
        }
      }
    }
  }

  // Check if the current user has liked the post
  Future<void> _checkIfLiked() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    try {
      final response = await _supabase
          .from('likes')
          .select()
          .eq('user_id', user.uid)
          .eq('post_id', widget.post['id'])
          .maybeSingle();

      if (response != null) {
        setState(() {
          _isLiked = true;
        });
      }
    } catch (e) {
      print('Error checking if liked: $e');
    }
  }

  // Check if the current user has saved the post
  Future<void> _checkIfSaved() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    try {
      final response = await _supabase
          .from('saved_posts')
          .select()
          .eq('user_id', user.uid)
          .eq('post_id', widget.post['id'])
          .maybeSingle();

      if (response != null) {
        setState(() {
          _isSaved = true;
        });
      }
    } catch (e) {
      print('Error checking if saved: $e');
    }
  }

  // Handle like action
  Future<void> _toggleLike() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    setState(() {
      _isLiked = !_isLiked;
      _likesCount = _isLiked ? _likesCount + 1 : _likesCount - 1;
    });

    try {
      if (_isLiked) {
        // Add like to the database
        await _supabase.from('likes').insert({
          'user_id': user.uid,
          'post_id': widget.post['id'],
        });
        print('Like inserted successfully');
      } else {
        // Remove like from the database
        await _supabase
            .from('likes')
            .delete()
            .eq('user_id', user.uid)
            .eq('post_id', widget.post['id']);
        print('Like deleted successfully');
      }

      // Update likes count in the posts table
      await _supabase
          .from('posts')
          .update({'likes': _likesCount}).eq('id', widget.post['id']);
      print('Likes count updated successfully');
    } catch (e) {
      print('Error toggling like: $e');
      setState(() {
        _isLiked = !_isLiked; // Revert the like state
        _likesCount = _isLiked ? _likesCount + 1 : _likesCount - 1;
      });
    }
  }

  // Handle save action
  Future<void> _toggleSave() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    setState(() {
      _isSaved = !_isSaved;
    });

    try {
      if (_isSaved) {
        // Add post to saved_posts
        await _supabase.from('saved_posts').insert({
          'user_id': user.uid,
          'post_id': widget.post['id'],
        });
        print('Post saved successfully');
      } else {
        // Remove post from saved_posts
        await _supabase
            .from('saved_posts')
            .delete()
            .eq('user_id', user.uid)
            .eq('post_id', widget.post['id']);
        print('Post unsaved successfully');
      }
    } catch (e) {
      print('Error toggling save: $e');
      setState(() {
        _isSaved = !_isSaved; // Revert the save state
      });
    }
  }

  // Handle post deletion
  Future<void> _deletePost() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).Delete_post),
        content: Text(S.of(context).Are_you_sure_you_want_to_delete_this_post),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.of(context).Cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              S.of(context).Delete,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      // Delete comments for this post
      await _supabase
          .from('comments')
          .delete()
          .eq('post_id', widget.post['id']);
      
      // Delete likes for this post
      await _supabase
          .from('likes')
          .delete()
          .eq('post_id', widget.post['id']);
      
      // Delete saved posts references
      await _supabase
          .from('saved_posts')
          .delete()
          .eq('post_id', widget.post['id']);
      
      // Finally delete the post itself
      await _supabase
          .from('posts')
          .delete()
          .eq('id', widget.post['id']);
      
      // Close loading dialog
      Navigator.pop(context);
      
      // Close post detail view and go back
      Navigator.pop(context, true); // Pass true to indicate post was deleted
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).Post_deleted_successfully)),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      
      print('Error deleting post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).Failed_to_delete_post)),
      );
    }
  }

  String _getTimeAgo() {
    if (widget.post['created_at'] == null) return '';
    
    DateTime createdAt;
    if (widget.post['created_at'] is DateTime) {
      createdAt = widget.post['created_at'];
    } else {
      createdAt = DateTime.parse(widget.post['created_at']);
    }
    
    return timeago.format(createdAt);
  }

  void _showComments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostComments(
          postId: widget.post['id'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final username = postUserData?['username'] ?? postUserData?['fullName'] ?? S.of(context).Loading;
    final description = widget.post['description'] ?? '';
    final hasHashtags = description.contains('#');
    String mainDescription = description;
    String hashtagsText = '';
    
    if (hasHashtags) {
      final parts = description.split(RegExp(r'(#[^\s#]+)'));
      final hashtags = RegExp(r'#[^\s#]+').allMatches(description).map((m) => m.group(0)).toList();
      mainDescription = parts.where((part) => !part.startsWith('#')).join(' ').trim();
      hashtagsText = hashtags.join(' ');
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Header - Updated with verified badge and more professional layout
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: postUserData == null ? LinearGradient(
                        colors: [Colors.purple.shade400, Colors.orange.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ) : null,
                      color: Colors.grey[300],
                      image: postUserData != null &&
                              postUserData!['profileImage'] != null &&
                              postUserData!['profileImage'].isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(postUserData!['profileImage']),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: postUserData == null ||
                            postUserData!['profileImage'] == null ||
                            postUserData!['profileImage'].isEmpty
                        ? const Icon(Icons.person,
                            size: 20, color: Colors.white)
                        : null,
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            username,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4),
                          if (postUserData?['isVerified'] == true)
                            Icon(Icons.verified, size: 14, color: Colors.blue),
                        ],
                      ),
                      if (postUserData?['location'] != null)
                        Text(
                          postUserData!['location'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.more_vert),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isCurrentUser)
                              ListTile(
                                leading: Icon(Icons.delete, color: Colors.red),
                                title: Text(
                                  S.of(context).Delete_post,
                                  style: TextStyle(color: Colors.red),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  _deletePost();
                                },
                              )
                            else
                              ListTile(
                                leading: Icon(Icons.share),
                                title: Text(S.of(context).Share),
                                onTap: () {
                                  Navigator.pop(context);
                                  // Handle share
                                },
                              ),
                            if (!_isCurrentUser)
                              ListTile(
                                leading: Icon(Icons.report),
                                title: Text(S.of(context).Report),
                                onTap: () {
                                  Navigator.pop(context);
                                  // Handle report
                                },
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Post Image
            Container(
              height: MediaQuery.of(context).size.width,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Image.network(
                widget.post['image_url'],
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / 
                            (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                  );
                },
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 28,
                      color: _isLiked ? Colors.red : theme.iconTheme.color,
                    ),
                    onPressed: _toggleLike,
                  ),
                  IconButton(
                    icon: Icon(FontAwesomeIcons.comment, size: 24),
                    onPressed: _showComments,
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(
                      _isSaved ? Icons.bookmark : Icons.bookmark_border,
                      size: 28,
                    ),
                    onPressed: _toggleSave,
                  ),
                ],
              ),
            ),

            // Enhanced Likes Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    '$_likesCount ${_likesCount == 1 ? S.of(context).like : S.of(context).likes}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 16),
                ],
              ),
            ),

            // Enhanced Post Description
            Container(
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Username + Description
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                      children: [
                        TextSpan(
                          text: '$username ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: mainDescription,
                        ),
                      ],
                    ),
                  ),
                  
                  // Hashtags (if any)
                  if (hashtagsText.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        hashtagsText,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    
                  // View all comments button
                  if (_commentsCount > 0)
                    TextButton(
                      onPressed: _showComments,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        alignment: Alignment.centerLeft,
                      ),
                      child: Text(
                        S.of(context).View_all_comments,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    
                  // Timestamp
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                    child: Text(
                      _getTimeAgo(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
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
}