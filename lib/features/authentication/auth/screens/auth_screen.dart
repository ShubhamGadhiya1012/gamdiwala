import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/features/authentication/auth/controllers/auth_controller.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/formatters/text_input_formatters.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';
import 'package:gamdiwala/widgets/app_button.dart';
import 'package:gamdiwala/widgets/app_loading_overlay.dart';
import 'package:gamdiwala/widgets/app_text_form_field.dart';
import 'package:get/get.dart';

class AuthScreen extends StatelessWidget {
  AuthScreen({super.key});

  final AuthController _controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },

          onPanUpdate: (details) {
            if (details.delta.dx > 10 && _controller.isLoginMode.value) {
              _controller.toggleMode();
            } else if (details.delta.dx < -10 &&
                !_controller.isLoginMode.value) {
              _controller.toggleMode();
            }
          },
          child: Scaffold(
            backgroundColor: kColorWhite,
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: AppPaddings.ph30,
                child: Column(
                  children: [
                    AppSpaces.v60,
                    _buildHeader(),
                    AppSpaces.v60,
                    _buildToggleButton(),
                    AppSpaces.v60,
                    _buildForm(),
                  ],
                ),
              ),
            ),
          ),
        ),
        Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
      ],
    );
  }

  Widget _buildHeader() {
    return Obx(
      () => Column(
        children: [
          Text(
            _controller.isLoginMode.value
                ? 'Welcome back'
                : 'Create an account',
            style: TextStyles.kBoldMontserrat(
              fontSize: FontSizes.k28FontSize,
              color: kColorPrimary,
            ),
          ),
          AppSpaces.v8,
          Text(
            _controller.isLoginMode.value
                ? 'Sign in to continue'
                : 'Fill details to register',
            style: TextStyles.kRegularMontserrat(
              fontSize: FontSizes.k14FontSize,
              color: kColorDarkGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton() {
    return Obx(
      () => Container(
        height: 50,
        decoration: BoxDecoration(
          color: kColorLightGrey,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            _buildToggleOption('Register', !_controller.isLoginMode.value),

            _buildToggleOption('Login', _controller.isLoginMode.value),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleOption(String title, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if ((title == 'Login' && !_controller.isLoginMode.value) ||
              (title == 'Register' && _controller.isLoginMode.value)) {
            _controller.toggleMode();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: 50,
          decoration: BoxDecoration(
            color: isActive ? kColorPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyles.kSemiBoldMontserrat(
                fontSize: FontSizes.k16FontSize,
                color: isActive ? kColorWhite : kColorDarkGrey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Obx(
      () => AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: _controller.isLoginMode.value
                  ? const Offset(-1.0, 0.0)
                  : const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        child: _controller.isLoginMode.value
            ? _buildLoginForm()
            : _buildRegisterForm(),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _controller.loginFormKey,
      child: Column(
        key: const ValueKey('login'),
        children: [
          AppTextFormField(
            controller: _controller.loginMobileController,
            hintText: 'Mobile Number',
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter a mobile number';
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
          AppSpaces.v16,
          Obx(
            () => AppTextFormField(
              controller: _controller.loginPasswordController,
              hintText: 'Password',
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a password';
                }
                return null;
              },
              isObscure: _controller.obscuredLoginPassword.value,
              suffixIcon: IconButton(
                onPressed: () {
                  _controller.toggleLoginPasswordVisibility();
                },
                icon: Icon(
                  _controller.obscuredLoginPassword.value
                      ? Icons.visibility
                      : Icons.visibility_off,
                  size: 20,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
          AppSpaces.v30,
          AppButton(
            title: 'Sign In',
            onPressed: () {
              _controller.hasAttemptedLogin.value = true;
              FocusManager.instance.primaryFocus?.unfocus();
              if (_controller.loginFormKey.currentState!.validate()) {
                _controller.loginUser();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: _controller.registerFormKey,
      child: Column(
        key: const ValueKey('register'),
        children: [
          Row(
            children: [
              Expanded(
                child: AppTextFormField(
                  controller: _controller.firstNameController,
                  hintText: 'First Name',
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                  inputFormatters: [TitleCaseTextInputFormatter()],
                ),
              ),
              AppSpaces.h16,
              Expanded(
                child: AppTextFormField(
                  controller: _controller.lastNameController,
                  hintText: 'Last Name',
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                  inputFormatters: [TitleCaseTextInputFormatter()],
                ),
              ),
            ],
          ),
          AppSpaces.v16,
          AppTextFormField(
            controller: _controller.registerMobileController,
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
          AppSpaces.v16,
          Obx(
            () => AppTextFormField(
              controller: _controller.registerPasswordController,
              hintText: 'Password',
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a password';
                }
                if (value.length < 3) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
              isObscure: _controller.obscuredRegisterPassword.value,
              suffixIcon: IconButton(
                onPressed: () {
                  _controller.toggleRegisterPasswordVisibility();
                },
                icon: Icon(
                  _controller.obscuredRegisterPassword.value
                      ? Icons.visibility
                      : Icons.visibility_off,
                  size: 20,
                  color: Colors.grey[600],
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
                if (value != _controller.registerPasswordController.text) {
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
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
          AppSpaces.v30,
          AppButton(
            title: 'Register',
            onPressed: () {
              _controller.hasAttemptedRegister.value = true;
              FocusManager.instance.primaryFocus?.unfocus();
              if (_controller.registerFormKey.currentState!.validate()) {
                _controller.registerUser();
              }
            },
          ),
        ],
      ),
    );
  }
}
