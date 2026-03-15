import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'arb_localizations_ar.dart';
import 'arb_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of ArbLocalizations
/// returned by `ArbLocalizations.of(context)`.
///
/// Applications need to include `ArbLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/arb_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: ArbLocalizations.localizationsDelegates,
///   supportedLocales: ArbLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the ArbLocalizations.supportedLocales
/// property.
abstract class ArbLocalizations {
  ArbLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static ArbLocalizations? of(BuildContext context) {
    return Localizations.of<ArbLocalizations>(context, ArbLocalizations);
  }

  static const LocalizationsDelegate<ArbLocalizations> delegate =
      _ArbLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @language_select_title.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get language_select_title;

  /// No description provided for @language_select_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get language_select_subtitle;

  /// No description provided for @language_arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get language_arabic;

  /// No description provided for @language_arabic_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Arabic Language'**
  String get language_arabic_subtitle;

  /// No description provided for @language_english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language_english;

  /// No description provided for @language_english_subtitle.
  ///
  /// In en, this message translates to:
  /// **'English Language'**
  String get language_english_subtitle;

  /// No description provided for @language_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Selection'**
  String get language_confirm;

  /// No description provided for @nav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_home;

  /// No description provided for @nav_favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get nav_favorites;

  /// No description provided for @nav_day_use.
  ///
  /// In en, this message translates to:
  /// **'Day Use'**
  String get nav_day_use;

  /// No description provided for @nav_bookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get nav_bookings;

  /// No description provided for @nav_admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get nav_admin;

  /// No description provided for @nav_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get nav_profile;

  /// No description provided for @nav_chalets.
  ///
  /// In en, this message translates to:
  /// **'Chalets'**
  String get nav_chalets;

  /// No description provided for @nav_transfers.
  ///
  /// In en, this message translates to:
  /// **'Transfers'**
  String get nav_transfers;

  /// No description provided for @nav_cancellations.
  ///
  /// In en, this message translates to:
  /// **'Cancellations'**
  String get nav_cancellations;

  /// No description provided for @nav_offers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get nav_offers;

  /// No description provided for @auth_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get auth_email;

  /// No description provided for @auth_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get auth_password;

  /// No description provided for @auth_forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get auth_forgot_password;

  /// No description provided for @auth_login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get auth_login;

  /// No description provided for @auth_register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get auth_register;

  /// No description provided for @auth_terms.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get auth_terms;

  /// No description provided for @auth_full_name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get auth_full_name;

  /// No description provided for @auth_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get auth_phone;

  /// No description provided for @auth_have_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get auth_have_account;

  /// No description provided for @auth_role_user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get auth_role_user;

  /// No description provided for @auth_role_owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get auth_role_owner;

  /// No description provided for @auth_camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get auth_camera;

  /// No description provided for @auth_gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get auth_gallery;

  /// No description provided for @home_search_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Where do you want to go?'**
  String get home_search_placeholder;

  /// No description provided for @home_welcome_back.
  ///
  /// In en, this message translates to:
  /// **'Welcome back 👋'**
  String get home_welcome_back;

  /// No description provided for @home_new_user.
  ///
  /// In en, this message translates to:
  /// **'New User'**
  String get home_new_user;

  /// No description provided for @home_explore_chalets.
  ///
  /// In en, this message translates to:
  /// **'Explore Chalets'**
  String get home_explore_chalets;

  /// No description provided for @home_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get home_reset;

  /// No description provided for @home_no_results.
  ///
  /// In en, this message translates to:
  /// **'No matching results'**
  String get home_no_results;

  /// No description provided for @home_advanced_search.
  ///
  /// In en, this message translates to:
  /// **'Advanced Search'**
  String get home_advanced_search;

  /// No description provided for @home_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search for chalet by name or description...'**
  String get home_search_hint;

  /// No description provided for @home_search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get home_search;

  /// No description provided for @home_chalet_no_name.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Chalet'**
  String get home_chalet_no_name;

  /// No description provided for @home_location_unknown.
  ///
  /// In en, this message translates to:
  /// **'Location not specified'**
  String get home_location_unknown;

  /// No description provided for @home_special_offer.
  ///
  /// In en, this message translates to:
  /// **'Special Offer'**
  String get home_special_offer;

  /// No description provided for @home_popular_destinations.
  ///
  /// In en, this message translates to:
  /// **'Most Requested Destinations'**
  String get home_popular_destinations;

  /// No description provided for @booking_select_dates.
  ///
  /// In en, this message translates to:
  /// **'Select Booking Period'**
  String get booking_select_dates;

  /// No description provided for @booking_select_start_end.
  ///
  /// In en, this message translates to:
  /// **'Select start and end dates'**
  String get booking_select_start_end;

  /// No description provided for @booking_from_date.
  ///
  /// In en, this message translates to:
  /// **'From date'**
  String get booking_from_date;

  /// No description provided for @booking_to_date.
  ///
  /// In en, this message translates to:
  /// **'To date'**
  String get booking_to_date;

  /// No description provided for @booking_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get booking_confirm;

  /// No description provided for @booking_my_bookings.
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get booking_my_bookings;

  /// No description provided for @booking_no_bookings.
  ///
  /// In en, this message translates to:
  /// **'No bookings'**
  String get booking_no_bookings;

  /// No description provided for @booking_print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get booking_print;

  /// No description provided for @booking_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get booking_save;

  /// No description provided for @booking_update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get booking_update;

  /// No description provided for @booking_contact_support.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get booking_contact_support;

  /// No description provided for @booking_date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get booking_date;

  /// No description provided for @booking_review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get booking_review;

  /// No description provided for @booking_payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get booking_payment;

  /// No description provided for @booking_please_login.
  ///
  /// In en, this message translates to:
  /// **'Please login to continue'**
  String get booking_please_login;

  /// No description provided for @booking_confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get booking_confirmed;

  /// No description provided for @booking_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get booking_cancelled;

  /// No description provided for @booking_accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get booking_accepted;

  /// No description provided for @booking_rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get booking_rejected;

  /// No description provided for @booking_payment_rejected.
  ///
  /// In en, this message translates to:
  /// **'Payment Rejected'**
  String get booking_payment_rejected;

  /// No description provided for @booking_whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get booking_whatsapp;

  /// No description provided for @booking_call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get booking_call;

  /// No description provided for @booking_check_in.
  ///
  /// In en, this message translates to:
  /// **'Check-in'**
  String get booking_check_in;

  /// No description provided for @booking_check_out.
  ///
  /// In en, this message translates to:
  /// **'Check-out'**
  String get booking_check_out;

  /// No description provided for @booking_cancellation_details.
  ///
  /// In en, this message translates to:
  /// **'Cancellation Details'**
  String get booking_cancellation_details;

  /// No description provided for @booking_confirm_cancellation.
  ///
  /// In en, this message translates to:
  /// **'Confirm Final Cancellation'**
  String get booking_confirm_cancellation;

  /// No description provided for @booking_revert.
  ///
  /// In en, this message translates to:
  /// **'Revert'**
  String get booking_revert;

  /// No description provided for @booking_confirm_cancel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Cancellation'**
  String get booking_confirm_cancel;

  /// No description provided for @booking_refund_reason.
  ///
  /// In en, this message translates to:
  /// **'Please explain the reason for cancelling the booking...'**
  String get booking_refund_reason;

  /// No description provided for @chalet_day_use.
  ///
  /// In en, this message translates to:
  /// **'Day Use Chalets'**
  String get chalet_day_use;

  /// No description provided for @chalet_offers.
  ///
  /// In en, this message translates to:
  /// **'Resale Offers'**
  String get chalet_offers;

  /// No description provided for @chalet_login_to_favorite.
  ///
  /// In en, this message translates to:
  /// **'Please login to add to favorites'**
  String get chalet_login_to_favorite;

  /// No description provided for @chalet_removed_from_favorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get chalet_removed_from_favorites;

  /// No description provided for @chalet_cancel_offer.
  ///
  /// In en, this message translates to:
  /// **'Cancel Offer'**
  String get chalet_cancel_offer;

  /// No description provided for @chalet_phone_call.
  ///
  /// In en, this message translates to:
  /// **'Phone Call'**
  String get chalet_phone_call;

  /// No description provided for @chalet_whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get chalet_whatsapp;

  /// No description provided for @chalet_beds.
  ///
  /// In en, this message translates to:
  /// **'Beds'**
  String get chalet_beds;

  /// No description provided for @chalet_baths.
  ///
  /// In en, this message translates to:
  /// **'Baths'**
  String get chalet_baths;

  /// No description provided for @chalet_child.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get chalet_child;

  /// No description provided for @chalet_wifi.
  ///
  /// In en, this message translates to:
  /// **'WiFi'**
  String get chalet_wifi;

  /// No description provided for @chalet_breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get chalet_breakfast;

  /// No description provided for @chalet_parking.
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get chalet_parking;

  /// No description provided for @chalet_pool.
  ///
  /// In en, this message translates to:
  /// **'Pool'**
  String get chalet_pool;

  /// No description provided for @chalet_ac.
  ///
  /// In en, this message translates to:
  /// **'AC'**
  String get chalet_ac;

  /// No description provided for @chalet_garden.
  ///
  /// In en, this message translates to:
  /// **'Garden'**
  String get chalet_garden;

  /// No description provided for @chalet_bbq.
  ///
  /// In en, this message translates to:
  /// **'BBQ Area'**
  String get chalet_bbq;

  /// No description provided for @chalet_beach_view.
  ///
  /// In en, this message translates to:
  /// **'Beach View'**
  String get chalet_beach_view;

  /// No description provided for @chalet_housekeeping.
  ///
  /// In en, this message translates to:
  /// **'Housekeeping'**
  String get chalet_housekeeping;

  /// No description provided for @chalet_pets.
  ///
  /// In en, this message translates to:
  /// **'Pets Allowed'**
  String get chalet_pets;

  /// No description provided for @chalet_gym.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get chalet_gym;

  /// No description provided for @chalet_kitchen.
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get chalet_kitchen;

  /// No description provided for @chalet_tv.
  ///
  /// In en, this message translates to:
  /// **'TV'**
  String get chalet_tv;

  /// No description provided for @owner_search_chalets.
  ///
  /// In en, this message translates to:
  /// **'Search your chalets...'**
  String get owner_search_chalets;

  /// No description provided for @owner_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get owner_all;

  /// No description provided for @owner_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get owner_active;

  /// No description provided for @owner_pending_review.
  ///
  /// In en, this message translates to:
  /// **'Pending Review'**
  String get owner_pending_review;

  /// No description provided for @owner_cancellation_log.
  ///
  /// In en, this message translates to:
  /// **'Cancellation Log'**
  String get owner_cancellation_log;

  /// No description provided for @owner_contact_client.
  ///
  /// In en, this message translates to:
  /// **'Contact Client'**
  String get owner_contact_client;

  /// No description provided for @owner_booking_transfers.
  ///
  /// In en, this message translates to:
  /// **'Booking Transfers'**
  String get owner_booking_transfers;

  /// No description provided for @owner_user_not_registered.
  ///
  /// In en, this message translates to:
  /// **'User not registered'**
  String get owner_user_not_registered;

  /// No description provided for @owner_add_new_chalet.
  ///
  /// In en, this message translates to:
  /// **'Add New Chalet'**
  String get owner_add_new_chalet;

  /// No description provided for @owner_info.
  ///
  /// In en, this message translates to:
  /// **'Owner Information'**
  String get owner_info;

  /// No description provided for @owner_name.
  ///
  /// In en, this message translates to:
  /// **'Owner Name'**
  String get owner_name;

  /// No description provided for @owner_chalet_name.
  ///
  /// In en, this message translates to:
  /// **'Chalet Name'**
  String get owner_chalet_name;

  /// No description provided for @owner_chalet_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your chalet name'**
  String get owner_chalet_name_hint;

  /// No description provided for @owner_location.
  ///
  /// In en, this message translates to:
  /// **'Geographical Location'**
  String get owner_location;

  /// No description provided for @owner_show_full_details.
  ///
  /// In en, this message translates to:
  /// **'Show Full Details'**
  String get owner_show_full_details;

  /// No description provided for @owner_old_tenant.
  ///
  /// In en, this message translates to:
  /// **'Old Tenant'**
  String get owner_old_tenant;

  /// No description provided for @owner_new_tenant.
  ///
  /// In en, this message translates to:
  /// **'New Tenant'**
  String get owner_new_tenant;

  /// No description provided for @owner_arrival_date.
  ///
  /// In en, this message translates to:
  /// **'Arrival Date'**
  String get owner_arrival_date;

  /// No description provided for @owner_departure_date.
  ///
  /// In en, this message translates to:
  /// **'Departure Date'**
  String get owner_departure_date;

  /// No description provided for @owner_undefined.
  ///
  /// In en, this message translates to:
  /// **'Undefined'**
  String get owner_undefined;

  /// No description provided for @owner_location_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search for location (e.g. Riyadh, Saudi Arabia)'**
  String get owner_location_search_hint;

  /// No description provided for @owner_confirm_location.
  ///
  /// In en, this message translates to:
  /// **'Confirm Location'**
  String get owner_confirm_location;

  /// No description provided for @owner_getting_address.
  ///
  /// In en, this message translates to:
  /// **'Getting address from map...'**
  String get owner_getting_address;

  /// No description provided for @admin_payments.
  ///
  /// In en, this message translates to:
  /// **'Payment Management'**
  String get admin_payments;

  /// No description provided for @admin_payments_review.
  ///
  /// In en, this message translates to:
  /// **'Review and approve payment requests'**
  String get admin_payments_review;

  /// No description provided for @admin_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get admin_all;

  /// No description provided for @admin_pending_review.
  ///
  /// In en, this message translates to:
  /// **'Pending Review'**
  String get admin_pending_review;

  /// No description provided for @admin_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get admin_close;

  /// No description provided for @admin_payment_review.
  ///
  /// In en, this message translates to:
  /// **'Payment Review'**
  String get admin_payment_review;

  /// No description provided for @admin_approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get admin_approve;

  /// No description provided for @admin_reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get admin_reject;

  /// No description provided for @admin_cancellations.
  ///
  /// In en, this message translates to:
  /// **'Booking Cancellations'**
  String get admin_cancellations;

  /// No description provided for @admin_client.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get admin_client;

  /// No description provided for @admin_owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get admin_owner;

  /// No description provided for @admin_search_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Search users, chalets, phone...'**
  String get admin_search_placeholder;

  /// No description provided for @admin_statistics.
  ///
  /// In en, this message translates to:
  /// **'App Performance Overview'**
  String get admin_statistics;

  /// No description provided for @admin_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get admin_refresh;

  /// No description provided for @admin_users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get admin_users;

  /// No description provided for @admin_chalets.
  ///
  /// In en, this message translates to:
  /// **'Chalets'**
  String get admin_chalets;

  /// No description provided for @admin_view_conversation.
  ///
  /// In en, this message translates to:
  /// **'View Conversation'**
  String get admin_view_conversation;

  /// No description provided for @admin_complete_booking.
  ///
  /// In en, this message translates to:
  /// **'Complete Booking'**
  String get admin_complete_booking;

  /// No description provided for @profile_settings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get profile_settings;

  /// No description provided for @profile_personal_info.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get profile_personal_info;

  /// No description provided for @profile_switch_to_owner.
  ///
  /// In en, this message translates to:
  /// **'Switch to Owner Mode'**
  String get profile_switch_to_owner;

