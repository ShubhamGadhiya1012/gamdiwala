import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/features/authentication/auth/controllers/select_party_controller.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';
import 'package:gamdiwala/widgets/app_button.dart';
import 'package:gamdiwala/widgets/app_loading_overlay.dart';
import 'package:gamdiwala/widgets/app_text_form_field.dart';
import 'package:get/get.dart';

class SelectPartyScreen extends StatelessWidget {
  SelectPartyScreen({super.key});

  final SelectPartyController _controller = Get.put(SelectPartyController());

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: Column(
            children: [
              Container(
                padding: AppPaddings.custom(top: 50, left: 30, right: 20),
                width: double.infinity,
                child: Text(
                  'Select Party',
                  style: TextStyles.kBoldMontserrat(
                    fontSize: FontSizes.k20FontSize,
                    color: kColorPrimary,
                  ),
                ),
              ),
              Container(
                padding: AppPaddings.p16,
                child: AppTextFormField(
                  controller: _controller.searchController,
                  hintText: 'Search Party',
                  onChanged: _controller.onSearchChanged,
                  showClearIcon: true,
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (_controller.filteredParties.isEmpty &&
                      !_controller.isLoading.value) {
                    return Center(
                      child: Text(
                        _controller.searchController.text.isEmpty
                            ? 'No parties available'
                            : 'No parties found',
                        style: TextStyles.kRegularMontserrat(
                          fontSize: FontSizes.k16FontSize,
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: AppPaddings.p16,
                    itemCount: _controller.filteredParties.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: Colors.grey.shade300),
                    itemBuilder: (context, index) {
                      final party = _controller.filteredParties[index];
                      return Obx(() {
                        final isSelected =
                            _controller.selectedParty.value?.pCode ==
                            party.pCode;

                        return InkWell(
                          onTap: () => _controller.onPartySelected(party),
                          child: Container(
                            padding: AppPaddings.p16,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? kColorPrimary.withOpacity(0.1)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? kColorPrimary
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  party.pName,
                                  style: TextStyles.kBoldMontserrat(
                                    fontSize: FontSizes.k16FontSize,
                                    color: isSelected
                                        ? kColorPrimary
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                    },
                  );
                }),
              ),

              Obx(() {
                if (_controller.selectedParty.value == null) {
                  return const SizedBox.shrink();
                }

                return Container(
                  padding: AppPaddings.custom(bottom: 30, left: 20, right: 20),
                  decoration: BoxDecoration(
                    color: kColorWhite,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: AppButton(
                      title: 'Continue',
                      onPressed: _controller.onContinue,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
      ],
    );
  }
}
