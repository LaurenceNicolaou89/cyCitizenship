import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
class BillingService {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  static const String premiumProductId = 'cy_citizenship_premium';

  bool _available = false;
  bool _initialized = false;
  List<ProductDetails> _products = [];

  bool get isAvailable => _available;
  List<ProductDetails> get products => _products;

  final _purchaseController = StreamController<PurchaseStatus>.broadcast();
  Stream<PurchaseStatus> get purchaseStream => _purchaseController.stream;

  /// Ensures the service is initialized before use.
  /// Safe to call multiple times — only runs once.
  Future<void> ensureInitialized() async {
    if (_initialized) return;
    await initialize();
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _available = await _iap.isAvailable();
    if (!_available) return;

    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdate,
      onError: (error) {
        _purchaseController.add(PurchaseStatus.error);
      },
    );

    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    final response = await _iap.queryProductDetails({premiumProductId});
    if (response.notFoundIDs.isNotEmpty) {
      // Product not configured in store yet
      return;
    }
    _products = response.productDetails;
  }

  void _handlePurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _purchaseController.add(PurchaseStatus.purchased);
          _iap.completePurchase(purchase);
        case PurchaseStatus.error:
          _purchaseController.add(PurchaseStatus.error);
        case PurchaseStatus.pending:
          _purchaseController.add(PurchaseStatus.pending);
        case PurchaseStatus.canceled:
          _purchaseController.add(PurchaseStatus.canceled);
      }
    }
  }

  Future<void> buyPremium() async {
    if (_products.isEmpty) return;

    final productDetails = _products.firstWhere(
      (p) => p.id == premiumProductId,
    );

    final purchaseParam = PurchaseParam(productDetails: productDetails);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  void dispose() {
    _subscription?.cancel();
    _purchaseController.close();
  }
}
