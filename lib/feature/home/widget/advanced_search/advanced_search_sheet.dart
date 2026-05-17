import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/feature/home/logic/cubit/home_cubit.dart';
import 'package:rebtal/feature/home/widget/advanced_search/advanced_search_sheet_form.dart';

class AdvancedSearchSheet extends StatelessWidget {
  const AdvancedSearchSheet({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<HomeCubit>().initAdvancedSearchFromFilters();
    return const AdvancedSearchSheetForm();
  }
}
