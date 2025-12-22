import 'package:flutter/material.dart';
import 'package:gamdiwala/features/invoice_entry/models/sale_invoice_dm.dart';
import 'package:gamdiwala/features/invoice_entry/repos/invoice_repo.dart';
import 'package:gamdiwala/utils/dialogs/app_dialogs.dart';
import 'package:get/get.dart';

class InvoiceController extends GetxController {
  var isLoading = true.obs;
  var isLoadingMore = false.obs;
  var hasMoreData = true.obs;
  var currentPage = 1;
  var pageSize = 10;
  var isFetchingData = false;

  var searchController = TextEditingController();
  var searchQuery = ''.obs;

  var sales = <SaleInvoiceDm>[].obs;

  @override
  void onInit() async {
    super.onInit();
    await getSales();
    debounceSearchQuery();
  }

  void debounceSearchQuery() {
    debounce(
      searchQuery,
      (_) => getSales(),
      time: const Duration(milliseconds: 300),
    );
  }

  Future<void> getSales({bool loadMore = false}) async {
    if (loadMore && !hasMoreData.value) return;
    if (isFetchingData) return;

    try {
      isFetchingData = true;
      if (!loadMore) {
        isLoading.value = true;
        currentPage = 1;
        sales.clear();
        hasMoreData.value = true;
      } else {
        isLoadingMore.value = true;
      }

      var fetchedSales = await InvoiceRepo.getSales(
        pageNumber: currentPage,
        pageSize: pageSize,
        searchText: searchQuery.value,
      );

      if (fetchedSales.isNotEmpty) {
        sales.addAll(fetchedSales);
        currentPage++;
      } else {
        hasMoreData.value = false;
      }
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
      isFetchingData = false;
      isLoadingMore.value = false;
    }
  }
}
