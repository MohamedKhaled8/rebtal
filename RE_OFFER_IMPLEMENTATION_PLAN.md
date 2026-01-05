# Re-Offer Booking Feature - Implementation Plan

## Executive Summary

This document outlines the complete implementation plan for the re-offer booking feature. This feature allows original tenants to transfer booking ownership while maintaining complete data integrity and audit trails.

## Core Principles

### 1. **NOT A NEW BOOKING SYSTEM**
- Re-offer is a **booking ownership transfer**, not a new booking
- Original booking ID **MUST NEVER CHANGE**
- Chalet reference **MUST REMAIN IMMUTABLE**
- Only tenant information changes upon acceptance

### 2. **Architecture Compliance**
- **MUST** use existing Cubit + Clean Architecture
- **ALL UI components MUST be stateless**
- **NO** stateful widgets allowed
- **NO** alternative state management approaches
- **NO** independent booking flows

### 3. **Data Integrity**
- **NO data deletion** - only state transitions
- Original tenant information **MUST be preserved permanently**
- All operations through Firestore transactions
- Complete audit trail maintained

---

## Phase 1: Data Layer

### 1.1 Extend Booking Model

**File**: `lib/feature/booking/models/booking.dart`

**Changes**:
```dart
enum BookingStatus {
  pending,
  approved,
  awaitingPayment,
  paymentUnderReview,
  confirmed,
  completed,
  rejected,
  cancelled,
  reOffered,  // NEW: Booking is re-offered
}

class Booking {
  // ... existing fields ...
  
  // NEW: Re-offer fields
  final String? originalTenantId;
  final String? originalTenantName;
  final String? originalTenantEmail;
  final String? originalTenantPhone;
  final DateTime? reOfferedAt;
  final String? offerId;  // Reference to the offer entity
}
```

### 1.2 Create Offer Model

**File**: `lib/feature/offer/models/offer.dart` (NEW)

```dart
class Offer {
  final String id;
  final String bookingId;  // Reference to existing booking
  final String originalTenantId;
  final String originalTenantName;
  final String originalTenantEmail;
  final String originalTenantPhone;
  final String chaletId;
  final String chaletName;
  final String chaletImage;
  final String chaletLocation;
  final String ownerId;
  final String ownerName;
  final DateTime from;
  final DateTime to;
  final double amount;
  final bool isNegotiable;  // For "Negotiable Price" badge
  final DateTime createdAt;
  final OfferStatus status;
}

enum OfferStatus {
  available,  // Re-offered and available
  accepted,   // Accepted by new tenant
  cancelled,  // Cancelled by original tenant
}
```

### 1.3 Create Offer Repository

**File**: `lib/feature/offer/data/repository/offer_repository.dart` (NEW)

**Responsibilities**:
- Create offer from existing booking
- Fetch available offers
- Accept offer (transfer booking ownership)
- Cancel offer

---

## Phase 2: Domain Layer

### 2.1 Create Base Repository Interface

**File**: `lib/feature/offer/domain/repository/base_offer_repository.dart` (NEW)

### 2.2 Create Use Cases

**Files** (NEW):
- `lib/feature/offer/domain/usecases/create_offer_usecase.dart`
- `lib/feature/offer/domain/usecases/fetch_offers_usecase.dart`
- `lib/feature/offer/domain/usecases/accept_offer_usecase.dart`
- `lib/feature/offer/domain/usecases/cancel_offer_usecase.dart`

---

## Phase 3: State Management Layer

### 3.1 Create OfferCubit

**File**: `lib/feature/offer/logic/cubit/offer_cubit.dart` (NEW)

**Responsibilities**:
- Manage offer state
- Coordinate with use cases
- Handle offer operations

**Key Methods**:
```dart
class OfferCubit extends Cubit<OfferState> {
  Future<void> createOffer(String bookingId);
  Future<void> fetchAvailableOffers();
  Future<void> acceptOffer(String offerId);
  Future<void> cancelOffer(String offerId);
  void contactOriginalTenant(String offerId, ContactMethod method);
}
```

### 3.2 Create OfferState

**File**: `lib/feature/offer/logic/cubit/offer_state.dart` (NEW)

```dart
abstract class OfferState {
  final List<Offer> offers;
  final bool isLoading;
  final String? error;
}

class OfferInitial extends OfferState
class OfferLoading extends OfferState
class OfferLoaded extends OfferState
class OfferError extends OfferState
class OfferCreated extends OfferState
class OfferAccepted extends OfferState
```

### 3.3 Integrate OfferCubit into AppCubit

**File**: `lib/core/app/cubit/app_cubit.dart`

