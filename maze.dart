import "dart:math";
import "dart:html";
import "dart:async";

import "direction.dart";
import "tile.dart";
import "room.dart";
import "link.dart";

class Maze {

  static const widthInRooms = 23;
  static const heightInRooms = 23;

  static const roomsCount = widthInRooms * heightInRooms;

  static const widthInLinks = widthInRooms - 1;
  static const heightInLinks = heightInRooms - 1;

  static const outerTilesCountPerDimension = 2;

  static const widthInTiles = widthInRooms + widthInLinks + outerTilesCountPerDimension;
  static const heightInTiles = heightInRooms + heightInLinks + outerTilesCountPerDimension;

  static const tilesCount = widthInTiles * heightInTiles;

  static final randomGenerator = new Random();

  double _canvasSize;

  int _tileWidth;
  int _tileHeight;

  List<Tile> _tiles = new List(tilesCount);
  List<Room> _rooms = new List(roomsCount);

  List<Room> _frontierRooms = [];

  bool isGenerating = false;

  Maze(this._canvasSize) {

    _tileWidth = (_canvasSize / widthInTiles).floor();
    _tileHeight = (_canvasSize / heightInTiles).floor();

    _buildRooms();
    _buildLinks();
//    _buildRemainingTiles();
    _buildTiles();

    _matchRoomsToTiles();

    _generateMaze();

  }

  void _buildRooms() {
    for (var roomIndex = 0; roomIndex < roomsCount; roomIndex++) {
      var xIndex = roomIndex % widthInRooms;
      var yIndex = roomIndex ~/ heightInRooms;

//      var tileX = xIndex * 2 + 1;
//      var tileY = yIndex * 2 + 1;
//      var tile = new Tile(tileX, tileY, TileState.unexploredRoom);
//      _assignTileAt(tileX, tileY, tile);

      var room = new Room(xIndex, yIndex);
      _rooms[roomIndex] = room;
    }
  }

//  int easternNeighborX(roomX) => roomX + 1;
//  int easternNeighborY(roomY) => roomY;

  void _buildLinks() {
    for (var room in _rooms) {
      var x = room.xIndex;
      var y = room.yIndex;

      var easternNeighborX = x + 1;
      if (easternNeighborX < widthInRooms) {
        var neighbor = _roomAt(easternNeighborX, y);
        var link = room.buildLinkToNeighbor(neighbor, Direction.east);
      }

      var southernNeighborY = y + 1;
      if (southernNeighborY < heightInRooms) {
        var neighbor = _roomAt(x, southernNeighborY);
        var link = room.buildLinkToNeighbor(neighbor, Direction.south);
      }



//      if (x + 1 < widthInRooms) {
//        var neighborX = x + 1;
//        var neighborY = y;
//        var tileX = x * 2 + 2;
//        var tileY = y * 2 + 1;
//        var neighborSide = Direction.east;
//        var roomSide = Direction.west;
//        _connectToNeighbor(room, neighborX, neighborY, tileX, tileY, neighborSide, roomSide);
//      }
//
//      if (y + 1 < heightInRooms) {
//        _connectToNeighbor(room, x, y + 1, x * 2 + 1, y * 2 + 2, Direction.south, Direction.north);
//      }

//      if (x + 1 < widthInRooms) {
//        var tileX = x * 2 + 2;
//        var tileY = y * 2 + 1;
//        var tile = new Tile(tileX, tileY, TileState.wall);
//        _assignTileAt(tileX, tileY, tile);
//
//        var eastRoom = _roomAt(x + 1, y);
//        var link = new Link(room, eastRoom, tile);
//        room.assignLink(Direction.east, link);
//        eastRoom.assignLink(Direction.west, link);
//      }
//
//      if (y + 1 < heightInRooms) {
//        var tileX = x * 2 + 1;
//        var tileY = y * 2 + 2;
//        var tile = new Tile(tileX, tileY, TileState.wall);
//        _assignTileAt(tileX, tileY, tile);
//
//        var southRoom = _roomAt(x, y + 1);
//        var link = new Link(room, southRoom, tile);
//        room.assignLink(Direction.south, link);
//        southRoom.assignLink(Direction.north, link);
//      }

    }
  }

//  void _connectToNeighbor(Room room, int neighborX, int neighborY, int tileX, int tileY, Direction neighborSide, Direction roomSide) {
//    var tile = new Tile(tileX, tileY, TileState.wall);
//    _assignTileAt(tileX, tileY, tile);
//
//    var neighbor = _roomAt(neighborX, neighborY);
//    var link = new Link(room, neighbor, tile);
//    room.assignLink(neighborSide, link);
//    neighbor.assignLink(roomSide, link);
//  }


  Room _roomAt(int xIndex, int yIndex) {
    var roomIndex = (yIndex * widthInRooms) + xIndex;
    return _rooms[roomIndex];
  }

  Tile _tileAt(int xIndex, int yIndex) {
    var tileIndex = (yIndex * widthInTiles) + xIndex;
    return _tiles[tileIndex];
  }

//  void _assignTileAt(xIndex, yIndex, tile) {
//    var tileIndex = (yIndex * widthInTiles) + xIndex;
//    _tiles[tileIndex] = tile;
//  }

  bool isInnerTile(tileX, tileY) =>
      (tileX > 0) ||
      (tileY > 0) ||
      (tileX < widthInTiles - 1) ||
      (tileY < heightInTiles - 1);

