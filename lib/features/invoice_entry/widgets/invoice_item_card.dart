// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';
import 'package:gamdiwala/widgets/app_button.dart';
import 'package:gamdiwala/widgets/app_card.dart';

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
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildHeader(context), AppSpaces.v6, _buildItemDetails()],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                item['INAME'] ?? '',
                style: TextStyles.kBoldMontserrat(
                  fontSize: FontSizes.k16FontSize,
                  color: kColorTextPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            AppSpaces.h10,
            Text(
              '₹${item['Amount']}',
              style: TextStyles.kBoldMontserrat(
                fontSize: FontSizes.k15FontSize,
                color: Colors.green.shade700,
              ),
            ),
            AppSpaces.h10,
            InkWell(
              onTap: () => _showDeleteConfirmation(context),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kColorRed.withOpacity(0.1),
                  border: Border.all(color: kColorRed, width: 2),
                ),
                child: Icon(Icons.delete, size: 16, color: kColorRed),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemDetails() {
    return Container(
      padding: AppPaddings.p10,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order No: ${item['OrderNo'] ?? 'N/A'}',
                      style: TextStyles.kMediumMontserrat(
                        fontSize: FontSizes.k14FontSize,
                        color: kColorDarkGrey,
                      ),
                    ),
                    if (item['ChallanNo'] != null &&
                        item['ChallanNo'].toString().isNotEmpty)
                      Text(
                        'Challan No: ${item['ChallanNo']}',
                        style: TextStyles.kRegularMontserrat(
                          fontSize: FontSizes.k12FontSize,
                          color: kColorDarkGrey,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          AppSpaces.v12,
          Divider(height: 1, color: Colors.grey.shade300),
          AppSpaces.v12,
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildInfoChip('Qty', item['Qty']?.toString() ?? '0'),
              _buildInfoChip('Rate', '₹${item['Rate'] ?? '0.00'}'),

              if (item['ItemPack'] != null &&
                  (double.tryParse(item['ItemPack'].toString()) ?? 0) > 0)
                _buildInfoChip('Pack', item['ItemPack'].toString()),

              if (item['CaratNos'] != null &&
                  (int.tryParse(item['CaratNos'].toString()) ?? 0) > 0)
                _buildInfoChip('Nos', item['CaratNos'].toString()),

              if (item['CaratQty'] != null &&
                  (int.tryParse(item['CaratQty'].toString()) ?? 0) > 0)
                _buildInfoChip('Carat Qty', item['CaratQty'].toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: AppPaddings.combined(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
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

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kColorWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: AppPaddings.p8,
                decoration: BoxDecoration(
                  color: kColorRed.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.warning_rounded, color: kColorRed, size: 24),
              ),
              AppSpaces.h10,
              Text(
                'Delete Item',
                style: TextStyles.kBoldMontserrat(
                  fontSize: FontSizes.k18FontSize,
                  color: kColorTextPrimary,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${item['INAME']}"?',
            style: TextStyles.kMediumMontserrat(
              fontSize: FontSizes.k14FontSize,
              color: kColorDarkGrey,
            ),
          ),
          actionsPadding: AppPaddings.combined(horizontal: 16, vertical: 12),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: AppPaddings.combined(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyles.kSemiBoldMontserrat(
                        fontSize: FontSizes.k14FontSize,
                        color: kColorDarkGrey,
                      ),
                    ),
                  ),
                ),
                AppSpaces.h8,
                Expanded(
                  child: AppButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onDelete();
                    },
                    title: 'Delete',
                    buttonColor: kColorRed,
                    titleSize: 16,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
