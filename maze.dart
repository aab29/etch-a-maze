import "dart:math";
import "dart:html";
import "dart:async";

import "direction.dart";
import "tile.dart";
import "room.dart";

class Maze {
  static const widthInRooms = 23;
  static const heightInRooms = 23;

  static const roomsCount = widthInRooms * heightInRooms;

  static const widthInLinks = widthInRooms - 1;
  static const heightInLinks = heightInRooms - 1;

  static const outerTilesCountPerDimension = 2;

  static const widthInTiles =
      widthInRooms + widthInLinks + outerTilesCountPerDimension;
  static const heightInTiles =
      heightInRooms + heightInLinks + outerTilesCountPerDimension;

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
    _buildTiles();

    _matchRoomsToTiles();

    _generateMaze();
  }

  void _buildRooms() {
    for (var roomIndex = 0; roomIndex < roomsCount; roomIndex++) {
      var xIndex = roomIndex % widthInRooms;
      var yIndex = roomIndex ~/ heightInRooms;

      var room = new Room(xIndex, yIndex);
      _rooms[roomIndex] = room;
    }
  }

  void _buildLinks() {
    for (var room in _rooms) {
      var x = room.xIndex;
      var y = room.yIndex;

      var easternNeighborX = x + 1;
      if (easternNeighborX < widthInRooms) {
        var neighbor = _roomAt(easternNeighborX, y);
        room.buildLinkToNeighbor(neighbor, Direction.east);
      }

      var southernNeighborY = y + 1;
      if (southernNeighborY < heightInRooms) {
        var neighbor = _roomAt(x, southernNeighborY);
        room.buildLinkToNeighbor(neighbor, Direction.south);
      }
    }
  }

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

  Room _roomAt(int xIndex, int yIndex) {
    var roomIndex = (yIndex * widthInRooms) + xIndex;
    return _rooms[roomIndex];
  }

  Tile _tileAt(int xIndex, int yIndex) {
    var tileIndex = (yIndex * widthInTiles) + xIndex;
    return _tiles[tileIndex];
  }

  void drawAllTiles(CanvasRenderingContext2D context) {
    for (var tile in _tiles) {
      context.setFillColorRgb(tile.red, tile.green, tile.blue);
      context.fillRect(tile.xIndex * _tileWidth, tile.yIndex * _tileHeight,
          _tileWidth, _tileHeight);
    }
  }

  void drawAnimatingTiles(CanvasRenderingContext2D context, double time) {
    for (var tile in _tiles) {
      if (tile.isAnimating) {
        tile.updateAnimation(time);

        context.setFillColorRgb(tile.red, tile.green, tile.blue);
        context.fillRect(tile.xIndex * _tileWidth, tile.yIndex * _tileHeight,
            _tileWidth, _tileHeight);
      }
    }
  }

  Room get _randomStartingRoom {
    var xIndex = randomGenerator.nextInt(widthInRooms);
    var yIndex = randomGenerator.nextInt(heightInRooms);
    return _roomAt(xIndex, yIndex);
  }

  Room get _removeRandomFrontierRoom {
    var roomIndex = randomGenerator.nextInt(_frontierRooms.length);
    return _frontierRooms.removeAt(roomIndex);
  }

  void _markNeighborsAsFrontier(Room room) async {
    await rest(20);

    var neighbors = room.unexploredNeighbors;
    for (var neighbor in neighbors) {
      _frontierRooms.add(neighbor);
      neighbor.state = RoomState.frontier;
      neighbor.tile.animateToState(TileState.frontierRoom, duration: 355.0);
    }

    await rest(60);
  }

  void _exploreStartingRoom() async {
    var startingRoom = _randomStartingRoom;

    startingRoom.state = RoomState.explored;
    startingRoom.tile.animateToState(TileState.exploredRoom, duration: 240.0);

    await _markNeighborsAsFrontier(startingRoom);
  }

  void _generateMaze() async {
    isGenerating = true;

    await _exploreStartingRoom();

    while (_frontierRooms.isNotEmpty) {
      var frontierRoom = _removeRandomFrontierRoom;

      var link = frontierRoom.randomCarvableLink;

      link.tile.animateToState(TileState.passage, duration: 120.0);
      await rest(10);
      frontierRoom.state = RoomState.explored;
      frontierRoom.tile.animateToState(TileState.exploredRoom, duration: 240.0);

      await _markNeighborsAsFrontier(frontierRoom);
    }

    await rest(400);
    isGenerating = false;
  }

  static Future rest(int milliseconds) =>
      new Future.delayed(new Duration(milliseconds: milliseconds));
}
