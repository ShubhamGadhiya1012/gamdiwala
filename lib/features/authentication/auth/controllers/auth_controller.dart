import 'package:flutter/material.dart';
import 'package:gamdiwala/features/authentication/auth/repos/auth_repo.dart';
import 'package:gamdiwala/utils/dialogs/app_dialogs.dart';
import 'package:gamdiwala/utils/helpers/secure_storage_helper.dart';
import 'package:gamdiwala/utils/helpers/device_helper.dart';
import 'package:get/get.dart';

class AuthController extends GetxController
    with GetSingleTickerProviderStateMixin {
  var isLoading = false.obs;
  var isLoginMode = true.obs; // true for login, false for register

  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();

  // Login Controllers
  var loginMobileController = TextEditingController();
  var loginPasswordController = TextEditingController();

  // Register Controllers
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var registerMobileController = TextEditingController();
  var registerPasswordController = TextEditingController();
  var confirmPasswordController = TextEditingController();

  var hasAttemptedLogin = false.obs;
  var hasAttemptedRegister = false.obs;

  // Password visibility
  var obscuredLoginPassword = true.obs;
  var obscuredRegisterPassword = true.obs;
  var obscuredConfirmPassword = true.obs;

  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );
    setupValidationListeners();
  }

  @override
  void onClose() {
    animationController.dispose();
    loginMobileController.dispose();
    loginPasswordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    registerMobileController.dispose();
    registerPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void setupValidationListeners() {
    // Login validation listeners
    loginMobileController.addListener(() {
      if (hasAttemptedLogin.value) {
        loginFormKey.currentState?.validate();
      }
    });
    loginPasswordController.addListener(() {
      if (hasAttemptedLogin.value) {
        loginFormKey.currentState?.validate();
      }
    });

    // Register validation listeners
    firstNameController.addListener(() {
      if (hasAttemptedRegister.value) {
        registerFormKey.currentState?.validate();
      }
    });
    lastNameController.addListener(() {
      if (hasAttemptedRegister.value) {
        registerFormKey.currentState?.validate();
      }
    });
    registerMobileController.addListener(() {
      if (hasAttemptedRegister.value) {
        registerFormKey.currentState?.validate();
      }
    });
    registerPasswordController.addListener(() {
      if (hasAttemptedRegister.value) {
        registerFormKey.currentState?.validate();
      }
    });
    confirmPasswordController.addListener(() {
      if (hasAttemptedRegister.value) {
        registerFormKey.currentState?.validate();
      }
    });
  }

  void toggleMode() {
    isLoginMode.value = !isLoginMode.value;
    if (isLoginMode.value) {
      animationController.reverse();
    } else {
      animationController.forward();
    }
    // Reset validation states
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

    if (deviceId == null) {
      showErrorSnackbar('Login Failed', 'Unable to fetch device ID.');
      isLoading.value = false;
      return;
    }

    try {
      await LoginRepo.loginUser(
        mobileNo: loginMobileController.text,
        password: loginPasswordController.text,
        fcmToken: '',
        deviceId: deviceId,
      );

      int cid = 1;
      int yearId = 2024;
      var tokenResponse = await LoginRepo.getToken(
        mobileNumber: loginMobileController.text,
        cid: cid,
        yearId: yearId,
      );

      await SecureStorageHelper.write('token', tokenResponse['token']);
      await SecureStorageHelper.write('fullName', tokenResponse['fullName']);
      await SecureStorageHelper.write(
        'userType',
        tokenResponse['userType'].toString(),
      );
      await SecureStorageHelper.write(
        'mobileNo',
        tokenResponse['mobileNo'].toString(),
      );
      await SecureStorageHelper.write(
        'userId',
        tokenResponse['userId'].toString(),
      );
      await SecureStorageHelper.write(
        'ledgerStart',
        tokenResponse['ledgerStart'] ?? '',
      );
      await SecureStorageHelper.write(
        'ledgerEnd',
        tokenResponse['ledgerEnd'] ?? '',
      );
      await SecureStorageHelper.write('company', 'Demo Company');
      await SecureStorageHelper.write('coCode', cid.toString());

      // Navigate to your main screen
      // Get.offAll(() => YourMainScreen());
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
      var response = await LoginRepo.registerUser(
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        mobileNo: registerMobileController.text,
        password: registerPasswordController.text,
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        showSuccessSnackbar('Success', message);

        // Switch to login mode after successful registration
        toggleMode();

        // Clear registration form
        firstNameController.clear();
        lastNameController.clear();
        registerMobileController.clear();
        registerPasswordController.clear();
        confirmPasswordController.clear();

        // Pre-fill login mobile number
        loginMobileController.text = registerMobileController.text;
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
}
