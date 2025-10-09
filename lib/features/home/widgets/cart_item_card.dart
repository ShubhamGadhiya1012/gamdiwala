import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/features/home/controllers/cart_controller.dart';
import 'package:gamdiwala/features/home/models/cart_item_dm.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';
import 'package:gamdiwala/widgets/app_card.dart';
import 'package:get/get.dart';

class CartItemCard extends StatefulWidget {
  final CartItemDm cartItem;

  const CartItemCard({super.key, required this.cartItem});

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
  final CartController _controller = Get.find<CartController>();

  late TextEditingController caratController;
  late TextEditingController nosController;
  late TextEditingController qtyController;

  var caratCount = 0.0.obs;
  var nosCount = 0.0.obs;
  var qty = 0.0.obs;
  var totalAmount = 0.0.obs;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _calculateAmount();
  }

  void _initializeControllers() {
    if (widget.cartItem.usesCaratSystem) {
      caratCount.value = widget.cartItem.caratCount;
      nosCount.value = widget.cartItem.nosCount.toDouble();
      caratController = TextEditingController(
        text: widget.cartItem.caratCount.toStringAsFixed(0),
      );
      nosController = TextEditingController(
        text: widget.cartItem.nosCount.toString(),
      );
    } else {
      qty.value = widget.cartItem.qty;
      qtyController = TextEditingController(
        text: widget.cartItem.qty.toInt().toString(),
      );
    }
  }

  @override
  void dispose() {
    if (widget.cartItem.usesCaratSystem) {
      caratController.dispose();
      nosController.dispose();
    } else {
      qtyController.dispose();
    }
    super.dispose();
  }

  void _calculateAmount() {
    if (widget.cartItem.usesCaratSystem) {
      double nos = nosCount.value;
      double actualQty =
          nos * (widget.cartItem.caratQty / widget.cartItem.caratNos);
      totalAmount.value = widget.cartItem.rate * actualQty;
    } else {
      totalAmount.value = widget.cartItem.rate * qty.value;
    }
  }

  Future<void> _updateCart() async {
    if (widget.cartItem.usesCaratSystem) {
      await _controller.updateCartItem(
        cartItem: widget.cartItem,
        qty: 0,
        caratCount: caratCount.value,
        nosCount: nosCount.value,
      );
    } else {
      await _controller.updateCartItem(
        cartItem: widget.cartItem,
        qty: qty.value,
        caratCount: 0,
        nosCount: 0,
      );
    }
  }

  void _updateCaratManually(String value) {
    if (value.isEmpty) {
      caratCount.value = 0;
      nosCount.value = 0;
      nosController.text = '';
    } else {
      double carats = double.tryParse(value) ?? 0;
      caratCount.value = carats;
      nosCount.value = carats * widget.cartItem.caratNos;
      nosController.text = nosCount.value.toStringAsFixed(0);
    }
    _calculateAmount();

    if (caratCount.value > 0) {
      _updateCart();
    }
  }

  void _updateNosManually(String value) {
    if (value.isEmpty) {
      nosCount.value = 0;
      caratCount.value = 0;
      caratController.text = '';
      _calculateAmount();
    } else {
      double nos = double.tryParse(value) ?? 0;
      nosCount.value = nos;
      caratCount.value = (nos / widget.cartItem.caratNos).ceilToDouble();
      caratController.text = caratCount.value.toStringAsFixed(0);
      _calculateAmount();
      _updateCart();
    }
  }

  void _incrementQty() {
    qty.value++;
    qtyController.text = qty.value.toInt().toString();
    _calculateAmount();
    _updateCart();
  }

  void _decrementQty() {
    if (qty.value > 1) {
      qty.value--;
      qtyController.text = qty.value.toInt().toString();
      _calculateAmount();
      _updateCart();
    } else if (qty.value == 1) {
      _showDeleteConfirmation();
    }
  }

  void _showDeleteConfirmation() {
    Get.dialog(
      AlertDialog(
        backgroundColor: kColorWhite,
        title: Text(
          'Remove Item',
          style: TextStyles.kBoldMontserrat(fontSize: FontSizes.k18FontSize),
        ),
        content: Text(
          'Are you sure you want to remove this item from cart?',
          style: TextStyles.kRegularMontserrat(fontSize: FontSizes.k14FontSize),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyles.kMediumMontserrat(
                fontSize: FontSizes.k14FontSize,
                color: kColorDarkGrey,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _controller.removeFromCart(widget.cartItem);
            },
            child: Text(
              'Remove',
              style: TextStyles.kMediumMontserrat(
                fontSize: FontSizes.k14FontSize,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.cartItem.itemName,
                  style: TextStyles.kSemiBoldMontserrat(
                    fontSize: FontSizes.k16FontSize,
                    color: kColorTextPrimary,
                  ),
                ),
              ),
              InkWell(
                onTap: () => _showDeleteConfirmation(),
                child: Container(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          AppSpaces.h8,
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildInfo('Rate', '₹${widget.cartItem.rate}'),
              _buildInfo('PackQty', widget.cartItem.packQty.toString()),
              if (widget.cartItem.usesCaratSystem) ...[
                _buildInfo('CaratNos', widget.cartItem.caratNos.toString()),
                _buildInfo('CaratQty', widget.cartItem.caratQty.toString()),
              ],
              _buildInfo('FAT', widget.cartItem.fat.toStringAsFixed(3)),
              _buildInfo('LR', widget.cartItem.lr.toStringAsFixed(3)),
            ],
          ),
          AppSpaces.v12,
          if (widget.cartItem.usesCaratSystem)
            _buildCaratInputs()
          else
            _buildQtyInput(),
          AppSpaces.v10,
          _buildAmountDisplay(),
        ],
      ),
    );
  }

  Widget _buildCaratInputs() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: kColorPrimary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kColorPrimary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: caratController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: TextStyles.kBoldMontserrat(
                fontSize: FontSizes.k16FontSize,
                color: kColorTextPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Carats',
                hintStyle: TextStyles.kRegularMontserrat(
                  fontSize: FontSizes.k14FontSize,
                  color: kColorDarkGrey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: kColorPrimary),
                ),
                contentPadding: AppPaddings.combined(
                  horizontal: 12,
                  vertical: 10,
                ),
                filled: true,
                fillColor: kColorWhite,
              ),
              onChanged: _updateCaratManually,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: kColorPrimary.withOpacity(0.3),
            margin: AppPaddings.combined(horizontal: 12, vertical: 0),
          ),
          Expanded(
            child: TextField(
              controller: nosController,
              keyboardType: TextInputType.number,
              style: TextStyles.kBoldMontserrat(
                fontSize: FontSizes.k16FontSize,
                color: kColorTextPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Nos',
                hintStyle: TextStyles.kRegularMontserrat(
                  fontSize: FontSizes.k14FontSize,
                  color: kColorDarkGrey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: kColorPrimary),
                ),
                contentPadding: AppPaddings.combined(
                  horizontal: 12,
                  vertical: 10,
                ),
                filled: true,
                fillColor: kColorWhite,
              ),
              onChanged: _updateNosManually,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: kColorPrimary,
            borderRadius: BorderRadius.circular(6),
          ),
          child: IconButton(
            onPressed: _decrementQty,
            icon: Icon(Icons.remove, color: kColorWhite, size: 18),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
        ),
        Container(
          width: 80,
          margin: AppPaddings.combined(horizontal: 8, vertical: 0),
          child: TextField(
            controller: qtyController,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyles.kBoldMontserrat(
              fontSize: FontSizes.k16FontSize,
              color: kColorTextPrimary,
            ),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyles.kRegularMontserrat(
                fontSize: FontSizes.k16FontSize,
                color: kColorDarkGrey,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: kColorPrimary, width: 1),
              ),
              contentPadding: AppPaddings.combined(horizontal: 8, vertical: 8),
              filled: true,
              fillColor: kColorWhite,
            ),
            onChanged: (value) {
              double newQty = value.isEmpty ? 0 : (double.tryParse(value) ?? 0);

              if (qty.value != newQty) {
                qty.value = newQty;
                _calculateAmount();

                if (newQty > 0) {
                  _updateCart();
                }
              }
            },
          ),
        ),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: kColorPrimary,
            borderRadius: BorderRadius.circular(6),
          ),
          child: IconButton(
            onPressed: _incrementQty,
            icon: Icon(Icons.add, color: kColorWhite, size: 18),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountDisplay() {
    return Container(
      padding: AppPaddings.combined(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Amount:',
            style: TextStyles.kSemiBoldMontserrat(
              fontSize: FontSizes.k14FontSize,
              color: kColorTextPrimary,
            ),
          ),
          Obx(
            () => Text(
              '₹${totalAmount.value.toStringAsFixed(2)}',
              style: TextStyles.kBoldMontserrat(
                fontSize: FontSizes.k16FontSize,
                color: Colors.green.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyles.kRegularMontserrat(
            fontSize: FontSizes.k12FontSize,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyles.kSemiBoldMontserrat(
            fontSize: FontSizes.k14FontSize,
            color: kColorTextPrimary,
          ),
        ),
      ],
    );
  }
}
