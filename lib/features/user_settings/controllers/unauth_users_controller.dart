import 'package:flutter/material.dart';
import 'package:gamdiwala/features/user_settings/models/unauth_user_dm.dart';
import 'package:gamdiwala/features/user_settings/repos/unauth_users_repo.dart';
import 'package:gamdiwala/utils/dialogs/app_dialogs.dart';
import 'package:get/get.dart';

class UnauthUsersController extends GetxController {
  var isLoading = false.obs;

  var unAuthorisedUsers = <UnauthUserDm>[].obs;
  var filteredUnAuthorisedUsers = <UnauthUserDm>[].obs;
  var searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    getUnauthorisedUsers();
  }

  Future<void> getUnauthorisedUsers() async {
    try {
      isLoading.value = true;

      final fetchedUsers = await UnauthUsersRepo.getUnauthorisedUsers();

      unAuthorisedUsers.assignAll(fetchedUsers);
      filteredUnAuthorisedUsers.assignAll(fetchedUsers);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void filterUsers(String query) {
    filteredUnAuthorisedUsers.assignAll(
      unAuthorisedUsers.where((user) {
        return user.fullName.toLowerCase().contains(query.toLowerCase()) ||
            user.mobileNo.toLowerCase().contains(query.toLowerCase());
      }).toList(),
    );
  }
}
