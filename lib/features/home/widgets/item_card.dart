import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/features/home/controllers/home_controller.dart';
import 'package:gamdiwala/features/home/models/item_dm.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';
import 'package:gamdiwala/widgets/app_button.dart';
import 'package:gamdiwala/widgets/app_card.dart';
import 'package:gamdiwala/widgets/app_text_button.dart';
import 'package:gamdiwala/widgets/app_text_form_field.dart';
import 'package:get/get.dart';

class ItemCard extends StatefulWidget {
  final ItemDm item;
  final VoidCallback? onTap;

  const ItemCard({super.key, required this.item, this.onTap});

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  final HomeController _controller = Get.find<HomeController>();

  var showInputs = false.obs;
  var caratCount = 0.0.obs;
  var totalNos = 0.0.obs;
  var caratController = TextEditingController();
  var nosController = TextEditingController();
  var qtyController = TextEditingController();
  var totalAmount = 0.0.obs;

  @override
  void dispose() {
    caratController.dispose();
    nosController.dispose();
    qtyController.dispose();
    super.dispose();
  }

  void _calculateAmount() {
    if (widget.item.caratNos > 0) {
      double nos = totalNos.value;
      double qty = nos * (widget.item.caratQty / widget.item.caratNos);
      totalAmount.value = widget.item.rate * qty;
    } else {
      double qty = double.tryParse(qtyController.text) ?? 0;
      totalAmount.value = widget.item.rate * qty;
    }
  }

  Future<void> _saveCart() async {
    try {
      double qty = 0;
      double caratQtyValue = 0;
      double caratNosValue = 0;

      if (widget.item.caratNos > 0) {
        caratQtyValue = caratCount.value;
        caratNosValue = totalNos.value;
        qty = 0;
      } else {
        qty = double.tryParse(qtyController.text) ?? 0;
        caratQtyValue = 0;
        caratNosValue = 0;
      }

      await _controller.saveCartItem(
        item: widget.item,
        qty: qty,
        caratQty: caratQtyValue,
        caratNos: caratNosValue,
      );
    } catch (e) {}
  }

