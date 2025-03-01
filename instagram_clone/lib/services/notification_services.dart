import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/views/UsersToChat.dart';

class TopNotificationBanner extends StatefulWidget {
  final String username;
  final String message;
  final String? profileImage;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  final String notificationId; // Add this

  const TopNotificationBanner({
    Key? key,
    required this.username,
    required this.message,
    this.profileImage,
    required this.onTap,
    required this.onDismiss,
    required this.notificationId, // Add this
  }) : super(key: key);

  @override
  State<TopNotificationBanner> createState() => _TopNotificationBannerState();
}

class _TopNotificationBannerState extends State<TopNotificationBanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _controller.forward();

    // Auto dismiss after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    NotificationService().markNotificationAsRead(widget.notificationId, dismiss: true);
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  SlideTransition(
    position: _offsetAnimation,
    child: Material(
      elevation: 4,
      child: InkWell( // Add this to make the whole banner tappable
        onTap: (){
          Navigator.push(context,  MaterialPageRoute(builder: (context) => UsersToChat()));
        },
        child: Container(
          width: double.infinity,
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.grey[850] 
              : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: widget.profileImage != null
                    ? NetworkImage(widget.profileImage!)
                    : const AssetImage('assets/profile-icon-design-free-vector.jpg')
                        as ImageProvider,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.message,
                      style: const TextStyle(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: _dismiss,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
  }

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getUnreadNotifications() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.empty();
    }

    return _firestore
        .collection('notifications')
        .where('receiverId', isEqualTo: user.uid)
        .where('read', isEqualTo: false)
        .snapshots();
  }

Stream<QuerySnapshot> getLatestNotification() {
  final user = _auth.currentUser;
  if (user == null) {
    return Stream.empty();
  }

  return _firestore
      .collection('notifications')
      .where('receiverId', isEqualTo: user.uid)
      .where('read', isEqualTo: false)
      .where('dismissed', isEqualTo: false) // Only get non-dismissed notifications
      .orderBy('timestamp', descending: true)
      .limit(1)
      .snapshots();
}

  Future<void> markNotificationAsRead(String notificationId, {bool dismiss = false}) async {
  final Map<String, dynamic> updates = {'read': true};
  if (dismiss) {
    updates['dismissed'] = true;
  }
  await _firestore
      .collection('notifications')
      .doc(notificationId)
      .update(updates);
}

  Future<void> storeMessageNotification({
  required String receiverId,
  required String message,
  required String senderName,
  String? senderProfileImage,
}) async {
  await _firestore.collection('notifications').add({
    'type': 'message',
    'receiverId': receiverId,
    'senderId': _auth.currentUser?.uid,
    'senderName': senderName,
    'senderProfileImage': senderProfileImage,
    'message': message,
    'timestamp': FieldValue.serverTimestamp(),
    'read': false,
    'dismissed': false, // Add this new field
  });
}
}