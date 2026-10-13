import 'seed_catalog.dart';

/// A public display card, not a transferable or server-verified inventory item.
class PlantListing {
  const PlantListing({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.plantId,
    required this.species,
    required this.power,
    required this.publishedAt,
  });

  final String id;
  final String ownerId;
  final String ownerName;
  final String plantId;
  final SeedSpecies species;
  final int power;
  final DateTime publishedAt;
}

class PlantListingPage {
  const PlantListingPage({required this.items, this.cursor});

  final List<PlantListing> items;
  final Object? cursor;
  bool get hasMore => cursor != null;
}

class ShowcaseIdentity {
  const ShowcaseIdentity(this.id, this.name);
  final String id;
  final String name;
}
