import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/features/home/models/item_dm.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';
import 'package:gamdiwala/widgets/app_card.dart';

class ItemCard extends StatelessWidget {
  final ItemDm item;
  final VoidCallback? onTap;

  const ItemCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.iName,
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
              _buildInfo('Unit', item.unit),
              _buildInfo('Rate', item.rate.toString()),
              _buildInfo('PackQty', item.packQty.toString()),
              _buildInfo('CaratNos', item.caratNos.toString()),
              _buildInfo('CaratQty', item.caratQty.toString()),
              _buildInfo('ItemPack', item.itemPack.toString()),
              _buildInfo('FAT', item.fat.toStringAsFixed(3)),
              _buildInfo('LR', item.lr.toStringAsFixed(3)),
            ],
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
