import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/features/home/controllers/cart_controller.dart';
import 'package:gamdiwala/features/home/widgets/cart_item_card.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';
import 'package:gamdiwala/widgets/app_button.dart';
import 'package:gamdiwala/widgets/app_date_picker_text_form_field.dart';
import 'package:gamdiwala/widgets/app_loading_overlay.dart';
import 'package:gamdiwala/widgets/app_dropdown.dart';
import 'package:gamdiwala/widgets/app_text_form_field.dart';
import 'package:get/get.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartController _controller = Get.find<CartController>();
  final TextEditingController remarkController = TextEditingController();
  bool showPlaceOrder = false;

  @override
  void dispose() {
    remarkController.dispose();
    super.dispose();
  }

  void _toggleToPlaceOrder() async {
    await _controller.loadAllOrderData();
    setState(() {
      showPlaceOrder = true;
    });
  }

  void _toggleToCart() {
    setState(() {
      showPlaceOrder = false;
    });
  }

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
              onPressed: () {
                if (showPlaceOrder) {
                  _toggleToCart();
                } else {
                  Get.back();
                }
              },
            ),
            title: Text(
              showPlaceOrder ? 'Place Order' : 'My Cart',
              style: TextStyles.kBoldMontserrat(
                fontSize: FontSizes.k20FontSize,
                color: kColorPrimary,
              ),
            ),
          ),
          body: showPlaceOrder ? _buildPlaceOrderView() : _buildCartView(),
        ),
        Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
      ],
    );
  }

  Widget _buildCartView() {
    return Obx(() {
      if (_controller.cartItems.isEmpty && !_controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 80,
                color: kColorDarkGrey.withOpacity(0.3),
              ),
              AppSpaces.h24,
              Text(
                'Your Cart is Empty',
                style: TextStyles.kBoldMontserrat(
                  fontSize: FontSizes.k24FontSize,
                  color: kColorTextPrimary,
                ),
              ),
              AppSpaces.h12,
              Text(
                'Add items to get started',
                style: TextStyles.kRegularMontserrat(
                  fontSize: FontSizes.k16FontSize,
                  color: kColorDarkGrey,
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              backgroundColor: kColorWhite,
              color: kColorPrimary,
              strokeWidth: 2.5,
              onRefresh: () async {
                await _controller.getCartItems();
              },
              child: ListView.builder(
                padding: AppPaddings.p10,
                itemCount: _controller.cartItems.length,
                itemBuilder: (context, index) {
                  final cartItem = _controller.cartItems[index];
                  return CartItemCard(
                    key: ValueKey(cartItem.iCode),
                    cartItem: cartItem,
                  );
                },
              ),
            ),
          ),
          _buildCartSummary(),
        ],
      );
    });
  }

  Widget _buildCartSummary() {
    return Obx(() {
      double totalAmount = _controller.getTotalAmount();

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
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Items:',
                  style: TextStyles.kSemiBoldMontserrat(
                    fontSize: FontSizes.k16FontSize,
                    color: kColorTextPrimary,
                  ),
                ),
                Text(
                  '${_controller.cartItems.length}',
                  style: TextStyles.kBoldMontserrat(
                    fontSize: FontSizes.k16FontSize,
                    color: kColorPrimary,
                  ),
                ),
              ],
            ),
            AppSpaces.h8,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount:',
                  style: TextStyles.kBoldMontserrat(
                    fontSize: FontSizes.k18FontSize,
                    color: kColorTextPrimary,
                  ),
                ),
                Text(
                  '₹${totalAmount.toStringAsFixed(2)}',
                  style: TextStyles.kBoldMontserrat(
                    fontSize: FontSizes.k20FontSize,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            AppSpaces.v12,
            if (_controller.cartItems.isNotEmpty)
              AppButton(
                onPressed: () => _toggleToPlaceOrder(),
                title: 'Place Order',
              ),
          ],
        ),
      );
    });
  }

  Widget _buildPlaceOrderView() {
    return Column(
      children: [
        Expanded(
          child: Form(
            key: _controller.formKey,
            child: SingleChildScrollView(
              padding: AppPaddings.p10,
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppDatePickerTextFormField(
                      dateController: _controller.orderDateController,
                      hintText: 'Order Date',
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please select order date'
                          : null,
                    ),
                    AppSpaces.v16,

                    AppDropdown(
                      items: _controller.driverNames,
                      hintText: 'Choose Driver',
                      onChanged: _controller.onDriverSelected,
                      selectedItem:
                          _controller.selectedDriverName.value.isNotEmpty
                          ? _controller.selectedDriverName.value
                          : null,
                      validatorText: 'Please select a driver',
                    ),
                    AppSpaces.v16,

                    AppDropdown(
                      items: _controller.vehicleDisplayNames,
                      hintText: 'Choose Vehicle',
                      onChanged: _controller.onVehicleSelected,
                      selectedItem:
                          _controller
                              .selectedVehicleDisplayName
                              .value
                              .isNotEmpty
                          ? _controller.selectedVehicleDisplayName.value
                          : null,
                      validatorText: 'Please select a vehicle',
                    ),
                    AppSpaces.v16,

                    AppTextFormField(
                      controller: remarkController,
                      maxLines: 3,
                      hintText: 'Enter remarks (optional)',
                    ),
                    AppSpaces.v16,

                    if (_controller.address.value != null) ...[
                      Text(
                        'Delivery Address',
                        style: TextStyles.kSemiBoldMontserrat(
                          fontSize: FontSizes.k14FontSize,
                          color: kColorTextPrimary,
                        ),
                      ),
                      AppSpaces.v8,
                      Container(
                        width: double.infinity,
                        padding: AppPaddings.p12,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _controller.address.value!.fullAddress,
                              style: TextStyles.kRegularMontserrat(
                                fontSize: FontSizes.k14FontSize,
                                color: kColorTextPrimary,
                              ),
                            ),
                            if (_controller
                                .address
                                .value!
                                .mobile
                                .isNotEmpty) ...[
                              AppSpaces.h4,
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone_android,
                                    size: 14,
                                    color: kColorDarkGrey,
                                  ),
                                  AppSpaces.h4,
                                  Text(
                                    _controller.address.value!.mobile,
                                    style: TextStyles.kMediumMontserrat(
                                      fontSize: FontSizes.k12FontSize,
                                      color: kColorDarkGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (_controller
                                .address
                                .value!
                                .phone
                                .isNotEmpty) ...[
                              AppSpaces.h4,
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone,
                                    size: 14,
                                    color: kColorDarkGrey,
                                  ),
                                  AppSpaces.h4,
                                  Text(
                                    _controller.address.value!.phone,
                                    style: TextStyles.kMediumMontserrat(
                                      fontSize: FontSizes.k12FontSize,
                                      color: kColorDarkGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      AppSpaces.v16,
                    ],
                    Text(
                      'Order Items (${_controller.cartItems.length})',
                      style: TextStyles.kSemiBoldMontserrat(
                        fontSize: FontSizes.k14FontSize,
                        color: kColorTextPrimary,
                      ),
                    ),
                    AppSpaces.v8,
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        primary: false,
                        padding: AppPaddings.p12,
                        itemCount: _controller.cartItems.length,
                        separatorBuilder: (context, index) =>
                            Divider(height: 16, color: Colors.grey.shade300),
                        itemBuilder: (context, index) {
                          final item = _controller.cartItems[index];
                          return Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.itemName,
                                      style: TextStyles.kMediumMontserrat(
                                        fontSize: FontSizes.k14FontSize,
                                        color: kColorTextPrimary,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    AppSpaces.h4,
                                    Text(
                                      item.usesCaratSystem
                                          ? 'Qty: ${item.nosCount} nos'
                                          : 'Qty: ${item.qty.toInt()}',
                                      style: TextStyles.kRegularMontserrat(
                                        fontSize: FontSizes.k12FontSize,
                                        color: kColorDarkGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AppSpaces.h8,
                              Text(
                                '₹${item.amount.toStringAsFixed(2)}',
                                style: TextStyles.kSemiBoldMontserrat(
                                  fontSize: FontSizes.k14FontSize,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    AppSpaces.v16,
                  ],
                ),
              ),
            ),
          ),
        ),

        Obx(
          () => Container(
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
            child: Column(
              children: [
                Container(
                  padding: AppPaddings.p12,
                  decoration: BoxDecoration(
                    color: kColorGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.green.shade200,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount:',
                        style: TextStyles.kBoldMontserrat(
                          fontSize: FontSizes.k16FontSize,
                          color: kColorTextPrimary,
                        ),
                      ),
                      Text(
                        '₹${_controller.getTotalAmount().toStringAsFixed(2)}',
                        style: TextStyles.kBoldMontserrat(
                          fontSize: FontSizes.k18FontSize,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpaces.v16,

                AppButton(
                  onPressed: () async {
                    if (_controller.formKey.currentState!.validate()) {
                      final result = await _controller.savePlaceOrder(
                        remark: remarkController.text.trim(),
                      );

                      if (result == true) {
                        remarkController.clear();
                        _toggleToCart();
                      }
                    }
                  },
                  title: 'Confirm Order',
                ),

                AppSpaces.h20,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
