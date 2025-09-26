import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';
import 'package:gamdiwala/widgets/app_button.dart';
import 'package:gamdiwala/widgets/app_text_button.dart';
import 'package:gamdiwala/widgets/app_text_form_field.dart';
import 'package:get/get.dart';

class SelectionBottomSheet<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final List<String> selectedCodes;
  final List<String> selectedNames;
  final String Function(T) itemNameGetter;
  final String Function(T) itemCodeGetter;
  final TextEditingController searchController;
  final void Function(bool?, T) onSelectionChanged;
  final void Function() onSelectAll;
  final void Function() onClearAll;
  final double maxHeight;
  final void Function(String) onSearchChanged;

  const SelectionBottomSheet({
    super.key,
    required this.title,
    required this.items,
    required this.selectedCodes,
    required this.selectedNames,
    required this.itemNameGetter,
    required this.itemCodeGetter,
    required this.searchController,
    required this.onSelectionChanged,
    required this.onSelectAll,
    required this.onClearAll,
    required this.onSearchChanged,
    this.maxHeight = 0.75,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final actualMaxHeight = mediaQuery.size.height * maxHeight;

    return Container(
      constraints: BoxConstraints(maxHeight: actualMaxHeight),
      padding: AppPaddings.p10,
      decoration: const BoxDecoration(
        color: kColorWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyles.kSemiBoldMontserrat()),
              Row(
                children: [
                  AppTextButton(
                    onPressed: onSelectAll,
                    title: 'Select All',
                    fontSize: FontSizes.k16FontSize,
                  ),
                  AppSpaces.h10,
                  AppTextButton(
                    onPressed: onClearAll,
                    title: 'Clear All',
                    fontSize: FontSizes.k16FontSize,
                  ),
                ],
              ),
            ],
          ),
          AppSpaces.v10,
          AppTextFormField(
            hintText: 'Search',
            controller: searchController,
            onChanged: onSearchChanged,
          ),
          AppSpaces.v10,
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Obx(
                    () => CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        itemNameGetter(item),
                        style: TextStyles.kRegularMontserrat(
                          fontSize: FontSizes.k16FontSize,
                          color: kColorTextPrimary,
                        ),
                      ),
                      checkColor: kColorWhite,
                      activeColor: kColorPrimary,
                      value: selectedCodes.contains(itemCodeGetter(item)),
                      onChanged: (bool? selected) {
                        onSelectionChanged(selected, item);
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          AppButton(
            onPressed: () {
              Get.back();
            },
            title: 'Done',
          ),
          AppSpaces.v10,
        ],
      ),
    );
  }
}
