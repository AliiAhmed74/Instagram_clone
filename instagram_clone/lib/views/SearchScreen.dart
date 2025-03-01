import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram_clone/controller/Search/cubit/search_cubit.dart';
import 'package:instagram_clone/generated/l10n.dart';
import 'package:instagram_clone/views/FeedPost.dart';
import 'package:instagram_clone/views/MyProfile.dart';
import 'package:instagram_clone/views/ProfileViewSearch.dart'; // Make sure this import points to the new file
import 'package:instagram_clone/views/ReelsScreen.dart';
import 'package:instagram_clone/views/UploadScreen.dart';
import 'package:instagram_clone/views/VediosScreen1.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 1;
  String? _profileImageUrl;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchProfileImage();
  }

  Future<void> _fetchProfileImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          _profileImageUrl = doc.data()?['profileImage'];
        });
      }
    } catch (e) {
      print('Error fetching profile image: $e');
    }
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });

    if (index == 0) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const FeedPost()));
    } else if (index == 4) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const ProfileView()));
    } else if (index == 3) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => VideosScreen1()));
    } else if (index == 2) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => UploadScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchCubit(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home,
                  color: selectedIndex == 0 ? Colors.black : Colors.grey),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search,
                  color: selectedIndex == 1 ? Colors.black : Colors.grey),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_rounded,
                  color: selectedIndex == 2 ? Colors.black : Colors.grey),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_collection_sharp,
                  color: selectedIndex == 3 ? Colors.black : Colors.grey),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: CircleAvatar(
                backgroundImage: _profileImageUrl != null
                    ? NetworkImage(_profileImageUrl!)
                    : const AssetImage(
                            'assets/profile-icon-design-free-vector.jpg')
                        as ImageProvider,
                radius: 15,
              ),
              label: '',
            ),
          ],
          currentIndex: selectedIndex,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          onTap: onItemTapped,
        ),
        body: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            if(state is SearchLoading){
              return Center(child: CircularProgressIndicator());
            } else if(state is SearchError){
              return Center(child: Text(state.message));
              } else if(state is SearchLoaded){
            return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          height: 50,
                          width: 300,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Icon(Icons.search, color: Colors.grey),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: TextField(
                                    onChanged: (query) {
                                      context.read<SearchCubit>().filterItems(query);
                                    },
                                    decoration:  InputDecoration(
                                      hintText: S.of(context).Search,
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                         Text(S.of(context).Cancel,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    tabs:  [
                      Tab(text: S.of(context).Recent),
                      Tab(text: S.of(context).Accounts),
                      Tab(text: S.of(context).Tags),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Recent Tab
                        ListView.separated(
                          padding: const EdgeInsets.only(top: 15),
                          itemCount: state.recentSearches.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final user = state.recentSearches[index];
                            return ListTile(
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundImage:
                                    NetworkImage(user['profileImage'] ?? ''),
                              ),
                              title: Row(
                                children: [
                                  Text(user['username'],
                                      style:
                                          const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              subtitle: Text(user['fullName'] ?? ''),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfileViewSearch(
                                        userData: user),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        // Accounts Tab
                        ListView.separated(
                          padding: const EdgeInsets.only(top: 15),
                          itemCount: state.filteredUsers.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final user = state.filteredUsers[index];
                            return ListTile(
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundImage:
                                    NetworkImage(user['profileImage'] ?? ''),
                              ),
                              title: Row(
                                children: [
                                  Text(user['username'],
                                      style:
                                          const TextStyle(fontWeight: FontWeight.bold)),
                                  if (user['verified'] == true)
                                    const Padding(
                                      padding: EdgeInsets.only(left: 4),
                                      child: Icon(Icons.verified,
                                          color: Colors.blue, size: 16),
                                    ),
                                ],
                              ),
                              subtitle: Text(user['fullName'] ?? ''),
                              onTap: () {
                                context.read<SearchCubit>().addToRecentSearches(user);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfileViewSearch(
                                        userData: user),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        // Tags Tab
                        ListView.separated(
                          padding: const EdgeInsets.only(top: 15),
                          itemCount: state.filteredTags.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundImage:
                                    AssetImage(state.filteredTags[index]['image']!),
                              ),
                              title: Text(state.filteredTags[index]['name']!,
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(state.filteredTags[index]['subtitle']!),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return const Center(child: Text('Something went wrong!'));
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}