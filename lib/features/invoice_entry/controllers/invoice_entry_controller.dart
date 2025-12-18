import 'package:flutter/material.dart';
import 'package:gamdiwala/features/invoice_entry/models/invoice_dm.dart';
import 'package:gamdiwala/features/invoice_entry/models/invoice_party_dm.dart';
import 'package:gamdiwala/features/invoice_entry/repos/invoice_entry_repo.dart';
import 'package:gamdiwala/utils/dialogs/app_dialogs.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class InvoiceEntryController extends GetxController {
  var isLoading = false.obs;
  final formKey = GlobalKey<FormState>();

  var fromDateController = TextEditingController();
  var toDateController = TextEditingController();

  final List<String> billPeriodOptions = [
    'Daily',
    'Monthly',
    'Weekly',
    'Fortnight',
    '10 Days',
  ];

  var selectedBillPeriod = ''.obs;
  var parties = <InvoicePartyDm>[].obs;
  var selectedParty = Rxn<InvoicePartyDm>();
  var challans = <InvoiceChallanDm>[].obs;

  @override
  void onInit() {
    super.onInit();
    fromDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    toDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  @override
  void onClose() {
    fromDateController.dispose();
    toDateController.dispose();
    super.onClose();
  }

  // Auto-fetch parties when conditions are met
  void _autoFetchParties() {
    if (fromDateController.text.isNotEmpty &&
        toDateController.text.isNotEmpty &&
        selectedBillPeriod.value.isNotEmpty) {
      getParties();
    }
  }

  // Called when dates change
  void onDateChanged() {
    parties.clear();
    selectedParty.value = null;
    challans.clear();
    _autoFetchParties();
  }

  // Called when bill period changes
  void onBillPeriodChanged(String? newPeriod) {
    if (newPeriod != null) {
      selectedBillPeriod.value = newPeriod;
      parties.clear();
      selectedParty.value = null;
      challans.clear();
      _autoFetchParties();
    }
  }

  Future<void> getParties() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final fromDate = DateFormat(
        'yyyy-MM-dd',
      ).format(DateFormat('dd-MM-yyyy').parse(fromDateController.text));
      final toDate = DateFormat(
        'yyyy-MM-dd',
      ).format(DateFormat('dd-MM-yyyy').parse(toDateController.text));

      final fetchedParties = await InvoiceEntryRepo.getParties(
        fromDate: fromDate,
        toDate: toDate,
        billPeriod: selectedBillPeriod.value,
      );

      parties.assignAll(fetchedParties);
      selectedParty.value = null;
      challans.clear();

      if (parties.isEmpty) {
        showErrorSnackbar('No Data', 'No parties found for selected criteria');
      }
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
      parties.clear();
      selectedParty.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  void onPartyChanged(String? pName) {
    if (pName != null) {
      selectedParty.value = parties.firstWhere((party) => party.pName == pName);
      getChallans();
    }
  }

  Future<void> getChallans() async {
    if (selectedParty.value == null) return;

    isLoading.value = true;
    try {
      final fromDate = DateFormat(
        'yyyy-MM-dd',
      ).format(DateFormat('dd-MM-yyyy').parse(fromDateController.text));
      final toDate = DateFormat(
        'yyyy-MM-dd',
      ).format(DateFormat('dd-MM-yyyy').parse(toDateController.text));

      final fetchedChallans = await InvoiceEntryRepo.getChallans(
        fromDate: fromDate,
        toDate: toDate,
        pCode: selectedParty.value!.pCode,
      );

      challans.assignAll(fetchedChallans);

      if (challans.isEmpty) {
        showErrorSnackbar('No Data', 'No challans found for selected party');
      }
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
      challans.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveInvoiceEntry() async {
    if (!formKey.currentState!.validate()) return false;
    if (selectedBillPeriod.value.isEmpty) {
      showErrorSnackbar('Error', 'Please select bill period');
      return false;
    }
    if (selectedParty.value == null) {
      showErrorSnackbar('Error', 'Please select a party');
      return false;
    }
    if (challans.isEmpty) {
      showErrorSnackbar('Error', 'No challans available to save');
      return false;
    }

    isLoading.value = true;
    try {
      final fromDate = DateFormat(
        'yyyy-MM-dd',
      ).format(DateFormat('dd-MM-yyyy').parse(fromDateController.text));
      final toDate = DateFormat(
        'yyyy-MM-dd',
      ).format(DateFormat('dd-MM-yyyy').parse(toDateController.text));

      final response = await InvoiceEntryRepo.saveInvoiceEntry(
        fromDate: fromDate,
        toDate: toDate,
        pCode: selectedParty.value!.pCode,
        billPeriod: selectedBillPeriod.value,
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        showSuccessSnackbar('Success', message);
        clearForm();
        return true;
      }
      return false;
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    fromDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    toDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    selectedBillPeriod.value = '';
    parties.clear();
    selectedParty.value = null;
    challans.clear();
  }
}
