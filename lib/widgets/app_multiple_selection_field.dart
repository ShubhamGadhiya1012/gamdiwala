import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/extensions/app_size_extensions.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';
import 'package:get/get.dart';

class AppMultipleSelectionField extends StatelessWidget {
  final String placeholder;
  final List<String> selectedItems;
  final VoidCallback onTap;
  final bool showFullList;
  final int maxItemsToShow;

  const AppMultipleSelectionField({
    super.key,
    required this.placeholder,
    required this.selectedItems,
    required this.onTap,
    this.showFullList = false,
    this.maxItemsToShow = 1,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.centerLeft,
        width: double.infinity,
        decoration: BoxDecoration(
          color: kColorWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kColorDarkGrey),
        ),
        child: Obx(() {
          final isEmpty = selectedItems.isEmpty;
          final text = isEmpty
              ? placeholder
              : showFullList
              ? selectedItems.join(', ')
              : selectedItems.length <= maxItemsToShow
              ? selectedItems.join(', ')
              : '${selectedItems.take(maxItemsToShow).join(', ')}, ...';

          return Padding(
            padding: AppPaddings.combined(
              horizontal: 16.appWidth,
              vertical: 8.appHeight,
            ),
            child: Text(
              text,
              style: isEmpty
                  ? TextStyles.kRegularMontserrat(
                      fontSize: FontSizes.k16FontSize,
                      color: kColorDarkGrey,
                    )
                  : TextStyles.kMediumMontserrat(
                      fontSize: FontSizes.k16FontSize,
                      color: kColorTextPrimary,
                    ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          );
        }),
      ),
    );
  }
}
