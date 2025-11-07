import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/features/home/controllers/cart_controller.dart';
import 'package:gamdiwala/features/home/models/cart_item_dm.dart';
import 'package:gamdiwala/features/home/models/item_dm.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';
import 'package:gamdiwala/widgets/app_button.dart';
import 'package:gamdiwala/widgets/app_card.dart';
import 'package:gamdiwala/widgets/app_text_form_field.dart';
import 'package:get/get.dart';

class HomeItemCard extends StatefulWidget {
  final ItemDm item;
  final VoidCallback? onTap;

  const HomeItemCard({super.key, required this.item, this.onTap});

  @override
  State<HomeItemCard> createState() => _HomeItemCardState();
}

class _HomeItemCardState extends State<HomeItemCard> {
  final CartController _cartController = Get.find<CartController>();
  Worker? _cartWorker;
  bool _isDisposed = false;

  late TextEditingController caratController;
  late TextEditingController nosController;
  TextEditingController? qtyController;

  var caratCount = 0.0.obs;
  var nosCount = 0.0.obs;
  var qty = 0.0.obs;
  var totalAmount = 0.0.obs;
  var isNosManuallySet = false.obs;
  @override
  void initState() {
    super.initState();
    _initializeControllers();

    _cartWorker = ever(_cartController.cartItems, (_) {
      if (!_isDisposed) {
        _syncWithCart();
      }
    });
  }

