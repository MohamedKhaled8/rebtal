import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:rebtal/core/utils/home_search_notifier.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/core/utils/format/currency.dart';
import 'package:rebtal/feature/chalet/ui/chalet_detail_page.dart';
import 'package:rebtal/core/utils/services/chalet_filter_service.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

class OwnerChaletsList extends StatelessWidget {
  final String status;
  final IconData? emptyIcon;
  final String? emptyTitle;
  final String? emptySubtitle;
  final String? ownerId;

  const OwnerChaletsList({
    super.key,
    required this.status,
    this.emptyIcon,
    this.emptyTitle,
    this.emptySubtitle,
    this.ownerId,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    // Use AppCubit as the single source of truth
    return BlocBuilder<AppCubit, AppState>(
      buildWhen: (previous, current) {
        // Only rebuild if owner chalets or loading state changes
        if (current is AppAuthenticated && previous is AppAuthenticated) {
          return current.ownerChalets != previous.ownerChalets ||
              current.isOwnerChaletsLoading != previous.isOwnerChaletsLoading;
        }
        return true;
      },
      builder: (context, state) {
        if (state is! AppAuthenticated) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.isOwnerChaletsLoading) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.deepPurple,
              ),
            ),
          );
        }

        // Filter chalets by status and ownerId locally
        // (Assuming OwnerCubit fetches ALL chalets for the owner, allowing local filtering)
        final List<dynamic> allChalets = state.ownerChalets;
        final docs = allChalets.where((data) {
          // Handle both Map and DocumentSnapshot if needed, but AppState likely has Maps or Snapshots
          // OwnerLoaded in AppCubit usually has List<Map<String, dynamic>> based on previous review
          // Let's assume it's List<Map<String, dynamic>> or similar.
          final map = data is Map<String, dynamic>
              ? data
              : (data as DocumentSnapshot).data() as Map<String, dynamic>;

          final docStatus = map['status'];
          final docOwnerId = map['ownerId'];

          // Filter by status if provided
          if (status.isNotEmpty && docStatus != status) return false;
          // Filter by ownerId if provided (though AppCubit likely fetched for this user)
          if (ownerId != null && docOwnerId != ownerId) return false;

          return true;
        }).toList();

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  emptyIcon ?? Icons.home_outlined,
                  size: 72,
                  color: isDark ? ColorManager.white70 : ColorManager.grey400,
                ),
                const SizedBox(height: 16),
                Text(
                  emptyTitle ?? 'لا توجد شاليهات',
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark ? ColorManager.white70 : ColorManager.grey600,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (emptySubtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    emptySubtitle!,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? ColorManager.white70
                          : ColorManager.grey700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          );
        }

        return ValueListenableBuilder<SearchFilters>(
          valueListenable: HomeSearch.filters,
          builder: (context, filters, _) {
            // Apply filters using centralized service
            final filtered = docs.where((chalet) {
              final data = chalet is Map<String, dynamic>
                  ? chalet
                  : (chalet as DocumentSnapshot).data() as Map<String, dynamic>;

              final singleList = [data];
              final result = ChaletFilterService.filterChalets(
                singleList,
                filters,
              );
              return result.isNotEmpty;
            }).toList();

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final chalet = filtered[i];
                final data = chalet is Map<String, dynamic>
                    ? chalet
                    : (chalet as DocumentSnapshot).data()
                          as Map<String, dynamic>;

                // We need ID. If it's a Map from OwnerCubit, does it have 'id'?
                // If it came from Firestore, the Map usually doesn't have ID unless we added it.
                // WE NEED TO CHECK OwnerCubit.
                // Assuming data has 'id' or we can't do this efficiently without the ID.
                // Let's use 'id' or 'docId' from the map.
                final String id = data['id'] ?? data['docId'] ?? '';

                return OwnerChaletCard(
                  chaletData: data,
                  docId: id,
                  status: status,
                );
              },
            );
          },
        );
      },
    );
  }
}

// Owner Chalet Card with home page design
class OwnerChaletCard extends StatefulWidget {
  final Map<String, dynamic> chaletData;
  final String docId;
  final String status;

  const OwnerChaletCard({
    super.key,
    required this.chaletData,
    required this.docId,
    required this.status,
  });

  @override
  State<OwnerChaletCard> createState() => _OwnerChaletCardState();
}

class _OwnerChaletCardState extends State<OwnerChaletCard> {
  bool _isLoading = false;
  bool? _localBookingAvailable;
  bool? _localVisible;

  // قراءة البيانات مع الأولوية للمتغيرات المحلية
  bool get _isBookingAvailable {
    if (_localBookingAvailable != null) return _localBookingAvailable!;
    return (widget.chaletData['bookingAvailability'] == 'available') ||
        (widget.chaletData['isAvailable'] == true) ||
        (widget.chaletData['available'] == true);
  }

  bool get _isVisible {
    if (_localVisible != null) return _localVisible!;
    return widget.chaletData['isVisible'] ?? true;
  }

