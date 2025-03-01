import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:instagram_clone/generated/l10n.dart';
import 'package:instagram_clone/views/ChatScreen.dart';
import 'package:timeago/timeago.dart' as timeago;
// import 'chat_screen.dart'; // You'll need to create this screen later

class UsersToChat extends StatefulWidget {
  const UsersToChat({Key? key}) : super(key: key);

  @override
  State<UsersToChat> createState() => _UsersToChatState();
}

class _UsersToChatState extends State<UsersToChat> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _users = [];
  List<DocumentSnapshot> _filteredUsers = [];
  bool _isLoading = true;
  Map<String, Map<String, dynamic>> _lastMessages = {};

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }
    String getChatRoomId(String user1, String user2) {
    List<String> ids = [user1, user2];
    ids.sort();
    return ids.join('_');
  }

  Future<void> _fetchUsers() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final usersSnapshot = await _firestore.collection('users').get();
      final users = usersSnapshot.docs
          .where((doc) => doc.id != currentUser.uid)
          .toList();

      // Fetch last messages for all users
      for (var user in users) {
        final chatRoomId = getChatRoomId(currentUser.uid, user.id);
        final lastMessageDoc = await _firestore
            .collection('chatRooms')
            .doc(chatRoomId)
            .get();

        if (lastMessageDoc.exists) {
          final data = lastMessageDoc.data() as Map<String, dynamic>;
          _lastMessages[user.id] = {
            'message': data['lastMessage'],
            'timestamp': data['lastMessageTime'],
            'senderId': data['lastMessageSenderId'],
          };
        }
      }

      setState(() {
        _users = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching users: $e');
      setState(() => _isLoading = false);
    }
  }

   void _filterUsers(String query) {
   setState(() {
      _filteredUsers = _users.where((user) {
        final userData = user.data() as Map<String, dynamic>;
        final username = userData['username']?.toString().toLowerCase() ?? '';
        return username.contains(query.toLowerCase());
      }).toList();
    });
  }
    Widget _buildLastMessage(String userId) {
    final currentUser = _auth.currentUser;
    final lastMessage = _lastMessages[userId];

    if (lastMessage == null) {
      return Text(
        S.of(context).Tap_to_Start_Chatting,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final isMe = lastMessage['senderId'] == currentUser?.uid;
    final messageText = lastMessage['message'] as String;
    
    return Text(
      '${isMe ? "You: " : ""}$messageText',
      style: TextStyle(
        color: Colors.grey[600],
        fontSize: 14,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTimestamp(String userId) {
    final lastMessage = _lastMessages[userId];
    
    if (lastMessage == null) {
      return Container(); // Empty container if no messages
    }

    final timestamp = (lastMessage['timestamp'] as Timestamp).toDate();
    
    return Text(
      timeago.format(timestamp),
      style: TextStyle(
        color: Colors.grey[600],
        fontSize: 12,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title:  Text(
          S.of(context).Messages,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.video,),
            onPressed: () {
              // Implement video call feature
            },
          ),
          IconButton(
            icon: const Icon(FontAwesomeIcons.penToSquare,),
            onPressed: () {
              // Implement new message feature
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterUsers,
                decoration: InputDecoration(
                  hintText: S.of(context).Search,
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search,color:Colors.grey ,),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ),

          // Users List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final userData = _filteredUsers[index].data() as Map<String, dynamic>;
                      final userId = _filteredUsers[index].id;
                      
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                userId: userId,
                                username: userData['username'],
                                profileImage: userData['profileImage'],
                              ),
                            ),
                          ).then((_) => _fetchUsers()); // Refresh messages after returning
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              // Profile Image with online indicator
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundImage: userData['profileImage'] != null
                                        ? NetworkImage(userData['profileImage'])
                                        : const AssetImage('assets/profile-icon-design-free-vector.jpg')
                                            as ImageProvider,
                                  ),
                                  if (userData['isOnline'] == true)
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              // User Info and Last Message
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userData['username'] ?? 'Unknown User',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    _buildLastMessage(userId),
                                  ],
                                ),
                              ),
                              // Timestamp
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _buildTimestamp(userId),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}