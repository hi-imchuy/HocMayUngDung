part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

class HomeInitialEvent extends HomeEvent{}

class HomeClickAlbumEvent extends HomeEvent{}

class HomeClickCameraEvent extends HomeEvent{}

class HomeClickDetectEvent extends HomeEvent{
  final File image;

  HomeClickDetectEvent(this.image);
}
