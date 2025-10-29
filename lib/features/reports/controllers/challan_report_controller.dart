import 'package:flutter/material.dart';
import 'package:gamdiwala/features/authentication/auth/models/party_dm.dart';
import 'package:gamdiwala/features/home/models/item_dm.dart';
import 'package:gamdiwala/features/reports/models/challan_repot_dm.dart';
import 'package:gamdiwala/features/reports/repos/challan_report_repo.dart';
import 'package:gamdiwala/features/reports/widgets/challan_report_pdf.dart';
import 'package:gamdiwala/utils/dialogs/app_dialogs.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChallanReportController extends GetxController {
  var isLoading = false.obs;

  var fromDateController = TextEditingController();
  var toDateController = TextEditingController();

  var reportTypes = <String>['Date Wise', 'Customer Wise', 'Item Wise'].obs;
  var selectedReportType = 'Date Wise'.obs;

  var parties = <PartyDm>[].obs;
  var partyNames = <String>[].obs;
  var selectedPartyName = ''.obs;
  var selectedPartyCode = ''.obs;

  var items = <ItemDm>[].obs;
  var itemNames = <String>[].obs;
  var selectedItemName = ''.obs;
  var selectedItemCode = ''.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final formatter = DateFormat('dd-MM-yyyy');
    fromDateController.text = formatter.format(monthStart);
    toDateController.text = formatter.format(now);

    isLoading.value = true;
    await getParties();
    await getItems();
    isLoading.value = false;
  }

  @override
  void onClose() {
    fromDateController.dispose();
    toDateController.dispose();
    super.onClose();
  }

  Future<void> getParties() async {
    try {
      final fetchedParties = await ChallanReportRepo.getParties();
      parties.assignAll(fetchedParties);
      partyNames.assignAll(fetchedParties.map((p) => p.pName));
      selectedPartyName.value = '';
      selectedPartyCode.value = '';
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    }
  }

  void onPartySelected(String? pName) {
    selectedPartyName.value = pName ?? '';
    final selectedPartyObj = parties.firstWhereOrNull((p) => p.pName == pName);
    selectedPartyCode.value = selectedPartyObj?.pCode ?? '';
  }

  Future<void> getItems() async {
    try {
      final fetchedItems = await ChallanReportRepo.getItems();
      items.assignAll(fetchedItems);
      itemNames.assignAll(fetchedItems.map((i) => i.iName));
      selectedItemName.value = '';
      selectedItemCode.value = '';
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    }
  }

  void onItemSelected(String? iName) {
    selectedItemName.value = iName ?? '';
    final selectedItemObj = items.firstWhereOrNull((i) => i.iName == iName);
    selectedItemCode.value = selectedItemObj?.iCode ?? '';
  }

  void onReportTypeSelected(String? reportType) {
    selectedReportType.value = reportType ?? 'Date Wise';
  }

  Future<void> getReport() async {
    final fromDate = DateFormat(
      'yyyy-MM-dd',
    ).format(DateFormat('dd-MM-yyyy').parse(fromDateController.text));

    final toDate = DateFormat(
      'yyyy-MM-dd',
    ).format(DateFormat('dd-MM-yyyy').parse(toDateController.text));

    try {
      isLoading.value = true;

      final response = await ChallanReportRepo.getChallanReport(
        fromDate: fromDate,
        toDate: toDate,
        pCode: selectedPartyCode.value,
        iCode: selectedItemCode.value,
      );

      final List<dynamic>? jsonList = response?['data'];

      if (jsonList == null || jsonList.isEmpty) {
        showErrorSnackbar(
          'No Data',
          'No records found for the selected filters.',
        );
        return;
      }

      final List<ChallanReportDm> reportData = jsonList
          .map((json) => ChallanReportDm.fromJson(json))
          .toList();

      await generateChallanReportPDF(
        reportData,
        fromDateController.text,
        toDateController.text,
        selectedReportType.value,
      );
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

  void clearAll() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final formatter = DateFormat('dd-MM-yyyy');
    fromDateController.text = formatter.format(monthStart);
    toDateController.text = formatter.format(now);
    selectedReportType.value = 'Date Wise';
    selectedPartyName.value = '';
    selectedPartyCode.value = '';
    selectedItemName.value = '';
    selectedItemCode.value = '';
  }
}
