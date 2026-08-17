import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/donation_model.dart';
import '../../../repositories/donation_repository.dart';

final donationRepositoryProvider =
Provider<DonationRepository>((ref) {
  return DonationRepository();
});

final donationsProvider =
FutureProvider<List<DonationModel>>((ref) async {
  final repository =
  ref.read(donationRepositoryProvider);

  return repository.getDonations();
});