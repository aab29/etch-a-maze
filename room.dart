
import "tile.dart";
import "link.dart";
import "direction.dart";

enum RoomState {
  unexplored,
  frontier,
  explored
}

class Room {

  final int xIndex;
  final int yIndex;

  final Tile tile;

  RoomState state = RoomState.unexplored;

  List<Link> _links = List(Direction.values.length);

  Room(this.xIndex, this.yIndex, this.tile);

  void assignLink(Direction direction, Link link) {
    _links[direction.index] = link;
  }

  Room neighborAt(Direction direction) {
    return _links[direction.index]?.oppositeRoom(this);
  }

  List<Room> get neighbors {
    var neighbors = [];
    for (var link in _links) {
      if (link != null) {
        neighbors.add(link.oppositeRoom(this));
      }
    }
    return neighbors;
  }

}