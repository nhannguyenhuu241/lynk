import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:lynk_an/common/theme.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/flame/lynk_game.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/enum/lynk_state_enum.dart';
import 'dart:ui' as ui;

import 'background_elements/raindrop.dart';
import 'background_elements/cloud.dart';
import 'background_elements/snowflake.dart';
import 'background_elements/start.dart';


class DynamicBackground extends PositionComponent with HasGameRef<LynkGame> {
  late TimeOfDayState timeOfDay;
  WeatherState weather;

  // --- Biến cho các animation ---
  double _animationTime = 0.0;
  final List<Star> _stars = [];
  final List<Cloud> _clouds = [];
  final List<Raindrop> _raindrops = [];
  final List<Snowflake> _snowflakes = [];

  // --- Timer để kiểm tra thời gian ---
  double _timeCheckTimer = 0.0;
  final double _timeCheckInterval = 300.0; // Kiểm tra mỗi 5 phút
  late Paint backgroundPaint;
  // --- Paints ---
  final _sunPaint = Paint()..color = const Color(0xFFFFD700);
  final _moonPaint = Paint()..color = const Color(0xFFF5F5F5);
  final _starPaint = Paint()..color = Colors.white;
  final _cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.9);
  final _stormyCloudPaint = Paint()..color = const Color(0xFF757575);
  final _rainPaint = Paint()
    ..color = Colors.white.withValues(alpha: 0.5)
    ..strokeWidth = 1.5
    ..strokeCap = StrokeCap.round;
  final _snowflakePaint = Paint()..color = Colors.white.withValues(alpha: 0.8);
  final _fogPaint = Paint()..color = Colors.white.withValues(alpha: 0.6);
  final _lightningFlashPaint = Paint()..color = Colors.white.withValues(alpha: 0.7);
  final _lightningBoltPaint = Paint()
    ..color = Colors.yellow.withValues(alpha: 0.8)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.solid, 3);

  // --- Biến cho sấm sét ---
  double _lightningTimer = 0.0;
  double _nextLightningFlash = 0.0;
  bool _isFlashing = false;
  final double _flashDuration = 0.15;
  late Path _lightningPath;

  DynamicBackground({
    required this.weather,
    required this.timeOfDay,
    required super.size,
  }) : super(position: Vector2.zero()) {
    _updatePaint();
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _updateTimeOfDay();
    _createStars();
    _createClouds();
    _createRaindrops();
    _createSnowflakes();
    _generateNextLightningFlash();
    _createLightningPath();
  }

  void _updateTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 8) {
      timeOfDay = TimeOfDayState.sunrise;
    } else if (hour >= 8 && hour < 17) {
      timeOfDay = TimeOfDayState.day;
    } else if (hour >= 17 && hour < 19) {
      timeOfDay = TimeOfDayState.sunset;
    } else {
      timeOfDay = TimeOfDayState.night;
    }
  }

  List<Color> _getGradientColors() {
    switch (timeOfDay) {
      case TimeOfDayState.sunrise:
        return [AppColors.sunriseTop, AppColors.sunriseMiddle, AppColors.sunriseBottom];
      case TimeOfDayState.day:
        return [AppColors.dayTop, AppColors.dayMiddle, AppColors.dayBottom];
      case TimeOfDayState.sunset:
        return [AppColors.sunsetTop, AppColors.sunsetMiddle, AppColors.sunsetBottom];
      case TimeOfDayState.night:
        return [AppColors.nightTop, AppColors.nightMiddle, AppColors.nightBottom];
    }
  }

  void _updatePaint() {
    final colors = _getGradientColors();
    backgroundPaint = Paint()
      ..shader = LinearGradient(
        colors: colors,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
  }


  void _createStars() {
    final random = Random();
    if (_stars.isNotEmpty) return;
    for (int i = 0; i < 100; i++) {
      _stars.add(Star(
        position: Vector2(random.nextDouble() * size.x, random.nextDouble() * size.y * 0.8),
        radius: random.nextDouble() * 1.2 + 0.5,
        twinkleSpeed: random.nextDouble() * 2 + 1,
      ));
    }
  }


  @override
  void onGameResize(Vector2 newSize) {
    super.onGameResize(newSize);
    size = newSize;
    _updatePaint();
  }

  void _createClouds() {
    final random = Random();
    if (_clouds.isNotEmpty) return;
    for (int i = 0; i < 7; i++) {
      _clouds.add(Cloud(
        position: Vector2(random.nextDouble() * size.x, random.nextDouble() * size.y * 0.4 + 50),
        size: random.nextDouble() * 50 + 70,
        speed: random.nextDouble() * 10 + 15,
        gameBounds: size,
      ));
    }
  }

  void _createRaindrops() {
    final random = Random();
    if (_raindrops.isNotEmpty) return;
    for (int i = 0; i < 150; i++) {
      _raindrops.add(Raindrop(
        position: Vector2(random.nextDouble() * size.x, random.nextDouble() * size.y),
        length: random.nextDouble() * 15 + 10,
        speed: random.nextDouble() * 150 + 250,
        gameBounds: size,
      ));
    }
  }

  void _createSnowflakes() {
    final random = Random();
    if (_snowflakes.isNotEmpty) return;
    for (int i = 0; i < 100; i++) {
      _snowflakes.add(Snowflake(
        position: Vector2(random.nextDouble() * size.x, random.nextDouble() * size.y),
        radius: random.nextDouble() * 2.0 + 1.0,
        speed: random.nextDouble() * 20 + 30,
        drift: random.nextDouble() * 80 + 40,
        driftSpeed: random.nextDouble() * 20 + 10,
        gameBounds: size,
      ));
    }
  }

  void _generateNextLightningFlash() {
    _nextLightningFlash = Random().nextDouble() * 5 + 3;
  }

  void _createLightningPath() {
    _lightningPath = Path();
    final random = Random();
    final startX = random.nextDouble() * size.x;
    _lightningPath.moveTo(startX, 0);

    var currentPoint = Vector2(startX, 0);
    while (currentPoint.y < size.y * 0.8) {
      final nextX = currentPoint.x + (random.nextDouble() - 0.5) * 80;
      final nextY = currentPoint.y + random.nextDouble() * 60 + 20;
      _lightningPath.lineTo(nextX, nextY);
      currentPoint = Vector2(nextX, nextY);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _animationTime += dt;

    _timeCheckTimer += dt;
    if (_timeCheckTimer >= _timeCheckInterval) {
      _timeCheckTimer = 0;
      _updateTimeOfDay();
    }

    if ([WeatherState.sunnyWithClouds, WeatherState.raining, WeatherState.drizzle, WeatherState.stormy, WeatherState.snowing, WeatherState.foggy].contains(weather)) {
      for (var cloud in _clouds) {
        cloud.update(dt);
      }
    }

    if ([WeatherState.raining, WeatherState.drizzle, WeatherState.stormy].contains(weather)) {
      for (var drop in _raindrops) {
        drop.update(dt);
      }
    }

    if (weather == WeatherState.snowing) {
      for (var flake in _snowflakes) {
        flake.update(dt);
      }
    }

    if (weather == WeatherState.stormy) {
      _updateLightning(dt);
    }
  }

  void _updateLightning(double dt) {
    _lightningTimer += dt;
    if (_isFlashing) {
      if (_lightningTimer > _flashDuration) {
        _isFlashing = false;
        _lightningTimer = 0.0;
        _generateNextLightningFlash();
      }
    } else {
      if (_lightningTimer > _nextLightningFlash) {
        _isFlashing = true;
        _lightningTimer = 0.0;
        _createLightningPath();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _drawSky(canvas);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), backgroundPaint);

    if (timeOfDay == TimeOfDayState.night) {
      _drawStars(canvas);
    }

    final bool hideCelestial = [WeatherState.raining, WeatherState.drizzle, WeatherState.stormy, WeatherState.snowing, WeatherState.foggy].contains(weather);
    if (!hideCelestial) {
      _drawCelestialBody(canvas);
    }

    if ([WeatherState.sunnyWithClouds, WeatherState.raining, WeatherState.drizzle, WeatherState.stormy, WeatherState.snowing, WeatherState.foggy].contains(weather)) {
      final paint = (weather == WeatherState.stormy) ? _stormyCloudPaint : _cloudPaint;
      _drawClouds(canvas, paint);
    }

    // Vẽ các hiệu ứng thời tiết
    switch (weather) {
      case WeatherState.raining:
        _drawRain(canvas, 1.0);
        break;
      case WeatherState.drizzle:
        _drawRain(canvas, 0.3);
        break;
      case WeatherState.stormy:
        _drawRain(canvas, 1.2);
        if (_isFlashing) {
          _drawLightning(canvas);
        }
        break;
      case WeatherState.snowing:
        _drawSnow(canvas);
        break;
      case WeatherState.foggy:
        _drawFog(canvas);
        break;
      default:
        break;
    }
  }

  void _drawSky(Canvas canvas) {
    Rect fullRect = Rect.fromLTWH(0, 0, size.x, size.y);
    late final Paint skyPaint;

    // Màu sắc bầu trời thay đổi theo thời tiết
    if (weather == WeatherState.stormy) {
      skyPaint = Paint()..color = const Color(0xFF424242).withValues(alpha: 0.0);
    } else if (weather == WeatherState.snowing || weather == WeatherState.foggy) {
      skyPaint = Paint()..color = const Color(0xFFBDBDBD).withValues(alpha: 0.0);
    } else {
      switch (timeOfDay) {
        case TimeOfDayState.sunrise:
          skyPaint = Paint()..color = const Color(0xFF424242).withValues(alpha: 0.0);
            //..shader = ui.Gradient.linear(Offset(size.x / 2, size.y), Offset(size.x / 2, 0), [const Color(0xFF8362A3), const Color(0xFFEE896D), const Color(0xFFFFC37A)]);
          break;
        case TimeOfDayState.day:
           skyPaint = Paint()..color = const Color(0xFF424242).withValues(alpha: 0.0);
          //    ..shader = ui.Gradient.linear(Offset(size.x / 2, size.y), Offset(size.x / 2, 0), [const Color(0xFF87CEEB), const Color(0xFF3C99DC)]);
           break;
        case TimeOfDayState.sunset:
          skyPaint = Paint()..color = const Color(0xFF424242).withValues(alpha: 0.0);
            //..shader = ui.Gradient.linear(Offset(size.x / 2, size.y), Offset(size.x / 2, 0), [const Color(0xFF3B326C), const Color(0xFFD97959), const Color(0xFFF0B363)]);
          break;
        case TimeOfDayState.night:
          skyPaint = Paint()..color = const Color(0xFF424242).withValues(alpha: 0.0);
           // ..shader = ui.Gradient.linear(Offset(size.x / 2, size.y), Offset(size.x / 2, 0), [const Color(0xFF000033), const Color(0xFF1a1a4a)]);
          break;
      }
    }
    canvas.drawRect(fullRect, skyPaint);
  }

  double _getCelestialPathPercentage() {
    final now = DateTime.now();
    final timeInMinutes = now.hour * 60 + now.minute;
    const sunriseStart = 5 * 60;
    const dayStart = 8 * 60;
    const sunsetStart = 17 * 60;
    const nightStart = 19 * 60;
    const dayEnd = 24 * 60;

    if (timeInMinutes >= sunriseStart && timeInMinutes < dayStart) {
      final duration = dayStart - sunriseStart;
      final progress = timeInMinutes - sunriseStart;
      return progress / duration;
    } else if (timeInMinutes >= dayStart && timeInMinutes < sunsetStart) {
      final duration = sunsetStart - dayStart;
      final progress = timeInMinutes - dayStart;
      return progress / duration;
    } else if (timeInMinutes >= sunsetStart && timeInMinutes < nightStart) {
      final duration = nightStart - sunsetStart;
      final progress = timeInMinutes - sunsetStart;
      return progress / duration;
    } else {
      final duration = (dayEnd - nightStart) + sunriseStart;
      double progress;
      if (timeInMinutes >= nightStart) {
        progress = (timeInMinutes - nightStart).toDouble();
      } else {
        progress = ((dayEnd - nightStart) + timeInMinutes).toDouble();
      }
      return progress / duration;
    }
  }

  void _drawCelestialBody(Canvas canvas) {
    final pathPercentage = _getCelestialPathPercentage();
    final x = size.x * pathPercentage;
    final y = size.y * 0.6 - sin(pathPercentage * pi) * size.y * 0.5;
    final radius = size.x * 0.08;

    if (timeOfDay != TimeOfDayState.night) {
      final sunColor = (timeOfDay == TimeOfDayState.day) ? const Color(0xFFFFD700) : const Color(
          0xFFFFDFDF);
      _sunPaint.color = sunColor;
      canvas.drawCircle(Offset(x, y), radius, _sunPaint);
    } else {
      canvas.drawCircle(Offset(x, y), radius, _moonPaint);
    }
  }

  void _drawStars(Canvas canvas) {
    for (var star in _stars) {
      final opacity = (sin(star.twinkleSpeed * _animationTime) + 1) / 2;
      _starPaint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(star.position.toOffset(), star.radius, _starPaint);
    }
  }

  void _drawClouds(Canvas canvas, Paint paint) {
    for (var cloud in _clouds) {
      cloud.render(canvas, paint);
    }
  }

  void _drawRain(Canvas canvas, double density) {
    final count = (_raindrops.length * density).toInt();
    for (int i = 0; i < count; i++) {
      final drop = _raindrops[i];
      canvas.drawLine(drop.position.toOffset(), drop.position.toOffset() + Offset(0, drop.length), _rainPaint);
    }
  }

  void _drawSnow(Canvas canvas) {
    for (var flake in _snowflakes) {
      canvas.drawCircle(flake.position.toOffset(), flake.radius, _snowflakePaint);
    }
  }

  void _drawFog(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _fogPaint);
  }

  void _drawLightning(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _lightningFlashPaint);
    canvas.drawPath(_lightningPath, _lightningBoltPaint);
  }

  void updateStates(WeatherState newWeather) {
    weather = newWeather;
  }
}