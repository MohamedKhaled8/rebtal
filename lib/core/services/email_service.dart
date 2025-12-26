import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:intl/intl.dart';

class EmailService {
  static final EmailService _instance = EmailService._internal();

  factory EmailService() {
    return _instance;
  }

  EmailService._internal();

  // ⚠️ NOTE:
  // For production, it's safer to use Firebase Trigger Email extension to avoid managing credentials in the app.
  // However, for this implementation, we will use SMTP with an App Password.
  // The user MUST provide their Gmail App Password in the configuration below.
  //
  // To get an App Password:
  // 1. Go to Google Account > Security
  // 2. Enable 2-Step Verification
  // 3. Go to "App passwords"
  // 4. Generate a new password for "Mail" and "Other (Custom name)" -> "Rebtal App"

  static const String _senderEmail = 'rebtal.service@gmail.com';
  // TODO: Replace with the actual App Password provided by the user securely
  // DO NOT Hardcode real passwords in production code committed to version control.
  // Ideally, use flutter_dotenv or remote config.
  // For purpose of this specific task request (Admin App), we place a placeholder.
  static const String _appPassword = 'iyhvowxciqctoxdn';

  Future<void> sendBookingConfirmationEmail(Booking booking) async {
    // If the user hasn't configured the password, we can't send.
    if (_appPassword.isEmpty ||
        _appPassword == 'REPLACE_WITH_YOUR_APP_PASSWORD') {
      debugPrint('⚠️ Email not sent: App Password is missing in EmailService.');
      return;
    }

    if (booking.userEmail == null || booking.userEmail!.isEmpty) {
      debugPrint('⚠️ Email not sent: User has no email address.');
      return;
    }

    if (kIsWeb) {
      debugPrint(
        '⚠️ Email skipped: SMTP is not supported on Web (Browser security). Use Android/Windows or an HTTP Email API.',
      );
      return;
    }

    final smtpServer = gmail(_senderEmail, _appPassword);

    final message = Message()
      ..from = Address(_senderEmail, 'Rebtal Service')
      ..recipients.add(booking.userEmail!)
      ..subject =
          'Booking Confirmation - #${booking.id.substring(0, 8)} - ${booking.chaletName}'
      ..html = _buildHtmlTemplate(booking);

    try {
      final sendReport = await send(message, smtpServer);
      debugPrint('✅ Email sent: ${sendReport.toString()}');
    } catch (e) {
      debugPrint('❌ Error sending email: $e');
      // Don't rethrow to avoid blocking the UI flow, just log it.
    }
  }

  String _buildHtmlTemplate(Booking booking) {
    final dateFormat = DateFormat('EEE, MMM d, yyyy');
    final currencyFormat = NumberFormat.currency(
      symbol: 'EGP',
      decimalDigits: 0,
    );

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    body {
      font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
      line-height: 1.6;
      color: #333;
      background-color: #f9f9f9;
      margin: 0;
      padding: 0;
    }
    .container {
      max-width: 600px;
      margin: 20px auto;
      background-color: #ffffff;
      border-radius: 8px;
      overflow: hidden;
      box-shadow: 0 4px 6px rgba(0,0,0,0.1);
    }
    .header {
      background-color: #003580; /* Booking.com like blue */
      color: #ffffff;
      padding: 24px;
      text-align: center;
    }
    .header h1 {
      margin: 0;
      font-size: 24px;
      font-weight: 700;
    }
    .content {
      padding: 30px;
    }
    .greeting {
      font-size: 18px;
      margin-bottom: 20px;
      color: #2c3e50;
    }
    .confirmation-box {
      background-color: #ebf3ff;
      border-left: 5px solid #003580;
      padding: 15px;
      margin-bottom: 25px;
      border-radius: 4px;
    }
    .confirmation-text {
      color: #003580;
      font-weight: bold;
      font-size: 16px;
      margin: 0;
    }
    .details-table {
      width: 100%;
      border-collapse: collapse;
      margin-bottom: 25px;
    }
    .details-table th {
      text-align: left;
      padding: 12px;
      border-bottom: 1px solid #eee;
      color: #666;
      font-weight: normal;
      width: 40%;
    }
    .details-table td {
      text-align: right;
      padding: 12px;
      border-bottom: 1px solid #eee;
      font-weight: bold;
      color: #333;
    }
    .total-row td {
      border-top: 2px solid #003580;
      font-size: 18px;
      color: #003580;
      padding-top: 20px;
    }
    .footer {
      background-color: #f1f1f1;
      padding: 20px;
      text-align: center;
      font-size: 12px;
      color: #888;
    }
    .footer a {
      color: #003580;
      text-decoration: none;
    }
    .cta-button {
      display: inline-block;
      background-color: #003580;
      color: #ffffff;
      text-decoration: none;
      padding: 12px 25px;
      border-radius: 4px;
      font-weight: bold;
      margin-top: 10px;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>Rebtal</h1>
      <p>Your booking is confirmed!</p>
    </div>
    
    <div class="content">
      <div class="greeting">
        Hello <strong>${booking.userName}</strong>,
      </div>

      <div class="confirmation-box">
        <p class="confirmation-text">✔ Booking Confirmed: #${booking.id.substring(0, 8)}</p>
        <p style="margin: 5px 0 0 0; font-size: 14px;">We are waiting for you!</p>
      </div>

      <p>Thank you for choosing Rebtal. Your reservation at <strong>${booking.chaletName}</strong> has been successfully confirmed. Below are your booking details:</p>

      <table class="details-table">
        <tr>
          <th>Chalet</th>
          <td>${booking.chaletName}</td>
        </tr>
        <tr>
          <th>Location</th>
          <td>${booking.chaletLocation ?? 'N/A'}</td>
        </tr>
        <tr>
          <th>Check-in</th>
          <td>${dateFormat.format(booking.from)}</td>
        </tr>
        <tr>
          <th>Check-out</th>
          <td>${dateFormat.format(booking.to)}</td>
        </tr>
        <tr>
          <th>Duration</th>
          <td>${booking.to.difference(booking.from).inDays + 1} Days</td>
        </tr>
        <tr class="total-row">
          <th>Total Price</th>
          <td>${currencyFormat.format(booking.amount ?? 0)}</td>
        </tr>
      </table>

      <div style="text-align: center; margin-top: 30px;">
        <p style="font-style: italic; color: #666;">"We wish you a pleasant and memorable stay!"</p>
      </div>
    </div>

    <div class="footer">
      <p>Need help? Contact us at <a href="mailto:rebtal.service@gmail.com">rebtal.service@gmail.com</a></p>
      <p>&copy; ${DateTime.now().year} Rebtal Services. All rights reserved.</p>
    </div>
  </div>
</body>
</html>
    ''';
  }
}
