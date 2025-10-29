import 'package:flutter/material.dart';
import 'package:gamdiwala/features/user_settings/controllers/user_authorisation_controller.dart';
import 'package:gamdiwala/features/user_settings/models/engineer_dm.dart';
import 'package:gamdiwala/features/user_settings/models/salesman_dm.dart';
import 'package:gamdiwala/features/user_settings/widgets/user_authorisation_info_card.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';
import 'package:gamdiwala/widgets/app_appbar.dart';
import 'package:gamdiwala/widgets/app_button.dart';
import 'package:gamdiwala/widgets/app_dropdown.dart';
import 'package:gamdiwala/widgets/app_loading_overlay.dart';
import 'package:gamdiwala/widgets/app_multiple_selection_bottom_sheet.dart';
import 'package:gamdiwala/widgets/app_multiple_selection_field.dart';
import 'package:get/get.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';

class UserAuthorisationScreen extends StatelessWidget {
  UserAuthorisationScreen({
    super.key,
    required this.userId,
    required this.fullName,
    required this.mobileNo,
  });

  final int userId;
  final String fullName;
  final String mobileNo;

  final UserAuthorisationController _controller = Get.put(
    UserAuthorisationController(),
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            appBar: AppAppbar(
              title: 'User Management',
              leading: IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: kColorTextPrimary,
                ),
              ),
            ),
            body: Padding(
              padding: AppPaddings.p10,
              child: SingleChildScrollView(
                child: Form(
                  key: _controller.authUserFormKey,
                  child: Column(
                    children: [
                      AppSpaces.v10,
                      UserAuthorisationInfoCard(
                        fullName: fullName,
                        mobileNo: mobileNo,
                      ),
                      AppSpaces.v10,
                      AppDropdown(
                        items: _controller.userTypes.values.toList(),
                        hintText: 'User Type',
                        showSearchBox: false,
                        onChanged: (selectedValue) {
                          _controller.onUserTypeChanged(selectedValue!);
                        },
                        selectedItem: _controller.selectedUserType.value != null
                            ? _controller.userTypes.entries
                                  .firstWhere(
                                    (ut) =>
                                        ut.key ==
                                        _controller.selectedUserType.value,
                                  )
                                  .value
                            : null,
                        validatorText: 'Please select a user type.',
                      ),
                      Obx(
                        () => Visibility(
                          visible: _controller.selectedUserType.value == 1,
                          child: Column(
                            children: [
                              AppSpaces.v10,
                              GestureDetector(
                                onTap: () {
                                  showEngineerSelectionBottomSheet(context);
                                },
                                child: AppMultipleSelectionField(
                                  placeholder: 'Engineer',
                                  selectedItems:
                                      _controller.selectedEngineerNames,
                                  onTap: () =>
                                      showEngineerSelectionBottomSheet(context),
                                  showFullList: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Obx(
                        () => Visibility(
                          visible: _controller.selectedUserType.value == 1,
                          child: Column(
                            children: [
                              AppSpaces.v10,
                              GestureDetector(
                                onTap: () {
                                  showSalesmanSelectionBottomSheet(context);
                                },
                                child: AppMultipleSelectionField(
                                  placeholder: 'Salesman',
                                  selectedItems:
                                      _controller.selectedSalesmanNames,
                                  onTap: () =>
                                      showSalesmanSelectionBottomSheet(context),
                                  showFullList: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Obx(
                        () => Visibility(
                          visible: _controller.selectedUserType.value == 2,
                          child: Column(
                            children: [
                              AppSpaces.v10,
                              AppDropdown(
                                items: _controller.salesmanNames,
                                hintText: 'Salesman',
                                onChanged: _controller.onSalesmanSelected,
                                selectedItem:
                                    _controller
                                        .selectedSalesmanName
                                        .value
                                        .isNotEmpty
                                    ? _controller.selectedSalesmanName.value
                                    : null,
                                validatorText: 'Please select a salesman.',
                              ),
                            ],
                          ),
                        ),
                      ),
                      Obx(
                        () => Visibility(
                          visible: _controller.selectedUserType.value == 3,
                          child: Column(
                            children: [
                              AppSpaces.v10,
                              AppDropdown(
                                items: _controller.engineerNames,
                                hintText: 'Engineer',
                                onChanged: _controller.onEngineerSelected,
                                selectedItem:
                                    _controller
                                        .selectedEngineerName
                                        .value
                                        .isNotEmpty
                                    ? _controller.selectedEngineerName.value
                                    : null,
                                validatorText: 'Please select an engineer.',
                              ),
                            ],
                          ),
                        ),
                      ),
                      AppSpaces.v30,
                      AppButton(
                        title: 'Save',
                        onPressed: () {
                          if (_controller.authUserFormKey.currentState!
                              .validate()) {
                            _controller.authoriseUser(userId: userId);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
      ],
    );
  }

  void showSalesmanSelectionBottomSheet(BuildContext context) {
    Get.bottomSheet(
      SelectionBottomSheet<SalesmanDm>(
        title: 'Select Salesman',
        items: _controller.filteredSalesmen,
        selectedCodes: _controller.selectedSalesmanCodes,
        selectedNames: _controller.selectedSalesmanNames,
        itemNameGetter: (se) => se.seName,
        itemCodeGetter: (se) => se.seCode,
        searchController: _controller.searchSalesmanController,
        onSelectionChanged: (selected, se) {
          if (selected == true) {
            _controller.selectedSalesmanCodes.add(se.seCode);
            _controller.selectedSalesmanNames.add(se.seName);
          } else {
            _controller.selectedSalesmanCodes.remove(se.seCode);
            _controller.selectedSalesmanNames.remove(se.seName);
          }
        },
        onSelectAll: _controller.selectAllSalesmen,
        onClearAll: () {
          _controller.selectedSalesmanCodes.clear();
          _controller.selectedSalesmanNames.clear();
        },
        onSearchChanged: (value) {
          _controller.filteredSalesmen.value = _controller.salesmen
              .where(
                (se) => se.seName.toLowerCase().contains(value.toLowerCase()),
              )
              .toList();
        },
      ),
      isScrollControlled: true,
    );
  }

  void showEngineerSelectionBottomSheet(BuildContext context) {
    Get.bottomSheet(
      SelectionBottomSheet<EngineerDm>(
        title: 'Select Engineer',
        items: _controller.filteredEngineers,
        selectedCodes: _controller.selectedEngineerCodes,
        selectedNames: _controller.selectedEngineerNames,
        itemNameGetter: (er) => er.eName,
        itemCodeGetter: (er) => er.eCode,
        searchController: _controller.searchEngineerController,
        onSelectionChanged: (selected, er) {
          if (selected == true) {
            _controller.selectedEngineerCodes.add(er.eCode);
            _controller.selectedEngineerNames.add(er.eName);
          } else {
            _controller.selectedEngineerCodes.remove(er.eCode);
            _controller.selectedEngineerNames.remove(er.eName);
          }
        },
        onSelectAll: _controller.selectAllEngineers,
        onClearAll: () {
          _controller.selectedEngineerCodes.clear();
          _controller.selectedEngineerNames.clear();
        },
        onSearchChanged: (value) {
          _controller.filteredEngineers.value = _controller.engineers
              .where(
                (er) => er.eName.toLowerCase().contains(value.toLowerCase()),
              )
              .toList();
        },
      ),
      isScrollControlled: true,
    );
  }
}
