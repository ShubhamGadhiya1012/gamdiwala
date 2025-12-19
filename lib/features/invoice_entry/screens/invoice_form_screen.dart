import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/features/invoice_entry/controllers/invoice_entry_controller.dart';
import 'package:gamdiwala/features/invoice_entry/widgets/invoice_item_card.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/dialogs/app_dialogs.dart';
import 'package:gamdiwala/utils/formatters/text_input_formatters.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';
import 'package:gamdiwala/widgets/app_appbar.dart';
import 'package:gamdiwala/widgets/app_button.dart';
import 'package:gamdiwala/widgets/app_date_picker_text_form_field.dart';
import 'package:gamdiwala/widgets/app_dropdown.dart';
import 'package:gamdiwala/widgets/app_loading_overlay.dart';
import 'package:gamdiwala/widgets/app_page_indicator%20copy.dart';
import 'package:gamdiwala/widgets/app_text_form_field.dart';
import 'package:get/get.dart';

class InvoiceFormScreen extends StatefulWidget {
  const InvoiceFormScreen({super.key});

  @override
  State<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends State<InvoiceFormScreen> {
  final InvoiceEntryController _controller = Get.find<InvoiceEntryController>();

  void _handleBackNavigation() {
    if (_controller.currentPage.value == 0) {
      _showProgressLostDialog(isBack: true);
    } else if (_controller.currentPage.value == 1) {
      _goToPreviousPage();
    } else if (_controller.currentPage.value == 2) {
      _goToPreviousPage();
    }
  }

  void _handleNextNavigation() async {
    switch (_controller.currentPage.value) {
      case 0:
        if (_controller.page1FormKey.currentState!.validate()) {
          _navigateFromPage1();
        }
        break;
      case 1:
        _navigateFromPage2();
        break;
    }
  }

  void _navigateFromPage1() {
    _controller.prepareItemsFromChallans();
    _goToNextPage();
  }

  void _navigateFromPage2() async {
    if (_controller.itemsToSend.isEmpty) {
      showErrorSnackbar('Oops!', 'No items available to continue.');
      return;
    }

    await _controller.getCustomiseVoucher();
    if (_controller.customiseVoucher.isNotEmpty) {
      _controller.fillLedgerDataToSend();
      _controller.customiseVoucherAmountControllers['Gross Total']!.text =
          _controller.grossTotal.value.toStringAsFixed(2);

      if (_controller.isIGSTApplicable.value) {
        _controller.customiseVoucherAmountControllers['IGST']!.text =
            _controller.totalIgst.value.toStringAsFixed(2);
      }

      if (_controller.isSGSTApplicable.value) {
        _controller.customiseVoucherAmountControllers['SGST']!.text =
            _controller.totalSgst.value.toStringAsFixed(2);
      }

      if (_controller.isCGSTApplicable.value) {
        _controller.customiseVoucherAmountControllers['CGST']!.text =
            _controller.totalCgst.value.toStringAsFixed(2);
      }
    }
    _goToNextPage();
  }

  void _goToPreviousPage() {
    _controller.pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToNextPage() {
    _controller.pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleBackNavigation();
        return false;
      },
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Scaffold(
              appBar: AppAppbar(
                title: 'Invoice Entry Form',
                leading: IconButton(
                  onPressed: () => _handleBackNavigation(),
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: kColorPrimary,
                    size: 20,
                  ),
                ),
                actions: [
                  Obx(
                    () => _controller.currentPage.value < 2
                        ? IconButton(
                            onPressed: () => _handleNextNavigation(),
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              color: kColorPrimary,
                              size: 20,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
              body: Padding(
                padding: AppPaddings.p12,
                child: Column(
                  children: [
                    Obx(() {
                      return AppPageIndicator(
                        currentStep: _controller.currentPage.value,
                        totalSteps: 3,
                      );
                    }),
                    Expanded(
                      child: PageView(
                        controller: _controller.pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (index) {
                          _controller.currentPage.value = index;
                        },
                        children: [buildPage1(), buildPage2(), buildPage3()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
        ],
      ),
    );
  }

  Widget buildPage1() {
    return SingleChildScrollView(
      child: Form(
        key: _controller.page1FormKey,
        child: Column(
          children: [
            AppSpaces.v10,
            AppDatePickerTextFormField(
              dateController: _controller.dateController,
              hintText: 'Date *',
            ),
            AppSpaces.v10,
            Obx(
              () => AppDropdown(
                items: _controller.bookDescriptions,
                hintText: 'Book *',
                onChanged: _controller.onBookSelected,
                selectedItem:
                    _controller.selectedBookDescription.value.isNotEmpty
                    ? _controller.selectedBookDescription.value
                    : null,
                validatorText: 'Please select a book.',
              ),
            ),
            AppSpaces.v10,
            Obx(
              () => AppDropdown(
                items: _controller.customerNames,
                hintText: 'Customer *',
                onChanged: _controller.onCustomerSelected,
                selectedItem: _controller.selectedCustomerName.value.isNotEmpty
                    ? _controller.selectedCustomerName.value
                    : null,
                validatorText: 'Please select a customer.',
              ),
            ),
            AppSpaces.v10,
            Obx(
              () => AppDropdown(
                items: _controller.salesAccountNames,
                hintText: 'Customer Account *',
                onChanged: _controller.onSalesAccountSelected,
                selectedItem:
                    _controller.selectedSalesAccountName.value.isNotEmpty
                    ? _controller.selectedSalesAccountName.value
                    : null,
                validatorText: 'Please select a customer account.',
              ),
            ),
            AppSpaces.v10,
            Obx(
              () => AppDropdown(
                items: _controller.taxTypeNames,
                hintText: 'Tax Type *',
                onChanged: _controller.onTaxTypeSelected,
                selectedItem: _controller.selectedTaxTypeName.value.isNotEmpty
                    ? _controller.selectedTaxTypeName.value
                    : null,
                validatorText: 'Please select a tax type.',
              ),
            ),
            AppSpaces.v10,
            Obx(
              () => AppDropdown(
                items: _controller.billTypeNames,
                hintText: 'Bill Type *',
                onChanged: _controller.onBillTypeSelected,
                selectedItem: _controller.selectedBillTypeName.value.isNotEmpty
                    ? _controller.selectedBillTypeName.value
                    : null,
                validatorText: 'Please select a bill type.',
              ),
            ),
            AppSpaces.v10,
            Obx(
              () => AppDropdown(
                items: _controller.invoiceTypeNames,
                hintText: 'Type Of Invoice *',
                onChanged: _controller.onInvoiceTypeSelected,
                selectedItem:
                    _controller.selectedInvoiceTypeName.value.isNotEmpty
                    ? _controller.selectedInvoiceTypeName.value
                    : null,
                validatorText: 'Please select an invoice type.',
              ),
            ),
            AppSpaces.v10,
            Obx(
              () => AppDropdown(
                items: _controller.vehicleDisplayNames,
                hintText: 'Choose Vehicle *',
                onChanged: _controller.onVehicleSelected,
                selectedItem:
                    _controller.selectedVehicleDisplayName.value.isNotEmpty
                    ? _controller.selectedVehicleDisplayName.value
                    : null,
                validatorText: 'Please select a vehicle.',
              ),
            ),

            AppSpaces.v10,

            AppTextFormField(
              controller: _controller.remarkController,
              hintText: 'Remarks',
              maxLines: 4,
              inputFormatters: [UpperCaseTextInputFormatter()],
            ),
            AppSpaces.v40,
          ],
        ),
      ),
    );
  }

  Widget buildPage2() {
    return Column(
      children: [
        AppSpaces.v10,
        Expanded(
          child: Obx(() {
            if (_controller.itemsToSend.isEmpty &&
                !_controller.isLoading.value) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 60,
                      color: kColorDarkGrey,
                    ),
                    AppSpaces.v16,
                    Text(
                      'No items available.',
                      style: TextStyles.kMediumMontserrat(
                        fontSize: FontSizes.k18FontSize,
                        color: kColorDarkGrey,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: _controller.itemsToSend.length,
                itemBuilder: (context, index) {
                  final item = _controller.itemsToSend[index];
                  return InvoiceItemCard(
                    item: item,
                    onDelete: () {
                      _controller.deleteItem(index);
                    },
                  );
                },
              );
            }
          }),
        ),
      ],
    );
  }

  Widget buildPage3() {
    return SingleChildScrollView(
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AppSpaces.v10,
            Obx(() {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _controller.ledgerDataToSend.length,
                itemBuilder: (context, index) {
                  final voucher = _controller.ledgerDataToSend[index];
                  final voucherDesc = voucher['DESC'];
                  final voucherAmountController = _controller
                      .customiseVoucherAmountControllers[voucherDesc];
                  final voucherPercentageController = _controller
                      .customiseVoucherPercentageControllers[voucherDesc];

                  if (voucher['PR'] == 'P') {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: AppTextFormField(
                                controller: voucherPercentageController!,
                                hintText: '${voucher['DESC']} %',
                                onChanged: (value) {
                                  voucherPercentageController.text = value;
                                },
                                keyboardType: TextInputType.number,
                                minLines: 1,
                                maxLines: 1,
                              ),
                            ),
                            AppSpaces.h10,
                            Expanded(
                              child: AppTextFormField(
                                controller: voucherAmountController!,
                                hintText: voucher['DESC'],
                                onChanged: (value) {
                                  voucherAmountController.text = value;
                                },
                                keyboardType: TextInputType.number,
                                minLines: 1,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        AppSpaces.v10,
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        AppTextFormField(
                          controller: voucherAmountController!,
                          hintText: voucher['DESC'],
                          enabled:
                              voucher['DESC'] == 'Gross Total' ||
                                  voucher['DESC'] == 'Net Total' ||
                                  voucher['DESC'] == 'Round [-]' ||
                                  voucher['DESC'] == 'Round [+]'
                              ? false
                              : true,
                          fillColor:
                              voucher['DESC'] == 'Gross Total' ||
                                  voucher['DESC'] == 'Net Total' ||
                                  voucher['DESC'] == 'Round [-]' ||
                                  voucher['DESC'] == 'Round [+]'
                              ? kColorLightGrey
                              : kColorWhite,
                          onChanged: (value) {
                            voucherAmountController.text = value;
                          },
                          keyboardType: TextInputType.number,
                          minLines: 1,
                          maxLines: 1,
                        ),
                        AppSpaces.v10,
                      ],
                    );
                  }
                },
              );
            }),
            AppButton(
              title: 'Save',
              onPressed: () {
                _controller.saveSalesEntry();
              },
            ),
            AppSpaces.v20,
          ],
        ),
      ),
    );
  }

  void _showProgressLostDialog({required bool isBack}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kColorWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: AppPaddings.p8,
                decoration: BoxDecoration(
                  color: kColorRed.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.warning_rounded, color: kColorRed, size: 24),
              ),
              AppSpaces.h12,
              Text(
                'Progress Will Be Lost',
                style: TextStyles.kBoldMontserrat(
                  fontSize: FontSizes.k18FontSize,
                  color: kColorTextPrimary,
                ),
              ),
            ],
          ),
          content: Text(
            'Going back will lose all progress. Are you sure?',
            style: TextStyles.kMediumMontserrat(
              fontSize: FontSizes.k14FontSize,
              color: kColorDarkGrey,
            ),
          ),
          actionsPadding: AppPaddings.combined(horizontal: 16, vertical: 12),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: AppPaddings.combined(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyles.kSemiBoldMontserrat(
                        fontSize: FontSizes.k14FontSize,
                        color: kColorDarkGrey,
                      ),
                    ),
                  ),
                ),
                AppSpaces.h8,
                Expanded(
                  child: AppButton(
                    onPressed: () {
                      Get.back();
                      if (isBack) {
                        Get.back();
                      }
                    },
                    buttonColor: kColorRed,
                    title: 'Go Back',
                    titleSize: 16,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
