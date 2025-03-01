import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/generated/l10n.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

class LikesSection extends StatefulWidget {
  const LikesSection({Key? key}) : super(key: key);

  @override
  State<LikesSection> createState() => _LikesSectionState();
}

class _LikesSectionState extends State<LikesSection> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  Map<String, bool> _followingStatus = {};

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _checkFollowingStatus(String userId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final response = await _supabase
          .from('follows')
          .select()
          .eq('follower_id', currentUser.uid)
          .eq('following_id', userId)
          .single();

      setState(() {
        _followingStatus[userId] = response != null;
      });
    } catch (e) {
      // If no record is found, user is not following
      setState(() {
        _followingStatus[userId] = false;
      });
    }
  }

  Future<void> _toggleFollow(String userId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final isFollowing = _followingStatus[userId] ?? false;

      if (isFollowing) {
        // Unfollow
        await _supabase
            .from('follows')
            .delete()
            .eq('follower_id', currentUser.uid)
            .eq('following_id', userId);

        setState(() {
          _followingStatus[userId] = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).Unfollowed_user)),
        );
      } else {
        // Follow
        await _supabase.from('follows').insert({
          'follower_id': currentUser.uid,
          'following_id': userId,
          'created_at': DateTime.now().toIso8601String(),
        });

        setState(() {
          _followingStatus[userId] = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).Started_following_user)),
        );
      }
    } catch (e) {
      print('Error toggling follow: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update follow status. Please try again.')),
      );
    }
  }

  Future<void> _fetchNotifications() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      List<Map<String, dynamic>> allNotifications = [];

      // 1. Fetch Likes
      final userPosts = await _supabase
          .from('posts')
          .select('id, image_url, description')
          .eq('user_id', currentUser.uid);

      for (var post in userPosts) {
        final likes = await _supabase
            .from('likes')
            .select('user_id, created_at')
            .eq('post_id', post['id'])
            .neq('user_id', currentUser.uid);

        for (var like in likes) {
          final userDoc = await _firestore
              .collection('users')
              .doc(like['user_id'])
              .get();

          if (userDoc.exists) {
            allNotifications.add({
              'type': 'like',
              'post_id': post['id'],
              'post_image': post['image_url'],
              'user_id': like['user_id'],
              'username': userDoc.data()?['username'] ?? 'Unknown User',
              'profile_image': userDoc.data()?['profileImage'] ?? '',
              'timestamp': DateTime.parse(like['created_at']),
            });
          }
        }
      }

      // 2. Fetch Comments
      for (var post in userPosts) {
        final comments = await _supabase
            .from('comments')
            .select('*, user_id, created_at, comment_text')
            .eq('post_id', post['id'])
            .neq('user_id', currentUser.uid);

        for (var comment in comments) {
          final userDoc = await _firestore
              .collection('users')
              .doc(comment['user_id'])
              .get();

          if (userDoc.exists) {
            allNotifications.add({
              'type': 'comment',
              'post_id': post['id'],
              'post_image': post['image_url'],
              'user_id': comment['user_id'],
              'username': userDoc.data()?['username'] ?? 'Unknown User',
              'profile_image': userDoc.data()?['profileImage'] ?? '',
              'comment': comment['comment_text'],
              'timestamp': DateTime.parse(comment['created_at']),
            });
          }
        }
      }

      // 3. Fetch Follows
      final follows = await _supabase
          .from('follows')
          .select('follower_id, created_at')
          .eq('following_id', currentUser.uid);

      for (var follow in follows) {
        final userDoc = await _firestore
            .collection('users')
            .doc(follow['follower_id'])
            .get();

        if (userDoc.exists) {
          allNotifications.add({
            'type': 'follow',
            'user_id': follow['follower_id'],
            'username': userDoc.data()?['username'] ?? 'Unknown User',
            'profile_image': userDoc.data()?['profileImage'] ?? '',
            'timestamp': DateTime.parse(follow['created_at']),
          });
          // Check following status for this user
          await _checkFollowingStatus(follow['follower_id']);
        }
      }

      // Sort all notifications by timestamp
      allNotifications.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

      setState(() {
        _notifications = allNotifications;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching notifications: $e');
      setState(() => _isLoading = false);
    }
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    String actionText = '';
    Widget? trailing;

    switch (notification['type']) {
      case 'like':
        actionText = S.of(context).liked_your_post;
        if (notification['post_image'] != null) {
          trailing = Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(notification['post_image']),
                fit: BoxFit.cover,
              ),
            ),
          );
        }
        break;
      case 'comment':
        actionText = '${S.of(context).commented} ${notification['comment']}';
        if (notification['post_image'] != null) {
          trailing = Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(notification['post_image']),
                fit: BoxFit.cover,
              ),
            ),
          );
        }
        break;
      case 'follow':
        actionText = S.of(context).started_following_you;
        final isFollowing = _followingStatus[notification['user_id']] ?? false;
        trailing = TextButton(
          onPressed: () => _toggleFollow(notification['user_id']),
          style: TextButton.styleFrom(
            backgroundColor: isFollowing ? Colors.grey[200] : Colors.blue,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            isFollowing ? S.of(context).Following : S.of(context).Follow_back,
            style: TextStyle(
              color: isFollowing ? Colors.black : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
        break;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: notification['profile_image'].isNotEmpty
            ? NetworkImage(notification['profile_image'])
            : AssetImage('assets/profile-icon-design-free-vector.jpg')
                as ImageProvider,
      ),
      title: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          children: [
            TextSpan(
              text: notification['username'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: ' $actionText'),
          ],
        ),
      ),
      subtitle: Text(
        timeago.format(notification['timestamp']),
        style: TextStyle(color: Colors.grey),
      ),
      trailing: trailing,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).Notifcation,
          style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).iconTheme.color,
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Text(
                    S.of(context).No_notifications_yet,
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        _buildNotificationItem(_notifications[index]),
                        Divider(),
                      ],
                    );
                  },
                ),
    );
  }
}