import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';
import 'package:gamdiwala/widgets/app_card.dart';
import 'package:gamdiwala/widgets/app_title_value_container.dart';

class InvoiceItemCard extends StatelessWidget {
  const InvoiceItemCard({
    super.key,
    required this.item,
    required this.onDelete,
  });

  final Map<String, dynamic> item;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item['INAME'],
                  style: TextStyles.kMediumMontserrat(
                    fontSize: FontSizes.k16FontSize,
                    color: kColorPrimary,
                  ),
                ),
              ),
              InkWell(
                onTap: onDelete,
                child: Icon(Icons.delete, size: 20, color: kColorRed),
              ),
            ],
          ),
          AppSpaces.v10,
          Row(
            children: [
              Expanded(
                child: AppTitleValueContainer(
                  title: 'Qty',
                  value: _formatNumber(double.tryParse(item['Qty']) ?? 0),
                  color: kColorGrey,
                ),
              ),
              AppSpaces.h10,
              Expanded(
                child: AppTitleValueContainer(
                  title: 'Rate',
                  value: '₹${item['Rate']}',
                  color: kColorGrey,
                ),
              ),
              AppSpaces.h10,
              Expanded(
                child: AppTitleValueContainer(
                  title: 'Amount',
                  value: '₹${item['Amount']}',
                  color: kColorGrey,
                ),
              ),
            ],
          ),
          if (item['ItemPack'] != null && item['ItemPack'] > 0) ...[
            AppSpaces.v10,
            Row(
              children: [
                if (item['ItemPack'] > 0)
                  Expanded(
                    child: AppTitleValueContainer(
                      title: 'Pack',
                      value: _formatNumber(item['ItemPack']),
                      color: kColorGrey,
                    ),
                  ),
                if (item['CaratNos'] != null && item['CaratNos'] > 0) ...[
                  AppSpaces.h10,
                  Expanded(
                    child: AppTitleValueContainer(
                      title: 'Nos',
                      value: item['CaratNos'].toString(),
                      color: kColorGrey,
                    ),
                  ),
                ],
                if (item['CaratQty'] != null && item['CaratQty'] > 0) ...[
                  AppSpaces.h10,
                  Expanded(
                    child: AppTitleValueContainer(
                      title: 'Carat Qty',
                      value: item['CaratQty'].toString(),
                      color: kColorGrey,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
      onTap: () {},
    );
  }

  String _formatNumber(double number) {
    if (number % 1 == 0) {
      return number.toInt().toString();
    }
    return number.toStringAsFixed(2);
  }
}
