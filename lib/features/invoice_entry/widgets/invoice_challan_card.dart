import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/features/invoice_entry/models/invoice_dm.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/helpers/date_format_helper.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';
import 'package:gamdiwala/widgets/app_card.dart';

class InvoiceChallanCard extends StatelessWidget {
  final InvoiceChallanDm challan;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const InvoiceChallanCard({
    super.key,
    required this.challan,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(isSelected ? 0.98 : 1.0),
        child: AppCard(
          borderColor: isSelected ? kColorPrimary : Colors.transparent,
          onTap: onTap,
          child: Stack(
            children: [
              if (isSelectionMode)
                Positioned(
                  top: 8,
                  left: 8,
                  child: AnimatedScale(
                    scale: isSelected ? 1.0 : 0.8,
                    duration: const Duration(milliseconds: 200),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? kColorPrimary
                            : Colors.grey.shade300,
                        border: Border.all(
                          color: isSelected
                              ? kColorPrimary
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                ),

              Padding(
                padding: isSelectionMode
                    ? const EdgeInsets.only(left: 40)
                    : EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_buildHeader(), AppSpaces.v6, _buildItemDetails()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              challan.invNo,
              style: TextStyles.kBoldMontserrat(
                fontSize: FontSizes.k16FontSize,
                color: kColorTextPrimary,
              ),
            ),
            AppSpaces.h6,
            Text(
              convertyyyyMMddToddMMyyyy(challan.date),
              style: TextStyles.kBoldMontserrat(
                fontSize: FontSizes.k16FontSize,
                color: kColorTextPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemDetails() {
    return Container(
      padding: AppPaddings.p12,
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
                child: Text(
                  challan.iName,
                  style: TextStyles.kMediumMontserrat(
                    fontSize: FontSizes.k14FontSize,
                    color: kColorTextPrimary,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppSpaces.h12,
              Text(
                '₹${challan.amount.toStringAsFixed(2)}',
                style: TextStyles.kBoldMontserrat(
                  fontSize: FontSizes.k15FontSize,
                  color: Colors.green.shade700,
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
              _buildInfoChip('Qty', _formatNumber(challan.qty)),
              _buildInfoChip('Rate', '₹${challan.rate.toStringAsFixed(2)}'),
              if (challan.itemPack > 0)
                _buildInfoChip('Pack', challan.itemPack.toStringAsFixed(2)),
              if (challan.caratNos > 0)
                _buildInfoChip('Nos', challan.caratNos.toString()),
              if (challan.caratQty > 0)
                _buildInfoChip('Carat Qty', challan.caratQty.toString()),
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

  String _formatNumber(double number) {
    if (number % 1 == 0) {
      return number.toInt().toString();
    }
    return number.toStringAsFixed(2);
  }
}
