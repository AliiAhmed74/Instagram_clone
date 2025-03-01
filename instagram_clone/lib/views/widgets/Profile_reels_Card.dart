import 'package:flutter/material.dart';

class ProfileReelsCards extends StatelessWidget {
  ProfileReelsCards({super.key});
  
  // List that can be empty or populated
  List<Map<String, dynamic>> mediaItems = [

  ];
  
  @override
  Widget build(BuildContext context) {
    if (mediaItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off_outlined,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              "No reels available",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    
    // Original grid view for when there are items
    return GridView.builder(
        itemCount: mediaItems.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2.0,
            mainAxisSpacing: 2.0,
            childAspectRatio: 0.6),
        itemBuilder: (context, index) {
          var item = mediaItems[index];
          return Stack(
            children: [
              Image.asset(
                "${item['imageUrl']}",
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                  bottom: 8,
                  left: 8,
                  child: Row(
                    children: [
                      Icon(Icons.play_circle_fill_outlined),
                      Text("295")
                    ],
                  ))
            ],
          );
        });
  }
}
