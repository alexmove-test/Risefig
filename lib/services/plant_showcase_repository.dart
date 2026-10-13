import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/garden.dart';
import '../models/plant_listing.dart';
import '../models/seed_catalog.dart';
import 'display_name_filter.dart';
import 'firebase_bootstrap.dart';
import 'guest_name.dart';
import 'player_profile_store.dart';

abstract class PlantShowcaseRepository {
  Future<ShowcaseIdentity> connect();
  Future<PlantListingPage> fetchPage({Object? cursor});
  Future<List<PlantListing>> fetchMine(String ownerId);
  Future<PlantListing> publish(ShowcaseIdentity owner, HarvestedPlant plant);
  Future<void> remove(ShowcaseIdentity owner, String plantId);
}

class ShowcaseUnavailable implements Exception {}

class FirebasePlantShowcaseRepository implements PlantShowcaseRepository {
  static const collection = 'plant_showcase';
  static const pageSize = 30;

  CollectionReference<Map<String, dynamic>> get _plants =>
      FirebaseFirestore.instance.collection(collection);

  @override
  Future<ShowcaseIdentity> connect() async {
    if (!FirebaseBootstrap.enabled) throw ShowcaseUnavailable();
    final user = await FirebaseBootstrap.ensureSignedIn().timeout(
      const Duration(seconds: 15),
    );
    if (user == null) throw ShowcaseUnavailable();
    final profile = await PlayerProfileStore.open();
    return ShowcaseIdentity(user.uid, profile.displayName);
  }

  @override
  Future<PlantListingPage> fetchPage({Object? cursor}) async {
    Query<Map<String, dynamic>> query = _plants
        .orderBy('publishedAt', descending: true)
        .limit(pageSize);
    if (cursor is DocumentSnapshot<Map<String, dynamic>>) {
      query = query.startAfterDocument(cursor);
    }
    final result = await query.get(const GetOptions(source: Source.server));
    return PlantListingPage(
      items: [for (final doc in result.docs) ?_decode(doc)],
      cursor: result.docs.length == pageSize ? result.docs.last : null,
    );
  }

  @override
  Future<List<PlantListing>> fetchMine(String ownerId) async {
    final items = <PlantListing>[];
    DocumentSnapshot<Map<String, dynamic>>? cursor;
    while (true) {
      Query<Map<String, dynamic>> query = _plants
          .where('ownerId', isEqualTo: ownerId)
          .orderBy(FieldPath.documentId)
          .limit(pageSize);
      if (cursor != null) query = query.startAfterDocument(cursor);
      final result = await query.get(const GetOptions(source: Source.server));
      for (final doc in result.docs) {
        final item = _decode(doc);
        if (item != null) items.add(item);
      }
      if (result.docs.length < pageSize) break;
      cursor = result.docs.last;
    }
    return items;
  }

  @override
  Future<PlantListing> publish(
    ShowcaseIdentity owner,
    HarvestedPlant plant,
  ) async {
    final ref = _plants.doc('${owner.id}__${plant.id}');
    // Transactions fail offline instead of queuing a publication behind a
    // later withdrawal. Repeating publication keeps the same document/date.
    await FirebaseFirestore.instance.runTransaction<void>(
      (transaction) async {
        final previous = await transaction.get(ref);
        transaction.set(ref, {
          'ownerId': owner.id,
          'ownerName': DisplayNameFilter.publicName(
            GuestName.clamp(owner.name),
          ),
          'plantId': plant.id,
          'species': plant.species.name,
          'power': GardenCatalog.foodFor(plant.species),
          'publishedAt':
              previous.data()?['publishedAt'] ?? FieldValue.serverTimestamp(),
        });
      },
      timeout: const Duration(seconds: 15),
      maxAttempts: 2,
    );
    final doc = await ref
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 15));
    final listing = _decode(doc);
    if (listing == null) throw StateError('Publication was not confirmed');
    return listing;
  }

  @override
  Future<void> remove(ShowcaseIdentity owner, String plantId) async {
    final ref = _plants.doc('${owner.id}__$plantId');
    await FirebaseFirestore.instance.runTransaction<void>(
      (transaction) async {
        final doc = await transaction.get(ref);
        if (doc.exists) transaction.delete(ref);
      },
      timeout: const Duration(seconds: 15),
      maxAttempts: 2,
    );
  }

  static PlantListing? _decode(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) return null;
    final ownerId = data['ownerId'];
    final name = data['ownerName'];
    final plantId = data['plantId'];
    final date = data['publishedAt'];
    if (ownerId is! String ||
        ownerId.isEmpty ||
        name is! String ||
        plantId is! String ||
        plantId.isEmpty ||
        date is! Timestamp) {
      return null;
    }
    SeedSpecies? species;
    for (final candidate in SeedSpecies.values) {
      if (candidate.name == data['species']) species = candidate;
    }
    if (species == null || data['power'] != GardenCatalog.foodFor(species)) {
      return null;
    }
    return PlantListing(
      id: doc.id,
      ownerId: ownerId,
      ownerName: DisplayNameFilter.publicName(GuestName.clamp(name)),
      plantId: plantId,
      species: species,
      power: GardenCatalog.foodFor(species),
      publishedAt: date.toDate(),
    );
  }
}