**Changes**:
```dart
class AppCubit extends Cubit<AppState> {
  final OfferCubit _offerCubit;
  
  OfferCubit get offerCubit => _offerCubit;
  
  // Add listener in _setupListeners()
  void _handleOfferStateChange(OfferState offerState) {
    // Update AppState with offer data
  }
}
```

### 3.4 Update AppState

**File**: `lib/core/app/cubit/app_state.dart`

**Changes**:
```dart
class AppAuthenticated extends AppState {
  final List<Offer> availableOffers;
  final bool isOffersLoading;
  // ... existing fields ...
}
```

---

## Phase 4: Presentation Layer - Original Tenant Flow

### 4.1 Add Re-Offer Button to Booking Details

**File**: Modify existing booking details widget

**Location**: Below cancel booking button

**Requirements**:
- **MUST be stateless widget**
- Only visible to original tenant
- Only enabled for confirmed bookings
- Triggers `offerCubit.createOffer(bookingId)`

**UI**:
```dart
// Below cancel button
ElevatedButton(
  onPressed: () => context.read<AppCubit>().offerCubit.createOffer(booking.id),
  child: Text('إعادة عرض الحجز'),
)
```

---

## Phase 5: Presentation Layer - Offers Page

### 5.1 Create Offers Page

**File**: `lib/feature/offer/ui/offers_page.dart` (NEW)

**Requirements**:
- **MUST be stateless widget**
- Uses exact same card design as `PublicChaletCard`
- Only visual addition: "Negotiable Price" badge
- No layout changes to existing card structure
- Displays only re-offered bookings

**Structure**:
```dart
class OffersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        if (state is AppAuthenticated) {
          return ListView.builder(
            itemCount: state.availableOffers.length,
            itemBuilder: (context, index) {
              return OfferCard(offer: state.availableOffers[index]);
            },
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
```

### 5.2 Create Offer Card Widget

**File**: `lib/feature/offer/widgets/offer_card.dart` (NEW)

**Requirements**:
- **MUST be stateless widget**
- **MUST use exact same design as PublicChaletCard**
- Only addition: Small "Negotiable Price" badge
- Badge must not affect existing layout
- Same spacing, typography, visual hierarchy

**Badge Implementation**:
```dart
// Add to image stack (like rating badge)
Positioned(
  top: 16,
  left: 16,
  child: Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.orange.withOpacity(0.9),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      'سعر قابل للتفاوض',
      style: TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
)
```

### 5.3 Update Bottom Navigation

**File**: `lib/feature/navigation/ui/bottom_navigation_screen.dart`

**Changes for User Role**:
```dart
// Add Offers page to user screens
screens = const [
  HomeScreen(),
  FavoritesPage(),
  OffersPage(),  // NEW
  NotificationsPage(),
  UserBookingsPage(),
  ProfilePage(),
];

bottomNavItems = const [
  NavItem(icon: Icons.home, label: 'الرئيسية'),
  NavItem(icon: Icons.favorite, label: 'المفضلة'),
  NavItem(icon: Icons.local_offer, label: 'العروض'),  // NEW
  NavItem(icon: Icons.notifications, label: 'الإشعارات'),
  NavItem(icon: Icons.confirmation_number, label: 'الحجوزات'),
  NavItem(icon: Icons.person, label: 'الملف'),
];
```

---

## Phase 6: Presentation Layer - Offer Details

### 6.1 Create Offer Details Page

**File**: `lib/feature/offer/ui/offer_details_page.dart` (NEW)

**Requirements**:
- **MUST be stateless widget**
- **MUST retain same design as chalet details screen**
- Same sections, spacing, visual hierarchy
- Only functional differences allowed

**Functional Differences**:
1. Contact section at bottom (replaces booking button)
2. "Negotiable Price" indicator
3. Accept booking button (after contact)

**Contact Section**:
```dart
// At bottom of page
Row(
  children: [
    Expanded(
      child: ElevatedButton.icon(
        icon: Icon(Icons.phone),
        label: Text('اتصال هاتفي'),
        onPressed: () => _contactOriginalTenant(ContactMethod.phone),
      ),
    ),
    SizedBox(width: 12),
    Expanded(
      child: ElevatedButton.icon(
        icon: Icon(Icons.chat),
        label: Text('واتساب'),
        onPressed: () => _contactOriginalTenant(ContactMethod.whatsapp),
      ),
    ),
  ],
)
```

**After Contact**:
```dart
// Show accept button after contact
if (hasContacted) {
  ElevatedButton(
    onPressed: () => context.read<AppCubit>().offerCubit.acceptOffer(offer.id),
    child: Text('قبول الحجز'),
  )
}
```

