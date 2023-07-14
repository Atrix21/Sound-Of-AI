import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'home.dart';
import 'login.dart';
import 'package:flutter/material.dart';

class Auth extends GetxController{
  static final Auth instance=Get.find();
  late Rx<User?> _user;
  FirebaseAuth auth=FirebaseAuth.instance;

  @override
  void onReady(){
    super.onReady();
    _user=Rx<User?>(auth.currentUser);
    _user.bindStream(auth.userChanges());
    ever(_user, _initialScreen);
  }

  _initialScreen(User? user){
    if(user==null){
      if (kDebugMode) {
        print("login page");
      }
      Get.offAll(()=>const MyLogin());
    }
    else{
      Get.offAll(()=>HomePage());
    }
  }

  void register_user(String email, password)async{
    try{
      await auth.createUserWithEmailAndPassword(email: email, password: password);
    }
    catch(e){
      Get.snackbar('About User', 'User message',
          backgroundColor: const Color(0xff003c5f),
          snackPosition: SnackPosition.BOTTOM,
          titleText: const Text(
            'Account creation failed',
            style: TextStyle(
                color:Colors.white
            ),
          ),
          messageText: Text(
            e.toString(),
            style: const TextStyle(
                color: Colors.white
            ),
          )
      );
    }
  }
  void login_user(String email, password)async{
    try{
      await auth.signInWithEmailAndPassword(email: email, password: password);
    }
    catch(e){
      Get.snackbar('About Login', 'Login message',
          backgroundColor: const Color(0xff003c5f),
          snackPosition: SnackPosition.BOTTOM,
          titleText: const Text(
            'Login failed',
            style: TextStyle(
                color:Colors.white
            ),
          ),
          messageText: Text(
            e.toString(),
            style: const TextStyle(
                color: Colors.white
            ),
          )
      );
    }
  }
  void logOut()async{
    await auth.signOut();
  }
}