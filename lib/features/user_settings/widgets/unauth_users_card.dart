// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/features/user_settings/models/unauth_user_dm.dart';
import 'package:gamdiwala/features/user_settings/screens/user_authorisation_screen.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';
import 'package:gamdiwala/widgets/app_card.dart';
import 'package:gamdiwala/widgets/app_title_value_container.dart';
import 'package:get/get.dart';

class UnauthUsersCard extends StatelessWidget {
  const UnauthUsersCard({super.key, required this.user});

  final UnauthUserDm user;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.fullName,
                style: TextStyles.kSemiBoldMontserrat(
                  fontSize: FontSizes.k18FontSize,
                ),
              ),
              AppSpaces.v10,
              AppTitleValueContainer(title: 'Mobile No.', value: user.mobileNo),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: CircleAvatar(
              backgroundColor: kColorPrimary.withOpacity(0.15),
              radius: 12,
              child: Icon(
                Icons.north_east,
                size: 14,
                color: kColorTextPrimary.withOpacity(0.75),
              ),
            ),
          ),
        ],
      ),
      onTap: () {
        Get.to(
          () => UserAuthorisationScreen(
            userId: user.userId,
            fullName: user.fullName,
            mobileNo: user.mobileNo,
          ),
        );
      },
    );
  }
}
