
import "dart:html";

import "tile.dart";
import "tile_animation.dart";
import "color.dart";

class Maze {

  static const widthInRooms = 38;
  static const heightInRooms = 38;

  static const widthInLinks = widthInRooms - 1;
  static const heightInLinks = heightInRooms - 1;

  static const outerTilesCountPerDimension = 2;

  static const widthInTiles = widthInRooms + widthInLinks + outerTilesCountPerDimension;
  static const heightInTiles = heightInRooms + heightInLinks + outerTilesCountPerDimension;

  static const tilesCount = widthInTiles * heightInTiles;




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

  List<TileAnimation> _tileAnimations = new List();

  Maze(this._canvasSize) {

    _tileWidth = _canvasSize / widthInTiles;
    _tileHeight = _canvasSize / heightInTiles;

    _buildTiles();


//    _tileAt(10, 12).animate(new Color(0, 0, 0), new Color(0, 255, 0), 0.0, 1500.0);
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

  Tile _tileAt(int xIndex, int yIndex) {
    var tileIndex = (yIndex * widthInTiles) + xIndex;
    return _tiles[tileIndex];
  }




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