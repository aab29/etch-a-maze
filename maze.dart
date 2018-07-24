import "dart:math";
import "dart:html";
import "dart:async";

import "direction.dart";
import "tile.dart";
import "room.dart";
import "link.dart";

class Maze {

  static const widthInRooms = 38;
  static const heightInRooms = 38;

  static const roomsCount = widthInRooms * heightInRooms;

  static const widthInLinks = widthInRooms - 1;
  static const heightInLinks = heightInRooms - 1;

  static const outerTilesCountPerDimension = 2;

  static const widthInTiles = widthInRooms + widthInLinks + outerTilesCountPerDimension;
  static const heightInTiles = heightInRooms + heightInLinks + outerTilesCountPerDimension;

  static const tilesCount = widthInTiles * heightInTiles;

  static final randomGenerator = new Random();


//  static const widthInRooms = 20;
//  static const heightInRooms = 20;
//
//  static const roomsCount = widthInRooms * heightInRooms;
//
//  static const widthInBarriers = widthInRooms - 1;
//  static const heightInBarriers = heightInRooms - 1;
//
//  static const widthInTiles = widthInRooms + widthInBarriers;
//  static const heightInTiles = heightInRooms + heightInBarriers;

  double _canvasSize;

  double _tileWidth;
  double _tileHeight;

  List<Tile> _tiles = new List(tilesCount);
  List<Room> _rooms = new List(roomsCount);

  List<Room> _frontierRooms = [];

  Maze(this._canvasSize) {

    _tileWidth = _canvasSize / widthInTiles;
    _tileHeight = _canvasSize / heightInTiles;

    _buildRooms();
    _buildLinks();
    _buildRemainingTiles();

    _generateMaze();

  }

  void _assignTileAt(xIndex, yIndex, tile) {
    var tileIndex = (yIndex * widthInTiles) + xIndex;
    _tiles[tileIndex] = tile;
  }

  void _buildRooms() {
    for (var roomIndex = 0; roomIndex < roomsCount; roomIndex++) {
      var xIndex = roomIndex % widthInRooms;
      var yIndex = roomIndex ~/ heightInRooms;

      var tileX = xIndex * 2 + 1;
      var tileY = yIndex * 2 + 1;
      var tile = new Tile(tileX, tileY, TileState.unexploredRoom);
      _assignTileAt(tileX, tileY, tile);

      var room = new Room(xIndex, yIndex, tile);
      _rooms[roomIndex] = room;
    }
  }

  void _buildLinks() {
    for (var room in _rooms) {
      var x = room.xIndex;
      var y = room.yIndex;

      if (x + 1 < widthInRooms) {
        var tileX = x * 2 + 2;
        var tileY = y * 2 + 1;
//        print("tile ($tileX, $tileY)");
        var tile = new Tile(tileX, tileY, TileState.wall);
        _assignTileAt(tileX, tileY, tile);

        var eastRoom = _roomAt(x + 1, y);
        var link = new Link(room, eastRoom, tile);
        room.assignLink(Direction.east, link);
        eastRoom.assignLink(Direction.west, link);
      }

      if (y + 1 < heightInRooms) {
        var tileX = x * 2 + 1;
        var tileY = y * 2 + 2;
//        print("tile ($tileX, $tileY)");
        var tile = new Tile(tileX, tileY, TileState.wall);
        _assignTileAt(tileX, tileY, tile);

        var southRoom = _roomAt(x, y + 1);
        var link = new Link(room, southRoom, tile);
        room.assignLink(Direction.south, link);
        southRoom.assignLink(Direction.north, link);
      }

    }
  }

  Room _roomAt(int xIndex, int yIndex) {
    var roomIndex = (yIndex * widthInRooms) + xIndex;
    return _rooms[roomIndex];
  }

  void _buildRemainingTiles() {
    for (var tileIndex = 0; tileIndex < tilesCount; tileIndex++) {
      if (_tiles[tileIndex] == null) {
        var xIndex = tileIndex % widthInTiles;
        var yIndex = tileIndex ~/ heightInTiles;

        _tiles[tileIndex] = new Tile(xIndex, yIndex, TileState.wall);
      }
    }
  }

//  void _buildTiles() {
//    for (var tileIndex = 0; tileIndex < tilesCount; tileIndex++) {
//      var xIndex = tileIndex % widthInTiles;
//      var yIndex = tileIndex ~/ heightInTiles;
//
//      var tile;
//
//      if ((xIndex == 0) ||
//          (yIndex == 0) ||
//          (xIndex == widthInTiles - 1) ||
//          (yIndex == heightInTiles - 1)) {
//        tile = new Tile(xIndex, yIndex, TileState.outerTile);
//      } else if (xIndex.isOdd && yIndex.isOdd) {
//        tile = new Tile(xIndex, yIndex, TileState.unexploredRoom);
//
//        var room = _roomAt((xIndex - 1) ~/ 2, (yIndex - 1) ~/ 2);
//        room.tile = tile;
//      } else {
//        tile = new T
//      }
//
////      var state = _initialTileStateForCoordinates(xIndex, yIndex);
////      var tile = new Tile(xIndex, yIndex, state);
//
////      if (state == TileState.unexploredRoom) {
////        _rooms.add(new Room(tile));
////      }
//
//      _tiles[tileIndex] = tile;
//    }
//  }

//  TileState _initialTileStateForCoordinates(int xIndex, int yIndex) {
//    if ((xIndex == 0) ||
//        (yIndex == 0) ||
//        (xIndex == widthInTiles - 1) ||
//        (yIndex == heightInTiles - 1)) {
//      return TileState.outerTile;
//    } else if (xIndex.isOdd && yIndex.isOdd) {
//      return TileState.unexploredRoom;
//    } else {
//      return TileState.wall;
//    }
//  }

  void drawAllTiles(CanvasRenderingContext2D context, double time) {
    for (var tile in _tiles) {
      tile.updateAnimation(time);

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

    await rest(200);
  }

  void _generateMaze() async {
    _exploreStartingRoom();

    while (_frontierRooms.isNotEmpty) {
      var frontierRoom = _removeRandomFrontierRoom;

      var link = frontierRoom.randomCarvableLink;

      link.state = LinkState.passage;
      link.tile.animateToState(TileState.passage);
      await rest(100);
      frontierRoom.state = RoomState.explored;
      frontierRoom.tile.animateToState(TileState.exploredRoom);
      await rest(100);

      var neighbors = frontierRoom.unexploredNeighbors;
      for (var neighbor in neighbors) {
        _frontierRooms.add(neighbor);
        neighbor.state = RoomState.frontier;
        neighbor.tile.animateToState(TileState.frontierRoom);
      }

      await rest(200);
    }
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