import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/feature/owner/logic/cubit/owner_cubit.dart';
import 'package:rebtal/feature/owner/logic/cubit/owner_state.dart';
import 'package:rebtal/feature/owner/widget/owner_chalets_list.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'package:rebtal/feature/owner/ui/owner_screen.dart';
import 'package:rebtal/core/utils/home_search_notifier.dart';

class OwnerChaletsPage extends StatefulWidget {
  const OwnerChaletsPage({super.key});

  @override
  State<OwnerChaletsPage> createState() => _OwnerChaletsPageState();
}

class _OwnerChaletsPageState extends State<OwnerChaletsPage> {
  OwnerCubit? _cubit;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit = OwnerCubit();
    _cubit?.fetchChalets();
    _searchController.text = HomeSearch.q.value;
  }

  @override
  void dispose() {
    _cubit?.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cubit == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocProvider.value(
      value: _cubit!,
      child: BlocBuilder<OwnerCubit, OwnerState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: ColorManager.white,
            body: CustomScrollView(
              slivers: [
                // Responsive Header with Search and Add Button
                SliverAppBar(
                  expandedHeight: MediaQuery.of(context).size.height * 0.25,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: const Color(0xFF1A1A2E),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1A1A2E), // Dark Blue
                            Color(0xFF16213E), // Darker Blue
                            Color(0xFF0F3460), // Navy Blue
                          ],
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.05,
                            vertical: 16,
                          ),
                          child: Column(
                            children: [
                              // Top Row with Title
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,

                                children: [
                                  const Text(
                                    'شاليهاتي',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Search Bar - Responsive
                              Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 16),
                                    Icon(
                                      Icons.search,
                                      color: Colors.grey[600],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ValueListenableBuilder<String>(
                                        valueListenable: HomeSearch.q,
                                        builder: (context, value, _) {
                                          return TextField(
                                            controller: _searchController,
                                            onChanged: (v) =>
                                                HomeSearch.q.value = v,
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: 'ابحث عن الشاليهات...',
                                              hintStyle: TextStyle(
                                                color: Colors.grey[400],
                                                fontSize: 14,
                                              ),
                                              border: InputBorder.none,
                                              isDense: true,
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Add Button - Responsive
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final result = await Navigator.push<bool?>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BlocProvider(
                                          create: (context) => OwnerCubit(),
                                          child: const OwnerChaletAddScreen(),
                                        ),
                                      ),
                                    );
                                    if (result == true) {
                                      _cubit?.fetchChalets();
                                    }
                                  },
                                  icon: const Icon(Icons.add_rounded, size: 18),
                                  label: const Text(
                                    'إضافة شاليه جديد',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE94560),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Chalets List
                SliverToBoxAdapter(
                  child: Builder(
                    builder: (context) {
                      final currentUser = context
                          .read<AuthCubit>()
                          .getCurrentUser();
                      final ownerId = currentUser?.uid;

                      return RefreshIndicator(
                        onRefresh: () =>
                            context.read<OwnerCubit>().fetchChalets(),
                        color: const Color(0xFFE94560),
                        backgroundColor: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 8,
                            bottom: 100, // مسافة كبيرة للـ BottomNavBar
                          ),
                          child: OwnerChaletsList(
                            status: 'approved',
                            ownerId: ownerId,
                            emptyIcon: Icons.home_outlined,
                            emptyTitle: 'لا توجد شاليهات موافق عليها',
                            emptySubtitle: 'ستظهر الشاليهات الموافق عليها هنا',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
