import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/features/reports/controllers/order_report_controller.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';
import 'package:gamdiwala/widgets/app_appbar.dart';
import 'package:gamdiwala/widgets/app_button.dart';
import 'package:gamdiwala/widgets/app_date_picker_text_form_field.dart';
import 'package:gamdiwala/widgets/app_dropdown.dart';
import 'package:gamdiwala/widgets/app_text_button.dart';
import 'package:gamdiwala/widgets/app_loading_overlay.dart';
import 'package:get/get.dart';

class OrderReportScreen extends StatelessWidget {
  OrderReportScreen({super.key});

  final _controller = Get.put(OrderReportController());

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            appBar: AppAppbar(
              title: 'Order Report',
              leading: IconButton(
                onPressed: () => Get.back(),
                icon: Icon(Icons.arrow_back_ios, color: kColorDarkGrey),
              ),
              actions: [
                Padding(
                  padding: AppPaddings.custom(right: 10),
                  child: AppTextButton(
                    title: 'Clear All',
                    fontSize: 14,
                    onPressed: _controller.clearAll,
                    color: kColorPrimary,
                  ),
                ),
              ],
            ),
            body: Padding(
              padding: AppPaddings.p10,
              child: Column(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: AppDatePickerTextFormField(
                                dateController: _controller.fromDateController,
                                hintText: 'From Date',
                              ),
                            ),
                            AppSpaces.h16,
                            Expanded(
                              child: AppDatePickerTextFormField(
                                dateController: _controller.toDateController,
                                hintText: 'To Date',
                              ),
                            ),
                          ],
                        ),
                        AppSpaces.v16,
                        Obx(
                          () => AppDropdown(
                            items: _controller.partyNames,
                            hintText: 'Party',
                            selectedItem:
                                _controller.selectedPartyName.value.isNotEmpty
                                ? _controller.selectedPartyName.value
                                : null,
                            onChanged: _controller.onPartySelected,
                          ),
                        ),
                        AppSpaces.v16,
                        Obx(
                          () => AppDropdown(
                            items: _controller.itemNames,
                            hintText: 'Item',
                            selectedItem:
                                _controller.selectedItemName.value.isNotEmpty
                                ? _controller.selectedItemName.value
                                : null,
                            onChanged: _controller.onItemSelected,
                          ),
                        ),
                        AppSpaces.v16,
                        Obx(
                          () => AppDropdown(
                            items: _controller.statusList,
                            hintText: 'Status',
                            selectedItem: _controller.selectedStatus.value,
                            onChanged: _controller.onStatusSelected,
                          ),
                        ),
                        AppSpaces.v16,
                        Obx(
                          () => AppDropdown(
                            items: _controller.typeList,
                            hintText: 'Type',
                            selectedItem: _controller.selectedType.value,
                            onChanged: _controller.onTypeSelected,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpaces.v16,
                  AppButton(
                    title: 'Generate Report',
                    onPressed: _controller.getReport,
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
