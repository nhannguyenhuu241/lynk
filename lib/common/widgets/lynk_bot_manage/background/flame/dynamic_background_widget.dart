import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/enum/lynk_state_enum.dart';

import 'background_game.dart';

class DynamicBackgroundWidget extends StatelessWidget {
  final WeatherState weather;
  final TimeOfDayState timeOfDay;

  const DynamicBackgroundWidget({
    super.key,
    this.weather = WeatherState.clear, required this.timeOfDay,
  });

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: BackgroundGame(initialWeather: weather, initialTimeOfDay: timeOfDay,),
    );
  }
}