  /// No description provided for @profile_switch_to_user.
  ///
  /// In en, this message translates to:
  /// **'Switch to User Mode'**
  String get profile_switch_to_user;

  /// No description provided for @profile_switch_user_subtitle.
  ///
  /// In en, this message translates to:
  /// **'View app as regular user'**
  String get profile_switch_user_subtitle;

  /// No description provided for @profile_please_login.
  ///
  /// In en, this message translates to:
  /// **'Please login'**
  String get profile_please_login;

  /// No description provided for @profile_about.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get profile_about;

  /// No description provided for @profile_contact.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get profile_contact;

  /// No description provided for @profile_privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get profile_privacy;

  /// No description provided for @profile_refund.
  ///
  /// In en, this message translates to:
  /// **'Refund Policy'**
  String get profile_refund;

  /// No description provided for @profile_delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery Policy'**
  String get profile_delivery;

  /// No description provided for @profile_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profile_language;

  /// No description provided for @profile_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get profile_phone;

  /// No description provided for @profile_email.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get profile_email;

  /// No description provided for @profile_contact_person.
  ///
  /// In en, this message translates to:
  /// **'Contact Person'**
  String get profile_contact_person;

  /// No description provided for @profile_theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get profile_theme;

  /// No description provided for @profile_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profile_logout;

  /// No description provided for @profile_invoices.
  ///
  /// In en, this message translates to:
  /// **'Booking Invoices'**
  String get profile_invoices;

  /// No description provided for @profile_please_login_first.
  ///
  /// In en, this message translates to:
  /// **'Please login first'**
  String get profile_please_login_first;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get common_confirm;

  /// No description provided for @common_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// No description provided for @common_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retry;

  /// No description provided for @common_copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get common_copy;

  /// No description provided for @common_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get common_phone;

  /// No description provided for @common_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get common_email;

  /// No description provided for @common_contact_person.
  ///
  /// In en, this message translates to:
  /// **'Contact Person'**
  String get common_contact_person;

  /// No description provided for @common_open_settings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get common_open_settings;

  /// No description provided for @payment_complete.
  ///
  /// In en, this message translates to:
  /// **'Complete Payment'**
  String get payment_complete;

  /// No description provided for @payment_ewallets.
  ///
  /// In en, this message translates to:
  /// **'E-Wallets / Instapay'**
  String get payment_ewallets;

  /// No description provided for @payment_contact_owner_receipt.
  ///
  /// In en, this message translates to:
  /// **'Contact owner to send receipt'**
  String get payment_contact_owner_receipt;

  /// No description provided for @payment_final_step.
  ///
  /// In en, this message translates to:
  /// **'Final Payment Step'**
  String get payment_final_step;

  /// No description provided for @payment_open_whatsapp.
  ///
  /// In en, this message translates to:
  /// **'Open WhatsApp and send receipt'**
  String get payment_open_whatsapp;

  /// No description provided for @onboarding_luxury.
  ///
  /// In en, this message translates to:
  /// **'Luxury Stays Await'**
  String get onboarding_luxury;

  /// No description provided for @onboarding_confidence.
  ///
  /// In en, this message translates to:
  /// **'Book with Confidence'**
  String get onboarding_confidence;

  /// No description provided for @onboarding_experiences.
  ///
  /// In en, this message translates to:
  /// **'Unforgettable Experiences'**
  String get onboarding_experiences;

  /// No description provided for @onboarding_terms_agree.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to the Terms & Conditions'**
  String get onboarding_terms_agree;

  /// No description provided for @onboarding_accept.
  ///
  /// In en, this message translates to:
  /// **'Accept & Continue'**
  String get onboarding_accept;

  /// No description provided for @onboarding_scroll_top.
  ///
  /// In en, this message translates to:
  /// **'Scroll to Top'**
  String get onboarding_scroll_top;

  /// No description provided for @map_select_location.
  ///
  /// In en, this message translates to:
  /// **'Select Location'**
  String get map_select_location;

  /// No description provided for @map_my_location.
  ///
  /// In en, this message translates to:
  /// **'My Location'**
  String get map_my_location;

  /// No description provided for @map_search_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Search for location...'**
  String get map_search_placeholder;

  /// No description provided for @map_confirm_location.
  ///
  /// In en, this message translates to:
  /// **'Confirm Location'**
  String get map_confirm_location;

  /// No description provided for @map_select_now.
  ///
  /// In en, this message translates to:
  /// **'Select My Location Now'**
  String get map_select_now;

  /// No description provided for @notifications_title.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications_title;

  /// No description provided for @notifications_delete_all.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get notifications_delete_all;

  /// No description provided for @notifications_start_date.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get notifications_start_date;

  /// No description provided for @notifications_end_date.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get notifications_end_date;

  /// No description provided for @notifications_duration.
  ///
  /// In en, this message translates to:
  /// **'Stay Duration'**
  String get notifications_duration;

  /// No description provided for @cancellation_7_days.
  ///
  /// In en, this message translates to:
  /// **'Cancellation before 7 days'**
  String get cancellation_7_days;

  /// No description provided for @cancellation_3_7_days.
  ///
  /// In en, this message translates to:
  /// **'Cancellation 3-7 days before'**
  String get cancellation_3_7_days;

  /// No description provided for @cancellation_3_days.
  ///
  /// In en, this message translates to:
  /// **'Cancellation within 3 days'**
  String get cancellation_3_days;

  /// No description provided for @basic_info.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basic_info;

  /// No description provided for @pricing_details.
  ///
  /// In en, this message translates to:
  /// **'Pricing & Details'**
  String get pricing_details;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @profile_view_profile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get profile_view_profile;

  /// No description provided for @profile_account_settings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get profile_account_settings;

  /// No description provided for @profile_switch_owner_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Return to dashboard or browse'**
  String get profile_switch_owner_subtitle;

  /// No description provided for @profile_invoices_payments.
  ///
  /// In en, this message translates to:
  /// **'Invoices & Payments'**
  String get profile_invoices_payments;

  /// No description provided for @profile_invoices_subtitle.
  ///
  /// In en, this message translates to:
  /// **'View your payment details'**
  String get profile_invoices_subtitle;

  /// No description provided for @profile_support.
  ///
  /// In en, this message translates to:
  /// **'Support & Help'**
  String get profile_support;

  /// No description provided for @profile_contact_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Support team is available to help'**
  String get profile_contact_subtitle;

  /// No description provided for @profile_about_app.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get profile_about_app;

  /// No description provided for @profile_legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get profile_legal;

  /// No description provided for @profile_terms.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get profile_terms;

  /// No description provided for @profile_refund_policy.
  ///
  /// In en, this message translates to:
  /// **'Refund Policy'**
  String get profile_refund_policy;

  /// No description provided for @owner_is_from_popular_destination.
  ///
  /// In en, this message translates to:
  /// **'Is this chalet from a popular destination?'**
  String get owner_is_from_popular_destination;

  /// No description provided for @profile_app_preferences.
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get profile_app_preferences;

  /// No description provided for @profile_dark_mode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get profile_dark_mode;

  /// No description provided for @profile_language_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get profile_language_subtitle;

  /// No description provided for @profile_version.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get profile_version;

  /// No description provided for @auth_login_title.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get auth_login_title;

  /// No description provided for @auth_login_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back you\'ve been missed'**
  String get auth_login_subtitle;

  /// No description provided for @auth_agree_terms.
  ///
  /// In en, this message translates to:
  /// **'I agree to '**
  String get auth_agree_terms;

  /// No description provided for @auth_and_privacy.
  ///
  /// In en, this message translates to:
  /// **' and Privacy Policy'**
  String get auth_and_privacy;

  /// No description provided for @auth_must_agree.
  ///
  /// In en, this message translates to:
  /// **'You must agree to the Terms & Conditions to continue'**
  String get auth_must_agree;

  /// No description provided for @auth_no_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get auth_no_account;

  /// No description provided for @auth_create_account.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get auth_create_account;

  /// No description provided for @home_view_all.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get home_view_all;

  /// No description provided for @home_try_other_search.
  ///
  /// In en, this message translates to:
  /// **'Try searching for something else'**
  String get home_try_other_search;

  /// No description provided for @booking_current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get booking_current;

  /// No description provided for @booking_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get booking_pending;

  /// No description provided for @booking_previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get booking_previous;

  /// No description provided for @booking_data_updated.
  ///
  /// In en, this message translates to:
  /// **'Data updated successfully'**
  String get booking_data_updated;

  /// No description provided for @common_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get common_yes;

  /// No description provided for @common_no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get common_no;

  /// No description provided for @common_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get common_name;

  /// No description provided for @common_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get common_unavailable;

  /// No description provided for @common_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get common_unknown;

  /// No description provided for @common_now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get common_now;

  /// No description provided for @common_chalet.
  ///
  /// In en, this message translates to:
  /// **'Chalet'**
  String get common_chalet;

  /// No description provided for @common_loading.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get common_loading;

  /// No description provided for @admin_search_payment.
  ///
  /// In en, this message translates to:
  /// **'Search by order ID or username...'**
  String get admin_search_payment;

  /// No description provided for @admin_no_payment_requests.
  ///
  /// In en, this message translates to:
  /// **'No payment requests'**
  String get admin_no_payment_requests;

  /// No description provided for @admin_no_results.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get admin_no_results;

  /// No description provided for @admin_duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get admin_duration;

  /// No description provided for @admin_total_amount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get admin_total_amount;

  /// No description provided for @admin_guest_info.
  ///
  /// In en, this message translates to:
  /// **'Guest Information'**
  String get admin_guest_info;

  /// No description provided for @admin_owner_info.
  ///
  /// In en, this message translates to:
  /// **'Owner Information'**
  String get admin_owner_info;

  /// No description provided for @admin_view_receipt.
  ///
  /// In en, this message translates to:
  /// **'View Receipt'**
  String get admin_view_receipt;

  /// No description provided for @admin_please_select_action.
  ///
  /// In en, this message translates to:
  /// **'Please select the appropriate action for this payment request:'**
  String get admin_please_select_action;

  /// No description provided for @admin_payment_confirmed.
  ///
  /// In en, this message translates to:
  /// **'Payment confirmed successfully!'**
  String get admin_payment_confirmed;

  /// No description provided for @admin_approved_notification.
  ///
  /// In en, this message translates to:
  /// **'Approved successfully and notification sent to user'**
  String get admin_approved_notification;

  /// No description provided for @admin_payment_rejected_msg.
  ///
  /// In en, this message translates to:
  /// **'Payment proof rejected'**
  String get admin_payment_rejected_msg;

  /// No description provided for @admin_rejected_notification.
  ///
  /// In en, this message translates to:
  /// **'Rejected and notification sent to user'**
  String get admin_rejected_notification;

  /// No description provided for @admin_request_date.
  ///
  /// In en, this message translates to:
  /// **'Request Date'**
  String get admin_request_date;

  /// No description provided for @admin_approval_date.
  ///
  /// In en, this message translates to:
  /// **'Approval Date'**
  String get admin_approval_date;

  /// No description provided for @admin_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get admin_edit;

  /// No description provided for @admin_show_chalet_success.
  ///
  /// In en, this message translates to:
  /// **'Chalet shown successfully'**
  String get admin_show_chalet_success;

  /// No description provided for @admin_hide_chalet_success.
  ///
  /// In en, this message translates to:
  /// **'Chalet hidden successfully'**
  String get admin_hide_chalet_success;

  /// No description provided for @admin_revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get admin_revenue;

  /// No description provided for @admin_unified_growth.
  ///
  /// In en, this message translates to:
  /// **'Unified Growth Path'**
  String get admin_unified_growth;

  /// No description provided for @admin_growth_comparison.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive comparison of all performance indicators'**
  String get admin_growth_comparison;

  /// No description provided for @admin_chalet_status.
  ///
  /// In en, this message translates to:
  /// **'Chalet Status'**
  String get admin_chalet_status;

  /// No description provided for @admin_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get admin_completed;

  /// No description provided for @invoice_title.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get invoice_title;

  /// No description provided for @invoice_no_invoices.
  ///
  /// In en, this message translates to:
  /// **'No invoices yet'**
  String get invoice_no_invoices;

  /// No description provided for @invoice_no_invoices_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Your booking invoices will appear here'**
  String get invoice_no_invoices_subtitle;

  /// No description provided for @invoice_id.
  ///
  /// In en, this message translates to:
  /// **'Invoice ID: {invoiceId}'**
  String invoice_id(Object invoiceId);

  /// No description provided for @invoice_date.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String invoice_date(Object date);

  /// No description provided for @invoice_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get invoice_status;

  /// No description provided for @invoice_total.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get invoice_total;

  /// No description provided for @invoice_view_details.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get invoice_view_details;

  /// No description provided for @invoice_print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get invoice_print;

  /// No description provided for @invoice_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get invoice_save;

  /// No description provided for @invoice_status_confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get invoice_status_confirmed;

  /// No description provided for @invoice_status_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get invoice_status_completed;

  /// No description provided for @invoice_status_under_review.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get invoice_status_under_review;

  /// No description provided for @invoice_status_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get invoice_status_pending;

  /// No description provided for @invoice_status_awaiting_payment.
  ///
  /// In en, this message translates to:
  /// **'Awaiting Payment'**
  String get invoice_status_awaiting_payment;

  /// No description provided for @invoice_status_rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get invoice_status_rejected;

  /// No description provided for @invoice_status_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get invoice_status_cancelled;

  /// No description provided for @profile_support_contact_hint.
  ///
  /// In en, this message translates to:
  /// **'Contact our support team for any inquiries:'**
  String profile_support_contact_hint(Object email, Object phone);

  /// No description provided for @profile_support_email.
  ///
  /// In en, this message translates to:
  /// **'Email: support@rebtal.com'**
  String get profile_support_email;

  /// No description provided for @profile_support_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone: +20 123 456 789'**
  String get profile_support_phone;

  /// No description provided for @common_egp_plain.
  ///
  /// In en, this message translates to:
  /// **'EGP'**
  String get common_egp_plain;

  /// No description provided for @admin_suspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get admin_suspended;

  /// No description provided for @admin_booking_distribution.
  ///
  /// In en, this message translates to:
  /// **'Booking Distribution'**
  String get admin_booking_distribution;

  /// No description provided for @admin_none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get admin_none;

  /// No description provided for @admin_beds.
  ///
  /// In en, this message translates to:
  /// **'Beds'**
  String get admin_beds;

  /// No description provided for @admin_baths.
  ///
  /// In en, this message translates to:
  /// **'Baths'**
  String get admin_baths;

  /// No description provided for @admin_child.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get admin_child;

  /// No description provided for @admin_m2.
  ///
  /// In en, this message translates to:
  /// **'m²'**
  String get admin_m2;

  /// No description provided for @auth_please_enter_name.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get auth_please_enter_name;

  /// No description provided for @auth_please_enter_email.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get auth_please_enter_email;

  /// No description provided for @auth_please_enter_password.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get auth_please_enter_password;

  /// No description provided for @booking_select_start_first.
  ///
  /// In en, this message translates to:
  /// **'Please select start date first'**
  String get booking_select_start_first;

  /// No description provided for @booking_select_period_first.
  ///
  /// In en, this message translates to:
  /// **'Please select booking period first'**
  String get booking_select_period_first;

