import 'package:flutter/material.dart';
import 'package:gamdiwala/features/authentication/auth/models/party_dm.dart';
import 'package:gamdiwala/features/home/models/item_dm.dart';
import 'package:gamdiwala/features/reports/models/order_report_dm.dart';
import 'package:gamdiwala/features/reports/repos/order_report_repo.dart';
import 'package:gamdiwala/features/reports/widgets/order_report_pdf.dart';
import 'package:gamdiwala/utils/dialogs/app_dialogs.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OrderReportController extends GetxController {
  var isLoading = false.obs;

  var fromDateController = TextEditingController();
  var toDateController = TextEditingController();

  var statusList = <String>['ALL', 'PENDING', 'COMPLETE'].obs;
  var selectedStatus = 'ALL'.obs;

  var typeList = <String>['DETAIL', 'WITH CHALLAN', 'SUMMARY'].obs;
  var selectedType = 'DETAIL'.obs;

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
      final fetchedParties = await OrderReportRepo.getParties();
      parties.assignAll(fetchedParties);
      partyNames.assignAll(fetchedParties.map((p) => p.pName));
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    }
  }

  Future<void> getItems() async {
    try {
      final fetchedItems = await OrderReportRepo.getItems();
      items.assignAll(fetchedItems);
      itemNames.assignAll(fetchedItems.map((i) => i.iName));
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    }
  }

  void onPartySelected(String? pName) {
    selectedPartyName.value = pName ?? '';
    final selectedPartyObj = parties.firstWhereOrNull((p) => p.pName == pName);
    selectedPartyCode.value = selectedPartyObj?.pCode ?? '';
  }

  void onItemSelected(String? iName) {
    selectedItemName.value = iName ?? '';
    final selectedItemObj = items.firstWhereOrNull((i) => i.iName == iName);
    selectedItemCode.value = selectedItemObj?.iCode ?? '';
  }

  void onStatusSelected(String? status) {
    selectedStatus.value = status ?? 'ALL';
  }

  void onTypeSelected(String? type) {
    selectedType.value = type ?? 'DETAIL';
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

      final response = await OrderReportRepo.getOrderReport(
        fromDate: fromDate,
        toDate: toDate,
        pCode: selectedPartyCode.value,
        iCode: selectedItemCode.value,
        status: selectedStatus.value,
        type: selectedType.value,
      );

      final List<dynamic>? jsonList = response?['data'];
      if (jsonList == null || jsonList.isEmpty) {
        showErrorSnackbar('No Data', 'No records found.');
        return;
      }

      final reportData = jsonList
          .map((json) => OrderReportDm.fromJson(json))
          .toList();

      await generateOrderReportPDF(
        reportData,
        fromDateController.text,
        toDateController.text,
        selectedStatus.value,
        selectedType.value,
      );
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
      // print(e);
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
    selectedPartyCode.value = '';
    selectedItemCode.value = '';
    selectedPartyName.value = '';
    selectedItemName.value = '';
    selectedStatus.value = 'ALL';
    selectedType.value = 'DETAIL';
  }
}
