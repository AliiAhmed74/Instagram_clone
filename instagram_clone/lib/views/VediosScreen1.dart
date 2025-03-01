// import 'package:card_swiper/card_swiper.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:instagram_clone/views/FeedPost.dart';
// import 'package:instagram_clone/views/MyProfile.dart';
// import 'package:instagram_clone/views/ReelsScreen.dart';
// import 'package:instagram_clone/views/SearchScreen.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class Vediosscreen1 extends StatefulWidget {

//   @override
//   State<Vediosscreen1> createState() => _Vediosscreen1State();
// }

// class _Vediosscreen1State extends State<Vediosscreen1> {
//   final _supabase = Supabase.instance.client;
//   final _firebaseAuth = FirebaseAuth.instance;
//   final _firestore = FirebaseFirestore.instance;
//   String? _profileImageUrl;
//   int selectedIndex = 3;
//   static const List<Widget> widgetOptions = <Widget>[
//     Text('Home Page'),
//     Text('Search Page'),
//     Text('Post Page'),
//     Text('Likes Page'),
//     Text('Profile Page'),
//   ];
//   @override
//   void initState() {
//     super.initState();
//     _fetchProfileImage();
//   }
//   /// Fetch user's profile image from Firestore
//   Future<void> _fetchProfileImage() async {
//     final user = _firebaseAuth.currentUser;
//     if (user == null) return;

//     try {
//       final doc = await _firestore.collection('users').doc(user.uid).get();
//       if (doc.exists) {
//         setState(() {
//           _profileImageUrl = doc.data()?['profileImage']; // Ensure this key matches Firestore
//         });
//       }
//     } catch (e) {
//       print('Error fetching profile image: $e');
//     }
//   }
//   void onItemTapped(int index) {
//     setState(() {
//       selectedIndex = index;
//     });

//     // Navigate to ProfileScreen when the profile item is selected
//     if (index == 4) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => ProfileView()),
//       );
//     }
//     else if (index == 1) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => const SearchScreen()),
//       );
//     }
//     else if (index == 0) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => const FeedPost()),
//       );
//     }
//   }

//   final List<String> videos = [
//     'https://video-previews.elements.envatousercontent.com/h264-video-previews/8af44033-2913-4c5b-8b35-9a2fe926c745/2004044.mp4',
//     'https://assets.mixkit.co/active_storage/video_items/100101/1720116057/100101-video-720.mp4',
//     'https://assets.mixkit.co/videos/preview/mixkit-mother-with-her-little-daughter-eating-a-marshmallow-in-nature-39764-large.mp4',
//     'https://assets.mixkit.co/videos/preview/mixkit-girl-in-neon-sign-1232-large.mp4',
//     'https://media.gettyimages.com/id/2183047514/video/uefa-champions-league-liverpool-training-session-november-4.mp4?s=mp4-640x640-gi&k=20&c=XsqtJmo3Ms5_zYuTGuQoWFf7EXqNJYcx8b4Ss_9Kj2s=',
//     'https://cdn.pixabay.com/video/2024/02/28/202368-918049003_large.mp4',
//     'https://assets.mixkit.co/videos/344/344-720.mp4'
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: BottomNavigationBar(
//         items: <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home, color: selectedIndex == 0 ? Colors.black : Colors.grey),
//             label: '',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.search, color: selectedIndex == 1 ? Colors.black : Colors.grey),
//             label: '',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.add_circle_rounded, color: selectedIndex == 2 ? Colors.black : Colors.grey),
//             label: '',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.video_collection_sharp, color: selectedIndex == 3 ? Colors.black : Colors.grey),
//             label: '',
//           ),
//           BottomNavigationBarItem(
//               icon: CircleAvatar(
//                 radius: 15,
//                 backgroundColor: selectedIndex == 4 ? Colors.black : Colors.grey,
//                 backgroundImage: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
//                     ? NetworkImage(_profileImageUrl!) // Use uploaded image
//                     : const AssetImage('assets/default_avatar.png') as ImageProvider, // Fallback avatar
//               ),
//               label: '',
//             ),
//         ],
//         currentIndex: selectedIndex,
//         selectedItemColor: Colors.black,
//         unselectedItemColor: Colors.grey,
//         onTap: onItemTapped,
//       ),
//       body: SafeArea(
//         child: Container(
//           child: Stack(
//             children: [
//               //We need swiper for every content
//   ]))));
  
//   }}