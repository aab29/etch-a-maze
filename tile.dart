
import "color.dart";
import "tile_animation.dart";

enum TileState {
  outerTile,
  unexploredRoom,
  frontierRoom,
  exploredRoom,
  wall,
  passage
}

class Tile {

  static const colorsByState = {
    TileState.outerTile: Color(70.0, 0.0, 90.0),
    TileState.unexploredRoom: Color(0.0, 29.0, 156.0),
    TileState.frontierRoom: Color(0.0, 255.0, 0.0),
    TileState.exploredRoom: Color(0.0, 0.0, 0.0),
    TileState.wall: Color(0.0, 0.0, 255.0),
    TileState.passage: Color(0.0, 0.0, 0.0)
  };

  TileState state;

  final int xIndex;
  final int yIndex;

  int red = 0;
  int green = 0;
  int blue = 0;

  TileAnimation _animation;

  Tile(this.xIndex, this.yIndex, this.state) {
    var color = colorsByState[state];
    red = color.red;
    green = color.green;
    blue = color.blue;
  }

  void updateAnimation(double time) {
    if (_animation != null) {
      var color = _animation.colorAtTime(time);
      red = color.red;
      green = color.green;
      blue = color.blue;

      if (time >= _animation.endTime) {
        _animation = null;
      }
    }
  }

  void animate(Color startColor, Color endColor, double startTime, double duration) {
    _animation = new TileAnimation(startColor, endColor, startTime, duration);
  }

}