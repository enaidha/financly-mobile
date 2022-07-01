import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_plan/main.dart';
import 'package:finance_plan/models/user.dart';
import 'package:finance_plan/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future signIn(String email, String password, dynamic context) async {
  try {
    var user = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    SharedPreferences pref = preferences;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.user!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        // print('Document data: ${documentSnapshot.data()}');
        pref.setString('user_id', user.user!.uid);
        pref.setString('name', documentSnapshot.get(FieldPath(['name'])));
        pref.setString('email', documentSnapshot.get(FieldPath(['email'])));
        pref.setString(
            'photo_url', documentSnapshot.get(FieldPath(['photoURL'])));
        pref.setString(
            'username', documentSnapshot.get(FieldPath(['username'])));
        pref.setBool('is_google', false);
      } else {
        print('Document does not exist on the database');
      }
    });

    return true;
  } catch (e) {
    print(e);
    return false;
  }
}

Future register({
  required CollectionReference userCol,
  required UserModel user,
  required String password,
}) async {
  try {
    var authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: user.email!,
      password: password,
    );

    // TODO: Create firestore user here and keep it locally.
    userCol.doc(authResult.user!.uid).set(user.toJson());

    return authResult.user != null;
  } on FirebaseAuthException catch (e) {
    return e.code;
  }
}

Future<User?> updateAccount(String name) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    user?.updateDisplayName(name);
    if (user != null) {
      preferences.setString('name', name);
      print("Pesan : Berhasil Update Akun");
      return user;
    } else {
      print("Pesan : Gagal Update Akun [Tidak Boleh Kosong]");
      return user;
    }
  } catch (e) {
    print("Error : ${e}");
    return null;
  }
}

Future<User?> updateProfilePhoto(String photoUrl) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    user?.updatePhotoURL(photoUrl);
    if (user != null) {
      preferences.setString('photo_url', photoUrl);
      print("Pesan : Berhasil mengupload");
      return user;
    } else {
      print("Pesan : Gagal mengupload [Tidak Boleh Kosong]");
      return user;
    }
  } catch (e) {
    print("Error : ${e}");
    return null;
  }
}

Future logout(BuildContext context) async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  try {
    SharedPreferences pref = preferences;
    await pref.clear();

    await _auth.signOut().then((value) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
          (Route<dynamic> route) => false);
    });
  } catch (e) {
    print("Error : ${e}");
    return null;
  }
}
