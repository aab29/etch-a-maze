import "tile.dart";
import "room.dart";

//enum LinkState {
//  wall,
//  passage
//}

class Link {

  final Room roomA;
  final Room roomB;

  Tile tile;

//  LinkState state = LinkState.wall;

  Link(this.roomA, this.roomB);

  Room oppositeRoom(Room room) {
    if (room == roomA) {
      return roomB;
    } else if (room == roomB) {
      return roomA;
    } else {
      throw new StateError("Room not contained in link");
    }
  }

}