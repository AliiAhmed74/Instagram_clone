import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/generated/l10n.dart';
import 'package:instagram_clone/views/MyProfile.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController descriptionController =
      TextEditingController(); // New controller for description

  // Gender dropdown
  String? selectedGender; // Holds the selected gender value
  final List<String> genderOptions = [
    'Male',
    'Female'
  ]; // Allowed gender options

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

// In fetchUserData method, add this modification:
  Future<void> fetchUserData() async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          fullNameController.text = data['fullName'];
          usernameController.text = data['username'];
          phoneNumberController.text = data['phoneNumber'].toString();

          // Normalize the gender value to match one in the dropdown list
          String dbGender = data['gender'] ?? '';
          if (dbGender.toLowerCase() == 'male') {
            selectedGender = 'Male';
          } else if (dbGender.toLowerCase() == 'female') {
            selectedGender = 'Female';
          } else {
            selectedGender = null; // If it doesn't match any option
          }

          descriptionController.text = data['description'] ?? '';
        });
      }
    }
  }

  Future<void> updateProfile() async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _firestore.collection('users').doc(userId).update({
        'fullName': fullNameController.text.trim(),
        'username': usernameController.text.trim(),
        'phoneNumber': int.parse(phoneNumberController.text.trim()),
        'gender': selectedGender, // Save the selected gender
        'description':
            descriptionController.text.trim(), // Save the description
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileView()),
      ); // Go back to the profile screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).Edit_Profile,
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Full Name Field
            TextFormField(
              controller: fullNameController,
              decoration: InputDecoration(
                labelText: S.of(context).FullName,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Username Field
            TextFormField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: S.of(context).Username,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Phone Number Field
            TextFormField(
              controller: phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: S.of(context).Phone_Number,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Description Field
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: S.of(context).Description,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3, // Allow multiple lines for description
            ),
            const SizedBox(height: 20),
            // Gender Dropdown
            DropdownButtonFormField<String>(
              value: genderOptions.contains(selectedGender)
                  ? selectedGender
                  : null,
              decoration: InputDecoration(
                labelText: S.of(context).Gender,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: genderOptions.map((String gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedGender = newValue; // Update the selected gender
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return S.of(context).Please_select_a_gender;
                }
                return null;
              },
            ),
            const SizedBox(height: 50),
            // Save Button
            ElevatedButton(
              onPressed: updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                S.of(context).Save_Changes,
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
