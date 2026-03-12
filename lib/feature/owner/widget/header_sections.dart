import 'package:rebtal/core/Router/export_routes.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

class HeaderSectionOwner extends StatelessWidget {
  const HeaderSectionOwner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: ColorsManager.kPrimaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.add_home_work, color: ColorsManager.white, size: 40),
          const SizedBox(height: 15),
          Text(
            'List Your Chalet',
            style: TextStyle(
              color: ColorsManager.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share your beautiful chalet with guests and start earning',
            style: TextStyle(
              color: ColorsManager.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
