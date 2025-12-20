import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/features/invoice_entry/models/sale_invoice_dm.dart';
import 'package:gamdiwala/features/invoice_entry/screens/invoice_entry_screen.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';
import 'package:gamdiwala/widgets/app_card.dart';
import 'package:get/get.dart';

class SaleInvoiceCard extends StatelessWidget {
  const SaleInvoiceCard({super.key, required this.sale});

  final SaleInvoiceDm sale;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  sale.pName,
                  style: TextStyles.kBoldMontserrat(
                    fontSize: FontSizes.k16FontSize,
                    color: kColorTextPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppSpaces.h10,
              InkWell(
                onTap: () {
                  Get.to(
                    () => InvoiceEntryScreen(
                      isEdit: true,
                      invNo: sale.invNo,
                      yearId: sale.yearId,
                    ),
                  );
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kColorPrimary.withOpacity(0.1),
                    border: Border.all(color: kColorPrimary, width: 2),
                  ),
                  child: Icon(Icons.edit, size: 16, color: kColorPrimary),
                ),
              ),
            ],
          ),
          AppSpaces.v6,
          Container(
            padding: AppPaddings.p10,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                _buildInfoRow('Invoice No', sale.invNo),
                AppSpaces.h12,
                _buildInfoRow('Date', sale.date),
                AppSpaces.v8,
                Divider(height: 1, color: Colors.grey.shade300),
                AppSpaces.v8,
                _buildInfoRow(
                  'Amount',
                  '₹${sale.amount.toStringAsFixed(2)}',
                  valueColor: Colors.green.shade700,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyles.kRegularMontserrat(
            fontSize: FontSizes.k12FontSize,
            color: kColorDarkGrey,
          ),
        ),
        Text(
          value,
          style: TextStyles.kSemiBoldMontserrat(
            fontSize: FontSizes.k12FontSize,
            color: valueColor ?? kColorTextPrimary,
          ),
        ),
      ],
    );
  }
}
