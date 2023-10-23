import 'package:flame_forge2d/flame_forge2d.dart';

class GroundBody extends BodyComponent {
  final Vector2 pos;
  final Vector2 size;

  GroundBody({required this.size, required this.pos}) : super() {
    // renderBody =false;
  }

  @override
  Body createBody() {
    //*** BOX
    // final shape = PolygonShape()..setAsBoxXY(size.x, size.y);
    // final bodyDef =
    //     BodyDef(position: pos, type: BodyType.static, userData: this);

    //*** LINE
    final shape = EdgeShape()..set(pos, Vector2(pos.x + size.x, pos.y));
    BodyDef bodyDef = BodyDef(
        userData: this, position: Vector2.zero(), type: BodyType.static);

    final fixtureDef =
        FixtureDef(shape, density: 0, friction: 0, restitution: 0);

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
