import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/constant/image_assets_manger.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/feature/home/widget/public_chalet/public_chalet_card.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/feature/favorites/logic/cubit/favorites_cubit.dart';
import 'package:rebtal/feature/favorites/logic/cubit/favorites_state.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AppCubit>().authCubit.getCurrentUser();
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final userId = user.uid;

    return BlocProvider(
      create: (context) => FavoritesCubit()..getFavorites(userId),
      child: Scaffold(
        backgroundColor: DynamicThemeManager.isDarkMode(context)
            ? Colors.black
            : ColorsManager.chaletBackgroundLight,
        appBar: AppBar(
          title: Text(
            context.tr('home_favorites'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: stv(
                context: context,
                mobile: 20.spScaled,
                tablet: 24.spScaled,
                desktop: 28.spScaled,
              ),
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: true,
          backgroundColor: DynamicThemeManager.isDarkMode(context)
              ? Colors.black
              : ColorsManager.chaletBackgroundLight,
          foregroundColor: DynamicThemeManager.isDarkMode(context)
              ? ColorsManager.white
              : ColorsManager.black,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        body: BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, state) {
            if (state is FavoritesLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is FavoritesError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: stv(
                        context: context,
                        mobile: 80.spScaled,
                        tablet: 100.spScaled,
                        desktop: 120.spScaled,
                      ),
                      color: DynamicThemeManager.isDarkMode(context)
                          ? ColorsManager.white24
                          : ColorsManager.chaletGrey400,
                    ),
                    SizedBox(
                      height: otv(
                        context: context,
                        portrait: 16.sh,
                        landscape: 8.sh,
                      ),
                    ),
                    Text(
                      context.tr('common_error'),
                      style: TextStyle(
                        color: DynamicThemeManager.isDarkMode(context)
                            ? ColorsManager.white70
                            : ColorsManager.chaletGrey500,
                        fontSize: stv(
                          context: context,
                          mobile: 18.spScaled,
                          tablet: 22.spScaled,
                          desktop: 26.spScaled,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: otv(
                        context: context,
                        portrait: 8.sh,
                        landscape: 4.sh,
                      ),
                    ),
                    Text(
                      state.message,
                      style: TextStyle(
                        color: DynamicThemeManager.isDarkMode(context)
                            ? ColorsManager.white70.withOpacity(0.7)
                            : ColorsManager.chaletGrey500,
                        fontSize: stv(
                          context: context,
                          mobile: 14.spScaled,
                          tablet: 16.spScaled,
                          desktop: 18.spScaled,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            if (state is FavoritesLoaded) {
              if (state.favorites.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppImageHelper(
                        path: ImageAssetsManger.favoriteRibbon,
                        height: otv(
                          context: context,
                          portrait: 200.sh,
                          landscape: 150.sh,
                        ),
                        width: otv(
                          context: context,
                          portrait: 200.sw,
                          landscape: 150.sw,
                        ),
                        fit: BoxFit.contain,
                      ),

                      SizedBox(
                        height: otv(
                          context: context,
                          portrait: 16.sh,
                          landscape: 8.sh,
                        ),
                      ),
                      Text(
                        context.tr('favorites_no_favorites'),
                        style: TextStyle(
                          color: DynamicThemeManager.isDarkMode(context)
                              ? ColorsManager.white70
                              : ColorsManager.chaletGrey500,
                          fontSize: stv(
                            context: context,
                            mobile: 18.spScaled,
                            tablet: 22.spScaled,
                            desktop: 26.spScaled,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Builder(
                builder: (context) {
                  final bool showTwoColumns = otv(
                    context: context,
                    portrait: stv(
                      context: context,
                      mobile: false,
                      tablet: true,
                      desktop: true,
                    ),
                    landscape: true,
                  );

                  if (showTwoColumns) {
                    final int rowCount = (state.favorites.length / 2).ceil();
                    return ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 16.sh),
                      itemCount: rowCount,
                      itemBuilder: (context, index) {
                        final firstIndex = index * 2;
                        final secondIndex = firstIndex + 1;

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildFavoriteCard(
                                context,
                                state.favorites[firstIndex],
                                isLeft: true,
                              ),
                            ),
                            if (secondIndex < state.favorites.length)
                              Expanded(
                                child: _buildFavoriteCard(
                                  context,
                                  state.favorites[secondIndex],
                                  isLeft: false,
                                ),
                              )
                            else
                              const Expanded(child: SizedBox.shrink()),
                          ],
                        );
                      },
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 16.sh),
                    itemCount: state.favorites.length,
                    itemBuilder: (context, i) {
                      return _buildFavoriteCard(context, state.favorites[i]);
                    },
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(
    BuildContext context,
    Map<String, dynamic> favorite, {
    bool? isLeft,
  }) {
    final chaletData = Map<String, dynamic>.from(favorite['chaletData'] ?? {});
    return PublicChaletCard(
      chaletData: chaletData,
      docId: favorite['chaletId'] ?? favorite['id'],
      margin: EdgeInsets.only(
        bottom: otv(context: context, portrait: 24.sh, landscape: 12.sh),
        left:
            isLeft == null
                ? stv(
                  context: context,
                  mobile: 16.sw,
                  tablet: 24.sw,
                  desktop: 32.sw,
                )
                : (isLeft
                    ? stv(
                      context: context,
                      mobile: 16.sw,
                      tablet: 24.sw,
                      desktop: 32.sw,
                    )
                    : stv(
                      context: context,
                      mobile: 12.sw,
                      tablet: 16.sw,
                      desktop: 20.sw,
                    )),
        right:
            isLeft == null
                ? stv(
                  context: context,
                  mobile: 16.sw,
                  tablet: 24.sw,
                  desktop: 32.sw,
                )
                : (isLeft
                    ? stv(
                      context: context,
                      mobile: 12.sw,
                      tablet: 16.sw,
                      desktop: 20.sw,
                    )
                    : stv(
                      context: context,
                      mobile: 16.sw,
                      tablet: 24.sw,
                      desktop: 32.sw,
                    )),
      ),
    );
  }
}
