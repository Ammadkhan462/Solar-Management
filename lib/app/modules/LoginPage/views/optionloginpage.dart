import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin/app/routes/app_pages.dart';

class LoginChoiceView extends StatelessWidget {
  const LoginChoiceView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Login Type")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Get.toNamed(Routes.LOGIN_PAGE,
                    parameters: {'isAdmin': 'true'}); // Admin login
              },
              child: const Text("Login as Admin"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.toNamed(Routes.LOGIN_PAGE,
                    parameters: {'isAdmin': 'false'}); // Manager login
              },
              child: const Text("Login as Manager"),
            ),
          ],
        ),
      ),
    );
  }
}
