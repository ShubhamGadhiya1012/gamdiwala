// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/features/invoice_entry/controllers/invoice_entry_controller.dart';
import 'package:gamdiwala/features/invoice_entry/widgets/invoice_challan_card.dart';
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
import 'package:gamdiwala/widgets/app_page_indicator.dart';
import 'package:gamdiwala/widgets/app_text_form_field.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class InvoiceEntryScreen extends StatefulWidget {
  const InvoiceEntryScreen({
    super.key,
    this.isEdit = false,
    this.invNo,
    this.yearId,
  });

  final bool isEdit;
  final String? invNo;
  final int? yearId;

  @override
  State<InvoiceEntryScreen> createState() => _InvoiceEntryScreenState();
}

class _InvoiceEntryScreenState extends State<InvoiceEntryScreen> {
  final InvoiceEntryController _controller = Get.put(InvoiceEntryController());
  bool _isFormMode = false;
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    if (widget.isEdit && widget.invNo != null && widget.yearId != null) {
      _isFormMode = true;
      _controller.isEditMode.value = true;
      _controller.editInvNo.value = widget.invNo!;
      _controller.editYearId.value = widget.yearId!;
    }

    _controller.dateController.text = DateFormat(
      'dd-MM-yyyy',
    ).format(DateTime.now());

    await _controller.getBooks(dbc: 'SALE');
    await _controller.getCustomers();
    await _controller.getSalesAccounts();
    await _controller.getTaxTypes();
    _controller.getBillTypes();
    _controller.getInvoiceTypes();
    await _controller.getVehicles();

