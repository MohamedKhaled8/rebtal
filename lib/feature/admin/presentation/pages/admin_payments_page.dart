import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/admin/presentation/cubit/admin_cubit.dart';
import 'package:rebtal/feature/admin/presentation/cubit/admin_state.dart';
import 'package:rebtal/feature/admin/presentation/widgets/admin_payments_header.dart';
import 'package:rebtal/feature/admin/presentation/widgets/admin_payments_empty_state.dart';
import 'package:rebtal/feature/payment/models/payment_proof.dart';
import 'package:rebtal/feature/admin/presentation/widgets/admin_payment_card.dart';
import 'package:rebtal/core/utils/helper/booking_profile_fields.dart';

class AdminPaymentsPage extends StatefulWidget {
  const AdminPaymentsPage({super.key});

  @override
  State<AdminPaymentsPage> createState() => _AdminPaymentsPageState();
}

class _AdminPaymentsPageState extends State<AdminPaymentsPage> {
  String _selectedFilter = 'all';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _expandedCards = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark
          ? ColorsManager.darkBackground0F0F1E
          : ColorsManager.bookingsBackgroundLight,
      body: SafeArea(
        child: BlocBuilder<AdminCubit, AdminState>(
          builder: (context, state) {
            if (state is AdminLoading || state is AdminInitial) {
              return Center(
                child: CircularProgressIndicator(
                  color: ColorsManager.chaletAccent,
                ),
              );
            }

            if (state is AdminError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 56,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? Colors.white70 : Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () =>
                            context.read<AdminCubit>().startListeningToAll(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is! AdminDataLoaded) {
              return const SizedBox.shrink();
            }

            final proofs = state.paymentProofs
                .map(
                  (doc) => PaymentProof.fromMap({...doc.data(), 'id': doc.id}),
                )
                .toList();

            if (proofs.isEmpty) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(isDark),
                    AdminPaymentsEmptyState(isDark: isDark),
                  ],
                ),
              );
            }

            final filteredDocs = proofs.where((proof) {
              if (_selectedFilter != 'all') {
                if (_selectedFilter == 'pending' &&
                    proof.status != PaymentProofStatus.pending) {
                  return false;
                }
                if (_selectedFilter == 'approved' &&
                    proof.status != PaymentProofStatus.approved) {
                  return false;
                }
                if (_selectedFilter == 'rejected' &&
                    proof.status != PaymentProofStatus.rejected) {
                  return false;
                }
              }
              if (_searchQuery.isNotEmpty) {
                final query = _searchQuery.toLowerCase();
                return proof.bookingId.toLowerCase().contains(query) ||
                    proof.id.toLowerCase().contains(query) ||
                    proof.userName.toLowerCase().contains(query);
              }
              return true;
            }).toList();

            if (filteredDocs.isEmpty) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(isDark),
                    AdminPaymentsEmptyState(isDark: isDark, hasFilters: true),
                  ],
                ),
              );
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(isDark)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final proof = filteredDocs[index];
                      final bd = state.bookings
                          .where((d) => d.id == proof.bookingId)
                          .firstOrNull;
                      Map<String, dynamic>? raw;
                      if (bd != null) {
                        raw = {...bd.data(), '__id': bd.id};
                      }
                      final booking = enrichBookingMapWithOwnerProfiles(
                        raw,
                        state.users,
                        state.owners,
                      );

                      return AdminPaymentCard(
                        proof: proof,
                        bookingData: booking,
                        isDark: isDark,
                        isExpanded: _expandedCards.contains(proof.id),
                        onToggleExpand: () {
                          setState(() {
                            if (_expandedCards.contains(proof.id)) {
                              _expandedCards.remove(proof.id);
                            } else {
                              _expandedCards.add(proof.id);
                            }
                          });
                        },
                        onApprovePayment: (proofDocId, bookingId) =>
                            context.read<AdminCubit>().approvePaymentProof(
                              proofDocId: proofDocId,
                              bookingId: bookingId,
                            ),
                        onRejectPayment: (proofDocId, bookingId) =>
                            context.read<AdminCubit>().rejectPaymentProof(
                              proofDocId: proofDocId,
                              bookingId: bookingId,
                            ),
                      );
                    }, childCount: filteredDocs.length),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return AdminPaymentsHeader(
      isDark: isDark,
      searchController: _searchController,
      searchQuery: _searchQuery,
      onSearchChanged: (value) =>
          setState(() => _searchQuery = value.toLowerCase()),
      onClearSearch: () {
        _searchController.clear();
        setState(() => _searchQuery = '');
      },
      selectedFilter: _selectedFilter,
      onFilterChanged: (value) => setState(() => _selectedFilter = value),
    );
  }
}
