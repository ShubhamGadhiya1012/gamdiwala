// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/constants/image_constants.dart';
import 'package:gamdiwala/features/authentication/auth/screens/reset_password_screen.dart';
import 'package:gamdiwala/features/authentication/auth/screens/select_party_screen.dart';
import 'package:gamdiwala/features/profile/controllers/profile_controller.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';
import 'package:gamdiwala/widgets/app_appbar.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final ProfileController _controller = Get.put(ProfileController());
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppbar(
        title: 'Profile',
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios, size: 20, color: kColorPrimary),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              kColorWhite,
              kColorWhite.withOpacity(0.95),
              kColorPrimary.withOpacity(0.05),
            ],
            stops: [0.0, 0.7, 1.0],
          ),
        ),
        child: Padding(
          padding: AppPaddings.p10,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                AppSpaces.v10,

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      padding: AppPaddings.p20,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            kColorPrimary,
                            kColorPrimary.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: kColorPrimary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                            spreadRadius: 2,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Hero(
                            tag: "profile_icon",
                            flightShuttleBuilder:
                                (
                                  BuildContext flightContext,
                                  Animation<double> animation,
                                  HeroFlightDirection flightDirection,
                                  BuildContext fromHeroContext,
                                  BuildContext toHeroContext,
                                ) {
                                  return AnimatedBuilder(
                                    animation: animation,
                                    builder: (context, child) {
                                      return Container(
                                        padding: EdgeInsets.all(
                                          animation.value * 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color.lerp(
                                            Colors.transparent,
                                            kColorWhite.withOpacity(0.15),
                                            animation.value,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16 * animation.value,
                                          ),
                                        ),
                                        child: SvgPicture.asset(
                                          kIconProfile,
                                          height: 18 + (animation.value * 57),
                                          colorFilter: ColorFilter.mode(
                                            Color.lerp(
                                              kColorPrimary,
                                              kColorWhite,
                                              animation.value,
                                            )!,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: kColorWhite.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: kColorWhite.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: SvgPicture.asset(
                                kIconProfile,
                                height: 75,
                                colorFilter: ColorFilter.mode(
                                  kColorWhite,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                          AppSpaces.h20,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(
                                  () => Text(
                                    _controller.fullName.value,
                                    style: TextStyles.kSemiBoldMontserrat(
                                      fontSize: FontSizes.k24FontSize,
                                      color: kColorWhite,
                                    ),
                                  ),
                                ),
                                AppSpaces.v4,
                                Obx(
                                  () => Text(
                                    _controller.getUserRole(
                                      _controller.userType.value,
                                    ),
                                    style: TextStyles.kRegularMontserrat(
                                      fontSize: FontSizes.k16FontSize,
                                      color: kColorWhite.withOpacity(0.9),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                AppSpaces.v30,

                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      'Account Settings',
                      style: TextStyles.kSemiBoldMontserrat(
                        fontSize: FontSizes.k20FontSize,
                        color: kColorTextPrimary,
                      ),
                    ),
                  ),
                ),
                AppSpaces.v14,
                _buildAnimatedMenuTile(
                  delay: 200,
                  iconPath: kIconResetPassword,
                  title: 'Reset Password',
                  onTap: () {
                    Get.to(
                      () => ResetPasswordScreen(
                        mobileNumber: _controller.mobileNumber.value,
                        fullName: _controller.fullName.value,
                      ),
                    );
                  },
                ),
                AppSpaces.v14,
                _buildAnimatedMenuTile(
                  delay: 200,
                  iconPath: kIconResetPassword,
                  title: 'Change Party',
                  onTap: () {
                    Get.offAll(() => SelectPartyScreen());
                  },
                ),
                AppSpaces.v14,
                _buildAnimatedMenuTile(
                  delay: 300,
                  iconPath: kIconLogOut,
                  title: 'Log Out',
                  isDestructive: true,
                  onTap: () {
                    _showBeautifulLogoutDialog();
                  },
                ),

                AppSpaces.v30,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedMenuTile({
    required int delay,
    required String iconPath,
    required String title,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: kColorWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDestructive
                ? Colors.red.withOpacity(0.1)
                : kColorPrimary.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDestructive ? Colors.red : kColorPrimary).withOpacity(
                0.08,
              ),
              blurRadius: 15,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: (isDestructive ? Colors.red : kColorPrimary)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        iconPath,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          isDestructive ? Colors.red : kColorPrimary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),

                  AppSpaces.h14,

                  Expanded(
                    child: Text(
                      title,
                      style: TextStyles.kSemiBoldMontserrat(
                        fontSize: FontSizes.k16FontSize,
                        color: isDestructive ? Colors.red : kColorTextPrimary,
                      ),
                    ),
                  ),

                  Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: (isDestructive ? Colors.red : kColorPrimary)
                        .withOpacity(0.6),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBeautifulLogoutDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          ),
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              backgroundColor: kColorWhite,
              contentPadding: EdgeInsets.zero,
              content: Container(
                width: 320,
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFFF6B6B).withOpacity(0.3),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          kIconLogOut,
                          height: 35,
                          colorFilter: ColorFilter.mode(
                            kColorWhite,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    AppSpaces.v24,
                    Text(
                      'Log Out',
                      style: TextStyles.kSemiBoldMontserrat(
                        fontSize: 26,
                        color: kColorTextPrimary,
                      ),
                    ),
                    AppSpaces.v10,
                    Text(
                      'Are you sure you want to\nlog out from your account?',
                      style: TextStyles.kRegularMontserrat(
                        fontSize: FontSizes.k15FontSize,
                        color: kColorDarkGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppSpaces.v30,
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Get.back(),
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: kColorGrey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  'Cancel',
                                  style: TextStyles.kSemiBoldMontserrat(
                                    fontSize: FontSizes.k16FontSize,
                                    color: kColorTextPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        AppSpaces.h12,
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Get.back();
                              _controller.logoutUser();
                            },
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFFF6B6B),
                                    Color(0xFFEE5A6F),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFFFF6B6B).withOpacity(0.4),
                                    blurRadius: 16,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  'Log Out',
                                  style: TextStyles.kSemiBoldMontserrat(
                                    fontSize: FontSizes.k16FontSize,
                                    color: kColorWhite,
                                  ),
                                ),
                              ),
                            ),
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
      },
    );
  }
}
