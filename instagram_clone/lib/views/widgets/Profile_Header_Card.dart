import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/generated/l10n.dart';
import 'package:instagram_clone/views/ProfileGetData.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileHeaderCard extends StatefulWidget {
  const ProfileHeaderCard({super.key});

  @override
  State<ProfileHeaderCard> createState() => _ProfileHeaderCardState();
}

class _ProfileHeaderCardState extends State<ProfileHeaderCard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient supabase = Supabase.instance.client;
  RealtimeChannel? _followsChannel;

  String fullName = 'Loading...';
  String username = 'Loading...';
  String profileImageUrl = '';
  String description = '';
  int postsCount = 0;
  int followersCount = 0;
  int followingCount = 0;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchPostsCount();
    fetchFollowCounts();
  }

  @override
  void dispose() {
    _followsChannel?.unsubscribe();
    super.dispose();
  }


  // Fetch both followers and following counts
  Future<void> fetchFollowCounts() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      // Fetch followers count
      final followersResponse = await supabase
          .from('follows')
          .select()
          .eq('following_id', userId);
      
      // Fetch following count
      final followingResponse = await supabase
          .from('follows')
          .select()
          .eq('follower_id', userId);

      setState(() {
        followersCount = followersResponse.length;
        followingCount = followingResponse.length;
      });
    } catch (error) {
      print('Error fetching follow counts: $error');
    }
  }

  Future<void> fetchUserData() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();

    if (userDoc.exists) {
      setState(() {
        fullName = userDoc['fullName'];
        username = userDoc['username'];
        description = userDoc['description'] ?? '';
        profileImageUrl = userDoc['profileImage'] ?? '';
      });
    }
  }

  Future<void> fetchPostsCount() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final response = await supabase
          .from('posts')
          .select('id')
          .eq('user_id', userId);

      setState(() {
        postsCount = response.length;
      });
    } catch (error) {
      print('Error fetching posts count: $error');
    }
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final file = File(image.path);
      final String fileName = 'profile_images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String imageUrl = await _uploadImageToSupabase(file, fileName);

      await _firestore.collection('users').doc(userId).update({
        'profileImage': imageUrl,
      });

      setState(() {
        profileImageUrl = imageUrl;
      });
    }
  }

  Future<String> _uploadImageToSupabase(File file, String fileName) async {
    try {
      final response = await supabase.storage
          .from('profile_images')
          .upload(fileName, file);
      
      final String publicUrl = supabase.storage
          .from('profile_images')
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (error) {
      print('Error uploading image: $error');
      throw error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
        child: Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(40),
                    bottomLeft: Radius.circular(40))),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(fullName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: profileImageUrl.isNotEmpty
                            ? NetworkImage(profileImageUrl)
                            : null,
                        child: profileImageUrl.isEmpty
                            ? Icon(Icons.person, size: 40)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickAndUploadImage,
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.add, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 20),
                  ProfileCountTitle(title: S.of(context).Posts, count: '$postsCount'),
                  CustomDivider(),
                  ProfileCountTitle(title: S.of(context).Followers, count: '$followersCount'),
                  CustomDivider(),
                  ProfileCountTitle(title: S.of(context).Following, count: '$followingCount'),
                ],
              ),
              SizedBox(height: 5),
              Text(username,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              Text(description, style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfileGetData()));
                        },
                        child: Container(
                          child: Center(
                            child: Text(S.of(context).Edit_Profile,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          width: 100,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness==Brightness.dark?Colors.grey:Colors.grey,
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ])));
  }
}

class ProfileCountTitle extends StatelessWidget {
  const ProfileCountTitle({super.key, required this.count, required this.title});
  final String count;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
        Text(title, style: TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }
}

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey.shade600, width: 2.0),
        ),
      ),
    );
  }
}