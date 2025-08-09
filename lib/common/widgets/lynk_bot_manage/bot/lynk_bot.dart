import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import 'components/accessories/flag_component.dart';
import 'components/accessories/sad_cloud_component.dart';
import 'components/accessories/sunglasses_component.dart';
import 'components/accessories/thinking_bubbles_component.dart';
import 'components/cheeks_component.dart';
import 'components/eyes_component.dart';
import 'components/face_component.dart';
import 'components/hands_component.dart';
import 'components/mouth_component.dart';
import 'enum/avatar_expressions.dart';
import 'enum/lynk_state_enum.dart';

/// Lớp quản lý chính cho LynkBot.
/// Chịu trách nhiệm về logic, trạng thái, hoạt ảnh và lắp ráp các bộ phận.
class LynkBot extends PositionComponent with TapCallbacks {

  late final FaceComponent face;
  late final CheeksComponent cheeks;
  late final EyesComponent eyes;
  late final MouthComponent mouth;
  late final HandsComponent hands;
  late final SadCloudComponent sadCloud;
  late final SunglassesComponent sunglasses;
  late final ThinkingBubblesComponent thinkingBubbles;
  FlagComponent? flagComponent;

  LynkState currentState = LynkState.idle;
  FlagType currentFlagType = FlagType.vietnam;

  double _animationTime = 0.0;
  double _animationSpeed = 1.5;
  bool _isBlinking = false;
  double _blinkTimer = 0.0;
  double _nextBlinkInterval = 3.0;
  bool _isTapped = false;
  double _tapAnimationTime = 0.0;
  final double _tapDuration = 0.4;
  double _handOffsetY = 0.0;
  double _dizzyRotationTime = 0.0;

  Vector2? _targetPosition;
  final double _moveSpeed = 25.0;
  late Vector2 _gameBounds;
  late Vector2 _initialPosition;
  final double _verticalBreathAmplitude = 0.03;
  final double _horizontalBreathAmplitude = 0.02;
  final double _verticalPositionAmplitude = 3.0;

  LynkBot({
    required super.position, 
    required super.size, 
    required Vector2 gameBounds,
    FlagType? flagType,
  }) {
    _initialPosition = position.clone();
    _gameBounds = gameBounds;
    currentFlagType = flagType ?? FlagType.vietnam;
    anchor = Anchor.center;
    _generateNewTarget();
  }

  @override
  Future<void> onLoad() async {
    face = FaceComponent(size: size);
    cheeks = CheeksComponent(size: size);
    eyes = EyesComponent(size: size);
    mouth = MouthComponent(size: size);
    hands = HandsComponent(size: size);
    sadCloud = SadCloudComponent(size: size)..componentOpacity = 0;
    sunglasses = SunglassesComponent(size: size)..componentOpacity = 0;
    thinkingBubbles = ThinkingBubblesComponent(size: size)..componentOpacity = 0;
    flagComponent = FlagComponent(
      flagType: currentFlagType,
      flagSize: size.x * 0.2,
      position: Vector2(size.x * 0.85, size.y * 0.15),
    )..componentOpacity = 0;

    await addAll([
      face, cheeks, eyes, mouth,
      sadCloud, sunglasses, thinkingBubbles,
      hands, flagComponent!,
    ]);
  }

  void changeState(LynkState newState) {
    if (currentState == newState) return;
    currentState = newState;
    _animationTime = 0;
    angle = 0;
    if (newState != LynkState.idle) {
      position = _initialPosition.clone();
    } else {
      _generateNewTarget();
    }
  }

  void updateFlag(FlagType flagType) {
    currentFlagType = flagType;
    if (flagComponent != null && children.contains(flagComponent)) {
      flagComponent!.removeFromParent();
    }
    flagComponent = FlagComponent(
      flagType: currentFlagType,
      flagSize: size.x * 0.2,
      position: Vector2(size.x * 0.85, size.y * 0.15),
    );
    flagComponent!.componentOpacity = currentState == LynkState.holdingFlag ? 1 : 0;
    add(flagComponent!);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateStateLogic(dt);
    _updateTapAnimation(dt);
    _updateAvatarParts();
  }

