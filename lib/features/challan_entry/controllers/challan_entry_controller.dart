import 'package:flutter/material.dart';
import 'package:gamdiwala/features/challan_entry/models/order_dm.dart';
import 'package:gamdiwala/features/challan_entry/repos/challan_entry_repo.dart';
import 'package:gamdiwala/utils/dialogs/app_dialogs.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChallanController extends GetxController {
  var isLoading = false.obs;
  final formKey = GlobalKey<FormState>();
  final challanDateFormKey = GlobalKey<FormState>();
  var orderDateController = TextEditingController();
  var challanDateController = TextEditingController();
  var challanOrders = <ChallanOrderDm>[].obs;

  @override
  void onClose() {
    orderDateController.dispose();
    challanDateController.dispose();
    super.onClose();
  }

  Future<void> searchOrders() async {
    isLoading.value = true;
    try {
      final orderDate = DateFormat(
        'yyyy-MM-dd',
      ).format(DateFormat('dd-MM-yyyy').parse(orderDateController.text));

      final fetchedOrders = await ChallanRepo.getOrders(date: orderDate);

      challanOrders.assignAll(fetchedOrders);

      if (fetchedOrders.isEmpty) {
        showErrorSnackbar('No Orders', 'No orders found for selected date');
      }
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveChallanEntry(String selectedInvNo) async {
    if (!challanDateFormKey.currentState!.validate()) return false;

    isLoading.value = true;
    try {
      final selectedOrder = challanOrders.firstWhere(
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
        await searchOrders();
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

  void clearSearch() {
    orderDateController.clear();
    challanOrders.clear();
  }
}
