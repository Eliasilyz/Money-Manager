class AppLinks {
  AppLinks._();

  static const bool showDonation = true;

  static const String donationUrl = 'https://ko-fi.com/eliasilyz';

  static const String privacyPolicyUrl = 'https://TODO_FILL_ME';

  static const String termsOfServiceUrl = 'https://TODO_FILL_ME';

  static const String contactUrl = 'mailto:farellh12@gmail.com';

  static const String rateAppUrl =
      'https://TODO_FILL_ME';

  static const String shareAppText =
      'Check out Money Manager - a personal finance tracker app!';

  static const String developerName = 'Irvan Farael Hanafi';

  static bool get hasDeveloperCredits =>
      developerName.isNotEmpty && developerName != 'TODO_FILL_ME';

  static bool get hasPrivacyPolicy =>
      privacyPolicyUrl.isNotEmpty && privacyPolicyUrl != 'https://TODO_FILL_ME';

  static bool get hasTermsOfService =>
      termsOfServiceUrl.isNotEmpty && termsOfServiceUrl != 'https://TODO_FILL_ME';

  static bool get hasContactUrl =>
      contactUrl.isNotEmpty && contactUrl != 'mailto:TODO_FILL_ME';

  static bool get hasRateApp =>
      rateAppUrl.isNotEmpty && rateAppUrl != 'https://TODO_FILL_ME';
}