  /// No description provided for @booking_phone_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Phone number unavailable'**
  String get booking_phone_unavailable;

  /// No description provided for @booking_approve_booking.
  ///
  /// In en, this message translates to:
  /// **'Approve Booking'**
  String get booking_approve_booking;

  /// No description provided for @booking_request_rejected.
  ///
  /// In en, this message translates to:
  /// **'Request rejected'**
  String get booking_request_rejected;

  /// No description provided for @booking_reject_booking.
  ///
  /// In en, this message translates to:
  /// **'Reject Booking'**
  String get booking_reject_booking;

  /// No description provided for @booking_select_date.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get booking_select_date;

  /// No description provided for @booking_agree_policies.
  ///
  /// In en, this message translates to:
  /// **'I agree to booking and cancellation policies'**
  String get booking_agree_policies;

  /// No description provided for @booking_hide_details.
  ///
  /// In en, this message translates to:
  /// **'Hide details'**
  String get booking_hide_details;

  /// No description provided for @booking_view_full_policy.
  ///
  /// In en, this message translates to:
  /// **'View full policy'**
  String get booking_view_full_policy;

  /// No description provided for @booking_new_request.
  ///
  /// In en, this message translates to:
  /// **'New booking request'**
  String get booking_new_request;

  /// No description provided for @booking_sent_to_owner.
  ///
  /// In en, this message translates to:
  /// **'Request sent to owner'**
  String get booking_sent_to_owner;

  /// No description provided for @booking_rate_experience.
  ///
  /// In en, this message translates to:
  /// **'Rate your experience'**
  String get booking_rate_experience;

  /// No description provided for @booking_rate_help.
  ///
  /// In en, this message translates to:
  /// **'Please rate the service to help us improve'**
  String get booking_rate_help;

  /// No description provided for @booking_write_comment.
  ///
  /// In en, this message translates to:
  /// **'Write your comment here (required)...'**
  String get booking_write_comment;

  /// No description provided for @booking_thanks_rating.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your rating'**
  String get booking_thanks_rating;

  /// No description provided for @booking_send_rating.
  ///
  /// In en, this message translates to:
  /// **'Send Rating'**
  String get booking_send_rating;

  /// No description provided for @booking_complete_data.
  ///
  /// In en, this message translates to:
  /// **'Complete data to send'**
  String get booking_complete_data;

  /// No description provided for @booking_weak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get booking_weak;

  /// No description provided for @booking_select_trip_date.
  ///
  /// In en, this message translates to:
  /// **'Select your trip date'**
  String get booking_select_trip_date;

  /// No description provided for @booking_arrival.
  ///
  /// In en, this message translates to:
  /// **'Arrival'**
  String get booking_arrival;

  /// No description provided for @booking_departure.
  ///
  /// In en, this message translates to:
  /// **'Departure'**
  String get booking_departure;

  /// No description provided for @booking_total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get booking_total;

  /// No description provided for @booking_agree_terms_cancel.
  ///
  /// In en, this message translates to:
  /// **'I agree to terms and cancellation policies'**
  String get booking_agree_terms_cancel;

  /// No description provided for @booking_children.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get booking_children;

  /// No description provided for @booking_add_children.
  ///
  /// In en, this message translates to:
  /// **'Add number of children'**
  String get booking_add_children;

  /// No description provided for @booking_confirm_continue.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Continue'**
  String get booking_confirm_continue;

  /// No description provided for @booking_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get booking_next;

  /// No description provided for @booking_how_was_experience.
  ///
  /// In en, this message translates to:
  /// **'How was your experience?'**
  String get booking_how_was_experience;

  /// No description provided for @booking_rating_helps.
  ///
  /// In en, this message translates to:
  /// **'Your rating helps us improve'**
  String get booking_rating_helps;

  /// No description provided for @booking_write_notes.
  ///
  /// In en, this message translates to:
  /// **'Write your notes here...'**
  String get booking_write_notes;

  /// No description provided for @booking_thanks_rating_star.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your rating!'**
  String get booking_thanks_rating_star;

  /// No description provided for @booking_rating_tenant.
  ///
  /// In en, this message translates to:
  /// **'Tenant Rating'**
  String get booking_rating_tenant;

  /// No description provided for @booking_rating_chalet.
  ///
  /// In en, this message translates to:
  /// **'Chalet Rating'**
  String get booking_rating_chalet;

  /// No description provided for @booking_total_rating.
  ///
  /// In en, this message translates to:
  /// **'Total Rating'**
  String get booking_total_rating;

  /// No description provided for @booking_rating_sent.
  ///
  /// In en, this message translates to:
  /// **'Your rating was sent successfully'**
  String get booking_rating_sent;

  /// No description provided for @booking_please_comment_rating.
  ///
  /// In en, this message translates to:
  /// **'Please write a comment and select rating'**
  String get booking_please_comment_rating;

  /// No description provided for @booking_schedule_rating.
  ///
  /// In en, this message translates to:
  /// **'Punctuality'**
  String get booking_schedule_rating;

  /// No description provided for @booking_cleanliness.
  ///
  /// In en, this message translates to:
  /// **'Cleanliness'**
  String get booking_cleanliness;

  /// No description provided for @booking_handling.
  ///
  /// In en, this message translates to:
  /// **'Handling'**
  String get booking_handling;

  /// No description provided for @booking_rules.
  ///
  /// In en, this message translates to:
  /// **'Rules adherence'**
  String get booking_rules;

  /// No description provided for @booking_location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get booking_location;

  /// No description provided for @booking_facilities.
  ///
  /// In en, this message translates to:
  /// **'Facilities'**
  String get booking_facilities;

  /// No description provided for @booking_value.
  ///
  /// In en, this message translates to:
  /// **'Value for money'**
  String get booking_value;

  /// No description provided for @booking_communication.
  ///
  /// In en, this message translates to:
  /// **'Communication'**
  String get booking_communication;

  /// No description provided for @booking_cancel_request.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get booking_cancel_request;

  /// No description provided for @booking_cancel_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel the booking request?'**
  String get booking_cancel_confirm;

  /// No description provided for @booking_from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get booking_from;

  /// No description provided for @booking_to.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get booking_to;

  /// No description provided for @booking_payment_rejected_msg.
  ///
  /// In en, this message translates to:
  /// **'Payment proof rejected'**
  String get booking_payment_rejected_msg;

  /// No description provided for @booking_cancel_booking.
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get booking_cancel_booking;

  /// No description provided for @booking_reoffer.
  ///
  /// In en, this message translates to:
  /// **'Re-offer'**
  String get booking_reoffer;

  /// No description provided for @booking_complete_payment.
  ///
  /// In en, this message translates to:
  /// **'Complete Payment'**
  String get booking_complete_payment;

  /// No description provided for @booking_rate_chalet.
  ///
  /// In en, this message translates to:
  /// **'Rate Chalet'**
  String get booking_rate_chalet;

  /// No description provided for @booking_cancelled_msg.
  ///
  /// In en, this message translates to:
  /// **'This request has been cancelled'**
  String get booking_cancelled_msg;

  /// No description provided for @booking_transfer_success.
  ///
  /// In en, this message translates to:
  /// **'Booking transferred successfully'**
  String get booking_transfer_success;

  /// No description provided for @booking_cancellation_policy.
  ///
  /// In en, this message translates to:
  /// **'Booking Cancellation Policy'**
  String get booking_cancellation_policy;

  /// No description provided for @booking_7_nights.
  ///
  /// In en, this message translates to:
  /// **'7 nights or more before arrival'**
  String get booking_7_nights;

  /// No description provided for @booking_3_6_nights.
  ///
  /// In en, this message translates to:
  /// **'3-6 nights before arrival'**
  String get booking_3_6_nights;

  /// No description provided for @booking_1_2_nights.
  ///
  /// In en, this message translates to:
  /// **'1-2 nights before arrival'**
  String get booking_1_2_nights;

  /// No description provided for @booking_same_day.
  ///
  /// In en, this message translates to:
  /// **'Same day'**
  String get booking_same_day;

  /// No description provided for @booking_arrival_passed.
  ///
  /// In en, this message translates to:
  /// **'Arrival date passed'**
  String get booking_arrival_passed;

  /// No description provided for @booking_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get booking_today;

  /// No description provided for @booking_reoffer_booking.
  ///
  /// In en, this message translates to:
  /// **'Re-offer Booking'**
  String get booking_reoffer_booking;

  /// No description provided for @booking_reoffer_success.
  ///
  /// In en, this message translates to:
  /// **'Booking re-offered for discussion successfully'**
  String get booking_reoffer_success;

  /// No description provided for @booking_confirm_reoffer.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Re-offer'**
  String get booking_confirm_reoffer;

  /// No description provided for @booking_final_approval.
  ///
  /// In en, this message translates to:
  /// **'Complete Final Approval'**
  String get booking_final_approval;

  /// No description provided for @booking_submit_cancellation.
  ///
  /// In en, this message translates to:
  /// **'Submit Cancellation Request'**
  String get booking_submit_cancellation;

  /// No description provided for @booking_review_request.
  ///
  /// In en, this message translates to:
  /// **'Review Request'**
  String get booking_review_request;

  /// No description provided for @booking_calculate_refund.
  ///
  /// In en, this message translates to:
  /// **'Calculate Refund Amount'**
  String get booking_calculate_refund;

  /// No description provided for @booking_refund_amount.
  ///
  /// In en, this message translates to:
  /// **'Refund amount'**
  String get booking_refund_amount;

  /// No description provided for @booking_less_3_days.
  ///
  /// In en, this message translates to:
  /// **'Cancellation less than 3 days before'**
  String get booking_less_3_days;

  /// No description provided for @chalet_booking_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Booking unavailable at the moment'**
  String get chalet_booking_unavailable;

  /// No description provided for @chalet_booking_closed.
  ///
  /// In en, this message translates to:
  /// **'Booking closed'**
  String get chalet_booking_closed;

  /// No description provided for @chalet_booking_now.
  ///
  /// In en, this message translates to:
  /// **'Booking Now'**
  String get chalet_booking_now;

  /// No description provided for @chalet_share_error.
  ///
  /// In en, this message translates to:
  /// **'Cannot share now. Make sure the app is installed.'**
  String get chalet_share_error;

  /// No description provided for @chalet_location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get chalet_location;

  /// No description provided for @chalet_view_route.
  ///
  /// In en, this message translates to:
  /// **'View Route'**
  String get chalet_view_route;

  /// No description provided for @chalet_tap_to_open.
  ///
  /// In en, this message translates to:
  /// **'Tap to open location on map'**
  String get chalet_tap_to_open;

  /// No description provided for @chalet_view_location_details.
  ///
  /// In en, this message translates to:
  /// **'View location details with high accuracy'**
  String get chalet_view_location_details;

  /// No description provided for @chalet_loading_error.
  ///
  /// In en, this message translates to:
  /// **'Chalet ID not found'**
  String get chalet_loading_error;

  /// No description provided for @chalet_added_to_favorites.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get chalet_added_to_favorites;

  /// No description provided for @home_rooms_facilities.
  ///
  /// In en, this message translates to:
  /// **'Rooms & Facilities'**
  String get home_rooms_facilities;

  /// No description provided for @home_bedrooms.
  ///
  /// In en, this message translates to:
  /// **'Bedrooms'**
  String get home_bedrooms;

  /// No description provided for @home_bathrooms.
  ///
  /// In en, this message translates to:
  /// **'Bathrooms'**
  String get home_bathrooms;

  /// No description provided for @home_features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get home_features;

  /// No description provided for @home_facilities_services.
  ///
  /// In en, this message translates to:
  /// **'Facilities & Services'**
  String get home_facilities_services;

  /// No description provided for @home_show_results.
  ///
  /// In en, this message translates to:
  /// **'Show Results'**
  String get home_show_results;

  /// No description provided for @home_load_error.
  ///
  /// In en, this message translates to:
  /// **'Error loading chalets'**
  String get home_load_error;

  /// No description provided for @home_no_chalets.
  ///
  /// In en, this message translates to:
  /// **'No chalets available'**
  String get home_no_chalets;

  /// No description provided for @map_location_error.
  ///
  /// In en, this message translates to:
  /// **'Could not get your location. Try again.'**
  String get map_location_error;

  /// No description provided for @map_location_permission.
  ///
  /// In en, this message translates to:
  /// **'Location access must be allowed'**
  String get map_location_permission;

  /// No description provided for @map_search_address.
  ///
  /// In en, this message translates to:
  /// **'Type address to search...'**
  String get map_search_address;

  /// No description provided for @notifications_mark_all_read.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notifications_mark_all_read;

  /// No description provided for @notifications_all_marked.
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read'**
  String get notifications_all_marked;

  /// No description provided for @notifications_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get notifications_all;

  /// No description provided for @notifications_unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get notifications_unread;

  /// No description provided for @notifications_deleted.
  ///
  /// In en, this message translates to:
  /// **'Notification deleted'**
  String get notifications_deleted;

  /// No description provided for @notifications_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get notifications_error;

  /// No description provided for @notifications_empty.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get notifications_empty;

  /// No description provided for @notifications_empty_unread.
  ///
  /// In en, this message translates to:
  /// **'No unread notifications'**
  String get notifications_empty_unread;

  /// No description provided for @notifications_empty_hint.
  ///
  /// In en, this message translates to:
  /// **'All your notifications will appear here'**
  String get notifications_empty_hint;

  /// No description provided for @notifications_clear_all_confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete all notifications'**
  String get notifications_clear_all_confirm;

  /// No description provided for @notifications_cleared.
  ///
  /// In en, this message translates to:
  /// **'All notifications deleted'**
  String get notifications_cleared;

  /// No description provided for @owner_start_add_first.
  ///
  /// In en, this message translates to:
  /// **'Start by adding your first chalet'**
  String get owner_start_add_first;

  /// No description provided for @owner_chalet_added.
  ///
  /// In en, this message translates to:
  /// **'Chalet added successfully!'**
  String get owner_chalet_added;

  /// No description provided for @owner_fill_data.
  ///
  /// In en, this message translates to:
  /// **'Fill in the data below'**
  String get owner_fill_data;

  /// No description provided for @owner_create_listing.
  ///
  /// In en, this message translates to:
  /// **'Create your listing'**
  String get owner_create_listing;

  /// No description provided for @owner_add_photos_details.
  ///
  /// In en, this message translates to:
  /// **'Add photos, details and amenities'**
  String get owner_add_photos_details;

  /// No description provided for @owner_submit_chalet.
  ///
  /// In en, this message translates to:
  /// **'Submit Chalet'**
  String get owner_submit_chalet;

  /// No description provided for @owner_chalet_details.
  ///
  /// In en, this message translates to:
  /// **'Chalet Details'**
  String get owner_chalet_details;

  /// No description provided for @owner_enter_chalet_name.
  ///
  /// In en, this message translates to:
  /// **'Enter chalet name'**
  String get owner_enter_chalet_name;

  /// No description provided for @owner_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get owner_description;

  /// No description provided for @owner_select_on_map.
  ///
  /// In en, this message translates to:
  /// **'Select location on map'**
  String get owner_select_on_map;

  /// No description provided for @owner_selected_address.
  ///
  /// In en, this message translates to:
  /// **'Selected Address'**
  String get owner_selected_address;

  /// No description provided for @owner_property_details.
  ///
  /// In en, this message translates to:
  /// **'Property Details'**
  String get owner_property_details;

