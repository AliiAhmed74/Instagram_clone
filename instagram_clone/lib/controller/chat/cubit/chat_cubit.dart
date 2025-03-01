import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_clone/controller/chat/cubit/chat_state.dart';
import 'package:instagram_clone/services/notification_services.dart';

class ChatCubit extends Cubit<ChatState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();
  
  final String receiverId;
  final String receiverUsername;
  final String? receiverProfileImage;
  
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _userStatusSubscription;

  ChatCubit({
    required this.receiverId,
    required this.receiverUsername,
    this.receiverProfileImage,
  }) : super(const ChatState()) {
    updateUserStatus(true);
    getCurrentUserInfo();
    listenToUserStatus();
    listenToMessages();
  }
  bool isCurrentUser(String senderId) {
  final currentUserId = _auth.currentUser?.uid;
  return senderId == currentUserId;
}

  String getChatRoomId() {
    final currentUserId = _auth.currentUser?.uid ?? '';
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    return ids.join('_');
  }

  void listenToUserStatus() {
    _userStatusSubscription = _firestore
        .collection('users')
        .doc(receiverId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final userData = snapshot.data() as Map<String, dynamic>?;
        final isOnline = userData?['isOnline'] ?? false;
        final lastSeen = userData?['lastSeen'] as Timestamp?;
        emit(state.copyWith(isOnline: isOnline, lastSeen: lastSeen));
      }
    });
  }

  void listenToMessages() {
    final chatRoomId = getChatRoomId();
    _messagesSubscription = _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snapshot) {
      final messages = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      emit(state.copyWith(
        messages: messages,
        status: ChatStatus.loaded,
      ));
    }, onError: (error) {
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: 'Failed to load messages: $error',
      ));
    });
  }

  Future<void> getCurrentUserInfo() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        emit(state.copyWith(
          currentUserName: userDoc.data()?['username'] ?? 'User',
          currentUserProfileImage: userDoc.data()?['profileImage'],
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: 'Failed to get user info: $e',
      ));
    }
  }

  Future<void> updateUserStatus(bool isOnline) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _firestore.collection('users').doc(currentUser.uid).update({
          'isOnline': isOnline,
          'lastSeen': Timestamp.now(),
        });
      }
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: 'Failed to update user status: $e',
      ));
    }
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    emit(state.copyWith(status: ChatStatus.sending));

    try {
      final chatRoomId = getChatRoomId();
      final timestamp = Timestamp.now();

      // Add message to chat collection
      await _firestore.collection('chats').doc(chatRoomId).collection('messages').add({
        'senderId': currentUser.uid,
        'receiverId': receiverId,
        'message': message,
        'timestamp': timestamp,
        'type': 'text',
      });

      // Update last message in chat rooms collection
      await _firestore.collection('chatRooms').doc(chatRoomId).set({
        'participants': [currentUser.uid, receiverId],
        'lastMessage': message,
        'lastMessageTime': timestamp,
        'lastMessageSenderId': currentUser.uid,
      });

      // Store notification for the receiver if they're offline
      await _notificationService.storeMessageNotification(
        receiverId: receiverId,
        message: message,
        senderName: state.currentUserName ?? 'User',
        senderProfileImage: state.currentUserProfileImage,
      );

      emit(state.copyWith(status: ChatStatus.loaded));
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: 'Failed to send message: $e',
      ));
    }
  }

  void toggleAttachmentVisibility() {
    emit(state.copyWith(isAttachmentVisible: !state.isAttachmentVisible));
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    _userStatusSubscription?.cancel();
    updateUserStatus(false);
    return super.close();
  }
}