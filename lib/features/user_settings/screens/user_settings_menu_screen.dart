// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/constants/image_constants.dart';
import 'package:gamdiwala/features/user_settings/screens/unauth_users_screen.dart';
import 'package:gamdiwala/features/user_settings/screens/users_screen.dart';
import 'package:gamdiwala/features/user_settings/widgets/user_settings_menu_card.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';
import 'package:gamdiwala/widgets/app_appbar.dart';
import 'package:get/get.dart';


class UserSettingsMenuScreen extends StatelessWidget {
  const UserSettingsMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppbar(
        title: 'User Settings',
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios, size: 20, color: kColorTextPrimary),
        ),
      ),
      body: Padding(
        padding: AppPaddings.p20,
        child: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 0.75,
          children: [
            UserSettingsMenuCard(
              iconPath: kIconUserAuthorisation,
              label: 'User\nAuth',
              onTap: () {
                Get.to(() => UnauthUsersScreen());
              },
            ),
            UserSettingsMenuCard(
              iconPath: kIconUserRights,
              label: 'User\nRights',
              onTap: () {
                Get.to(() => UsersScreen(fromWhere: 'R'));
              },
            ),
            UserSettingsMenuCard(
              iconPath: kIconUserManagement,
              label: 'Manage\nUser',
              onTap: () {
                Get.to(() => UsersScreen(fromWhere: 'M'));
              },
            ),
          ],
        ),
      ),
    );
  }
}
