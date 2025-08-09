import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/enum/avatar_expressions.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/enum/lynk_state_enum.dart';

import 'lynk_game.dart';

class LynkFlameWidget extends StatefulWidget {
  final double? width;
  final double? height;
  final double? botSize;
  final LynkState state;
  final FlagType? flagType;
  final ValueNotifier<Offset?>? lookDirection;

  const LynkFlameWidget({
    super.key,
    this.width,
    this.height,
    this.botSize,
    this.state = LynkState.idle,
    this.flagType,
    this.lookDirection,
  });

  @override
  State<LynkFlameWidget> createState() => _LynkFlameWidgetState();
}

class _LynkFlameWidgetState extends State<LynkFlameWidget> {
  late final LynkGame _game;

  @override
  void initState() {
    super.initState();
    _game = LynkGame(
      initialBotState: widget.state,
      botSize: widget.botSize ?? 0.5,
      flagType: widget.flagType,
    );
  }

  @override
  void didUpdateWidget(LynkFlameWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state) {
      _game.updateBotState(widget.state);
    }
    if (widget.flagType != oldWidget.flagType && widget.flagType != null) {
      _game.updateBotFlag(widget.flagType!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: GameWidget(game: _game),
    );
  }
}
