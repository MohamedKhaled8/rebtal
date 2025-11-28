// import 'package:flutter/material.dart';
// import 'package:paymob_payment/paymob_payment.dart';
// import 'package:rebtal/core/config/payment_config.dart';

// class PaymobService {
//   static final PaymobService _instance = PaymobService._internal();
//   factory PaymobService() => _instance;
//   PaymobService._internal();

//   late PaymobPayment _paymobPayment;
//   bool _isInitialized = false;

//   /// Initialize Paymob with credentials
//   void initialize() {
//     if (_isInitialized) return;

//     _paymobPayment = PaymobPayment();
//     _paymobPayment.initialize(
//       apiKey: PaymentConfig.paymobApiKey,
//       integrationID: PaymentConfig.paymobIntegrationId,
//       iFrameID: PaymentConfig.paymobCardIframeId,
//     );

//     _isInitialized = true;
//     debugPrint('✅ Paymob initialized successfully');
//   }

//   /// Process payment
//   /// [context] - BuildContext for navigation
//   /// [amountInEGP] - Amount in Egyptian Pounds (will be converted to cents)
//   /// [onPayment] - Optional callback when payment completes
//   Future<PaymobResponse?> pay({
//     required BuildContext context,
//     required double amountInEGP,
//     Function(PaymobResponse)? onPayment,
//   }) async {
//     if (!_isInitialized) {
//       initialize();
//     }

//     try {
//       // Convert EGP to cents (Paymob requires amount in cents)
//       final String amountInCents = (amountInEGP * 100).toInt().toString();

//       debugPrint(
//         '💳 Processing payment: $amountInEGP EGP ($amountInCents cents)',
//       );

//       final PaymobResponse? response = await _paymobPayment.pay(
//         context: context,
//         currency: PaymentConfig.currency,
//         amountInCents: amountInCents,
//         onPayment: onPayment,
//       );

//       return response;
//     } catch (e) {
//       debugPrint('❌ Payment error: $e');
//       rethrow;
//     }
//   }

//   /// Check if payment was successful
//   bool isPaymentSuccessful(PaymobResponse? response) {
//     if (response == null) return false;

//     // Check response success status
//     return response.success == true;
//   }

//   /// Get transaction ID from response
//   String? getTransactionId(PaymobResponse? response) {
//     return response?.transactionID;
//   }
// }
