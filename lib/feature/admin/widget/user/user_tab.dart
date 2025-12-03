// ===== UsersTab: segmented control replacing TabBar =====
import 'package:flutter/material.dart';
import 'package:rebtal/feature/admin/widget/user/user_list.dart';

class UsersTab extends StatelessWidget {
  const UsersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // Segmented control header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Builder(
                builder: (context) {
                  final TabController tabController = DefaultTabController.of(
                    context,
                  );
                  // defensive fallback
                  final items = <Map<String, dynamic>>[
                    {'icon': Icons.person_outline, 'label': 'Users'},
                    {'icon': Icons.storefront_outlined, 'label': 'Owners'},
                    {
                      'icon': Icons.admin_panel_settings_outlined,
                      'label': 'Admins',
                    },
                  ];

                  return Row(
                    children: [
                      Expanded(
                        child: AnimatedBuilder(
                          animation:
                              tabController,
                          builder: (context, _) {
                            return Row(
                              children: List.generate(items.length, (i) {
                                final bool selected =
                                    (tabController.index) == i;
                                return Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: () => tabController.animateTo(i),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      margin: EdgeInsets.only(
                                        left: i == 0 ? 0 : 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? Colors.deepPurple
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: selected
                                              ? Colors.deepPurple
                                              : Colors.grey.withOpacity(0.12),
                                        ),
                                        boxShadow: selected
                                            ? [
                                                BoxShadow(
                                                  color: Colors.deepPurple
                                                      .withOpacity(0.08),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            items[i]['icon'] as IconData,
                                            size: 16,
                                            color: selected
                                                ? Colors.white
                                                : Colors.grey[700],
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            items[i]['label'] as String,
                                            style: TextStyle(
                                              color: selected
                                                  ? Colors.white
                                                  : Colors.grey[800],
                                              fontWeight: selected
                                                  ? FontWeight.w700
                                                  : FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                      ),

                      // small utility chip area (keeps header clean)
                    ],
                  );
                },
              ),
            ),
          ),

          // Tab views unchanged (keeps data & logic)
          const Expanded(
            child: TabBarView(
              physics: BouncingScrollPhysics(),
              children: [
                UsersList(collection: 'Users'),
                UsersList(collection: 'Owners'),
                UsersList(collection: 'Admins'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
