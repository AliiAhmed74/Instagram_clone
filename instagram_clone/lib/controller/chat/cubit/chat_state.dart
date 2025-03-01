import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum ChatStatus { initial, loading, loaded, sending, error }

class ChatState extends Equatable {
  final List<Map<String, dynamic>> messages;
  final ChatStatus status;
  final String? errorMessage;
  final bool isAttachmentVisible;
  final bool isOnline;
  final Timestamp? lastSeen;
  final String? currentUserName;
  final String? currentUserProfileImage;

  const ChatState({
    this.messages = const [],
    this.status = ChatStatus.initial,
    this.errorMessage,
    this.isAttachmentVisible = false,
    this.isOnline = false,
    this.lastSeen,
    this.currentUserName,
    this.currentUserProfileImage,
  });

  ChatState copyWith({
    List<Map<String, dynamic>>? messages,
    ChatStatus? status,
    String? errorMessage,
    bool? isAttachmentVisible,
    bool? isOnline,
    Timestamp? lastSeen,
    String? currentUserName,
    String? currentUserProfileImage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      status: status ?? this.status,
      errorMessage: errorMessage,
      isAttachmentVisible: isAttachmentVisible ?? this.isAttachmentVisible,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      currentUserName: currentUserName ?? this.currentUserName,
      currentUserProfileImage: currentUserProfileImage ?? this.currentUserProfileImage,
    );
  }

  @override
  List<Object?> get props => [
        messages,
        status,
        errorMessage,
        isAttachmentVisible,
        isOnline,
        lastSeen,
        currentUserName,
        currentUserProfileImage,
      ];
}