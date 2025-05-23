import 'package:get/get.dart';

import '../modules/DashBoard/bindings/dash_board_binding.dart';
import '../modules/DashBoard/views/dash_board_view.dart';
import '../modules/EmployeeDashboard/bindings/employee_dashboard_binding.dart';
import '../modules/EmployeeDashboard/views/employee_dashboard_view.dart';
import '../modules/EmployeeLoginPage/bindings/employee_login_page_binding.dart';
import '../modules/EmployeeLoginPage/views/employee_login_page_view.dart';
import '../modules/EmployeesRegistration/bindings/employees_registration_binding.dart';
import '../modules/EmployeesRegistration/views/employees_registration_view.dart';
import '../modules/ForgotPassword/bindings/forgot_password_binding.dart';
import '../modules/ForgotPassword/views/forgot_password_view.dart';
import '../modules/LoginPage/views/login_page_view.dart';
import '../modules/Login_choice/bindings/login_choice_binding.dart';
import '../modules/Login_choice/views/login_choice_view.dart';
import '../modules/ManagerDashboard/bindings/manager_dashboard_binding.dart';
import '../modules/ManagerDashboard/views/manager_dashboard_view.dart';
import '../modules/ManagerLogin/bindings/manager_login_binding.dart';
import '../modules/ManagerLogin/views/manager_login_view.dart';
import '../modules/ManagerPanel/bindings/manager_panel_binding.dart';
import '../modules/ManagerPanel/views/manager_panel_view.dart';
import '../modules/SignupPage/bindings/signup_page_binding.dart';
import '../modules/SignupPage/views/signup_page_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SIGNUP_PAGE;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: '/login-page',
      page: () => LoginPageView(), // Default is admin login
    ),
    GetPage(
      name: _Paths.SIGNUP_PAGE,
      page: () => SignupPageView(),
      binding: SignupPageBinding(),
    ),
    GetPage(
      name: _Paths.DASH_BOARD,
      page: () => DashBoardView(),
      binding: DashBoardBinding(),
    ),
    GetPage(
      name: _Paths.FORGOT_PASSWORD,
      page: () => ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: _Paths.MANAGER_DASHBOARD,
      page: () => ManagerDashboardView(),
      binding: ManagerDashboardBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN_CHOICE,
      page: () => const LoginChoiceView(),
      binding: LoginChoiceBinding(),
    ),
    GetPage(
      name: _Paths.MANAGER_LOGIN,
      page: () => ManagerLoginView(),
      binding: ManagerLoginBinding(),
    ),
    GetPage(
      name: _Paths.MANAGER_PANEL,
      page: () => const ManagerPanelView(),
      binding: ManagerPanelBinding(),
    ),
    GetPage(
      name: _Paths.EMPLOYEES_REGISTRATION,
      page: () => EmployeesRegistrationView(),
      binding: EmployeesRegistrationBinding(),
    ),
    GetPage(
      name: _Paths.EMPLOYEE_LOGIN_PAGE,
      page: () => EmployeeLoginPageView(),
      binding: EmployeeLoginPageBinding(),
    ),
    GetPage(
      name: _Paths.EMPLOYEE_DASHBOARD,
      page: () => EmployeeDashboardView(),
      binding: EmployeeDashboardBinding(),
    ),
  ];
}
