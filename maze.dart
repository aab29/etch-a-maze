import "dart:math";
import "dart:html";
import "dart:async";

import "direction.dart";
import "tile.dart";

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

  List<Tile> _frontierRooms = [];

  Maze(this._canvasSize) {

    _tileWidth = _canvasSize / widthInTiles;
    _tileHeight = _canvasSize / heightInTiles;

    _buildTiles();


    _generateMaze();

  }

  void _buildTiles() {
    for (var tileIndex = 0; tileIndex < tilesCount; tileIndex++) {
      var xIndex = tileIndex % widthInTiles;
      var yIndex = tileIndex ~/ heightInTiles;

      var state = _initialTileStateForCoordinates(xIndex, yIndex);
      var tile = new Tile(xIndex, yIndex, state);

      _tiles[tileIndex] = tile;
    }
  }

  TileState _initialTileStateForCoordinates(int xIndex, int yIndex) {
    if ((xIndex == 0) ||
        (yIndex == 0) ||
        (xIndex == widthInTiles - 1) ||
        (yIndex == heightInTiles - 1)) {
      return TileState.outerTile;
    } else if (xIndex.isOdd && yIndex.isOdd) {
      return TileState.unexploredRoom;
    } else {
      return TileState.wall;
    }
  }

  void drawAllTiles(CanvasRenderingContext2D context, double time) {

    for (var tile in _tiles) {
      tile.updateAnimation(time);

      context.setFillColorRgb(tile.red, tile.green, tile.blue);
      context.fillRect(tile.xIndex * _tileWidth, tile.yIndex * _tileHeight, _tileWidth, _tileHeight);
    }
  }

  bool _areCoordinatesInBounds(int xIndex, int yIndex) =>
      (xIndex > 0) ||
      (yIndex > 0) ||
      (xIndex < widthInTiles - 1) ||
      (yIndex < heightInTiles - 1);

  Tile _tileAt(int xIndex, int yIndex) {
    if (!_areCoordinatesInBounds(xIndex, yIndex)) {
      return null;
    }

    var tileIndex = (yIndex * widthInTiles) + xIndex;
    return _tiles[tileIndex];
  }

  List<Tile> _neighborsOf(Tile room) {
    var x = room.xIndex;
    var y = room.yIndex;
    var neighbors = [
      _tileAt(x + 2, y),
      _tileAt(x, y - 2),
      _tileAt(x - 2, y),
      _tileAt(x, y + 2)
    ];
    return neighbors.where((neighbor) => neighbor != null).toList(growable: false);
  }

  Tile get _randomStartingRoom {
    var xIndex = randomGenerator.nextInt(widthInRooms) * 2 + 1;
    var yIndex = randomGenerator.nextInt(heightInRooms) * 2 + 1;
    return _tileAt(xIndex, yIndex);
  }

  void _exploreStartingRoom() {
    var startingRoom = _randomStartingRoom;

    startingRoom.animateToState(TileState.exploredRoom);

    var neighbors = _neighborsOf(startingRoom);
    _frontierRooms.addAll(neighbors);

    for (var neighbor in neighbors) {
      neighbor.animateToState(TileState.frontierRoom);
    }

    delay(1000);
  }

  void _generateMaze() {
    _exploreStartingRoom();
  }

  static Future delay(int milliseconds) => new Future.delayed(new Duration(milliseconds:milliseconds)).whenComplete(() {});


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