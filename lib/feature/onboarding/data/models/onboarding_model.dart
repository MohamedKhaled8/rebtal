/// Model class for onboarding page content
/// Contains tourism-focused marketing copy for premium vacation booking app
class OnboardingContent {
  final String title;
  final String description;
  final String animationPath;
  final List<String> highlights; // Key features to highlight

  const OnboardingContent({
    required this.title,
    required this.description,
    required this.animationPath,
    this.highlights = const [],
  });

  /// Premium tourism-focused onboarding pages
  static List<OnboardingContent> get pages => [
    // Page 1: Luxury Chalets
    const OnboardingContent(
      title: 'Luxury Redefined',
      description:
          'Experience the epitome of comfort in our handpicked selection of premium chalets and resorts. Your exclusive getaway begins here.',
      animationPath: 'assets/images/json/luxury_chalet.json',
      highlights: [
        'Exclusive Properties',
        'Premium Amenities',
        'Verified Quality',
      ],
    ),

    // Page 2: Beach & Nature
    const OnboardingContent(
      title: 'Nature\'s Embrace',
      description:
          'Wake up to the sound of waves or the whisper of the forest. Discover destinations that reconnect you with the beauty of nature.',
      animationPath: 'assets/images/json/beach_vacation.json',
      highlights: ['Stunning Views', 'Private Beaches', 'Serene Locations'],
    ),

    // Page 3: Seamless Booking
    const OnboardingContent(
      title: 'Effortless Journeys',
      description:
          'From discovery to check-in, enjoy a seamless booking experience designed for the modern traveler. Secure, fast, and reliable.',
      animationPath: 'assets/images/json/easy_booking.json',
      highlights: ['Instant Confirmation', 'Secure Payment', '24/7 Concierge'],
    ),
  ];
}
