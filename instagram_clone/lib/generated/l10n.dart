// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Profile`
  String get Profile {
    return Intl.message('Profile', name: 'Profile', desc: '', args: []);
  }

  /// `Email`
  String get Email {
    return Intl.message('Email', name: 'Email', desc: '', args: []);
  }

  /// `Full Name`
  String get FullName {
    return Intl.message('Full Name', name: 'FullName', desc: '', args: []);
  }

  /// `Username`
  String get Username {
    return Intl.message('Username', name: 'Username', desc: '', args: []);
  }

  /// `Password`
  String get Password {
    return Intl.message('Password', name: 'Password', desc: '', args: []);
  }

  /// `Phone Number`
  String get Phone_Number {
    return Intl.message(
      'Phone Number',
      name: 'Phone_Number',
      desc: '',
      args: [],
    );
  }

  /// `Gender`
  String get Gender {
    return Intl.message('Gender', name: 'Gender', desc: '', args: []);
  }

  /// `Description`
  String get Description {
    return Intl.message('Description', name: 'Description', desc: '', args: []);
  }

  /// `Edit Profile`
  String get Edit_Profile {
    return Intl.message(
      'Edit Profile',
      name: 'Edit_Profile',
      desc: '',
      args: [],
    );
  }

  /// `Posts`
  String get Posts {
    return Intl.message('Posts', name: 'Posts', desc: '', args: []);
  }

  /// `Followers`
  String get Followers {
    return Intl.message('Followers', name: 'Followers', desc: '', args: []);
  }

  /// `Following`
  String get Following {
    return Intl.message('Following', name: 'Following', desc: '', args: []);
  }

  /// `Follow`
  String get Follow {
    return Intl.message('Follow', name: 'Follow', desc: '', args: []);
  }

  /// `Your Story`
  String get Your_Story {
    return Intl.message('Your Story', name: 'Your_Story', desc: '', args: []);
  }

  /// `Likes`
  String get likes {
    return Intl.message('Likes', name: 'likes', desc: '', args: []);
  }

  /// `Comments`
  String get Comments {
    return Intl.message('Comments', name: 'Comments', desc: '', args: []);
  }

  /// `No comments yet`
  String get No_Comments_yet {
    return Intl.message(
      'No comments yet',
      name: 'No_Comments_yet',
      desc: '',
      args: [],
    );
  }

  /// `Add a comment...`
  String get Add_a_Commment {
    return Intl.message(
      'Add a comment...',
      name: 'Add_a_Commment',
      desc: '',
      args: [],
    );
  }

  /// `Post`
  String get Post {
    return Intl.message('Post', name: 'Post', desc: '', args: []);
  }

  /// `Cancel`
  String get Cancel {
    return Intl.message('Cancel', name: 'Cancel', desc: '', args: []);
  }

  /// `Search...`
  String get Search {
    return Intl.message('Search...', name: 'Search', desc: '', args: []);
  }

  /// `Recent`
  String get Recent {
    return Intl.message('Recent', name: 'Recent', desc: '', args: []);
  }

  /// `Accounts`
  String get Accounts {
    return Intl.message('Accounts', name: 'Accounts', desc: '', args: []);
  }

  /// `Tags`
  String get Tags {
    return Intl.message('Tags', name: 'Tags', desc: '', args: []);
  }

  /// `Upload Post`
  String get Upload_Post {
    return Intl.message('Upload Post', name: 'Upload_Post', desc: '', args: []);
  }

  /// `No image selected`
  String get No_Image_Selected {
    return Intl.message(
      'No image selected',
      name: 'No_Image_Selected',
      desc: '',
      args: [],
    );
  }

  /// `Pick Image`
  String get Pick_Image {
    return Intl.message('Pick Image', name: 'Pick_Image', desc: '', args: []);
  }

  /// `Messages`
  String get Messages {
    return Intl.message('Messages', name: 'Messages', desc: '', args: []);
  }

  /// `Tap to start chatting`
  String get Tap_to_Start_Chatting {
    return Intl.message(
      'Tap to start chatting',
      name: 'Tap_to_Start_Chatting',
      desc: '',
      args: [],
    );
  }

  /// `Online`
  String get Online {
    return Intl.message('Online', name: 'Online', desc: '', args: []);
  }

  /// `Offline`
  String get Offline {
    return Intl.message('Offline', name: 'Offline', desc: '', args: []);
  }

  /// `Message...`
  String get Message {
    return Intl.message('Message...', name: 'Message', desc: '', args: []);
  }

  /// `Gallery`
  String get Gallery {
    return Intl.message('Gallery', name: 'Gallery', desc: '', args: []);
  }

  /// `Camera`
  String get Camera {
    return Intl.message('Camera', name: 'Camera', desc: '', args: []);
  }

  /// `Document`
  String get Document {
    return Intl.message('Document', name: 'Document', desc: '', args: []);
  }

  /// `No posts available`
  String get No_posts_available {
    return Intl.message(
      'No posts available',
      name: 'No_posts_available',
      desc: '',
      args: [],
    );
  }

  /// `No reels available`
  String get No_reels_available {
    return Intl.message(
      'No reels available',
      name: 'No_reels_available',
      desc: '',
      args: [],
    );
  }

  /// `No saved posts available`
  String get No_saved_posts_available {
    return Intl.message(
      'No saved posts available',
      name: 'No_saved_posts_available',
      desc: '',
      args: [],
    );
  }

  /// `User not found`
  String get User_not_found {
    return Intl.message(
      'User not found',
      name: 'User_not_found',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get Loading {
    return Intl.message('Loading...', name: 'Loading', desc: '', args: []);
  }

  /// `Please select a gender`
  String get Please_select_a_gender {
    return Intl.message(
      'Please select a gender',
      name: 'Please_select_a_gender',
      desc: '',
      args: [],
    );
  }

  /// `Save Changes`
  String get Save_Changes {
    return Intl.message(
      'Save Changes',
      name: 'Save_Changes',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the 'Profile_updated_successfully!' key

  /// `Add Text`
  String get AddText {
    return Intl.message('Add Text', name: 'AddText', desc: '', args: []);
  }

  /// `Upload Image`
  String get Upload_Image {
    return Intl.message(
      'Upload Image',
      name: 'Upload_Image',
      desc: '',
      args: [],
    );
  }

  /// `Delete_Story`
  String get Delete_Story {
    return Intl.message(
      'Delete_Story',
      name: 'Delete_Story',
      desc: '',
      args: [],
    );
  }

  /// `No stories yet`
  String get No_Stories_yet {
    return Intl.message(
      'No stories yet',
      name: 'No_Stories_yet',
      desc: '',
      args: [],
    );
  }

  /// `My Stories`
  String get My_Stories {
    return Intl.message('My Stories', name: 'My_Stories', desc: '', args: []);
  }

  /// `Add text to story`
  String get Add_Text_To_Story {
    return Intl.message(
      'Add text to story',
      name: 'Add_Text_To_Story',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get Save {
    return Intl.message('Save', name: 'Save', desc: '', args: []);
  }

  /// `Enter your text`
  String get Enter_Your_Text {
    return Intl.message(
      'Enter your text',
      name: 'Enter_Your_Text',
      desc: '',
      args: [],
    );
  }

  /// `Post removed from saved`
  String get Post_removed_from_saved {
    return Intl.message(
      'Post removed from saved',
      name: 'Post_removed_from_saved',
      desc: '',
      args: [],
    );
  }

  /// `Post saved successfully!`
  String get Post_saved_successfully {
    return Intl.message(
      'Post saved successfully!',
      name: 'Post_saved_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Unfollowed user`
  String get Unfollowed_user {
    return Intl.message(
      'Unfollowed user',
      name: 'Unfollowed_user',
      desc: '',
      args: [],
    );
  }

  /// `Started following user`
  String get Started_following_user {
    return Intl.message(
      'Started following user',
      name: 'Started_following_user',
      desc: '',
      args: [],
    );
  }

  /// `liked your post`
  String get liked_your_post {
    return Intl.message(
      'liked your post',
      name: 'liked_your_post',
      desc: '',
      args: [],
    );
  }

  /// `commented: `
  String get commented {
    return Intl.message('commented: ', name: 'commented', desc: '', args: []);
  }

  /// `started following you`
  String get started_following_you {
    return Intl.message(
      'started following you',
      name: 'started_following_you',
      desc: '',
      args: [],
    );
  }

  /// `Follow back`
  String get Follow_back {
    return Intl.message('Follow back', name: 'Follow_back', desc: '', args: []);
  }

  /// `Notification`
  String get Notifcation {
    return Intl.message(
      'Notification',
      name: 'Notifcation',
      desc: '',
      args: [],
    );
  }

  /// `No notifications yet`
  String get No_notifications_yet {
    return Intl.message(
      'No notifications yet',
      name: 'No_notifications_yet',
      desc: '',
      args: [],
    );
  }

  /// `Email is required`
  String get Email_is_required {
    return Intl.message(
      'Email is required',
      name: 'Email_is_required',
      desc: '',
      args: [],
    );
  }

  /// `Password is required`
  String get Password_is_required {
    return Intl.message(
      'Password is required',
      name: 'Password_is_required',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid email`
  String get Enter_a_valid_email {
    return Intl.message(
      'Enter a valid email',
      name: 'Enter_a_valid_email',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 6 characters long`
  String get Password_must_be_at_least_6_characters_long {
    return Intl.message(
      'Password must be at least 6 characters long',
      name: 'Password_must_be_at_least_6_characters_long',
      desc: '',
      args: [],
    );
  }

  /// `Success`
  String get Success {
    return Intl.message('Success', name: 'Success', desc: '', args: []);
  }

  // skipped getter for the 'Password_reset_email_has_been_sent.' key

  /// `OK`
  String get OK {
    return Intl.message('OK', name: 'OK', desc: '', args: []);
  }

  /// `Error`
  String get Error {
    return Intl.message('Error', name: 'Error', desc: '', args: []);
  }

  /// `Failed to send password reset email: `
  String get Failed_to_send_password_reset_email {
    return Intl.message(
      'Failed to send password reset email: ',
      name: 'Failed_to_send_password_reset_email',
      desc: '',
      args: [],
    );
  }

  /// `Forget Password ?`
  String get Forget_Password {
    return Intl.message(
      'Forget Password ?',
      name: 'Forget_Password',
      desc: '',
      args: [],
    );
  }

  /// `No user found for that email.`
  String get No_user_found_for_that_email {
    return Intl.message(
      'No user found for that email.',
      name: 'No_user_found_for_that_email',
      desc: '',
      args: [],
    );
  }

  /// `Wrong password provided.`
  String get Wrong_password_provided {
    return Intl.message(
      'Wrong password provided.',
      name: 'Wrong_password_provided',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred`
  String get An_error_occurred {
    return Intl.message(
      'An error occurred',
      name: 'An_error_occurred',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get Login {
    return Intl.message('Login', name: 'Login', desc: '', args: []);
  }

  /// `Do not have an email? `
  String get Do_not_have_an_email {
    return Intl.message(
      'Do not have an email? ',
      name: 'Do_not_have_an_email',
      desc: '',
      args: [],
    );
  }

  /// `Sign up.`
  String get Sign_up {
    return Intl.message('Sign up.', name: 'Sign_up', desc: '', args: []);
  }

  /// `Login successful`
  String get Login_successful {
    return Intl.message(
      'Login successful',
      name: 'Login_successful',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your email`
  String get Please_enter_your_email {
    return Intl.message(
      'Please enter your email',
      name: 'Please_enter_your_email',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid email`
  String get Please_enter_a_valid_email {
    return Intl.message(
      'Please enter a valid email',
      name: 'Please_enter_a_valid_email',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your full name`
  String get Please_enter_your_fullname {
    return Intl.message(
      'Please enter your full name',
      name: 'Please_enter_your_fullname',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your username`
  String get Please_enter_your_username {
    return Intl.message(
      'Please enter your username',
      name: 'Please_enter_your_username',
      desc: '',
      args: [],
    );
  }

  /// `Username must be at least 3 characters long`
  String get Username_must_be_at_least_3_characters_long {
    return Intl.message(
      'Username must be at least 3 characters long',
      name: 'Username_must_be_at_least_3_characters_long',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your password`
  String get Please_enter_your_password {
    return Intl.message(
      'Please enter your password',
      name: 'Please_enter_your_password',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your phone number`
  String get Please_enter_your_phone_number {
    return Intl.message(
      'Please enter your phone number',
      name: 'Please_enter_your_phone_number',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid phone number`
  String get Please_enter_a_valid_phone_number {
    return Intl.message(
      'Please enter a valid phone number',
      name: 'Please_enter_a_valid_phone_number',
      desc: '',
      args: [],
    );
  }

  /// `Gender: (Male/Female)`
  String get Gender_Male_Female {
    return Intl.message(
      'Gender: (Male/Female)',
      name: 'Gender_Male_Female',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your gender`
  String get Please_enter_your_gender {
    return Intl.message(
      'Please enter your gender',
      name: 'Please_enter_your_gender',
      desc: '',
      args: [],
    );
  }

  /// `Gender must be Male or Female`
  String get Gender_must_be_Male_or_Female {
    return Intl.message(
      'Gender must be Male or Female',
      name: 'Gender_must_be_Male_or_Female',
      desc: '',
      args: [],
    );
  }

  /// `The password provided is too weak.`
  String get The_password_provided_is_too_weak {
    return Intl.message(
      'The password provided is too weak.',
      name: 'The_password_provided_is_too_weak',
      desc: '',
      args: [],
    );
  }

  /// `The account already exists for that email.`
  String get The_account_already_exists_for_that_email {
    return Intl.message(
      'The account already exists for that email.',
      name: 'The_account_already_exists_for_that_email',
      desc: '',
      args: [],
    );
  }

  /// `By signing up, you agree to our terms, Data`
  String get By_signing_up_you_agree_to_our_terms_Data {
    return Intl.message(
      'By signing up, you agree to our terms, Data',
      name: 'By_signing_up_you_agree_to_our_terms_Data',
      desc: '',
      args: [],
    );
  }

  /// `Policy, and Cookies Policy.`
  String get Policy_and_Cookies_Policy {
    return Intl.message(
      'Policy, and Cookies Policy.',
      name: 'Policy_and_Cookies_Policy',
      desc: '',
      args: [],
    );
  }

  /// `Have an account? `
  String get Have_an_account {
    return Intl.message(
      'Have an account? ',
      name: 'Have_an_account',
      desc: '',
      args: [],
    );
  }

  /// `Share`
  String get Share {
    return Intl.message('Share', name: 'Share', desc: '', args: []);
  }

  /// `Report`
  String get Report {
    return Intl.message('Report', name: 'Report', desc: '', args: []);
  }

  /// `like`
  String get like {
    return Intl.message('like', name: 'like', desc: '', args: []);
  }

  /// `comment`
  String get comment {
    return Intl.message('comment', name: 'comment', desc: '', args: []);
  }

  /// `comments`
  String get comments {
    return Intl.message('comments', name: 'comments', desc: '', args: []);
  }

  /// `View all comments`
  String get View_all_comments {
    return Intl.message(
      'View all comments',
      name: 'View_all_comments',
      desc: '',
      args: [],
    );
  }

  /// `Related content`
  String get Related_content {
    return Intl.message(
      'Related content',
      name: 'Related_content',
      desc: '',
      args: [],
    );
  }

  /// `Suggested`
  String get Suggested {
    return Intl.message('Suggested', name: 'Suggested', desc: '', args: []);
  }

  /// `Delete post`
  String get Delete_post {
    return Intl.message('Delete post', name: 'Delete_post', desc: '', args: []);
  }

  /// `Failed to delete post`
  String get Failed_to_delete_post {
    return Intl.message(
      'Failed to delete post',
      name: 'Failed_to_delete_post',
      desc: '',
      args: [],
    );
  }

  /// `Post deleted successfully`
  String get Post_deleted_successfully {
    return Intl.message(
      'Post deleted successfully',
      name: 'Post_deleted_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this post`
  String get Are_you_sure_you_want_to_delete_this_post {
    return Intl.message(
      'Are you sure you want to delete this post',
      name: 'Are_you_sure_you_want_to_delete_this_post',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get Delete {
    return Intl.message('Delete', name: 'Delete', desc: '', args: []);
  }

  /// `Photo Library`
  String get Photo_Library {
    return Intl.message(
      'Photo Library',
      name: 'Photo_Library',
      desc: '',
      args: [],
    );
  }

  /// `Please select an image first`
  String get Please_select_an_image_first {
    return Intl.message(
      'Please select an image first',
      name: 'Please_select_an_image_first',
      desc: '',
      args: [],
    );
  }

  /// `Please add a caption`
  String get Please_add_a_caption {
    return Intl.message(
      'Please add a caption',
      name: 'Please_add_a_caption',
      desc: '',
      args: [],
    );
  }

  /// `User not logged in`
  String get User_not_logged_in {
    return Intl.message(
      'User not logged in',
      name: 'User_not_logged_in',
      desc: '',
      args: [],
    );
  }

  /// `Post shared successfully!`
  String get Post_shared_successfully {
    return Intl.message(
      'Post shared successfully!',
      name: 'Post_shared_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Error uploading post`
  String get Error_uploading_post {
    return Intl.message(
      'Error uploading post',
      name: 'Error_uploading_post',
      desc: '',
      args: [],
    );
  }

  /// `Sharing your post...`
  String get Sharing_your_post {
    return Intl.message(
      'Sharing your post...',
      name: 'Sharing_your_post',
      desc: '',
      args: [],
    );
  }

  /// `Create a new post`
  String get Create_a_new_post {
    return Intl.message(
      'Create a new post',
      name: 'Create_a_new_post',
      desc: '',
      args: [],
    );
  }

  /// `Share photos with your followers`
  String get Share_photos_with_your_followers {
    return Intl.message(
      'Share photos with your followers',
      name: 'Share_photos_with_your_followers',
      desc: '',
      args: [],
    );
  }

  /// `Select from Gallery`
  String get Select_from_Gallery {
    return Intl.message(
      'Select from Gallery',
      name: 'Select_from_Gallery',
      desc: '',
      args: [],
    );
  }

  /// `Take a Photo`
  String get Take_a_Photo {
    return Intl.message(
      'Take a Photo',
      name: 'Take_a_Photo',
      desc: '',
      args: [],
    );
  }

  /// `Write a caption...`
  String get Write_a_caption {
    return Intl.message(
      'Write a caption...',
      name: 'Write_a_caption',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get Notifications {
    return Intl.message(
      'Notifications',
      name: 'Notifications',
      desc: '',
      args: [],
    );
  }

  /// `Mark all as read`
  String get markallasread {
    return Intl.message(
      'Mark all as read',
      name: 'markallasread',
      desc: '',
      args: [],
    );
  }

  /// `No notifications`
  String get No_notifications {
    return Intl.message(
      'No notifications',
      name: 'No_notifications',
      desc: '',
      args: [],
    );
  }

  /// `You have unread messages`
  String get You_have_unread_messages {
    return Intl.message(
      'You have unread messages',
      name: 'You_have_unread_messages',
      desc: '',
      args: [],
    );
  }

  /// `View`
  String get View {
    return Intl.message('View', name: 'View', desc: '', args: []);
  }

  /// `Add Image Story`
  String get Add_Image_Story {
    return Intl.message(
      'Add Image Story',
      name: 'Add_Image_Story',
      desc: '',
      args: [],
    );
  }

  /// `Add Text Story`
  String get Add_Text_Story {
    return Intl.message(
      'Add Text Story',
      name: 'Add_Text_Story',
      desc: '',
      args: [],
    );
  }

  /// `Check your email to change password`
  String get Check_your_email_to_change_password {
    return Intl.message(
      'Check your email to change password',
      name: 'Check_your_email_to_change_password',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
