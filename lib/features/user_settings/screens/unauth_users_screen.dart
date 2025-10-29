import 'package:flutter/material.dart';
import 'package:gamdiwala/features/user_settings/controllers/unauth_users_controller.dart';
import 'package:gamdiwala/features/user_settings/widgets/unauth_users_card.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';
import 'package:gamdiwala/widgets/app_appbar.dart';
import 'package:gamdiwala/widgets/app_loading_overlay.dart';
import 'package:gamdiwala/widgets/app_text_form_field.dart';
import 'package:get/get.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';

class UnauthUsersScreen extends StatelessWidget {
  UnauthUsersScreen({super.key});

  final UnauthUsersController _controller = Get.put(UnauthUsersController());

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
              title: 'Unauthorised Users',
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
                  Obx(
                    () => _controller.unAuthorisedUsers.isNotEmpty
                        ? AppTextFormField(
                            controller: _controller.searchController,
                            hintText: 'Search',
                            onChanged: (value) {
                              _controller.filterUsers(value);
                            },
                          )
                        : const SizedBox.shrink(),
                  ),
                  AppSpaces.v10,
                  Obx(() {
                    if (_controller.isLoading.value) {
                      return const SizedBox.shrink();
                    }

                    if (_controller.filteredUnAuthorisedUsers.isEmpty &&
                        !_controller.isLoading.value) {
                      return Expanded(
                        child: Center(
                          child: Text(
                            'No unauthorised users.',
                            style: TextStyles.kMediumMontserrat(),
                          ),
                        ),
                      );
                    }

                    return Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _controller.filteredUnAuthorisedUsers.length,
                        itemBuilder: (context, index) {
                          final user =
                              _controller.filteredUnAuthorisedUsers[index];
                          return UnauthUsersCard(user: user);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
        Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
      ],
    );
  }
}