  /// No description provided for @owner_price_per_night.
  ///
  /// In en, this message translates to:
  /// **'Price per night (EGP)'**
  String get owner_price_per_night;

  /// No description provided for @owner_area_m2.
  ///
  /// In en, this message translates to:
  /// **'Area (m²)'**
  String get owner_area_m2;

  /// No description provided for @owner_availability_period.
  ///
  /// In en, this message translates to:
  /// **'Availability Period'**
  String get owner_availability_period;

  /// No description provided for @owner_extra_features.
  ///
  /// In en, this message translates to:
  /// **'Extra Features'**
  String get owner_extra_features;

  /// No description provided for @owner_discounts_offers.
  ///
  /// In en, this message translates to:
  /// **'Discounts & Offers'**
  String get owner_discounts_offers;

  /// No description provided for @owner_enable_discount.
  ///
  /// In en, this message translates to:
  /// **'Enable Discount'**
  String get owner_enable_discount;

  /// No description provided for @owner_discount_hint.
  ///
  /// In en, this message translates to:
  /// **'Enable this option to add a price discount'**
  String get owner_discount_hint;

  /// No description provided for @owner_discount_type.
  ///
  /// In en, this message translates to:
  /// **'Discount Type'**
  String get owner_discount_type;

  /// No description provided for @owner_day_use_feature.
  ///
  /// In en, this message translates to:
  /// **'Day Use Booking'**
  String get owner_day_use_feature;

  /// No description provided for @owner_enable_day_use.
  ///
  /// In en, this message translates to:
  /// **'Enable Day Use'**
  String get owner_enable_day_use;

  /// No description provided for @owner_day_use_hint.
  ///
  /// In en, this message translates to:
  /// **'Allow users to book chalet for day only without overnight stay'**
  String get owner_day_use_hint;

  /// No description provided for @owner_select_date.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get owner_select_date;

  /// No description provided for @owner_booking_number.
  ///
  /// In en, this message translates to:
  /// **'Booking Number'**
  String get owner_booking_number;

  /// No description provided for @owner_booking_copied.
  ///
  /// In en, this message translates to:
  /// **'Booking number copied'**
  String get owner_booking_copied;

  /// No description provided for @owner_accept_booking.
  ///
  /// In en, this message translates to:
  /// **'Accept Booking'**
  String get owner_accept_booking;

  /// No description provided for @owner_reject_booking.
  ///
  /// In en, this message translates to:
  /// **'Reject Booking'**
  String get owner_reject_booking;

  /// No description provided for @owner_accept_success.
  ///
  /// In en, this message translates to:
  /// **'Booking accepted successfully'**
  String get owner_accept_success;

  /// No description provided for @owner_cancelled_by_client.
  ///
  /// In en, this message translates to:
  /// **'Booking cancelled by client'**
  String get owner_cancelled_by_client;

  /// No description provided for @owner_cancellation_datetime.
  ///
  /// In en, this message translates to:
  /// **'Cancellation date and time'**
  String get owner_cancellation_datetime;

  /// No description provided for @owner_reject_success.
  ///
  /// In en, this message translates to:
  /// **'Booking rejected'**
  String get owner_reject_success;

  /// No description provided for @owner_cancellation_summary.
  ///
  /// In en, this message translates to:
  /// **'Cancellation Policy Summary'**
  String get owner_cancellation_summary;

  /// No description provided for @owner_arrival_day.
  ///
  /// In en, this message translates to:
  /// **'Arrival day'**
  String get owner_arrival_day;

  /// No description provided for @owner_chalet_name_colon.
  ///
  /// In en, this message translates to:
  /// **'Chalet name:'**
  String get owner_chalet_name_colon;

  /// No description provided for @owner_stay_dates.
  ///
  /// In en, this message translates to:
  /// **'Stay dates:'**
  String get owner_stay_dates;

  /// No description provided for @owner_booking_value.
  ///
  /// In en, this message translates to:
  /// **'Booking value:'**
  String get owner_booking_value;

  /// No description provided for @owner_booking_expired.
  ///
  /// In en, this message translates to:
  /// **'Booking period ended'**
  String get owner_booking_expired;

  /// No description provided for @payment_copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get payment_copied;

  /// No description provided for @payment_whatsapp_error.
  ///
  /// In en, this message translates to:
  /// **'Could not open WhatsApp'**
  String get payment_whatsapp_error;

  /// No description provided for @profile_updated_success.
  ///
  /// In en, this message translates to:
  /// **'Data updated successfully'**
  String get profile_updated_success;

  /// No description provided for @profile_password_changed.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get profile_password_changed;

  /// No description provided for @profile_our_mission.
  ///
  /// In en, this message translates to:
  /// **'Our Mission'**
  String get profile_our_mission;

  /// No description provided for @profile_what_we_offer.
  ///
  /// In en, this message translates to:
  /// **'What We Offer'**
  String get profile_what_we_offer;

  /// No description provided for @profile_easy_search.
  ///
  /// In en, this message translates to:
  /// **'Easy Search'**
  String get profile_easy_search;

  /// No description provided for @profile_best_prices.
  ///
  /// In en, this message translates to:
  /// **'Best Prices'**
  String get profile_best_prices;

  /// No description provided for @profile_secure_booking.
  ///
  /// In en, this message translates to:
  /// **'Secure Booking'**
  String get profile_secure_booking;

  /// No description provided for @profile_support_24.
  ///
  /// In en, this message translates to:
  /// **'24/7 Support'**
  String get profile_support_24;

  /// No description provided for @profile_why_choose.
  ///
  /// In en, this message translates to:
  /// **'Why Choose Us'**
  String get profile_why_choose;

  /// No description provided for @profile_support_hours.
  ///
  /// In en, this message translates to:
  /// **'Support Hours'**
  String get profile_support_hours;

  /// No description provided for @profile_available_24_7.
  ///
  /// In en, this message translates to:
  /// **'We\'re available to assist you 24/7'**
  String get profile_available_24_7;

  /// No description provided for @profile_label_copied.
  ///
  /// In en, this message translates to:
  /// **'copied to clipboard'**
  String get profile_label_copied;

  /// No description provided for @welcome_curated.
  ///
  /// In en, this message translates to:
  /// **'Curated stays'**
  String get welcome_curated;

  /// No description provided for @welcome_curated_desc.
  ///
  /// In en, this message translates to:
  /// **'Discover modern chalets and villas selected by experts.'**
  String get welcome_curated_desc;

  /// No description provided for @welcome_plan.
  ///
  /// In en, this message translates to:
  /// **'Plan with ease'**
  String get welcome_plan;

  /// No description provided for @welcome_plan_desc.
  ///
  /// In en, this message translates to:
  /// **'Manage bookings, payments, and support in one place.'**
  String get welcome_plan_desc;

  /// No description provided for @welcome_inspired.
  ///
  /// In en, this message translates to:
  /// **'Stay inspired'**
  String get welcome_inspired;

  /// No description provided for @welcome_inspired_desc.
  ///
  /// In en, this message translates to:
  /// **'Save favorites and receive tailored recommendations.'**
  String get welcome_inspired_desc;

  /// No description provided for @welcome_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Rebtal'**
  String get welcome_title;

  /// No description provided for @welcome_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Rent and showcase beautiful chalets with a couple of taps.'**
  String get welcome_subtitle;

  /// No description provided for @welcome_get_started.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get welcome_get_started;

  /// No description provided for @welcome_create_account.
  ///
  /// In en, this message translates to:
  /// **'Create a new account'**
  String get welcome_create_account;

  /// No description provided for @onboarding_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboarding_skip;

  /// No description provided for @onboarding_get_started.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboarding_get_started;

  /// No description provided for @onboarding_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboarding_next;

  /// No description provided for @onboarding_luxury_redefined.
  ///
  /// In en, this message translates to:
  /// **'Luxury Redefined'**
  String get onboarding_luxury_redefined;

  /// No description provided for @onboarding_nature_desc.
  ///
  /// In en, this message translates to:
  /// **'Wake up to the sound of waves...'**
  String get onboarding_nature_desc;

  /// No description provided for @onboarding_effortless.
  ///
  /// In en, this message translates to:
  /// **'Effortless Journeys'**
  String get onboarding_effortless;

  /// No description provided for @onboarding_instant_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Instant Confirmation'**
  String get onboarding_instant_confirmation;

  /// No description provided for @onboarding_secure_payment.
  ///
  /// In en, this message translates to:
  /// **'Secure Payment'**
  String get onboarding_secure_payment;

  /// No description provided for @onboarding_concierge.
  ///
  /// In en, this message translates to:
  /// **'24/7 Concierge'**
  String get onboarding_concierge;

  /// No description provided for @router_no_route.
  ///
  /// In en, this message translates to:
  /// **'No route defined'**
  String get router_no_route;

  /// No description provided for @user_save_changes.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get user_save_changes;

  /// No description provided for @user_please_enter_name.
  ///
  /// In en, this message translates to:
  /// **'Please enter name'**
  String get user_please_enter_name;

  /// No description provided for @user_please_enter_email.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get user_please_enter_email;

  /// No description provided for @user_please_enter_password.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get user_please_enter_password;

  /// No description provided for @user_updated_success.
  ///
  /// In en, this message translates to:
  /// **'User data updated successfully'**
  String get user_updated_success;

  /// No description provided for @invoice_preparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing print...'**
  String get invoice_preparing;

  /// No description provided for @request_details.
  ///
  /// In en, this message translates to:
  /// **'Request Details'**
  String get request_details;

  /// No description provided for @request_id.
  ///
  /// In en, this message translates to:
  /// **'Request ID: '**
  String get request_id;

  /// No description provided for @request_submitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted: '**
  String get request_submitted;

  /// No description provided for @request_updated.
  ///
  /// In en, this message translates to:
  /// **'Updated: '**
  String get request_updated;

  /// No description provided for @transfer_preliminary.
  ///
  /// In en, this message translates to:
  /// **'Preliminary approval for booking transfer'**
  String get transfer_preliminary;

  /// No description provided for @transfer_accepted.
  ///
  /// In en, this message translates to:
  /// **'Booking transfer request accepted'**
  String get transfer_accepted;

  /// No description provided for @booking_new_day_use.
  ///
  /// In en, this message translates to:
  /// **'New Day Use booking request!'**
  String get booking_new_day_use;

  /// No description provided for @chalet_new_review.
  ///
  /// In en, this message translates to:
  /// **'New chalet under review'**
  String get chalet_new_review;

  /// No description provided for @auth_please_login_first.
  ///
  /// In en, this message translates to:
  /// **'Please login first'**
  String get auth_please_login_first;

  /// No description provided for @cannot_open_map.
  ///
  /// In en, this message translates to:
  /// **'Cannot open map'**
  String get cannot_open_map;

  /// No description provided for @auth_create_account_title.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get auth_create_account_title;

  /// No description provided for @auth_create_account_desc.
  ///
  /// In en, this message translates to:
  /// **'Create an account so you can start your journey with us'**
  String get auth_create_account_desc;

  /// No description provided for @auth_i_am.
  ///
  /// In en, this message translates to:
  /// **'I am...'**
  String get auth_i_am;

  /// No description provided for @auth_forgot_password_title.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get auth_forgot_password_title;

  /// No description provided for @auth_forgot_password_desc.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a password reset link'**
  String get auth_forgot_password_desc;

  /// No description provided for @chalet_no_day_use.
  ///
  /// In en, this message translates to:
  /// **'No Day Use chalets available at the moment'**
  String get chalet_no_day_use;

  /// No description provided for @chalet_no_offers.
  ///
  /// In en, this message translates to:
  /// **'No offers available'**
  String get chalet_no_offers;

  /// No description provided for @owner_welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get owner_welcome;

  /// No description provided for @owner_default_name.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get owner_default_name;

  /// No description provided for @owner_no_chalets.
  ///
  /// In en, this message translates to:
  /// **'No chalets'**
  String get owner_no_chalets;

  /// No description provided for @owner_add_chalet.
  ///
  /// In en, this message translates to:
  /// **'Add Chalet'**
  String get owner_add_chalet;

  /// No description provided for @home_show_more.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get home_show_more;

  /// No description provided for @booking_invoice.
  ///
  /// In en, this message translates to:
  /// **'Booking Invoice'**
  String get booking_invoice;

  /// No description provided for @booking_chalet_details.
  ///
  /// In en, this message translates to:
  /// **'Chalet Details'**
  String get booking_chalet_details;

  /// No description provided for @booking_host_info.
  ///
  /// In en, this message translates to:
  /// **'Host (Owner) Information'**
  String get booking_host_info;

  /// No description provided for @booking_guest_info.
  ///
  /// In en, this message translates to:
  /// **'Guest (You) Information'**
  String get booking_guest_info;

  /// No description provided for @booking_booking_details.
  ///
  /// In en, this message translates to:
  /// **'Booking Details'**
  String get booking_booking_details;

  /// No description provided for @booking_name_label.
  ///
  /// In en, this message translates to:
  /// **'Name:'**
  String get booking_name_label;

  /// No description provided for @booking_location_label.
  ///
  /// In en, this message translates to:
  /// **'Location:'**
  String get booking_location_label;

  /// No description provided for @booking_phone_label.
  ///
  /// In en, this message translates to:
  /// **'Phone:'**
  String get booking_phone_label;

  /// No description provided for @booking_email_label.
  ///
  /// In en, this message translates to:
  /// **'Email:'**
  String get booking_email_label;

  /// No description provided for @booking_arrival_label.
  ///
  /// In en, this message translates to:
  /// **'Arrival:'**
  String get booking_arrival_label;

  /// No description provided for @booking_departure_label.
  ///
  /// In en, this message translates to:
  /// **'Departure:'**
  String get booking_departure_label;

  /// No description provided for @booking_days_count.
  ///
  /// In en, this message translates to:
  /// **'Days:'**
  String get booking_days_count;

  /// No description provided for @booking_nights_count.
  ///
  /// In en, this message translates to:
  /// **'Nights:'**
  String get booking_nights_count;

  /// No description provided for @booking_children_count.
  ///
  /// In en, this message translates to:
  /// **'Children:'**
  String get booking_children_count;

  /// No description provided for @booking_total_amount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount:'**
  String get booking_total_amount;

  /// No description provided for @booking_payment_status.
  ///
  /// In en, this message translates to:
  /// **'Payment Status:'**
  String get booking_payment_status;

  /// No description provided for @booking_paid_full.
  ///
  /// In en, this message translates to:
  /// **'Fully Paid'**
  String get booking_paid_full;

  /// No description provided for @booking_under_review.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get booking_under_review;

  /// No description provided for @booking_swipe_details.
  ///
  /// In en, this message translates to:
  /// **'Swipe for details'**
  String get booking_swipe_details;

  /// No description provided for @booking_egp.
  ///
  /// In en, this message translates to:
  /// **'EGP'**
  String get booking_egp;

  /// No description provided for @common_undetermined.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get common_undetermined;

  /// No description provided for @common_unavailable_short.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get common_unavailable_short;

  /// No description provided for @booking_status_payment_rejected.
  ///
  /// In en, this message translates to:
  /// **'Payment Rejected'**
  String get booking_status_payment_rejected;

  /// No description provided for @booking_status_confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get booking_status_confirmed;

  /// No description provided for @booking_status_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get booking_status_cancelled;

  /// No description provided for @booking_status_accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get booking_status_accepted;

  /// No description provided for @booking_status_rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get booking_status_rejected;

