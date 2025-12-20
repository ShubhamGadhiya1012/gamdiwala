import 'package:gamdiwala/features/authentication/auth/models/party_dm.dart';
import 'package:gamdiwala/features/home/models/vehicle_dm.dart';
import 'package:gamdiwala/features/invoice_entry/models/book_dm.dart';
import 'package:gamdiwala/features/invoice_entry/models/customer_account_dm.dart';
import 'package:gamdiwala/features/invoice_entry/models/customer_voucher_dm.dart';
import 'package:gamdiwala/features/invoice_entry/models/challan_dm.dart';
import 'package:gamdiwala/features/invoice_entry/models/invoice_party_dm.dart';
import 'package:gamdiwala/features/invoice_entry/models/item_tax_dm.dart';
import 'package:gamdiwala/features/invoice_entry/models/tax_dm.dart';
import 'package:gamdiwala/features/user_settings/models/salesman_dm.dart';
import 'package:gamdiwala/services/api_service.dart';
import 'package:gamdiwala/utils/helpers/secure_storage_helper.dart';

class InvoiceEntryRepo {
  static Future<List<InvoicePartyDm>> getParties({
    required String fromDate,
    required String toDate,
    required String billPeriod,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Invoice/getParties',
        token: token,
        queryParams: {
          'FromDate': fromDate,
          'ToDate': toDate,
          'BillPeriod': billPeriod,
        },
      );

      if (response == null || response['data'] == null) {
        return [];
      }

      return (response['data'] as List<dynamic>)
          .map((item) => InvoicePartyDm.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<ChallanDm>> getChallans({
    required String fromDate,
    required String toDate,
    required String pCode,
    required String vehicleCode,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Invoice/getChallans',
        token: token,
        queryParams: {
          'FromDate': fromDate,
          'ToDate': toDate,
          'PCode': pCode,
          'VehicleCode': vehicleCode,
        },
      );

      if (response == null || response['data'] == null) {
        return [];
      }

      return (response['data'] as List<dynamic>)
          .map((item) => ChallanDm.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<BookDm>> getBooks({required String dbc}) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Master/book',
        token: token,
        queryParams: {'DBC': dbc},
      );

      if (response == null || response['data'] == null) {
        return [];
      }

      return (response['data'] as List<dynamic>)
          .map((item) => BookDm.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<PartyDm>> getCustomers() async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Master/customer',
        token: token,
      );

      if (response == null || response['data'] == null) {
        return [];
      }

      return (response['data'] as List<dynamic>)
          .map((item) => PartyDm.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<CustomerAccountDm>> getCustomerAccounts() async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Master/customerAccount',
        token: token,
      );

      if (response == null || response['data'] == null) {
        return [];
      }

      return (response['data'] as List<dynamic>)
          .map((item) => CustomerAccountDm.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<TaxDm>> getTaxTypes() async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Master/tax',
        token: token,
      );

      if (response == null || response['data'] == null) {
        return [];
      }

      return (response['data'] as List<dynamic>)
          .map((item) => TaxDm.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<SalesmanDm>> getSalesmen() async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Master/salesmen',
        token: token,
      );

      if (response == null || response['data'] == null) {
        return [];
      }

      return (response['data'] as List<dynamic>)
          .map((item) => SalesmanDm.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<CustomiseVoucherDm>> getCustomiseVoucher() async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Master/customizeVoucher',
        token: token,
        queryParams: {'BOOKCODE': '1000', 'DBC': 'SALE'},
      );

      if (response == null || response['data'] == null) {
        return [];
      }

      return (response['data'] as List<dynamic>)
          .map((item) => CustomiseVoucherDm.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<VehicleDm>> getVehicles() async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Master/vehicle',
        token: token,
      );

      if (response == null || response['data'] == null) return [];

      return (response['data'] as List)
          .map((item) => VehicleDm.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<ItemTaxDm?> getItemTax({
    required String iCode,
    required String tCode,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Master/itemtax',
        token: token,
        queryParams: {'ICODE': iCode, 'TCODE': tCode},
      );

      if (response == null ||
          response['data'] == null ||
          response['data'].isEmpty) {
        return null;
      }

      return ItemTaxDm.fromJson(response['data'][0]);
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> saveSalesEntry({
    required String bookCode,
    required String salesInvo,
    required String date,
    required String amount,
    required String pCode,
    required String pCodeC,
    required String gstBillType,
    required String remark,
    required String tCode,
    required String vCode,
    required String typeOfInvoice,
    required String valueOfGoods,
    required List<Map<String, dynamic>> itemData,
    required List<Map<String, dynamic>> ledgerData,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    final Map<String, dynamic> requestBody = {
      "SalesInvno": salesInvo,
      "BookCode": bookCode,
      "Date": date,
      "Amount": amount,
      "PCode": pCode,
      "PCodeC": pCodeC,
      "GSTBillType": gstBillType,
      "Remark": remark,
      "TCode": tCode,
      "TypeofInvoice": typeOfInvoice,
      "ValueOfGoods": valueOfGoods,
      "VehicleCode": vCode,
      "ItemData": itemData,
      "LedgerData": ledgerData,
    };

    requestBody.forEach((key, value) {
      print('$key: $value');
    });

    try {
      var response = await ApiService.postRequest(
        endpoint: '/Invoice/salesEntry',
        requestBody: requestBody,
        token: token,
      );
      print(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
