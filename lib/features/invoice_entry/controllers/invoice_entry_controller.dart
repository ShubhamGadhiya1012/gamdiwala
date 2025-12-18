import 'package:flutter/material.dart';
import 'package:gamdiwala/features/invoice_entry/models/bill_type_dm.dart';
import 'package:gamdiwala/features/invoice_entry/models/book_dm.dart';
import 'package:gamdiwala/features/invoice_entry/models/customer_dm.dart';
import 'package:gamdiwala/features/invoice_entry/models/customer_voucher_dm.dart';
import 'package:gamdiwala/features/invoice_entry/models/invoice_dm.dart';
import 'package:gamdiwala/features/invoice_entry/models/invoice_party_dm.dart';
import 'package:gamdiwala/features/invoice_entry/models/invoice_type_dm.dart';
import 'package:gamdiwala/features/invoice_entry/models/tax_dm.dart';
import 'package:gamdiwala/features/invoice_entry/repos/invoice_entry_repo.dart';
import 'package:gamdiwala/features/user_settings/models/salesman_dm.dart';
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

  var selectedChallans = <InvoiceChallanDm>[].obs;
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

  var customers = <CustomerDm>[].obs;
  var customerNames = <String>[].obs;
  var selectedCustomerName = ''.obs;
  var selectedCustomerCode = ''.obs;

  var salesAccounts = <CustomerDm>[].obs;
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

  var termsController = TextEditingController();
  var daysController = TextEditingController();
  var tDueDateController = TextEditingController();
  var pdc = false.obs;

  var salesmen = <SalesmanDm>[].obs;
  var salesmanNames = <String>[].obs;
  var selectedSalesmanCode = ''.obs;
  var selectedSalesmanName = ''.obs;

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

  @override
  void onInit() {
    super.onInit();
    fromDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    toDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    daysController.addListener(_updateDueDate);
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

  void startSelection(InvoiceChallanDm challan) {
    if (isSelectionMode.value) return;

    isSelectionMode.value = true;
    selectedChallans.add(challan);
    selectedChallans.refresh();
  }

  void toggleChallanSelection(InvoiceChallanDm challan) {
    print('toggleChallanSelection called for ${challan.invNo}');
    print('isSelectionMode: ${isSelectionMode.value}');

    // If we're already in selection mode
    if (isSelectionMode.value) {
      print('In selection mode - toggling selection');
      // In selection mode, tap toggles selection
      if (isChallanSelected(challan)) {
        print('Deselecting card');
        selectedChallans.removeWhere(
          (c) => c.invNo == challan.invNo && c.itemSrno == challan.itemSrno,
        );
        // If no items selected, exit selection mode
        if (selectedChallans.isEmpty) {
          isSelectionMode.value = false;
          print('No items selected, exiting selection mode');
        }
      } else {
        print('Selecting card');
        selectedChallans.add(challan);
      }
      selectedChallans.refresh();
    } else {
      print('NOT in selection mode - entering selection mode');
      // If NOT in selection mode and user taps, enter selection mode and select this card
      isSelectionMode.value = true;
      if (!isChallanSelected(challan)) {
        selectedChallans.add(challan);
        selectedChallans.refresh();
      }
    }
    print(
      'After toggle - Selection mode: ${isSelectionMode.value}, Selected count: ${selectedChallans.length}',
    );
  }

  bool isChallanSelected(InvoiceChallanDm challan) {
    return selectedChallans.any(
      (c) => c.invNo == challan.invNo && c.itemSrno == challan.itemSrno,
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

  void _updateDueDate() {
    final text = daysController.text.trim();
    if (text.isEmpty) {
      tDueDateController.text = '';
      return;
    }

    final intDays = int.tryParse(text);
    if (intDays == null) return;

    final today = DateFormat('dd-MM-yyyy').parse(dateController.text);
    final dueDate = today.add(Duration(days: intDays));

    tDueDateController.text = DateFormat('dd-MM-yyyy').format(dueDate);
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
      final fetchedCustomers = await InvoiceEntryRepo.getCustomers(
        type: '2,4,5',
      );
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
    termsController.text = selectedCustomerObj.terms ?? '';
    daysController.text = selectedCustomerObj.crDays?.toString() ?? '';
  }

  Future<void> getSalesAccounts() async {
    isLoading.value = true;
    try {
      final fetchedSalesAccounts = await InvoiceEntryRepo.getCustomers(
        type: '6',
      );
      salesAccounts.assignAll(fetchedSalesAccounts);
      salesAccountNames.assignAll(
        fetchedSalesAccounts.map((customer) => customer.pName),
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
      (customer) => customer.pName == salesAccountName,
    );
    selectedSalesAccountCode.value = selectedSalesAccountObj.pCode;
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

  void onTaxTypeSelected(String? taxTypeName) {
    selectedTaxTypeName.value = taxTypeName!;
    final selectedTaxTypeObj = taxTypes.firstWhere(
      (taxType) => taxType.tName == taxTypeName,
    );
    selectedTaxTypeCode.value = selectedTaxTypeObj.tCode;
    isIGSTApplicable.value = selectedTaxTypeObj.igstYn;
    isCGSTApplicable.value = selectedTaxTypeObj.cgstYn;
    isSGSTApplicable.value = selectedTaxTypeObj.sgstYn;
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

  Future<void> getSalesmen() async {
    isLoading.value = true;
    try {
      final fetchedSalesmen = await InvoiceEntryRepo.getSalesmen();
      salesmen.assignAll(fetchedSalesmen);
      salesmanNames.assignAll(fetchedSalesmen.map((se) => se.seName));
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onSalesmanSelected(String? salesmanName) {
    selectedSalesmanName.value = salesmanName!;
    final selectedSalesmanObj = salesmen.firstWhere(
      (se) => se.seName == salesmanName,
    );
    selectedSalesmanCode.value = selectedSalesmanObj.seCode;
  }

  void prepareItemsFromChallans() {
    itemsToSend.clear();

    for (var challan in selectedChallans) {
      Map<String, dynamic> itemData = {
        "SrNo": (itemsToSend.length + 1).toString(),
        "OrderNo": challan.orderNo,
        "OrderYearID": "0",
        "OrdItemSrNo": challan.orderSrNo.toString(),
        "ICODE": challan.iCode,
        "INAME": challan.iName.trim(),
        "Qty": challan.qty.toString(),
        "Rate": challan.rate.toStringAsFixed(2),
        "DIS_P": "0.00",
        "DIS_A": "0.00",
        "Amount": challan.amount.toStringAsFixed(2),
        "GDCode": "",
        "GDName": "",
        "BatchNo": "",
        "IGSTPerc": 0.0,
        "CGSTPerc": 0.0,
        "SGSTPerc": 0.0,
        "HSNNo": "",
        "MFGBatchNo": "",
        "MfgDate1": "",
        "ExpDate1": "",
        "ItemPack": challan.itemPack,
        "CaratNos": challan.caratNos,
        "CaratQty": challan.caratQty,
        "VehicleCode": challan.vehicleCode,
      };
      itemsToSend.add(itemData);
    }

    updateGrossTotal();
    itemsToSend.refresh();
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

      if (discountAmount > 0) {
        customiseVoucherPercentageControllers['Discount']?.text = '0';
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

      double igst = item["IGSTPerc"] ?? 0.00;
      double cgst = item["CGSTPerc"] ?? 0.00;
      double sgst = item["SGSTPerc"] ?? 0.00;

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
        "OrderNo": item['OrderNo'],
        "OrderYearID": item['OrderYearID'],
        "OrdItemSrNo": item['OrdItemSrNo'],
        "ICODE": item['ICODE'],
        "SrNo": item['SrNo'],
        "Qty": item['Qty'],
        "Rate": item['Rate'],
        "DIS_P": item['DIS_P'],
        "DIS_A": item['DIS_A'],
        "Amount": item['Amount'],
        "GDCode": item['GDCode'],
        "BatchNo": item['BatchNo'],
        "HSNNo": item['HSNNo'],
        "IGSTPerc": item['IGSTPerc'].toString(),
        "SGSTPerc": item['SGSTPerc'].toString(),
        "CGSTPerc": item['CGSTPerc'].toString(),
        "MFGBatchNo": item['MFGBatchNo'],
        "MfgDate1": item['MfgDate1'],
        "ExpDate1": item['ExpDate1'],
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

  Future<void> saveInvoiceEntry({required String invNo}) async {
    isLoading.value = true;

    try {
      var response = await InvoiceEntryRepo.saveInvoiceEntry(
        invNo: invNo,
        bookCode: selectedBookCode.value,
        date: convertToApiDateFormat(dateController.text),
        amount: netTotalToSend.value.toString(),
        pCode: selectedCustomerCode.value,
        pdc: pdc.value,
        pCodeC: selectedSalesAccountCode.value,
        gstBillType: selectedBillTypeCode.value,
        remark: remarkController.text.isNotEmpty ? remarkController.text : '',
        terms: termsController.text.isNotEmpty ? termsController.text : '',
        days: daysController.text.isNotEmpty ? daysController.text : '0',
        tDueDate: tDueDateController.text.isNotEmpty
            ? (convertToApiDateFormat(tDueDateController.text))
            : '',
        tCode: selectedTaxTypeCode.value,
        seCode: selectedSalesmanCode.value,
        typeOfInvoice: selectedInvoiceTypeCode.value,
        valueOfGoods: valueOfGoodsToSend.value.toString(),
        itemData: getItemsForAPI(),
        ledgerData: getLedgerForAPI(),
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        showSuccessSnackbar('Success', message);
        Get.back();
        Get.back();
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

  String convertToApiDateFormat(String date) {
    try {
      final parsedDate = DateFormat('dd-MM-yyyy').parse(date);
      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } catch (e) {
      return date;
    }
  }
}
