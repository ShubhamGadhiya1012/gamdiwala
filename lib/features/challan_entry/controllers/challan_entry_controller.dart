import 'package:flutter/material.dart';
import 'package:gamdiwala/features/challan_entry/models/order_dm.dart';
import 'package:gamdiwala/features/challan_entry/repos/challan_entry_repo.dart';
import 'package:gamdiwala/features/challan_entry/screens/challan_pdf_screen.dart';
import 'package:gamdiwala/utils/dialogs/app_dialogs.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChallanController extends GetxController {
  var isLoading = false.obs;
  final formKey = GlobalKey<FormState>();
  final challanDateFormKey = GlobalKey<FormState>();
  var orderDateController = TextEditingController();
  var challanDateController = TextEditingController();
  var pendingOrders = <ChallanOrderDm>[].obs;
  var completedOrders = <ChallanOrderDm>[].obs;

  @override
  void onInit() {
    super.onInit();

    orderDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  @override
  void onClose() {
    orderDateController.dispose();
    challanDateController.dispose();
    super.onClose();
  }

  void loadTodayOrders() {
    searchOrders();
  }

  Future<void> searchOrders() async {
    await loadOrdersByStatus('PENDING');
  }

  Future<void> loadOrdersByStatus(String status) async {
    isLoading.value = true;
    try {
      final orderDate = DateFormat(
        'yyyy-MM-dd',
      ).format(DateFormat('dd-MM-yyyy').parse(orderDateController.text));

      final fetchedOrders = await ChallanRepo.getOrders(
        date: orderDate,
        status: status,
      );

      if (status == 'PENDING') {
        pendingOrders.assignAll(fetchedOrders);
      } else {
        completedOrders.assignAll(fetchedOrders);
      }
    } catch (e) {
      showErrorSnackbar('Error', e.toString());

      if (status == 'PENDING') {
        pendingOrders.clear();
      } else {
        completedOrders.clear();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveChallanEntry(String selectedInvNo) async {
    if (!challanDateFormKey.currentState!.validate()) return false;

    isLoading.value = true;
    try {
      final selectedOrder = pendingOrders.firstWhere(
        (order) => order.invNo == selectedInvNo,
      );

      final challanDate = DateFormat(
        'yyyy-MM-dd',
      ).format(DateFormat('dd-MM-yyyy').parse(challanDateController.text));

      final response = await ChallanRepo.saveChallanEntry(
        invNos: selectedOrder.invNo,
        date: challanDate,
        pCode: selectedOrder.pCode,
        vCode: selectedOrder.vCode,
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        Get.back();
        challanDateController.clear();

        showSuccessSnackbar('Success', message);

        await loadOrdersByStatus('PENDING');
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

  Future<void> generateChallanPdf(String challanNo) async {
    isLoading.value = true;
    try {
      final response = await ChallanRepo.getChallanPdfData(
        challanNo: challanNo,
      );

      if (response != null &&
          response['data'] != null &&
          response['data'].isNotEmpty) {
        await ChallanPdfScreen.generateChallanPdf(
          challanData: response['data'][0],
        );
      } else {
        showErrorSnackbar('Error', 'No data found for PDF generation');
      }
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
      // print(e);
    } finally {
      isLoading.value = false;
    }
  }

  void clearSearch() {
    orderDateController.clear();
    pendingOrders.clear();
    completedOrders.clear();
  }
}
