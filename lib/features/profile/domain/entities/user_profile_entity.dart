class UserProfileEntity {
  final String? phoneE164;
  final String? country;
  final String? locale;
  final String? timezone;
  final String? currency;
  final DateTime? birthdate;
  final String? avatarUrl;
  final bool marketingOptin;

  UserProfileEntity({
    this.phoneE164,
    this.country,
    this.locale,
    this.timezone,
    this.currency,
    this.birthdate,
    this.avatarUrl,
    this.marketingOptin = false,
  });

  factory UserProfileEntity.fromJson(Map<String, dynamic> json) {
    return UserProfileEntity(
      phoneE164: json['phone_e164'] as String?,
      country: json['country'] as String?,
      locale: json['locale'] as String?,
      timezone: json['timezone'] as String?,
      currency: json['currency'] as String?,
      birthdate: json['birthdate'] != null
          ? DateTime.tryParse(json['birthdate'])
          : null,
      avatarUrl: json['avatar_url'] as String?,
      marketingOptin: (json['marketing_optin'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (phoneE164 != null) 'upf_phone_e164': phoneE164,
      if (country != null) 'upf_country': country,
      if (locale != null) 'upf_locale': locale,
      if (timezone != null) 'upf_timezone': timezone,
      if (currency != null) 'upf_currency': currency,
      if (birthdate != null)
        'upf_birthdate': birthdate!.toIso8601String().substring(0, 10),
      if (avatarUrl != null) 'upf_avatar_url': avatarUrl,
      'upf_marketing_optin': marketingOptin,
    };
  }
}