    if (widget.isEdit && widget.invNo != null && widget.yearId != null) {
      await _controller.loadEditModeData(
        invNo: widget.invNo!,
        yearId: widget.yearId.toString(),
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _navigateToForm() {
    setState(() {
      _isFormMode = true;
    });
  }

  void _handleBackNavigation() {
    if (!_isFormMode) {
      Get.back();
    } else {
      if (_controller.currentPage.value == 0) {
        _showProgressLostDialog(isBack: true);
      } else {
        _goToPreviousPage();
      }
    }
  }

  void _handleNextNavigation() async {
    switch (_controller.currentPage.value) {
      case 0:
        if (_controller.page1FormKey.currentState!.validate()) {
          if (_controller.isEditMode.value) {
            _goToNextPage();
          } else {
            _navigateFromPage1();
          }
        }
        break;
      case 1:
        if (_controller.isEditMode.value) {
          _goToNextPage();
        } else {
          _navigateFromPage2();
        }
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

    if (_controller.ledgerDataToSend.isEmpty) {
      if (_controller.isEditMode.value) {
        if (_controller.data3.isNotEmpty) {
          _controller.fillLedgerDataToSendForEdit(_controller.data3);
        }
      } else {
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
      }
    } else {
      _controller.updateLedger();
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
          Scaffold(
            backgroundColor: kColorWhite,
            appBar: _isFormMode ? _buildFormAppBar() : _buildListAppBar(),
            body: _isFormMode ? _buildFormBody() : _buildListBody(),
          ),
          Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildListAppBar() {
    return AppBar(
      backgroundColor: kColorWhite,
      elevation: 1,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: kColorPrimary),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'Invoice Entry',
        style: TextStyles.kBoldMontserrat(
          fontSize: FontSizes.k20FontSize,
          color: kColorPrimary,
        ),
      ),
      actions: [
        Obx(() {
          if (_controller.isSelectionMode.value) {
            return Row(
              children: [
                TextButton(
                  onPressed: _controller.selectAllChallans,
                  child: Text(
                    'Select All',
                    style: TextStyles.kMediumMontserrat(
                      fontSize: FontSizes.k14FontSize,
                      color: kColorPrimary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _controller.clearSelection,
                  child: Text(
                    'Clear',
                    style: TextStyles.kMediumMontserrat(
                      fontSize: FontSizes.k14FontSize,
                      color: kColorRed,
                    ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  PreferredSizeWidget _buildFormAppBar() {
    return AppAppbar(
      title: 'Invoice Entry Form',
      leading: IconButton(
        onPressed: () => _handleBackNavigation(),
        icon: Icon(Icons.arrow_back_ios, color: kColorPrimary, size: 20),
      ),
    );
  }

  Widget _buildListBody() {
    return Column(
      children: [
        _buildFilterSection(),
        Expanded(child: _buildChallansList()),
        Obx(() {
          if (_controller.selectedChallans.isNotEmpty) {
            return Container(
              padding: AppPaddings.p16,
              decoration: BoxDecoration(
                color: kColorWhite,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: AppButton(
                title: 'Next (${_controller.selectedChallans.length} selected)',
                onPressed: () {
                  if (_controller.selectedVehicleForFilter.value != null) {
                    _controller.selectedVehicleDisplayName.value =
                        '${_controller.selectedVehicleForFilter.value!.regNo} - ${_controller.selectedVehicleForFilter.value!.vType}';
                    _controller.selectedVehicleCode.value =
                        _controller.selectedVehicleForFilter.value!.vCode;
                  }
                  if (_controller.selectedParty.value != null) {
                    _controller.selectedCustomerName.value =
                        _controller.selectedParty.value!.pName;
                    _controller.selectedCustomerCode.value =
                        _controller.selectedParty.value!.pCode;
                  }
                  _navigateToForm();
                },
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildFormBody() {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Padding(
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
                children: [_buildPage1(), _buildPage2(), _buildPage3()],
              ),
            ),
            Obx(() {
              if (_controller.currentPage.value < 2) {
                return AppButton(
                  title: 'Next',
                  onPressed: () => _handleNextNavigation(),
                );
              }
              return const SizedBox.shrink();
            }),
            AppSpaces.v14,
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: AppPaddings.p16,
      decoration: BoxDecoration(
        color: kColorWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _controller.formKey,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: AppDatePickerTextFormField(
                    dateController: _controller.fromDateController,
                    hintText: 'From Date',
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Please select from date'
                        : null,
                    onChanged: (date) {
                      if (date.isNotEmpty) {
                        setState(() {});
                        _controller.onDateChanged();
                      }
                    },
                  ),
                ),
                AppSpaces.h12,
                Expanded(
                  child: AppDatePickerTextFormField(
                    dateController: _controller.toDateController,
                    hintText: 'To Date',
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Please select to date' : null,
                    onChanged: (date) {
                      if (date.isNotEmpty) {
                        setState(() {});
                        _controller.onDateChanged();
                      }
                    },
                  ),
                ),
              ],
            ),
            AppSpaces.v10,
            Obx(
              () => AppDropdown(
                items: _controller.billPeriodOptions,
                hintText: 'Choose Bill Period',
                onChanged: (value) {
                  setState(() {});
                  _controller.onBillPeriodChanged(value);
                },
                selectedItem: _controller.selectedBillPeriod.value.isNotEmpty
                    ? _controller.selectedBillPeriod.value
                    : null,
              ),
            ),
            AppSpaces.v10,
            Obx(
              () => AppDropdown(
                items: _controller.parties.map((party) => party.pName).toList(),
                hintText: 'Choose Party',
                onChanged: (value) {
                  setState(() {});
                  _controller.onPartyChanged(value);
                },
                selectedItem: _controller.selectedParty.value?.pName,
              ),
            ),
            AppSpaces.v10,
            Obx(
              () => AppDropdown(
                items: _controller.vehicleDisplayNames,
                hintText: 'Choose Vehicle',
                onChanged: (value) {
                  setState(() {});
                  _controller.onVehicleForFilterChanged(value);
                },
                selectedItem: _controller.selectedVehicleForFilter.value != null
                    ? '${_controller.selectedVehicleForFilter.value!.regNo} - ${_controller.selectedVehicleForFilter.value!.vType}'
                    : null,
              ),
            ),
            AppSpaces.v8,
            Container(
              padding: AppPaddings.combined(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: kColorPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: kColorPrimary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: kColorPrimary),
                  AppSpaces.h8,
                  Expanded(
                    child: Text(
                      'Long press on card to select multiple items',
                      style: TextStyles.kMediumMontserrat(
                        fontSize: FontSizes.k12FontSize,
                        color: kColorPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallansList() {
    return Obx(() {
      final challans = _controller.challans;

      if (challans.isEmpty && !_controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 80,
                color: kColorDarkGrey.withOpacity(0.3),
              ),
              AppSpaces.h24,
              Text(
                'No Challans Found',
                style: TextStyles.kBoldMontserrat(
                  fontSize: FontSizes.k24FontSize,
                  color: kColorTextPrimary,
                ),
              ),
              AppSpaces.h12,
              Text(
                'Select dates, bill period and party to view challans',
                style: TextStyles.kRegularMontserrat(
                  fontSize: FontSizes.k16FontSize,
                  color: kColorDarkGrey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        backgroundColor: kColorWhite,
        color: kColorPrimary,
        strokeWidth: 2.5,
        onRefresh: () async {
          if (_controller.selectedParty.value != null) {
            await _controller.getChallans();
          }
        },
        child: ListView.builder(
          padding: AppPaddings.p10,
          itemCount: challans.length,
          itemBuilder: (context, index) {
            final challan = challans[index];

            return Obx(
              () => InvoiceChallanCard(
                key: ValueKey('${challan.invNo}_${challan.challanItemSrno}'),
                challan: challan,
                isSelected: _controller.isChallanSelected(challan),
                isSelectionMode: _controller.isSelectionMode.value,
                onTap: () {
                  _controller.toggleChallanSelection(challan);
                },
                onLongPress: () {
                  _controller.startSelection(challan);
                },
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildPage1() {
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
                fillColor: kColorLightGrey,
                enabled: false,
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
                fillColor: kColorLightGrey,
                enabled: false,
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

  Widget _buildPage2() {
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

  Widget _buildPage3() {
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
                    onPressed: () => Navigator.of(context).pop(),
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
                      Navigator.of(context).pop();
                      _controller.clearAll();

                      Get.back();
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
