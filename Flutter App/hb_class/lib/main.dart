
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:untitled/otp.dart';
import 'package:untitled/phone.dart';
import 'package:untitled/us8k_home.dart';
import 'firebase_options.dart';
import 'login.dart';
import 'register.dart';
import 'package:get/get.dart';
import 'auth.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform).then((value) => Get.put(Auth()));
  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: 'login',
    routes:{
      'login':(context)=> const MyLogin(),
      'register':(context)=> const MyRegister(),
      'home': (context)=> const MyHome(),
      'phone': (context)=> const MyPhone(),
      'otp': (context)=> const MyOtp()
    },
  ));
}