  void _updateStateLogic(double dt) {
    switch (currentState) {
      case LynkState.idle: _updateWandering(dt); break;
      case LynkState.sleeping: _updateStationary(dt); break;
      case LynkState.happy: _updateStationary(dt, speedMultiplier: 2.0, vAmp: 0.05, hAmp: 0.04); break;
      case LynkState.thinking: _updateStationary(dt, speedMultiplier: 0.8, vAmp: 0.01, hAmp: 0.01); break;
      case LynkState.angry: _updateAngry(dt); break;
      case LynkState.sadboi: _updateStationary(dt, speedMultiplier: 0.4, vAmp: 0.01, hAmp: 0.02); break;
      case LynkState.dizzy: _updateDizzy(dt); break;
      case LynkState.lowenergy: _updateStationary(dt, speedMultiplier: 0.2, vAmp: 0.01, hAmp: 0.01); break;
      case LynkState.listening: _updateListening(dt); break;
      case LynkState.holdingFlag: _updateStationary(dt, speedMultiplier: 1.2, vAmp: 0.03, hAmp: 0.02); break;
      default: _updateStationary(dt);
    }
  }

  void _updateAvatarParts() {
    _updateFace();
    _updateCheeks();
    _updateEyes();
    _updateMouth();
    _updateHands();
    _updateAccessories();
  }

  void _updateFace() {
    face.showShadow = currentState != LynkState.idle;
    switch (currentState) {
      case LynkState.angry: face.updateColor(const Color(0xFFD32F2F), const Color(0xFFE57373)); break;
      case LynkState.sadboi: face.updateColor(const Color(0xFF78909C), const Color(0xFFB0BEC5)); break;
      case LynkState.lowenergy: face.updateColor(const Color(0xFF66BB6A), const Color(0xFFA5D6A7)); break;
      default: face.updateColor();
    }
  }

  void _updateCheeks() {
    cheeks.opacity = (currentState == LynkState.sadboi) ? 0.3 : 0.7;
  }

  void _updateEyes() {
    eyes.animationTime = _animationTime;
    eyes.dizzyRotationTime = _dizzyRotationTime;
    eyes.componentOpacity = currentState == LynkState.trolling ? 0 : 1;
    if (_isBlinking) {
      eyes.expression = EyeExpression.blinking;
      return;
    }
    switch (currentState) {
      case LynkState.happy: eyes.expression = EyeExpression.happy; break;
      case LynkState.sleeping: eyes.expression = EyeExpression.closed; break;
      case LynkState.angry: eyes.expression = EyeExpression.angry; break;
      case LynkState.sadboi: eyes.expression = EyeExpression.sad; break;
      case LynkState.thinking: eyes.expression = EyeExpression.thinking; break;
      case LynkState.listening: eyes.expression = EyeExpression.listening; break;
      case LynkState.dizzy: eyes.expression = EyeExpression.dizzy; break;
      case LynkState.lowenergy: eyes.expression = EyeExpression.lowEnergy; break;
      default: eyes.expression = EyeExpression.normal;
    }
  }

  void _updateMouth() {
    switch (currentState) {
      case LynkState.happy: mouth.expression = MouthExpression.happy; break;
      case LynkState.angry: mouth.expression = MouthExpression.angry; break;
      case LynkState.sadboi: mouth.expression = MouthExpression.sad; break;
      case LynkState.listening: mouth.expression = MouthExpression.listening; break;
      case LynkState.dizzy: mouth.expression = MouthExpression.dizzy; break;
      case LynkState.trolling: mouth.expression = MouthExpression.trolling; break;
      case LynkState.thinking: mouth.expression = MouthExpression.thinking; break;
      default: mouth.expression = MouthExpression.normal;
    }
  }

  void _updateHands() {
    hands.bodyPaint = face.bodyPaint;
    hands.animationTime = _animationTime;
    hands.handOffsetY = _handOffsetY;
    switch (currentState) {
      case LynkState.listening: hands.pose = HandPose.listening; break;
      case LynkState.thinking: hands.pose = HandPose.thinking; break;
      case LynkState.angry: hands.pose = HandPose.angry; break;
      case LynkState.lowenergy: hands.pose = HandPose.lowEnergy; break;
      case LynkState.sleeping: hands.pose = HandPose.sleeping; break;
      case LynkState.trolling: hands.pose = HandPose.trolling; break;
      case LynkState.holdingFlag: hands.pose = HandPose.holdingFlag; break;
      default: hands.pose = HandPose.normal;
    }
    switch (currentState) {
      case LynkState.angry: face.updateColor(const Color(0xFFD32F2F), const Color(0xFFE57373)); break;
      case LynkState.sadboi: face.updateColor(const Color(0xFF78909C), const Color(0xFFB0BEC5)); break;
      case LynkState.lowenergy: face.updateColor(const Color(0xFF66BB6A), const Color(0xFFA5D6A7)); break;
      default: face.updateColor();
    }
  }

