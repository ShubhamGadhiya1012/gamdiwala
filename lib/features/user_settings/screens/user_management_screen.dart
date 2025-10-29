import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamdiwala/features/user_settings/controllers/user_management_controller.dart';
import 'package:gamdiwala/features/user_settings/models/engineer_dm.dart';
import 'package:gamdiwala/features/user_settings/models/salesman_dm.dart';
import 'package:gamdiwala/utils/formatters/text_input_formatters.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';
import 'package:gamdiwala/widgets/app_appbar.dart';
import 'package:gamdiwala/widgets/app_button.dart';
import 'package:gamdiwala/widgets/app_dropdown.dart';
import 'package:gamdiwala/widgets/app_loading_overlay.dart';
import 'package:gamdiwala/widgets/app_multiple_selection_bottom_sheet.dart';
import 'package:gamdiwala/widgets/app_multiple_selection_field.dart';
import 'package:gamdiwala/widgets/app_text_form_field.dart';
import 'package:get/get.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({
    super.key,
    required this.isEdit,
    this.fullName,
    this.mobileNo,
    this.userId,
    this.isAppAccess,
    this.userType,
    this.seCodes,
    this.pCodes,
    this.eCodes,
  });

  final bool isEdit;
  final String? fullName;
  final String? mobileNo;
  final int? userId;
  final bool? isAppAccess;
  final int? userType;
  final String? seCodes;
  final String? pCodes;
  final String? eCodes;

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final UserManagementController _controller = Get.put(
    UserManagementController(),
  );

  @override
  void initState() {
    super.initState();
    _controller.setupValidationListeners();
    initialize();
  }

  void initialize() async {
    if (widget.isEdit) {
      _controller.fullNameController.text = widget.fullName!;
      _controller.mobileNoController.text = widget.mobileNo!;
      _controller.selectedUserType.value = widget.userType!;

      if (widget.userType == 1) {
        await _controller.getSalesmen();
        await _controller.getEngineers();

        if (widget.seCodes != null && widget.seCodes!.isNotEmpty) {
          _controller.selectedSalesmanCodes.addAll(
            widget.seCodes!.split(',').map((secode) => secode.trim()),
          );
        }

        for (var salesman in _controller.salesmen) {
          if (_controller.selectedSalesmanCodes.contains(salesman.seCode)) {
            _controller.selectedSalesmanNames.add(salesman.seName);
          }
        }

        if (widget.eCodes != null && widget.eCodes!.isNotEmpty) {
          _controller.selectedEngineerCodes.addAll(
            widget.eCodes!.split(',').map((ecode) => ecode.trim()),
          );
        }

        for (var engineer in _controller.engineers) {
          if (_controller.selectedEngineerCodes.contains(engineer.eCode)) {
            _controller.selectedEngineerNames.add(engineer.eName);
          }
        }
      }

      if (widget.userType == 2) {
        await _controller.getSalesmen();

        if (widget.seCodes != null && widget.seCodes!.isNotEmpty) {
          _controller.selectedSalesmanCode.value = widget.seCodes!;
          _controller.selectedSalesmanName.value = _controller.salesmen
              .firstWhere((se) => se.seCode == widget.seCodes!)
              .seName;
        }
      }

      if (widget.userType == 3) {
        await _controller.getEngineers();

        if (widget.eCodes != null && widget.eCodes!.isNotEmpty) {
          _controller.selectedEngineerCode.value = widget.eCodes!;
          _controller.selectedEngineerName.value = _controller.engineers
              .firstWhere((er) => er.eCode == widget.eCodes!)
              .eName;
        }
      }
    }
  }

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
                  key: _controller.manageUserFormKey,
                  child: Column(
                    children: [
                      AppTextFormField(
                        controller: _controller.fullNameController,
                        hintText: 'Full Name',
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                        inputFormatters: [TitleCaseTextInputFormatter()],
                      ),
                      AppSpaces.v10,
                      AppTextFormField(
                        controller: _controller.mobileNoController,
                        hintText: 'Mobile Number',
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your mobile number';
                          }
                          if (value.length != 10) {
                            return 'Please enter a 10-digit mobile number';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          MobileNumberInputFormatter(),
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                      ),
                      AppSpaces.v10,
                      Obx(
                        () => AppTextFormField(
                          controller: _controller.passwordController,
                          hintText: 'Password',
                          isObscure: _controller.obscuredText.value,
                          suffixIcon: IconButton(
                            onPressed: () {
                              _controller.togglePasswordVisibility();
                            },
                            icon: Icon(
                              _controller.obscuredText.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 20,
                            ),
                          ),
                        ),
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
                          _controller.hasAttemptedSubmit.value = true;
                          if (_controller.manageUserFormKey.currentState!
                              .validate()) {
                            _controller.manageUser(
                              userId: widget.isEdit ? widget.userId! : 0,
                            );
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
