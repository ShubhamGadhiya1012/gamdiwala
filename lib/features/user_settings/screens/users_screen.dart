import 'package:flutter/material.dart';
import 'package:gamdiwala/features/user_settings/controllers/users_controller.dart';
import 'package:gamdiwala/features/user_settings/screens/user_management_screen.dart';
import 'package:gamdiwala/features/user_settings/widgets/users_card.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';
import 'package:gamdiwala/widgets/app_appbar.dart';
import 'package:gamdiwala/widgets/app_loading_overlay.dart';
import 'package:gamdiwala/widgets/app_text_form_field.dart';
import 'package:get/get.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';

class UsersScreen extends StatelessWidget {
  UsersScreen({super.key, required this.fromWhere});

  final String fromWhere;

  final UsersController _controller = Get.put(UsersController());

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
              title: 'Users',
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
              child: Column(
                children: [
                  AppSpaces.v10,
                  AppTextFormField(
                    controller: _controller.searchController,
                    hintText: 'Search User',
                    onChanged: (value) {
                      _controller.filterUsers(value);
                    },
                  ),
                  AppSpaces.v10,
                  Obx(() {
                    if (_controller.filteredUsers.isEmpty &&
                        !_controller.isLoading.value) {
                      return Expanded(
                        child: Center(
                          child: Text(
                            'No users found.',
                            style: TextStyles.kMediumMontserrat(),
                          ),
                        ),
                      );
                    }

                    return Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _controller.filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _controller.filteredUsers[index];

                          return UsersCard(
                            user: user,
                            controller: _controller,
                            fromWhere: fromWhere,
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            floatingActionButton: fromWhere == 'M'
                ? FloatingActionButton(
                    onPressed: () {
                      Get.to(() => UserManagementScreen(isEdit: false));
                    },
                    shape: const CircleBorder(),
                    backgroundColor: kColorPrimary,
                    child: Icon(Icons.add, color: kColorWhite, size: 25),
                  )
                : null,
          ),
        ),

        Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
      ],
    );
  }
}
