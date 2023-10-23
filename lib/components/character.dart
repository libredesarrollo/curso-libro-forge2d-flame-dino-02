import 'package:flame/components.dart';

enum MovementType {
  walkingright,
  walkingleft,
  runright,
  runleft,
  idle,
  jump,
  fall
}

class Character extends SpriteAnimationComponent {
  MovementType movementType = MovementType.idle;

  final double spriteSheetWidth = 680;
  final double spriteSheetHeight = 472;

  bool inGround = false;
  bool right = true;

  late SpriteAnimation deadAnimation,
      idleAnimation,
      jumpAnimation,
      runAnimation,
      walkAnimation;
}
