import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/garden_models.dart';

class GardenService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const int kMaxPlots = 9;

  Future<List<GardenPlot>> loadGardenPlots(String userId) async {
    final plots = List.generate(
      kMaxPlots,
      (i) => GardenPlot(plotIndex: i),
    );

    try {
      final snapshot = await _db
          .collection('WordGardenTrees')
          .where('UserId', isEqualTo: userId)
          .get();

      for (final doc in snapshot.docs) {
        final data        = doc.data();
        final plotIndex   = (data['PlotIndex']   as int?) ?? 0;
        final growthStage = (data['GrowthStage'] as int?) ?? 0;
        final isMastered  = (data['IsMastered']  as bool?) ?? false;

        if (plotIndex < 0 || plotIndex >= kMaxPlots) continue;

        plots[plotIndex] = GardenPlot(
          plotIndex:      plotIndex,
          status:         isMastered ? PlotStatus.mastered : PlotStatus.planted,
          treeId:         doc.id,                           // ← dùng doc.id làm treeId
          setId:          data['SetId']     as String?,
          setTitle:       data['SetTitle']  as String?,
          plantName:      data['PlantName'] as String?,
          imagePath:      data['ImagePath'] as String?,
          growthStage:    growthStage.clamp(0, 5),
          lastWatered:    (data['LastWatered']    as Timestamp?)?.toDate(),
          lastFertilized: (data['LastFertilized'] as Timestamp?)?.toDate(),
          isMastered:     isMastered,
          canFertilize:   data['LastWatered'] != null && growthStage >= 1,
        );
      }
    } catch (e) {
      print('Error loading garden: $e');
    }

    return plots;
  }

  Future<List<SeedItem>> loadUserSeeds(String userId) async {
    try {
      final snapshot = await _db
          .collection('UserSeeds')
          .where('UserId',    isEqualTo: userId)
          .where('IsPlanted', isEqualTo: false)
          .get();

      final seeds = snapshot.docs.map((doc) {
        final data = doc.data();
        return SeedItem(
          setId:      data['SetId']     as String? ?? '',
          title:      data['PlantName'] as String? ?? '',
          totalCards: 0,
          difficulty: 'Easy',
          imagePath:  data['ImagePath'] as String?,
          seedDocId:  doc.id,
        );
      }).toList();

      final enriched = await Future.wait(seeds.map((seed) async {
        try {
          final setDoc = await _db
              .collection('FlashcardSets')
              .doc(seed.setId)
              .get();

          final totalCards = (setDoc.data()?['TotalCards'] as int?) ?? 0;
          final setTitle   = setDoc.data()?['Title'] as String?;

          return SeedItem(
            setId:      seed.setId,
            title:      setTitle ?? seed.title,
            totalCards: totalCards,
            difficulty: 'Easy',
            imagePath:  seed.imagePath,
            seedDocId:  seed.seedDocId,
          );
        } catch (_) {
          return seed;
        }
      }));

      return enriched;
    } catch (e) {
      print('loadUserSeeds error: $e');
      return [];
    }
  }

  Future<void> markSeedAsPlanted(String userId, String setId) async {
    try {
      final snapshot = await _db
          .collection('UserSeeds')
          .where('UserId',    isEqualTo: userId)
          .where('SetId',     isEqualTo: setId)
          .where('IsPlanted', isEqualTo: false)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update({'IsPlanted': true});
      }
    } catch (e) {
      print('Error marking seed as planted: $e');
    }
  }

  Future<void> waterTree(String treeId) async {
    try {
      await _db.collection('WordGardenTrees').doc(treeId).update({
        'LastWatered': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error watering tree: $e');
    }
  }

  Future<void> updateGrowthStage({
    required String treeId,
    required int stage,
  }) async {
    try {
      await _db.collection('WordGardenTrees').doc(treeId).update({
        'GrowthStage':    stage,
        'LastFertilized': FieldValue.serverTimestamp(),
        if (stage >= 5) 'IsMastered': true,
      });
    } catch (e) {
      print('updateGrowthStage error: $e');
    }
  }

  Future<Set<String>> loadUnlockedPlantNames(String userId) async {
    try {
      final snapshot = await _db
          .collection('UserSeeds')
          .where('UserId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['PlantName'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .toSet();
    } catch (e) {
      print('loadUnlockedPlantNames error: $e');
      return {};
    }
  }

  Future<List<SeedItem>> loadAllUserSeeds(String userId) async {
    try {
      final snapshot = await _db
          .collection('UserSeeds')
          .where('UserId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return SeedItem(
          setId:          data['SetId']     as String? ?? '',
          title:          data['PlantName'] as String? ?? '',
          totalCards:     0,
          difficulty:     'Easy',
          imagePath:      data['ImagePath'] as String?,
          seedDocId:      doc.id,
          alreadyPlanted: (data['IsPlanted'] as bool?) ?? false,
        );
      }).toList();
    } catch (e) {
      print('loadAllUserSeeds error: $e');
      return [];
    }
  }

  Future<Map<String, int>> loadUserResources(String userId) async {
    try {
      final doc  = await _db.collection('users').doc(userId).get();
      final data = doc.data() ?? {};
      return {
        'water':      (data['waterCount']      as int?) ?? 0,
        'fertilizer': (data['fertilizerCount'] as int?) ?? 0,
        'stars':      (data['stars']           as int?) ?? 0,
      };
    } catch (e) {
      print('loadUserResources error: $e');
      return {'water': 0, 'fertilizer': 0, 'stars': 0};
    }
  }

  Future<void> deductResource({
    required String userId,
    required String type,
  }) async {
    try {
      final field = type == 'water' ? 'waterCount' : 'fertilizerCount';
      await _db.collection('users').doc(userId).update({
        field: FieldValue.increment(-1),
      });
    } catch (e) {
      print('deductResource error: $e');
    }
  }

  Future<void> harvestTree({
    required String userId,
    required String treeId,
    required String plantName,
    required String imagePath,
    required String setId,  
  }) async {
    try {
      final batch = _db.batch();

      batch.delete(_db.collection('WordGardenTrees').doc(treeId));

      final harvestDoc = _db.collection('HarvestedPlants').doc();
      batch.set(harvestDoc, {
        'HarvestId':  harvestDoc.id,
        'UserId':     userId,
        'PlantName':  plantName,
        'ImagePath':  imagePath,
        'SetId':       setId,  
        'HarvestedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      print('Harvested $plantName');
    } catch (e) {
      print('harvestTree error: $e');
    }
  }

  Future<Set<String>> loadHarvestedPlantNames(String userId) async {
    try {
      final snapshot = await _db
          .collection('HarvestedPlants')
          .where('UserId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['PlantName'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .toSet();
    } catch (e) {
      print('loadHarvestedPlantNames error: $e');
      return {};
    }
  }
}