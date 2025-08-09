import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:lynk_an/common/widgets/bot/cosmic_critter_widget.dart';

import 'component/cosmic_critter_component.dart';

class CosmicCritterGame extends FlameGame {
  final CritterState initialState;
  final VoidCallback? onTap;

  CosmicCritterComponent? critter;

  CosmicCritterGame({
    required this.initialState,
    this.onTap,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    camera.backdrop = Component();
    critter = CosmicCritterComponent(initialState: initialState, onTap: onTap,);
    add(critter!);
  }
}