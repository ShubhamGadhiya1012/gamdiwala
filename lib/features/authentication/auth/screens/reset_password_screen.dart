import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/features/authentication/auth/controllers/reset_password_controller.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';
import 'package:gamdiwala/widgets/app_button.dart';
import 'package:gamdiwala/widgets/app_loading_overlay.dart';
import 'package:gamdiwala/widgets/app_text_form_field.dart';
import 'package:get/get.dart';

class ResetPasswordScreen extends StatelessWidget {
  ResetPasswordScreen({
    super.key,
    required this.mobileNumber,
    required this.fullName,
  });

  final String mobileNumber;
  final String fullName;

  final ResetPasswordController _controller = Get.put(
    ResetPasswordController(),
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
            resizeToAvoidBottomInset: false,
            body: Center(
              child: SingleChildScrollView(
                padding: AppPaddings.ph30,
                child: Form(
                  key: _controller.resetPasswordFormKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, $fullName',
                        style: TextStyles.kSemiBoldMontserrat(
                          color: kColorPrimary,
                          fontSize: FontSizes.k30FontSize,
                        ),
                      ),
                      Text(
                        'Please enter a new password to continue.',
                        style: TextStyles.kRegularMontserrat(
                          fontSize: FontSizes.k16FontSize,
                        ),
                      ),
                      AppSpaces.v40,
                      Obx(
                        () => AppTextFormField(
                          controller: _controller.newPasswordController,
                          hintText: 'New Password',
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a valid new password';
                            }
                            return null;
                          },
                          isObscure: _controller.obscuredNewPassword.value,
                          suffixIcon: IconButton(
                            onPressed: () {
                              _controller.toggleNewPasswordVisibility();
                            },
                            icon: Icon(
                              _controller.obscuredNewPassword.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      AppSpaces.v16,
                      Obx(
                        () => AppTextFormField(
                          controller: _controller.confirmPasswordController,
                          hintText: 'Confirm Password',
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value !=
                                _controller.newPasswordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                          isObscure: _controller.obscuredConfirmPassword.value,
                          suffixIcon: IconButton(
                            onPressed: () {
                              _controller.toggleConfirmPasswordVisibility();
                            },
                            icon: Icon(
                              _controller.obscuredConfirmPassword.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      AppSpaces.v30,
                      AppButton(
                        title: 'Reset Password',
                        onPressed: () {
                          _controller.hasAttemptedSubmit.value = true;
                          if (_controller.resetPasswordFormKey.currentState!
                              .validate()) {
                            FocusManager.instance.primaryFocus?.unfocus();

                            _controller.resetPassword(
                              mobileNumber: mobileNumber,
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
}
