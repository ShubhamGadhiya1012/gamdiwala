import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/features/invoice_entry/controllers/sales_invoice_controller.dart';
import 'package:gamdiwala/features/invoice_entry/screens/invoice_entry_screen.dart';
import 'package:gamdiwala/features/invoice_entry/widgets/sale_invoice_card.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';
import 'package:gamdiwala/widgets/app_loading_overlay.dart';
import 'package:gamdiwala/widgets/app_text_form_field.dart';
import 'package:get/get.dart';

class SalesInvoiceScreen extends StatelessWidget {
  SalesInvoiceScreen({super.key});

  final SalesInvoiceController _controller = Get.put(SalesInvoiceController());

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            backgroundColor: kColorWhite,
            appBar: AppBar(
              backgroundColor: kColorWhite,
              elevation: 1,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: kColorPrimary),
                onPressed: () => Get.back(),
              ),
              title: Text(
                'Sales Invoice',
                style: TextStyles.kBoldMontserrat(
                  fontSize: FontSizes.k20FontSize,
                  color: kColorPrimary,
                ),
              ),
            ),
            body: RefreshIndicator(
              backgroundColor: kColorWhite,
              color: kColorPrimary,
              strokeWidth: 2.5,
              onRefresh: () async {
                await _controller.getSales();
              },
              child: Padding(
                padding: AppPaddings.p10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextFormField(
                      controller: _controller.searchController,
                      hintText: 'Search',
                      onChanged: (query) {
                        _controller.searchQuery.value = query;
                      },
                    ),
                    AppSpaces.v10,
                    Obx(() {
                      if (_controller.sales.isEmpty &&
                          !_controller.isLoading.value) {
                        return Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 80,
                                  color: kColorDarkGrey.withOpacity(0.3),
                                ),
                                AppSpaces.v24,
                                Text(
                                  'No Sales Found',
                                  style: TextStyles.kBoldMontserrat(
                                    fontSize: FontSizes.k24FontSize,
                                    color: kColorTextPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Expanded(
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (scrollNotification) {
                            if (scrollNotification is ScrollEndNotification &&
                                scrollNotification.metrics.extentAfter == 0) {
                              _controller.getSales(loadMore: true);
                            }
                            return false;
                          },
                          child: Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  itemCount: _controller.sales.length,
                                  itemBuilder: (context, index) {
                                    final sale = _controller.sales[index];
                                    return SaleInvoiceCard(sale: sale);
                                  },
                                ),
                              ),
                              Obx(() {
                                return _controller.isLoadingMore.value
                                    ? Padding(
                                        padding: AppPaddings.p10,
                                        child: CircularProgressIndicator(
                                          color: kColorPrimary,
                                        ),
                                      )
                                    : const SizedBox.shrink();
                              }),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Get.to(() => const InvoiceEntryScreen(isEdit: false));
              },
              shape: const CircleBorder(),
              backgroundColor: kColorLightGrey,
              child: Icon(Icons.add, color: kColorPrimary, size: 25),
            ),
          ),
        ),
        Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
      ],
    );
  }
}
