import 'package:gamdiwala/features/authentication/auth/screens/auth_screen.dart';
import 'package:gamdiwala/utils/dialogs/app_dialogs.dart';
import 'package:gamdiwala/utils/helpers/secure_storage_helper.dart';
import 'package:gamdiwala/utils/helpers/version_helper.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  var isLoading = false.obs;

  var fullName = ''.obs;
  var userType = ''.obs;
  var mobileNumber = ''.obs;
  var appVersion = ''.obs;

  @override
  void onInit() async {
    super.onInit();
    await loadUserInfo();
    await loadAppVersion();
  }

  Future<void> loadUserInfo() async {
    try {
      fullName.value = await SecureStorageHelper.read('fullName') ?? 'Unknown';
      userType.value = await SecureStorageHelper.read('userType') ?? 'guest';
      mobileNumber.value = await SecureStorageHelper.read('mobileNo') ?? '';
    } catch (e) {
      showErrorSnackbar(
        'Failed to Load User Info',
        'There was an issue loading your data. Please try again.',
      );
    }
  }

  Future<void> loadAppVersion() async {
    try {
      appVersion.value = await VersionHelper.getVersion();
    } catch (e) {
      appVersion.value = 'N/A';
    }
  }

  String getUserRole(String userType) {
    switch (userType) {
      case '0':
        return 'Admin';
      case '1':
        return 'Manager';
      case '2':
        return 'Salesman';
      case '3':
        return 'Engineer';
      default:
        return 'Unknown';
    }
  }

  Future<void> logoutUser() async {
    isLoading.value = true;
    try {
      await SecureStorageHelper.clearAll();

      Get.offAll(() => AuthScreen());
    } catch (e) {
      showErrorSnackbar(
        'Logout Failed',
        'Something went wrong. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
