
import "color.dart";
import "tile_animation.dart";

enum TileState {
  unexploredRoom,
  frontierRoom,
  exploredRoom,
  wall,
  passage
}

class Tile {

  static const colorsByState = {
    TileState.unexploredRoom: Color(161.0, 64.0, 210.0),
    TileState.frontierRoom: Color(253.0, 213.0, 0.0),
    TileState.exploredRoom: Color(10.0, 12.0, 1.0),
    TileState.wall: Color(141.0, 37.0, 199.0),
    TileState.passage: Color(10.0, 12.0, 1.0)
  };

  TileState _state;

  final int xIndex;
  final int yIndex;

  int red = 0;
  int green = 0;
  int blue = 0;

  TileAnimation _animation;

  Tile(this.xIndex, this.yIndex) {
    state = TileState.wall;
  }

  void set color(Color value) {
    red = value.red;
    green = value.green;
    blue = value.blue;
  }

  void set state(TileState value) {
    _state = value;
    color = colorsByState[value];
  }

  void get state => _state;

  bool get isAnimating => _animation != null;

  void updateAnimation(double time) {
    if (isAnimating) {

      if (_animation.startTime == null) {
        _animation.startTime = time;
      }

      color = _animation.colorAtTime(time);

      if (time >= _animation.endTime) {
        _animation = null;
      }
    }
  }

  void _animate(Color startColor, Color endColor, double duration) {
    _animation = new TileAnimation(startColor, endColor, duration);
  }

  void animateToState(TileState destinationState, {double duration = 150.0}) {
    var startColor = colorsByState[_state];
    var endColor = colorsByState[destinationState];
    _animate(startColor, endColor, duration);

    _state = destinationState;
  }

}