// import 'package:supabase_flutter/supabase_flutter.dart';

// class LikeHandler {
//   final SupabaseClient _supabase;
//   final String userId;
  
//   LikeHandler(this._supabase, this.userId);

//   Future<bool> checkIfLiked(String postId) async {
//     try {
//       final response = await _supabase
//           .from('likes')
//           .select()
//           .eq('user_id', userId)
//           .eq('post_id', postId)
//           .maybeSingle();
      
//       return response != null;
//     } catch (e) {
//       print('Error checking if liked: $e');
//       return false;
//     }
//   }

//   Future<bool> toggleLike(String postId, Function(bool, int) onStateChanged) async {
//     try {
//       final isCurrentlyLiked = await checkIfLiked(postId);
      
//       if (isCurrentlyLiked) {
//         // Remove like
//         await _supabase
//             .from('likes')
//             .delete()
//             .eq('user_id', userId)
//             .eq('post_id', postId);
            
//         // Get current likes count
//         final response = await _supabase
//             .from('posts')
//             .select('likes')
//             .eq('id', postId)
//             .single();
            
//         final currentLikes = (response['likes'] ?? 1) - 1;
        
//         // Update likes count
//         await _supabase
//             .from('posts')
//             .update({'likes': currentLikes})
//             .eq('id', postId);
            
//         onStateChanged(false, currentLikes);
//         return false;
//       } else {
//         // Add like
//         await _supabase.from('likes').insert({
//           'user_id': userId,
//           'post_id': postId,
//           'created_at': DateTime.now().toIso8601String(),
//         });
        
//         // Get current likes count
//         final response = await _supabase
//             .from('posts')
//             .select('likes')
//             .eq('id', postId)
//             .single();
            
//         final currentLikes = (response['likes'] ?? 0) + 1;
        
//         // Update likes count
//         await _supabase
//             .from('posts')
//             .update({'likes': currentLikes})
//             .eq('id', postId);
            
//         onStateChanged(true, currentLikes);
//         return true;
//       }
//     } catch (e) {
//       print('Error toggling like: $e');
//       throw e;
//     }
//   }
// }