  void _showCaratDialog() {
    final dialogController = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: kColorWhite,
        title: Text(
          'Add Carat',
          style: TextStyles.kBoldMontserrat(fontSize: FontSizes.k18FontSize),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How many carats do you want to add?',
              style: TextStyles.kRegularMontserrat(
                fontSize: FontSizes.k14FontSize,
              ),
            ),
            AppSpaces.v16,
            AppTextFormField(
              controller: dialogController,
              hintText: 'Enter carat count',
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              showClearIcon: true,
            ),
          ],
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
          AppButton(
            title: 'Save',
            buttonHeight: 36,
            buttonWidth: 80,
            titleSize: FontSizes.k14FontSize,
            onPressed: () async {
              double carats = double.tryParse(dialogController.text) ?? 0;
              if (carats > 0) {
                caratCount.value = carats;
                totalNos.value = carats * widget.item.caratNos;
                caratController.text = carats.toStringAsFixed(0);
                nosController.text = totalNos.value.toStringAsFixed(0);
                showInputs.value = true;
                _calculateAmount();
                Get.back();
                await _saveCart();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showNosDialog() {
    final dialogController = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: kColorWhite,
        title: Text(
          'Add Nos',
          style: TextStyles.kBoldMontserrat(fontSize: FontSizes.k18FontSize),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How many packets do you want?',
              style: TextStyles.kRegularMontserrat(
                fontSize: FontSizes.k14FontSize,
              ),
            ),
            AppSpaces.v16,
            AppTextFormField(
              controller: dialogController,
              hintText: 'Enter number of packets',
              keyboardType: TextInputType.number,
              showClearIcon: true,
            ),
          ],
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
          AppButton(
            title: 'Save',
            buttonHeight: 36,
            buttonWidth: 80,
            titleSize: FontSizes.k14FontSize,
            onPressed: () async {
              double nos = double.tryParse(dialogController.text) ?? 0;
              if (nos > 0) {
                totalNos.value = nos;
                caratCount.value = (nos / widget.item.caratNos).ceilToDouble();
                caratController.text = caratCount.value.toStringAsFixed(0);
                nosController.text = nos.toStringAsFixed(0);
                showInputs.value = true;
                _calculateAmount();
                Get.back();
                await _saveCart();
              }
            },
          ),
        ],
      ),
    );
  }

  void _updateCaratManually(String value) {
    double carats = double.tryParse(value) ?? 0;
    caratCount.value = carats;
    _calculateAmount();
    _saveCart();
  }

  void _updateNosManually(String value) {
    double nos = double.tryParse(value) ?? 0;
    totalNos.value = nos;
    _calculateAmount();
    _saveCart();
  }

  void _clearInputs() {
    showInputs.value = false;
    caratCount.value = 0;
    totalNos.value = 0;
    nosController.clear();
    caratController.clear();
    totalAmount.value = 0;
  }

  void _incrementQty() {
    double currentQty = double.tryParse(qtyController.text) ?? 0;
    int newQty = currentQty.toInt() + 1;
    qtyController.text = newQty.toString();
    _calculateAmount();
    _saveCart();
  }

  void _decrementQty() {
    double currentQty = double.tryParse(qtyController.text) ?? 0;
    int intQty = currentQty.toInt();
    if (intQty > 1) {
      qtyController.text = (intQty - 1).toString();
      _calculateAmount();
      _saveCart();
    } else if (intQty == 1) {
      qtyController.text = '0';
      showInputs.value = false;
      qtyController.clear();
      totalAmount.value = 0;
      _saveCart();
    }
  }

  @override
  Widget build(BuildContext context) {
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
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildInfo(
                'Unit',
                widget.item.unit.isEmpty ? 'N/A' : widget.item.unit,
              ),
              _buildInfo('Rate', widget.item.rate.toString()),
              _buildInfo('PackQty', widget.item.packQty.toString()),
              _buildInfo('CaratNos', widget.item.caratNos.toString()),
              _buildInfo('CaratQty', widget.item.caratQty.toString()),
              _buildInfo('ItemPack', widget.item.itemPack.toString()),
              _buildInfo('FAT', widget.item.fat.toStringAsFixed(3)),
              _buildInfo('LR', widget.item.lr.toStringAsFixed(3)),
            ],
          ),
          AppSpaces.v12,
          Obx(() {
            if (!showInputs.value) {
              if (widget.item.caratNos > 0) {
                return Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        onPressed: _showCaratDialog,
                        title: 'Carat',
                        buttonHeight: 36,
                        titleSize: FontSizes.k14FontSize,
                      ),
                    ),
                    AppSpaces.h12,
                    Expanded(
                      child: AppButton(
                        onPressed: _showNosDialog,
                        title: 'Nos',
                        buttonHeight: 36,
                        titleSize: FontSizes.k14FontSize,
                        borderColor: kColorPrimary.withOpacity(0.7),
                        buttonColor: kColorWhite,
                        titleColor: kColorPrimary,
                      ),
                    ),
                  ],
                );
              } else {
                return AppButton(
                  title: 'Add to Cart',
                  buttonHeight: 36,
                  titleSize: FontSizes.k14FontSize,
                  onPressed: () {
                    qtyController.text = '1';
                    showInputs.value = true;
                    _calculateAmount();
                    _saveCart();
                  },
                );
              }
            } else {
              if (widget.item.caratNos > 0) {
                return Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: kColorPrimary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: kColorPrimary.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Carats',
                                      style: TextStyles.kRegularMontserrat(
                                        fontSize: FontSizes.k12FontSize,
                                        color: kColorDarkGrey,
                                      ),
                                    ),
                                    AppSpaces.h4,
                                    AppTextFormField(
                                      controller: caratController,
                                      hintText: 'Carats',
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      fontSize: FontSizes.k16FontSize,
                                      onChanged: _updateCaratManually,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: kColorPrimary.withOpacity(0.3),
                                margin: AppPaddings.combined(
                                  horizontal: 12,
                                  vertical: 0,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Nos',
                                      style: TextStyles.kRegularMontserrat(
                                        fontSize: FontSizes.k12FontSize,
                                        color: kColorDarkGrey,
                                      ),
                                    ),
                                    AppSpaces.h4,
                                    AppTextFormField(
                                      controller: nosController,
                                      hintText: 'Nos',
                                      keyboardType: TextInputType.number,
                                      fontSize: FontSizes.k16FontSize,
                                      onChanged: _updateNosManually,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    AppSpaces.v10,
                    Container(
                      padding: AppPaddings.combined(
                        horizontal: 10,
                        vertical: 8,
                      ),
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
                    ),
                    AppSpaces.h10,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppTextButton(
                          onPressed: _clearInputs,
                          title: 'Clear',
                          fontSize: FontSizes.k14FontSize,
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Row(
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
                            icon: Icon(
                              Icons.remove,
                              color: kColorWhite,
                              size: 18,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ),
                        Container(
                          width: 80,
                          margin: AppPaddings.combined(
                            horizontal: 8,
                            vertical: 0,
                          ),
                          child: SizedBox(
                            width: 80,
                            height: 36,
                            child: TextFormField(
                              controller: qtyController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
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
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade400,
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade400,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color: kColorPrimary,
                                    width: 1,
                                  ),
                                ),
                                contentPadding: AppPaddings.combined(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                filled: true,
                                fillColor: kColorWhite,
                              ),
                              onChanged: (value) {
                                _calculateAmount();
                                _saveCart();
                              },
                            ),
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
                    ),
                    AppSpaces.v8,
                    Container(
                      padding: AppPaddings.combined(
                        horizontal: 12,
                        vertical: 10,
                      ),
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
                    ),
                  ],
                );
              }
            }
          }),
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
