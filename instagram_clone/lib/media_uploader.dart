// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';

// class MediaUploader {
//   final SupabaseClient supabase = Supabase.instance.client;

//   Future<String?> uploadMedia(File file, String userId) async {
//     try {
//       // Upload the file to Supabase Storage
//       final String filePath = 'uploads/$userId/${DateTime.now().millisecondsSinceEpoch}';
//       await supabase.storage.from('media').upload(filePath, file);

//       // Get the public URL of the uploaded file
//       final String mediaUrl = supabase.storage.from('media').getPublicUrl(filePath);
//       return mediaUrl;
//     } catch (e) {
//       print('Error uploading media: $e');
//       return null;
//     }
//   }

//   Future<void> createPost(String mediaUrl, String caption) async {
//     try {
//       final String userId = supabase.auth.currentUser?.id ?? '';
//       if (userId.isEmpty) {
//         throw Exception('User not logged in');
//       }

//       // Insert a new post into the `posts` table
//       await supabase.from('posts').insert({
//         'user_id': userId,
//         'media_url': mediaUrl,
//         'caption': caption,
//       });
//     } catch (e) {
//       print('Error creating post: $e');
//     }
//   }

//   Future<File?> pickMedia() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? file = await picker.pickImage(source: ImageSource.gallery);
//     if (file != null) {
//       return File(file.path);
//     }
//     return null;
//   }
// }