---

## Phase 7: Presentation Layer - Owner View

### 7.1 Create Re-Offered Transfers Page

**File**: `lib/feature/owner/ui/owner_reoffer_transfers_page.dart` (NEW)

**Requirements**:
- **MUST be stateless widget**
- Display accepted re-offered bookings
- Show full new tenant details
- No approval/rejection actions (auto-accepted)

**Display Information**:
- New tenant name
- New tenant phone
- New tenant email
- Chalet number
- Booking date and time
- Full booking information

**Structure**:
```dart
class OwnerReofferTransfersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        if (state is AppAuthenticated) {
          final transfers = state.bookings
              .where((b) => b.originalTenantId != null)
              .toList();
          
          return ListView.builder(
            itemCount: transfers.length,
            itemBuilder: (context, index) {
              return TransferCard(booking: transfers[index]);
            },
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
```

---

## Phase 8: Financial System Integration

### 8.1 Invoice Management

**Requirements**:
1. Update original tenant's invoice to "resold" state
2. Create new invoice for new tenant
3. Link new invoice to same booking
4. No UI changes to invoices section

**Implementation**:
```dart
// In acceptOffer use case
Future<void> acceptOffer(String offerId) async {
  // 1. Get offer and booking
  // 2. Update original tenant invoice status
  await _updateInvoiceStatus(booking.id, booking.userId, 'resold');
  
  // 3. Create new invoice for new tenant
  await _createInvoice(
    bookingId: booking.id,
    userId: newTenantId,
    amount: booking.amount,
  );
  
  // 4. Transfer booking ownership
  // 5. Send notification to owner
}
```

---

## Phase 9: Dependency Injection

### 9.1 Register Dependencies

**File**: `lib/core/utils/dependency/get_it.dart`

**Additions**:
```dart
void setupGetIt() {
  // ... existing registrations ...
  
  // Offer Repository
  getIt.registerLazySingleton<BaseOfferRepository>(
    () => OfferRepository(),
  );
  
  // Offer Use Cases
  getIt.registerLazySingleton(() => CreateOfferUseCase(getIt()));
  getIt.registerLazySingleton(() => FetchOffersUseCase(getIt()));
  getIt.registerLazySingleton(() => AcceptOfferUseCase(getIt()));
  getIt.registerLazySingleton(() => CancelOfferUseCase(getIt()));
  
  // Offer Cubit
  getIt.registerLazySingleton(() => OfferCubit(
    createOfferUseCase: getIt(),
    fetchOffersUseCase: getIt(),
    acceptOfferUseCase: getIt(),
    cancelOfferUseCase: getIt(),
  ));
  
  // Update AppCubit registration to include OfferCubit
  getIt.registerLazySingleton<AppCubit>(() => AppCubit(
    authCubit: getIt(),
    bookingCubit: getIt(),
    themeCubit: getIt(),
    notificationCubit: getIt(),
    ownerCubit: getIt(),
    offerCubit: getIt(),  // NEW
  ));
}
```

---

## Phase 10: Routing

### 10.1 Add Routes

**File**: `lib/core/Router/routes.dart`

**Additions**:
```dart
class Routes {
  // ... existing routes ...
  static const String offersPage = '/offers';
  static const String offerDetails = '/offer-details';
  static const String ownerReofferTransfers = '/owner-reoffer-transfers';
}
```

### 10.2 Update Router

**File**: `lib/core/Router/app_router.dart`

**Additions**:
```dart
case Routes.offersPage:
  return MaterialPageRoute(builder: (_) => const OffersPage());

case Routes.offerDetails:
  final offer = settings.arguments as Offer;
  return MaterialPageRoute(
    builder: (_) => OfferDetailsPage(offer: offer),
  );

case Routes.ownerReofferTransfers:
  return MaterialPageRoute(
    builder: (_) => const OwnerReofferTransfersPage(),
  );
```

---

## Phase 11: Firestore Structure

### 11.1 Collections

**offers** (NEW Collection):
```json
{
  "id": "auto-generated",
  "bookingId": "reference-to-booking",
  "originalTenantId": "user-id",
  "originalTenantName": "name",
  "originalTenantEmail": "email",
  "originalTenantPhone": "phone",
  "chaletId": "chalet-id",
  "chaletName": "name",
  "chaletImage": "url",
  "chaletLocation": "location",
  "ownerId": "owner-id",
  "ownerName": "name",
  "from": "timestamp",
  "to": "timestamp",
  "amount": 1000.0,
  "isNegotiable": true,
  "status": "available",
  "createdAt": "timestamp"
}
```

