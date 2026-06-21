import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/owner/logic/cubit/owner_cubit.dart';
import 'package:rebtal/feature/owner/logic/cubit/owner_state.dart';

typedef OwnerChaletFormColumnBuilder = Widget Function(
  BuildContext context,
  bool isDark,
  OwnerCubit ownerCubit,
  ChaletDraft draft,
);

/// Rebuilds the edit form only when draft changes beyond typing; strips keyboard insets.
class OwnerChaletFormHost extends StatefulWidget {
  const OwnerChaletFormHost({
    super.key,
    required this.cubit,
    required this.builder,
  });

  final OwnerCubit cubit;
  final OwnerChaletFormColumnBuilder builder;

  @override
  State<OwnerChaletFormHost> createState() => _OwnerChaletFormHostState();
}

class _OwnerChaletFormHostState extends State<OwnerChaletFormHost>
    with AutomaticKeepAliveClientMixin {
  late OwnerState _formState;
  StreamSubscription<OwnerState>? _sub;

  @override
  bool get wantKeepAlive => true;

  bool _shouldRebuildForm(OwnerState prev, OwnerState next) {
    if (prev.isFormSubmitting != next.isFormSubmitting) return true;
    if (prev.isLocationLoading != next.isLocationLoading) return true;
    if (prev.locationResults != next.locationResults) return true;
    if (prev.draft.differsOnlyByTypingInForm(next.draft)) return false;
    return prev.draft != next.draft;
  }

  @override
  void initState() {
    super.initState();
    _formState = widget.cubit.state;
    _sub = widget.cubit.stream.listen((next) {
      final prev = _formState;
      _formState = next;
      if (_shouldRebuildForm(prev, next) && mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = DynamicThemeManager.isDarkMode(context);
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(viewInsets: EdgeInsets.zero),
      child: widget.builder(
        context,
        isDark,
        widget.cubit,
        _formState.draft,
      ),
    );
  }
}
