import 'package:flutter/material.dart';
import 'package:gamdiwala/features/user_settings/controllers/users_controller.dart';
import 'package:gamdiwala/features/user_settings/models/user_access_dm.dart';
import 'package:gamdiwala/features/user_settings/repos/user_access_repo.dart';
import 'package:gamdiwala/features/home/controllers/home_controller.dart';
import 'package:gamdiwala/utils/dialogs/app_dialogs.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class UserAccessController extends GetxController {
  var isLoading = false.obs;

  var menuAccess = <MenuAccessDm>[].obs;
  var ledgerDates = <LedgerDateDm>[].obs;

  var ledgerStartDateController = TextEditingController();
  var ledgerEndDateController = TextEditingController();

  Future<void> getUserAccess({required int userId}) async {
    try {
      isLoading.value = true;

      final fetchedUserAccess = await UserAccessRepo.getUserAccess(
        userId: userId,
      );

      menuAccess.assignAll(fetchedUserAccess.menuAccess);
      ledgerDates.assignAll(fetchedUserAccess.ledgerDate);

      if (ledgerDates.isNotEmpty) {
        final start = ledgerDates.first.ledgerStart;
        final end = ledgerDates.first.ledgerEnd;

        if (start.isNotEmpty) {
          ledgerStartDateController.text = DateFormat(
            'dd-MM-yyyy',
          ).format(DateTime.parse(start));
        } else {
          ledgerStartDateController.clear();
        }

        if (end.isNotEmpty) {
          ledgerEndDateController.text = DateFormat(
            'dd-MM-yyyy',
          ).format(DateTime.parse(end));
        } else {
          ledgerEndDateController.clear();
        }
      } else {
        ledgerStartDateController.clear();
        ledgerEndDateController.clear();
      }
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  final UsersController usersController = Get.find<UsersController>();
  final HomeController homeController = Get.find<HomeController>();

  Future<void> setAppAccess({
    required int userId,
    required bool appAccess,
  }) async {
    isLoading.value = true;

    try {
      var response = await UserAccessRepo.setAppAccess(
        userId: userId,
        appAccess: appAccess,
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        usersController.getUsers();
        showSuccessSnackbar('Success', message);
      }
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setMenuAccess({
    required int userId,
    required int menuId,
    required bool menuAccess,
  }) async {
    isLoading.value = true;

    try {
      var response = await UserAccessRepo.setMenuAccess(
        userId: userId,
        menuId: menuId,
        menuAccess: menuAccess,
      );

      if (response != null && response.containsKey('message')) {
        getUserAccess(userId: userId);
        homeController.getUserAccess();
      }
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setLedger({required int userId}) async {
    isLoading.value = true;

    try {
      var response = await UserAccessRepo.setLedger(
        userId: userId,
        ledgerStart: ledgerStartDateController.text.isNotEmpty
            ? DateFormat('yyyy-MM-dd').format(
                DateFormat('dd-MM-yyyy').parse(ledgerStartDateController.text),
              )
            : null,
        ledgerEnd: ledgerEndDateController.text.isNotEmpty
            ? DateFormat('yyyy-MM-dd').format(
                DateFormat('dd-MM-yyyy').parse(ledgerEndDateController.text),
              )
            : null,
      );

      if (response != null && response.containsKey('message')) {
        getUserAccess(userId: userId);
      }
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
