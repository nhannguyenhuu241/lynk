import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:lynk_an/common/widgets/bot/cosmic_critter_widget.dart';

import 'cosmic_critter_game.dart';

class CosmicCritterFlameWidget extends StatefulWidget {
  final double size;
  final CritterState state;
  final VoidCallback? onTap;
  final ValueNotifier<Offset?>? lookDirection;

  const CosmicCritterFlameWidget({
    super.key,
    this.size = 150.0,
    this.state = CritterState.idle,
    this.onTap,
    this.lookDirection,
  });

  @override
  State<CosmicCritterFlameWidget> createState() => _CosmicCritterFlameWidgetState();
}

class _CosmicCritterFlameWidgetState extends State<CosmicCritterFlameWidget> {
  late final CosmicCritterGame _game;

  @override
  void initState() {
    super.initState();
    _game = CosmicCritterGame(
      initialState: widget.state,
      onTap: widget.onTap,
    );
  }

  @override
  void didUpdateWidget(CosmicCritterFlameWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state) {
      _game.critter?.changeState(widget.state);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: GameWidget(game: _game),
    );
  }
}
