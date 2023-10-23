import 'dart:async';

import 'package:dino02/components/ground.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flame/components.dart';

import 'package:dino02/components/character.dart';
import 'package:dino02/utils/create_animation_by_limit.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/src/services/raw_keyboard.dart';

class PlayerBody extends BodyComponent with KeyboardHandler, ContactCallbacks {
  // sprite
  late PlayerComponent playerComponent;

  bool _inGround = false;

  //*** mobility
  Vector2 _playerMove = Vector2.all(0);
  final double _playerNormalVelocity = 15.0;
  final double _playerNormalJump = -25.0;

  //*** double jump
  final double _timeToDoubleJump = .5;
  double _elapseTimeToDoubleJump = 0;
  bool _doubleJump = false;

  // impulse
  final double _playerNormalImpulse = 2000.0;

  // state
  MovementType movementType = MovementType.idle;

  PlayerBody();

  @override
  Future<void> onLoad() {
    // renderBody = false;
    playerComponent = PlayerComponent();
    add(playerComponent);
    return super.onLoad();
  }

  @override
  Body createBody() {
    final position = Vector2.all(15);
    final shape = PolygonShape()..setAsBoxXY(3, 5);
    final bodyDef =
        BodyDef(position: position, type: BodyType.dynamic, userData: this);
    final fixtureDef =
        FixtureDef(shape, friction: 0, density: 0, restitution: 0);

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (keysPressed.isEmpty) {
      if (_inGround) movementType = MovementType.idle;
      _playerMove = Vector2.all(0);
      body.linearVelocity = Vector2.all(0);
    }

    // RIGHT
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD)) {
      if (keysPressed.contains(LogicalKeyboardKey.shiftLeft)) {
        // RUN
        if (movementType != MovementType.jump &&
            movementType != MovementType.fall) {
          movementType = MovementType.runright;
        }

        _playerMove.x = _playerNormalVelocity * 3;
      } else {
        //WALK
        if (movementType != MovementType.jump &&
            movementType != MovementType.fall) {
          movementType = MovementType.walkingright;
        }
        _playerMove.x = _playerNormalVelocity;
      }
    }
    // LEFT
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA)) {
      if (keysPressed.contains(LogicalKeyboardKey.shiftLeft)) {
        // RUN
        if (movementType != MovementType.jump &&
            movementType != MovementType.fall) {
          movementType = MovementType.runleft;
        }
        _playerMove.x = -_playerNormalVelocity * 3;
      } else {
        //WALK
        if (movementType != MovementType.jump &&
            movementType != MovementType.fall) {
          movementType = MovementType.walkingleft;
        }
        _playerMove.x = -_playerNormalVelocity;
      }
    }

    // JUMP
    if (keysPressed.contains((LogicalKeyboardKey.space))) {
      movementType = MovementType.jump;
      if (_inGround) {
        _playerMove.y = _playerNormalJump;
      } else if (_elapseTimeToDoubleJump >= _timeToDoubleJump && !_doubleJump) {
        // in the air
        // el usuario presiono la tecla para un doble salto
        // paso el tiempo en el cual se puede usar el doble salto
        // double jump active
        _doubleJump = true;
        _playerMove.y = _playerNormalJump;
      } else {
        // reset the jump
        _playerMove = Vector2.all(0);
      }
    }

    // IMPULSE
    if (keysPressed.contains(LogicalKeyboardKey.keyC)) {
      _playerMove.x *= _playerNormalImpulse;
    }

    playerComponent.setMode(movementType);
    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void update(double dt) {
    body.setTransform(body.position, 0);

    // *** double jump
    if (movementType == MovementType.jump ||
        movementType == MovementType.fall) {
      // if the player is in the air
      _elapseTimeToDoubleJump += dt;
    } else {
      // reset the properties to double jump
      _elapseTimeToDoubleJump = 0;
      _doubleJump = false;
    }

    // *** linearVelocity
    if (_playerMove != Vector2.all(0)) {
      if (body.linearVelocity.y.abs() > 0.1 && _playerMove.y == 0) {
        body.linearVelocity.x = _playerMove.x;
      } else {
        body.linearVelocity = _playerMove;
      }
    }

    // *** MovementType
    if (body.linearVelocity.y > 0.1 && movementType == MovementType.jump) {
      movementType = MovementType.fall;
      playerComponent.setMode(movementType);
    } else if (body.linearVelocity.y == 0 &&
        movementType == MovementType.fall) {
      // si el player esta en el aire, cayendo al entrar en contacto
      // con el piso, tiene velocidad cero, se coloca en reposo
      // si no queda con la animacion de saltando
      // if the player is in the air, falling upon contact
      // with the floor, it has zero speed, it is placed at rest
      // if it doesn't stay with the jumping animation
      movementType = MovementType.idle;

      movementType = MovementType.idle;
      playerComponent.setMode(movementType);
    }
    // print(movementType.toString());

    super.update(dt);
  }

  // *** contatcs
  @override
  void beginContact(Object other, Contact contact) {
    if (other is GroundBody) {
      _inGround = true;
    }
    super.beginContact(other, contact);
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is GroundBody) {
      _inGround = false;
    }
    super.endContact(other, contact);
  }
}

class PlayerComponent extends Character {
  PlayerComponent() : super() {
    anchor = Anchor.center;
    size = Vector2(spriteSheetWidth / 40, spriteSheetHeight / 40);
  }

  setMode(MovementType movementType) {
    switch (movementType) {
      case MovementType.idle:
        animation = idleAnimation;
        break;
      case MovementType.walkingleft:
        if (right) flipHorizontally();
        right = false;
        animation = walkAnimation;
        break;
      case MovementType.runleft:
        if (right) flipHorizontally();
        right = false;
        animation = runAnimation;
        break;
      case MovementType.walkingright:
        if (!right) flipHorizontally();
        right = true;
        animation = walkAnimation;
        break;
      case MovementType.runright:
        if (!right) flipHorizontally();
        right = true;
        animation = runAnimation;
        break;
      case MovementType.jump:
      case MovementType.fall:
        animation = jumpAnimation;
        break;
    }
  }

  @override
  FutureOr<void> onLoad() async {
    final spriteImage = await Flame.images.load('dinofull.png');
    final spriteSheet = SpriteSheet(
        image: spriteImage,
        srcSize: Vector2(spriteSheetWidth, spriteSheetHeight));

    // init animation
    deadAnimation = spriteSheet.createAnimationByLimit(
        xInit: 0, yInit: 0, step: 8, sizeX: 5, stepTime: .08, loop: false);
    idleAnimation = spriteSheet.createAnimationByLimit(
        xInit: 1, yInit: 2, step: 10, sizeX: 5, stepTime: .08);
    jumpAnimation = spriteSheet.createAnimationByLimit(
        xInit: 3, yInit: 0, step: 12, sizeX: 5, stepTime: .08, loop: false);
    runAnimation = spriteSheet.createAnimationByLimit(
        xInit: 5, yInit: 0, step: 8, sizeX: 5, stepTime: .08);
    walkAnimation = spriteSheet.createAnimationByLimit(
        xInit: 6, yInit: 2, step: 10, sizeX: 5, stepTime: .08);
    // end animation

    animation = idleAnimation;

    return super.onLoad();
  }
}
