import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/constants/image_constants.dart';
import 'package:gamdiwala/features/authentication/auth/screens/auth_screen.dart';
import 'package:gamdiwala/features/home/screens/home_screen.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/helpers/secure_storage_helper.dart';
import 'package:gamdiwala/utils/helpers/version_helper.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  String appVersion = '';
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    _initialize();
  }

  Future<void> _initialize() async {
    appVersion = await VersionHelper.getVersion();
    setState(() {});
    await Future.delayed(const Duration(seconds: 3));
    String? token = await SecureStorageHelper.read('token');

    Future.delayed(const Duration(seconds: 1), () {
      if (token != null && token.isNotEmpty) {
        Get.offAll(() => HomeScreen());
      } else {
        Get.offAll(() => AuthScreen());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FadeTransition(
            opacity: _animation,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(kImageSplash),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'v$appVersion',
                style: TextStyles.kBoldMontserrat(
                  fontSize: FontSizes.k16FontSize,
                  color: kColorBlack,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
