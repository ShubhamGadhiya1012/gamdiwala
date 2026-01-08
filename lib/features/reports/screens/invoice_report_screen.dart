import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/features/reports/controllers/invoice_report_controller.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';
import 'package:gamdiwala/widgets/app_appbar.dart';
import 'package:gamdiwala/widgets/app_button.dart';
import 'package:gamdiwala/widgets/app_date_picker_text_form_field.dart';
import 'package:gamdiwala/widgets/app_dropdown.dart';
import 'package:gamdiwala/widgets/app_text_button.dart';
import 'package:gamdiwala/widgets/app_loading_overlay.dart';
import 'package:get/get.dart';

class InvoiceReportScreen extends StatelessWidget {
  InvoiceReportScreen({super.key});

  final _controller = Get.put(InvoiceReportController());

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            appBar: AppAppbar(
              title: 'Invoice Report',
              leading: IconButton(
                onPressed: () => Get.back(),
                icon: Icon(Icons.arrow_back_ios, color: kColorDarkGrey),
              ),
              actions: [
                Padding(
                  padding: AppPaddings.custom(right: 10),
                  child: AppTextButton(
                    title: 'Clear All',
                    onPressed: () {
                      _controller.clearAll();
                    },
                    fontSize: FontSizes.k14FontSize,
                    color: kColorPrimary,
                  ),
                ),
              ],
            ),
            body: Padding(
              padding: AppPaddings.p10,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: AppDatePickerTextFormField(
                                  dateController:
                                      _controller.fromDateController,
                                  hintText: 'From Date',
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'Please select from date'
                                      : null,
                                  onChanged: (date) {
                                    if (date.isNotEmpty) {
                                      _controller.onFiltersChanged();
                                    }
                                  },
                                ),
                              ),
                              AppSpaces.h16,
                              Expanded(
                                child: AppDatePickerTextFormField(
                                  dateController: _controller.toDateController,
                                  hintText: 'To Date',
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'Please select to date'
                                      : null,
                                  onChanged: (date) {
                                    if (date.isNotEmpty) {
                                      _controller.onFiltersChanged();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          AppSpaces.v16,

                          Obx(
                            () => AppDropdown(
                              items: _controller.billPeriodOptions,
                              hintText: 'Bill Period',
                              onChanged: _controller.onBillPeriodSelected,
                              selectedItem:
                                  _controller.selectedBillPeriod.value,
                              validatorText: 'Please select a bill period',
                              clearButtonProps: ClearButtonProps(
                                isVisible: false,
                              ),
                            ),
                          ),
                          AppSpaces.v16,

                          Obx(
                            () => AppDropdown(
                              items: _controller.partyNames,
                              hintText: 'Party (Optional)',
                              onChanged: _controller.onPartySelected,
                              selectedItem:
                                  _controller.selectedPartyName.value.isNotEmpty
                                  ? _controller.selectedPartyName.value
                                  : null,
                              clearButtonProps: ClearButtonProps(
                                isVisible: _controller
                                    .selectedPartyCode
                                    .value
                                    .isNotEmpty,
                              ),
                            ),
                          ),
                          AppSpaces.v16,

                          Obx(
                            () => AppDropdown(
                              items: _controller.vehicleDisplayNames,
                              hintText: 'Vehicle (Optional)',
                              onChanged: _controller.onVehicleSelected,
                              selectedItem:
                                  _controller
                                      .selectedVehicleDisplayName
                                      .value
                                      .isNotEmpty
                                  ? _controller.selectedVehicleDisplayName.value
                                  : null,
                              clearButtonProps: ClearButtonProps(
                                isVisible: _controller
                                    .selectedVehicleCode
                                    .value
                                    .isNotEmpty,
                              ),
                            ),
                          ),
                          AppSpaces.v16,

                          Obx(
                            () => AppDropdown(
                              items: _controller.statusOptions,
                              hintText: 'Status',
                              onChanged: _controller.onStatusSelected,
                              selectedItem: _controller.selectedStatus.value,
                              validatorText: 'Please select a status',
                              clearButtonProps: ClearButtonProps(
                                isVisible: false,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AppSpaces.v16,
                  AppButton(
                    title: 'Generate Report',
                    onPressed: () {
                      _controller.getReport();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
      ],
    );
  }
}
