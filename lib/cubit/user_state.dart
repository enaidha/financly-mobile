part of 'user_cubit.dart';

abstract class UserState extends Equatable {
  final String? uid;
  final String? name;
  final bool? isGoogle;
  const UserState(this.uid, this.name, this.isGoogle);

  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {
  const UserInitial() : super('0', 'user', false);
}

class UserLoaded extends UserState {
  final String? uid;
  final String? name;
  final bool? isGoogle;
  const UserLoaded(this.uid, this.name, this.isGoogle)
      : super(uid, name, isGoogle);
}
