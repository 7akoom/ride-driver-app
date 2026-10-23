import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/captain/captain_providers.dart';
import '../../core/network/api_client_provider.dart';
import 'data/offers_api.dart';
import 'data/offers_repository_impl.dart';
import 'domain/repositories/offers_repository.dart';
import 'domain/use_cases/describe_offer.dart';

// The feature's wiring. Tests override the repository.

final offersRepositoryProvider = Provider<OffersRepository>(
  (ref) => OffersRepositoryImpl(OffersApi(ref.watch(apiClientProvider)), ref.watch(captainAccountRepositoryProvider)),
);

final describeOfferProvider = Provider<DescribeOffer>((ref) => DescribeOffer(ref.watch(offersRepositoryProvider)));