  /// No description provided for @booking_status_payment_review.
  ///
  /// In en, this message translates to:
  /// **'Payment Under Review'**
  String get booking_status_payment_review;

  /// No description provided for @booking_status_awaiting_payment.
  ///
  /// In en, this message translates to:
  /// **'Awaiting Payment'**
  String get booking_status_awaiting_payment;

  /// No description provided for @booking_status_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get booking_status_completed;

  /// No description provided for @booking_status_under_discussion.
  ///
  /// In en, this message translates to:
  /// **'Under Discussion'**
  String get booking_status_under_discussion;

  /// No description provided for @booking_status_awaiting_approval.
  ///
  /// In en, this message translates to:
  /// **'Awaiting Approval'**
  String get booking_status_awaiting_approval;

  /// No description provided for @booking_status_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get booking_status_pending;

  /// No description provided for @booking_host.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get booking_host;

  /// No description provided for @booking_nights.
  ///
  /// In en, this message translates to:
  /// **'nights'**
  String get booking_nights;

  /// No description provided for @booking_payment_rejected_msg_short.
  ///
  /// In en, this message translates to:
  /// **'Payment proof rejected'**
  String get booking_payment_rejected_msg_short;

  /// No description provided for @booking_whatsapp_contact.
  ///
  /// In en, this message translates to:
  /// **'Hi, payment proof was rejected for booking:'**
  String get booking_whatsapp_contact;

  /// No description provided for @booking_approve_booking_btn.
  ///
  /// In en, this message translates to:
  /// **'Approve Booking'**
  String get booking_approve_booking_btn;

  /// No description provided for @booking_reoffer_btn.
  ///
  /// In en, this message translates to:
  /// **'Re-offer'**
  String get booking_reoffer_btn;

  /// No description provided for @booking_reoffer_success_msg.
  ///
  /// In en, this message translates to:
  /// **'Booking re-offered successfully'**
  String get booking_reoffer_success_msg;

  /// No description provided for @booking_cancel_booking_btn.
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get booking_cancel_booking_btn;

  /// No description provided for @booking_complete_payment_btn.
  ///
  /// In en, this message translates to:
  /// **'Complete Payment'**
  String get booking_complete_payment_btn;

  /// No description provided for @booking_rate_chalet_btn.
  ///
  /// In en, this message translates to:
  /// **'Rate Chalet'**
  String get booking_rate_chalet_btn;

  /// No description provided for @booking_transfer_success_msg.
  ///
  /// In en, this message translates to:
  /// **'Booking transferred successfully ✅'**
  String get booking_transfer_success_msg;

  /// No description provided for @booking_final_approval_btn.
  ///
  /// In en, this message translates to:
  /// **'Complete Final Approval'**
  String get booking_final_approval_btn;

  /// No description provided for @booking_cancellation_policy_title.
  ///
  /// In en, this message translates to:
  /// **'Booking Cancellation Policy'**
  String get booking_cancellation_policy_title;

  /// No description provided for @booking_policy_7_nights.
  ///
  /// In en, this message translates to:
  /// **'7 nights or more before arrival'**
  String get booking_policy_7_nights;

  /// No description provided for @booking_policy_7_refund.
  ///
  /// In en, this message translates to:
  /// **'Full refund (100%)'**
  String get booking_policy_7_refund;

  /// No description provided for @booking_policy_3_6_nights.
  ///
  /// In en, this message translates to:
  /// **'3-6 nights before arrival'**
  String get booking_policy_3_6_nights;

  /// No description provided for @booking_policy_3_6_refund.
  ///
  /// In en, this message translates to:
  /// **'Up to 50% deduction'**
  String get booking_policy_3_6_refund;

  /// No description provided for @booking_policy_less_3.
  ///
  /// In en, this message translates to:
  /// **'Less than 3 nights before arrival'**
  String get booking_policy_less_3;

  /// No description provided for @booking_policy_less_3_refund.
  ///
  /// In en, this message translates to:
  /// **'50% deduction'**
  String get booking_policy_less_3_refund;

  /// No description provided for @booking_policy_same_day.
  ///
  /// In en, this message translates to:
  /// **'Day of arrival'**
  String get booking_policy_same_day;

  /// No description provided for @booking_policy_no_refund.
  ///
  /// In en, this message translates to:
  /// **'No refund (0%)'**
  String get booking_policy_no_refund;

  /// No description provided for @booking_details_dates.
  ///
  /// In en, this message translates to:
  /// **'Booking details and dates:'**
  String get booking_details_dates;

  /// No description provided for @booking_duration.
  ///
  /// In en, this message translates to:
  /// **'Booking duration:'**
  String get booking_duration;

  /// No description provided for @booking_days_nights.
  ///
  /// In en, this message translates to:
  /// **'days, nights'**
  String get booking_days_nights;

  /// No description provided for @booking_arrival_date.
  ///
  /// In en, this message translates to:
  /// **'Arrival date:'**
  String get booking_arrival_date;

  /// No description provided for @booking_remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining until arrival:'**
  String get booking_remaining;

  /// No description provided for @booking_arrival_passed_short.
  ///
  /// In en, this message translates to:
  /// **'Arrival date passed'**
  String get booking_arrival_passed_short;

  /// No description provided for @booking_amount_paid.
  ///
  /// In en, this message translates to:
  /// **'Amount paid:'**
  String get booking_amount_paid;

  /// No description provided for @booking_egp_currency.
  ///
  /// In en, this message translates to:
  /// **'EGP'**
  String get booking_egp_currency;

  /// No description provided for @booking_discount_value.
  ///
  /// In en, this message translates to:
  /// **'Discount value:'**
  String get booking_discount_value;

  /// No description provided for @booking_refund_amount_label.
  ///
  /// In en, this message translates to:
  /// **'Refund amount:'**
  String get booking_refund_amount_label;

  /// No description provided for @booking_revert_btn.
  ///
  /// In en, this message translates to:
  /// **'Revert'**
  String get booking_revert_btn;

  /// No description provided for @booking_confirm_cancel_btn.
  ///
  /// In en, this message translates to:
  /// **'Confirm Cancellation'**
  String get booking_confirm_cancel_btn;

  /// No description provided for @booking_reoffer_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Re-offer Booking'**
  String get booking_reoffer_dialog_title;

  /// No description provided for @booking_reoffer_dialog_content.
  ///
  /// In en, this message translates to:
  /// **'Do you want to re-offer this booking for discussion with other tenants? Other users will be able to see and request the transfer.'**
  String get booking_reoffer_dialog_content;

  /// No description provided for @booking_reoffer_success_snack.
  ///
  /// In en, this message translates to:
  /// **'Booking re-offered successfully'**
  String get booking_reoffer_success_snack;

  /// No description provided for @booking_confirm_reoffer_btn.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Re-offer'**
  String get booking_confirm_reoffer_btn;

  /// No description provided for @booking_awaiting_host.
  ///
  /// In en, this message translates to:
  /// **'Awaiting host approval'**
  String get booking_awaiting_host;

  /// No description provided for @booking_select_period_first_msg.
  ///
  /// In en, this message translates to:
  /// **'Please select booking period first'**
  String get booking_select_period_first_msg;

  /// No description provided for @booking_undef_period_msg.
  ///
  /// In en, this message translates to:
  /// **'Booking period undefined. You can select from today for up to 60 days.'**
  String get booking_undef_period_msg;

  /// No description provided for @booking_open_whatsapp.
  ///
  /// In en, this message translates to:
  /// **'Open WhatsApp'**
  String get booking_open_whatsapp;

  /// No description provided for @booking_whatsapp_message.
  ///
  /// In en, this message translates to:
  /// **'Hello, I would like to book the chalet from'**
  String get booking_whatsapp_message;

  /// No description provided for @booking_final_price.
  ///
  /// In en, this message translates to:
  /// **'Final price:'**
  String get booking_final_price;

  /// No description provided for @booking_from_to.
  ///
  /// In en, this message translates to:
  /// **'From to:'**
  String get booking_from_to;

  /// No description provided for @booking_children_count_label.
  ///
  /// In en, this message translates to:
  /// **'Children count:'**
  String get booking_children_count_label;

  /// No description provided for @booking_policy_summary.
  ///
  /// In en, this message translates to:
  /// **'Per night. Cancellation: full refund before 7+ days, partial before 3-6 days, 50% before less than 3 days, no refund on arrival day.'**
  String get booking_policy_summary;

  /// No description provided for @booking_policy_full.
  ///
  /// In en, this message translates to:
  /// **'Bookings are per night. Cancellation: full refund (100%) if 7+ nights before; up to 50% if 3-6 nights before; 50% deduction if less than 3 nights; no refund on arrival day.'**
  String get booking_policy_full;

  /// No description provided for @booking_confirm_booking_btn.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get booking_confirm_booking_btn;

  /// No description provided for @booking_new_request_notif.
  ///
  /// In en, this message translates to:
  /// **'New booking request'**
  String get booking_new_request_notif;

  /// No description provided for @booking_new_request_body.
  ///
  /// In en, this message translates to:
  /// **'You have a new booking request for'**
  String get booking_new_request_body;

  /// No description provided for @booking_review_approve.
  ///
  /// In en, this message translates to:
  /// **'Please review and approve.'**
  String get booking_review_approve;

  /// No description provided for @booking_error_msg.
  ///
  /// In en, this message translates to:
  /// **'An error occurred:'**
  String get booking_error_msg;

  /// No description provided for @booking_rating_excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent!'**
  String get booking_rating_excellent;

  /// No description provided for @booking_rating_great.
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get booking_rating_great;

  /// No description provided for @booking_rating_good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get booking_rating_good;

  /// No description provided for @booking_rating_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get booking_rating_ok;

  /// No description provided for @booking_rating_weak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get booking_rating_weak;

  /// No description provided for @booking_thanks_rating_short.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your rating'**
  String get booking_thanks_rating_short;

  /// No description provided for @booking_save_rating_error.
  ///
  /// In en, this message translates to:
  /// **'Could not save rating:'**
  String get booking_save_rating_error;

  /// No description provided for @booking_my_requests.
  ///
  /// In en, this message translates to:
  /// **'My Booking Requests'**
  String get booking_my_requests;

  /// No description provided for @booking_request_received.
  ///
  /// In en, this message translates to:
  /// **'Request received successfully'**
  String get booking_request_received;

  /// No description provided for @booking_admin_review.
  ///
  /// In en, this message translates to:
  /// **'Admin will review payment and confirm your booking soon.'**
  String get booking_admin_review;

  /// No description provided for @booking_back_home.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get booking_back_home;

  /// No description provided for @booking_no_requests.
  ///
  /// In en, this message translates to:
  /// **'No booking requests yet'**
  String get booking_no_requests;

  /// No description provided for @booking_no_requests_hint.
  ///
  /// In en, this message translates to:
  /// **'New requests will appear here. You can refresh or contact support.'**
  String get booking_no_requests_hint;

  /// No description provided for @booking_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get booking_refresh;

  /// No description provided for @booking_contact_support_btn.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get booking_contact_support_btn;

  /// No description provided for @booking_chalet_owner.
  ///
  /// In en, this message translates to:
  /// **'Chalet owner:'**
  String get booking_chalet_owner;

  /// No description provided for @booking_request_date.
  ///
  /// In en, this message translates to:
  /// **'Request date:'**
  String get booking_request_date;

  /// No description provided for @booking_last_update.
  ///
  /// In en, this message translates to:
  /// **'Last update:'**
  String get booking_last_update;

  /// No description provided for @booking_cancel_request_btn.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get booking_cancel_request_btn;

  /// No description provided for @booking_cancel_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get booking_cancel_dialog_title;

  /// No description provided for @booking_cancel_dialog_content.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel the booking request?'**
  String get booking_cancel_dialog_content;

  /// No description provided for @booking_day.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get booking_day;

  /// No description provided for @booking_hour.
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get booking_hour;

  /// No description provided for @booking_minute.
  ///
  /// In en, this message translates to:
  /// **'minute'**
  String get booking_minute;

  /// No description provided for @booking_request_rejected_short.
  ///
  /// In en, this message translates to:
  /// **'Request rejected'**
  String get booking_request_rejected_short;

  /// No description provided for @booking_reject_booking_btn.
  ///
  /// In en, this message translates to:
  /// **'Reject Booking'**
  String get booking_reject_booking_btn;

  /// No description provided for @booking_refund_request_title.
  ///
  /// In en, this message translates to:
  /// **'Refund Request'**
  String get booking_refund_request_title;

  /// No description provided for @booking_booking_info.
  ///
  /// In en, this message translates to:
  /// **'Booking Information'**
  String get booking_booking_info;

  /// No description provided for @booking_amount_paid_label.
  ///
  /// In en, this message translates to:
  /// **'Amount paid'**
  String get booking_amount_paid_label;

  /// No description provided for @booking_booking_date.
  ///
  /// In en, this message translates to:
  /// **'Booking date'**
  String get booking_booking_date;

  /// No description provided for @booking_refund_percentage.
  ///
  /// In en, this message translates to:
  /// **'Refund percentage'**
  String get booking_refund_percentage;

  /// No description provided for @booking_cancel_reason.
  ///
  /// In en, this message translates to:
  /// **'Cancellation reason'**
  String get booking_cancel_reason;

  /// No description provided for @booking_cancel_reason_hint.
  ///
  /// In en, this message translates to:
  /// **'Please explain the reason for cancelling...'**
  String get booking_cancel_reason_hint;

  /// No description provided for @booking_no_refund_policy.
  ///
  /// In en, this message translates to:
  /// **'No amount will be refunded per cancellation policy'**
  String get booking_no_refund_policy;

  /// No description provided for @booking_enter_cancel_reason.
  ///
  /// In en, this message translates to:
  /// **'Please enter cancellation reason'**
  String get booking_enter_cancel_reason;

  /// No description provided for @booking_refund_success.
  ///
  /// In en, this message translates to:
  /// **'Refund request submitted successfully'**
  String get booking_refund_success;

  /// No description provided for @booking_submit_refund.
  ///
  /// In en, this message translates to:
  /// **'Submit Refund Request'**
  String get booking_submit_refund;

  /// No description provided for @booking_view_cancel_policy.
  ///
  /// In en, this message translates to:
  /// **'View Cancellation Policy'**
  String get booking_view_cancel_policy;

  /// No description provided for @booking_refund_7_days.
  ///
  /// In en, this message translates to:
  /// **'Cancellation before 7 days - full refund'**
  String get booking_refund_7_days;

  /// No description provided for @booking_refund_3_7_days.
  ///
  /// In en, this message translates to:
  /// **'Cancellation 3-7 days - 50% refund'**
  String get booking_refund_3_7_days;

  /// No description provided for @booking_refund_less_3.
  ///
  /// In en, this message translates to:
  /// **'Cancellation less than 3 days - no refund'**
  String get booking_refund_less_3;

  /// No description provided for @booking_wizard_processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get booking_wizard_processing;

  /// No description provided for @booking_wizard_step_date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get booking_wizard_step_date;

  /// No description provided for @booking_wizard_step_review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get booking_wizard_step_review;

  /// No description provided for @booking_wizard_step_payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get booking_wizard_step_payment;

  /// No description provided for @booking_wizard_undef_period_30.
  ///
  /// In en, this message translates to:
  /// **'Booking period undefined. You can select from today for up to 30 days.'**
  String get booking_wizard_undef_period_30;

