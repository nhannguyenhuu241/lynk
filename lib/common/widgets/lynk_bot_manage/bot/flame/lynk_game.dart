import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../lynk_bot.dart';
import '../enum/avatar_expressions.dart';
import '../enum/lynk_state_enum.dart';

class LynkGame extends FlameGame {
  final LynkState initialBotState;
  final double botSize;
  final FlagType? flagType;

  late final LynkBot lynkBot;

  LynkGame({
    required this.initialBotState,
    required this.botSize,
    this.flagType,
  });

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final botVisualSize = size.x * botSize;
    lynkBot = LynkBot(
      position: size / 2,
      size: Vector2.all(botVisualSize),
      gameBounds: size,
      flagType: flagType,
    );
    lynkBot.changeState(initialBotState);
    add(lynkBot);
  }

  /// Cập nhật trạng thái cảm xúc của LynkBot
  void updateBotState(LynkState newState) {
    if (isLoaded && children.contains(lynkBot)) {
      lynkBot.changeState(newState);
    }
  }

  /// Cập nhật loại cờ của LynkBot
  void updateBotFlag(FlagType newFlagType) {
    if (isLoaded && children.contains(lynkBot)) {
      lynkBot.updateFlag(newFlagType);
    }
  }
}
