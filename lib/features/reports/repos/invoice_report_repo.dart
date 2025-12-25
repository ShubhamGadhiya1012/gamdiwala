import 'package:gamdiwala/features/home/models/vehicle_dm.dart';
import 'package:gamdiwala/features/invoice_entry/models/invoice_party_dm.dart';
import 'package:gamdiwala/services/api_service.dart';
import 'package:gamdiwala/utils/helpers/secure_storage_helper.dart';

class InvoiceReportRepo {
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

      if (response == null || response['data'] == null) return [];

      return (response['data'] as List<dynamic>)
          .map((item) => InvoicePartyDm.fromJson(item))
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

  static Future<dynamic> getInvoiceReport({
    required String fromDate,
    required String toDate,
    required String pCode,
    required String vCode,
    required String status,
    required String billPeriod,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Report/invoiceReport',
        queryParams: {
          'FromDate': fromDate,
          'ToDate': toDate,
          'PCode': pCode,
          'VCode': vCode,
          'Status': status,
          'BillPeriod': billPeriod,
        },
        token: token,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