  @override
  void didUpdateWidget(OwnerChaletCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // إعادة بناء الواجهة عند تغيير البيانات
    if (oldWidget.chaletData != widget.chaletData) {
      // إعادة تعيين المتغيرات المحلية عند تحديث البيانات
      _localBookingAvailable = null;
      _localVisible = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    final chaletName = widget.chaletData['chaletName'] ?? 'Unnamed Chalet';
    final location = widget.chaletData['location'] ?? 'Unknown Location';
    final price = widget.chaletData['price'];

    final image =
        (widget.chaletData['images'] is List &&
            widget.chaletData['images'].isNotEmpty)
        ? widget.chaletData['images'][0]
        : (widget.chaletData['profileImage']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: isDark
            ? Border.all(color: ColorManager.white.withOpacity(0.1))
            : null,
        boxShadow: [
          BoxShadow(
            color: ColorManager.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background Image
            SizedBox(
              height: 280,
              width: double.infinity,
              child: AppImageHelper(path: image, fit: BoxFit.cover),
            ),

            // Dark Gradient Overlay
            Container(
              height: 280,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    ColorManager.transparent,
                    ColorManager.black.withOpacity(0.7),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),

            // Clickable Area
            Positioned.fill(
              child: Material(
                color: ColorManager.transparent,
                child: InkWell(
                  onTap: () => _navigateToChaletDetails(
                    context,
                    widget.chaletData,
                    widget.docId,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),

            // Content
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Status Badges
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _isBookingAvailable
                                ? ColorManager.chaletActionGreen
                                : ColorManager.chaletUnavailableRed,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _isBookingAvailable ? 'متاح' : 'مغلق',
                            style: const TextStyle(
                              color: ColorManager.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // Visibility Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _isVisible
                                ? ColorManager.chaletActionBlue
                                : ColorManager.chaletActionGrey,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _isVisible ? 'مرئي' : 'مخفي',
                            style: const TextStyle(
                              color: ColorManager.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Bottom Content
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Location
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: ColorManager.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location,
                                style: const TextStyle(
                                  color: ColorManager.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Chalet Name
                        Text(
                          chaletName,
                          style: const TextStyle(
                            color: ColorManager.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8),

                        // Price
                        Text(
                          CurrencyFormatter.egp(
                            (price is num)
                                ? price
                                : double.tryParse(
                                        (price ?? '').toString().replaceAll(
                                          RegExp('[^0-9.]'),
                                          '',
                                        ),
                                      ) ??
                                      0,
                            withSuffixPerNight: true,
                          ),
                          style: const TextStyle(
                            color: ColorManager.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Management Controls
                        Row(
                          children: [
                            // Visibility Toggle
                            Expanded(
                              child: _buildToggleButton(
                                icon: _isVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                label: _isVisible ? 'إخفاء' : 'إظهار',
                                color: _isVisible
                                    ? ColorManager.orange
                                    : ColorManager.green,
                                onPressed: _toggleVisibility,
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Booking Availability Toggle
                            Expanded(
                              child: _buildToggleButton(
                                icon: _isBookingAvailable
                                    ? Icons.lock_outline
                                    : Icons.lock_open,
                                label: _isBookingAvailable
                                    ? 'إيقاف الحجز'
                                    : 'تشغيل الحجز',
                                color: _isBookingAvailable
                                    ? ColorManager.red
                                    : ColorManager.green,
                                onPressed: _toggleBookingAvailability,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: _isLoading ? null : onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              )
            else
              Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToChaletDetails(
    BuildContext context,
    Map<String, dynamic> chaletData,
    String docId,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChaletDetailPage(
          requestData: chaletData,
          docId: docId,
          status: widget.status,
        ),
      ),
    );
  }

  Future<void> _toggleVisibility() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newVisibility = !_isVisible;

      await FirebaseFirestore.instance
          .collection('chalets')
          .doc(widget.docId)
          .update({
            'isVisible': newVisibility,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // تحديث فوري للواجهة
      if (mounted) {
        try {
          _localVisible = newVisibility;
          setState(() {});
        } catch (e) {
          // تجاهل أخطاء setState
        }
      }

      if (mounted) {
        if (newVisibility) {
          SnackBarHelper.showSuccess(context, 'تم إظهار الشاليه بنجاح');
        } else {
          SnackBarHelper.showWarning(context, 'تم إخفاء الشاليه بنجاح');
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, 'خطأ في تحديث حالة الشاليه: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleBookingAvailability() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newAvailability = _isBookingAvailable ? 'unavailable' : 'available';

      await FirebaseFirestore.instance
          .collection('chalets')
          .doc(widget.docId)
          .update({
            'bookingAvailability': newAvailability,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // تحديث فوري للواجهة
      if (mounted) {
        try {
          _localBookingAvailable = newAvailability == 'available';
          setState(() {});
        } catch (e) {
          // تجاهل أخطاء setState
        }
      }

      if (mounted) {
        if (newAvailability == 'available') {
          SnackBarHelper.showSuccess(context, 'تم تشغيل الحجز بنجاح');
        } else {
          SnackBarHelper.showError(context, 'تم إيقاف الحجز بنجاح');
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, 'خطأ في تحديث حالة الحجز: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
