import 'package:gamdiwala/features/home/models/item_dm.dart';

class CartItemDm {
  final ItemDm item;
  final double quantity;
  final double caratNos;
  final double totalAmount;

  CartItemDm({
    required this.item,
    required this.quantity,
    required this.caratNos,
    required this.totalAmount,
  });
}
