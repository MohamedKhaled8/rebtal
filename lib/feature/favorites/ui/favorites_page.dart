import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/feature/home/widget/public_chalets_list.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'package:rebtal/feature/favorites/logic/cubit/favorites_cubit.dart';
import 'package:rebtal/feature/favorites/logic/cubit/favorites_state.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().getCurrentUser();
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final userId = user.uid;

    return BlocProvider(
      create: (context) => FavoritesCubit()..getFavorites(userId),
      child: Scaffold(
        backgroundColor: DynamicThemeManager.isDarkMode(context)
            ? const Color(0xFF001409)
            : ColorManager.white,
        appBar: AppBar(
          title: const Text(
            'المفضلة',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          centerTitle: true,
          backgroundColor: DynamicThemeManager.isDarkMode(context)
              ? ColorManager.black
              : ColorManager.white,
          foregroundColor: DynamicThemeManager.isDarkMode(context)
              ? ColorManager.white
              : ColorManager.black,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
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
                      size: 80,
                      color: DynamicThemeManager.isDarkMode(context)
                          ? Colors.white24
                          : Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'حدث خطأ',
                      style: TextStyle(
                        color: DynamicThemeManager.isDarkMode(context)
                            ? Colors.white70
                            : Colors.grey.shade600,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: TextStyle(
                        color: DynamicThemeManager.isDarkMode(context)
                            ? Colors.white54
                            : Colors.grey.shade500,
                        fontSize: 14,
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
                      Icon(
                        Icons.favorite_border_rounded,
                        size: 80,
                        color: DynamicThemeManager.isDarkMode(context)
                            ? Colors.white24
                            : Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد مفضلات بعد',
                        style: TextStyle(
                          color: DynamicThemeManager.isDarkMode(context)
                              ? Colors.white70
                              : Colors.grey.shade600,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.favorites.length,
                itemBuilder: (context, i) {
                  final favorite = state.favorites[i];
                  final chaletData = Map<String, dynamic>.from(
                    favorite['chaletData'] ?? {},
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: PublicChaletCard(
                      chaletData: chaletData,
                      docId: favorite['chaletId'] ?? favorite['id'],
                    ),
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
}
