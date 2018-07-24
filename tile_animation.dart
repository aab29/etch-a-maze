import "color.dart";

class TileAnimation {
  final Color startColor;
  final Color endColor;

  double startTime;
  final double _duration;

  TileAnimation(this.startColor, this.endColor, this._duration);

  double get endTime => startTime + _duration;

  double _elapsedTime(double time) => time - startTime;

  double _progressAtTime(double time) =>
      (_elapsedTime(time) / _duration).clamp(0.0, 1.0);

  Color colorAtTime(double time) {
    var progress = _progressAtTime(time);
    var invertedProgress = 1.0 - progress;

    return new Color(
        (startColor.red * invertedProgress + endColor.red * progress).toInt(),
        (startColor.green * invertedProgress + endColor.green * progress)
            .toInt(),
        (startColor.blue * invertedProgress + endColor.blue * progress)
            .toInt());
  }
}
