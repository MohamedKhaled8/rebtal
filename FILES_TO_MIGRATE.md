# Files Requiring Migration to AppCubit

## Summary

Found **50+ files** that directly access feature cubits and need to be updated to access them through `AppCubit`.

---

## Migration Status

### ✅ Already Fixed
- `lib/feature/splash/ui/splash_screen.dart`

### ⚠️ Needs Fixing (50+ files)

#### Profile Feature
- `lib/feature/profile/widget/profile_content.dart` (3 occurrences)
- `lib/feature/profile/ui/user_invoices_page.dart` (3 occurrences)
- `lib/feature/profile/ui/profile_page.dart` (1 occurrence)

#### Payment Feature
- `lib/feature/payment/ui/payment_proof_upload_page.dart` (1 occurrence)
- `lib/feature/payment/ui/payment_method_selection_page.dart` (1 occurrence)

#### Owner Feature
- `lib/feature/owner/ui/widgets/booking_card.dart` (1 occurrence)
- `lib/feature/owner/ui/owner_chalet_Add_screen.dart` (2 occurrences)
- `lib/feature/owner/ui/owner_bookings_page.dart` (4 occurrences)
- `lib/feature/owner/ui/chalet_status_page.dart` (1 occurrence)

#### Notifications Feature
- `lib/feature/notifications/ui/notifications_screen.dart` (5 occurrences)
- `lib/feature/notifications/ui/notifications_page.dart` (6 occurrences)
- `lib/feature/notifications/widget/notification_icon_button.dart` (2 occurrences)

#### Navigation Feature
- `lib/feature/navigation/ui/bottom_navigation_screen.dart` (2 occurrences)

#### Home Feature
- `lib/feature/home/widget/public_chalets_list.dart` (1 occurrence)

#### Favorites Feature
- `lib/feature/favorites/ui/favorites_page.dart` (1 occurrence)

#### Booking Feature
- `lib/feature/booking/widgets/empty_bookings_state.dart` (1 occurrence)
- `lib/feature/booking/widgets/bookings_list.dart` (1 occurrence)
- `lib/feature/booking/ui/user_bookings_page.dart` (4 occurrences)
- `lib/feature/booking/ui/refund_request_page.dart` (1 occurrence)
- `lib/feature/booking/ui/booking_confirmation_page.dart` (1 occurrence)
- `lib/feature/booking/ui/booking_bridge_widget.dart` (2 occurrences - commented out)

#### Chalet Feature
- `lib/feature/chalet/ui/chalet_detail_page.dart` (1 occurrence)
- `lib/feature/chalet/widget/action_buttons.dart` (1 occurrence)
- `lib/feature/chalet/widget/user_buttons.dart` (1 occurrence)
- `lib/feature/chalet/logic/cubit/fixed_bottom_bar_cubit.dart` (1 occurrence)
- `lib/feature/chalet/logic/cubit/action_buttons_cubit.dart` (1 occurrence)

#### Admin Feature
- `lib/feature/admin/widget/mobile/mobile_drawer_widget.dart` (1 occurrence)

#### Auth Feature
- `lib/feature/auth/login/logic/login_cubit.dart` (1 occurrence - commented out)

---

## Migration Pattern

For each file, apply this pattern:

### 1. Add Import
```dart
import 'package:rebtal/core/app/cubit/app_cubit.dart';
```

### 2. Replace Direct Access
```dart
// ❌ Before
final authCubit = context.read<AuthCubit>();

// ✅ After
final authCubit = context.read<AppCubit>().authCubit;
```

### 3. Update BlocListener/BlocBuilder
```dart
// ❌ Before
BlocListener<AuthCubit, AuthState>(...)

// ✅ After
final authCubit = context.read<AppCubit>().authCubit;
BlocListener(bloc: authCubit, ...)
```

---

## Automated Migration Script

You can use this PowerShell script to help find and replace:

```powershell
# Find all files with direct cubit access
Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | 
  Select-String -Pattern "context\.read<(AuthCubit|BookingCubit|ThemeCubit|NotificationCubit)>" |
  Select-Object -ExpandProperty Path -Unique
```

---

## Priority Order

### High Priority (Core Navigation)
1. ✅ `splash_screen.dart` - **DONE**
2. `bottom_navigation_screen.dart` - Main navigation
3. `profile_page.dart` - Logout functionality
4. `notifications_page.dart` - Notifications

### Medium Priority (User Features)
5. `user_bookings_page.dart` - User bookings
6. `owner_bookings_page.dart` - Owner bookings
7. `booking_confirmation_page.dart` - Booking creation
8. `chalet_detail_page.dart` - Chalet viewing

### Low Priority (Admin/Settings)
9. `profile_content.dart` - Settings
10. `mobile_drawer_widget.dart` - Admin drawer
11. Other files

---

## Testing After Migration

After updating each file:

1. **Hot Restart** (not hot reload)
2. **Test the feature**:
   - Navigate to the screen
   - Perform actions (login, logout, create booking, etc.)
   - Verify no `ProviderNotFoundException` errors

3. **Check console** for any errors

---

## Example Migration

### File: `profile_page.dart`

**Before**:
```dart
ElevatedButton(
  onPressed: () {
    context.read<AuthCubit>().logout();  // ❌
  },
  child: Text('Logout'),
)
```

**After**:
```dart
// Add import at top
import 'package:rebtal/core/app/cubit/app_cubit.dart';

// Update code
ElevatedButton(
  onPressed: () {
    context.read<AppCubit>().logout();  // ✅
  },
  child: Text('Logout'),
)
```

---

## Need Help?

See `UI_MIGRATION_GUIDE.md` for detailed patterns and examples.

---

## Progress Tracker

- [x] splash_screen.dart
- [ ] bottom_navigation_screen.dart
- [ ] profile_page.dart
- [ ] profile_content.dart
- [ ] notifications_page.dart
- [ ] notifications_screen.dart
- [ ] notification_icon_button.dart
- [ ] user_bookings_page.dart
- [ ] owner_bookings_page.dart
- [ ] booking_confirmation_page.dart
- [ ] chalet_detail_page.dart
- [ ] ... (40+ more files)

**Estimated Time**: 2-4 hours for all files (if done manually)

**Recommendation**: Start with high-priority files and test incrementally.
