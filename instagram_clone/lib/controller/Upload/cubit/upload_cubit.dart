import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/controller/Upload/cubit/upload_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadCubit extends Cubit<UploadState> {
  final _supabase = Supabase.instance.client;
  final _firebaseAuth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _picker = ImagePicker();
  
  File? _selectedImage;
  String? _profileImageUrl;
  
  UploadCubit() : super(UploadInitial()) {
    fetchProfileImage();
  }
  
  // Get the currently selected image
  File? get selectedImage => _selectedImage;
  
  // Get the profile image URL
  String? get profileImageUrl => _profileImageUrl;
  
  // Fetch user's profile image
  Future<void> fetchProfileImage() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _profileImageUrl = doc.data()?['profileImage'];
        emit(ProfileImageLoadedState(_profileImageUrl));
      }
    } catch (e) {
      print('Error fetching profile image: $e');
    }
  }
  
  // Pick image from gallery
  Future<void> pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _selectedImage = File(pickedFile.path);
      emit(UploadImageSelectedState(_selectedImage!));
    }
  }
  
  // Take a photo with camera
  Future<void> takePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _selectedImage = File(pickedFile.path);
      emit(UploadImageSelectedState(_selectedImage!));
    }
  }
  
  // Clear selected image
  void clearImage() {
    _selectedImage = null;
    emit(UploadInitial());
  }
  
  // Upload post with image and description
  Future<void> uploadPost(String description) async {
    if (_selectedImage == null) {
      emit(UploadFailureState('Please select an image first'));
      return;
    }

    if (description.isEmpty) {
      emit(UploadFailureState('Please add a caption'));
      return;
    }

    final user = _firebaseAuth.currentUser;
    if (user == null) {
      emit(UploadFailureState('User not logged in'));
      return;
    }

    emit(UploadLoadingState(0));

    try {
      // Simulate progress updates
      for (int i = 1; i <= 5; i++) {
        await Future.delayed(Duration(milliseconds: 400));
        emit(UploadLoadingState(i / 5));
      }

      // Upload image to Supabase Storage
      final filePath = 'uploads/${user.uid}/${DateTime.now().toIso8601String()}.jpg';
      await _supabase.storage.from('images').upload(filePath, _selectedImage!);

      // Get the public URL of the uploaded image
      final imageUrl = _supabase.storage.from('images').getPublicUrl(filePath);

      // Create post data with simplified fields
      final postData = {
        'user_id': user.uid,
        'image_url': imageUrl,
        'description': description,
        'created_at': DateTime.now().toIso8601String(),
      };

      // Save to Supabase
      await _supabase.from('posts').insert(postData);

      // Also save to Firestore for increased compatibility
      await _firestore.collection('posts').add(postData);

      // Success
      emit(UploadSuccessState());
      
      // Reset after successful upload
      _selectedImage = null;
      
    } catch (e) {
      emit(UploadFailureState('Error uploading post: ${e.toString()}'));
    }
  }
}