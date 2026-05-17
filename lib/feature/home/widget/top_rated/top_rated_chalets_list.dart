import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/feature/home/domain/entities/home_chalet_entity.dart';
import 'package:rebtal/feature/home/logic/cubit/home_cubit.dart';
import 'package:rebtal/feature/home/logic/cubit/home_state.dart';
import 'package:rebtal/feature/home/logic/helpers/top_rated_chalets_helper.dart';
import 'package:rebtal/feature/home/widget/top_rated/top_rated_chalet_card.dart';

class TopRatedChaletsList extends StatelessWidget {
  const TopRatedChaletsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HomeCubit, HomeState, List<HomeChaletEntity>>(
      selector: (state) =>
          TopRatedChaletsHelper.topRatedPreview(state.publicChalets),
      builder: (context, preview) {
        if (preview.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: preview.length,
            itemBuilder: (context, index) {
              return TopRatedChaletCard(entity: preview[index]);
            },
          ),
        );
      },
    );
  }
}
