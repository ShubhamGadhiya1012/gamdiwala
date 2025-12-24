import 'package:flutter/material.dart';
import 'package:gamdiwala/features/authentication/auth/models/company_dm.dart';
import 'package:gamdiwala/features/authentication/auth/screens/select_company_screen.dart';
import 'package:get/get.dart';
import 'package:gamdiwala/features/authentication/auth/repos/auth_repo.dart';
import 'package:gamdiwala/utils/dialogs/app_dialogs.dart';
import 'package:gamdiwala/utils/helpers/device_helper.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var isLoginMode = true.obs;

  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();

  var loginMobileController = TextEditingController();
  var loginPasswordController = TextEditingController();

  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var registerMobileController = TextEditingController();
  var registerPasswordController = TextEditingController();
  var confirmPasswordController = TextEditingController();

  var hasAttemptedLogin = false.obs;
  var hasAttemptedRegister = false.obs;

  var obscuredLoginPassword = true.obs;
  var obscuredRegisterPassword = true.obs;
  var obscuredConfirmPassword = true.obs;
  var companies = <CompanyDm>[].obs;

  @override
  void onInit() {
    super.onInit();
    setupValidationListeners();
  }

  void setupValidationListeners() {
    loginMobileController.addListener(validateLoginForm);
    loginPasswordController.addListener(validateLoginForm);

    firstNameController.addListener(validateRegisterForm);
    lastNameController.addListener(validateRegisterForm);
    registerMobileController.addListener(validateRegisterForm);
    registerPasswordController.addListener(validateRegisterForm);
    confirmPasswordController.addListener(validateRegisterForm);
  }

  void validateLoginForm() {
    if (hasAttemptedLogin.value) {
      loginFormKey.currentState?.validate();
    }
  }

  void validateRegisterForm() {
    if (hasAttemptedRegister.value) {
      registerFormKey.currentState?.validate();
    }
  }

  void toggleMode() {
    isLoginMode.value = !isLoginMode.value;
    hasAttemptedLogin.value = false;
    hasAttemptedRegister.value = false;
  }

  void toggleLoginPasswordVisibility() {
    obscuredLoginPassword.value = !obscuredLoginPassword.value;
  }

  void toggleRegisterPasswordVisibility() {
    obscuredRegisterPassword.value = !obscuredRegisterPassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscuredConfirmPassword.value = !obscuredConfirmPassword.value;
  }

  Future<void> loginUser() async {
    isLoading.value = true;
    String? deviceId = await DeviceHelper().getDeviceId();
    print(deviceId);
    if (deviceId == null) {
      showErrorSnackbar('Login Failed', 'Unable to fetch device ID.');
      isLoading.value = false;
      return;
    }

    try {
      final fetchedCompanies = await AuthRepo.loginUser(
        mobileNo: loginMobileController.text,
        password: loginPasswordController.text,
        fcmToken: '',
        deviceId: deviceId,
      );

      companies.assignAll(fetchedCompanies);
      Get.to(
        () => SelectCompanyScreen(
          companies: companies,
          mobileNumber: loginMobileController.text,
        ),
      );
    } catch (e) {
      if (e is Map<String, dynamic>) {
        showErrorSnackbar('Login Error', e['message']);
      } else {
        showErrorSnackbar('Login Error', e.toString());
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> registerUser() async {
    isLoading.value = true;

    try {
      var response = await AuthRepo.registerUser(
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        mobileNo: registerMobileController.text,
        password: registerPasswordController.text,
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        showSuccessSnackbar('Success', message);

        toggleMode();

        firstNameController.clear();
        lastNameController.clear();
        registerMobileController.clear();
        registerPasswordController.clear();
        confirmPasswordController.clear();
      }
    } catch (e) {
      if (e is Map<String, dynamic>) {
        showErrorSnackbar('Error', e['message']);
      } else {
        showErrorSnackbar('Error', e.toString());
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    loginMobileController.dispose();
    loginPasswordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    registerMobileController.dispose();
    registerPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
