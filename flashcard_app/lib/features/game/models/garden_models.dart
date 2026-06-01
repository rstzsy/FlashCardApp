// lib/features/game/models/garden_models.dart

import 'package:flutter/material.dart';

enum PlotStatus { empty, planted, mastered }

/// Max hours before a tree "needs watering" per growth stage
const List<int> kWaterIntervalHours = [6, 12, 18, 24, 36, 0]; // stage 5 = mastered, no watering needed

class GardenPlot {
  final int plotIndex;
  PlotStatus status;
  String? treeId;
  String? setId;
  String? setTitle;
  String? plantName;   // ← THÊM
  String? imagePath;   // ← THÊM
  int growthStage;
  DateTime? lastWatered;
  DateTime? lastFertilized;
  bool isMastered;
  bool canFertilize;     // watered at least once and stage >= 1
  bool wateredAtCurrentStage;

  GardenPlot({
    required this.plotIndex,
    this.status = PlotStatus.empty,
    this.treeId,
    this.setId,
    this.setTitle,
    this.plantName,    // ← THÊM
    this.imagePath,    // ← THÊM
    this.growthStage = 0,
    this.lastWatered,
    this.lastFertilized,
    this.isMastered = false,
    this.canFertilize = false,
    this.wateredAtCurrentStage = false,
  });

  /// Does the tree need watering? (based on time elapsed since last watering)
  bool get needsWater {
    if (status != PlotStatus.planted) return false;
    if (growthStage >= 5) return false;
    if (lastWatered == null) return true;
    final hours = kWaterIntervalHours[growthStage];
    return DateTime.now().difference(lastWatered!).inHours >= hours;
  }

  /// Progress % within the current stage (used for small progress bar)
  double get stageProgress {
    if (status == PlotStatus.empty) return 0;
    return growthStage / 5.0;
  }

  GardenPlot copyWith({
    PlotStatus? status,
    int? growthStage,
    String? treeId,
    String? setId,
    String? setTitle,
    String? plantName,
    String? imagePath,
    DateTime? lastWatered,
    bool? isMastered,
    bool? canFertilize,
    bool? wateredAtCurrentStage,
  }) => GardenPlot(
    plotIndex:    plotIndex,
    status:       status       ?? this.status,
    growthStage:  growthStage  ?? this.growthStage,
    treeId:       treeId       ?? this.treeId,
    setId:        setId        ?? this.setId,
    setTitle:     setTitle     ?? this.setTitle,
    plantName:    plantName    ?? this.plantName,
    imagePath:    imagePath    ?? this.imagePath,
    lastWatered:  lastWatered  ?? this.lastWatered,
    isMastered:   isMastered   ?? this.isMastered,
    canFertilize: canFertilize ?? this.canFertilize,
    wateredAtCurrentStage: wateredAtCurrentStage ?? this.wateredAtCurrentStage,
  );
}

class SeedItem {
  final String  setId;
  final String  title;
  final String? subtitle;
  final int     totalCards;
  final String  difficulty;
  final bool    alreadyPlanted;
  final String? imagePath;
  final String? seedDocId; // ← THÊM: Firestore document ID của UserSeeds

  const SeedItem({
    required this.setId,
    required this.title,
    this.subtitle,
    required this.totalCards,
    required this.difficulty,
    this.alreadyPlanted = false,
    this.imagePath,
    this.seedDocId,      // ← THÊM
  });


  String get difficultyLabel {
    switch (difficulty) {
      case 'Easy':
        return 'Easy';
      case 'Medium':
        return 'Medium';
      case 'Hard':
        return 'Hard';
      default:
        return difficulty;
    }
  }

  Color get difficultyColor {
    switch (difficulty) {
      case 'Easy':
        return const Color(0xFF4CAF50);
      case 'Medium':
        return const Color(0xFFFF9800);
      case 'Hard':
        return const Color(0xFFE53935);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}

/// Growth stage names
const List<String> kStageNames = [
  'Seed', 'Sprout', 'Seedling', 'Sapling', 'Flowering', 'Fruiting',
];

const List<String> kStageEmoji = ['🌰','🌱','🌿','🪴','🌸','🍎'];

