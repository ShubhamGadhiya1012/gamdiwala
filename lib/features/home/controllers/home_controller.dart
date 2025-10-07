import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/constants/image_constants.dart';
import 'package:gamdiwala/features/authentication/auth/screens/auth_screen.dart';
import 'package:gamdiwala/features/home/models/cart_item_dm.dart';
import 'package:gamdiwala/features/home/models/item_dm.dart';
import 'package:gamdiwala/features/user_settings/models/user_access_dm.dart';
import 'package:gamdiwala/features/user_settings/repos/user_access_repo.dart';
import 'package:gamdiwala/features/user_settings/screens/unauth_users_screen.dart';
import 'package:gamdiwala/features/user_settings/screens/users_screen.dart';
import 'package:gamdiwala/features/home/models/home_menu_item_dm.dart';
import 'package:gamdiwala/features/home/repos/home_repo.dart';
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

  var cartItems = <CartItemDm>[].obs;
  var cartCount = 0.obs;

  @override
  void onInit() async {
    super.onInit();
    await getItems();
    await getCartItems();
    await _loadVersion();
    await loadCompany();
    await checkAppVersion();
    await getUserAccess();
  }

  Future<void> getItems() async {
    isLoading.value = true;

    String? selectPCode = await SecureStorageHelper.read('selectPCode');
    String? selectPName = await SecureStorageHelper.read('selectPName');

    print(selectPCode);
    print(selectPName);
    try {
      final fetchedList = await HomeRepo.getItems(
        pCode: selectPCode.toString(),
      );
      itemList.assignAll(fetchedList);

      await getCartItems();
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getCartItems() async {
    isLoading.value = true;
    try {
      String? selectPCode = await SecureStorageHelper.read('selectPCode');

      final fetchedCartItems = await HomeRepo.getCartItems(
        pCode: selectPCode.toString(),
      );

      cartItems.assignAll(fetchedCartItems);
      cartCount.value = fetchedCartItems.length;
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
    company.value = companyName!;
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
        'https://play.google.com/store/apps/details?id=com.jinee.jct';

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
        menuName: 'User Settings',

        icon: kIconUserSettings,
        subMenus: [
          HomeMenuItemDm(
            menuName: 'User Rights',

            icon: kIconUserRights,
            onTap: () {
              Get.to(() => UsersScreen(fromWhere: 'R'));
            },
          ),
          HomeMenuItemDm(
            menuName: 'Manage User',

            icon: kIconUserManagement,
            onTap: () {
              Get.to(() => UsersScreen(fromWhere: 'M'));
            },
          ),
          HomeMenuItemDm(
            menuName: 'User Auth',

            icon: kIconUserAuthorisation,
            onTap: () {
              Get.to(() => UnauthUsersScreen());
            },
          ),
        ],
      ),
      HomeMenuItemDm(
        menuName: 'Ledger',

        icon: kIconUserManagement,
        onTap: () {},
      ),
      HomeMenuItemDm(
        menuName: 'Invoice',

        icon: kIconUserManagement,
        onTap: () {},
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

  Future<void> saveCartItem({
    required ItemDm item,
    required double qty,
    required double caratQty,
    required double caratNos,
  }) async {
    isLoading.value = true;
    try {
      String? selectPCode = await SecureStorageHelper.read('selectPCode');

      double amount = 0;
      if (item.caratNos > 0) {
        amount = item.rate * item.caratQty * caratQty;
      } else {
        amount = item.rate * qty;
      }

      final response = await HomeRepo.saveCartItem(
        pCode: selectPCode ?? '',
        iCode: item.iCode,
        qty: qty,
        rate: item.rate,
        amount: amount,
        packQty: item.packQty,
        caratNos: caratNos,
        caratQty: caratQty,
        itemPack: item.itemPack,
        fat: item.fat,
        lr: item.lr,
      );

      if (response != null && response['message'] != null) {
        final itemIndex = itemList.indexWhere((i) => i.iCode == item.iCode);
        if (itemIndex != -1) {
          final updatedItem = ItemDm(
            iCode: item.iCode,
            iName: item.iName,
            description: item.description,
            unit: item.unit,
            rate: item.rate,
            hsnNo: item.hsnNo,
            packQty: item.packQty,
            caratNos: item.caratNos,
            caratQty: item.caratQty,
            itemPack: item.itemPack,
            fat: item.fat,
            lr: item.lr,
            qty: qty,
            caratCount: caratQty,
            nosCount: caratNos.toInt(),
          );
          itemList[itemIndex] = updatedItem;
          itemList.refresh();
        }

        final index = cartItems.indexWhere((cart) => cart.iCode == item.iCode);

        if (qty == 0 && caratQty == 0 && caratNos == 0) {
          if (index != -1) {
            cartItems.removeAt(index);
            cartCount.value = cartItems.length;
          }
        } else {
          final updatedCartItem = CartItemDm(
            date: DateTime.now().toString(),
            pCode: selectPCode ?? '',
            partyName: '',
            iCode: item.iCode,
            itemName: item.iName,
            qty: qty,
            rate: item.rate,
            amount: amount,
            caratNos: caratNos,
            caratQty: caratQty,
            itemPack: item.itemPack,
            packQty: item.packQty,
            fat: item.fat,
            lr: item.lr,
            nosCount: caratNos.toInt(),
            caratCount: caratQty,
          );

          if (index != -1) {
            cartItems[index] = updatedCartItem;
          } else {
            cartItems.add(updatedCartItem);
            cartCount.value = cartItems.length;
          }
        }

        cartItems.refresh();
      }

      cartCount.value = await _getCartCount();
    } catch (e) {
      print(e);
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<int> _getCartCount() async {
    try {
      String? selectPCode = await SecureStorageHelper.read('selectPCode');
      final fetchedCartItems = await HomeRepo.getCartItems(
        pCode: selectPCode ?? '',
      );
      return fetchedCartItems.length;
    } catch (e) {
      return 0;
    }
  }
}
