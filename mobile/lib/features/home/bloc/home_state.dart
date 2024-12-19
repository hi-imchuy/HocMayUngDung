part of 'home_bloc.dart';

@immutable
sealed class HomeState {}

abstract class HomeActionState extends HomeState {}

final class HomeInitial extends HomeState {}

class HomeChooseImageFromAlbumSuccess extends HomeActionState{
  final File image;

  HomeChooseImageFromAlbumSuccess(this.image);
}

class HomeChooseImageFromAlbumFailed extends HomeActionState{}

class HomeTakeAPhotoSuccess extends HomeActionState{
  final File image;

  HomeTakeAPhotoSuccess(this.image);
}

class HomeTakeAPhotoFailed extends HomeActionState{}

class HomeClickDetectSuccess extends HomeActionState{
  final String imageUrl;
  final Map<String, dynamic> detections;

  HomeClickDetectSuccess(this.imageUrl, this.detections);
}

class HomeClickDetectFailed extends HomeActionState{}

class HomeClickDetectLoading extends HomeActionState{}
