import 'package:flutter/material.dart';
import 'package:gamdiwala/features/authentication/auth/models/party_dm.dart';
import 'package:gamdiwala/features/authentication/auth/repos/select_party_repo.dart';
import 'package:gamdiwala/features/home/screens/home_screen.dart';
import 'package:gamdiwala/utils/dialogs/app_dialogs.dart';
import 'package:gamdiwala/utils/helpers/secure_storage_helper.dart';
import 'package:get/get.dart';

class SelectPartyController extends GetxController {
  var isLoading = false.obs;
  var parties = <PartyDm>[].obs;
  var filteredParties = <PartyDm>[].obs;
  var selectedParty = Rxn<PartyDm>();
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    getCustomers();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> getCustomers() async {
    try {
      isLoading.value = true;

      final fetchedParties = await SelectPartyRepo.getCustomers();
      parties.assignAll(fetchedParties);
      filteredParties.assignAll(fetchedParties);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String query) {
    if (query.isEmpty) {
      filteredParties.assignAll(parties);
    } else {
      filteredParties.assignAll(
        parties
            .where(
              (party) =>
                  party.pName.toLowerCase().contains(query.toLowerCase()) ||
                  party.pCode.toLowerCase().contains(query.toLowerCase()),
            )
            .toList(),
      );
    }
  }

  void onPartySelected(PartyDm party) {
    if (selectedParty.value?.pCode == party.pCode) {
      selectedParty.value = null;
    } else {
      selectedParty.value = party;
    }
  }

  Future<void> onContinue() async {
    if (selectedParty.value == null) {
      showErrorSnackbar('Error', 'Please select a party');
      return;
    }

    try {
      isLoading.value = true;

      await SecureStorageHelper.write(
        'selectPCode',
        selectedParty.value!.pCode,
      );
      await SecureStorageHelper.write(
        'selectPName',
        selectedParty.value!.pName,
      );

      Get.offAll(() => HomeScreen());
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
