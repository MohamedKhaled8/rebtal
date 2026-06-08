import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/network/network_cubit.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/dependency/get_it.dart';

class NetworkConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const NetworkConnectivityWrapper({super.key, required this.child});

  @override
  State<NetworkConnectivityWrapper> createState() => _NetworkConnectivityWrapperState();
}

class _NetworkConnectivityWrapperState extends State<NetworkConnectivityWrapper> {
  bool _showBanner = false;
  bool _isOffline = false;
  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _handleNetworkChange(NetworkStatus status) {
    if (status == NetworkStatus.disconnected) {
      _hideTimer?.cancel();
      setState(() {
        _isOffline = true;
        _showBanner = true;
      });
    } else if (status == NetworkStatus.connected && _isOffline) {
      // Only show the "Back online" banner if we were previously offline.
      setState(() {
        _isOffline = false;
        _showBanner = true;
      });

      _hideTimer?.cancel();
      _hideTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && !_isOffline) {
          setState(() {
            _showBanner = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return BlocListener<NetworkCubit, NetworkStatus>(
      bloc: getIt<NetworkCubit>(),
      listener: (context, status) {
        _handleNetworkChange(status);
      },
      child: Stack(
        children: [
          widget.child,
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            bottom: _showBanner ? 40 : -100, // Slide up from bottom
            left: 20,
            right: 20,
            child: SafeArea(
              child: Material(
                color: Colors.transparent,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _isOffline 
                        ? (isDark ? Colors.red.shade900 : Colors.red)
                        : (isDark ? Colors.green.shade800 : const Color(0xFF10B981)), // Emerald Green
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isOffline ? Icons.wifi_off : Icons.wifi, 
                        color: Colors.white, 
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          _isOffline 
                              ? context.tr('auth_error_network') // "No internet connection"
                              : "تم استعادة الاتصال بالإنترنت بنجاح", // Back online
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
