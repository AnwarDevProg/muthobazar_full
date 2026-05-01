import 'package:get/get.dart';
import 'package:shared_models/orders/mb_cart_item.dart';



class CartRepository {
  CartRepository._();

  static final CartRepository instance = CartRepository._();

  final RxList<MBCartItem> _items = <MBCartItem>[].obs;

  List<MBCartItem> get items => _items;

  Stream<List<MBCartItem>> watchCart() => _items.stream;

  List<MBCartItem> getCartItems() => List<MBCartItem>.from(_items);

  void setCartItems(List<MBCartItem> items) {
    _items.assignAll(items);
  }

  void clearCart() {
    _items.clear();
  }

  void clearItemsByMode(String purchaseMode) {
    _items.removeWhere((e) => (e.purchaseMode ?? 'instant') == purchaseMode);
  }

  void addItem(MBCartItem item) {
    final index = _items.indexWhere((e) =>
    e.productId == item.productId &&
        e.variationId == item.variationId &&
        (e.purchaseMode ?? 'instant') == (item.purchaseMode ?? 'instant') &&
        _sameDate(e.selectedDate, item.selectedDate) &&
        (e.selectedShift ?? '') == (item.selectedShift ?? ''));

    if (index == -1) {
      _items.add(item);
      return;
    }

    final existing = _items[index];
    _items[index] = existing.copyWith(
      quantity: existing.quantity + item.quantity,
    );
  }

  void updateItem(MBCartItem updated) {
    final index = _items.indexWhere((e) =>
    e.productId == updated.productId &&
        e.variationId == updated.variationId &&
        (e.purchaseMode ?? 'instant') == (updated.purchaseMode ?? 'instant') &&
        _sameDate(e.selectedDate, updated.selectedDate) &&
        (e.selectedShift ?? '') == (updated.selectedShift ?? ''));

    if (index == -1) return;
    _items[index] = updated;
  }

  void removeItem(MBCartItem item) {
    _items.removeWhere((e) =>
    e.productId == item.productId &&
        e.variationId == item.variationId &&
        (e.purchaseMode ?? 'instant') == (item.purchaseMode ?? 'instant') &&
        _sameDate(e.selectedDate, item.selectedDate) &&
        (e.selectedShift ?? '') == (item.selectedShift ?? ''));
  }

  bool _sameDate(DateTime? a, DateTime? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;

    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}