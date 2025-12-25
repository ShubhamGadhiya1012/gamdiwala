import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gamdiwala/features/invoice_entry/models/sale_invoice_dm.dart';
import 'package:gamdiwala/features/invoice_entry/repos/invoice_repo.dart';
import 'package:gamdiwala/utils/dialogs/app_dialogs.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

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

  Future<void> printInvoice({
    required String invNo,
    required String bookCode,
    required String yearId,
    required String coCode,
    required String branchCode,
    required String pageSize,
  }) async {
    try {
      isLoading.value = true;

      final pdfBytes = await InvoiceRepo.printInvoice(
        invNo: invNo,
        bookCode: bookCode,
        yearId: yearId,
        coCode: coCode,
        branchCode: branchCode,
        pageSize: pageSize,
      );

      if (pdfBytes != null && pdfBytes.isNotEmpty) {
        await _savePdfAndOpenInvoice(pdfBytes, invNo, pageSize);
      } else {
        showErrorSnackbar('Error', 'Failed to print invoice.');
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

  Future<void> _savePdfAndOpenInvoice(
    Uint8List pdfBytes,
    String invNo,
    String pageSize,
  ) async {
    try {
      final sanitizedInvoiceNo = invNo.replaceAll(RegExp(r'[^\w\s-]'), '_');
      final fileName = 'Invoice_${sanitizedInvoiceNo}_$pageSize.pdf';

      // Use different directories for Android and iOS
      final Directory directory;
      if (Platform.isAndroid) {
        directory =
            await getExternalStorageDirectory() ??
            await getApplicationDocumentsDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pdfBytes);

      // Add a small delay to ensure file is written completely
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify file exists before opening
      if (!await file.exists()) {
        showErrorSnackbar('Error', 'PDF file was not created successfully.');
        return;
      }

      final result = await OpenFilex.open(file.path);

      if (result.type != ResultType.done) {
        showErrorSnackbar(
          'Error',
          'Could not open PDF file: ${result.message}',
        );
      } else {
        // Optional: Show success message
        Get.snackbar(
          'Success',
          'Invoice opened successfully',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to save PDF: ${e.toString()}');
    }
  }
}
