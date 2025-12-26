import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'dart:ui' as ui;
import 'package:gal/gal.dart';

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

  /// Request storage permission with settings redirect
  static Future<bool> _requestPermission(BuildContext context) async {
    if (Platform.isAndroid) {
      // For Android 13+ (API 33+), use manageExternalStorage
      var status = await Permission.manageExternalStorage.status;

      if (status.isGranted) {
        return true;
      }

      // Request permission
      status = await Permission.manageExternalStorage.request();

      if (status.isGranted) {
        return true;
      }

      // If denied, show dialog to open settings
      if (status.isDenied || status.isPermanentlyDenied) {
        final shouldOpenSettings = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'إذن التخزين مطلوب',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            content: const Text(
              'لحفظ الفاتورة، يجب السماح بالوصول للتخزين.\n\nسيتم فتح الإعدادات لتفعيل الإذن.',
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(ctx, true),
                icon: const Icon(Icons.settings),
                label: const Text('فتح الإعدادات'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        );

        if (shouldOpenSettings == true) {
          // Open app settings
          await openAppSettings();

          // Wait a bit for user to return
          await Future.delayed(const Duration(milliseconds: 500));

          // Check permission again after returning from settings
          final newStatus = await Permission.manageExternalStorage.status;
          return newStatus.isGranted;
        }
      }

      return false;
    }
    return true; // iOS doesn't need permission
  }

  /// Get Downloads directory
  static Future<Directory> _getDownloadsDir() async {
    if (Platform.isAndroid) {
      return Directory('/storage/emulated/0/Download');
    }
    return await getApplicationDocumentsDirectory();
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('جاري تحضير الطباعة...'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الطباعة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Save as PDF
  static Future<void> saveAsPdf(
    BuildContext context,
    GlobalKey repaintKey,
    Booking booking,
  ) async {
    try {
      if (!await _requestPermission(context)) {
        if (context.mounted) {
          _showModernSnackBar(
            context,
            message: 'يرجى السماح بالوصول للتخزين',
            icon: Icons.warning_amber_rounded,
            color: Colors.orange,
          );
        }
        return;
      }

      final pdf = await _generatePdf(repaintKey, booking);
      final output = await _getDownloadsDir();
      final fileName = 'فاتورة_${booking.id.substring(0, 8)}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      debugPrint('✅ PDF saved: ${file.path}');

      if (context.mounted) {
        _showModernSnackBar(
          context,
          message: 'تم حفظ PDF في مجلد التنزيلات ✓',
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

  /// Save as Image
  static Future<void> saveAsImage(
    BuildContext context,
    GlobalKey repaintKey,
    Booking booking,
  ) async {
    try {
      if (!await _requestPermission(context)) {
        if (context.mounted) {
          _showModernSnackBar(
            context,
            message: 'يرجى السماح بالوصول للتخزين',
            icon: Icons.warning_amber_rounded,
            color: Colors.orange,
          );
        }
        return;
      }

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

      // Use lower pixelRatio for faster processing if speed is critical,
      // but 3.0 is good for quality. Let's keep 3.0.
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final fileName =
          'invoice_${booking.id.substring(0, 8)}_${DateTime.now().millisecondsSinceEpoch}';

      // Save to Gallery using Gal
      // Gal handles permissions and saving automatically
      await Gal.putImageBytes(pngBytes, name: fileName);

      debugPrint('✅ Image saved to gallery');

      if (context.mounted) {
        _showModernSnackBar(
          context,
          message: 'تم حفظ الصورة في المعرض بنجاح ✓',
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
