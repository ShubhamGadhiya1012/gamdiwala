import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/features/challan_entry/controllers/challan_entry_controller.dart';
import 'package:gamdiwala/features/challan_entry/widgets/challna_entry_card.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/dialogs/app_dialogs.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';
import 'package:gamdiwala/widgets/app_button.dart';
import 'package:gamdiwala/widgets/app_date_picker_text_form_field.dart';
import 'package:gamdiwala/widgets/app_loading_overlay.dart';
import 'package:get/get.dart';

class ChallanEntryScreen extends StatefulWidget {
  const ChallanEntryScreen({super.key});

  @override
  State<ChallanEntryScreen> createState() => _ChallanEntryScreenState();
}

class _ChallanEntryScreenState extends State<ChallanEntryScreen>
    with SingleTickerProviderStateMixin {
  final ChallanController _controller = Get.put(ChallanController());
  String? _expandedCardKey;
  String? _selectedCardKey;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadTodayOrders();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _expandedCardKey = null;
        _selectedCardKey = null;
      });

      _controller.loadOrdersByStatus(
        _tabController.index == 0 ? 'PENDING' : 'COMPLETE',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: kColorWhite,
          appBar: AppBar(
            backgroundColor: kColorWhite,
            elevation: 1,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: kColorPrimary),
              onPressed: () => Get.back(),
            ),
            title: Text(
              _selectedCardKey != null ? '1 Selected' : 'Challan Entry',
              style: TextStyles.kBoldMontserrat(
                fontSize: FontSizes.k20FontSize,
                color: kColorPrimary,
              ),
            ),
            actions: _selectedCardKey != null
                ? [
                    IconButton(
                      icon: Icon(Icons.close, color: kColorPrimary),
                      onPressed: () {
                        setState(() {
                          _selectedCardKey = null;
                        });
                      },
                    ),
                  ]
                : null,
          ),
          body: Column(
            children: [
              _buildDatePickerSection(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOrdersList(isPending: true),
                    _buildOrdersList(isPending: false),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton:
              _selectedCardKey != null && _tabController.index == 0
              ? FloatingActionButton.extended(
                  onPressed: _showChallanDateDialog,
                  label: Text('Challan Entry'),
                  foregroundColor: kColorWhite,
                  icon: Icon(Icons.check),
                  backgroundColor: kColorPrimary,
                )
              : null,
        ),
        Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
      ],
    );
  }

  Widget _buildDatePickerSection() {
    return Container(
      padding: AppPaddings.p16,
      decoration: BoxDecoration(
        color: kColorWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AppDatePickerTextFormField(
        dateController: _controller.orderDateController,
        hintText: 'Order Date',
        onChanged: (date) {
          if (date.isNotEmpty) {
            setState(() {
              _expandedCardKey = null;
              _selectedCardKey = null;
            });
            _controller.searchOrders();
          }
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: kColorWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: kColorPrimary,
        labelColor: kColorPrimary,
        unselectedLabelColor: kColorDarkGrey,
        labelStyle: TextStyles.kSemiBoldMontserrat(
          fontSize: FontSizes.k14FontSize,
        ),
        unselectedLabelStyle: TextStyles.kMediumMontserrat(
          fontSize: FontSizes.k14FontSize,
        ),
        tabs: const [
          Tab(text: 'Pending Challan'),
          Tab(text: 'Completed Challan'),
        ],
      ),
    );
  }

  Widget _buildOrdersList({required bool isPending}) {
    return Obx(() {
      final orders = isPending
          ? _controller.pendingOrders
          : _controller.completedOrders;

      if (orders.isEmpty && !_controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 80,
                color: kColorDarkGrey.withOpacity(0.3),
              ),
              AppSpaces.h24,
              Text(
                'No Orders Found',
                style: TextStyles.kBoldMontserrat(
                  fontSize: FontSizes.k24FontSize,
                  color: kColorTextPrimary,
                ),
              ),
              AppSpaces.h12,
              Text(
                isPending
                    ? 'No pending orders for selected date'
                    : 'No completed orders for selected date',
                style: TextStyles.kRegularMontserrat(
                  fontSize: FontSizes.k16FontSize,
                  color: kColorDarkGrey,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        backgroundColor: kColorWhite,
        color: kColorPrimary,
        strokeWidth: 2.5,
        onRefresh: () async {
          await _controller.loadOrdersByStatus(
            isPending ? 'PENDING' : 'COMPLETE',
          );
          setState(() {
            _expandedCardKey = null;
            _selectedCardKey = null;
          });
        },
        child: ListView.builder(
          padding: AppPaddings.p10,
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final isSelected = _selectedCardKey == order.invNo;

            return ChallanOrderCard(
              key: ValueKey(order.invNo),
              order: order,
              expandedCardKey: _expandedCardKey,
              isSelected: isSelected,
              isPending: isPending,
              onExpanded: (String? cardKey) {
                setState(() {
                  _expandedCardKey = cardKey;
                });
              },
              onLongPress: isPending
                  ? () {
                      _handleCardSelection(order.invNo);
                    }
                  : null,
              onSelectionToggle: isPending
                  ? () {
                      _handleCardSelection(order.invNo);
                    }
                  : null,
              onTap: () {},
              onPdfDownload: !isPending
                  ? () {
                      _controller.downloadChallanPdf(order.invNo);
                    }
                  : null,
            );
          },
        ),
      );
    });
  }

  void _handleCardSelection(String invNo) {
    setState(() {
      if (_selectedCardKey == invNo) {
        _selectedCardKey = null;
      } else if (_selectedCardKey != null) {
        showErrorSnackbar(
          'Single Selection Only',
          'You can only select one order at a time for challan entry',
        );
      } else {
        _selectedCardKey = invNo;
      }
    });
  }

  void _showChallanDateDialog() {
    if (_selectedCardKey == null) return;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: kColorWhite,
        child: Container(
          padding: AppPaddings.p20,
          child: Form(
            key: _controller.challanDateFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Challan Entry',
                      style: TextStyles.kBoldMontserrat(
                        fontSize: FontSizes.k18FontSize,
                        color: kColorTextPrimary,
                      ),
                    ),
                  ],
                ),
                AppSpaces.v20,
                AppDatePickerTextFormField(
                  dateController: _controller.challanDateController,
                  hintText: 'Challan Date',
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Please select challan date'
                      : null,
                ),
                AppSpaces.v24,
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        onPressed: () async {
                          if (_controller.challanDateFormKey.currentState!
                              .validate()) {
                            final success = await _controller.saveChallanEntry(
                              _selectedCardKey!,
                            );
                            if (success) {
                              setState(() {
                                _selectedCardKey = null;
                              });
                            }
                          }
                        },
                        title: 'Submit',
                        titleSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
