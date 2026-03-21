import 'dart:async';
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'i_billing_service.dart';

/// Result of a purchase verification attempt.
enum VerificationResult {
  success,
  alreadyVerified,
  failed,
}

class BillingService implements IBillingService {
  final InAppPurchase _iap = InAppPurchase.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  static const String premiumProductId = 'cy_citizenship_premium';

  bool _available = false;
  bool _initialized = false;
  List<ProductDetails> _products = [];

  @override
  bool get isAvailable => _available;
  @override
  List<ProductDetails> get products => _products;

  final _purchaseController = StreamController<PurchaseStatus>.broadcast();
  @override
  Stream<PurchaseStatus> get purchaseStream => _purchaseController.stream;

  /// Human-readable error message from the last failed verification.
  String? _lastVerificationError;
  String? get lastVerificationError => _lastVerificationError;

  /// Ensures the service is initialized before use.
  /// Safe to call multiple times — only runs once.
  Future<void> ensureInitialized() async {
    if (_initialized) return;
    await initialize();
  }

  @override
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

  /// Handles purchase lifecycle updates from the App Store / Play Store.
  ///
  /// Business rule: restored purchases are treated identically to new
  /// purchases -- both grant premium access and emit [PurchaseStatus.purchased].
  /// This ensures users who reinstall the app or switch devices automatically
  /// regain their paid tier without re-purchasing.
  void _handlePurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _verifyAndCompletePurchase(purchase);
        case PurchaseStatus.error:
          _purchaseController.add(PurchaseStatus.error);
        case PurchaseStatus.pending:
          _purchaseController.add(PurchaseStatus.pending);
        case PurchaseStatus.canceled:
          _purchaseController.add(PurchaseStatus.canceled);
      }
    }
  }

  /// Verify the purchase server-side before granting premium access.
  ///
  /// Calls the `verifyPurchase` Cloud Function which validates the receipt
  /// with Google Play / App Store, then updates the user's Firestore document.
  /// Only emits [PurchaseStatus.purchased] after successful server verification.
  Future<void> _verifyAndCompletePurchase(PurchaseDetails purchase) async {
    _lastVerificationError = null;

    try {
      // Determine the purchase token based on platform
      final String purchaseToken;
      if (Platform.isAndroid) {
        // Android: use purchaseID or serverVerificationData
        purchaseToken =
            purchase.verificationData.serverVerificationData;
      } else {
        // iOS: use the transaction ID for App Store Server API v2
        purchaseToken =
            purchase.purchaseID ?? purchase.verificationData.serverVerificationData;
      }

      final platform = Platform.isAndroid ? 'android' : 'ios';

      final result = await _functions.httpsCallable('verifyPurchase').call({
        'purchaseToken': purchaseToken,
        'productId': purchase.productID,
        'platform': platform,
      });

      final data = result.data as Map<String, dynamic>;

      if (data['success'] == true) {
        // Server verified the purchase — now complete it with the store
        await _iap.completePurchase(purchase);
        _purchaseController.add(PurchaseStatus.purchased);
      } else {
        _lastVerificationError =
            data['message'] as String? ?? 'Verification failed.';
        _purchaseController.add(PurchaseStatus.error);
      }
    } on FirebaseFunctionsException catch (e) {
      _lastVerificationError = e.message ?? 'Purchase verification failed.';
      _purchaseController.add(PurchaseStatus.error);
    } catch (e) {
      _lastVerificationError =
          'Unable to verify purchase. Please check your connection and try again.';
      _purchaseController.add(PurchaseStatus.error);
    }
  }

  /// Initiates a non-consumable purchase for the premium tier (one-time).
  ///
  /// Uses [buyNonConsumable] because premium is a lifetime unlock -- the user
  /// pays once and keeps access forever, including across reinstalls via
  /// restore. If no products are loaded (e.g. store unavailable), this is a
  /// no-op.
  @override
  Future<void> buyPremium() async {
    if (_products.isEmpty) return;

    final productDetails = _products.cast<ProductDetails?>().firstWhere(
      (p) => p!.id == premiumProductId,
      orElse: () => null,
    );

    if (productDetails == null) {
      _purchaseController.add(PurchaseStatus.error);
      return;
    }

    final purchaseParam = PurchaseParam(productDetails: productDetails);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _purchaseController.close();
  }
}
