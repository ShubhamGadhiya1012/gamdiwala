// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:gamdiwala/features/user_settings/controllers/users_controller.dart';
import 'package:gamdiwala/features/user_settings/models/user_dm.dart';
import 'package:gamdiwala/features/user_settings/screens/user_access_screen.dart';
import 'package:gamdiwala/features/user_settings/screens/user_management_screen.dart';
import 'package:gamdiwala/widgets/app_card.dart';
import 'package:gamdiwala/widgets/app_title_value_container.dart';
import 'package:get/get.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';

class UsersCard extends StatelessWidget {
  const UsersCard({
    super.key,
    required this.user,
    required this.fromWhere,
    required UsersController controller,
  }) : _controller = controller;

  final UserDm user;
  final UsersController _controller;
  final String fromWhere;

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
              Row(
                children: [
                  Expanded(
                    child: AppTitleValueContainer(
                      title: 'Designation',
                      value: _controller.getUserDesignation(user.userType),
                    ),
                  ),
                  AppSpaces.h10,
                  Expanded(
                    child: AppTitleValueContainer(
                      title: 'Mobile No.',
                      value: user.mobileNo,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: CircleAvatar(
              backgroundColor: kColorTextPrimary.withOpacity(0.15),
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
        if (fromWhere == 'R') {
          Get.to(
            () => UserAccessScreen(
              fullName: user.fullName,
              userId: user.userId,
              appAccess: user.appAccess,
            ),
          );
        } else if (fromWhere == 'M') {
          Get.to(
            () => UserManagementScreen(
              isEdit: true,
              fullName: user.fullName,
              mobileNo: user.mobileNo,
              userId: user.userId,
              isAppAccess: user.appAccess,
              userType: user.userType,
              seCodes: user.seCodes,
              pCodes: user.pCodes,
              eCodes: user.eCodes,
            ),
          );
        }
      },
    );
  }
}