  /// No description provided for @booking_wizard_select_dates_desc.
  ///
  /// In en, this message translates to:
  /// **'Select suitable stay dates.'**
  String get booking_wizard_select_dates_desc;

  /// No description provided for @booking_wizard_agree_terms.
  ///
  /// In en, this message translates to:
  /// **'I agree to terms and cancellation policies'**
  String get booking_wizard_agree_terms;

  /// No description provided for @booking_wizard_nights.
  ///
  /// In en, this message translates to:
  /// **'nights'**
  String get booking_wizard_nights;

  /// No description provided for @booking_rating_how_experience.
  ///
  /// In en, this message translates to:
  /// **'How was your experience?'**
  String get booking_rating_how_experience;

  /// No description provided for @booking_rating_write_notes.
  ///
  /// In en, this message translates to:
  /// **'Write your notes here...'**
  String get booking_rating_write_notes;

  /// No description provided for @booking_rating_thanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your rating!'**
  String get booking_rating_thanks;

  /// No description provided for @common_unknown_status.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get common_unknown_status;

  /// No description provided for @booking_approve_booking_bridge.
  ///
  /// In en, this message translates to:
  /// **'Approve Booking'**
  String get booking_approve_booking_bridge;

  /// No description provided for @booking_reject_booking_bridge.
  ///
  /// In en, this message translates to:
  /// **'Reject Booking'**
  String get booking_reject_booking_bridge;

  /// No description provided for @booking_days_label.
  ///
  /// In en, this message translates to:
  /// **'Days:'**
  String get booking_days_label;

  /// No description provided for @booking_nights_label.
  ///
  /// In en, this message translates to:
  /// **'Nights:'**
  String get booking_nights_label;

  /// No description provided for @booking_price_per_night.
  ///
  /// In en, this message translates to:
  /// **'Price per night:'**
  String get booking_price_per_night;

  /// No description provided for @booking_total_label.
  ///
  /// In en, this message translates to:
  /// **'Total:'**
  String get booking_total_label;

  /// No description provided for @profile_update_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update data: '**
  String get profile_update_failed;

  /// No description provided for @profile_password_min_length.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get profile_password_min_length;

  /// No description provided for @profile_password_change_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to change password: '**
  String get profile_password_change_failed;

  /// No description provided for @profile_basic_info.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get profile_basic_info;

  /// No description provided for @profile_security_privacy.
  ///
  /// In en, this message translates to:
  /// **'Security & Privacy'**
  String get profile_security_privacy;

  /// No description provided for @profile_current_password.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get profile_current_password;

  /// No description provided for @profile_new_password.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get profile_new_password;

  /// No description provided for @profile_change_photo.
  ///
  /// In en, this message translates to:
  /// **'Change Profile Picture'**
  String get profile_change_photo;

  /// No description provided for @profile_photo_updated.
  ///
  /// In en, this message translates to:
  /// **'Profile picture updated successfully!'**
  String get profile_photo_updated;

  /// No description provided for @common_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get common_edit;

  /// No description provided for @common_update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get common_update;

  /// No description provided for @common_select_source.
  ///
  /// In en, this message translates to:
  /// **'Select image source'**
  String get common_select_source;

  /// No description provided for @common_select_source_single.
  ///
  /// In en, this message translates to:
  /// **'Select image source'**
  String get common_select_source_single;

  /// No description provided for @common_capture_photo.
  ///
  /// In en, this message translates to:
  /// **'Capture single photo'**
  String get common_capture_photo;

  /// No description provided for @common_capture_new_photo.
  ///
  /// In en, this message translates to:
  /// **'Capture new photo'**
  String get common_capture_new_photo;

  /// No description provided for @common_select_multiple.
  ///
  /// In en, this message translates to:
  /// **'Select multiple images'**
  String get common_select_multiple;

  /// No description provided for @common_select_one.
  ///
  /// In en, this message translates to:
  /// **'Select one image from gallery'**
  String get common_select_one;

  /// No description provided for @common_permission_denied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied. Please grant camera/gallery access in settings.'**
  String get common_permission_denied;

  /// No description provided for @common_upload_error.
  ///
  /// In en, this message translates to:
  /// **'Error uploading image: '**
  String get common_upload_error;

  /// No description provided for @common_pick_error.
  ///
  /// In en, this message translates to:
  /// **'Error picking image'**
  String get common_pick_error;

  /// No description provided for @common_permission_error.
  ///
  /// In en, this message translates to:
  /// **'Camera/Gallery access error. Please check permissions.'**
  String get common_permission_error;

  /// No description provided for @common_plugin_error.
  ///
  /// In en, this message translates to:
  /// **'Plugin connection error. Please restart the app.'**
  String get common_plugin_error;

  /// No description provided for @owner_add_chalet_images.
  ///
  /// In en, this message translates to:
  /// **'Add Chalet Images'**
  String get owner_add_chalet_images;

  /// No description provided for @owner_chalet_photos_added.
  ///
  /// In en, this message translates to:
  /// **'Chalet photos added successfully!'**
  String get owner_chalet_photos_added;

  /// No description provided for @owner_chalet_photo_added.
  ///
  /// In en, this message translates to:
  /// **'Chalet photo added successfully!'**
  String get owner_chalet_photo_added;

  /// No description provided for @owner_images_not_added.
  ///
  /// In en, this message translates to:
  /// **'Some images were not added:\n'**
  String get owner_images_not_added;

  /// No description provided for @owner_error_upload_images.
  ///
  /// In en, this message translates to:
  /// **'Upload chalet images'**
  String get owner_error_upload_images;

  /// No description provided for @owner_error_fill_fields.
  ///
  /// In en, this message translates to:
  /// **'Fill all fields'**
  String get owner_error_fill_fields;

  /// No description provided for @owner_chalet_submitted.
  ///
  /// In en, this message translates to:
  /// **'Chalet submitted successfully'**
  String get owner_chalet_submitted;

  /// No description provided for @owner_error_id_not_found.
  ///
  /// In en, this message translates to:
  /// **'Error: Owner ID not found'**
  String get owner_error_id_not_found;

  /// No description provided for @auth_create_account_btn.
  ///
  /// In en, this message translates to:
  /// **'Create My Account'**
  String get auth_create_account_btn;

  /// No description provided for @notif_new_chalet_review.
  ///
  /// In en, this message translates to:
  /// **'New Chalet under review 🏗️'**
  String get notif_new_chalet_review;

  /// No description provided for @notif_new_chalet_body.
  ///
  /// In en, this message translates to:
  /// **'{name} uploaded a new chalet ({chalet}) and it\'s waiting for your approval.'**
  String notif_new_chalet_body(Object chalet, Object name);

  /// No description provided for @booking_policy_timeline.
  ///
  /// In en, this message translates to:
  /// **'Cancellation Policy Followed'**
  String get booking_policy_timeline;

  /// No description provided for @booking_policy_7_nights_desc.
  ///
  /// In en, this message translates to:
  /// **'This period provides enough time to re-rent the unit without loss to the owner.'**
  String get booking_policy_7_nights_desc;

  /// No description provided for @booking_policy_3_6_nights_desc.
  ///
  /// In en, this message translates to:
  /// **'Due to the short remaining time, a percentage is deducted to compensate the owner.'**
  String get booking_policy_3_6_nights_desc;

  /// No description provided for @booking_policy_less_3_desc.
  ///
  /// In en, this message translates to:
  /// **'Very late cancellation makes it difficult to find a replacement tenant.'**
  String get booking_policy_less_3_desc;

  /// No description provided for @booking_policy_same_day_desc.
  ///
  /// In en, this message translates to:
  /// **'Cancellation is not possible on the same day due to commitment to prepare the unit.'**
  String get booking_policy_same_day_desc;

  /// No description provided for @booking_financial_details.
  ///
  /// In en, this message translates to:
  /// **'Financial Account Details'**
  String get booking_financial_details;

  /// No description provided for @booking_total_paid.
  ///
  /// In en, this message translates to:
  /// **'Total Amount Paid'**
  String get booking_total_paid;

  /// No description provided for @booking_deduction_value.
  ///
  /// In en, this message translates to:
  /// **'Eligible Deduction Value'**
  String get booking_deduction_value;

  /// No description provided for @booking_net_refund.
  ///
  /// In en, this message translates to:
  /// **'Net Refund Amount'**
  String get booking_net_refund;

  /// No description provided for @booking_confirm_cancellation_final.
  ///
  /// In en, this message translates to:
  /// **'Confirm Final Cancellation'**
  String get booking_confirm_cancellation_final;

  /// No description provided for @booking_cancel_confirm_question.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel the booking permanently? This action cannot be undone.'**
  String get booking_cancel_confirm_question;

  /// No description provided for @booking_revert_and_back.
  ///
  /// In en, this message translates to:
  /// **'Revert and Back'**
  String get booking_revert_and_back;

  /// No description provided for @common_reason.
  ///
  /// In en, this message translates to:
  /// **'Reason:'**
  String get common_reason;

  /// No description provided for @common_required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get common_required;

  /// No description provided for @common_invalid_number.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get common_invalid_number;

  /// No description provided for @owner_select_location_error.
  ///
  /// In en, this message translates to:
  /// **'Please select a location'**
  String get owner_select_location_error;

  /// No description provided for @owner_num_rooms.
  ///
  /// In en, this message translates to:
  /// **'Number of Rooms'**
  String get owner_num_rooms;

  /// No description provided for @owner_num_bathrooms.
  ///
  /// In en, this message translates to:
  /// **'Number of Bathrooms'**
  String get owner_num_bathrooms;

  /// No description provided for @owner_price_per_night_usd.
  ///
  /// In en, this message translates to:
  /// **'Price per night (\$)'**
  String get owner_price_per_night_usd;

  /// No description provided for @owner_price_hint_usd.
  ///
  /// In en, this message translates to:
  /// **'Enter price in USD'**
  String get owner_price_hint_usd;

  /// No description provided for @owner_enter_price_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter price per night'**
  String get owner_enter_price_error;

  /// No description provided for @owner_valid_price_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price'**
  String get owner_valid_price_error;

  /// No description provided for @auth_name_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get auth_name_required;

  /// No description provided for @auth_email_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get auth_email_required;

  /// No description provided for @auth_password_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get auth_password_required;

  /// No description provided for @owner_capture_single_photo.
  ///
  /// In en, this message translates to:
  /// **'Capture single photo'**
  String get owner_capture_single_photo;

  /// No description provided for @profile_capture_new_photo.
  ///
  /// In en, this message translates to:
  /// **'Capture new photo'**
  String get profile_capture_new_photo;

  /// No description provided for @owner_select_multiple_photos.
  ///
  /// In en, this message translates to:
  /// **'Select multiple photos'**
  String get owner_select_multiple_photos;

  /// No description provided for @profile_select_from_gallery.
  ///
  /// In en, this message translates to:
  /// **'Select from gallery'**
  String get profile_select_from_gallery;

  /// No description provided for @owner_chalet_photos_added_success.
  ///
  /// In en, this message translates to:
  /// **'Chalet photos added successfully!'**
  String get owner_chalet_photos_added_success;

  /// No description provided for @owner_chalet_photo_added_success.
  ///
  /// In en, this message translates to:
  /// **'Chalet photo added successfully!'**
  String get owner_chalet_photo_added_success;

  /// No description provided for @owner_some_images_not_added.
  ///
  /// In en, this message translates to:
  /// **'Some images were not added:'**
  String get owner_some_images_not_added;

  /// No description provided for @owner_permission_denied_settings.
  ///
  /// In en, this message translates to:
  /// **'Permission denied. Please grant camera/gallery access in settings.'**
  String get owner_permission_denied_settings;

  /// No description provided for @profile_picture_updated_success.
  ///
  /// In en, this message translates to:
  /// **'Profile picture updated successfully!'**
  String get profile_picture_updated_success;

  /// No description provided for @common_error_uploading_image.
  ///
  /// In en, this message translates to:
  /// **'Error uploading image:'**
  String get common_error_uploading_image;

  /// No description provided for @common_error_picking_image.
  ///
  /// In en, this message translates to:
  /// **'Error picking image'**
  String get common_error_picking_image;

  /// No description provided for @common_access_error_permissions.
  ///
  /// In en, this message translates to:
  /// **'Camera/Gallery access error. Please check permissions.'**
  String get common_access_error_permissions;

  /// No description provided for @common_plugin_error_restart.
  ///
  /// In en, this message translates to:
  /// **'Plugin connection error. Please restart the app.'**
  String get common_plugin_error_restart;

  /// No description provided for @owner_upload_chalet_images.
  ///
  /// In en, this message translates to:
  /// **'Please upload chalet images'**
  String get owner_upload_chalet_images;

  /// No description provided for @owner_fill_all_fields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get owner_fill_all_fields;

  /// No description provided for @owner_chalet_submitted_success.
  ///
  /// In en, this message translates to:
  /// **'Chalet submitted successfully'**
  String get owner_chalet_submitted_success;

  /// No description provided for @home_resale_offers.
  ///
  /// In en, this message translates to:
  /// **'Resale Offers'**
  String get home_resale_offers;

  /// No description provided for @home_exclusive_offers.
  ///
  /// In en, this message translates to:
  /// **'Exclusive Offers'**
  String get home_exclusive_offers;

  /// No description provided for @home_offers_available.
  ///
  /// In en, this message translates to:
  /// **'Offer Available'**
  String get home_offers_available;

  /// No description provided for @home_top_rated.
  ///
  /// In en, this message translates to:
  /// **'Top Rated'**
  String get home_top_rated;

  /// No description provided for @common_discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get common_discount;

  /// No description provided for @common_beds_short.
  ///
  /// In en, this message translates to:
  /// **'Bed'**
  String get common_beds_short;

  /// No description provided for @common_baths_short.
  ///
  /// In en, this message translates to:
  /// **'Bath'**
  String get common_baths_short;

  /// No description provided for @common_m2.
  ///
  /// In en, this message translates to:
  /// **'m²'**
  String get common_m2;

  /// No description provided for @common_hide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get common_hide;

  /// No description provided for @common_show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get common_show;

  /// No description provided for @common_hidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get common_hidden;

  /// No description provided for @common_visible.
  ///
  /// In en, this message translates to:
  /// **'Visible'**
  String get common_visible;

  /// No description provided for @common_closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get common_closed;

  /// No description provided for @common_available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get common_available;

  /// No description provided for @chalet_resale_offers.
  ///
  /// In en, this message translates to:
  /// **'Resale Offers'**
  String get chalet_resale_offers;

  /// No description provided for @favorites_no_favorites.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get favorites_no_favorites;

  /// No description provided for @owner_stop_booking.
  ///
  /// In en, this message translates to:
  /// **'Stop Booking'**
  String get owner_stop_booking;

  /// No description provided for @owner_start_booking.
  ///
  /// In en, this message translates to:
  /// **'Start Booking'**
  String get owner_start_booking;

  /// No description provided for @owner_chalet_photos.
  ///
  /// In en, this message translates to:
  /// **'Chalet Photos'**
  String get owner_chalet_photos;

  /// No description provided for @owner_add_3_photos_hint.
  ///
  /// In en, this message translates to:
  /// **'Add high-quality photos'**
  String get owner_add_3_photos_hint;

  /// No description provided for @owner_add_first_photo.
  ///
  /// In en, this message translates to:
  /// **'Add your first photo'**
  String get owner_add_first_photo;

