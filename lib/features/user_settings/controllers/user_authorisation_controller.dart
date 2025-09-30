import 'package:flutter/material.dart';
import 'package:gamdiwala/features/user_settings/controllers/unauth_users_controller.dart';
import 'package:gamdiwala/features/user_settings/models/engineer_dm.dart';
import 'package:gamdiwala/features/user_settings/models/salesman_dm.dart';
import 'package:gamdiwala/features/user_settings/repos/user_authorisation_repo.dart';
import 'package:gamdiwala/features/user_settings/repos/user_management_repo.dart';
import 'package:gamdiwala/utils/dialogs/app_dialogs.dart';
import 'package:get/get.dart';

class UserAuthorisationController extends GetxController {
  var isLoading = false.obs;
  final authUserFormKey = GlobalKey<FormState>();

  var salesmen = <SalesmanDm>[].obs;
  var salesmanNames = <String>[].obs;
  var filteredSalesmen = <SalesmanDm>[].obs;
  var selectedSalesmanCodes = <String>[].obs;
  var selectedSalesmanNames = <String>[].obs;
  var searchSalesmanController = TextEditingController();
  var selectedSalesmanName = ''.obs;
  var selectedSalesmanCode = ''.obs;

  var engineers = <EngineerDm>[].obs;
  var engineerNames = <String>[].obs;
  var filteredEngineers = <EngineerDm>[].obs;
  var selectedEngineerCodes = <String>[].obs;
  var selectedEngineerNames = <String>[].obs;
  var searchEngineerController = TextEditingController();
  var selectedEngineerName = ''.obs;
  var selectedEngineerCode = ''.obs;

  var userTypes = {0: 'Admin', 1: 'Manager', 2: 'Salesman', 3: 'Engineer'}.obs;

  var selectedUserType = Rxn<int>();

  void onUserTypeChanged(String selectedValue) async {
    final selectedIndex = userTypes.values.toList().indexOf(selectedValue);

    selectedUserType.value = selectedIndex == -1 ? null : selectedIndex;

    selectedSalesmanCodes.clear();
    selectedSalesmanNames.clear();
    selectedSalesmanCode.value = '';
    selectedSalesmanName.value = '';
    selectedEngineerCodes.clear();
    selectedEngineerNames.clear();
    selectedEngineerCode.value = '';
    selectedEngineerName.value = '';

    if (selectedUserType.value == 1) {
      await getSalesmen();
      await getEngineers();
    }
    if (selectedUserType.value == 2) {
      await getSalesmen();
    }
    if (selectedUserType.value == 3) {
      await getEngineers();
    }
  }

  Future<void> getSalesmen() async {
    isLoading.value = true;
    try {
      final fetchedSalesmen = await UserManagementRepo.getSalesmen();

      salesmen.assignAll(fetchedSalesmen);
      salesmanNames.assignAll(fetchedSalesmen.map((se) => se.seName));
      filteredSalesmen.assignAll(fetchedSalesmen);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onSalesmanSelected(String? salesmanName) {
    selectedSalesmanName.value = salesmanName!;

    var selectedSalesmanObj = salesmen.firstWhere(
      (se) => se.seName == salesmanName,
    );

    selectedSalesmanCode.value = selectedSalesmanObj.seCode;
  }

  void selectAllSalesmen() {
    selectedSalesmanCodes.assignAll(salesmen.map((se) => se.seCode));
    selectedSalesmanNames.assignAll(salesmen.map((se) => se.seName));
  }

  Future<void> getEngineers() async {
    isLoading.value = true;
    try {
      final fetchedEngineers = await UserManagementRepo.getEngineers();

      engineers.assignAll(fetchedEngineers);
      engineerNames.assignAll(fetchedEngineers.map((er) => er.eName));
      filteredEngineers.assignAll(fetchedEngineers);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onEngineerSelected(String? engineerName) {
    selectedEngineerName.value = engineerName!;

    var selectedEngineerObj = engineers.firstWhere(
      (er) => er.eName == engineerName,
    );

    selectedEngineerCode.value = selectedEngineerObj.eCode;
  }

  void selectAllEngineers() {
    selectedEngineerCodes.assignAll(engineers.map((er) => er.eCode));
    selectedEngineerNames.assignAll(engineers.map((er) => er.eName));
  }

  final UnauthUsersController unauthUsersController =
      Get.find<UnauthUsersController>();

  Future<void> authoriseUser({required int userId}) async {
    isLoading.value = true;

    try {
      var response = await UserAuthorisationRepo.authoriseUser(
        userId: userId,
        userType: selectedUserType.value!,
        pCodes: '',
        seCodes: selectedUserType.value == 1
            ? (selectedSalesmanCodes.isEmpty
                  ? ''
                  : selectedSalesmanCodes.join(','))
            : (selectedUserType.value == 2 ? selectedSalesmanCode.value : ''),
        eCodes: selectedUserType.value == 1
            ? (selectedEngineerCodes.isEmpty
                  ? ''
                  : selectedEngineerCodes.join(','))
            : (selectedUserType.value == 3 ? selectedEngineerCode.value : ''),
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        await unauthUsersController.getUnauthorisedUsers();
        Get.back();
        showSuccessSnackbar('Success', message);
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
