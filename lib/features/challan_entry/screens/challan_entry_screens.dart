import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/features/challan_entry/controllers/challan_entry_controller.dart';
import 'package:gamdiwala/features/challan_entry/widgets/challna_entry_card.dart';
import 'package:gamdiwala/features/home/screens/home_screen.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/dialogs/app_dialogs.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';
import 'package:gamdiwala/widgets/app_button.dart';
import 'package:gamdiwala/widgets/app_date_picker_text_form_field.dart';
import 'package:gamdiwala/widgets/app_dropdown.dart';
import 'package:gamdiwala/widgets/app_loading_overlay.dart';
import 'package:gamdiwala/widgets/app_text_button.dart';
import 'package:get/get.dart';

class ChallanEntryScreen extends StatefulWidget {
  const ChallanEntryScreen({super.key});

  @override
  State<ChallanEntryScreen> createState() => _ChallanEntryScreenState();
}

class _ChallanEntryScreenState extends State<ChallanEntryScreen> {
  final ChallanController _controller = Get.put(ChallanController());
  String? _expandedCardKey;
  String? _selectedCardKey;

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
              _selectedCardKey != null ? '1 Selected' : 'Challan Entry',
              style: TextStyles.kBoldMontserrat(
                fontSize: FontSizes.k20FontSize,
                color: kColorPrimary,
              ),
            ),
            actions: _selectedCardKey != null
                ? [
                    IconButton(
                      icon: Icon(Icons.close, color: kColorPrimary),
                      onPressed: () {
                        setState(() {
                          _selectedCardKey = null;
                        });
                      },
                    ),
                  ]
                : null,
          ),
          body: Column(
            children: [
              _buildFilterSection(),
              Expanded(child: _buildOrdersList()),
            ],
          ),
          floatingActionButton: Obx(() {
            final isPending =
                _controller.selectedStatus.value == 'Pending Challan';

            if (_selectedCardKey != null && isPending) {
              return FloatingActionButton.extended(
                onPressed: _showChallanDateDialog,
                label: Text('Challan Entry'),
                foregroundColor: kColorWhite,
                icon: Icon(Icons.check),
                backgroundColor: kColorPrimary,
              );
            }
            return SizedBox.shrink();
          }),
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
      child: Column(
        children: [
          AppDatePickerTextFormField(
            dateController: _controller.orderDateController,
            hintText: 'Order Date',
            onChanged: (date) {
              if (date.isNotEmpty) {
                setState(() {
                  _expandedCardKey = null;
                  _selectedCardKey = null;
                });
                _controller.searchOrders();
              }
            },
          ),
          AppSpaces.v12,
          Obx(
            () => AppDropdown(
              items: _controller.parties.map((party) => party.pName).toList(),
              hintText: 'Choose Party',
              onChanged: (value) {
                setState(() {
                  _expandedCardKey = null;
                  _selectedCardKey = null;
                });
                _controller.onPartyChanged(value);
              },
              selectedItem: _controller.selectedParty.value?.pName,
              validatorText: 'Please select a party',
            ),
          ),
          AppSpaces.v12,
          Obx(
            () => AppDropdown(
              items: _controller.statusOptions,
              hintText: 'Choose Status',
              onChanged: (value) {
                setState(() {
                  _expandedCardKey = null;
                  _selectedCardKey = null;
                });
                _controller.onStatusChanged(value);
              },
              selectedItem: _controller.selectedStatus.value.isNotEmpty
                  ? _controller.selectedStatus.value
                  : null,
              validatorText: 'Please select a status',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    return Obx(() {
      final isPending = _controller.selectedStatus.value == 'Pending Challan';
      final orders = isPending
          ? _controller.pendingOrders
          : _controller.completedOrders;

      if (orders.isEmpty && !_controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 80,
                color: kColorDarkGrey.withOpacity(0.3),
              ),
              AppSpaces.h24,
              Text(
                'No Orders Found',
                style: TextStyles.kBoldMontserrat(
                  fontSize: FontSizes.k24FontSize,
                  color: kColorTextPrimary,
                ),
              ),
              AppSpaces.h12,
              Text(
                isPending
                    ? 'No pending orders for selected date'
                    : 'No completed orders for selected date',
                style: TextStyles.kRegularMontserrat(
                  fontSize: FontSizes.k16FontSize,
                  color: kColorDarkGrey,
                ),
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
          final status = isPending ? 'PENDING' : 'COMPLETE';
          await _controller.loadOrdersByStatus(status);
          setState(() {
            _expandedCardKey = null;
            _selectedCardKey = null;
          });
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification is ScrollEndNotification &&
                scrollNotification.metrics.extentAfter == 0) {
              final status = isPending ? 'PENDING' : 'COMPLETE';
              _controller.loadOrdersByStatus(status, loadMore: true);
            }
            return false;
          },
          child: ListView.builder(
            padding: AppPaddings.p10,
            itemCount: orders.length + 1,
            itemBuilder: (context, index) {
              if (index == orders.length) {
                return Obx(() {
                  return _controller.isLoadingMore.value
                      ? Padding(
                          padding: AppPaddings.p10,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: kColorPrimary,
                            ),
                          ),
                        )
                      : const SizedBox.shrink();
                });
              }

              final order = orders[index];
              final isSelected = _selectedCardKey == order.invNo;

              return ChallanOrderCard(
                key: ValueKey(order.invNo),
                order: order,
                expandedCardKey: _expandedCardKey,
                isSelected: isSelected,
                isPending: isPending,
                onExpanded: (String? cardKey) {
                  setState(() {
                    _expandedCardKey = cardKey;
                  });
                },
                onLongPress: isPending
                    ? () {
                        _handleCardSelection(order.invNo);
                      }
                    : null,
                onSelectionToggle: isPending
                    ? () {
                        _handleCardSelection(order.invNo);
                      }
                    : null,
                onTap: () {},
                onPdfDownload: !isPending
                    ? () {
                        _controller.generateChallanPdf(order.challanNo);
                      }
                    : null,
                onEdit: isPending
                    ? () {
                        _showActionConfirmDialog(
                          action: 'Edit',
                          invNo: order.invNo,
                          onConfirm: () async {
                            Get.back();
                            final success = await _controller.updateOrder(
                              order.invNo,
                              'isEdit',
                            );
                            if (success) {
                              Get.offAll(() => HomeScreen());
                            }
                          },
                        );
                      }
                    : null,
                onDelete: isPending
                    ? () {
                        _showActionConfirmDialog(
                          action: 'Delete',
                          invNo: order.invNo,
                          onConfirm: () async {
                            Get.back();
                            final success = await _controller.updateOrder(
                              order.invNo,
                              'isDelete',
                            );
                            if (success) {
                              setState(() {
                                _expandedCardKey = null;
                                _selectedCardKey = null;
                              });
                            }
                          },
                        );
                      }
                    : (!isPending && order.hasSaleBill.toUpperCase() == 'NO')
                    ? () {
                        _showActionConfirmDialog(
                          action: 'Delete',
                          invNo: order.challanNo,
                          onConfirm: () async {
                            Get.back();
                            final success = await _controller.deleteChallan(
                              order.challanNo,
                            );
                            if (success) {
                              setState(() {
                                _expandedCardKey = null;
                              });
                            }
                          },
                        );
                      }
                    : null,
              );
            },
          ),
        ),
      );
    });
  }

  void _handleCardSelection(String invNo) {
    setState(() {
      if (_selectedCardKey == invNo) {
        _selectedCardKey = null;
      } else if (_selectedCardKey != null) {
        showErrorSnackbar(
          'Single Selection Only',
          'You can only select one order at a time for challan entry',
        );
      } else {
        _selectedCardKey = invNo;
      }
    });
  }

  void _showChallanDateDialog() {
    if (_selectedCardKey == null) return;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: kColorWhite,
        child: Container(
          padding: AppPaddings.p20,
          child: Form(
            key: _controller.challanDateFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Challan Entry',
                      style: TextStyles.kBoldMontserrat(
                        fontSize: FontSizes.k18FontSize,
                        color: kColorTextPrimary,
                      ),
                    ),
                  ],
                ),
                AppSpaces.v20,
                AppDatePickerTextFormField(
                  dateController: _controller.challanDateController,
                  hintText: 'Challan Date',
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Please select challan date'
                      : null,
                ),
                AppSpaces.v24,
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        onPressed: () async {
                          if (_controller.challanDateFormKey.currentState!
                              .validate()) {
                            final success = await _controller.saveChallanEntry(
                              _selectedCardKey!,
                            );
                            if (success) {
                              setState(() {
                                _selectedCardKey = null;
                              });
                            }
                          }
                        },
                        title: 'Submit',
                        titleSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showActionConfirmDialog({
    required String action,
    required String invNo,
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: kColorWhite,
        child: Container(
          padding: AppPaddings.p24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                action == 'Edit' ? Icons.edit : Icons.delete_forever,
                size: 60,
                color: action == 'Edit' ? kColorBlue : kColorRed,
              ),
              AppSpaces.v20,
              Text(
                '$action Order',
                style: TextStyles.kBoldMontserrat(
                  fontSize: FontSizes.k20FontSize,
                  color: kColorTextPrimary,
                ),
              ),
              AppSpaces.v12,
              Text(
                'Are you sure you want to $action this order?\nAfter, You can’t undo this action.',
                style: TextStyles.kRegularMontserrat(
                  fontSize: FontSizes.k16FontSize,
                  color: kColorDarkGrey,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpaces.v8,
              Text(
                'Order No: $invNo',
                style: TextStyles.kSemiBoldMontserrat(
                  fontSize: FontSizes.k14FontSize,
                  color: kColorTextPrimary,
                ),
              ),
              AppSpaces.v24,
              Row(
                children: [
                  Expanded(
                    child: AppTextButton(
                      onPressed: () => Get.back(),
                      title: 'Cancel',
                      color: kColorDarkGrey,
                    ),
                  ),
                  AppSpaces.h16,
                  Expanded(
                    child: AppButton(
                      onPressed: onConfirm,
                      title: 'Yes, $action',
                      titleSize: 14,
                      buttonColor: action == 'Edit' ? kColorBlue : kColorRed,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