  void _syncWithCart() {
    if (_isDisposed) return;

    CartItemDm? cartItem = _getCartItem();

    if (cartItem != null) {
      if (widget.item.usesCaratSystem) {
        if (caratCount.value != cartItem.caratCount) {
          caratCount.value = cartItem.caratCount;
          if (mounted &&
              caratController.text != cartItem.caratCount.toStringAsFixed(0)) {
            caratController.text = cartItem.caratCount.toStringAsFixed(0);
          }
        }
        if (nosCount.value != cartItem.nosCount.toDouble()) {
          nosCount.value = cartItem.nosCount.toDouble();
          if (mounted && nosController.text != cartItem.nosCount.toString()) {
            nosController.text = cartItem.nosCount.toString();
          }
        }
      } else {
        if (qty.value != cartItem.qty) {
          qty.value = cartItem.qty;
          if (mounted &&
              qtyController != null &&
              qtyController!.text != cartItem.qty.toInt().toString()) {
            qtyController!.text = cartItem.qty.toInt().toString();
          }
        }
      }
      if (mounted) {
        _calculateAmount();
      }
    } else {
      if (widget.item.usesCaratSystem) {
        caratCount.value = 0;
        nosCount.value = 0;
        isNosManuallySet.value = false;
        if (mounted) {
          caratController.clear();
          nosController.clear();
        }
      } else {
        qty.value = 0;
        if (mounted && qtyController != null) {
          qtyController!.clear();
        }
      }
      if (mounted) {
        _calculateAmount();
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _cartWorker?.dispose();
    caratController.dispose();
    nosController.dispose();
    qtyController?.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    CartItemDm? cartItem = _getCartItem();

    if (widget.item.usesCaratSystem) {
      if (cartItem != null) {
        caratCount.value = cartItem.caratCount;
        nosCount.value = cartItem.nosCount.toDouble();
      }
      caratController = TextEditingController(
        text: caratCount.value > 0 ? caratCount.value.toStringAsFixed(0) : '',
      );
      nosController = TextEditingController(
        text: nosCount.value > 0 ? nosCount.value.toStringAsFixed(0) : '',
      );
    } else {
      if (cartItem != null) {
        qty.value = cartItem.qty;
      }
      qtyController = TextEditingController(
        text: qty.value > 0 ? qty.value.toInt().toString() : '',
      );

      caratController = TextEditingController();
      nosController = TextEditingController();
    }
    _calculateAmount();
  }

  CartItemDm? _getCartItem() {
    try {
      return _cartController.cartItems.firstWhere(
        (cartItem) => cartItem.iCode == widget.item.iCode,
      );
    } catch (e) {
      return null;
    }
  }

  void _calculateAmount() {
    if (widget.item.usesCaratSystem) {
      totalAmount.value = nosCount.value * widget.item.rate;
    } else {
      totalAmount.value = widget.item.rate * qty.value;
    }
  }

  Future<void> _addOrUpdateCart() async {
    CartItemDm? existingCartItem = _getCartItem();

    if (widget.item.usesCaratSystem) {
      if (existingCartItem != null) {
        await _cartController.updateCartItem(
          cartItem: existingCartItem,
          qty: 0,
          caratCount: caratCount.value,
          nosCount: nosCount.value,
        );
      } else {
        await _cartController.addToCart(
          item: widget.item,
          qty: 0,
          caratCount: caratCount.value,
          nosCount: nosCount.value,
        );
      }
    } else {
      if (existingCartItem != null) {
        await _cartController.updateCartItem(
          cartItem: existingCartItem,
          qty: qty.value,
          caratCount: 0,
          nosCount: 0,
        );
      } else {
        await _cartController.addToCart(
          item: widget.item,
          qty: qty.value,
          caratCount: 0,
          nosCount: 0,
        );
      }
    }
  }

  void _updateCaratManually(String value) {
    if (value.isEmpty) {
      caratCount.value = 0;
    } else {
      double carats = double.tryParse(value) ?? 0;
      if (carats > 0) {
        caratCount.value = carats;

        _addOrUpdateCart();
      }
    }
    _calculateAmount();
  }

  void _updateNosManually(String value) {
    if (value.isEmpty) {
      nosCount.value = 0;
      isNosManuallySet.value = false;
    } else {
      double nos = double.tryParse(value) ?? 0;
      if (nos > 0) {
        nosCount.value = nos;
        isNosManuallySet.value = true;
        caratCount.value = nos / widget.item.caratNos;

        if (caratController.text != caratCount.value.toStringAsFixed(0)) {
          caratController.text = caratCount.value.toStringAsFixed(0);
        }
        _addOrUpdateCart();
      }
    }
    _calculateAmount();
  }

  void _incrementQty() {
    qty.value++;
    if (qtyController != null) {
      qtyController!.text = qty.value.toInt().toString();
    }
    _calculateAmount();
    _addOrUpdateCart();
  }

  void _decrementQty() {
    if (qty.value > 1) {
      qty.value--;
      if (qtyController != null) {
        qtyController!.text = qty.value.toInt().toString();
      }
      _calculateAmount();
      _addOrUpdateCart();
    } else if (qty.value == 1) {
      _showDeleteConfirmation();
    }
  }

  void _showDeleteConfirmation() {
    CartItemDm? cartItem = _getCartItem();
    if (cartItem == null) return;

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
              await _cartController.removeFromCart(cartItem);

              if (widget.item.usesCaratSystem) {
                caratCount.value = 0;
                nosCount.value = 0;
                isNosManuallySet.value = false;
                caratController.text = '';
                nosController.text = '';
              } else {
                qty.value = 0;
                qtyController?.text = '';
              }
              _calculateAmount();
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
    return Obx(() {
      _cartController.cartItems.length;

      CartItemDm? cartItem = _getCartItem();
      bool isInCart = cartItem != null;

      return AppCard(
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.item.iName,
              style: TextStyles.kSemiBoldMontserrat(
                fontSize: FontSizes.k16FontSize,
                color: kColorTextPrimary,
              ),
            ),
            AppSpaces.h8,
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildInfo(
                  'Unit',
                  widget.item.unit.isEmpty ? 'N/A' : widget.item.unit,
                  Icons.straighten_outlined,
                ),
                _buildInfo(
                  'Rate',
                  '₹${widget.item.rate}',
                  Icons.currency_rupee,
                ),
                _buildInfo(
                  'PackQty',
                  widget.item.packQty.toString(),
                  Icons.inventory_2_outlined,
                ),
                if (widget.item.usesCaratSystem) ...[
                  _buildInfo(
                    'CaratNos',
                    widget.item.caratNos.toString(),
                    Icons.diamond_outlined,
                  ),
                  _buildInfo(
                    'CaratQty',
                    widget.item.caratQty.toString(),
                    Icons.scale_outlined,
                  ),
                ],
                _buildInfo(
                  'ItemPack',
                  widget.item.itemPack.toString(),
                  Icons.widgets_outlined,
                ),
                _buildInfo(
                  'FAT',
                  widget.item.fat.toStringAsFixed(3),
                  Icons.water_drop_outlined,
                ),
                _buildInfo(
                  'LR',
                  widget.item.lr.toStringAsFixed(3),
                  Icons.local_shipping_outlined,
                ),
              ],
            ),
            AppSpaces.v12,
            if (widget.item.usesCaratSystem)
              isInCart ? _buildCaratInputs() : _buildAddCaratButtons()
            else
              isInCart ? _buildQtyInput() : _buildAddToCartButton(),
            if (isInCart) ...[AppSpaces.v10, _buildAmountDisplay()],
          ],
        ),
      );
    });
  }

  Widget _buildAddCaratButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              final TextEditingController inputController =
                  TextEditingController();

              await Get.dialog(
                AlertDialog(
                  backgroundColor: kColorWhite,
                  title: Text(
                    'Enter Carat',
                    style: TextStyles.kBoldMontserrat(
                      fontSize: FontSizes.k18FontSize,
                    ),
                  ),
                  content: AppTextFormField(
                    controller: inputController,
                    keyboardType: TextInputType.number,
                    hintText: 'Enter Carat value',
                  ),
                  actions: [
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Get.back(),
                            child: Text(
                              'Cancel',
                              style: TextStyles.kMediumMontserrat(
                                fontSize: FontSizes.k14FontSize,
                                color: kColorDarkGrey,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: AppButton(
                            onPressed: () {
                              Get.back(result: inputController.text.trim());
                            },
                            title: 'Add',
                            titleSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).then((value) {
                if (value != null && value.isNotEmpty) {
                  double enteredCarat = double.tryParse(value) ?? 0;
                  if (enteredCarat > 0) {
                    caratCount.value = enteredCarat;
                    isNosManuallySet.value = false;
                    nosCount.value = enteredCarat * widget.item.caratNos;
                    caratController.text = enteredCarat.toStringAsFixed(0);
                    nosController.text = nosCount.value.toStringAsFixed(0);
                    _calculateAmount();
                    _addOrUpdateCart();
                  }
                }
              });
            },

            style: ElevatedButton.styleFrom(
              backgroundColor: kColorPrimary,
              foregroundColor: kColorWhite,
              padding: EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(60),
              ),
            ),
            child: Text(
              'Add Carat',
              style: TextStyles.kSemiBoldMontserrat(
                fontSize: FontSizes.k14FontSize,
                color: kColorWhite,
              ),
            ),
          ),
        ),
        AppSpaces.h12,
        Expanded(
          child: OutlinedButton(
            onPressed: () async {
              final TextEditingController inputController =
                  TextEditingController();

              await Get.dialog(
                AlertDialog(
                  backgroundColor: kColorWhite,
                  title: Text(
                    'Enter Nos',
                    style: TextStyles.kBoldMontserrat(
                      fontSize: FontSizes.k18FontSize,
                    ),
                  ),
                  content: AppTextFormField(
                    controller: inputController,
                    keyboardType: TextInputType.number,
                    hintText: 'Enter Nos value',
                  ),
                  actions: [
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Get.back(),
                            child: Text(
                              'Cancel',
                              style: TextStyles.kMediumMontserrat(
                                fontSize: FontSizes.k14FontSize,
                                color: kColorDarkGrey,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: AppButton(
                            onPressed: () {
                              Get.back(result: inputController.text.trim());
                            },
                            titleSize: 14,
                            title: 'Add',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).then((value) {
                if (value != null && value.isNotEmpty) {
                  double enteredNos = double.tryParse(value) ?? 0;
                  if (enteredNos > 0) {
                    nosCount.value = enteredNos;
                    isNosManuallySet.value = true;

                    caratCount.value = (enteredNos / widget.item.caratNos)
                        .ceilToDouble();
                    nosController.text = enteredNos.toStringAsFixed(0);
                    caratController.text = caratCount.value.toStringAsFixed(0);
                    _calculateAmount();
                    _addOrUpdateCart();
                  }
                }
              });
            },

            style: OutlinedButton.styleFrom(
              foregroundColor: kColorPrimary,
              side: BorderSide(color: kColorPrimary),
              padding: EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(60),
              ),
            ),
            child: Text(
              'Add Nos',
              style: TextStyles.kSemiBoldMontserrat(
                fontSize: FontSizes.k14FontSize,
                color: kColorPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddToCartButton() {
    return ElevatedButton(
      onPressed: () {
        qty.value = 1;
        if (qtyController != null) {
          qtyController!.text = '1';
        }
        _calculateAmount();
        _addOrUpdateCart();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: kColorPrimary,
        foregroundColor: kColorWhite,
        padding: EdgeInsets.symmetric(vertical: 10),
        minimumSize: Size(double.infinity, 36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
      ),
      child: Text(
        'Add to Cart',
        style: TextStyles.kSemiBoldMontserrat(
          fontSize: FontSizes.k14FontSize,
          color: kColorWhite,
        ),
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
            child: AppTextFormField(
              controller: caratController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: _updateCaratManually,
              hintText: 'Carat',
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: kColorPrimary.withOpacity(0.3),
            margin: AppPaddings.combined(horizontal: 12, vertical: 0),
          ),
          Expanded(
            child: AppTextFormField(
              controller: nosController,
              keyboardType: TextInputType.number,
              onChanged: _updateNosManually,
              hintText: 'Nos',
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
                  _addOrUpdateCart();
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

  Widget _buildInfo(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: kColorPrimary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: kColorPrimary.withOpacity(0.1), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: kColorPrimary),
          SizedBox(width: 6),
          Text(
            '$title: ',
            style: TextStyles.kRegularMontserrat(
              fontSize: FontSizes.k12FontSize,
              color: kColorDarkGrey,
            ),
          ),
          Text(
            value,
            style: TextStyles.kSemiBoldMontserrat(
              fontSize: FontSizes.k12FontSize,
              color: kColorTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
