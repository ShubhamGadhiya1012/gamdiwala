import 'package:flutter/material.dart';
import 'package:gamdiwala/features/authentication/auth/models/party_dm.dart';
import 'package:gamdiwala/features/authentication/auth/repos/select_party_repo.dart';
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

  final List<String> statusOptions = ['Pending Challan', 'Completed Challan'];
  var selectedStatus = ''.obs;

  var isLoadingMore = false.obs;
  var hasMoreData = true.obs;
  var currentPage = 1;
  var pageSize = 5;
  var isFetchingData = false;
  var parties = <PartyDm>[].obs;
  var selectedParty = Rxn<PartyDm>();
  @override
  void onInit() {
    super.onInit();
    orderDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    getParties();
  }

  @override
  void onClose() {
    orderDateController.dispose();
    challanDateController.dispose();
    super.onClose();
  }

  Future<void> getParties() async {
    isLoading.value = true;
    try {
      final fetchedParties = await SelectPartyRepo.getCustomers();

      // Add "All" option at the beginning
      final allParty = PartyDm(pCode: '', pName: 'All');
      parties.assignAll([allParty, ...fetchedParties]);

      // Set "All" as default selected
      selectedParty.value = allParty;
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onPartyChanged(String? pName) {
    if (pName != null) {
      selectedParty.value = parties.firstWhere((party) => party.pName == pName);
      searchOrders();
    }
  }

  Future<void> searchOrders() async {
    if (selectedStatus.value.isEmpty || selectedParty.value == null) return;

    String status = selectedStatus.value == 'Pending Challan'
        ? 'PENDING'
        : 'COMPLETE';
    await loadOrdersByStatus(status);
  }

  void onStatusChanged(String? newStatus) {
    if (newStatus != null && newStatus != selectedStatus.value) {
      selectedStatus.value = newStatus;
      searchOrders();
    }
  }

  Future<void> loadOrdersByStatus(
    String status, {
    bool loadMore = false,
  }) async {
    if (loadMore && !hasMoreData.value) return;
    if (isFetchingData) return;

    try {
      isFetchingData = true;
      if (!loadMore) {
        isLoading.value = true;
        currentPage = 1;
        if (status == 'PENDING') {
          pendingOrders.clear();
        } else {
          completedOrders.clear();
        }
        hasMoreData.value = true;
      } else {
        isLoadingMore.value = true;
      }

      final orderDate = DateFormat(
        'yyyy-MM-dd',
      ).format(DateFormat('dd-MM-yyyy').parse(orderDateController.text));

      final fetchedOrders = await ChallanRepo.getOrders(
        date: orderDate,
        status: status,
        pageNumber: currentPage,
        pageSize: pageSize,
        pCode: selectedParty.value?.pCode ?? '',
      );

      if (fetchedOrders.isNotEmpty) {
        if (status == 'PENDING') {
          pendingOrders.addAll(fetchedOrders);
        } else {
          completedOrders.addAll(fetchedOrders);
        }
        currentPage++;
      } else {
        hasMoreData.value = false;
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
      isFetchingData = false;
      isLoadingMore.value = false;
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
