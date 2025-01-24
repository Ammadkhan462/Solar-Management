import 'package:admin/Common%20widgets/commonbutton.dart';
import 'package:admin/app/modules/home/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../controllers/signup_page_controller.dart';

class SignupPageView extends GetView<SignupPageController> {
  const SignupPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController email = TextEditingController();
    TextEditingController password = TextEditingController();
    TextEditingController name = TextEditingController();
    TextEditingController role =
        TextEditingController(); // For admin to assign role
    Authcontroller authcontroller = Get.put(Authcontroller());

    return Column(
      children: [
        Container(
          height: 100,
        ),
        TextField(
          controller: name,
          decoration: InputDecoration(
            hintText: "Name",
            prefixIcon: Icon(Icons.person),
          ),
        ),
        SizedBox(height: 10),
        TextField(
          controller: email,
          decoration: InputDecoration(
            hintText: "Email",
            prefixIcon: Icon(Icons.email),
          ),
        ),
        SizedBox(height: 10),
        TextField(
          controller: password,
          decoration: InputDecoration(
            hintText: "Password",
            prefixIcon: Icon(Icons.lock),
          ),
        ),
        SizedBox(height: 10),
        SizedBox(height: 30),
        Obx(() => authcontroller.isLoading.value
            ? CircularProgressIndicator()
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PrimaryButton(
                    ontap: () {
                      String trimmedEmail = email.text.trim();
                      if (trimmedEmail.isEmpty ||
                          password.text.isEmpty ||
                          name.text.isEmpty) {
                        print("Please fill in all fields.");
                        return;
                      }
                      authcontroller.createUser(
                        trimmedEmail,
                        password.text,
                        name.text.trim(),
                      );
                    },
                    btnName: "SIGN UP",
                    icon: Icons.lock_open_outlined,
                  ),
                ],
              ))
      ],
    ).paddingAll(10);
  }
}

class Authcontroller extends GetxController {
  final auth = FirebaseAuth.instance;
  RxBool isLoading = false.obs;
  final db = FirebaseFirestore.instance;

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      Get.offAll(HomeView());
    } catch (e) {
      print('Login failed: $e');
      Get.snackbar('Error', 'Login failed. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createUser(String email, String password, String name) async {
    isLoading.value = true;
    try {
      // Create user with Firebase Authentication
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Initialize user with their name and role
      await userInit(userCredential.user!.uid, email, name);
      print("Account created successfully");

      // Navigate to homepage after successful sign up
      Get.offAll(HomeView());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print('Email already in use');
        Get.snackbar('Error', 'This email address is already in use.');
      } else if (e.code == 'weak-password') {
        print('Password is too weak');
        Get.snackbar('Error', 'The password is too weak.');
      } else {
        print('Unhandled error: ${e.code}');
        Get.snackbar('Error', 'An unexpected error occurred: ${e.message}');
      }
    } catch (e) {
      print('An error occurred: $e');
      Get.snackbar('Error', 'An unexpected error occurred. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> userInit(
    String uid,
    String email,
    String name,
  ) async {
    // Add user details to Firestore
    await db.collection('users').doc(uid).set({
      'email': email,
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> logout() async {
    await auth.signOut();
    Get.offAllNamed('/authpage');
  }
}
