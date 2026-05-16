// lib/features/game/data/shop_data.dart
import 'package:flashcard_app/features/game/models/garden_models.dart';
import 'package:flashcard_app/features/game/screens/shop_game_screen.dart';

// Catalog thuần — tất cả locked mặc định
// Trạng thái unlock được tính runtime từ UserSeeds
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
    isLocked: true,
    price: 80,
    requiredSetId: 'set_basic_flowers',
    requiredSetTitle: 'Basic Flowers',
  ),
  ShopItem(
    imagePath: 'assets/game/Frangipani.png',
    name: 'Purple Frangipani',
    isLocked: true,
    price: 90,
    requiredSetId: 'set_garden_vocab',
    requiredSetTitle: 'Garden Vocabulary',
  ),
  ShopItem(
    imagePath: 'assets/game/lotus.png',
    name: 'White Lotus',
    isLocked: true,
    price: 110,
    requiredSetId: 'set_water_plants',
    requiredSetTitle: 'Aquatic Plants',
  ),
  ShopItem(
    imagePath: 'assets/game/Plumeria.png',
    name: 'Red Plumeria',
    isLocked: true,
    price: 95,
    requiredSetId: 'set_color_adjectives',
    requiredSetTitle: 'Color Adjectives',
  ),
  ShopItem(
    imagePath: 'assets/game/rose.png',
    name: 'Golden Rose',
    isLocked: true,
    price: 130,
    requiredSetId: 'set_emotions_vocab',
    requiredSetTitle: 'Emotion Vocabulary',
  ),
  ShopItem(
    imagePath: 'assets/game/tulip.png',
    name: 'Purple Tulip',
    isLocked: true,
    price: 85,
    requiredSetId: 'set_spring_vocab',
    requiredSetTitle: 'Spring Vocabulary',
  ),
  ShopItem(
    imagePath: 'assets/game/sunFlower.png',
    name: 'Sunflower Yellow',
    isLocked: true,
    price: 75,
    requiredSetId: 'set_daily_vocab',
    requiredSetTitle: 'Daily Vocabulary',
  ),
];