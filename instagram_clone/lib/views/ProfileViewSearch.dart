import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram_clone/controller/ProfileViewSearch/cubit/profile_view_search_cubit.dart';
import 'package:instagram_clone/controller/ProfileViewSearch/cubit/profile_view_search_state.dart';
import 'package:instagram_clone/generated/l10n.dart';
import 'package:instagram_clone/views/widgets/Post_Detail_View.dart';

class ProfileViewSearch extends StatelessWidget {
  final Map<String, dynamic> userData;
  
  const ProfileViewSearch({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create and provide the cubit
    return BlocProvider(
      create: (context) => ProfileViewSearchCubit(userData),
      child: const _ProfileViewSearchContent(),
    );
  }
}

class _ProfileViewSearchContent extends StatelessWidget {
  const _ProfileViewSearchContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Listen to the cubit state changes
    return BlocConsumer<ProfileViewSearchCubit, ProfileViewSearchState>(
      listener: (context, state) {
        // Display any errors as snackbars
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              state.userData['fullName'] ?? '', 
              style: const TextStyle(fontWeight: FontWeight.bold)
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(state.userData['profileImage'] ?? ''),
                        ),
                        const SizedBox(width: 30),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatColumn(S.of(context).Posts, state.userPosts.length.toString()),
                              _buildStatColumn(S.of(context).Followers, state.followerCount.toString()),
                              _buildStatColumn(S.of(context).Following, state.followingCount.toString()),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      state.userData['username'] ?? '',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (state.userData['description'] != null)
                      Text(
                        state.userData['description'],
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    const SizedBox(height: 10),
                    // Only show follow button if not viewing own profile
                    if (context.read<ProfileViewSearchCubit>().currentUserId != state.userData['uid'])
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => context.read<ProfileViewSearchCubit>().toggleFollow(),
                            child: Container(
                              width: 150,
                              height: 50,
                              decoration: BoxDecoration(
                                color: state.isFollowing 
                                    ? Colors.grey[300] 
                                    : const Color.fromARGB(255, 13, 174, 255),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Center(
                                child: Text(
                                  state.isFollowing ? S.of(context).Following : S.of(context).Follow,
                                  style: TextStyle(
                                    color: state.isFollowing ? Colors.black : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              DefaultTabController(
                length: 3,
                initialIndex: state.selectedTabIndex,
                child: Column(
                  children: [
                    TabBar(
                      onTap: (index) {
                        context.read<ProfileViewSearchCubit>().changeTab(index);
                      },
                      unselectedLabelColor: Colors.grey,
                      tabs: const [
                        Tab(icon: Icon(Icons.add_a_photo),),
                        Tab(icon: Icon(Icons.play_circle_outline),),
                        Tab(icon: Icon(Icons.bookmark_outline),),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),

              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildTabContent(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabContent(BuildContext context, ProfileViewSearchState state) {
    if (state.selectedTabIndex == 0) {
      // Posts tab
      return state.userPosts.isEmpty
          ? Center(child: Text(S.of(context).No_posts_available))
          : GridView.builder(
              padding: const EdgeInsets.all(2),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: state.userPosts.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailView(post: state.userPosts[index]),
                      ),
                    );
                  },
                  child: Image.network(
                    state.userPosts[index]['image_url'],
                    fit: BoxFit.cover,
                  ),
                );
              },
            );
    } else if (state.selectedTabIndex == 1) {
      // Reels tab
      return state.userReels.isEmpty
          ? Center(child: Text(S.of(context).No_reels_available))
          : ListView.builder(
              itemCount: state.userReels.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.video_library),
                  title: Text(state.userReels[index]['title'] ?? 'Reel'),
                  subtitle: Text(state.userReels[index]['description'] ?? ''),
                );
              },
            );
    } else {
      // Saved posts tab
      return state.savedPosts.isEmpty
          ? Center(child: Text(S.of(context).No_saved_posts_available))
          : GridView.builder(
              padding: const EdgeInsets.all(2),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: state.savedPosts.length,
              itemBuilder: (context, index) {
                final post = state.savedPosts[index]['posts'];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailView(post: post),
                      ),
                    );
                  },
                  child: Image.network(
                    post['image_url'],
                    fit: BoxFit.cover,
                  ),
                );
              },
            );
    }
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}