import 'package:equatable/equatable.dart';

enum BookingWizardStatus { initial, loading, success, failure, submitting }

class BookingNightLine extends Equatable {
  final DateTime date;
  final double price;

  const BookingNightLine({required this.date, required this.price});

  @override
  List<Object?> get props => [date, price];
}

class BookingWizardState extends Equatable {
  final int currentStep;
  final DateTime? startDate;
  final DateTime? endDate;
  final int guestCount; // Children count
  final BookingWizardStatus status;
  final String? errorMessage;

  // Pricing
  final double nightlyPrice;
  final double totalAmount;
  final int nights;
  final int days;
  final List<BookingNightLine> nightlyBreakdown;

  // Data for booking
  final String? ownerPhone;
  final String? ownerEmail;
  final String? ownerNameResolved;
  final String? ownerIdResolved;

  final String? userPhone;
  final String? userEmail;

  final bool termsAccepted;
  final bool isDayUse;

  /// Bumped when chalet Firestore data is merged into the wizard.
  final int dataRevision;

  // Rating post-booking
  final bool showRating;

  bool get isDatesSelected => startDate != null && endDate != null;

  const BookingWizardState({
    this.currentStep = 0,
    this.startDate,
    this.endDate,
    this.guestCount = 0,
    this.status = BookingWizardStatus.initial,
    this.errorMessage,
    this.nightlyPrice = 0.0,
    this.totalAmount = 0.0,
    this.nights = 0,
    this.days = 0,
    this.nightlyBreakdown = const [],
    this.ownerPhone,
    this.ownerEmail,
    this.ownerNameResolved,
    this.ownerIdResolved,
    this.userPhone,
    this.userEmail,
    this.termsAccepted = false,
    this.showRating = false,
    this.isDayUse = false,
    this.dataRevision = 0,
  });

  BookingWizardState copyWith({
    int? currentStep,
    DateTime? startDate,
    DateTime? endDate,
    int? guestCount,
    BookingWizardStatus? status,
    String? errorMessage,
    double? nightlyPrice,
    double? totalAmount,
    int? nights,
    int? days,
    List<BookingNightLine>? nightlyBreakdown,
    String? ownerPhone,
    String? ownerEmail,
    String? ownerNameResolved,
    String? ownerIdResolved,
    String? userPhone,
    String? userEmail,
    bool? termsAccepted,
    bool? showRating,
    bool? isDayUse,
    int? dataRevision,
  }) {
    return BookingWizardState(
      currentStep: currentStep ?? this.currentStep,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      guestCount: guestCount ?? this.guestCount,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      nightlyPrice: nightlyPrice ?? this.nightlyPrice,
      totalAmount: totalAmount ?? this.totalAmount,
      nights: nights ?? this.nights,
      days: days ?? this.days,
      nightlyBreakdown: nightlyBreakdown ?? this.nightlyBreakdown,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      ownerNameResolved: ownerNameResolved ?? this.ownerNameResolved,
      ownerIdResolved: ownerIdResolved ?? this.ownerIdResolved,
      userPhone: userPhone ?? this.userPhone,
      userEmail: userEmail ?? this.userEmail,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      showRating: showRating ?? this.showRating,
      isDayUse: isDayUse ?? this.isDayUse,
      dataRevision: dataRevision ?? this.dataRevision,
    );
  }

  @override
  List<Object?> get props => [
    currentStep,
    startDate,
    endDate,
    guestCount,
    status,
    errorMessage,
    nightlyPrice,
    totalAmount,
    nights,
    days,
    nightlyBreakdown,
    ownerPhone,
    ownerEmail,
    ownerNameResolved,
    ownerIdResolved,
    userPhone,
    userEmail,
    termsAccepted,
    showRating,
    isDayUse,
    dataRevision,
  ];
}
