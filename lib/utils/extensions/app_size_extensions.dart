import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gamdiwala/utils/screen_utils/app_screen_utils.dart';

extension AppSizeExtension on num {
  double get screenHeight => AppScreenUtils.height * this;

  double get screenWidth => AppScreenUtils.width * this;

  double get appHeight => ScreenUtil().setHeight(this);

  double get appWidth => ScreenUtil().setWidth(this);

  double get appText => ScreenUtil().setSp(this);
}
