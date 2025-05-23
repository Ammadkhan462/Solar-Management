import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EmployeesRegistrationView extends StatelessWidget {
  const EmployeesRegistrationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Registration'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("Employees")
              .orderBy("createdAt", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final employees = snapshot.data!.docs;

            return ListView.builder(
              itemCount: employees.length,
              itemBuilder: (context, index) {
                var employee = employees[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(employee["name"]),
                    subtitle: Text(employee["email"]),
                    trailing: Text(employee["designation"]),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
