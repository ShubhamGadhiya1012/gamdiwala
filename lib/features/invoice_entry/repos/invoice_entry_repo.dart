import 'package:gamdiwala/features/invoice_entry/models/book_dm.dart';
import 'package:gamdiwala/features/invoice_entry/models/customer_dm.dart';
import 'package:gamdiwala/features/invoice_entry/models/customer_voucher_dm.dart';
import 'package:gamdiwala/features/invoice_entry/models/invoice_dm.dart';
import 'package:gamdiwala/features/invoice_entry/models/invoice_party_dm.dart';
import 'package:gamdiwala/features/invoice_entry/models/tax_dm.dart';
import 'package:gamdiwala/features/user_settings/models/salesman_dm.dart';
import 'package:gamdiwala/services/api_service.dart';
import 'package:gamdiwala/utils/helpers/secure_storage_helper.dart';

class InvoiceEntryRepo {
  // Get Parties for filter
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

  // Get Challans
  static Future<List<InvoiceChallanDm>> getChallans({
    required String fromDate,
    required String toDate,
    required String pCode,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Invoice/getChallans',
        token: token,
        queryParams: {'FromDate': fromDate, 'ToDate': toDate, 'PCode': pCode},
      );

      if (response == null || response['data'] == null) {
        return [];
      }

      return (response['data'] as List<dynamic>)
          .map((item) => InvoiceChallanDm.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get Books
  static Future<List<BookDm>> getBooks({required String dbc}) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Master/books',
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

  // Get Customers
  static Future<List<CustomerDm>> getCustomers({required String type}) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Master/customers',
        token: token,
        queryParams: {'Type': type},
      );

      if (response == null || response['data'] == null) {
        return [];
      }

      return (response['data'] as List<dynamic>)
          .map((item) => CustomerDm.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get Tax Types
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

  // Get Salesmen
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

  // Get Customise Voucher
  static Future<List<CustomiseVoucherDm>> getCustomiseVoucher() async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Master/CustomiseVoucher',
        token: token,
        queryParams: {'BookCode': '1000'},
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

  // Save Invoice Entry
  static Future<dynamic> saveInvoiceEntry({
    required String invNo,
    required String bookCode,
    required String date,
    required String amount,
    required String pCode,
    required bool pdc,
    required String pCodeC,
    required String gstBillType,
    required String remark,
    required String terms,
    required String days,
    required String tDueDate,
    required String tCode,
    required String seCode,
    required String typeOfInvoice,
    required String valueOfGoods,
    required List<Map<String, dynamic>> itemData,
    required List<Map<String, dynamic>> ledgerData,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    final Map<String, dynamic> requestBody = {
      "InvNo": invNo,
      "BookCode": bookCode,
      "Date": date,
      "Amount": amount,
      "PCode": pCode,
      "PDC": pdc,
      "PCodeC": pCodeC,
      "GSTBillType": gstBillType,
      "Remark": remark,
      "Terms": terms,
      "Days": days,
      "TDueDate": tDueDate,
      "SECode": seCode,
      "TCode": tCode,
      "TypeofInvoice": typeOfInvoice,
      "ValueOfGoods": valueOfGoods,
      "ItemData": itemData,
      "LedgerData": ledgerData,
    };
    print(requestBody);
    try {
      var response = await ApiService.postRequest(
        endpoint: '/Invoice/saveInvoice',
        requestBody: requestBody,
        token: token,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
