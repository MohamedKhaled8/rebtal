import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'dart:ui' as ui;

class InvoiceService {
  /// Modern SnackBar at Top
  static void _showModernSnackBar(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color color,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -50 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto remove after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  /// Get app-private temp directory (NO permissions needed)
  static Future<Directory> _getAppTempDir() async {
    final dir = await getTemporaryDirectory();
    final invoiceDir = Directory('${dir.path}/invoices');
    if (!await invoiceDir.exists()) {
      await invoiceDir.create(recursive: true);
    }
    return invoiceDir;
  }

  /// Show dialog to choose between PDF or Image
  static Future<void> showSaveOptions(
    BuildContext context,
    GlobalKey repaintKey,
    Booking booking,
  ) async {
    return showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.save_alt_rounded, size: 50, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'حفظ الفاتورة',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  saveAsPdf(context, repaintKey, booking);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'حفظ كـ PDF',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'ملف PDF قابل للمشاركة',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  saveAsImage(context, repaintKey, booking);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.image_rounded,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'حفظ كصورة',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'صورة PNG عالية الجودة',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Print the invoice
  static Future<void> printInvoice(
    BuildContext context,
    GlobalKey repaintKey,
    Booking booking,
  ) async {
    try {
      final pdf = await _generatePdf(repaintKey, booking);
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

      if (context.mounted) {
        SnackBarHelper.showInfo(context, 'جاري تحضير الطباعة...');
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarHelper.showError(context, 'خطأ في الطباعة: $e');
      }
    }
  }

  /// Save as PDF — saves to app-private dir then shares via system share sheet
  static Future<void> saveAsPdf(
    BuildContext context,
    GlobalKey repaintKey,
    Booking booking,
  ) async {
    try {
      final pdf = await _generatePdf(repaintKey, booking);
      final output = await _getAppTempDir();
      final fileName = 'فاتورة_${booking.id.substring(0, 8)}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      debugPrint('✅ PDF saved: ${file.path}');

      // Use share_plus to let the user save/share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'فاتورة حجز Rebtal',
      );

      if (context.mounted) {
        _showModernSnackBar(
          context,
          message: 'تم تجهيز ملف PDF بنجاح ✓',
          icon: Icons.check_circle_rounded,
          color: Colors.green,
        );
      }
    } catch (e) {
      debugPrint('❌ PDF Error: $e');
      if (context.mounted) {
        _showModernSnackBar(
          context,
          message: 'فشل الحفظ: $e',
          icon: Icons.error_outline,
          color: Colors.red,
        );
      }
    }
  }

  /// Save as Image — saves to app-private dir then shares via system share sheet
  static Future<void> saveAsImage(
    BuildContext context,
    GlobalKey repaintKey,
    Booking booking,
  ) async {
    try {
      // Show loading indicator
      if (context.mounted) {
        _showModernSnackBar(
          context,
          message: 'جاري حفظ الصورة...',
          icon: Icons.downloading_rounded,
          color: Colors.blue,
        );
      }

      RenderRepaintBoundary boundary =
          repaintKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final output = await _getAppTempDir();
      final fileName =
          'invoice_${booking.id.substring(0, 8)}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(pngBytes);

      debugPrint('✅ Image saved: ${file.path}');

      // Use share_plus to let the user save/share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'فاتورة حجز Rebtal',
      );

      if (context.mounted) {
        _showModernSnackBar(
          context,
          message: 'تم تجهيز الصورة بنجاح ✓',
          icon: Icons.check_circle_rounded,
          color: Colors.green,
        );
      }
    } catch (e) {
      debugPrint('❌ Image Error: $e');
      if (context.mounted) {
        _showModernSnackBar(
          context,
          message: 'فشل الحفظ: $e',
          icon: Icons.error_outline,
          color: Colors.red,
        );
      }
    }
  }

  /// Generate PDF from widget
  static Future<pw.Document> _generatePdf(
    GlobalKey repaintKey,
    Booking booking,
  ) async {
    final pdf = pw.Document();

    // Capture widget as image
    RenderRepaintBoundary boundary =
        repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    final pdfImage = pw.MemoryImage(pngBytes);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(child: pw.Image(pdfImage, fit: pw.BoxFit.contain));
        },
      ),
    );

    return pdf;
  }
}
