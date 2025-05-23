import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeDetailsView extends StatelessWidget {
  final String employeeUID;

  const EmployeeDetailsView({required this.employeeUID, super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection("Employees")
          .doc(employeeUID)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Employee Details"),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Employee Details"),
            ),
            body: Center(child: Text("Error: ${snapshot.error}")),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Employee Details"),
            ),
            body: const Center(child: Text("Employee not found.")),
          );
        }

        var employeeData = snapshot.data!.data() as Map<String, dynamic>;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Employee Details"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text("Name: ${employeeData['name']}",
                    style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Text("CNIC: ${employeeData['cnic']}",
                    style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Text("Position: ${employeeData['position']}",
                    style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Text("Email: ${employeeData['email']}",
                    style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
        );
      },
    );
  }
}
