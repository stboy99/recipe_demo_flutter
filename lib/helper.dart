import 'package:firebase_auth/firebase_auth.dart';

class Helper{
  static bool isUserLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }
}