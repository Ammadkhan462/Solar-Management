import 'dart:math';
import 'package:admin/app/modules/ManagerDashboard/controllers/manager_dashboard_controller.dart';
import 'package:admin/app/modules/ManagerDashboard/views/manager_dashboard_view.dart';
import 'package:admin/app/modules/ManagerPanel/controllers/manager_panel_controller.dart';
import 'package:admin/app/modules/SignupPage/controllers/signup_page_controller.dart';
import 'package:admin/app/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashBoardController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? storedAdminUID;

  // ✅ List to Store Registered Managers
  var managersList = <ManagerModel>[].obs;

  var admin = AdminModel(uid: '', name: '', email: '').obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAdminData(); // Fetch admin data directly from Firebase when the controller is initialized
  }

  void loadStoredAdminUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    storedAdminUID = prefs.getString("admin_uid");

    if (storedAdminUID != null) {
      // Fetch admin data from Firebase based on stored admin UID
      try {
        DocumentSnapshot doc =
            await _firestore.collection("Admin").doc(storedAdminUID).get();

        if (doc.exists) {
          // Convert the document data to AdminModel
          admin.value = AdminModel.fromJson(doc.data() as Map<String, dynamic>);
        } else {
          print("No admin data found.");
        }
      } catch (e) {
        print("Error fetching admin data: $e");
      }
    } else {
      print("No stored admin UID found.");
    }
  }

  void fetchAdminData() async {
    try {
      // Assuming you are already logged in and have the admin's UID
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        String adminUID = currentUser.uid;

        // Fetch admin data from Firebase using the UID
        DocumentSnapshot doc =
            await _firestore.collection("Admin").doc(adminUID).get();

        if (doc.exists) {
          admin.value = AdminModel.fromJson(doc.data() as Map<String, dynamic>);
        } else {
          print("No admin data found.");
        }
      } else {
        print("No user is logged in.");
      }
    } catch (e) {
      print("Error fetching admin data: $e");
    }
  }

  void navigateToManagerDashboard() {
    Get.toNamed('/manager-dashboard'); // ✅ Navigate to the manager list screen
  }

  Future<void> registerManager(String name, String cnic) async {
    try {
      isLoading.value = true;

      String adminEmail = admin.value.email;
      if (adminEmail.isEmpty) {
        throw Exception("Admin email is missing!");
      }

      // Extract organization name (before @ symbol)
      String organization = adminEmail.split('@')[0];

      // Generate manager email
      String managerEmail =
          "${name.replaceAll(' ', '').toLowerCase()}@$organization.com";

      // Generate random password
      String managerPassword = _generateRandomPassword(8);

      // Create manager in Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: managerEmail,
        password: managerPassword,
      );

      String managerUID = userCredential.user!.uid;

      // ✅ Store manager details
      ManagerModel newManager = ManagerModel(
        uid: managerUID,
        name: name,
        email: managerEmail,
        password: managerPassword,
        cnic: cnic,
        adminUid: storedAdminUID!, // Changed 'createdBy' to 'adminUid'
      );

      await _firestore
          .collection("Managers")
          .doc(managerUID)
          .set(newManager.toJson());

      isLoading.value = false;

      // ✅ Redirect to Manager Credentials View
      Get.to(() => ManagerDashboardView());
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", e.toString());
    }
  }

  String _generateRandomPassword(int length) {
    const String chars =
        "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#\$%^&*";
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  // ✅ Fetch All Registered Managers
  void fetchManagers() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection("Managers").get();

      managersList.value = querySnapshot.docs
          .map((doc) =>
              ManagerModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error fetching managers: $e");
    }
  }

  // ✅ Remove Manager
  Future<void> removeManager(String uid) async {
    try {
      await _firestore.collection("Managers").doc(uid).delete();
      fetchManagers(); // Refresh list after deletion
      Get.snackbar("Success", "Manager Removed Successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to remove manager: $e");
    }
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("admin_uid"); // Remove stored admin UID
    await _auth.signOut();
    Get.offAllNamed(Routes.LOGIN_CHOICE);
  }
}
