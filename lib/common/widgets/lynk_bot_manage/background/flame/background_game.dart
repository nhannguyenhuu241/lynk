import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/background/dynamic_background.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/enum/lynk_state_enum.dart';

/// Một Game riêng biệt chỉ để quản lý và hiển thị DynamicBackground.
class BackgroundGame extends FlameGame {
  final WeatherState initialWeather;
  final TimeOfDayState initialTimeOfDay;

  late final DynamicBackground background;

  BackgroundGame({required this.initialWeather, required this.initialTimeOfDay});

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    background = DynamicBackground(
      weather: initialWeather,
      timeOfDay: initialTimeOfDay,
      size: size,
    );
    add(background);
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    if (isLoaded) {
      background.size = canvasSize;
    }
  }

  void updateWeather(WeatherState newWeather) {
    if (isLoaded) {
      background.updateStates(newWeather);
    }
  }
}