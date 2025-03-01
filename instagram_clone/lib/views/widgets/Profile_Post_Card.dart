import 'package:flutter/material.dart';
import 'package:instagram_clone/views/widgets/Post_Detail_View.dart';

class ProfilePostCards extends StatelessWidget {
  final List<Map<String, dynamic>> posts;

  ProfilePostCards({required this.posts, super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: posts.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2.0,
        mainAxisSpacing: 2.0,
      ),
      itemBuilder: (context, index) {
        final post = posts[index];
        return GestureDetector(
          onTap: () {
            // Navigate to a detailed view of the post
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailView(post: post),
              ),
            );
          },
          child: Image.network(
            post['image_url'],
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}