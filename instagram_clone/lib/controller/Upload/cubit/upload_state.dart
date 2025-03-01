import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class UploadState extends Equatable {
  const UploadState();
  
  @override
  List<Object?> get props => [];
}

class UploadInitial extends UploadState {}

class UploadImageSelectedState extends UploadState {
  final File image;
  
  const UploadImageSelectedState(this.image);
  
  @override
  List<Object?> get props => [image];
}

class UploadLoadingState extends UploadState {
  final double progress;
  
  const UploadLoadingState(this.progress);
  
  @override
  List<Object?> get props => [progress];
}

class UploadSuccessState extends UploadState {}

class UploadFailureState extends UploadState {
  final String message;
  
  const UploadFailureState(this.message);
  
  @override
  List<Object?> get props => [message];
}

class ProfileImageLoadedState extends UploadState {
  final String? profileImageUrl;
  
  const ProfileImageLoadedState(this.profileImageUrl);
  
  @override
  List<Object?> get props => [profileImageUrl];
}