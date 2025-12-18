import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/features/invoice_entry/controllers/invoice_entry_controller.dart';
import 'package:gamdiwala/features/invoice_entry/screens/invoice_form_screen.dart';
import 'package:gamdiwala/features/invoice_entry/widgets/invoice_challan_card.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';
import 'package:gamdiwala/widgets/app_button.dart';
import 'package:gamdiwala/widgets/app_date_picker_text_form_field.dart';
import 'package:gamdiwala/widgets/app_dropdown.dart';
import 'package:gamdiwala/widgets/app_loading_overlay.dart';
import 'package:get/get.dart';

class InvoiceEntryScreen extends StatefulWidget {
  const InvoiceEntryScreen({super.key});

  @override
  State<InvoiceEntryScreen> createState() => _InvoiceEntryScreenState();
}

class _InvoiceEntryScreenState extends State<InvoiceEntryScreen> {
  final InvoiceEntryController _controller = Get.put(InvoiceEntryController());

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: kColorWhite,
          appBar: AppBar(
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
          ),
          body: Column(
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
                      title:
                          'Next (${_controller.selectedChallans.length} selected)',
                      onPressed: () {
                        Get.to(() => const InvoiceFormScreen());
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
        Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
      ],
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
            AppSpaces.v12,
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
            AppSpaces.v12,
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
                key: ValueKey('${challan.invNo}_${challan.itemSrno}'),
                challan: challan,
                isSelected: _controller.isChallanSelected(challan),
                isSelectionMode: _controller.isSelectionMode.value,
                onTap: () {
                  if (_controller.isSelectionMode.value) {
                    _controller.toggleChallanSelection(challan);
                  }
                },
                onLongPress: () {
                  if (!_controller.isSelectionMode.value) {
                    _controller.startSelection(challan);
                  }
                },
              ),
            );
          },
        ),
      );
    });
  }
}