**bookings** (Updated):
```json
{
  // ... existing fields ...
  "status": "reOffered",
  "originalTenantId": "preserved-user-id",
  "originalTenantName": "preserved-name",
  "originalTenantEmail": "preserved-email",
  "originalTenantPhone": "preserved-phone",
  "reOfferedAt": "timestamp",
  "offerId": "reference-to-offer"
}
```

### 11.2 Security Rules

**firestore.rules**:
```
match /offers/{offerId} {
  // Allow read for authenticated users
  allow read: if request.auth != null;
  
  // Allow create only by original tenant
  allow create: if request.auth != null 
    && request.resource.data.originalTenantId == request.auth.uid;
  
  // Allow update only for acceptance
  allow update: if request.auth != null 
    && request.resource.data.status == 'accepted';
}
```

---

## Implementation Checklist

### Phase 1: Data Layer ✓
- [ ] Extend Booking model with re-offer fields
- [ ] Create Offer model
- [ ] Create OfferRepository
- [ ] Create BaseOfferRepository interface

### Phase 2: Domain Layer ✓
- [ ] Create CreateOfferUseCase
- [ ] Create FetchOffersUseCase
- [ ] Create AcceptOfferUseCase
- [ ] Create CancelOfferUseCase

### Phase 3: State Management ✓
- [ ] Create OfferCubit
- [ ] Create OfferState
- [ ] Integrate OfferCubit into AppCubit
- [ ] Update AppState

### Phase 4: Original Tenant Flow ✓
- [ ] Add re-offer button to booking details
- [ ] Implement create offer logic

### Phase 5: Offers Page ✓
- [ ] Create OffersPage (stateless)
- [ ] Create OfferCard widget (stateless, same design as PublicChaletCard)
- [ ] Add "Negotiable Price" badge
- [ ] Update bottom navigation

### Phase 6: Offer Details ✓
- [ ] Create OfferDetailsPage (stateless)
- [ ] Implement contact section
- [ ] Implement accept booking logic

### Phase 7: Owner View ✓
- [ ] Create OwnerReofferTransfersPage
- [ ] Display transfer information

### Phase 8: Financial Integration ✓
- [ ] Update original tenant invoice
- [ ] Create new tenant invoice

### Phase 9: Dependency Injection ✓
- [ ] Register all dependencies in GetIt

### Phase 10: Routing ✓
- [ ] Add routes
- [ ] Update router

### Phase 11: Firestore ✓
- [ ] Create offers collection
- [ ] Update security rules
- [ ] Test data integrity

---

## Testing Strategy

### Unit Tests
- [ ] Test OfferCubit state transitions
- [ ] Test use cases
- [ ] Test repository methods

### Integration Tests
- [ ] Test complete re-offer flow
- [ ] Test booking ownership transfer
- [ ] Test invoice generation

### UI Tests
- [ ] Verify stateless widgets
- [ ] Verify design consistency
- [ ] Verify navigation flow

---

## Critical Success Factors

1. **Data Integrity**: Original booking ID never changes
2. **Audit Trail**: Original tenant info permanently preserved
3. **Architecture Compliance**: All widgets stateless, using Cubit
4. **Design Consistency**: Offer cards identical to chalet cards
5. **No Data Deletion**: Only state transitions
6. **Transaction Safety**: All operations in Firestore transactions

---

## Risk Mitigation

### Risk: Booking ID Changes
**Mitigation**: Use Firestore transactions, validate booking ID before and after

### Risk: Data Loss
**Mitigation**: Preserve all original data in separate fields before transfer

### Risk: UI Inconsistency
**Mitigation**: Reuse existing card components, only add badge

### Risk: State Management Issues
**Mitigation**: Follow existing AppCubit pattern strictly

---

## Timeline Estimate

- **Phase 1-2 (Data + Domain)**: 2-3 hours
- **Phase 3 (State Management)**: 2 hours
- **Phase 4-7 (UI)**: 4-5 hours
- **Phase 8 (Financial)**: 2 hours
- **Phase 9-10 (DI + Routing)**: 1 hour
- **Phase 11 (Firestore)**: 1 hour
- **Testing**: 2-3 hours

**Total**: ~15-17 hours

---

## Post-Implementation Verification

- [ ] Booking ID remains unchanged after transfer
- [ ] Original tenant info preserved
- [ ] New tenant can access booking
- [ ] Owner receives notification
- [ ] Invoices correctly generated
- [ ] All widgets are stateless
- [ ] Design matches existing cards
- [ ] No data deleted from Firestore
