import 'dart:async';

import 'package:dino02/components/character.dart';
import 'package:dino02/components/ground.dart';
import 'package:dino02/components/player.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(GameWidget(game: MyGame()));
}

class MyGame extends Forge2DGame with HasKeyboardHandlerComponents {
  late PlayerBody _playerBody;

  MyGame() : super(gravity: Vector2(0, 40), zoom: 10);

  @override
  FutureOr<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
    // camera.viewfinder.anchor = const Anchor(.2, .2);
    _playerBody = PlayerBody();

    world.add(_playerBody);

    await _tile();

    _playerBody.loaded.then((value) {
      _playerBody.playerComponent.loaded.then((value) {
        camera.follow(_playerBody);
        camera.viewfinder.anchor = Anchor.center;
      });
    });

    world.physicsWorld.setContactFilter(CustomContactFilter(_playerBody));

    // camera.viewfinder.anchor = Anchor.topLeft;

    // _playerBody = PlayerBody();
    // world.add(_playerBody);

    // _playerBody.loaded.then((value) {
    //   _playerBody.playerComponent.loaded.then((value) {
    //     camera.follow(_playerBody);
    //     camera.viewfinder.anchor = Anchor.center;
    //   });
    // });

    return super.onLoad();
  }

  _tile() async {
    final tiledMap = await TiledComponent.load('map3.tmx', Vector2.all(32));

    final objGroup = tiledMap.tileMap.getLayer<ObjectGroup>('ground');

    for (var obj in objGroup!.objects) {
      //*** BOX
      // world.add(GroundBody(
      //     size: screenToWorld(Vector2(obj.width / 2, obj.height / 2)),
      //     pos: screenToWorld(
      //         Vector2(obj.x + (obj.width / 2), obj.y + (obj.height / 2)))));

      //*** LINE
      world.add(GroundBody(
          size: screenToWorld(Vector2(obj.width, obj.height)),
          pos: screenToWorld(Vector2(obj.x, obj.y))));
    }
    tiledMap.scale = Vector2.all(.1);
    world.add(tiledMap);
  }
}

class CustomContactFilter implements ContactFilter {
  final PlayerBody _playerBody;

  CustomContactFilter(this._playerBody);

  @override
  bool shouldCollide(Fixture fixtureA, Fixture fixtureB) {
    if (fixtureA.body.userData is PlayerBody &&
        fixtureB.body.userData is GroundBody &&
        _playerBody.movementType == MovementType.jump) {
      return false;
    }
    return true;
  }
}
