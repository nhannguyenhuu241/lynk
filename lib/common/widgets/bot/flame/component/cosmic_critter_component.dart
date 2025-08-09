import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/cupertino.dart';
import 'package:lynk_an/common/widgets/bot/cosmic_critter_widget.dart';
import 'package:lynk_an/common/widgets/bot/flame/component/sad_cloud_component.dart';
import 'package:lynk_an/common/widgets/bot/flame/component/sleeping_z_component.dart';

import '../cosmic_critter_game.dart';
import 'body_component.dart';
import 'face_component.dart';
import 'hand_component.dart';

class CosmicCritterComponent extends PositionComponent with HasGameRef<CosmicCritterGame>, TapCallbacks {
  final CritterState initialState;
  final VoidCallback? onTap;

  CritterState _currentState;

  final List<Component> _activeStateComponents = [];

  late final BodyComponent body;
  late final HandComponent leftHand;
  late final HandComponent rightHand;
  late final FaceComponent face;

  CosmicCritterComponent({
    required this.initialState,
    this.onTap,
  }) : _currentState = initialState, super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    position = Vector2(gameRef.size.x, gameRef.size.y);
    size = Vector2(150, 150 * 1.2);

    body = BodyComponent();
    leftHand = HandComponent();
    rightHand = HandComponent();
    face = FaceComponent();

    const handY = 25.0;
    const handX = 70.0;
    leftHand.position = Vector2(-handX, handY);
    rightHand.position = Vector2(handX, handY);

    await addAll([body, leftHand, rightHand, face]);

    _applyBaseEffects();

    changeState(initialState, isInitial: true);
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap?.call();
    super.onTapDown(event);
  }

  void _applyBaseEffects() {
    body.add(
      ScaleEffect.by(
        Vector2(1.05, 0.95),
        EffectController(duration: 1.5, alternate: true, infinite: true),
      ),
    );
    leftHand.add(
        MoveEffect.by(
          Vector2(0, -8),
          EffectController(duration: 1.2, alternate: true, infinite: true),
        )
    );
    rightHand.add(
        MoveEffect.by(
          Vector2(0, -8),
          EffectController(duration: 1.2, alternate: true, infinite: true),
        )
    );
  }

  void changeState(CritterState newState, {bool isInitial = false}) {
    if (!isInitial && _currentState == newState) return;
    _onStateExit();
    _currentState = newState;
    _onStateEnter(_currentState);
  }

  void _onStateEnter(CritterState state) {
    face.updateLook(state);

    Color targetColor;
    switch (state) {
      case CritterState.angry:
        targetColor = const Color(0xFFE57373);
        break;
      case CritterState.sadboi:
        targetColor = const Color(0xFFB0BEC5);
        break;
      default:
        targetColor = body.defaultColor1;
    }
    body.add(ColorEffect(targetColor, EffectController(duration: 0.3)));

    switch (state) {
      case CritterState.happy:
        final jumpEffectLeft = MoveEffect.by(Vector2(0, -20), EffectController(duration: 0.3, alternate: true, repeatCount: 4));
        final jumpEffectRight = MoveEffect.by(Vector2(0, -20), EffectController(duration: 0.3, alternate: true, repeatCount: 4));
        leftHand.add(jumpEffectLeft);
        rightHand.add(jumpEffectRight);
        _activeStateComponents.addAll([jumpEffectLeft, jumpEffectRight]);
        break;
      case CritterState.sadboi:
        final sadCloud = SadCloudComponent();
        add(sadCloud);
        _activeStateComponents.add(sadCloud);
        break;
      case CritterState.sleeping:
        final sleepingZ = SleepingZComponent();
        add(sleepingZ);
        _activeStateComponents.add(sleepingZ);
        break;
      case CritterState.thinking:
        final moveLeft = MoveToEffect(Vector2(-20, 10), EffectController(duration: 0.3));
        final moveRight = MoveToEffect(Vector2(20, 10), EffectController(duration: 0.3));
        leftHand.add(moveLeft);
        rightHand.add(moveRight);
        _activeStateComponents.addAll([moveLeft, moveRight]);
        break;
      default:
        break;
    }
  }

  void _onStateExit() {
    for (final component in _activeStateComponents) {
      component.removeFromParent();
    }
    _activeStateComponents.clear();

    leftHand.children.whereType<Effect>().where((e) => e is! ScaleEffect && e is! MoveEffect).forEach((e) => e.removeFromParent());
    rightHand.children.whereType<Effect>().where((e) => e is! ScaleEffect && e is! MoveEffect).forEach((e) => e.removeFromParent());

    // 3. Đặt lại các thuộc tính về giá trị mặc định một cách tức thì.
    // Điều này tránh tạo ra các hiệu ứng "reset" chồng chéo.
    const handY = 25.0;
    const handX = 70.0;
    leftHand.position = Vector2(-handX, handY);
    rightHand.position = Vector2(handX, handY);
  }
}