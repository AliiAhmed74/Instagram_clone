import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:instagram_clone/controller/theme/cubit/theme_cubit.dart';
import 'package:instagram_clone/controller/theme/cubit/theme_state.dart';
import 'package:instagram_clone/views/EditProfile.dart';
import 'package:instagram_clone/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileGetData extends StatefulWidget {
  const ProfileGetData({super.key});

  @override
  _ProfileGetDataState createState() => _ProfileGetDataState();
}

class _ProfileGetDataState extends State<ProfileGetData> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Locale _currentLocale = const Locale('en');  // Default to English

  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguageCode = prefs.getString('language_code') ?? 'en';
    setState(() {
      _currentLocale = Locale(savedLanguageCode);
    });
  }

  Future<void> _saveLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
  }

  Future<void> fetchUserData() async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        setState(() {
          userData = doc.data();
        });
      }
    }
  }

void _changeLanguage(String languageCode) async {
  // First save the new locale
  await _saveLocale(languageCode);
  
  // Then update the current locale state
  setState(() {
    _currentLocale = Locale(languageCode);
  });
  
  // Finally restart the app
  Phoenix.rebirth(context);
}

  @override
  Widget build(BuildContext context) {
        return Directionality(
      // Set text direction based on current locale
      textDirection: _currentLocale.languageCode == 'ar' 
          ? TextDirection.rtl 
          : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).Profile, style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.language,
                color: Colors.white,
              ),
              onSelected: _changeLanguage,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'en',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('🇺🇸 '),
                          const SizedBox(width: 8),
                          const Text('English'),
                        ],
                      ),
                      if (_currentLocale.languageCode == 'en')
                        const Icon(Icons.check, size: 20)
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'ar',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('🇸🇦 '),
                          const SizedBox(width: 8),
                          const Text('العربية'),
                        ],
                      ),
                      if (_currentLocale.languageCode == 'ar')
                        const Icon(Icons.check, size: 20)
                    ],
                  ),
                ),
              ],
            ),
            BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, state) {
                return IconButton(
                  icon: Icon(
                    state.themeMode == ThemeMode.dark
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    context.read<ThemeCubit>().toggleTheme();
                  },
                );
              },
            ),
          ],
        ),
        body: FutureBuilder<DocumentSnapshot>(
            future: _firestore
                .collection('users')
                .doc(_auth.currentUser?.uid)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(
                    child:
                        Text('No data found', style: TextStyle(fontSize: 16)));
              }
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[300],
                            image: userData['profileImage'] != null &&
                                    userData['profileImage'].isNotEmpty
                                ? DecorationImage(
                                    image:
                                        NetworkImage(userData['profileImage']),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: userData['profileImage'] == null ||
                                  userData['profileImage'].isEmpty
                              ? const Icon(Icons.person,
                                  size: 45, color: Colors.white)
                              : null,
                        ),

                        const SizedBox(height: 20),
                        // Full Name
                        Text(
                          userData['fullName'],
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        // Username
                        Text(
                          '@${userData['username']}',
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 30),
                        // Profile Details Card
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                // Email
                                _buildProfileDetailRow(
                                    Icons.email, S.of(context).Email, userData['email']),
                                const Divider(height: 20, thickness: 1),
                                // Phone Number
                                _buildProfileDetailRow(
                                    Icons.phone,
                                    S.of(context).Phone_Number,
                                    userData['phoneNumber'].toString()),
                                const Divider(height: 20, thickness: 1),
                                // Gender
                                _buildProfileDetailRow(
                                    Icons.person, S.of(context).Gender, userData['gender']),
                                const Divider(height: 20, thickness: 1),
                                // Description
                                _buildProfileDetailRow(
                                    Icons.description,
                                    S.of(context).Description,
                                    userData['description'] ??
                                        'No description'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),
                        // Edit Profile Button
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const EditProfile()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child:  Text(
                              S.of(context).Edit_Profile,
                              style:
                                  TextStyle(fontSize: 16,color: Colors.grey,fontWeight:FontWeight.bold ),
                            ),
                          ),
                        ),
                      ]),
                ),
              );
            })));
  }
}

Widget _buildProfileDetailRow(IconData icon, String label, String value) {
  return Row(
    children: [
      Icon(icon, size: 24, color: Colors.blue),
      const SizedBox(width: 16),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ],
  );
}
