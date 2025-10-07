import 'package:gamdiwala/features/home/models/cart_item_dm.dart';
import 'package:gamdiwala/features/home/models/item_dm.dart';
import 'package:gamdiwala/features/home/repos/cart_repo.dart';
import 'package:gamdiwala/utils/dialogs/app_dialogs.dart';
import 'package:gamdiwala/utils/helpers/secure_storage_helper.dart';
import 'package:get/get.dart';

class CartController extends GetxController {
  var isLoading = false.obs;
  var cartItems = <CartItemDm>[].obs;
  var cartCount = 0.obs;

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

  Future<void> addToCart({
    required ItemDm item,
    required double qty,
    required double caratCount,
    required double nosCount,
  }) async {
    isLoading.value = true;
    try {
      String? selectPCode = await SecureStorageHelper.read('selectPCode');

      // Calculate amount based on carat system or direct qty
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

      // Calculate amount
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

      // Send zero values to remove item
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
}
