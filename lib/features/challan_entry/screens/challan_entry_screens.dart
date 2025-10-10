import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/features/challan_entry/controllers/challan_entry_controller.dart';
import 'package:gamdiwala/features/challan_entry/widgets/challna_entry_card.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/dialogs/app_dialogs.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';
import 'package:gamdiwala/widgets/app_button.dart';
import 'package:gamdiwala/widgets/app_date_picker_text_form_field.dart';
import 'package:gamdiwala/widgets/app_loading_overlay.dart';
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
              _buildSearchSection(),
              Expanded(child: _buildOrdersList()),
            ],
          ),
          floatingActionButton: _selectedCardKey != null
              ? FloatingActionButton.extended(
                  onPressed: _showChallanDateDialog,
                  label: Text('Challan Entry'),
                  foregroundColor: kColorWhite,
                  icon: Icon(Icons.check),
                  backgroundColor: kColorPrimary,
                )
              : null,
        ),
        Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: AppPaddings.p16,
      decoration: BoxDecoration(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppDatePickerTextFormField(
              dateController: _controller.orderDateController,
              hintText: 'Select Order Date',
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please select date' : null,
            ),
            AppSpaces.v16,
            AppButton(
              onPressed: () {
                if (_controller.formKey.currentState!.validate()) {
                  _controller.searchOrders();
                  setState(() {
                    _expandedCardKey = null;
                    _selectedCardKey = null;
                  });
                }
              },
              title: 'Search Orders',
              titleSize: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    return Obx(() {
      if (_controller.challanOrders.isEmpty &&
          !_controller.isLoading.value &&
          _controller.orderDateController.text.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search,
                size: 80,
                color: kColorDarkGrey.withOpacity(0.3),
              ),
              AppSpaces.h24,
              Text(
                'Search Orders',
                style: TextStyles.kBoldMontserrat(
                  fontSize: FontSizes.k24FontSize,
                  color: kColorTextPrimary,
                ),
              ),
              AppSpaces.h12,
              Padding(
                padding: AppPaddings.p20,
                child: Text(
                  'Select a date and click "Search Orders" to view available orders',
                  style: TextStyles.kRegularMontserrat(
                    fontSize: FontSizes.k16FontSize,
                    color: kColorDarkGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      }

      if (_controller.challanOrders.isEmpty && !_controller.isLoading.value) {
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
                'No orders available for selected date',
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
          await _controller.searchOrders();
          setState(() {
            _expandedCardKey = null;
            _selectedCardKey = null;
          });
        },
        child: ListView.builder(
          padding: AppPaddings.p10,
          itemCount: _controller.challanOrders.length,
          itemBuilder: (context, index) {
            final order = _controller.challanOrders[index];
            final isSelected = _selectedCardKey == order.invNo;

            return ChallanOrderCard(
              key: ValueKey(order.invNo),
              order: order,
              expandedCardKey: _expandedCardKey,
              isSelected: isSelected,
              onExpanded: (String? cardKey) {
                setState(() {
                  _expandedCardKey = cardKey;
                });
              },
              onLongPress: () {
                _handleCardSelection(order.invNo);
              },
              onSelectionToggle: () {
                _handleCardSelection(order.invNo);
              },
              onTap: () {},
            );
          },
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
                  hintText: 'Select Challan Date',
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
                                _selectedCardKey =
                                    null; // ✅ Only clear on success
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
}
