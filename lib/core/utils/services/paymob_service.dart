import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymobService {
  static final PaymobService _instance = PaymobService._internal();
  factory PaymobService() => _instance;
  PaymobService._internal();

  // Load keys from .env
  String get apiKey => dotenv.env['PAYMOB_API_KEY'] ?? '';
  String get hmac => dotenv.env['PAYMOB_HMAC'] ?? '';
  String get secretKey => dotenv.env['PAYMOB_SECRET_KEY'] ?? '';
  String get publicKey => dotenv.env['PAYMOB_PUBLIC_KEY'] ?? '';

  // Paymob API endpoints
  static const String _baseUrl = 'https://accept.paymob.com/api';
  static const String _authEndpoint = '$_baseUrl/auth/tokens';
  static const String _orderEndpoint = '$_baseUrl/ecommerce/orders';
  static const String _paymentKeyEndpoint = '$_baseUrl/acceptance/payment_keys';
  static const String _walletPayEndpoint = '$_baseUrl/acceptance/payments/pay';

  String? _authToken;

  /// Step 1: Authenticate and get auth token
  Future<String> authenticate() async {
    try {
      final response = await http.post(
        Uri.parse(_authEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'api_key': apiKey}),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        _authToken = data['token'];
        return _authToken!;
      } else {
        throw Exception('Authentication failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Authentication error: $e');
    }
  }

  /// Step 2: Create an order
  Future<Map<String, dynamic>> createOrder({
    required double amountCents,
    required String currency,
    required Map<String, dynamic> items,
  }) async {
    if (_authToken == null) {
      await authenticate();
    }

    try {
      final response = await http.post(
        Uri.parse(_orderEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'auth_token': _authToken,
          'delivery_needed': 'false',
          'amount_cents': amountCents.toString(),
          'currency': currency,
          'items': [items],
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Order creation failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Order creation error: $e');
    }
  }

  /// Step 3: Get payment key
  Future<String> getPaymentKey({
    required int orderId,
    required double amountCents,
    required String currency,
    required int integrationId,
    required Map<String, dynamic> billingData,
  }) async {
    if (_authToken == null) {
      await authenticate();
    }

    try {
      final response = await http.post(
        Uri.parse(_paymentKeyEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'auth_token': _authToken,
          'amount_cents': amountCents.toString(),
          'expiration': 3600,
          'order_id': orderId.toString(),
          'billing_data': billingData,
          'currency': currency,
          'integration_id': integrationId,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['token'];
      } else {
        throw Exception('Payment key generation failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Payment key error: $e');
    }
  }

  /// Pay with Mobile Wallet
  Future<Map<String, dynamic>> payWithWallet({
    required String paymentToken,
    required String phoneNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_walletPayEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'source': {'identifier': phoneNumber, 'subtype': 'WALLET'},
          'payment_token': paymentToken,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Wallet payment failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Wallet payment error: $e');
    }
  }

  /// Complete Wallet Payment Flow
  Future<Map<String, dynamic>> processWalletPayment({
    required double amount,
    required String phoneNumber,
    required int walletIntegrationId,
    required Map<String, dynamic> billingData,
    String currency = 'EGP',
  }) async {
    try {
      // Step 1: Authenticate
      await authenticate();

      // Step 2: Create order
      final order = await createOrder(
        amountCents: amount * 100, // Convert to cents
        currency: currency,
        items: {
          'name': 'Chalet Booking',
          'amount_cents': (amount * 100).toString(),
          'description': 'Booking payment',
          'quantity': '1',
        },
      );

      // Step 3: Get payment key
      final paymentToken = await getPaymentKey(
        orderId: order['id'],
        amountCents: amount * 100,
        currency: currency,
        integrationId: walletIntegrationId,
        billingData: billingData,
      );

      // Step 4: Pay with wallet
      final paymentResult = await payWithWallet(
        paymentToken: paymentToken,
        phoneNumber: phoneNumber,
      );

      return paymentResult;
    } catch (e) {
      throw Exception('Wallet payment process failed: $e');
    }
  }

  /// Pay with ValU
  Future<Map<String, dynamic>> payWithValU({
    required String paymentToken,
    required String phoneNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_walletPayEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'source': {'identifier': phoneNumber, 'subtype': 'VALU'},
          'payment_token': paymentToken,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('ValU payment failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('ValU payment error: $e');
    }
  }

  /// Complete ValU Payment Flow
  Future<Map<String, dynamic>> processValUPayment({
    required double amount,
    required String phoneNumber,
    required int valuIntegrationId,
    required Map<String, dynamic> billingData,
    String currency = 'EGP',
  }) async {
    try {
      // Step 1: Authenticate
      await authenticate();

      // Step 2: Create order
      final order = await createOrder(
        amountCents: amount * 100, // Convert to cents
        currency: currency,
        items: {
          'name': 'Chalet Booking',
          'amount_cents': (amount * 100).toString(),
          'description': 'Booking payment via ValU',
          'quantity': '1',
        },
      );

      // Step 3: Get payment key
      final paymentToken = await getPaymentKey(
        orderId: order['id'],
        amountCents: amount * 100,
        currency: currency,
        integrationId: valuIntegrationId,
        billingData: billingData,
      );

      // Step 4: Pay with ValU
      final paymentResult = await payWithValU(
        paymentToken: paymentToken,
        phoneNumber: phoneNumber,
      );

      return paymentResult;
    } catch (e) {
      throw Exception('ValU payment process failed: $e');
    }
  }
}
