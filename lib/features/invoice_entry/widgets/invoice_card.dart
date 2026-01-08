// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/features/invoice_entry/controllers/invoice_controller.dart';
import 'package:gamdiwala/features/invoice_entry/models/sale_invoice_dm.dart';
import 'package:gamdiwala/features/invoice_entry/screens/invoice_entry_screen.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';
import 'package:gamdiwala/widgets/app_card.dart';
import 'package:get/get.dart';

class InvoiceCard extends StatelessWidget {
  const InvoiceCard({super.key, required this.sale});

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
                onTap: () => _showPrintDialog(context),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.withOpacity(0.1),
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: Icon(Icons.print, size: 16, color: Colors.blue),
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

  void _showPrintDialog(BuildContext context) {
    final controller = Get.find<InvoiceController>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kColorWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: AppPaddings.p20,
          title: Row(
            children: [
              Container(
                padding: AppPaddings.p10,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.print, color: Colors.blue, size: 28),
              ),
              AppSpaces.h12,
              Expanded(
                child: Text(
                  'Print Invoice',
                  style: TextStyles.kBoldMontserrat(
                    fontSize: FontSizes.k18FontSize,
                    color: kColorTextPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select printing size for invoice ${sale.invNo}',
                style: TextStyles.kMediumMontserrat(
                  fontSize: FontSizes.k14FontSize,
                  color: kColorDarkGrey,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpaces.v20,
              _buildPrintOption(
                context: context,
                controller: controller,
                icon: Icons.receipt,
                title: 'Half Print',
                pageSize: 'HALF',
              ),
              AppSpaces.v12,
              _buildPrintOption(
                context: context,
                controller: controller,
                icon: Icons.description,
                title: 'Full Print',
                pageSize: 'FULL',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrintOption({
    required BuildContext context,
    required InvoiceController controller,
    required IconData icon,
    required String title,

    required String pageSize,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        controller.printInvoice(
          invNo: sale.invNo,
          bookCode: sale.bookCode,
          yearId: sale.yearId.toString(),
          coCode: sale.companyCode.toString(),
          branchCode: sale.branchCode,
          pageSize: pageSize,
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: AppPaddings.p16,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Container(
              padding: AppPaddings.p12,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.blue, size: 24),
            ),
            AppSpaces.h16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyles.kBoldMontserrat(
                      fontSize: FontSizes.k16FontSize,
                      color: kColorTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: kColorDarkGrey),
          ],
        ),
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