  void _buildTiles() {
    for (var tileY = 0; tileY < heightInTiles; tileY++) {
      for (var tileX = 0; tileX < widthInTiles; tileX++) {
        var tileIndex = (tileY * widthInTiles) + tileX;
        _tiles[tileIndex] = new Tile(tileX, tileY);
      }
    }
  }

  void _matchRoomsToTiles() {

    for (var room in _rooms) {

      var roomTile = _tileAt(room.xIndex * 2 + 1, room.yIndex * 2 + 1);
      roomTile.state = TileState.unexploredRoom;
      room.tile = roomTile;

      var easternLink = room.linkAt(Direction.east);
      if (easternLink != null) {
        easternLink.tile = _tileAt(room.xIndex * 2 + 2, room.yIndex * 2 + 1);
      }

      var southernLink = room.linkAt(Direction.south);
      if (southernLink != null) {
        southernLink.tile = _tileAt(room.xIndex * 2 + 1, room.yIndex * 2 + 2);
      }
    }

  }

//  void _buildRemainingTiles() {
//    for (var tileIndex = 0; tileIndex < tilesCount; tileIndex++) {
//      if (_tiles[tileIndex] == null) {
//        var xIndex = tileIndex % widthInTiles;
//        var yIndex = tileIndex ~/ heightInTiles;
//
//        _tiles[tileIndex] = new Tile(xIndex, yIndex, TileState.wall);
//      }
//    }
//  }

  void drawAllTiles(CanvasRenderingContext2D context) {
    for (var tile in _tiles) {
      context.setFillColorRgb(tile.red, tile.green, tile.blue);
      context.fillRect(tile.xIndex * _tileWidth, tile.yIndex * _tileHeight, _tileWidth, _tileHeight);
    }
  }

  void drawAnimatingTiles(CanvasRenderingContext2D context, double time) {
    for (var tile in _tiles) {
      if (tile.isAnimating) {
        tile.updateAnimation(time);

        context.setFillColorRgb(tile.red, tile.green, tile.blue);
        context.fillRect(tile.xIndex * _tileWidth, tile.yIndex * _tileHeight, _tileWidth, _tileHeight);
      }
    }
  }

//  bool _areCoordinatesInBounds(int xIndex, int yIndex) =>
//      (xIndex > 0) ||
//      (yIndex > 0) ||
//      (xIndex < widthInTiles - 1) ||
//      (yIndex < heightInTiles - 1);
//
//  Tile _tileAt(int xIndex, int yIndex) {
//    if (!_areCoordinatesInBounds(xIndex, yIndex)) {
//      return null;
//    }
//
//    var tileIndex = (yIndex * widthInTiles) + xIndex;
//    return _tiles[tileIndex];
//  }

//  List<Tile> _neighborsOf(Tile room) {
//    var x = room.xIndex;
//    var y = room.yIndex;
//    var neighbors = [
//      _tileAt(x + 2, y),
//      _tileAt(x, y - 2),
//      _tileAt(x - 2, y),
//      _tileAt(x, y + 2)
//    ];
//    return neighbors.where((neighbor) => neighbor != null).toList(growable: false);
//  }

  Room get _randomStartingRoom {
    var xIndex = randomGenerator.nextInt(widthInRooms);
    var yIndex = randomGenerator.nextInt(heightInRooms);
    return _roomAt(xIndex, yIndex);
  }

  Room get _removeRandomFrontierRoom {
    var roomIndex = randomGenerator.nextInt(_frontierRooms.length);
    return _frontierRooms.removeAt(roomIndex);
  }

  void _exploreStartingRoom() async {
    var startingRoom = _randomStartingRoom;

    startingRoom.state = RoomState.explored;
    startingRoom.tile.animateToState(TileState.exploredRoom);

    var neighbors = startingRoom.neighbors;
    for (var neighbor in neighbors) {
      _frontierRooms.add(neighbor);
      neighbor.state = RoomState.frontier;
      neighbor.tile.animateToState(TileState.frontierRoom);
    }

    await rest(20);
  }

  void _generateMaze() async {
    isGenerating = true;

    _exploreStartingRoom();

    while (_frontierRooms.isNotEmpty) {
      var frontierRoom = _removeRandomFrontierRoom;

      var link = frontierRoom.randomCarvableLink;

//      link.state = LinkState.passage;
      link.tile.animateToState(TileState.passage, duration: 120.0);
      await rest(10);
      frontierRoom.state = RoomState.explored;
      frontierRoom.tile.animateToState(TileState.exploredRoom, duration: 240.0);
      await rest(20);

      var neighbors = frontierRoom.unexploredNeighbors;
      for (var neighbor in neighbors) {
        _frontierRooms.add(neighbor);
        neighbor.state = RoomState.frontier;
        neighbor.tile.animateToState(TileState.frontierRoom, duration: 355.0);
      }

      await rest(40);
    }

    await rest(1500);
    isGenerating = false;
    print("Finished generating");
  }

  static Future rest(int milliseconds) => new Future.delayed(new Duration(milliseconds:milliseconds));

//  void _buildLinks() {
//
//    for (var yIndex = 0; yIndex < heightInRooms; yIndex++) {
//      for (var xIndex = 0; xIndex < widthInRooms; xIndex++) {
//
//        var room = _roomAt(xIndex, yIndex);
//        var eastLink = new Link();
//
//
//      }
//    }
//
//  }

//  Room _roomAt(int xIndex, int yIndex) {
//    var roomIndex = (yIndex * widthInRooms) + xIndex;
//    return _rooms[roomIndex];
//  }

}