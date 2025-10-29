import 'package:gamdiwala/features/authentication/auth/models/party_dm.dart';
import 'package:gamdiwala/services/api_service.dart';

class SelectPartyRepo {
  static Future<List<PartyDm>> getCustomers() async {
    try {
      final response = await ApiService.getRequest(
        endpoint: '/Master/customer',
      );

      if (response == null) {
        return [];
      }

      if (response['data'] != null) {
        return (response['data'] as List<dynamic>)
            .map((item) => PartyDm.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }
}
