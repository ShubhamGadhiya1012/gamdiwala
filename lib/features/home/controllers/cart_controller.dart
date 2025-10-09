import 'package:flutter/material.dart';
import 'package:gamdiwala/features/home/models/address_dm.dart';
import 'package:gamdiwala/features/home/models/cart_item_dm.dart';
import 'package:gamdiwala/features/home/models/driver_dm.dart';
import 'package:gamdiwala/features/home/models/item_dm.dart';
import 'package:gamdiwala/features/home/models/vehicle_dm.dart';
import 'package:gamdiwala/features/home/repos/cart_repo.dart';
import 'package:gamdiwala/utils/dialogs/app_dialogs.dart';
import 'package:gamdiwala/utils/helpers/secure_storage_helper.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CartController extends GetxController {
  var isLoading = false.obs;
  final formKey = GlobalKey<FormState>();
  var cartItems = <CartItemDm>[].obs;
  var cartCount = 0.obs;

  var vehicles = <VehicleDm>[].obs;
  var vehicleDisplayNames = <String>[].obs;
  var selectedVehicleDisplayName = ''.obs;
  var selectedVehicleCode = ''.obs;

  var drivers = <DriverDm>[].obs;
  var driverNames = <String>[].obs;
  var selectedDriverName = ''.obs;
  var selectedDriverCode = ''.obs;
  var orderDateController = TextEditingController();
  var address = Rxn<AddressDm>();

  @override
  void onInit() {
    super.onInit();
    getCartItems();
  }

  Future<void> getCartItems() async {
    isLoading.value = true;
    try {
      String? selectPCode = await SecureStorageHelper.read('selectPCode');

      final fetchedCartItems = await CartRepo.getCartItems(
        pCode: selectPCode ?? '',
      );

      cartItems.assignAll(fetchedCartItems);
      cartCount.value = fetchedCartItems.length;
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getVehicles() async {
    try {
      isLoading.value = true;
      final fetchedVehicles = await CartRepo.getVehicles();
      vehicles.assignAll(fetchedVehicles);
      vehicleDisplayNames.assignAll(
        fetchedVehicles.map((v) => '${v.regNo} - ${v.vType}'),
      );
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getDrivers() async {
    try {
      isLoading.value = true;
      final fetchedDrivers = await CartRepo.getDrivers();
      drivers.assignAll(fetchedDrivers);
      driverNames.assignAll(fetchedDrivers.map((d) => d.driverName));
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getAddress() async {
    try {
      isLoading.value = true;
      String? selectPCode = await SecureStorageHelper.read('selectPCode');

      final fetchedAddress = await CartRepo.getAddress(
        pCode: selectPCode ?? '',
      );

      address.value = fetchedAddress;
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAllOrderData() async {
    await Future.wait([getVehicles(), getDrivers(), getAddress()]);
  }

  void onDriverSelected(String? driverName) {
    if (driverName == null) return;
    selectedDriverName.value = driverName;
    var selectedDriverObj = drivers.firstWhere(
      (d) => d.driverName == driverName,
    );
    selectedDriverCode.value = selectedDriverObj.dCode;
  }

  void onVehicleSelected(String? vehicleDisplay) {
    if (vehicleDisplay == null) return;
    selectedVehicleDisplayName.value = vehicleDisplay;
    var selectedVehicleObj = vehicles.firstWhere(
      (v) => '${v.regNo} - ${v.vType}' == vehicleDisplay,
    );
    selectedVehicleCode.value = selectedVehicleObj.vCode;
  }

  Future<void> addToCart({
    required ItemDm item,
    required double qty,
    required double caratCount,
    required double nosCount,
  }) async {
    isLoading.value = true;
    try {
      String? selectPCode = await SecureStorageHelper.read('selectPCode');

      double amount = _calculateAmount(
        item: item,
        qty: qty,
        nosCount: nosCount,
      );

      final response = await CartRepo.addToCart(
        pCode: selectPCode ?? '',
        iCode: item.iCode,
        qty: qty,
        rate: item.rate,
        amount: amount,
        packQty: item.packQty,
        caratNos: nosCount,
        caratQty: caratCount,
        itemPack: item.itemPack,
        fat: item.fat,
        lr: item.lr,
      );

      if (response != null && response['message'] != null) {
        await getCartItems();
        showSuccessSnackbar('Success', response['message']);
      }
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCartItem({
    required CartItemDm cartItem,
    required double qty,
    required double caratCount,
    required double nosCount,
  }) async {
    isLoading.value = true;
    try {
      String? selectPCode = await SecureStorageHelper.read('selectPCode');

      double amount = 0;
      if (cartItem.usesCaratSystem) {
        double actualQty = nosCount * (cartItem.caratQty / cartItem.caratNos);
        amount = cartItem.rate * actualQty;
      } else {
        amount = cartItem.rate * qty;
      }

      final response = await CartRepo.addToCart(
        pCode: selectPCode ?? '',
        iCode: cartItem.iCode,
        qty: qty,
        rate: cartItem.rate,
        amount: amount,
        packQty: cartItem.packQty,
        caratNos: nosCount,
        caratQty: caratCount,
        itemPack: cartItem.itemPack,
        fat: cartItem.fat,
        lr: cartItem.lr,
      );

      if (response != null) {
        await getCartItems();
      }
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeFromCart(CartItemDm cartItem) async {
    isLoading.value = true;
    try {
      String? selectPCode = await SecureStorageHelper.read('selectPCode');

      await CartRepo.addToCart(
        pCode: selectPCode ?? '',
        iCode: cartItem.iCode,
        qty: 0,
        rate: cartItem.rate,
        amount: 0,
        packQty: cartItem.packQty,
        caratNos: 0,
        caratQty: 0,
        itemPack: cartItem.itemPack,
        fat: cartItem.fat,
        lr: cartItem.lr,
      );

      await getCartItems();
      showSuccessSnackbar('Success', 'Item removed from cart');
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  double _calculateAmount({
    required ItemDm item,
    required double qty,
    required double nosCount,
  }) {
    if (item.usesCaratSystem) {
      double actualQty = nosCount * (item.caratQty / item.caratNos);
      return item.rate * actualQty;
    } else {
      return item.rate * qty;
    }
  }

  double getTotalAmount() {
    return cartItems.fold(0, (sum, item) => sum + item.amount);
  }

  Future<bool> savePlaceOrder({String? remark}) async {
    isLoading.value = true;
    try {
      String? selectPCode = await SecureStorageHelper.read('selectPCode');

      final orderDate = DateFormat(
        'yyyy-MM-dd',
      ).format(DateFormat('dd-MM-yyyy').parse(orderDateController.text));

      final response = await CartRepo.savePlaceOrder(
        pCode: selectPCode ?? '',
        orderDate: orderDate,
        dCode: selectedDriverCode.value,
        vCode: selectedVehicleCode.value,
        remark: remark,
      );

      if (response != null && response['message'] != null) {
        await getCartItems();

        selectedDriverName.value = '';
        selectedDriverCode.value = '';
        selectedVehicleDisplayName.value = '';
        selectedVehicleCode.value = '';

        showSuccessSnackbar('Success', response['message']);

        return true;
      }

      return false;
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
