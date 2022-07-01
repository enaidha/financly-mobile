import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(const UserInitial());

  void userLoaded(String uid, String name, bool isGoogle) {
    emit(UserLoaded(uid, name, isGoogle));
  }
}