  void _updateAccessories() {
    sadCloud.componentOpacity = currentState == LynkState.sadboi ? 1 : 0;
    sunglasses.componentOpacity = currentState == LynkState.trolling ? 1 : 0;
    thinkingBubbles.componentOpacity = currentState == LynkState.thinking ? 1 : 0;
    flagComponent?.componentOpacity = currentState == LynkState.holdingFlag ? 1 : 0;
    
    if (currentState == LynkState.sadboi) sadCloud.animationTime = _animationTime;
    if (currentState == LynkState.thinking) thinkingBubbles.animationTime = _animationTime;
  }

  void _updateWandering(double dt) {
    _animationTime += dt * _animationSpeed;
    if (_targetPosition == null || position.distanceTo(_targetPosition!) < 15) {
      _generateNewTarget();
    }
    final direction = (_targetPosition! - position).normalized();
    position += direction * _moveSpeed * dt;
    _updateBreathing(vAmp: 0.02, hAmp: 0.015, pAmp: 0);
    _updateBlinking(dt);
    _handOffsetY = sin(_animationTime * 1.5) * 4;
  }

  void _updateStationary(double dt, {double speedMultiplier = 1.0, double? vAmp, double? hAmp}) {
    _animationTime += dt * _animationSpeed * speedMultiplier;
    _updateBreathing(vAmp: vAmp ?? -1, hAmp: hAmp ?? -1);
    _updateBlinking(dt);
    _handOffsetY = sin(_animationTime * 1.5) * 4;
  }

  void _updateListening(double dt) {
    _animationTime += dt * _animationSpeed;
    angle = sin(_animationTime * 2.5) * 0.15;
    _updateBreathing(vAmp: 0.02, hAmp: 0.02, pAmp: 1.0);
  }

  void _updateAngry(double dt) {
    final shakeIntensity = 2.0;
    final newPos = _initialPosition.clone();
    newPos.x += (Random().nextDouble() - 0.5) * shakeIntensity;
    newPos.y += (Random().nextDouble() - 0.5) * shakeIntensity;
    position = newPos;
  }

  void _updateDizzy(double dt) {
    _animationTime += dt * 0.7;
    _dizzyRotationTime += dt * 2.5;
    angle = sin(_animationTime) * 0.15;
    position.y = _initialPosition.y + cos(_animationTime * 2) * 5;
  }

  void _generateNewTarget() {
    final random = Random();
    final padding = size.x;
    _targetPosition = Vector2(
      padding + random.nextDouble() * (_gameBounds.x - padding * 2),
      padding + random.nextDouble() * (_gameBounds.y - padding * 2),
    );
  }

  void _updateBreathing({double vAmp = -1, double hAmp = -1, double pAmp = -1}) {
    final verticalAmp = vAmp == -1 ? _verticalBreathAmplitude : vAmp;
    final horizontalAmp = hAmp == -1 ? _horizontalBreathAmplitude : hAmp;
    final positionAmp = pAmp == -1 ? _verticalPositionAmplitude : pAmp;
    final breathValue = sin(_animationTime);
    scale = Vector2(1.0 + breathValue * horizontalAmp, 1.0 + breathValue * verticalAmp);
    if (positionAmp > 0) {
      position.y = _initialPosition.y - (((breathValue + 1) / 2) * positionAmp);
    }
  }

  void _updateBlinking(double dt) {
    _blinkTimer += dt;
    if (_blinkTimer >= _nextBlinkInterval) {
      _isBlinking = true;
      _blinkTimer = 0;
      _nextBlinkInterval = 2.0 + Random().nextDouble() * 3.0;
    }
    if (_isBlinking && _blinkTimer > 0.15) {
      _isBlinking = false;
    }
  }

  void _updateTapAnimation(double dt) {
    if (_isTapped) {
      _tapAnimationTime += dt;
      final progress = _tapAnimationTime / _tapDuration;
      final curve = sin(pi * progress);
      final tapScaleX = curve * 0.1;
      final tapScaleY = curve * 0.2;
      scale.x += tapScaleX;
      scale.y += tapScaleY;
      if (_tapAnimationTime >= _tapDuration) {
        _isTapped = false;
        _tapAnimationTime = 0;
      }
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (!_isTapped) {
      _isTapped = true;
      _tapAnimationTime = 0;
    }
  }
}
