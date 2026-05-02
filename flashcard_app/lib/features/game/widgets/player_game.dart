import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class PlayerGame extends FlameGame {
  @override
  Color backgroundColor() => Colors.transparent;

  late SpriteAnimationComponent _player;
  late _BounceEffect _bounceController;

  void jump() => _bounceController.triggerBounce();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    images.prefix = 'assets/';
    final image = await images.load('game/player/idle/player_idle.png');

    const frameW        = 186.0;
    const frameH        = 177.0;
    const frame5OffsetX = 808.0;
    const frame5W       = 202.0;

    final frames = [
      SpriteAnimationFrame(Sprite(image, srcPosition: Vector2(0, 0),             srcSize: Vector2(frameW, frameH)),  1.4),
      SpriteAnimationFrame(Sprite(image, srcPosition: Vector2(frameW, 0),        srcSize: Vector2(frameW, frameH)),  1.4),
      SpriteAnimationFrame(Sprite(image, srcPosition: Vector2(frameW * 2, 0),    srcSize: Vector2(frameW, frameH)),  1.4),
      SpriteAnimationFrame(Sprite(image, srcPosition: Vector2(frameW * 3, 0),    srcSize: Vector2(frameW, frameH)),  1.4),
      SpriteAnimationFrame(Sprite(image, srcPosition: Vector2(frame5OffsetX, 0), srcSize: Vector2(frame5W, frameH)), 1.4),
    ];

    const displayH = 110.0;
    const displayW = frame5W / frameH * displayH;
    final posX     = size.x / 2 + 10;
    final posY     = size.y - displayH / 2 + 15;

    _bounceController = _BounceEffect(baseX: posX, baseY: posY);

    _player = SpriteAnimationComponent(
      animation: SpriteAnimation(frames, loop: true),
      size:      Vector2(displayW, displayH),
      anchor:    Anchor.center,
      position:  Vector2(posX, posY),
    );

    _player.add(_bounceController);
    add(_player);
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _BounceEffect extends Component with HasGameRef {
  final double baseX;
  final double baseY;

  // ── Physics ───────────────────────────────────────────────────────────────
  static const double _jumpForce = -320.0;
  static const double _gravity   = 850.0;
  static const double _maxJump   = 70.0;

  double _vy      = 0;
  double _offsetY = 0;
  bool   _jumping = false;

  // ── Squash & Stretch ──────────────────────────────────────────────────────
  double _scaleX = 1.0;
  double _scaleY = 1.0;

  // ── Idle bob ──────────────────────────────────────────────────────────────
  double _idleTime = 0;
  static const double _bobAmp   = 1.8; // nhẹ hơn, trông tự nhiên hơn
  static const double _bobSpeed = 0.9; // chậm hơn, như thở

  _BounceEffect({required this.baseX, required this.baseY});

  void triggerBounce() {
    if (_jumping) return;
    _vy      = _jumpForce;
    _jumping = true;
    // Squash ngang khi bắt đầu bật
    _scaleX = 1.25;
    _scaleY = 0.78;
  }

  @override
  void update(double dt) {
    if (parent is! PositionComponent) return;
    final p = parent as PositionComponent;

    if (_jumping) {
      _vy      += _gravity * dt;
      _offsetY += _vy * dt;

      if (_offsetY < -_maxJump) {
        _offsetY = -_maxJump;
        _vy      = 0;
      }

      // Bay lên → kéo dài dọc
      if (_vy < 0) {
        _scaleX = _lerp(_scaleX, 0.88, dt * 14);
        _scaleY = _lerp(_scaleY, 1.18, dt * 14);
      }
      // Rơi xuống → thu về bình thường
      else {
        _scaleX = _lerp(_scaleX, 1.0, dt * 10);
        _scaleY = _lerp(_scaleY, 1.0, dt * 10);
      }

      // Chạm đất → squash dọc rồi bật về
      if (_offsetY >= 0) {
        _offsetY = 0;
        _vy      = 0;
        _jumping = false;
        _scaleX  = 1.28;
        _scaleY  = 0.72;
      }

    } else {
      // ── Idle: thở nhẹ lên xuống ───────────────────────────────────────
      _idleTime += dt;
      _offsetY   = sin(_idleTime * _bobSpeed * pi * 2) * _bobAmp;

      // Phục hồi scale mượt sau squash
      _scaleX = _lerp(_scaleX, 1.0, dt * 16);
      _scaleY = _lerp(_scaleY, 1.0, dt * 16);
    }

    p.position.x = baseX;
    p.position.y = baseY + _offsetY;
    p.scale      = Vector2(_scaleX, _scaleY);
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t.clamp(0.0, 1.0);
}