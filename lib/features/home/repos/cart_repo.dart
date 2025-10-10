import 'package:gamdiwala/features/home/models/address_dm.dart';
import 'package:gamdiwala/features/home/models/cart_item_dm.dart';
import 'package:gamdiwala/features/home/models/driver_dm.dart';
import 'package:gamdiwala/features/home/models/vehicle_dm.dart';
import 'package:gamdiwala/services/api_service.dart';
import 'package:gamdiwala/utils/helpers/secure_storage_helper.dart';

class CartRepo {
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

  static Future<dynamic> addToCart({
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

  static Future<List<VehicleDm>> getVehicles() async {
    String? token = await SecureStorageHelper.read('token');

    final response = await ApiService.getRequest(
      endpoint: '/Master/vehicle',
      token: token,
    );

    if (response == null || response['data'] == null) return [];

    return (response['data'] as List)
        .map((item) => VehicleDm.fromJson(item))
        .toList();
  }

  static Future<List<DriverDm>> getDrivers() async {
    String? token = await SecureStorageHelper.read('token');

    final response = await ApiService.getRequest(
      endpoint: '/Master/driver',
      token: token,
    );

    if (response == null || response['data'] == null) return [];

    return (response['data'] as List)
        .map((item) => DriverDm.fromJson(item))
        .toList();
  }

  static Future<AddressDm?> getAddress({required String pCode}) async {
    String? token = await SecureStorageHelper.read('token');

    final response = await ApiService.getRequest(
      endpoint: '/Master/address',
      token: token,
      queryParams: {'PCODE': pCode},
    );

    if (response == null ||
        response['data'] == null ||
        (response['data'] as List).isEmpty) {
      return null;
    }

    return AddressDm.fromJson(response['data'][0]);
  }

  static Future<dynamic> savePlaceOrder({
    required String pCode,
    required String orderDate,
    required String dCode,
    required String vCode,
    String? remark,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    final requestBody = {
      "PCode": pCode,
      "Date": orderDate,
      "DCode": dCode,
      "VCode": vCode,
      "Remark": remark ?? "",
    };
    print(requestBody);
    try {
      final response = await ApiService.postRequest(
        endpoint: '/Cart/confirmOrder',
        token: token,
        requestBody: requestBody,
      );
      return response;
    } catch (e) {
      throw e.toString();
    }
  }
}
