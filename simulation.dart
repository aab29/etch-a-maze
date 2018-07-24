import "dart:html";

import "maze.dart";

class Simulation {
  CanvasElement _canvas;
  CanvasRenderingContext2D _context;

  double _canvasSize;

  Maze _maze;

  Simulation(this._canvas, this._context) {
    _canvasSize = _canvas.width.toDouble();

    _maze = new Maze(_canvasSize);
    _maze.drawAllTiles(_context);

    _startAnimating();
  }

  void _startAnimating() {
    window.animationFrame.then(_update);
  }

  void _update(num time) {
    _maze.drawAnimatingTiles(_context, time);

    if (_maze.isGenerating) {
      window.animationFrame.then(_update);
    }
  }
}
