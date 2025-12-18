import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';

class AppPageIndicator extends StatefulWidget {
  final int currentStep;
  final int totalSteps;

  const AppPageIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
  });

  @override
  State<AppPageIndicator> createState() => _AppPageIndicatorState();
}

class _AppPageIndicatorState extends State<AppPageIndicator> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPaddings.custom(bottom: 10, left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.totalSteps * 2 - 1, (index) {
          if (index.isEven) {
            final stepIndex = index ~/ 2;
            return _buildModernStepCircle(stepIndex);
          } else {
            final lineIndex = index ~/ 2;
            return _buildModernConnectingLine(lineIndex);
          }
        }),
      ),
    );
  }

  Widget _buildModernStepCircle(int stepIndex) {
    final isCompleted = stepIndex < widget.currentStep;
    final isActive = stepIndex == widget.currentStep;

    Widget circleContent;
    BoxDecoration decoration;

    if (isCompleted) {
      decoration = BoxDecoration(
        color: kColorPrimary,
        borderRadius: BorderRadius.circular(10),
      );
      circleContent = const Icon(Icons.check, color: kColorWhite, size: 20);
    } else if (isActive) {
      decoration = BoxDecoration(
        color: kColorPrimary,
        borderRadius: BorderRadius.circular(10),
      );
      circleContent = Text(
        '${stepIndex + 1}',
        style: TextStyles.kBoldMontserrat(
          fontSize: FontSizes.k16FontSize,
          color: kColorWhite,
        ),
      );
    } else {
      decoration = BoxDecoration(
        color: kColorGrey,
        borderRadius: BorderRadius.circular(10),
      );
      circleContent = Text(
        '${stepIndex + 1}',
        style: TextStyles.kMediumMontserrat(
          fontSize: FontSizes.k16FontSize,
          color: kColorDarkGrey,
        ),
      );
    }

    Widget circle = Container(
      width: 45,
      height: 45,
      decoration: decoration,
      child: Center(child: circleContent),
    );

    return circle;
  }

  Widget _buildModernConnectingLine(int lineIndex) {
    final isCompleted = lineIndex < widget.currentStep;
    final isActive =
        lineIndex == widget.currentStep - 1 && widget.currentStep > 0;

    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: isCompleted || isActive ? kColorPrimary : kColorGrey,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
