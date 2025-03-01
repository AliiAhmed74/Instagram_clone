import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:instagram_clone/controller/FeedPost/feed_post_cubit.dart';
import 'package:instagram_clone/controller/FeedPost/feed_post_state.dart';
import 'package:instagram_clone/generated/l10n.dart';
import 'package:instagram_clone/services/notification_services.dart';
import 'package:instagram_clone/views/ChatScreen.dart';
import 'package:instagram_clone/views/LikesSection.dart';
import 'package:instagram_clone/views/LoginPage.dart';
import 'package:instagram_clone/views/MyProfile.dart';
import 'package:instagram_clone/views/MyStoriesScreen.dart';
import 'package:instagram_clone/views/ReelsScreen.dart';
import 'package:instagram_clone/views/SearchScreen.dart';
import 'package:instagram_clone/views/UploadScreen.dart';
import 'package:instagram_clone/views/UsersStoriesScreen.dart';
import 'package:instagram_clone/views/UsersToChat.dart';
import 'package:instagram_clone/views/VediosScreen1.dart';
import 'package:instagram_clone/views/widgets/Post_Comments.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedPost extends StatefulWidget {
  const FeedPost({super.key});

  @override
  State<FeedPost> createState() => _FeedPostState();
}

class _FeedPostState extends State<FeedPost> {
  int selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FeedPostCubit(),
      child: BlocBuilder<FeedPostCubit, FeedPostState>(
        builder: (context, state) {
          return _buildScaffold(context, state);
        },
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, FeedPostState state) {
    final cubit = context.read<FeedPostCubit>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: _buildBottomNav(state.profileImageUrl),
      body: Stack(
        children: [
          state.isLoading 
            ? const Center(child: CircularProgressIndicator())
            : _buildContentList(context, state, cubit),
          if (state.showNotificationBanner && state.currentNotification != null)
            _buildNotificationBanner(context, state, cubit),
        ],
      ),
    );
  }

  Widget _buildBottomNav(String? profileImageUrl) {
    return BottomNavigationBar(
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
            backgroundImage: profileImageUrl != null
                ? NetworkImage(profileImageUrl)
                : const AssetImage('assets/profile-icon-design-free-vector.jpg')
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
    );
  }

  Widget _buildContentList(BuildContext context, FeedPostState state, FeedPostCubit cubit) {
    void showMessage(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }

    return ListView(
      children: [
        _buildAppBar(context, cubit),
        _buildStories(context, state, cubit),
        const Divider(),
        _buildPostsList(context, state, cubit, showMessage),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, FeedPostCubit cubit) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Container(
            width: 120,
            height: 50,
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Image.asset(
              Theme.of(context).brightness == Brightness.light
                  ? 'assets/instagram_text.png' // Light mode image
                  : 'assets/IG_logo.png', // Dark mode image
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LikesSection()),
              );
            },
            icon: Icon(
              FontAwesomeIcons.heart,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
          const SizedBox(width: 20),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UsersToChat()),
              );
            },
            icon: Icon(
              FontAwesomeIcons.facebookMessenger,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
          const SizedBox(width: 20),
          IconButton(
            onPressed: () async {
              await cubit.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            icon: Icon(
              FontAwesomeIcons.rightFromBracket,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStories(BuildContext context, FeedPostState state, FeedPostCubit cubit) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Your Story
          _buildYourStory(context, state, cubit),
          // Other Users' Stories
          ..._buildOtherStories(context, state),
        ],
      ),
    );
  }

  Widget _buildYourStory(BuildContext context, FeedPostState state, FeedPostCubit cubit) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 75.7,
                height: 75.7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.red],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyStoriesScreen(
                        profileImageUrl: state.profileImageUrl,
                      ),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 35,
                  backgroundImage: state.profileImageUrl != null
                      ? NetworkImage(state.profileImageUrl!)
                      : const AssetImage('assets/profile-icon-design-free-vector.jpg')
                          as ImageProvider,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    _showStoryOptions(context, cubit);
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            S.of(context).Your_Story,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOtherStories(BuildContext context, FeedPostState state) {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    return state.stories.map((story) {
      final userId = story['userid'];
      final userData = state.storyUserData[userId];

      // Skip if it's the current user's story
      if (userId == currentUser?.uid) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserStoriesScreen(
                      userId: story['userid'],
                      username: userData?['username'],
                      profileImage: userData?['profileImage'],
                    ),
                  ),
                );
              },
              child: Container(
                width: 75.7,
                height: 75.7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.red],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundImage: userData?['profileImage'] != null
                        ? NetworkImage(userData!['profileImage'])
                        : const AssetImage('assets/profile-icon-design-free-vector.jpg')
                            as ImageProvider,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              userData?['username'] ?? 'User',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildPostsList(BuildContext context, FeedPostState state, FeedPostCubit cubit, Function(String) showMessage) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: state.posts.length,
      itemBuilder: (context, index) {
        final post = state.posts[index];
        final postId = post['id'].toString();
        final isSaved = state.savedPosts.contains(postId);
        final username = post['username'] ?? 'Unknown User';
        final profileImage = post['profileImage'] ?? '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: profileImage.isNotEmpty
                        ? NetworkImage(profileImage)
                        : const AssetImage('assets/profile-icon-design-free-vector.jpg')
                            as ImageProvider,
                    radius: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const Icon(Icons.more_vert),
                ],
              ),
            ),
            GestureDetector(
              onDoubleTap: () {
                cubit.toggleLike(postId, context, showMessage);
              },
              child: Image.network(
                post['image_url'] ?? '',
                width: double.infinity,
                height: 400,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      state.userLikes[postId] ?? false
                          ? FontAwesomeIcons.solidHeart
                          : FontAwesomeIcons.heart,
                      color: state.userLikes[postId] ?? false
                          ? Colors.red
                          : Theme.of(context).iconTheme.color,
                      size: 28,
                    ),
                    onPressed: () => cubit.toggleLike(postId, context, showMessage),
                  ),
                  const SizedBox(width: 5),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostComments(
                            postId: post['id'],
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      FontAwesomeIcons.comment,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      size: 28,
                    ),
                    onPressed: () => cubit.toggleSavePost(postId, context, showMessage),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${post['likes'] ?? 0} ${S.of(context).likes}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  RichText(
                    text: TextSpan(
                      text: '$username ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white 
                            : Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: post['description'],
                          style: const TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  Widget _buildNotificationBanner(BuildContext context, FeedPostState state, FeedPostCubit cubit) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: TopNotificationBanner(
        username: state.currentNotification!['senderName'] ?? 'User',
        message: state.currentNotification!['message'] ?? '',
        profileImage: state.currentNotification!['senderProfileImage'],
        onTap: () => cubit.handleNotificationTap(context),
        onDismiss: cubit.dismissNotificationBanner,
        notificationId: state.currentNotification!['id'],
      ),
    );
  }

  void _showStoryOptions(BuildContext context, FeedPostCubit cubit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableStoryOptions(
          onImageSelected: () async {
            Navigator.pop(context);
            await cubit.pickAndUploadStory();
          },
          onTextSelected: () {
            Navigator.pop(context);
            _addTextToStory(context, cubit);
          },
          onBothSelected: () async {
            Navigator.pop(context);
            await cubit.pickAndUploadStory();
            _addTextToStory(context, cubit);
          },
        );
      },
    );
  }

  void _addTextToStory(BuildContext context, FeedPostCubit cubit) {
    showDialog(
      context: context,
      builder: (context) {
        String text = '';
        return AlertDialog(
          title: Text(S.of(context).Add_Text_To_Story),
          content: TextField(
            decoration: InputDecoration(hintText: S.of(context).Enter_Your_Text),
            onChanged: (value) {
              text = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(S.of(context).Cancel),
            ),
            TextButton(
              onPressed: () async {
                if (text.isNotEmpty) {
                  await cubit.saveTextStory(text);
                  Navigator.pop(context);
                }
              },
              child: Text(S.of(context).Save),
            ),
          ],
        );
      },
    );
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });

    if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileView()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SearchScreen()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VideosScreen1()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UploadScreen()),
      );
    }
  }
}

// Draggable Story Options Widget
class DraggableStoryOptions extends StatelessWidget {
  final VoidCallback onImageSelected;
  final VoidCallback onTextSelected;
  final VoidCallback onBothSelected;

  const DraggableStoryOptions({
    super.key,
    required this.onImageSelected,
    required this.onTextSelected,
    required this.onBothSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),

          // Option 1: Upload Image
          ListTile(
            leading: const Icon(Icons.image, color: Colors.blue),
            title: Text(
              S.of(context).Upload_Image,
              style: const TextStyle(color: Color.fromARGB(255, 126, 124, 124)),
            ),
            onTap: onImageSelected,
          ),

          // Option 2: Add Text
          ListTile(
            leading: const Icon(Icons.text_fields, color: Colors.green),
            title: Text(
              S.of(context).AddText,
              style: const TextStyle(color: Color.fromARGB(255, 126, 124, 124)),
            ),
            onTap: onTextSelected,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
