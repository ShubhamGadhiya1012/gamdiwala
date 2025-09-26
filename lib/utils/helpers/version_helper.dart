import 'package:package_info_plus/package_info_plus.dart';

class VersionHelper {
  static Future<String> getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }
}
