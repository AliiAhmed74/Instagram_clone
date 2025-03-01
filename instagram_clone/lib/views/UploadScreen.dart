import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram_clone/controller/Upload/cubit/upload_cubit.dart';
import 'package:instagram_clone/controller/Upload/cubit/upload_state.dart';
import 'package:instagram_clone/generated/l10n.dart';
import 'package:instagram_clone/views/FeedPost.dart';
import 'package:instagram_clone/views/MyProfile.dart';
import 'package:instagram_clone/views/ReelsScreen.dart';
import 'package:instagram_clone/views/SearchScreen.dart';
import 'package:instagram_clone/views/VediosScreen1.dart';


class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  int selectedIndex = 2;
  final _descriptionController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UploadCubit(),
      child: BlocConsumer<UploadCubit, UploadState>(
        listener: (context, state) {
          if (state is UploadFailureState) {
            _showErrorSnackBar(state.message);
          } else if (state is UploadSuccessState) {
            _showSuccessSnackBar();
            _descriptionController.clear();
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: _buildAppBar(context, state),
            bottomNavigationBar: _buildBottomNavigationBar(context, state),
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

AppBar _buildAppBar(BuildContext context, UploadState state) {
  return AppBar(
    elevation: 1,
    backgroundColor:  Theme.of(context).scaffoldBackgroundColor,
    foregroundColor: Colors.black,
    automaticallyImplyLeading: false, // This line removes the back arrow
    actions: [
      if (state is UploadImageSelectedState)
        TextButton(
          onPressed: state is UploadLoadingState
              ? null
              : () => context.read<UploadCubit>().uploadPost(_descriptionController.text),
          child: Text(
            S.of(context).Share,
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
    ],
  );
}

  Widget _buildBottomNavigationBar(BuildContext context, UploadState state) {
    String? profileImageUrl;
    if (state is ProfileImageLoadedState) {
      profileImageUrl = state.profileImageUrl;
    } else if (context.read<UploadCubit>().profileImageUrl != null) {
      profileImageUrl = context.read<UploadCubit>().profileImageUrl;
    }
    
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: selectedIndex == 0 ? Colors.black : Colors.grey),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search, color: selectedIndex == 1 ? Colors.black : Colors.grey),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_box, color: selectedIndex == 2 ? Colors.black : Colors.grey),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.video_collection_sharp, color: selectedIndex == 3 ? Colors.black : Colors.grey),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selectedIndex == 4 ? Colors.black : Colors.transparent,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 13,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                  ? NetworkImage(profileImageUrl)
                  : const AssetImage('assets/profile-icon-design-free-vector.jpg') as ImageProvider,
            ),
          ),
          label: '',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      onTap: onItemTapped,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
    );
  }

  Widget _buildBody(BuildContext context, UploadState state) {
    if (state is UploadLoadingState) {
      return _buildUploadingUI(state.progress);
    } else if (state is UploadImageSelectedState) {
      return _buildCreatePostUI(context, state.image);
    } else {
      return _buildSelectImageUI(context);
    }
  }

  Widget _buildUploadingUI(double progress) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          SizedBox(height: 24),
          Text(
            S.of(context).Sharing_your_post,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '${(progress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectImageUI(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            size: 100,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            S.of(context).Create_a_new_post,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            S.of(context).Share_photos_with_your_followers,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.read<UploadCubit>().pickImageFromGallery(), // Fixed direct call
            child: Text(
              S.of(context).Select_from_Gallery,
              style: TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => context.read<UploadCubit>().takePhoto(),
            icon: Icon(Icons.camera_alt),
            label: Text(S.of(context).Take_a_Photo),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              side: BorderSide(color: Colors.blue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatePostUI(BuildContext context, File image) {
    final profileImageUrl = context.read<UploadCubit>().profileImageUrl;
    
    return Column(
      children: [
        Divider(height: 1),
        
        // Post image and details
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image preview
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User info and caption input
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                                ? NetworkImage(profileImageUrl)
                                : const AssetImage('assets/profile-icon-design-free-vector.jpg') as ImageProvider,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _descriptionController,
                              maxLines: 5,
                              minLines: 1,
                              decoration: InputDecoration(
                                hintText: S.of(context).Write_a_caption,
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showImageSourceOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.purple),
                title: Text(S.of(context).Photo_Library),
                onTap: () {
                  Navigator.pop(context);
                  context.read<UploadCubit>().pickImageFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera, color: Colors.blue),
                title: Text(S.of(context).Camera),
                onTap: () {
                  Navigator.pop(context);
                  context.read<UploadCubit>().takePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });

    if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileView()),
      );
    }
    else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SearchScreen()),
      );
    }
    else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VideosScreen1()),
      );
    }
    else if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FeedPost()),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text(S.of(context).Post_shared_successfully),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}