import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:instagram_clone/controller/chat/cubit/chat_cubit.dart';
import 'package:instagram_clone/controller/chat/cubit/chat_state.dart';
import 'package:instagram_clone/generated/l10n.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatScreen extends StatefulWidget {
  final String userId;
  final String username;
  final String? profileImage;

  const ChatScreen({
    Key? key,
    required this.userId,
    required this.username,
    this.profileImage,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatCubit _chatCubit;

  @override
  void initState() {
    super.initState();
    _chatCubit = ChatCubit(
      receiverId: widget.userId,
      receiverUsername: widget.username,
      receiverProfileImage: widget.profileImage,
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildUserStatus(bool isOnline, DateTime? lastSeen) {
    if (isOnline) {
      return Row(
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 4),
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          Text(
            S.of(context).Online,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      );
    } else {
      return Text(
        lastSeen != null
            ? 'Last seen ${timeago.format(lastSeen)}'
            : S.of(context).Offline,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      );
    }
  }

  Widget _buildMessage(Map<String, dynamic> message, bool isMe) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.profileImage != null
                  ? NetworkImage(widget.profileImage!)
                  : const AssetImage('assets/profile-icon-design-free-vector.jpg')
                      as ImageProvider,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 0),
                  bottomRight: Radius.circular(isMe ? 0 : 20),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message['message'],
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeago.format(message['timestamp'].toDate()),
                    style: TextStyle(
                      color: isMe ? Colors.white70 : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _chatCubit,
      child: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state.status == ChatStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
          
          // Scroll to bottom when new messages arrive
          if (state.status == ChatStatus.loaded && state.messages.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              elevation: 1,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: widget.profileImage != null
                        ? NetworkImage(widget.profileImage!)
                        : const AssetImage('assets/profile-icon-design-free-vector.jpg')
                            as ImageProvider,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.username,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildUserStatus(
                        state.isOnline, 
                        state.lastSeen?.toDate()
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(FontAwesomeIcons.phone),
                  onPressed: () {
                    // Implement voice call
                  },
                ),
                IconButton(
                  icon: const Icon(FontAwesomeIcons.video),
                  onPressed: () {
                    // Implement video call
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                // Messages List
                Expanded(
                  child: state.status == ChatStatus.initial
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(top: 16),
                          itemCount: state.messages.length,
                          itemBuilder: (context, index) {
                            final message = state.messages[index];
                            final isMe = context.read<ChatCubit>().isCurrentUser(message['senderId']);

                            return _buildMessage(message, isMe);
                          },
                        ),
                ),

                // Input Area
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, -1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (state.isAttachmentVisible)
                        Container(
                          height: 100,
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildAttachmentOption(
                                icon: Icons.image,
                                label: S.of(context).Gallery,
                                color: Colors.purple,
                                onTap: () {
                                  // Implement gallery picker
                                },
                              ),
                              _buildAttachmentOption(
                                icon: Icons.camera_alt,
                                label: S.of(context).Camera,
                                color: Colors.red,
                                onTap: () {
                                  // Implement camera
                                },
                              ),
                              _buildAttachmentOption(
                                icon: Icons.insert_drive_file,
                                label: S.of(context).Document,
                                color: Colors.blue,
                                onTap: () {
                                  // Implement document picker
                                },
                              ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                state.isAttachmentVisible
                                    ? Icons.close
                                    : Icons.add_circle_outline,
                                color: Colors.grey[600],
                              ),
                              onPressed: () {
                                context.read<ChatCubit>().toggleAttachmentVisibility();
                              },
                            ),
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                decoration: InputDecoration(
                                  hintText: S.of(context).Message,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                ),
                                maxLines: null,
                                textCapitalization: TextCapitalization.sentences,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send, color: Colors.blue),
                              onPressed: () {
                                final message = _messageController.text.trim();
                                if (message.isNotEmpty) {
                                  context.read<ChatCubit>().sendMessage(message);
                                  _messageController.clear();
                                }
                              },
                            ),
                          ],
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
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}