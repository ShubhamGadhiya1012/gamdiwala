// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/features/challan_entry/models/order_dm.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';
import 'package:gamdiwala/widgets/app_card.dart';

class ChallanOrderCard extends StatefulWidget {
  final ChallanOrderDm order;
  final VoidCallback? onTap;
  final String? expandedCardKey;
  final Function(String?)? onExpanded;
  final bool isSelected;
  final VoidCallback? onLongPress;
  final VoidCallback? onSelectionToggle;
  final bool isPending;
  final VoidCallback? onPdfDownload;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ChallanOrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.expandedCardKey,
    this.onExpanded,
    this.isSelected = false,
    this.onLongPress,
    this.onSelectionToggle,
    this.isPending = true,
    this.onPdfDownload,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<ChallanOrderCard> createState() => _ChallanOrderCardState();
}

class _ChallanOrderCardState extends State<ChallanOrderCard> {
  late bool isExpanded;

  @override
  void initState() {
    super.initState();
    isExpanded = widget.expandedCardKey == widget.order.invNo;
  }

  @override
  void didUpdateWidget(ChallanOrderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    isExpanded = widget.expandedCardKey == widget.order.invNo;
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () {
        if (isExpanded) {
          widget.onExpanded?.call(null);
        } else {
          widget.onExpanded?.call(widget.order.invNo);
        }
        widget.onTap?.call();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          if (isExpanded) ...[AppSpaces.v16, _buildOrderItemsList()],
          AppSpaces.v16,
          _buildTotalAmount(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return GestureDetector(
      onLongPress: widget.onLongPress,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isPending)
            GestureDetector(
              onTap: widget.onSelectionToggle,
              child: Padding(
                padding: AppPaddings.custom(right: 12),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isSelected
                        ? kColorPrimary
                        : Colors.transparent,
                    border: Border.all(
                      color: widget.isSelected
                          ? kColorPrimary
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: widget.isSelected
                      ? Icon(Icons.check, size: 16, color: kColorWhite)
                      : null,
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.order.pName,
                  style: TextStyles.kBoldMontserrat(
                    fontSize: FontSizes.k16FontSize,
                    color: kColorTextPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpaces.h6,

                if (widget.order.challanNo.isNotEmpty) ...[
                  Text(
                    'Challan No: ${widget.order.challanNo}',
                    style: TextStyles.kBoldMontserrat(
                      fontSize: FontSizes.k14FontSize,
                      color: kColorTextPrimary,
                    ),
                  ),
                  AppSpaces.h4,
                ],

                Text(
                  'Order No: ${widget.order.invNo}',
                  style: TextStyles.kMediumMontserrat(
                    fontSize: FontSizes.k10FontSize,
                    color: kColorDarkGrey,
                  ),
                ),
              ],
            ),
          ),

          AppSpaces.h12,
          Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: AppPaddings.combined(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: kColorPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kColorPrimary.withOpacity(0.3)),
                    ),
                    child: Text(
                      '${widget.order.orderItems.length} Items',
                      style: TextStyles.kSemiBoldMontserrat(
                        fontSize: FontSizes.k12FontSize,
                        color: kColorPrimary,
                      ),
                    ),
                  ),
                  if (widget.isPending &&
                      (widget.onEdit != null || widget.onDelete != null)) ...[
                    AppSpaces.h8,
                    if (widget.onEdit != null)
                      GestureDetector(
                        onTap: widget.onEdit,
                        child: Container(
                          padding: AppPaddings.p8,
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.shade300),
                          ),
                          child: Icon(
                            Icons.edit,
                            color: Colors.orange.shade700,
                            size: 18,
                          ),
                        ),
                      ),
                    if (widget.onDelete != null) ...[
                      AppSpaces.h8,
                      GestureDetector(
                        onTap: widget.onDelete,
                        child: Container(
                          padding: AppPaddings.p8,
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade300),
                          ),
                          child: Icon(
                            Icons.delete,
                            color: Colors.red.shade700,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ],
                  if (!widget.isPending) ...[
                    AppSpaces.h8,
                    GestureDetector(
                      onTap: widget.onPdfDownload,
                      child: Container(
                        padding: AppPaddings.p8,
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red.shade700,
                          size: 20,
                        ),
                      ),
                    ),
                    // Show delete button only if hasSaleBill is "NO"
                    if (widget.order.hasSaleBill.toUpperCase() == 'NO') ...[
                      AppSpaces.h8,
                      GestureDetector(
                        onTap: widget.onDelete,
                        child: Container(
                          padding: AppPaddings.p8,
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade300),
                          ),
                          child: Icon(
                            Icons.delete,
                            color: Colors.red.shade700,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
              AppSpaces.v8,
              AnimatedRotation(
                turns: isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 300),
                child: Icon(Icons.expand_more, color: kColorPrimary, size: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Items',
          style: TextStyles.kSemiBoldMontserrat(
            fontSize: FontSizes.k14FontSize,
            color: kColorTextPrimary,
          ),
        ),
        AppSpaces.v12,
        ...widget.order.orderItems.asMap().entries.map((entry) {
          int index = entry.key;
          var item = entry.value;
          return Column(
            children: [if (index > 0) AppSpaces.v12, _buildOrderItemCard(item)],
          );
        }),
      ],
    );
  }

  Widget _buildOrderItemCard(ChallanOrderItemDm item) {
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.iName,
                      style: TextStyles.kMediumMontserrat(
                        fontSize: FontSizes.k14FontSize,
                        color: kColorTextPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              AppSpaces.h12,
              Text(
                '₹${item.amount.toStringAsFixed(2)}',
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
              _buildInfoChip('Qty', _formatNumber(item.qty)),
              _buildInfoChip('Rate', '₹${item.rate.toStringAsFixed(2)}'),
              if (item.itemPack > 0)
                _buildInfoChip('Pack', item.itemPack.toString()),
              if (item.fat > 0)
                _buildInfoChip('Fat', item.fat.toStringAsFixed(3)),
              if (item.lr > 0) _buildInfoChip('LR', item.lr.toString()),
              if (item.caratQty > 0)
                _buildInfoChip('Carat Qty', item.caratQty.toString()),
              if (item.caratNos > 0)
                _buildInfoChip('Carat Nos', item.caratNos.toString()),
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

  Widget _buildTotalAmount() {
    return Container(
      padding: AppPaddings.combined(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade300, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Amount',
            style: TextStyles.kBoldMontserrat(
              fontSize: FontSizes.k15FontSize,
              color: kColorTextPrimary,
            ),
          ),
          Text(
            '₹${widget.order.totalAmount.toStringAsFixed(2)}',
            style: TextStyles.kBoldMontserrat(
              fontSize: FontSizes.k18FontSize,
              color: Colors.green.shade700,
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
