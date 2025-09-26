import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:lottie/lottie.dart';

class AppLoadingOverlay extends StatelessWidget {
  final bool isLoading;

  const AppLoadingOverlay({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: kColorBlackWithOpacity,
      child: const Center(child: AppProgressIndicator()),
    );
  }
}

class AppProgressIndicator extends StatelessWidget {
  const AppProgressIndicator({super.key, this.size = 100});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Lottie.asset(
          'assets/loader.json',
          width: size,
          height: size,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
