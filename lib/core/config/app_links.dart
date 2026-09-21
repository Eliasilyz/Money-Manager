class AppLinks {
  AppLinks._();

  static const bool showDonation = false;

  static const String donationUrl = 'https://saweria.co/TODO_FILL_ME';

  static const String privacyPolicyUrl = 'https://TODO_FILL_ME';

  static const String termsOfServiceUrl = 'https://TODO_FILL_ME';

  static const String contactUrl = 'mailto:TODO_FILL_ME';

  static const String rateAppUrl =
      'https://play.google.com/store/apps/details?id=com.moneymanager.app';

  static const String shareAppText =
      'Check out Money Manager - a personal finance tracker app!';

  static const String developerName = 'TODO_FILL_ME';

  static bool get hasDeveloperCredits => developerName != 'TODO_FILL_ME';

  static bool get hasPrivacyPolicy =>
      privacyPolicyUrl != 'https://TODO_FILL_ME';

  static bool get hasTermsOfService =>
      termsOfServiceUrl != 'https://TODO_FILL_ME';

  static bool get hasContactUrl => contactUrl != 'mailto:TODO_FILL_ME';
}
