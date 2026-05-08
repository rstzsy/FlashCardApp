// lib/features/game/data/shop_data.dart
//
// Source of truth duy nhất cho tất cả cây trong game.
// ShopGameScreen và HomeGameScreen đều lấy data từ đây.

import 'package:flashcard_app/features/game/models/garden_models.dart';
import 'package:flashcard_app/features/game/screens/shop_game_screen.dart';

const List<ShopItem> kShopItems = [
  ShopItem(
    imagePath: 'assets/game/Frangipani.png',
    name: 'White Frangipani',
    isLocked: true,
    price: 120,
    requiredSetId: 'set_flowers_advanced',
    requiredSetTitle: 'Advanced Flowers & Plants',
  ),
  ShopItem(
    imagePath: 'assets/game/lotus.png',
    name: 'Pink Lotus',
    isLocked: true,
    price: 200,
    requiredSetId: 'set_nature_master',
    requiredSetTitle: 'Nature – Master Level',
  ),
  ShopItem(
    imagePath: 'assets/game/Plumeria.png',
    name: 'Golden Plumeria',
    isLocked: true,
    price: 150,
    requiredSetId: 'set_tropical_plants',
    requiredSetTitle: 'Tropical Plants',
  ),
  ShopItem(
    imagePath: 'assets/game/rose.png',
    name: 'Rose',
    isLocked: true,
    price: 180,
    requiredSetId: 'set_romance_vocab',
    requiredSetTitle: 'Romantic Vocabulary',
  ),
  ShopItem(
    imagePath: 'assets/game/sunFlower.png',
    name: 'Sunflower',
    isLocked: true,
    price: 100,
    requiredSetId: 'set_weather_nature',
    requiredSetTitle: 'Weather & Nature',
  ),
  ShopItem(
    imagePath: 'assets/game/tulip.png',
    name: 'Tulip',
    isLocked: false,
    price: 80,
    requiredSetId: 'set_basic_flowers',
    requiredSetTitle: 'Basic Flowers',
    linkedSeed: SeedItem(
      setId: 'set_basic_flowers',
      title: 'Basic Flowers',
      subtitle: 'Tulip, Rose, Daisy...',
      totalCards: 24,
      difficulty: 'Easy',
      imagePath: 'assets/game/tulip.png',
    ),
  ),
  ShopItem(
    imagePath: 'assets/game/Frangipani.png',
    name: 'Purple Frangipani',
    isLocked: false,
    price: 90,
    requiredSetId: 'set_garden_vocab',
    requiredSetTitle: 'Garden Vocabulary',
    linkedSeed: SeedItem(
      setId: 'set_garden_vocab',
      title: 'Garden Vocabulary',
      subtitle: 'Plants, flowers, soil...',
      totalCards: 32,
      difficulty: 'Easy',
      imagePath: 'assets/game/Frangipani.png',
    ),
  ),
  ShopItem(
    imagePath: 'assets/game/lotus.png',
    name: 'White Lotus',
    isLocked: false,
    price: 110,
    requiredSetId: 'set_water_plants',
    requiredSetTitle: 'Aquatic Plants',
    linkedSeed: SeedItem(
      setId: 'set_water_plants',
      title: 'Aquatic Plants',
      subtitle: 'Lotus, water lily...',
      totalCards: 18,
      difficulty: 'Medium',
      imagePath: 'assets/game/lotus.png',
    ),
  ),
  ShopItem(
    imagePath: 'assets/game/Plumeria.png',
    name: 'Red Plumeria',
    isLocked: false,
    price: 95,
    requiredSetId: 'set_color_adjectives',
    requiredSetTitle: 'Color Adjectives',
    linkedSeed: SeedItem(
      setId: 'set_color_adjectives',
      title: 'Color Adjectives',
      subtitle: 'Scarlet, crimson...',
      totalCards: 28,
      difficulty: 'Medium',
      imagePath: 'assets/game/Plumeria.png',
    ),
  ),
  ShopItem(
    imagePath: 'assets/game/rose.png',
    name: 'Golden Rose',
    isLocked: false,
    price: 130,
    requiredSetId: 'set_emotions_vocab',
    requiredSetTitle: 'Emotion Vocabulary',
    linkedSeed: SeedItem(
      setId: 'set_emotions_vocab',
      title: 'Emotion Vocabulary',
      subtitle: 'Joy, melancholy...',
      totalCards: 40,
      difficulty: 'Hard',
      imagePath: 'assets/game/rose.png',
    ),
  ),
  ShopItem(
    imagePath: 'assets/game/tulip.png',
    name: 'Purple Tulip',
    isLocked: false,
    price: 85,
    requiredSetId: 'set_spring_vocab',
    requiredSetTitle: 'Spring Vocabulary',
    linkedSeed: SeedItem(
      setId: 'set_spring_vocab',
      title: 'Spring Vocabulary',
      subtitle: 'Bloom, blossom...',
      totalCards: 22,
      difficulty: 'Easy',
      imagePath: 'assets/game/tulip.png',
    ),
  ),
  ShopItem(
    imagePath: 'assets/game/plant.png',
    name: 'Exotic Plant',
    isLocked: false,
    price: 60,
    requiredSetId: 'set_exotic_plants',
    requiredSetTitle: 'World Exotic Plants',
  ),
];

/// Lấy tất cả SeedItem từ shop items đã unlock có linkedSeed.
/// Dùng trong HomeGameScreen thay cho hardcode _availableSeeds.
List<SeedItem> unlockedSeeds() {
  return kShopItems
      .where((item) => !item.isLocked && item.linkedSeed != null)
      .map((item) => item.linkedSeed!)
      .toList();
}