import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/features/home/controllers/home_controller.dart';
import 'package:gamdiwala/features/home/models/item_dm.dart';
import 'package:gamdiwala/features/home/widgets/item_card.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';
import 'package:gamdiwala/widgets/app_loading_overlay.dart';
import 'package:get/get.dart';

class CartScreen extends StatelessWidget {
  CartScreen({super.key});

  final HomeController _controller = Get.find<HomeController>();

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
              'My Cart',
              style: TextStyles.kBoldMontserrat(
                fontSize: FontSizes.k20FontSize,
                color: kColorPrimary,
              ),
            ),
          ),
          body: Obx(() {
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

                        final originalItem = _controller.itemList
                            .firstWhereOrNull(
                              (item) => item.iCode == cartItem.iCode,
                            );

                        final item = ItemDm(
                          iCode: cartItem.iCode,
                          iName: cartItem.itemName,
                          unit: '',
                          rate: cartItem.rate,
                          packQty: cartItem.packQty,
                          caratNos: originalItem?.caratNos ?? 0,
                          caratQty: originalItem?.caratQty ?? 0,
                          itemPack: cartItem.itemPack,
                          fat: cartItem.fat,
                          lr: cartItem.lr,
                          description: '',
                          hsnNo: '',
                        );

                        return ItemCard(
                          key: ValueKey(cartItem.iCode),
                          item: item,
                          onTap: () {},
                        );
                      },
                    ),
                  ),
                ),
                _buildCartSummary(),
              ],
            );
          }),
        ),
        Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
      ],
    );
  }

  Widget _buildCartSummary() {
    return Obx(() {
      double totalAmount = _controller.cartItems.fold(
        0,
        (sum, item) => sum + item.amount,
      );

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
          ],
        ),
      );
    });
  }
}
