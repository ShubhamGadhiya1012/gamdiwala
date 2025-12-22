import 'package:flutter/material.dart';
import 'package:gamdiwala/features/authentication/auth/models/party_dm.dart';
import 'package:gamdiwala/features/home/models/vehicle_dm.dart';
import 'package:gamdiwala/features/invoice_entry/controllers/invoice_controller.dart';
import 'package:gamdiwala/features/invoice_entry/models/bill_type_dm.dart';
import 'package:gamdiwala/features/invoice_entry/models/book_dm.dart';
import 'package:gamdiwala/features/invoice_entry/models/customer_account_dm.dart';
import 'package:gamdiwala/features/invoice_entry/models/customer_voucher_dm.dart';
import 'package:gamdiwala/features/invoice_entry/models/challan_dm.dart';
import 'package:gamdiwala/features/invoice_entry/models/invoice_party_dm.dart';
import 'package:gamdiwala/features/invoice_entry/models/invoice_type_dm.dart';
import 'package:gamdiwala/features/invoice_entry/models/item_tax_dm.dart';
import 'package:gamdiwala/features/invoice_entry/models/sale_invoice_detail_dm.dart';
import 'package:gamdiwala/features/invoice_entry/models/tax_dm.dart';
import 'package:gamdiwala/features/invoice_entry/repos/invoice_entry_repo.dart';
import 'package:gamdiwala/features/invoice_entry/repos/invoice_repo.dart';
import 'package:gamdiwala/utils/dialogs/app_dialogs.dart';
import 'package:gamdiwala/utils/helpers/date_format_helper.dart';
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
  var challans = <ChallanDm>[].obs;
  var selectedVehicleForFilter = Rxn<VehicleDm>();

  var selectedChallans = <ChallanDm>[].obs;
  var isSelectionMode = false.obs;

  final page1FormKey = GlobalKey<FormState>();
  final page4FormKey = GlobalKey<FormState>();

  var currentPage = 0.obs;
  final PageController pageController = PageController();

  var dateController = TextEditingController();

  var books = <BookDm>[].obs;
  var bookDescriptions = <String>[].obs;
  var selectedBookCode = ''.obs;
  var selectedBookDescription = ''.obs;

  var customers = <PartyDm>[].obs;
  var customerNames = <String>[].obs;
  var selectedCustomerName = ''.obs;
  var selectedCustomerCode = ''.obs;

  var salesAccounts = <CustomerAccountDm>[].obs;
  var salesAccountNames = <String>[].obs;
  var selectedSalesAccountName = ''.obs;
  var selectedSalesAccountCode = ''.obs;

  var taxTypes = <TaxDm>[].obs;
  var taxTypeNames = <String>[].obs;
  var selectedTaxTypeName = ''.obs;
  var selectedTaxTypeCode = ''.obs;
  var isIGSTApplicable = false.obs;
  var isCGSTApplicable = false.obs;
  var isSGSTApplicable = false.obs;

  var billTypes = <BillTypeDm>[].obs;
  var billTypeNames = <String>[].obs;
  var selectedBillTypeName = ''.obs;
  var selectedBillTypeCode = ''.obs;

  var invoiceTypes = <InvoiceTypeDm>[].obs;
  var invoiceTypeNames = <String>[].obs;
  var selectedInvoiceTypeName = ''.obs;
  var selectedInvoiceTypeCode = ''.obs;

  var vehicles = <VehicleDm>[].obs;
  var vehicleDisplayNames = <String>[].obs;
  var selectedVehicleDisplayName = ''.obs;
  var selectedVehicleCode = ''.obs;

  var remarkController = TextEditingController();

  var itemsToSend = <Map<String, dynamic>>[].obs;

  var customiseVoucher = <CustomiseVoucherDm>[].obs;
  var ledgerDataToSend = <Map<String, dynamic>>[].obs;
  var customiseVoucherAmountControllers = <String, TextEditingController>{}.obs;
  var customiseVoucherPercentageControllers =
      <String, TextEditingController>{}.obs;

  var grossTotal = 0.0.obs;
  var totalIgst = 0.0.obs;
  var totalCgst = 0.0.obs;
  var totalSgst = 0.0.obs;
  var valueOfGoodsToSend = 0.0.obs;
  var netTotalToSend = 0.0.obs;

  var isEditMode = false.obs;
  var editInvNo = ''.obs;
  var editYearId = 0.obs;

  var saleInvoiceDetails = Rxn<SaleInvoiceDetailDm>();
  List<SaleInvoiceData1Dm> get data1 => saleInvoiceDetails.value?.data1 ?? [];
  List<SaleInvoiceData2Dm> get data2 => saleInvoiceDetails.value?.data2 ?? [];
  List<SaleInvoiceData3Dm> get data3 => saleInvoiceDetails.value?.data3 ?? [];

  @override
  Future<void> onInit() async {
    super.onInit();
    fromDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    toDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());

    await getBooks(dbc: 'SALE');
    await getCustomers();
    await getSalesAccounts();
    await getTaxTypes();
    getBillTypes();
    getInvoiceTypes();
    await getVehicles();
  }

  void _autoFetchParties() {
    if (fromDateController.text.isNotEmpty &&
        toDateController.text.isNotEmpty &&
        selectedBillPeriod.value.isNotEmpty) {
      getParties();
    }
  }

  void onDateChanged() {
    parties.clear();
    selectedParty.value = null;
    challans.clear();
    selectedChallans.clear();
    isSelectionMode.value = false;
    selectedVehicleForFilter.value = null;
    _autoFetchParties();
  }

  void onBillPeriodChanged(String? newPeriod) {
    if (newPeriod != null) {
      selectedBillPeriod.value = newPeriod;
      parties.clear();
      selectedParty.value = null;
      challans.clear();
      selectedChallans.clear();
      isSelectionMode.value = false;
      selectedVehicleForFilter.value = null;
      _autoFetchParties();
    }
  }

  void onVehicleForFilterChanged(String? vehicleDisplay) {
    if (vehicleDisplay != null) {
      selectedVehicleForFilter.value = vehicles.firstWhere(
        (v) => '${v.regNo} - ${v.vType}' == vehicleDisplay,
      );
      getChallans();
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
      selectedChallans.clear();
      isSelectionMode.value = false;

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
      selectedVehicleForFilter.value = null;
      challans.clear();
      selectedChallans.clear();
      isSelectionMode.value = false;
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
        vehicleCode: selectedVehicleForFilter.value?.vCode ?? '',
      );

      challans.assignAll(fetchedChallans);
      selectedChallans.clear();
      isSelectionMode.value = false;

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

  void startSelection(ChallanDm challan) {
    isSelectionMode.value = true;
    if (!isChallanSelected(challan)) {
      selectedChallans.add(challan);
      selectedChallans.refresh();
    }
  }

  void toggleChallanSelection(ChallanDm challan) {
    if (!isSelectionMode.value) {
      isSelectionMode.value = true;
      selectedChallans.add(challan);
      selectedChallans.refresh();
    } else {
      if (isChallanSelected(challan)) {
        selectedChallans.removeWhere(
          (c) =>
              c.invNo == challan.invNo &&
              c.challanItemSrno == challan.challanItemSrno &&
              c.iCode == challan.iCode,
        );

        selectedChallans.refresh();

        if (selectedChallans.isEmpty) {
          isSelectionMode.value = false;
        }
      } else {
        selectedChallans.add(challan);
        selectedChallans.refresh();
      }
    }
  }

  bool isChallanSelected(ChallanDm challan) {
    return selectedChallans.any(
      (c) =>
          c.invNo == challan.invNo &&
          c.challanItemSrno == challan.challanItemSrno &&
          c.iCode == challan.iCode,
    );
  }

  void clearSelection() {
    selectedChallans.clear();
    isSelectionMode.value = false;
  }

  void selectAllChallans() {
    selectedChallans.assignAll(challans);
    isSelectionMode.value = true;
  }

  Future<void> getSalesInvoiceDetails({
    required String invNo,
    required String yearId,
  }) async {
    isLoading.value = true;

    try {
      final fetchedDetails = await InvoiceRepo.getSalesDetail(
        invNo: invNo,
        yearId: yearId,
      );

      saleInvoiceDetails.value = fetchedDetails;
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getBooks({required String dbc}) async {
    isLoading.value = true;
    try {
      final fetchedBooks = await InvoiceEntryRepo.getBooks(dbc: dbc);
      books.assignAll(fetchedBooks);
      bookDescriptions.assignAll(
        fetchedBooks.map((book) => book.description).toList(),
      );
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onBookSelected(String? bookDescription) {
    selectedBookDescription.value = bookDescription!;
    var selectedBookObj = books.firstWhere(
      (book) => book.description == bookDescription,
    );
    selectedBookCode.value = selectedBookObj.bookCode;
  }

  Future<void> getCustomers() async {
    isLoading.value = true;
    try {
      final fetchedCustomers = await InvoiceEntryRepo.getCustomers();
      customers.assignAll(fetchedCustomers);
      customerNames.assignAll(
        fetchedCustomers.map((customer) => customer.pName),
      );
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onCustomerSelected(String? customerName) {
    selectedCustomerName.value = customerName!;
    var selectedCustomerObj = customers.firstWhere(
      (customer) => customer.pName == customerName,
    );
    selectedCustomerCode.value = selectedCustomerObj.pCode;
    if (ledgerDataToSend.isNotEmpty) {
      for (var ledger in ledgerDataToSend) {
        ledger['PCODE'] = selectedCustomerCode.value;
      }
    }
  }

  Future<void> getSalesAccounts() async {
    isLoading.value = true;
    try {
      final fetchedSalesAccounts = await InvoiceEntryRepo.getCustomerAccounts();
      salesAccounts.assignAll(fetchedSalesAccounts);
      salesAccountNames.assignAll(
        fetchedSalesAccounts.map((account) => account.pName),
      );
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onSalesAccountSelected(String? salesAccountName) {
    selectedSalesAccountName.value = salesAccountName!;
    var selectedSalesAccountObj = salesAccounts.firstWhere(
      (account) => account.pName == salesAccountName,
    );
    selectedSalesAccountCode.value = selectedSalesAccountObj.pCode;
  }

  Future<void> getVehicles() async {
    isLoading.value = true;
    try {
      final fetchedVehicles = await InvoiceEntryRepo.getVehicles();
      vehicles.assignAll(fetchedVehicles);
      vehicleDisplayNames.assignAll(
        fetchedVehicles.map((v) => '${v.regNo} - ${v.vType}'),
      );
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onVehicleSelected(String? vehicleDisplay) {
    if (vehicleDisplay == null) return;
    selectedVehicleDisplayName.value = vehicleDisplay;
    var selectedVehicleObj = vehicles.firstWhere(
      (v) => '${v.regNo} - ${v.vType}' == vehicleDisplay,
    );
    selectedVehicleCode.value = selectedVehicleObj.vCode;
  }

  Future<void> getTaxTypes() async {
    isLoading.value = true;
    try {
      final fetchedTaxTypes = await InvoiceEntryRepo.getTaxTypes();
      taxTypes.assignAll(fetchedTaxTypes);
      taxTypeNames.assignAll(fetchedTaxTypes.map((taxType) => taxType.tName));
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onTaxTypeSelected(String? taxTypeName) async {
    selectedTaxTypeName.value = taxTypeName!;

    final selectedTaxTypeObj = taxTypes.firstWhere(
      (taxType) => taxType.tName == taxTypeName,
    );

    selectedTaxTypeCode.value = selectedTaxTypeObj.tCode;
    isIGSTApplicable.value = selectedTaxTypeObj.igstYn;
    isCGSTApplicable.value = selectedTaxTypeObj.cgstYn;
    isSGSTApplicable.value = selectedTaxTypeObj.sgstYn;

    if (itemsToSend.isNotEmpty) {
      updateGrossTotal();

      if (ledgerDataToSend.isNotEmpty) {
        updateLedger();
      }
    }
  }

  final List<Map<String, String>> staticBillTypes = [
    {"code": "0", "name": "None"},
    {"code": "1", "name": "Sales Taxable"},
    {"code": "2", "name": "Sales to Consumer - Taxable"},
    {"code": "3", "name": "Sales to Consumer - Exempt"},
    {"code": "4", "name": "Sales Nil Rated"},
    {"code": "5", "name": "Sales Exempt"},
    {"code": "6", "name": "Interstate Sales Taxable"},
    {"code": "7", "name": "Interstate Consumer - Taxable"},
    {"code": "8", "name": "Interstate Consumer - Exempt"},
    {"code": "9", "name": "Interstate Sales Exempt"},
    {"code": "10", "name": "Interstate Sales Nil Rated"},
    {"code": "11", "name": "Exports Taxable"},
    {"code": "12", "name": "Exports Exempt"},
    {"code": "13", "name": "Exports LUT / Bond"},
    {"code": "14", "name": "Deemed Exports Taxable"},
    {"code": "15", "name": "Deemed Exports Exempt"},
    {"code": "16", "name": "Sales to SEZ - Taxable"},
    {"code": "17", "name": "Sales to SEZ - Exempt"},
    {"code": "18", "name": "Sales to SEZ - LUT/Bond"},
    {"code": "19", "name": "Service Taxable"},
    {"code": "20", "name": "Service to Consumer"},
    {"code": "21", "name": "No Credit"},
  ];

  void getBillTypes() {
    final fetchedBillTypes = staticBillTypes
        .map(
          (billType) => BillTypeDm(
            billCode: billType['code']!,
            billName: billType['name']!,
          ),
        )
        .toList();
    billTypes.assignAll(fetchedBillTypes);
    billTypeNames.assignAll(
      fetchedBillTypes.map((billType) => billType.billName).toList(),
    );
  }

  void onBillTypeSelected(String? billTypeName) {
    selectedBillTypeName.value = billTypeName!;
    final selectedBillTypeObj = billTypes.firstWhere(
      (billType) => billType.billName == billTypeName,
    );
    selectedBillTypeCode.value = selectedBillTypeObj.billCode;
  }

  final List<Map<String, String>> staticInvoiceTypes = [
    {"code": "0", "name": "Tax Invoice"},
    {"code": "1", "name": "Retail Invoice"},
  ];

  void getInvoiceTypes() {
    final fetchedInvoiceTypes = staticInvoiceTypes
        .map(
          (invType) => InvoiceTypeDm(
            invoiceTypeCode: invType['code']!,
            invoiceTypeName: invType['name']!,
          ),
        )
        .toList();
    invoiceTypes.assignAll(fetchedInvoiceTypes);
    invoiceTypeNames.assignAll(
      fetchedInvoiceTypes.map((invType) => invType.invoiceTypeName).toList(),
    );
  }

  void onInvoiceTypeSelected(String? invoiceTypeName) {
    selectedInvoiceTypeName.value = invoiceTypeName!;
    final selectedInvoiceTypeObj = invoiceTypes.firstWhere(
      (invType) => invType.invoiceTypeName == invoiceTypeName,
    );
    selectedInvoiceTypeCode.value = selectedInvoiceTypeObj.invoiceTypeCode;
  }

  Future<void> prepareItemsFromChallans() async {
    itemsToSend.clear();
    isLoading.value = true;

    try {
      if (selectedVehicleForFilter.value != null) {
        selectedVehicleDisplayName.value =
            '${selectedVehicleForFilter.value!.regNo} - ${selectedVehicleForFilter.value!.vType}';
        selectedVehicleCode.value = selectedVehicleForFilter.value!.vCode;
      }
      for (var challan in selectedChallans) {
        ItemTaxDm? taxData = await InvoiceEntryRepo.getItemTax(
          iCode: challan.iCode,
          tCode: selectedTaxTypeCode.value,
        );

        Map<String, dynamic> itemData = {
          "SrNo": (itemsToSend.length + 1).toString(),
          "ICode": challan.iCode,
          "ItemPack": challan.itemPack,
          "CaratNos": challan.caratNos,
          "Qty": challan.qty.toStringAsFixed(3),
          "Rate": challan.rate.toStringAsFixed(2),
          "Amount": challan.amount.toStringAsFixed(2),
          "CaratQty": challan.caratQty,
          "LRValue": challan.lrValue.toStringAsFixed(2),
          "Fat": challan.fat.toStringAsFixed(3),
          "OrderSrNo": challan.orderSrNo.toString(),
          "OrderNo": challan.orderNo,
          "ChallanItemSrNo": challan.challanItemSrno.toString(),
          "ChallanNo": challan.invNo,
          "IGSTPerc": taxData?.igst ?? 0.0,
          "CGSTPerc": taxData?.cgst ?? 0.0,
          "SGSTPerc": taxData?.sgst ?? 0.0,
          "INAME": challan.iName.trim(),
        };
        itemsToSend.add(itemData);
      }

      updateGrossTotal();
      itemsToSend.refresh();
    } catch (e) {
      showErrorSnackbar(
        'Error',
        'Failed to fetch item tax details: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void deleteItem(int index) {
    itemsToSend.removeAt(index);
    _reorderSerialNumbers();
    updateGrossTotal();
    itemsToSend.refresh();
  }

  void _reorderSerialNumbers() {
    for (int i = 0; i < itemsToSend.length; i++) {
      itemsToSend[i]['SrNo'] = (i + 1).toString();
    }
  }

  void updateGrossTotal() {
    grossTotal.value = 0.0;
    totalIgst.value = 0.0;
    totalSgst.value = 0.0;
    totalCgst.value = 0.0;

    for (var item in itemsToSend) {
      double amount = double.tryParse(item["Amount"].toString()) ?? 0.00;
      double igstRate = item["IGSTPerc"] ?? 0.00;
      double cgstRate = item["CGSTPerc"] ?? 0.00;
      double sgstRate = item["SGSTPerc"] ?? 0.00;

      grossTotal.value += amount;
      totalIgst.value += ((amount * igstRate) / 100);
      totalSgst.value += ((amount * cgstRate) / 100);
      totalCgst.value += ((amount * sgstRate) / 100);
    }

    update();
  }

  Future<void> getCustomiseVoucher() async {
    isLoading.value = true;
    try {
      final fetchedCustomiseVoucher =
          await InvoiceEntryRepo.getCustomiseVoucher();
      customiseVoucher.assignAll(fetchedCustomiseVoucher);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void fillLedgerDataToSend() {
    ledgerDataToSend.clear();
    customiseVoucherAmountControllers.clear();
    customiseVoucherPercentageControllers.clear();

    ledgerDataToSend.add({
      'SRNO': 1,
      'DESC': 'Gross Total',
      'FORMULA': '',
      'VISIBLE': true,
      'PR': 'R',
      'PERC': '0',
      'AMOUNT': '0',
      'NT': 'D',
      'PCODE': selectedCustomerCode.value,
      'ADDLESS': 0,
    });

    for (var voucher in customiseVoucher.where(
      (voucher) => voucher.srNo != 15,
    )) {
      ledgerDataToSend.add({
        'SRNO': voucher.srNo + 2,
        'DESC': voucher.description,
        'FORMULA': voucher.formula,
        'VISIBLE': voucher.visible,
        'PR': voucher.pr,
        'PERC': '0',
        'AMOUNT': '0',
        'NT': voucher.nt,
        'PCODE': selectedCustomerCode.value,
        'ADDLESS': voucher.addLess,
      });
    }

    ledgerDataToSend.add({
      'SRNO': 2,
      'DESC': 'Net Total',
      'FORMULA':
          'GrossAmt - Discount + P.F. + Freight + Other + IGST + SGST + CGST + NoTaxOth - NoTaxDisc + TCS. - Round [-] + Round [+] + TCS_IT ',
      'VISIBLE': true,
      'PR': 'R',
      'PERC': '0',
      'AMOUNT': '0',
      'NT': 'C',
      'PCODE': selectedCustomerCode.value,
      'ADDLESS': 0,
    });

    for (var voucher in ledgerDataToSend) {
      var controller = TextEditingController(text: voucher['AMOUNT']);
      controller.addListener(() {
        voucher['AMOUNT'] = controller.text;
        updateLedger();
      });
      customiseVoucherAmountControllers[voucher['DESC']] = controller;
    }

    for (var voucher in ledgerDataToSend) {
      var percController = TextEditingController(text: voucher['PERC']);
      percController.addListener(() {
        voucher['PERC'] = percController.text;
        updateLedger();
      });
      customiseVoucherPercentageControllers[voucher['DESC']] = percController;
    }
  }

  void updateLedger() {
    double discountPercentage =
        double.tryParse(
          customiseVoucherPercentageControllers['Discount']?.text ?? '0',
        ) ??
        0.0;

    double discountAmount;

    if (discountPercentage > 0) {
      discountAmount = (grossTotal.value * discountPercentage) / 100;
      customiseVoucherAmountControllers['Discount']?.text = discountAmount
          .toStringAsFixed(2);
    } else {
      discountAmount =
          double.tryParse(
            customiseVoucherAmountControllers['Discount']?.text ?? '0',
          ) ??
          0.0;
      if (discountPercentage == 0.0) {
        customiseVoucherAmountControllers['Discount']?.text = '0.00';
        discountAmount = 0.0;
      }
    }

    double pf =
        double.tryParse(
          customiseVoucherAmountControllers['P.F.']?.text ?? '0',
        ) ??
        0.0;

    double freight =
        double.tryParse(
          customiseVoucherAmountControllers['Freight']?.text ?? '0',
        ) ??
        0.0;

    double other =
        double.tryParse(
          customiseVoucherAmountControllers['Other']?.text ?? '0',
        ) ??
        0.0;

    double noTaxOth =
        double.tryParse(
          customiseVoucherAmountControllers['NoTaxOth']?.text ?? '0',
        ) ??
        0.0;

    double noTaxDisc =
        double.tryParse(
          customiseVoucherAmountControllers['NoTaxDisc']?.text ?? '0',
        ) ??
        0.0;

    double tcsPercentage =
        double.tryParse(
          customiseVoucherPercentageControllers['TCS.']?.text ?? '0',
        ) ??
        0.0;

    double tcsItPercentage =
        double.tryParse(
          customiseVoucherPercentageControllers['TCS_IT']?.text ?? '0',
        ) ??
        0.0;

    String pfNT =
        ledgerDataToSend.firstWhereOrNull((v) => v['DESC'] == 'P.F.')?['NT'] ??
        'C';
    String freightNT =
        ledgerDataToSend.firstWhereOrNull(
          (v) => v['DESC'] == 'Freight',
        )?['NT'] ??
        'C';
    String otherNT =
        ledgerDataToSend.firstWhereOrNull((v) => v['DESC'] == 'Other')?['NT'] ??
        'C';
    String igstNT =
        ledgerDataToSend.firstWhereOrNull((v) => v['DESC'] == 'IGST')?['NT'] ??
        'C';
    String sgstNT =
        ledgerDataToSend.firstWhereOrNull((v) => v['DESC'] == 'SGST')?['NT'] ??
        'C';
    String cgstNT =
        ledgerDataToSend.firstWhereOrNull((v) => v['DESC'] == 'CGST')?['NT'] ??
        'C';
    String noTaxOthNT =
        ledgerDataToSend.firstWhereOrNull(
          (v) => v['DESC'] == 'NoTaxOth',
        )?['NT'] ??
        'C';
    String noTaxDiscNT =
        ledgerDataToSend.firstWhereOrNull(
          (v) => v['DESC'] == 'NoTaxDisc',
        )?['NT'] ??
        'C';
    String tcsNT =
        ledgerDataToSend.firstWhereOrNull((v) => v['DESC'] == 'TCS.')?['NT'] ??
        'C';
    String tcsItNT =
        ledgerDataToSend.firstWhereOrNull(
          (v) => v['DESC'] == 'TCS_IT',
        )?['NT'] ??
        'C';

    double totalOriginalGrossAmount = itemsToSend.fold(
      0.0,
      (sum, item) => sum + (double.tryParse(item["Amount"].toString()) ?? 0.0),
    );

    totalIgst.value = 0.0;
    totalSgst.value = 0.0;
    totalCgst.value = 0.0;

    for (var item in itemsToSend) {
      double originalAmount = double.tryParse(item["Amount"].toString()) ?? 0.0;
      double itemDiscount =
          (originalAmount / totalOriginalGrossAmount) * discountAmount;
      double discountedAmount = originalAmount - itemDiscount;
      double pfShare = (originalAmount / totalOriginalGrossAmount) * pf;
      double freightShare =
          (originalAmount / totalOriginalGrossAmount) * freight;
      double otherShare = (originalAmount / totalOriginalGrossAmount) * other;

      double amountWithCharges = discountedAmount;
      amountWithCharges += (pfNT == 'C') ? pfShare : -pfShare;
      amountWithCharges += (freightNT == 'C') ? freightShare : -freightShare;
      amountWithCharges += (otherNT == 'C') ? otherShare : -otherShare;

      double igst = double.tryParse(item["IGSTPerc"]?.toString() ?? '0') ?? 0.0;
      double cgst = double.tryParse(item["CGSTPerc"]?.toString() ?? '0') ?? 0.0;
      double sgst = double.tryParse(item["SGSTPerc"]?.toString() ?? '0') ?? 0.0;

      if (isIGSTApplicable.value) {
        totalIgst.value += ((amountWithCharges * igst) / 100);
      }
      if (isCGSTApplicable.value) {
        totalCgst.value += ((amountWithCharges * cgst) / 100);
      }
      if (isSGSTApplicable.value) {
        totalSgst.value += ((amountWithCharges * sgst) / 100);
      }
    }

    double discountedGrossTotal = grossTotal.value - discountAmount;
    double valueOfGoods = discountedGrossTotal;
    valueOfGoods += (pfNT == 'C') ? pf : -pf;
    valueOfGoods += (freightNT == 'C') ? freight : -freight;
    valueOfGoods += (otherNT == 'C') ? other : -other;

    double netTotal = valueOfGoods;
    valueOfGoodsToSend.value = valueOfGoods;

    if (customiseVoucherAmountControllers.containsKey('IGST')) {
      if (isIGSTApplicable.value) {
        customiseVoucherAmountControllers['IGST']!.text = totalIgst.value
            .toStringAsFixed(2);
        netTotal += (igstNT == 'C') ? totalIgst.value : -totalIgst.value;
      } else {
        customiseVoucherAmountControllers['IGST']!.text = '0.00';
        totalIgst.value = 0.0;
      }
    }

    if (customiseVoucherAmountControllers.containsKey('CGST')) {
      if (isCGSTApplicable.value) {
        customiseVoucherAmountControllers['CGST']!.text = totalCgst.value
            .toStringAsFixed(2);
        netTotal += (cgstNT == 'C') ? totalCgst.value : -totalCgst.value;
      } else {
        customiseVoucherAmountControllers['CGST']!.text = '0.00';
        totalCgst.value = 0.0;
      }
    }

    if (customiseVoucherAmountControllers.containsKey('SGST')) {
      if (isSGSTApplicable.value) {
        customiseVoucherAmountControllers['SGST']!.text = totalSgst.value
            .toStringAsFixed(2);
        netTotal += (sgstNT == 'C') ? totalSgst.value : -totalSgst.value;
      } else {
        customiseVoucherAmountControllers['SGST']!.text = '0.00';
        totalSgst.value = 0.0;
      }
    }

    netTotal += (noTaxOthNT == 'C') ? noTaxOth : -noTaxOth;
    netTotal += (noTaxDiscNT == 'C') ? noTaxDisc : -noTaxDisc;

    double tcs = (grossTotal.value) * tcsPercentage / 100;
    customiseVoucherAmountControllers['TCS.']?.text = tcs.toStringAsFixed(2);
    netTotal += (tcsNT == 'C') ? tcs : -tcs;

    double tcsItBase = grossTotal.value - discountAmount;
    tcsItBase += (pfNT == 'C') ? pf : -pf;
    tcsItBase += (freightNT == 'C') ? freight : -freight;
    tcsItBase += (otherNT == 'C') ? other : -other;
    tcsItBase += (igstNT == 'C') ? totalIgst.value : -totalIgst.value;
    tcsItBase += (sgstNT == 'C') ? totalSgst.value : -totalSgst.value;
    tcsItBase += (cgstNT == 'C') ? totalCgst.value : -totalCgst.value;
    tcsItBase += (noTaxOthNT == 'C') ? noTaxOth : -noTaxOth;
    tcsItBase += (noTaxDiscNT == 'C') ? noTaxDisc : -noTaxDisc;
    tcsItBase += (tcsNT == 'C') ? tcs : -tcs;

    double tcsIt = tcsItBase * tcsItPercentage / 100;
    customiseVoucherAmountControllers['TCS_IT']?.text = tcsIt.toStringAsFixed(
      2,
    );
    netTotal += (tcsItNT == 'C') ? tcsIt : -tcsIt;

    double decimalPart = netTotal - netTotal.floorToDouble();

    if (decimalPart < 0.5) {
      customiseVoucherAmountControllers['Round [-]']?.text = decimalPart
          .toStringAsFixed(2);
      customiseVoucherAmountControllers['Round [+]']?.text = 0.toStringAsFixed(
        2,
      );
      netTotal -= decimalPart;
    } else {
      customiseVoucherAmountControllers['Round [+]']?.text = (1.0 - decimalPart)
          .toStringAsFixed(2);
      customiseVoucherAmountControllers['Round [-]']?.text = 0.toStringAsFixed(
        2,
      );
      netTotal = netTotal.floorToDouble() + 1.0;
    }

    netTotalToSend.value = netTotal;
    customiseVoucherAmountControllers['Net Total']?.text = netTotal
        .toStringAsFixed(2);
  }

  List<Map<String, dynamic>> getItemsForAPI() {
    return itemsToSend.map((item) {
      return {
        "SrNo": item['SrNo'],
        "ICode": item['ICode'],
        "ItemPack": item['ItemPack'].toString(),
        "CaratNos": item['CaratNos'].toString(),
        "Qty": item['Qty'],
        "Rate": item['Rate'],
        "Amount": item['Amount'],
        "CaratQty": item['CaratQty'].toString(),
        "LRValue": item['LRValue'],
        "Fat": item['Fat'],
        "OrderSrNo": item['OrderSrNo'],
        "OrderNo": item['OrderNo'],
        "ChallanItemSrNo": item['ChallanItemSrNo'],
        "ChallanNo": item['ChallanNo'],
        "IGSTPerc": (item['IGSTPerc'] ?? 0.0).toString(),
        "SGSTPerc": (item['SGSTPerc'] ?? 0.0).toString(),
        "CGSTPerc": (item['CGSTPerc'] ?? 0.0).toString(),
      };
    }).toList();
  }

  List<Map<String, dynamic>> getLedgerForAPI() {
    return ledgerDataToSend.map((ledger) {
      int srNo = ledger["SRNO"];
      String nt = ledger["NT"];

      if (ledger["DESC"] == "Gross Total") {
        srNo = 2;
        nt = "C";
      } else if (ledger["DESC"] == "Net Total") {
        srNo = 1;
        nt = "D";
      }

      return {
        "SRNO": srNo.toString(),
        "PERC": ledger["PERC"].toString(),
        "AMOUNT": ledger["AMOUNT"].toString(),
        "NT": nt,
        "PCODE": ledger["PCODE"],
      };
    }).toList();
  }

  Future<void> loadEditModeData({
    required String invNo,
    required String yearId,
  }) async {
    isLoading.value = true;

    try {
      await getSalesInvoiceDetails(invNo: invNo, yearId: yearId);

      if (data1.isNotEmpty) {
        final data = data1.first;

        dateController.text = data.date;

        if (data.bookCode.isNotEmpty && books.isNotEmpty) {
          var book = books.firstWhereOrNull(
            (book) => book.bookCode == data.bookCode,
          );
          if (book != null) {
            selectedBookCode.value = data.bookCode;
            selectedBookDescription.value = book.description;
          }
        }

        if (data.pCode.isNotEmpty && customers.isNotEmpty) {
          var customer = customers.firstWhereOrNull(
            (customer) => customer.pCode == data.pCode,
          );
          if (customer != null) {
            selectedCustomerCode.value = data.pCode;
            selectedCustomerName.value = customer.pName;
          }
        }

        if (data.pCodeC.isNotEmpty && salesAccounts.isNotEmpty) {
          var account = salesAccounts.firstWhereOrNull(
            (sa) => sa.pCode == data.pCodeC,
          );
          if (account != null) {
            selectedSalesAccountCode.value = data.pCodeC;
            selectedSalesAccountName.value = account.pName;
          }
        }

        if (data.tCode.isNotEmpty && taxTypes.isNotEmpty) {
          var taxType = taxTypes.firstWhereOrNull(
            (tax) => tax.tCode == data.tCode,
          );
          if (taxType != null) {
            selectedTaxTypeCode.value = data.tCode;
            selectedTaxTypeName.value = taxType.tName;
            isIGSTApplicable.value = taxType.igstYn;
            isCGSTApplicable.value = taxType.cgstYn;
            isSGSTApplicable.value = taxType.sgstYn;
          }
        }

        if (data.gstBillType.toString().isNotEmpty && billTypes.isNotEmpty) {
          var billType = billTypes.firstWhereOrNull(
            (bill) => bill.billCode == data.gstBillType.toString(),
          );
          if (billType != null) {
            selectedBillTypeCode.value = data.gstBillType.toString();
            selectedBillTypeName.value = billType.billName;
          }
        }

        if (data.typeOfInvoice.isNotEmpty && invoiceTypes.isNotEmpty) {
          var invType = invoiceTypes.firstWhereOrNull(
            (invType) => invType.invoiceTypeCode == data.typeOfInvoice,
          );
          if (invType != null) {
            selectedInvoiceTypeCode.value = data.typeOfInvoice;
            selectedInvoiceTypeName.value = invType.invoiceTypeName;
          }
        }

        if (data.vehicleCode.isNotEmpty && vehicles.isNotEmpty) {
          var vehicle = vehicles.firstWhereOrNull(
            (v) => v.vCode == data.vehicleCode,
          );
          if (vehicle != null) {
            selectedVehicleCode.value = data.vehicleCode;
            selectedVehicleDisplayName.value =
                '${vehicle.regNo} - ${vehicle.vType}';
          }
        }

        remarkController.text = data.remarks;
      }

      itemsToSend.clear();
      if (data2.isNotEmpty) {
        for (var item in data2) {
          Map<String, dynamic> itemData = {
            "SrNo": item.srNo.toString(),
            "ICode": item.iCode,
            "INAME": item.iName,
            "ItemPack": item.itemPack.toString(),
            "CaratNos": item.caratNos.toString(),
            "Qty": item.qty.toString(),
            "Rate": item.rate.toStringAsFixed(2),
            "Amount": item.amount.toStringAsFixed(2),
            "CaratQty": item.caratQty.toString(),
            "LRValue": item.lrValue.toStringAsFixed(2),
            "Fat": item.fat.toStringAsFixed(2),
            "OrderSrNo": item.orderSrNo.toString(),
            "OrderNo": item.orderNo,
            "ChallanItemSrNo": item.challanItemSrNo?.toString() ?? "",
            "ChallanNo": item.challanNo,
            "IGSTPerc": item.igstPerc,
            "CGSTPerc": item.cgstPerc,
            "SGSTPerc": item.sgstPerc,
          };
          itemsToSend.add(itemData);
        }
        updateGrossTotal();
        itemsToSend.refresh();
      }

      if (data3.isNotEmpty) {
        await getCustomiseVoucher();
        fillLedgerDataToSendForEdit(data3);

        update();
        ledgerDataToSend.refresh();
      }
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void fillLedgerDataToSendForEdit(List<SaleInvoiceData3Dm> existingLedger) {
    ledgerDataToSend.clear();
    customiseVoucherAmountControllers.clear();
    customiseVoucherPercentageControllers.clear();

    Map<String, SaleInvoiceData3Dm> existingMap = {};
    for (var item in existingLedger) {
      existingMap[item.description] = item;
    }

    ledgerDataToSend.add({
      'SRNO': 1,
      'DESC': 'Gross Total',
      'FORMULA': '',
      'VISIBLE': true,
      'PR': 'R',
      'PERC': '0',
      'AMOUNT': grossTotal.value.toStringAsFixed(2),
      'NT': 'D',
      'PCODE': selectedCustomerCode.value,
      'ADDLESS': 0,
    });

    for (var voucher in customiseVoucher.where((v) => v.srNo != 15)) {
      var existingData = existingMap[voucher.description];

      ledgerDataToSend.add({
        'SRNO': voucher.srNo + 2,
        'DESC': voucher.description,
        'FORMULA': voucher.formula,
        'VISIBLE': voucher.visible,
        'PR': voucher.pr,
        'PERC': existingData?.perc.toString() ?? '0',
        'AMOUNT': existingData?.amount.toString() ?? '0',
        'NT': voucher.nt,
        'PCODE': selectedCustomerCode.value,
        'ADDLESS': voucher.addLess,
      });
    }

    ledgerDataToSend.add({
      'SRNO': 2,
      'DESC': 'Net Total',
      'FORMULA':
          'GrossAmt - Discount + P.F. + Freight + Other + IGST + SGST + CGST + NoTaxOth - NoTaxDisc + TCS. - Round [-] + Round [+] + TCS_IT ',
      'VISIBLE': true,
      'PR': 'R',
      'PERC': '0',
      'AMOUNT': '0',
      'NT': 'C',
      'PCODE': selectedCustomerCode.value,
      'ADDLESS': 0,
    });

    for (var voucher in ledgerDataToSend) {
      var controller = TextEditingController(text: voucher['AMOUNT']);
      customiseVoucherAmountControllers[voucher['DESC']] = controller;
    }

    for (var voucher in ledgerDataToSend) {
      var percController = TextEditingController(text: voucher['PERC']);
      customiseVoucherPercentageControllers[voucher['DESC']] = percController;
    }

    for (var voucher in ledgerDataToSend) {
      var controller = customiseVoucherAmountControllers[voucher['DESC']]!;

      controller.addListener(() {
        voucher['AMOUNT'] = controller.text;

        if (voucher['DESC'] == 'Discount' && controller.text.isNotEmpty) {
          double amount = double.tryParse(controller.text) ?? 0.0;
          double currentPerc =
              double.tryParse(
                customiseVoucherPercentageControllers['Discount']?.text ?? '0',
              ) ??
              0.0;

          if (amount > 0 && currentPerc > 0) {
            double calculatedAmount = (grossTotal.value * currentPerc) / 100;

            if ((amount - calculatedAmount).abs() > 0.01) {
              customiseVoucherPercentageControllers['Discount']!.text = '0';
            }
          }
        }

        updateLedger();
      });
    }

    for (var voucher in ledgerDataToSend) {
      var percController =
          customiseVoucherPercentageControllers[voucher['DESC']]!;

      percController.addListener(() {
        voucher['PERC'] = percController.text;
        updateLedger();
      });
    }

    customiseVoucherAmountControllers['Gross Total']!.text = grossTotal.value
        .toStringAsFixed(2);

    updateLedger();
  }

  Future<void> saveSalesEntry() async {
    isLoading.value = true;

    try {
      var response = await InvoiceEntryRepo.saveSalesEntry(
        salesInvo: isEditMode.value ? editInvNo.value : "",
        bookCode: selectedBookCode.value,
        date: convertToApiDateFormat(dateController.text),
        amount: netTotalToSend.value.toStringAsFixed(2),
        pCode: selectedCustomerCode.value,
        pCodeC: selectedSalesAccountCode.value,
        gstBillType: selectedBillTypeCode.value,
        remark: remarkController.text.isNotEmpty ? remarkController.text : '',
        tCode: selectedTaxTypeCode.value,
        vCode: selectedVehicleCode.value,
        typeOfInvoice: selectedInvoiceTypeCode.value,
        valueOfGoods: valueOfGoodsToSend.value.toStringAsFixed(2),
        itemData: getItemsForAPI(),
        ledgerData: getLedgerForAPI(),
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        clearAll();
        Get.back();
        if (isEditMode.value) {
          Get.back();
        }
        showSuccessSnackbar('Success', message);

        if (Get.isRegistered<InvoiceController>()) {
          final salesController = Get.find<InvoiceController>();
          await salesController.getSales();
        }
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

  void clearAll() {
    dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    selectedBookCode.value = '';
    selectedBookDescription.value = '';
    selectedCustomerName.value = '';
    selectedCustomerCode.value = '';
    selectedSalesAccountName.value = '';
    selectedSalesAccountCode.value = '';
    selectedTaxTypeName.value = '';
    selectedTaxTypeCode.value = '';
    selectedBillTypeName.value = '';
    selectedBillTypeCode.value = '';
    selectedInvoiceTypeName.value = '';
    selectedInvoiceTypeCode.value = '';
    selectedVehicleDisplayName.value = '';
    selectedVehicleCode.value = '';
    remarkController.clear();

    isIGSTApplicable.value = false;
    isCGSTApplicable.value = false;
    isSGSTApplicable.value = false;

    itemsToSend.clear();

    ledgerDataToSend.clear();
    customiseVoucherAmountControllers.clear();
    customiseVoucherPercentageControllers.clear();

    grossTotal.value = 0.0;
    totalIgst.value = 0.0;
    totalCgst.value = 0.0;
    totalSgst.value = 0.0;
    valueOfGoodsToSend.value = 0.0;
    netTotalToSend.value = 0.0;

    currentPage.value = 0;
    pageController.jumpToPage(0);

    selectedChallans.clear();
    isSelectionMode.value = false;

    isEditMode.value = false;
    editInvNo.value = '';
    editYearId.value = 0;
    saleInvoiceDetails.value = null;
  }
}
