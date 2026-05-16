import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class WordGardenService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const List<Map<String, String>> _availablePlants = [
    {'imagePath': 'assets/game/Frangipani.png', 'name': 'White Frangipani'},
    {'imagePath': 'assets/game/lotus.png',      'name': 'Pink Lotus'},
    {'imagePath': 'assets/game/Plumeria.png',   'name': 'Golden Plumeria'},
    {'imagePath': 'assets/game/rose.png',       'name': 'Rose'},
    {'imagePath': 'assets/game/sunFlower.png',  'name': 'Sunflower'},
    {'imagePath': 'assets/game/tulip.png',      'name': 'Tulip'},
    {'imagePath': 'assets/game/Frangipani.png', 'name': 'Purple Frangipani'},
    {'imagePath': 'assets/game/lotus.png',      'name': 'White Lotus'},
    {'imagePath': 'assets/game/Plumeria.png',   'name': 'Red Plumeria'},
    {'imagePath': 'assets/game/rose.png',       'name': 'Golden Rose'},
    {'imagePath': 'assets/game/tulip.png',      'name': 'Purple Tulip'},
  ];

  Future<Map<String, String>?> createRandomSeed({
    required String userId,
    required String setId,
  }) async {
    try {
      final existing = await _firestore
          .collection('UserSeeds')
          .where('UserId', isEqualTo: userId)
          .where('SetId',  isEqualTo: setId)
          .get();

      if (existing.docs.isNotEmpty) {
        print('Seed already exists for setId: $setId');
        return null;
      }

      final plant = _availablePlants[Random().nextInt(_availablePlants.length)];

      final batch = _firestore.batch();

      final seedDoc = _firestore.collection('UserSeeds').doc();
      batch.set(seedDoc, {
        'SeedId':     seedDoc.id,
        'UserId':     userId,
        'SetId':      setId,
        'PlantName':  plant['name'],
        'ImagePath':  plant['imagePath'],
        'IsPlanted':  false,
        'ReceivedAt': FieldValue.serverTimestamp(),
      });

      final userRef = _firestore.collection('users').doc(userId);
      batch.update(userRef, {'plants': FieldValue.increment(1)});

      await batch.commit();
      print('Seed saved to tray: ${plant['name']}');
      return plant;
    } catch (e) {
      print('Error creating seed: $e');
      return null;
    }
  }

  Future<void> plantSeedToPlot({
    required String userId,
    required String setId,
    required String plantName,
    required String imagePath,
    required String seedDocId,
    required int plotIndex,        
  }) async {
    try {
      final batch = _firestore.batch();

      final treeDoc = _firestore.collection('WordGardenTrees').doc();
      batch.set(treeDoc, {
        'TreeId':         treeDoc.id,
        'UserId':         userId,
        'SetId':          setId,
        'PlantName':      plantName,
        'ImagePath':      imagePath,
        'PlotIndex':      plotIndex,   
        'GrowthStage':    0,
        'LastWatered':    null,
        'LastFertilized': null,
        'IsMastered':     false,
        'CreatedAt':      FieldValue.serverTimestamp(),
      });

      final seedRef = _firestore.collection('UserSeeds').doc(seedDocId);
      batch.update(seedRef, {'IsPlanted': true});

      await batch.commit();
      print('Planted $plantName to plot $plotIndex');
    } catch (e) {
      print('Error planting seed: $e');
    }
  }
}