import 'package:flutter/material.dart';
import 'package:gamdiwala/features/home/models/vehicle_dm.dart';
import 'package:gamdiwala/features/invoice_entry/models/invoice_party_dm.dart';
import 'package:gamdiwala/features/reports/models/invoice_report_dm.dart';
import 'package:gamdiwala/features/reports/repos/invoice_report_repo.dart';
import 'package:gamdiwala/features/reports/widgets/invoice_report_pdf.dart';
import 'package:gamdiwala/utils/dialogs/app_dialogs.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class InvoiceReportController extends GetxController {
  var isLoading = false.obs;

  var fromDateController = TextEditingController();
  var toDateController = TextEditingController();

  final List<String> billPeriodOptions = [
    'All',
    'Daily',
    'Monthly',
    'Weekly',
    'Fortnight',
    '10 Days',
  ];
  var selectedBillPeriod = 'All'.obs;

  final List<String> statusOptions = ['ALL', 'PENDING', 'COMPLETE'];
  var selectedStatus = 'PENDING'.obs;

  var parties = <InvoicePartyDm>[].obs;
  var partyNames = <String>[].obs;
  var selectedPartyName = ''.obs;
  var selectedPartyCode = ''.obs;

  var vehicles = <VehicleDm>[].obs;
  var vehicleDisplayNames = <String>[].obs;
  var selectedVehicleDisplayName = ''.obs;
  var selectedVehicleCode = ''.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final formatter = DateFormat('dd-MM-yyyy');
    fromDateController.text = formatter.format(monthStart);
    toDateController.text = formatter.format(now);

    isLoading.value = true;
    await getVehicles();
    await getParties();
    isLoading.value = false;
  }

  @override
  void onClose() {
    fromDateController.dispose();
    toDateController.dispose();
    super.onClose();
  }

  void onFiltersChanged() {
    parties.clear();
    selectedPartyName.value = '';
    selectedPartyCode.value = '';
    partyNames.clear();
    getParties();
  }

  Future<void> getParties() async {
    if (fromDateController.text.isEmpty ||
        toDateController.text.isEmpty ||
        selectedBillPeriod.value.isEmpty) {
      return;
    }

    try {
      final fromDate = DateFormat(
        'yyyy-MM-dd',
      ).format(DateFormat('dd-MM-yyyy').parse(fromDateController.text));

      final toDate = DateFormat(
        'yyyy-MM-dd',
      ).format(DateFormat('dd-MM-yyyy').parse(toDateController.text));

      final fetchedParties = await InvoiceReportRepo.getParties(
        fromDate: fromDate,
        toDate: toDate,
        billPeriod: selectedBillPeriod.value,
      );

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

  Future<void> getVehicles() async {
    try {
      final fetchedVehicles = await InvoiceReportRepo.getVehicles();
      vehicles.assignAll(fetchedVehicles);
      vehicleDisplayNames.assignAll(
        fetchedVehicles.map((v) => '${v.regNo} - ${v.vType}'),
      );
      selectedVehicleDisplayName.value = '';
      selectedVehicleCode.value = '';
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    }
  }

  void onVehicleSelected(String? vehicleDisplay) {
    selectedVehicleDisplayName.value = vehicleDisplay ?? '';
    final selectedVehicleObj = vehicles.firstWhereOrNull(
      (v) => '${v.regNo} - ${v.vType}' == vehicleDisplay,
    );
    selectedVehicleCode.value = selectedVehicleObj?.vCode ?? '';
  }

  void onBillPeriodSelected(String? billPeriod) {
    selectedBillPeriod.value = billPeriod ?? 'All';
    onFiltersChanged();
  }

  void onStatusSelected(String? status) {
    selectedStatus.value = status ?? 'PENDING';
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

      final response = await InvoiceReportRepo.getInvoiceReport(
        fromDate: fromDate,
        toDate: toDate,
        pCode: selectedPartyCode.value,
        vCode: selectedVehicleCode.value,
        status: selectedStatus.value,
        billPeriod: selectedBillPeriod.value,
      );

      final List<dynamic>? jsonList = response?['data'];

      if (jsonList == null || jsonList.isEmpty) {
        showErrorSnackbar(
          'No Data',
          'No records found for the selected filters.',
        );
        return;
      }

      final List<InvoiceReportDm> reportData = jsonList
          .map((json) => InvoiceReportDm.fromJson(json))
          .toList();

      await generateInvoiceReportPDF(
        reportData,
        fromDateController.text,
        toDateController.text,
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
    selectedBillPeriod.value = 'All';
    selectedStatus.value = 'PENDING';
    selectedPartyName.value = '';
    selectedPartyCode.value = '';
    selectedVehicleDisplayName.value = '';
    selectedVehicleCode.value = '';
  }
}
