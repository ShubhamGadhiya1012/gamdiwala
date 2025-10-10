import 'package:flutter/material.dart';
import 'package:gamdiwala/features/authentication/auth/models/year_dm.dart';
import 'package:gamdiwala/features/authentication/auth/repos/select_company_repo.dart';
import 'package:gamdiwala/features/authentication/auth/screens/select_party_screen.dart';
import 'package:gamdiwala/utils/dialogs/app_dialogs.dart';
import 'package:gamdiwala/utils/helpers/secure_storage_helper.dart';
import 'package:get/get.dart';

class SelectCompanyController extends GetxController {
  var isLoading = false.obs;
  final selectCompanyFormKey = GlobalKey<FormState>();

  var selectedCoCode = Rxn<int>();
  var selectedCid = Rxn<int>();
  var selectedCoName = ''.obs;

  var years = <YearDm>[].obs;
  var finYears = <String>[].obs;
  var selectedFinYear = ''.obs;
  var selectedYearId = 0.obs;

  Future<void> getYears() async {
    try {
      isLoading.value = true;

      final fetchedYears = await SelectCompanyRepo.getYears(
        coCode: selectedCoCode.value!,
      );

      years.assignAll(fetchedYears);
      finYears.assignAll(fetchedYears.map((year) => year.finYear).toList());

      if (fetchedYears.isNotEmpty) {
        selectedFinYear.value = fetchedYears.first.finYear;
        selectedYearId.value = fetchedYears.first.yearId;
      }
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onYearSelected(String? finYear) {
    selectedFinYear.value = finYear!;

    var selectedYearObj = years.firstWhere((year) => year.finYear == finYear);

    selectedYearId.value = selectedYearObj.yearId;
  }

  Future<void> getToken({
    required String mobileNumber,
    required int cid,
    required int yearId,
  }) async {
    isLoading.value = true;

    try {
      var response = await SelectCompanyRepo.getToken(
        mobileNumber: mobileNumber,
        cid: cid,
        yearId: yearId,
      );

      await SecureStorageHelper.write('token', response['token']);
      await SecureStorageHelper.write('fullName', response['fullName']);
      await SecureStorageHelper.write(
        'userType',
        response['userType'].toString(),
      );
      await SecureStorageHelper.write(
        'mobileNo',
        response['mobileNo'].toString(),
      );
      await SecureStorageHelper.write('userId', response['userId'].toString());
      await SecureStorageHelper.write(
        'ledgerStart',
        response['ledgerStart'] ?? '',
      );
      await SecureStorageHelper.write('ledgerEnd', response['ledgerEnd'] ?? '');
      await SecureStorageHelper.write('eCodes', response['ecodEs'] ?? '');
      await SecureStorageHelper.write('pCodes', response['pcodEs'] ?? '');
      await SecureStorageHelper.write('seCodes', response['secodEs'] ?? '');
      await SecureStorageHelper.write('company', selectedCoName.value);

      await SecureStorageHelper.write(
        'coCode',
        selectedCoCode.value.toString(),
      );

      Get.offAll(() => SelectPartyScreen());
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
