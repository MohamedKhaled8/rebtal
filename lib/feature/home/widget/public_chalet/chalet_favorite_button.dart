import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/feature/home/logic/cubit/home_cubit.dart';
import 'package:rebtal/feature/home/logic/cubit/home_state.dart';
import 'package:rebtal/core/utils/dependency/get_it.dart';
import 'package:rebtal/core/utils/widgets/glass_badge.dart';

class ChaletFavoriteButton extends StatefulWidget {
  const ChaletFavoriteButton({
    super.key,
    required this.chaletId,
    required this.chaletData,
  });

  final String chaletId;
  final Map<String, dynamic> chaletData;

  @override
  State<ChaletFavoriteButton> createState() => ChaletFavoriteButtonState();
}

class ChaletFavoriteButtonState extends State<ChaletFavoriteButton> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final homeCubit = getIt<HomeCubit>();
      final userId = context.read<AppCubit>().authCubit.getCurrentUser()?.uid;
      homeCubit.setFavoriteUserId(userId);
      homeCubit.ensureChaletFavoriteLoaded(widget.chaletId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      bloc: getIt<HomeCubit>(),
      buildWhen: (previous, current) {
        final prevFav = previous.isFavorite(widget.chaletId);
        final currFav = current.isFavorite(widget.chaletId);
        final prevBusy = previous.isFavoriteBusy(widget.chaletId);
        final currBusy = current.isFavoriteBusy(widget.chaletId);
        return prevFav != currFav || prevBusy != currBusy;
      },
      builder: (context, state) {
        final canToggle =
            state.favoriteUserId != null && !state.isFavoriteBusy(widget.chaletId);

        return GestureDetector(
          onTap: canToggle
              ? () async {
                  final success = await getIt<HomeCubit>().toggleChaletFavorite(
                        chaletId: widget.chaletId,
                        chaletData: widget.chaletData,
                      );
                  if (!success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.tr('favorites_update_error')),
                      ),
                    );
                  }
                }
              : null,
          child: GlassBadge(
            padding: const EdgeInsets.all(8),
            borderRadius: 50,
            backgroundColor: Colors.black.withOpacity(0.35),
            borderColor: Colors.white.withOpacity(0.3),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                state.isFavorite(widget.chaletId)
                    ? Icons.favorite
                    : Icons.favorite_border,
                key: ValueKey<bool>(state.isFavorite(widget.chaletId)),
                color: state.isFavorite(widget.chaletId)
                    ? Colors.redAccent
                    : Colors.white,
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }
}