  /// No description provided for @owner_add_more_photos.
  ///
  /// In en, this message translates to:
  /// **'Add more photos'**
  String get owner_add_more_photos;

  /// No description provided for @owner_tap_to_select.
  ///
  /// In en, this message translates to:
  /// **'Tap to select from gallery'**
  String get owner_tap_to_select;

  /// No description provided for @owner_image_cover.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get owner_image_cover;

  /// No description provided for @owner_select_amenities_hint.
  ///
  /// In en, this message translates to:
  /// **'Select all available amenities'**
  String get owner_select_amenities_hint;

  /// No description provided for @owner_selected_count.
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get owner_selected_count;

  /// No description provided for @owner_no_transfers.
  ///
  /// In en, this message translates to:
  /// **'No transfers yet'**
  String get owner_no_transfers;

  /// No description provided for @owner_no_cancellations.
  ///
  /// In en, this message translates to:
  /// **'No cancelled bookings'**
  String get owner_no_cancellations;

  /// No description provided for @owner_view_full_details.
  ///
  /// In en, this message translates to:
  /// **'View Full Details'**
  String get owner_view_full_details;

  /// No description provided for @owner_approved_chalets.
  ///
  /// In en, this message translates to:
  /// **'Approved Chalets'**
  String get owner_approved_chalets;

  /// No description provided for @owner_no_approved_chalets.
  ///
  /// In en, this message translates to:
  /// **'No approved chalets'**
  String get owner_no_approved_chalets;

  /// No description provided for @owner_approved_chalets_hint.
  ///
  /// In en, this message translates to:
  /// **'Approved chalets will appear here'**
  String get owner_approved_chalets_hint;

  /// No description provided for @home_banner_title_1.
  ///
  /// In en, this message translates to:
  /// **'Enjoy the best chalets in North Coast'**
  String get home_banner_title_1;

  /// No description provided for @home_banner_subtitle_1.
  ///
  /// In en, this message translates to:
  /// **'Discounts up to 25% with Rebtal app'**
  String get home_banner_subtitle_1;

  /// No description provided for @home_banner_tag_1.
  ///
  /// In en, this message translates to:
  /// **'Special Offer'**
  String get home_banner_tag_1;

  /// No description provided for @home_banner_title_2.
  ///
  /// In en, this message translates to:
  /// **'Peace and luxury in Ain Sokhna'**
  String get home_banner_title_2;

  /// No description provided for @home_banner_subtitle_2.
  ///
  /// In en, this message translates to:
  /// **'Book now and get instant 15% discount'**
  String get home_banner_subtitle_2;

  /// No description provided for @home_banner_tag_2.
  ///
  /// In en, this message translates to:
  /// **'Early Booking'**
  String get home_banner_tag_2;

  /// No description provided for @home_banner_title_3.
  ///
  /// In en, this message translates to:
  /// **'Unforgettable atmosphere in Dahab city'**
  String get home_banner_title_3;

  /// No description provided for @home_banner_subtitle_3.
  ///
  /// In en, this message translates to:
  /// **'Exclusive offers for families and groups'**
  String get home_banner_subtitle_3;

  /// No description provided for @home_banner_tag_3.
  ///
  /// In en, this message translates to:
  /// **'Most Requested'**
  String get home_banner_tag_3;

  /// No description provided for @home_winter_offers_title.
  ///
  /// In en, this message translates to:
  /// **'Enjoy the best winter offers'**
  String get home_winter_offers_title;

  /// No description provided for @home_limited_time.
  ///
  /// In en, this message translates to:
  /// **'For a limited time only'**
  String get home_limited_time;

  /// No description provided for @favorites_update_error.
  ///
  /// In en, this message translates to:
  /// **'Could not update favorites'**
  String get favorites_update_error;

  /// No description provided for @common_new_badge.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get common_new_badge;

  /// No description provided for @home_price_range_per_night.
  ///
  /// In en, this message translates to:
  /// **'Price Range (per night)'**
  String get home_price_range_per_night;

  /// No description provided for @home_chalet_area_m2.
  ///
  /// In en, this message translates to:
  /// **'Chalet Area (m²)'**
  String get home_chalet_area_m2;

  /// No description provided for @common_any.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get common_any;

  /// No description provided for @profile_logout_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get profile_logout_confirm;

  /// No description provided for @home_favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get home_favorites;

  /// No description provided for @common_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get common_error;

  /// No description provided for @owner_my_bookings.
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get owner_my_bookings;

  /// No description provided for @owner_no_bookings.
  ///
  /// In en, this message translates to:
  /// **'No bookings found'**
  String get owner_no_bookings;

  /// No description provided for @common_approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get common_approved;

  /// No description provided for @booking_transfers.
  ///
  /// In en, this message translates to:
  /// **'Booking Transfers'**
  String get booking_transfers;

  /// No description provided for @cancellation_log.
  ///
  /// In en, this message translates to:
  /// **'Cancellation Log'**
  String get cancellation_log;

  /// No description provided for @owner_rejected_chalets.
  ///
  /// In en, this message translates to:
  /// **'Rejected Chalets'**
  String get owner_rejected_chalets;

  /// No description provided for @owner_no_rejected_chalets.
  ///
  /// In en, this message translates to:
  /// **'No rejected chalets found'**
  String get owner_no_rejected_chalets;

  /// No description provided for @owner_rejected_chalets_hint.
  ///
  /// In en, this message translates to:
  /// **'Rejected chalets will appear here'**
  String get owner_rejected_chalets_hint;

  /// No description provided for @owner_policy_apply_msg.
  ///
  /// In en, this message translates to:
  /// **'The following cancellation policy will apply to this booking:'**
  String get owner_policy_apply_msg;

  /// No description provided for @owner_create_ad.
  ///
  /// In en, this message translates to:
  /// **'Create your ad'**
  String get owner_create_ad;

  /// No description provided for @owner_add_details_hint.
  ///
  /// In en, this message translates to:
  /// **'Add photos, details and amenities'**
  String get owner_add_details_hint;

  /// No description provided for @owner_discount_percentage.
  ///
  /// In en, this message translates to:
  /// **'% Percentage'**
  String get owner_discount_percentage;

  /// No description provided for @owner_discount_fixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed Amount (EGP)'**
  String get owner_discount_fixed;

  /// No description provided for @owner_enter_discount_percentage.
  ///
  /// In en, this message translates to:
  /// **'Enter discount percentage (%)'**
  String get owner_enter_discount_percentage;

  /// No description provided for @owner_enter_discount_fixed.
  ///
  /// In en, this message translates to:
  /// **'Enter discount value (EGP)'**
  String get owner_enter_discount_fixed;

  /// No description provided for @owner_price_after_discount.
  ///
  /// In en, this message translates to:
  /// **'Price after discount:'**
  String get owner_price_after_discount;

  /// No description provided for @common_sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get common_sending;

  /// No description provided for @common_egp.
  ///
  /// In en, this message translates to:
  /// **'EGP'**
  String get common_egp;

  /// No description provided for @booking_remaining_days.
  ///
  /// In en, this message translates to:
  /// **'Remaining: {days} days'**
  String booking_remaining_days(Object days);

  /// No description provided for @chalet_what_offers.
  ///
  /// In en, this message translates to:
  /// **'What this place offers'**
  String get chalet_what_offers;

  /// No description provided for @chalet_show_all_amenities.
  ///
  /// In en, this message translates to:
  /// **'Show all {count} amenities'**
  String chalet_show_all_amenities(Object count);

  /// No description provided for @chalet_show_less.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get chalet_show_less;

  /// No description provided for @chalet_about_place.
  ///
  /// In en, this message translates to:
  /// **'About this place'**
  String get chalet_about_place;

  /// No description provided for @chalet_gallery_title.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get chalet_gallery_title;

  /// No description provided for @chalet_guest_label.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get chalet_guest_label;

  /// No description provided for @chalet_favourite_label.
  ///
  /// In en, this message translates to:
  /// **'favourite'**
  String get chalet_favourite_label;

  /// No description provided for @chalet_rating_label.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get chalet_rating_label;

  /// No description provided for @chalet_reviews_label.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get chalet_reviews_label;

  /// No description provided for @chalet_night.
  ///
  /// In en, this message translates to:
  /// **'night'**
  String get chalet_night;

  /// No description provided for @chalet_reserve.
  ///
  /// In en, this message translates to:
  /// **'Reserve'**
  String get chalet_reserve;

  /// No description provided for @chalet_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get chalet_unavailable;

  /// No description provided for @profile_about_us_title.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get profile_about_us_title;

  /// No description provided for @profile_welcome_rebtal.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Rebtal'**
  String get profile_welcome_rebtal;

  /// No description provided for @profile_trusted_platform.
  ///
  /// In en, this message translates to:
  /// **'Your trusted platform for chalet bookings'**
  String get profile_trusted_platform;

  /// No description provided for @profile_our_mission_title.
  ///
  /// In en, this message translates to:
  /// **'Our Mission'**
  String get profile_our_mission_title;

  /// No description provided for @profile_our_mission_content.
  ///
  /// In en, this message translates to:
  /// **'We strive to facilitate accessibility to suitable chalets for our clients at the best prices while ensuring complete booking security. We aim to provide an exceptional experience that combines comfort and reliability.'**
  String get profile_our_mission_content;

  /// No description provided for @profile_what_we_offer_title.
  ///
  /// In en, this message translates to:
  /// **'What We Offer'**
  String get profile_what_we_offer_title;

  /// No description provided for @profile_easy_search_desc.
  ///
  /// In en, this message translates to:
  /// **'Find your perfect chalet with our advanced search filters'**
  String get profile_easy_search_desc;

  /// No description provided for @profile_best_prices_desc.
  ///
  /// In en, this message translates to:
  /// **'Competitive pricing and exclusive deals for our users'**
  String get profile_best_prices_desc;

  /// No description provided for @profile_secure_booking_desc.
  ///
  /// In en, this message translates to:
  /// **'Safe and reliable booking process with instant confirmation'**
  String get profile_secure_booking_desc;

  /// No description provided for @profile_support_24_desc.
  ///
  /// In en, this message translates to:
  /// **'Always here to help with any questions or concerns'**
  String get profile_support_24_desc;

  /// No description provided for @profile_why_choose_us_title.
  ///
  /// In en, this message translates to:
  /// **'Why Choose Us'**
  String get profile_why_choose_us_title;

  /// No description provided for @profile_why_choose_us_content.
  ///
  /// In en, this message translates to:
  /// **'We connect chalet owners with guests looking for the perfect getaway. Our platform ensures transparency, security, and convenience for both parties. With verified listings and secure payment methods, you can book with confidence.'**
  String get profile_why_choose_us_content;

  /// No description provided for @profile_start_exploring.
  ///
  /// In en, this message translates to:
  /// **'Start exploring amazing chalets today!'**
  String get profile_start_exploring;

  /// No description provided for @profile_get_in_touch.
  ///
  /// In en, this message translates to:
  /// **'Get In Touch'**
  String get profile_get_in_touch;

  /// No description provided for @profile_contact_hint.
  ///
  /// In en, this message translates to:
  /// **'We\'re here to help! Reach out to us through any of the following methods.'**
  String get profile_contact_hint;

  /// No description provided for @profile_support_hours_title.
  ///
  /// In en, this message translates to:
  /// **'Support Hours'**
  String get profile_support_hours_title;

  /// No description provided for @profile_support_hours_content.
  ///
  /// In en, this message translates to:
  /// **'We\'re available to assist you 24/7'**
  String get profile_support_hours_content;

  /// No description provided for @profile_copied_clipboard.
  ///
  /// In en, this message translates to:
  /// **'{label} copied to clipboard'**
  String profile_copied_clipboard(Object label);

  /// No description provided for @profile_privacy_policy_title.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get profile_privacy_policy_title;

  /// No description provided for @profile_last_updated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String profile_last_updated(Object date);

  /// No description provided for @profile_info_collect_title.
  ///
  /// In en, this message translates to:
  /// **'Information We Collect'**
  String get profile_info_collect_title;

  /// No description provided for @profile_info_collect_content.
  ///
  /// In en, this message translates to:
  /// **'We collect information that you provide directly to us when you create an account, make a booking, or contact us. This may include your name, email address, phone number, and booking preferences.'**
  String get profile_info_collect_content;

  /// No description provided for @profile_how_use_info_title.
  ///
  /// In en, this message translates to:
  /// **'How We Use Your Information'**
  String get profile_how_use_info_title;

  /// No description provided for @profile_how_use_info_content.
  ///
  /// In en, this message translates to:
  /// **'We use your information to:\n• Process and manage your bookings\n• Communicate with you about your reservations\n• Improve our services and user experience\n• Send important updates and notifications\n• Ensure security and prevent fraud'**
  String get profile_how_use_info_content;

  /// No description provided for @profile_data_protection_title.
  ///
  /// In en, this message translates to:
  /// **'Data Protection'**
  String get profile_data_protection_title;

  /// No description provided for @profile_data_protection_content.
  ///
  /// In en, this message translates to:
  /// **'We implement robust security measures to protect your personal information. Your data is encrypted and stored securely. We never sell or share your personal information with third parties for marketing purposes.'**
  String get profile_data_protection_content;

  /// No description provided for @profile_your_rights_title.
  ///
  /// In en, this message translates to:
  /// **'Your Rights'**
  String get profile_your_rights_title;

  /// No description provided for @profile_your_rights_content.
  ///
  /// In en, this message translates to:
  /// **'You have the right to:\n• Access your personal data\n• Request corrections to your information\n• Delete your account and associated data\n• Opt-out of promotional communications\n• Request a copy of your data'**
  String get profile_your_rights_content;

  /// No description provided for @profile_cookies_tracking_title.
  ///
  /// In en, this message translates to:
  /// **'Cookies and Tracking'**
  String get profile_cookies_tracking_title;

  /// No description provided for @profile_cookies_tracking_content.
  ///
  /// In en, this message translates to:
  /// **'We use cookies and similar technologies to enhance your experience, analyze usage patterns, and remember your preferences. You can control cookie settings through your browser.'**
  String get profile_cookies_tracking_content;

  /// No description provided for @profile_third_party_title.
  ///
  /// In en, this message translates to:
  /// **'Third-Party Services'**
  String get profile_third_party_title;

  /// No description provided for @profile_third_party_content.
  ///
  /// In en, this message translates to:
  /// **'We may use third-party services for payment processing, analytics, and communication. These services have their own privacy policies and we encourage you to review them.'**
  String get profile_third_party_content;

  /// No description provided for @profile_children_privacy_title.
  ///
  /// In en, this message translates to:
  /// **'Children\'s Privacy'**
  String get profile_children_privacy_title;

  /// No description provided for @profile_children_privacy_content.
  ///
  /// In en, this message translates to:
  /// **'Our services are not intended for users under the age of 18. We do not knowingly collect personal information from children.'**
  String get profile_children_privacy_content;

  /// No description provided for @profile_policy_changes_title.
  ///
  /// In en, this message translates to:
  /// **'Changes to This Policy'**
  String get profile_policy_changes_title;

  /// No description provided for @profile_policy_changes_content.
  ///
  /// In en, this message translates to:
  /// **'We may update this privacy policy from time to time. We will notify you of any significant changes by posting the new policy on this page and updating the \"Last updated\" date.'**
  String get profile_policy_changes_content;

