import 'package:flutter/material.dart';
import 'package:gamdiwala/utils/extensions/app_size_extensions.dart';

class AppPaddings {
  //* All Side Padding
  static EdgeInsets get p2 => EdgeInsets.all(2.appWidth);
  static EdgeInsets get p4 => EdgeInsets.all(4.appWidth);
  static EdgeInsets get p6 => EdgeInsets.all(6.appWidth);
  static EdgeInsets get p8 => EdgeInsets.all(8.appWidth);
  static EdgeInsets get p10 => EdgeInsets.all(10.appWidth);
  static EdgeInsets get p12 => EdgeInsets.all(12.appWidth);
  static EdgeInsets get p14 => EdgeInsets.all(14.appWidth);
  static EdgeInsets get p16 => EdgeInsets.all(16.appWidth);
  static EdgeInsets get p18 => EdgeInsets.all(18.appWidth);
  static EdgeInsets get p20 => EdgeInsets.all(20.appWidth);
  static EdgeInsets get p22 => EdgeInsets.all(22.appWidth);
  static EdgeInsets get p24 => EdgeInsets.all(24.appWidth);
  static EdgeInsets get p26 => EdgeInsets.all(26.appWidth);
  static EdgeInsets get p28 => EdgeInsets.all(28.appWidth);
  static EdgeInsets get p30 => EdgeInsets.all(30.appWidth);
  static EdgeInsets get p32 => EdgeInsets.all(32.appWidth);
  static EdgeInsets get p34 => EdgeInsets.all(34.appWidth);
  static EdgeInsets get p36 => EdgeInsets.all(36.appWidth);
  static EdgeInsets get p38 => EdgeInsets.all(38.appWidth);
  static EdgeInsets get p40 => EdgeInsets.all(40.appWidth);

  //* Horizontal Padding
  static EdgeInsets get ph2 => EdgeInsets.symmetric(horizontal: 2.appWidth);
  static EdgeInsets get ph4 => EdgeInsets.symmetric(horizontal: 4.appWidth);
  static EdgeInsets get ph6 => EdgeInsets.symmetric(horizontal: 6.appWidth);
  static EdgeInsets get ph8 => EdgeInsets.symmetric(horizontal: 8.appWidth);
  static EdgeInsets get ph10 => EdgeInsets.symmetric(horizontal: 10.appWidth);
  static EdgeInsets get ph12 => EdgeInsets.symmetric(horizontal: 12.appWidth);
  static EdgeInsets get ph14 => EdgeInsets.symmetric(horizontal: 14.appWidth);
  static EdgeInsets get ph16 => EdgeInsets.symmetric(horizontal: 16.appWidth);
  static EdgeInsets get ph18 => EdgeInsets.symmetric(horizontal: 18.appWidth);
  static EdgeInsets get ph20 => EdgeInsets.symmetric(horizontal: 20.appWidth);
  static EdgeInsets get ph22 => EdgeInsets.symmetric(horizontal: 22.appWidth);
  static EdgeInsets get ph24 => EdgeInsets.symmetric(horizontal: 24.appWidth);
  static EdgeInsets get ph26 => EdgeInsets.symmetric(horizontal: 26.appWidth);
  static EdgeInsets get ph28 => EdgeInsets.symmetric(horizontal: 28.appWidth);
  static EdgeInsets get ph30 => EdgeInsets.symmetric(horizontal: 30.appWidth);
  static EdgeInsets get ph32 => EdgeInsets.symmetric(horizontal: 32.appWidth);
  static EdgeInsets get ph34 => EdgeInsets.symmetric(horizontal: 34.appWidth);
  static EdgeInsets get ph36 => EdgeInsets.symmetric(horizontal: 36.appWidth);
  static EdgeInsets get ph38 => EdgeInsets.symmetric(horizontal: 38.appWidth);
  static EdgeInsets get ph40 => EdgeInsets.symmetric(horizontal: 40.appWidth);

  //* Vertical Padding
  static EdgeInsets get pv2 => EdgeInsets.symmetric(vertical: 2.appHeight);
  static EdgeInsets get pv4 => EdgeInsets.symmetric(vertical: 4.appHeight);
  static EdgeInsets get pv6 => EdgeInsets.symmetric(vertical: 6.appHeight);
  static EdgeInsets get pv8 => EdgeInsets.symmetric(vertical: 8.appHeight);
  static EdgeInsets get pv10 => EdgeInsets.symmetric(vertical: 10.appHeight);
  static EdgeInsets get pv12 => EdgeInsets.symmetric(vertical: 12.appHeight);
  static EdgeInsets get pv14 => EdgeInsets.symmetric(vertical: 14.appHeight);
  static EdgeInsets get pv16 => EdgeInsets.symmetric(vertical: 16.appHeight);
  static EdgeInsets get pv18 => EdgeInsets.symmetric(vertical: 18.appHeight);
  static EdgeInsets get pv20 => EdgeInsets.symmetric(vertical: 20.appHeight);
  static EdgeInsets get pv22 => EdgeInsets.symmetric(vertical: 22.appHeight);
  static EdgeInsets get pv24 => EdgeInsets.symmetric(vertical: 24.appHeight);
  static EdgeInsets get pv26 => EdgeInsets.symmetric(vertical: 26.appHeight);
  static EdgeInsets get pv28 => EdgeInsets.symmetric(vertical: 28.appHeight);
  static EdgeInsets get pv30 => EdgeInsets.symmetric(vertical: 30.appHeight);
  static EdgeInsets get pv32 => EdgeInsets.symmetric(vertical: 32.appHeight);
  static EdgeInsets get pv34 => EdgeInsets.symmetric(vertical: 34.appHeight);
  static EdgeInsets get pv36 => EdgeInsets.symmetric(vertical: 36.appHeight);
  static EdgeInsets get pv38 => EdgeInsets.symmetric(vertical: 38.appHeight);
  static EdgeInsets get pv40 => EdgeInsets.symmetric(vertical: 40.appHeight);

  //* Combined Horizontal and Vertical Padding
  static EdgeInsets combined({
    required double horizontal,
    required double vertical,
  }) {
    return EdgeInsets.symmetric(
      horizontal: horizontal.appWidth,
      vertical: vertical.appHeight,
    );
  }

  //* Custom Padding
  static EdgeInsets custom({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.only(
      left: left.appWidth,
      top: top.appHeight,
      right: right.appWidth,
      bottom: bottom.appHeight,
    );
  }
}
