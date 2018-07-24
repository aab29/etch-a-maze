
import "maze.dart";
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

  Tile tile;

  RoomState state = RoomState.unexplored;

  List<Link> _links = List(Direction.values.length);

  Room(this.xIndex, this.yIndex);

  void assignLink(Direction direction, Link link) {
    _links[direction.index] = link;
  }

  Link buildLinkToNeighbor(Room neighbor, Direction directionToNeighbor) {
    var link = new Link(this, neighbor);
    assignLink(directionToNeighbor, link);

    var opposite = oppositeDirections[directionToNeighbor];
    neighbor.assignLink(opposite, link);

    return link;
  }

  Link linkAt(Direction direction) => _links[direction.index];

  Room neighborAt(Direction direction) => linkAt(direction)?.oppositeRoom(this);

  List<Room> get neighbors {
    var neighborsList = new List<Room>();
    for (var link in _links) {
      if (link != null) {
        var neighbor = link.oppositeRoom(this);
        neighborsList.add(neighbor);
//        print(neighborsList);
      }
    }
    return neighborsList;
  }

  List<Room> get unexploredNeighbors {
    var neighborsList = new List<Room>();
    for (var link in _links) {
      if ((link != null) && (link.oppositeRoom(this).state == RoomState.unexplored)) {
        var neighbor = link.oppositeRoom(this);
        neighborsList.add(neighbor);
      }
    }
    return neighborsList;
  }

  List<Link> get carvableLinks {
    var linksList = new List<Link>();
    for (var link in _links) {
      if ((link != null) &&
          (link.oppositeRoom(this).state == RoomState.explored)) {
        linksList.add(link);
      }
    }
//    print(linksList.length);
    return linksList;
  }

  Link get randomCarvableLink {
    var links = carvableLinks;
    var linkIndex = Maze.randomGenerator.nextInt(links.length);
    return links[linkIndex];
  }

}