  /// No description provided for @profile_privacy_agree_info.
  ///
  /// In en, this message translates to:
  /// **'By using our services, you agree to this Privacy Policy.'**
  String get profile_privacy_agree_info;

  /// No description provided for @profile_refund_cancel_title.
  ///
  /// In en, this message translates to:
  /// **'Refund & Cancellation'**
  String get profile_refund_cancel_title;

  /// No description provided for @profile_cancel_rules_title.
  ///
  /// In en, this message translates to:
  /// **'Cancellation Rules'**
  String get profile_cancel_rules_title;

  /// No description provided for @profile_cancel_rules_content.
  ///
  /// In en, this message translates to:
  /// **'You can cancel your booking through the app. Cancellation policies vary by property and are clearly stated at the time of booking. Please review the specific cancellation terms before confirming your reservation.'**
  String get profile_cancel_rules_content;

  /// No description provided for @profile_flexible_cancel_title.
  ///
  /// In en, this message translates to:
  /// **'Flexible Cancellation'**
  String get profile_flexible_cancel_title;

  /// No description provided for @profile_flexible_cancel_content.
  ///
  /// In en, this message translates to:
  /// **'• Cancel up to 48 hours before check-in: 100% refund\n• Cancel 24-48 hours before check-in: 50% refund\n• Cancel less than 24 hours before check-in: No refund\n• No-show: No refund'**
  String get profile_flexible_cancel_content;

  /// No description provided for @profile_strict_cancel_title.
  ///
  /// In en, this message translates to:
  /// **'Strict Cancellation'**
  String get profile_strict_cancel_title;

  /// No description provided for @profile_strict_cancel_content.
  ///
  /// In en, this message translates to:
  /// **'• Cancel up to 7 days before check-in: 50% refund\n• Cancel less than 7 days before check-in: No refund\n• No-show: No refund'**
  String get profile_strict_cancel_content;

  /// No description provided for @profile_non_refundable_title.
  ///
  /// In en, this message translates to:
  /// **'Non-Refundable'**
  String get profile_non_refundable_title;

  /// No description provided for @profile_non_refundable_content.
  ///
  /// In en, this message translates to:
  /// **'Some special offers and promotions are non-refundable. These bookings are clearly marked during the booking process. Once confirmed, these reservations cannot be cancelled or refunded.'**
  String get profile_non_refundable_content;

  /// No description provided for @profile_refund_proc_title.
  ///
  /// In en, this message translates to:
  /// **'Refund Processing'**
  String get profile_refund_proc_title;

  /// No description provided for @profile_refund_proc_content.
  ///
  /// In en, this message translates to:
  /// **'• Approved refunds are processed within 5-10 business days\n• Refunds are returned to the original payment method\n• You will receive a confirmation email once the refund is processed\n• Bank processing may take additional 3-5 business days'**
  String get profile_refund_proc_content;

  /// No description provided for @profile_special_circ_title.
  ///
  /// In en, this message translates to:
  /// **'Special Circumstances'**
  String get profile_special_circ_title;

  /// No description provided for @profile_special_circ_content.
  ///
  /// In en, this message translates to:
  /// **'In case of emergencies or unforeseen circumstances (natural disasters, medical emergencies, etc.), please contact us directly. We will review your case and work with the property owner to find a fair solution.'**
  String get profile_special_circ_content;

  /// No description provided for @profile_booking_mod_title.
  ///
  /// In en, this message translates to:
  /// **'Booking Modifications'**
  String get profile_booking_mod_title;

  /// No description provided for @profile_booking_mod_content.
  ///
  /// In en, this message translates to:
  /// **'You can request to modify your booking dates subject to availability and property approval. Modifications may incur additional charges based on price differences and modification policies.'**
  String get profile_booking_mod_content;

  /// No description provided for @profile_dispute_res_title.
  ///
  /// In en, this message translates to:
  /// **'Dispute Resolution'**
  String get profile_dispute_res_title;

  /// No description provided for @profile_dispute_res_content.
  ///
  /// In en, this message translates to:
  /// **'If you have any issues with your booking or refund, please contact us immediately. We are committed to resolving all disputes fairly and promptly. Our support team will mediate between you and the property owner.'**
  String get profile_dispute_res_content;

  /// No description provided for @profile_review_specific_policy.
  ///
  /// In en, this message translates to:
  /// **'Always review the specific cancellation policy for your chosen property before booking. Policies may vary.'**
  String get profile_review_specific_policy;

  /// No description provided for @profile_questions_cancel.
  ///
  /// In en, this message translates to:
  /// **'Questions about cancellations?'**
  String get profile_questions_cancel;

  /// No description provided for @profile_booking_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Booking & Confirmation'**
  String get profile_booking_confirm_title;

  /// No description provided for @profile_instant_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Instant Confirmation'**
  String get profile_instant_confirm_title;

  /// No description provided for @profile_instant_confirm_content.
  ///
  /// In en, this message translates to:
  /// **'Once your booking is submitted and payment is processed, you will receive an instant confirmation via email and in-app notification. Your booking details will be immediately available in your account.'**
  String get profile_instant_confirm_content;

  /// No description provided for @profile_booking_timeline_title.
  ///
  /// In en, this message translates to:
  /// **'Booking Timeline'**
  String get profile_booking_timeline_title;

  /// No description provided for @profile_booking_timeline_content.
  ///
  /// In en, this message translates to:
  /// **'You can book a chalet up to 6 months in advance. Last-minute bookings are accepted subject to availability. We recommend booking at least 48 hours before your desired check-in date for the best availability.'**
  String get profile_booking_timeline_content;

  /// No description provided for @profile_checkin_proc_title.
  ///
  /// In en, this message translates to:
  /// **'Check-In Process'**
  String get profile_checkin_proc_title;

  /// No description provided for @profile_checkin_proc_content.
  ///
  /// In en, this message translates to:
  /// **'• Check-in time: As specified in the chalet listing (typically 2:00 PM)\n• You will receive check-in instructions 24 hours before arrival\n• Present your booking confirmation to the property owner\n• All guest information must be accurate and verified'**
  String get profile_checkin_proc_content;

  /// No description provided for @profile_checkout_proc_title.
  ///
  /// In en, this message translates to:
  /// **'Check-Out Process'**
  String get profile_checkout_proc_title;

  /// No description provided for @profile_checkout_proc_content.
  ///
  /// In en, this message translates to:
  /// **'• Check-out time: As specified in the chalet listing (typically 12:00 PM)\n• Please leave the chalet in good condition\n• Return all keys and access cards\n• Late check-out may be available upon request (additional fees may apply)'**
  String get profile_checkout_proc_content;

  /// No description provided for @profile_booking_verify_title.
  ///
  /// In en, this message translates to:
  /// **'Booking Verification'**
  String get profile_booking_verify_title;

  /// No description provided for @profile_booking_verify_content.
  ///
  /// In en, this message translates to:
  /// **'All bookings are subject to verification by the property owner. In rare cases, a booking may be declined. If this occurs, you will receive a full refund within 3-5 business days.'**
  String get profile_booking_verify_content;

  /// No description provided for @profile_important_info_title.
  ///
  /// In en, this message translates to:
  /// **'Important Information'**
  String get profile_important_info_title;

  /// No description provided for @profile_important_info_content.
  ///
  /// In en, this message translates to:
  /// **'• Bring a valid ID for check-in\n• Review house rules before your stay\n• Maximum occupancy must be respected\n• Smoking and pet policies vary by property\n• Contact the owner for any special requests'**
  String get profile_important_info_content;

  /// No description provided for @profile_stay_support_title.
  ///
  /// In en, this message translates to:
  /// **'Support During Your Stay'**
  String get profile_stay_support_title;

  /// No description provided for @profile_stay_support_content.
  ///
  /// In en, this message translates to:
  /// **'Our support team is available 24/7 to assist you during your stay. Contact us immediately if you encounter any issues with the property or have questions about your booking.'**
  String get profile_stay_support_content;

  /// No description provided for @profile_booking_help_title.
  ///
  /// In en, this message translates to:
  /// **'Need help with your booking?'**
  String get profile_booking_help_title;

  /// No description provided for @chalet_detail_superhost.
  ///
  /// In en, this message translates to:
  /// **'Superhost'**
  String get chalet_detail_superhost;

  /// No description provided for @chalet_detail_area.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get chalet_detail_area;

  /// No description provided for @chalet_detail_bedroom.
  ///
  /// In en, this message translates to:
  /// **'bedroom'**
  String get chalet_detail_bedroom;

  /// No description provided for @chalet_detail_bedrooms.
  ///
  /// In en, this message translates to:
  /// **'bedrooms'**
  String get chalet_detail_bedrooms;

  /// No description provided for @chalet_detail_beds.
  ///
  /// In en, this message translates to:
  /// **'beds'**
  String get chalet_detail_beds;

  /// No description provided for @chalet_detail_hosted_by.
  ///
  /// In en, this message translates to:
  /// **'Hosted by'**
  String get chalet_detail_hosted_by;

  /// No description provided for @chalet_detail_month_hosting.
  ///
  /// In en, this message translates to:
  /// **'month hosting'**
  String get chalet_detail_month_hosting;

  /// No description provided for @chalet_detail_months_hosting.
  ///
  /// In en, this message translates to:
  /// **'months hosting'**
  String get chalet_detail_months_hosting;

  /// No description provided for @chalet_detail_year_hosting.
  ///
  /// In en, this message translates to:
  /// **'year hosting'**
  String get chalet_detail_year_hosting;

  /// No description provided for @chalet_detail_years_hosting.
  ///
  /// In en, this message translates to:
  /// **'years hosting'**
  String get chalet_detail_years_hosting;

  /// No description provided for @chalet_detail_day_hosting.
  ///
  /// In en, this message translates to:
  /// **'day hosting'**
  String get chalet_detail_day_hosting;

  /// No description provided for @chalet_detail_days_hosting.
  ///
  /// In en, this message translates to:
  /// **'days hosting'**
  String get chalet_detail_days_hosting;

  /// No description provided for @chalet_detail_new_host.
  ///
  /// In en, this message translates to:
  /// **'New host'**
  String get chalet_detail_new_host;

  /// No description provided for @chalet_detail_show_more.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get chalet_detail_show_more;

  /// No description provided for @chalet_detail_show_less.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get chalet_detail_show_less;

  /// No description provided for @chalet_detail_reviews.
  ///
  /// In en, this message translates to:
  /// **'reviews'**
  String get chalet_detail_reviews;

  /// No description provided for @chalet_detail_show_all_reviews.
  ///
  /// In en, this message translates to:
  /// **'Show all {count} reviews'**
  String chalet_detail_show_all_reviews(Object count);

  /// No description provided for @chalet_detail_no_reviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get chalet_detail_no_reviews;

  /// No description provided for @chalet_detail_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get chalet_detail_today;

  /// No description provided for @chalet_detail_booking_period.
  ///
  /// In en, this message translates to:
  /// **'Booking Period'**
  String get chalet_detail_booking_period;

  /// No description provided for @chalet_detail_nights.
  ///
  /// In en, this message translates to:
  /// **'nights'**
  String get chalet_detail_nights;

  /// No description provided for @chalet_detail_check_in.
  ///
  /// In en, this message translates to:
  /// **'Check-in'**
  String get chalet_detail_check_in;

  /// No description provided for @chalet_detail_check_out.
  ///
  /// In en, this message translates to:
  /// **'Check-out'**
  String get chalet_detail_check_out;

  /// No description provided for @common_egp_abbr.
  ///
  /// In en, this message translates to:
  /// **'EGP'**
  String get common_egp_abbr;

  /// No description provided for @admin_requests_error.
  ///
  /// In en, this message translates to:
  /// **'Error loading requests'**
  String get admin_requests_error;

  /// No description provided for @admin_no_requests.
  ///
  /// In en, this message translates to:
  /// **'No requests yet'**
  String get admin_no_requests;

  /// No description provided for @admin_no_approved_requests.
  ///
  /// In en, this message translates to:
  /// **'No approved requests'**
  String get admin_no_approved_requests;

  /// No description provided for @admin_no_pending_requests.
  ///
  /// In en, this message translates to:
  /// **'No pending requests'**
  String get admin_no_pending_requests;

  /// No description provided for @admin_no_rejected_requests.
  ///
  /// In en, this message translates to:
  /// **'No rejected requests'**
  String get admin_no_rejected_requests;

  /// No description provided for @admin_tab_statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get admin_tab_statistics;

  /// No description provided for @admin_tab_users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get admin_tab_users;

  /// No description provided for @admin_tab_owners.
  ///
  /// In en, this message translates to:
  /// **'Owners'**
  String get admin_tab_owners;

  /// No description provided for @admin_tab_admins.
  ///
  /// In en, this message translates to:
  /// **'Admins'**
  String get admin_tab_admins;

  /// No description provided for @admin_tab_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get admin_tab_pending;

  /// No description provided for @admin_tab_payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get admin_tab_payments;

  /// No description provided for @admin_tab_cancellations.
  ///
  /// In en, this message translates to:
  /// **'Cancellations'**
  String get admin_tab_cancellations;

  /// No description provided for @admin_tab_approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get admin_tab_approved;

  /// No description provided for @admin_tab_rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get admin_tab_rejected;

  /// No description provided for @admin_panel.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get admin_panel;

  /// No description provided for @admin_dashboard_overview.
  ///
  /// In en, this message translates to:
  /// **'Dashboard Overview'**
  String get admin_dashboard_overview;

  /// No description provided for @admin_administrator.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get admin_administrator;

  /// No description provided for @admin_user_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get admin_user_edit;

  /// No description provided for @admin_user_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get admin_user_delete;

  /// No description provided for @admin_user_view_photos.
  ///
  /// In en, this message translates to:
  /// **'View Profile & ID Photos'**
  String get admin_user_view_photos;

  /// No description provided for @admin_user_profile_photo.
  ///
  /// In en, this message translates to:
  /// **'Profile Photo'**
  String get admin_user_profile_photo;

  /// No description provided for @admin_user_id_card.
  ///
  /// In en, this message translates to:
  /// **'ID Card'**
  String get admin_user_id_card;

  /// No description provided for @admin_user_photos_title.
  ///
  /// In en, this message translates to:
  /// **'{name} Photos'**
  String admin_user_photos_title(Object name);

  /// No description provided for @time_months_ago.
  ///
  /// In en, this message translates to:
  /// **'months ago'**
  String get time_months_ago;

  /// No description provided for @time_days_ago.
  ///
  /// In en, this message translates to:
  /// **'days ago'**
  String get time_days_ago;

  /// No description provided for @time_yesterday.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get time_yesterday;

  /// No description provided for @time_weeks_ago.
  ///
  /// In en, this message translates to:
  /// **'weeks ago'**
  String get time_weeks_ago;

  /// No description provided for @owner_your_chalet.
  ///
  /// In en, this message translates to:
  /// **'Your Chalet'**
  String get owner_your_chalet;
}

class _ArbLocalizationsDelegate
    extends LocalizationsDelegate<ArbLocalizations> {
  const _ArbLocalizationsDelegate();

  @override
  Future<ArbLocalizations> load(Locale locale) {
    return SynchronousFuture<ArbLocalizations>(lookupArbLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_ArbLocalizationsDelegate old) => false;
}

ArbLocalizations lookupArbLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return ArbLocalizationsAr();
    case 'en':
      return ArbLocalizationsEn();
  }

  throw FlutterError(
    'ArbLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
