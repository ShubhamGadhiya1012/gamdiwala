// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/features/authentication/auth/screens/auth_screen.dart';
import 'package:gamdiwala/features/challan_entry/screens/challan_entry_screens.dart';
import 'package:gamdiwala/features/home/models/home_menu_item_dm.dart';
import 'package:gamdiwala/features/home/models/item_dm.dart';
import 'package:gamdiwala/features/home/repos/home_repo.dart';
import 'package:gamdiwala/features/home/screens/home_screen.dart';
import 'package:gamdiwala/features/invoice_entry/screens/sales_invoice_screen.dart';
import 'package:gamdiwala/features/reports/screens/challan_report_screen.dart';
import 'package:gamdiwala/features/reports/screens/order_report_screen.dart';
import 'package:gamdiwala/features/user_settings/models/user_access_dm.dart';
import 'package:gamdiwala/features/user_settings/repos/user_access_repo.dart';
import 'package:gamdiwala/features/user_settings/screens/unauth_users_screen.dart';
import 'package:gamdiwala/features/user_settings/screens/users_screen.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/dialogs/app_dialogs.dart';
import 'package:gamdiwala/utils/helpers/device_helper.dart';
import 'package:gamdiwala/utils/helpers/secure_storage_helper.dart';
import 'package:gamdiwala/utils/helpers/version_helper.dart';
import 'package:gamdiwala/widgets/app_text_button.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeController extends GetxController {
  var isLoading = false.obs;
  var company = ''.obs;
  var menuAccess = <MenuAccessDm>[].obs;
  var menuItems = <HomeMenuItemDm>[].obs;
  var selectedMenuIndex = 0.obs;
  var expandedMenuIndex = RxInt(-1);
  var appVersion = ''.obs;
  var itemList = <ItemDm>[].obs;

  var fullName = ''.obs;
  var userType = ''.obs;
  var partyName = ''.obs;

  @override
  void onInit() async {
    super.onInit();

    await loadUserInfo();
    await _loadVersion();
    await loadCompany();
    await checkAppVersion();
    await getUserAccess();
    await getItems();
  }

  Future<void> loadUserInfo() async {
    try {
      fullName.value = await SecureStorageHelper.read('fullName') ?? 'Unknown';
      userType.value = await SecureStorageHelper.read('userType') ?? 'guest';
      String? pName = await SecureStorageHelper.read('selectPName');
      partyName.value = pName ?? 'No Party Selected';
    } catch (e) {
      showErrorSnackbar(
        'Failed to Load User Info',
        'There was an issue loading your data. Please try again.',
      );
    }
  }

  Future<void> getItems() async {
    isLoading.value = true;
    String? selectPCode = await SecureStorageHelper.read('selectPCode');

    try {
      final fetchedList = await HomeRepo.getItems(
        pCode: selectPCode.toString(),
      );
      itemList.assignAll(fetchedList);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadVersion() async {
    appVersion.value = await VersionHelper.getVersion();
  }

  Future<void> loadCompany() async {
    String? companyName = await SecureStorageHelper.read('company');
    company.value = companyName ?? '';
  }

  Future<void> getUserAccess() async {
    isLoading.value = true;

    try {
      String? userId = await SecureStorageHelper.read('userId');

      final fetchedUserAccess = await UserAccessRepo.getUserAccess(
        userId: int.parse(userId!),
      );

      menuAccess.assignAll(fetchedUserAccess.menuAccess);
      buildMenuItems();
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logoutUser() async {
    isLoading.value = true;
    try {
      await SecureStorageHelper.clearAll();
      Get.offAll(() => AuthScreen());
      showSuccessSnackbar(
        'Logged Out',
        'You have been successfully logged out.',
      );
    } catch (e) {
      showErrorSnackbar(
        'Logout Failed',
        'Something went wrong. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkAppVersion() async {
    isLoading.value = true;
    String? deviceId = await DeviceHelper().getDeviceId();

    if (deviceId == null) {
      showErrorSnackbar('Login Failed', 'Unable to fetch device ID.');
      isLoading.value = false;
      return;
    }

    try {
      String? version = await VersionHelper.getVersion();

      var result = await HomeRepo.checkVersion(
        version: version,
        deviceId: deviceId,
      );

      if (result is List && result.isEmpty) {
        return;
      }
    } catch (e) {
      if (e.toString().contains('Please update your app with latest version')) {
        Get.dialog(
          WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              title: Text(
                'Update Required',
                style: TextStyles.kBoldMontserrat(
                  fontSize: FontSizes.k20FontSize,
                ),
              ),
              content: Text(
                e.toString(),
                style: TextStyles.kRegularMontserrat(
                  fontSize: FontSizes.k16FontSize,
                ),
              ),
              actions: [
                AppTextButton(
                  onPressed: () async {
                    await redirectToPlayStore();
                  },
                  title: 'Update',
                ),
              ],
            ),
          ),
          barrierDismissible: false,
        );
      } else if (e.toString().contains('Please login again.')) {
        Get.dialog(
          WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              title: Text(
                'Session Expired',
                style: TextStyles.kBoldMontserrat(
                  fontSize: FontSizes.k20FontSize,
                ),
              ),
              content: Text(
                e.toString(),
                style: TextStyles.kRegularMontserrat(
                  fontSize: FontSizes.k16FontSize,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back();
                    logoutUser();
                  },
                  child: Text(
                    'Login Again',
                    style:
                        TextStyles.kMediumMontserrat(
                          fontSize: FontSizes.k16FontSize,
                          color: kColorPrimary,
                        ).copyWith(
                          height: 1,
                          decoration: TextDecoration.underline,
                          decorationColor: kColorPrimary,
                        ),
                  ),
                ),
              ],
            ),
          ),
          barrierDismissible: false,
        );
      } else {
        showErrorSnackbar('Error', e.toString());
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> redirectToPlayStore() async {
    const playStoreUrl =
        'https://play.google.com/store/apps/details?id=com.jinee.gamdiwala';

    final uri = Uri.parse(playStoreUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      showErrorSnackbar('Error', 'Could not launch the Play Store.');
    }
  }

  void buildMenuItems() {
    menuItems.value = [
      HomeMenuItemDm(
        menuName: 'Order',
        icon: Icons.shopping_bag_outlined,
        onTap: () {
          Get.to(() => HomeScreen());
        },
      ),
      HomeMenuItemDm(
        menuName: 'Challan',
        icon: Icons.description_outlined,
        onTap: () {
          Get.to(() => ChallanEntryScreen());
        },
      ),
      HomeMenuItemDm(
        menuName: 'Invoice',
        icon: Icons.description_outlined,
        onTap: () {
          Get.to(() => SalesInvoiceScreen());
        },
      ),
      HomeMenuItemDm(
        menuName: 'Reports',
        icon: Icons.assessment_outlined,
        subMenus: [
          HomeMenuItemDm(
            menuName: 'Order Report',
            icon: Icons.analytics_outlined,
            onTap: () {
              Get.to(() => OrderReportScreen());
            },
          ),
          HomeMenuItemDm(
            menuName: 'Challan Report',
            icon: Icons.summarize_outlined,
            onTap: () {
              Get.to(() => ChallanReportScreen());
            },
          ),
        ],
      ),

      HomeMenuItemDm(
        menuName: 'User Settings',
        icon: Icons.settings_outlined,
        subMenus: [
          HomeMenuItemDm(
            menuName: 'User Rights',
            icon: Icons.admin_panel_settings_outlined,
            onTap: () {
              Get.to(() => UsersScreen(fromWhere: 'R'));
            },
          ),
          HomeMenuItemDm(
            menuName: 'Manage User',
            icon: Icons.manage_accounts_outlined,
            onTap: () {
              Get.to(() => UsersScreen(fromWhere: 'M'));
            },
          ),
          HomeMenuItemDm(
            menuName: 'User Auth',
            icon: Icons.verified_user_outlined,
            onTap: () {
              Get.to(() => UnauthUsersScreen());
            },
          ),
        ],
      ),
    ];
  }

  void toggleMenuExpansion(int index) {
    if (expandedMenuIndex.value == index) {
      expandedMenuIndex.value = -1;
    } else {
      expandedMenuIndex.value = index;
    }
  }
}
