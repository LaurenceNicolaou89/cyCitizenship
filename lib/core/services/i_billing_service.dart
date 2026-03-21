import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';

abstract class IBillingService {
  bool get isAvailable;
  List<ProductDetails> get products;
  Stream<PurchaseStatus> get purchaseStream;

  Future<void> initialize();
  Future<void> buyPremium();
  Future<void> restorePurchases();
  void dispose();
}
