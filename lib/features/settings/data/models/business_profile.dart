class BusinessProfile {
  final String logoPath;
  final String businessName;
  final String email;
  final String website;
  final String address;

  BusinessProfile({
    this.logoPath = 'assets/images/logo.png',
    this.businessName = 'CranePro-Manager',
    this.email = 'info@cranepromanager.com',
    this.website = 'www.cranepromanager.com',
    this.address = 'Musaffah M-26, Abu Dhabi, UAE',
  });

  BusinessProfile copyWith({
    String? logoPath,
    String? businessName,
    String? email,
    String? website,
    String? address,
  }) {
    return BusinessProfile(
      logoPath: logoPath ?? this.logoPath,
      businessName: businessName ?? this.businessName,
      email: email ?? this.email,
      website: website ?? this.website,
      address: address ?? this.address,
    );
  }
}
