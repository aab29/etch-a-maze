enum Direction { east, south, west, north }

const Map<Direction, Direction> oppositeDirections = {
  Direction.east: Direction.west,
  Direction.south: Direction.north,
  Direction.west: Direction.west,
  Direction.north: Direction.south
};
