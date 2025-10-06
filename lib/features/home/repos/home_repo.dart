import 'package:gamdiwala/features/home/models/cart_item_dm.dart';
import 'package:gamdiwala/features/home/models/item_dm.dart';
import 'package:gamdiwala/services/api_service.dart';
import 'package:gamdiwala/utils/helpers/secure_storage_helper.dart';

class HomeRepo {
  static Future<List<ItemDm>> getItems({required String pCode}) async {
    String? token = await SecureStorageHelper.read('token');

    final response = await ApiService.getRequest(
      endpoint: '/Master/items',
      token: token,
      queryParams: {'PCODE': pCode},
    );

    if (response == null || response['data'] == null) return [];

    return (response['data'] as List)
        .map((item) => ItemDm.fromJson(item))
        .toList();
  }

  static Future<dynamic> checkVersion({
    required String version,
    required String deviceId,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Master/version',
        token: token,
        queryParams: {'Version': version, 'DeviceID': deviceId},
      );

      if (response == null) {
        return [];
      }

      if (response is List) {
        return response;
      }

      if (response is Map<String, dynamic> && response.containsKey('error')) {
        throw response['error'];
      }

      return [];
    } catch (e) {
      throw e.toString();
    }
  }

  static Future<dynamic> saveCartItem({
    required String pCode,
    required String iCode,
    required double qty,
    required double rate,
    required double amount,
    required double packQty,
    required double caratNos,
    required double caratQty,
    required double itemPack,
    required double fat,
    required double lr,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    final requestBody = {
      "PCode": pCode,
      "ICode": iCode,
      "Qty": qty,
      "Rate": rate,
      "Amount": amount,
      "PackQty": packQty,
      "CaratNos": caratNos,
      "CaratQty": caratQty,
      "ItemPack": itemPack,
      "Fat": fat,
      "LR": lr,
    };

    print(requestBody);

    try {
      final response = await ApiService.postRequest(
        endpoint: '/Cart/addToCart',
        token: token,
        requestBody: requestBody,
      );
      return response;
    } catch (e) {
      throw e.toString();
    }
  }

  static Future<List<CartItemDm>> getCartItems({required String pCode}) async {
    String? token = await SecureStorageHelper.read('token');

    final response = await ApiService.getRequest(
      endpoint: '/Cart/getCart',
      token: token,
      queryParams: {'PCODE': pCode},
    );

    if (response == null || response['data'] == null) return [];

    return (response['data'] as List)
        .map((item) => CartItemDm.fromJson(item))
        .toList();
  }
}
