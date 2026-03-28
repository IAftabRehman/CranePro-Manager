import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/business_profile.dart';

class BusinessProfileNotifier extends Notifier<BusinessProfile> {
  @override
  BusinessProfile build() {
    return BusinessProfile(
      businessName: 'Bahadar Transport and Crane Services',
      email: 'info@bahadartransport.com',
      website: 'bahadartransport.com',
      address: 'Musaffah-M26 Abu Dhabi, UAE',
    );
  }

  void updateProfile(BusinessProfile newProfile) {
    state = newProfile;
  }
}

final businessProfileProvider = NotifierProvider<BusinessProfileNotifier, BusinessProfile>(BusinessProfileNotifier.new);
