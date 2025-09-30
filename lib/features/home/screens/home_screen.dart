// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/constants/image_constants.dart';
import 'package:gamdiwala/features/home/controllers/home_controller.dart';
import 'package:gamdiwala/features/home/models/home_menu_item_dm.dart';
import 'package:gamdiwala/features/home/widgets/sidebar_menu_item.dart';
import 'package:gamdiwala/features/profile/screens/profile_screen.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';
import 'package:gamdiwala/widgets/app_loading_overlay.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final HomeController _controller = Get.put(HomeController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          key: _scaffoldKey,
          backgroundColor: kColorWhite,
          drawer: _buildDrawer(context),
          body: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: Container(
                  color: Colors.grey[50],
                  child: Obx(() {
                    final accessMap = {
                      for (var menu in _controller.menuAccess)
                        menu.menuName: menu.access,
                    };

                    final visibleMenuItems = _controller.menuItems
                        .where((item) => accessMap[item.menuName] ?? false)
                        .toList();

                    if (visibleMenuItems.isEmpty &&
                        !_controller.isLoading.value) {
                      return _buildEmptyState(context);
                    }

                    final selectedIndex = _controller.selectedMenuIndex.value;
                    if (selectedIndex >= 0 &&
                        selectedIndex < visibleMenuItems.length) {
                      final selectedMenu = visibleMenuItems[selectedIndex];
                      return _buildContentArea(context, selectedMenu);
                    }

                    return const SizedBox.shrink();
                  }),
                ),
              ),
            ],
          ),
        ),
        Obx(() => AppLoadingOverlay(isLoading: _controller.isLoading.value)),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: kColorWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.menu, color: kColorPrimary),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          AppSpaces.h8,
          Expanded(
            child: Obx(
              () => Text(
                _controller.company.value,
                style: TextStyles.kBoldMontserrat(
                  fontSize: FontSizes.k18FontSize,
                  color: kColorPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          IconButton(
            icon: Hero(
              tag: "profile_icon",
              child: SvgPicture.asset(
                kIconProfile,
                height: 24,
                width: 24,
                colorFilter: ColorFilter.mode(kColorPrimary, BlendMode.srcIn),
              ),
            ),
            onPressed: () {
              Get.to(() => ProfileScreen());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: kColorWhite,
      child: Obx(() {
        final accessMap = {
          for (var menu in _controller.menuAccess) menu.menuName: menu.access,
        };

        final visibleMenuItems = _controller.menuItems
            .where((item) => accessMap[item.menuName] ?? false)
            .toList();

        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    kColorPrimary,
                    kColorPrimary.withOpacity(0.85),
                    kColorPrimary.withOpacity(0.7),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: kColorPrimary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Obx(
                      () => AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _controller.company.value,
                          key: ValueKey(_controller.company.value),
                          style: TextStyles.kBoldMontserrat(
                            fontSize: FontSizes.k20FontSize,
                            color: kColorWhite,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: kColorWhite),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: visibleMenuItems.isEmpty
                  ? Center(
                      child: Padding(
                        padding: AppPaddings.p20,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 48,
                              color: kColorDarkGrey.withOpacity(0.5),
                            ),
                            AppSpaces.h16,
                            Text(
                              'No Access',
                              style: TextStyles.kSemiBoldMontserrat(
                                fontSize: FontSizes.k16FontSize,
                                color: kColorDarkGrey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            AppSpaces.h8,
                            Text(
                              'Contact your administrator',
                              style: TextStyles.kRegularMontserrat(
                                fontSize: FontSizes.k14FontSize,
                                color: kColorDarkGrey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      backgroundColor: kColorWhite,
                      color: kColorPrimary,
                      strokeWidth: 2.5,
                      onRefresh: () async {
                        await _controller.checkAppVersion();
                        await _controller.getUserAccess();
                        await _controller.getCounts();
                      },
                      child: ListView.builder(
                        padding: AppPaddings.custom(top: 8, bottom: 8),
                        itemCount: visibleMenuItems.length,
                        itemBuilder: (context, index) {
                          final menu = visibleMenuItems[index];
                          return Obx(() {
                            final isExpanded =
                                _controller.expandedMenuIndex.value == index;
                            final hasSubMenus =
                                menu.subMenus != null &&
                                menu.subMenus!.isNotEmpty;

                            return Column(
                              children: [
                                SidebarMenuItem(
                                  menu: menu,
                                  isSelected:
                                      _controller.selectedMenuIndex.value ==
                                      index,
                                  isExpanded: isExpanded,
                                  hasSubMenus: hasSubMenus,
                                  onTap: () {
                                    if (hasSubMenus) {
                                      _controller.toggleMenuExpansion(index);
                                    } else {
                                      _controller.selectedMenuIndex.value =
                                          index;
                                      Get.back();
                                      if (menu.onTap != null) {
                                        menu.onTap!();
                                      }
                                    }
                                  },
                                ),
                                if (hasSubMenus && isExpanded)
                                  ...menu.subMenus!.map((subMenu) {
                                    return SubMenuItem(
                                      menu: subMenu,
                                      onTap: () {
                                        Get.back();
                                        if (subMenu.onTap != null) {
                                          subMenu.onTap!();
                                        }
                                      },
                                    );
                                  }),
                              ],
                            );
                          });
                        },
                      ),
                    ),
            ),
            Container(
              padding: AppPaddings.p16,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    kColorPrimary.withOpacity(0.3),
                    kColorPrimary.withOpacity(0.3),
                    kColorPrimary.withOpacity(0.3),
                    kColorPrimary.withOpacity(0.3),
                    kColorPrimary.withOpacity(0.3),
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  'v${_controller.appVersion.value}',
                  style: TextStyles.kBoldMontserrat(
                    fontSize: FontSizes.k12FontSize,
                    color: kColorWhite,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard_outlined,
            size: 80,
            color: kColorDarkGrey.withOpacity(0.3),
          ),
          AppSpaces.h24,
          Text(
            'Welcome to Dashboard',
            style: TextStyles.kBoldMontserrat(
              fontSize: FontSizes.k24FontSize,
              color: kColorTextPrimary,
            ),
          ),
          AppSpaces.h12,
          Padding(
            padding: AppPaddings.p20,
            child: Text(
              'Select a menu to get started',
              style: TextStyles.kRegularMontserrat(
                fontSize: FontSizes.k16FontSize,
                color: kColorDarkGrey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentArea(BuildContext context, HomeMenuItemDm selectedMenu) {
    if (selectedMenu.screen != null) {
      return selectedMenu.screen!;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: AppPaddings.p20,
          decoration: BoxDecoration(
            color: kColorWhite,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                selectedMenu.icon,
                height: 28,
                width: 28,
                colorFilter: ColorFilter.mode(kColorPrimary, BlendMode.srcIn),
              ),
              AppSpaces.h16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedMenu.menuName,
                      style: TextStyles.kBoldMontserrat(
                        fontSize: FontSizes.k20FontSize,
                        color: kColorTextPrimary,
                      ),
                    ),
                    if (selectedMenu.count.isNotEmpty) ...[
                      AppSpaces.h4,
                      Text(
                        selectedMenu.count,
                        style: TextStyles.kRegularMontserrat(
                          fontSize: FontSizes.k14FontSize,
                          color: kColorDarkGrey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: AppPaddings.p20,
              child: Container(
                padding: AppPaddings.p24,
                decoration: BoxDecoration(
                  color: kColorWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.construction_outlined,
                      size: 64,
                      color: kColorPrimary.withOpacity(0.6),
                    ),
                    AppSpaces.h16,
                    Text(
                      '${selectedMenu.menuName} Content',
                      style: TextStyles.kSemiBoldMontserrat(
                        fontSize: FontSizes.k18FontSize,
                        color: kColorTextPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppSpaces.h8,
                    Text(
                      'This section is under development',
                      style: TextStyles.kRegularMontserrat(
                        fontSize: FontSizes.k14FontSize,
                        color: kColorDarkGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
