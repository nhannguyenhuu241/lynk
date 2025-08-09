import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lynk_an/presentation/modules/authen_module/splash/src/bloc/splash_boc.dart';
import 'package:lynk_an/common/assets.dart';
import 'package:lynk_an/common/globals.dart';
import 'package:lynk_an/common/theme.dart';
import 'package:lynk_an/common/utils/custom_navigator.dart';
import 'package:lynk_an/common/widgets/widget.dart';
import 'package:lynk_an/data/local/shared_prefs/shared_prefs_key.dart';
import 'package:lynk_an/presentation/modules/authen_module/language_selection/src/ui/language_selection_screen.dart';
import 'package:lynk_an/presentation/modules/authen_module/onboarding_module/src/ui/onboarding_screen.dart';
import 'package:lynk_an/presentation/modules/main_modules/main_chat_module/src/ui/chat_screen.dart';
import 'package:lynk_an/presentation/modules/authen_module/zodiac_selection/src/ui/zodiac_selection_screen.dart';
import 'package:lynk_an/data/services/user_profile_service.dart';
import 'package:lynk_an/common/localization/app_localizations.dart';
import 'package:lynk_an/common/lang_key.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late SplashBoc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = SplashBoc(context);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await _setupListeners();
      _bloc.initializeApp();
    });
  }

  Future<void> _setupListeners() async {
    _bloc.initializationCompleteStream.listen((result) {
      if (mounted) {
        if (result.isInit && result.profileModel != null) {
          // User is initialized - go to chat
          if (result.shouldShowWelcomeMessage) {
            // Show welcome back message for returning active user
            _showWelcomeBackMessage(() {
              CustomNavigator.pushReplacement(
                context,
                ChatScreen(model: result.profileModel!, isInit: false),
                animationType: AnimationType.slide,
              );
            });
          } else {
            // Check if user has selected zodiac
            final hasSelectedZodiac = UserProfileService.hasSelectedZodiac();
            if (!hasSelectedZodiac) {
              // Go to zodiac selection
              CustomNavigator.pushReplacement(
                context,
                ZodiacSelectionScreen(model: result.profileModel!),
                animationType: AnimationType.slide,
              );
            } else {
              // Go directly to chat
              CustomNavigator.pushReplacement(
                context,
                ChatScreen(model: result.profileModel!, isInit: false),
                animationType: AnimationType.slide,
              );
            }
          }
        } else {
          // User is not initialized - go to registration flow
          _navigateToRegistrationFlow();
        }
      }
    });
  }

  void _navigateToRegistrationFlow() {
    // Check if language has been selected
    final bool languageSelected = Globals.prefs.getBool(SharedPrefsKey.language_selected, value: false);
    
    if (!languageSelected) {
      // Show language selection screen first
      CustomNavigator.pushReplacement(
        context,
        LanguageSelectionScreen(),
        animationType: AnimationType.slide,
      );
    } else {
      // Go directly to onboarding
      CustomNavigator.pushReplacement(
        context,
        OnboardingScreen(),
        animationType: AnimationType.slide,
      );
    }
  }

  void _showWelcomeBackMessage(VoidCallback onComplete) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.favorite, color: Colors.pink),
              SizedBox(width: 8),
              Text(
                AppLocalizations.text(LangKey.app_name),
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
          content: Text(
            AppLocalizations.text(LangKey.welcome_back_message),
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onComplete();
              },
              child: Text(
                AppLocalizations.text(LangKey.continueString),
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _body() {
    return Stack(
      children: [
        // Bright Playful Background
        const BrightPlayfulBackground(),
        // Content with enhanced cosmic theme
        Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                child: CustomIconSplashAnimation(
                  iconPath: Assets.iconApp,
                  size: 250.0,
                ),
              ),
              const SizedBox(height: 40),
              const Spacer(),
              CustomLoadingIndicator(
                effectType: LoadingEffectType.bouncingDots,
                size: 50.0,
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Use white for bright effect
      body: _body(),
    );
  }
}

// ============================================================================
// BRIGHT PLAYFUL BACKGROUND IMPLEMENTATION
// ============================================================================

/// Bright Playful Background với gentle waves và colorful bubbles
class BrightPlayfulBackground extends StatefulWidget {
  const BrightPlayfulBackground({super.key});

  @override
  State<BrightPlayfulBackground> createState() => _BrightPlayfulBackgroundState();
}

class _BrightPlayfulBackgroundState extends State<BrightPlayfulBackground>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _bubbleController;
  late AnimationController _gradientController;
  
  late Animation<double> _waveAnimation;
  late Animation<double> _bubbleAnimation;
  late Animation<double> _gradientAnimation;

  final List<PlayfulBubble> _bubbles = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateBubbles();
  }

  void _initializeAnimations() {
    // Wave animation - gentle, slow movement
    _waveController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();

    // Bubble animation - floating bubbles
    _bubbleController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();

    // Gradient animation - slow color transitions
    _gradientController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    _bubbleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bubbleController, curve: Curves.linear),
    );

    _gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _gradientController, curve: Curves.easeInOut),
    );
  }

  void _generateBubbles() {
    final random = math.Random();
    // Generate 8-10 floating bubbles for optimal performance vs visual appeal
    final bubbleCount = 8 + random.nextInt(3);
    
    for (int i = 0; i < bubbleCount; i++) {
      _bubbles.add(PlayfulBubble(
        position: Offset(
          random.nextDouble(),
          random.nextDouble(),
        ),
        size: 25.0 + random.nextDouble() * 35.0, // Slightly larger bubbles, fewer needed
        color: _getRandomBrightColor(random),
        floatOffset: random.nextDouble() * 2 * math.pi,
        speed: 0.4 + random.nextDouble() * 0.3, // Slightly faster for more liveliness
      ));
    }
  }

  Color _getRandomBrightColor(math.Random random) {
    final colors = [
      AppColors.coral,
      AppColors.mint,
      AppColors.lavender,
      AppColors.sunnyYellow,
      AppColors.peach,
      AppColors.skyBlue,
    ];
    return colors[random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _waveController.dispose();
    _bubbleController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _waveController,
          _bubbleController,
          _gradientController,
        ]),
        builder: (context, child) {
          return Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              gradient: _buildBrightGradient(),
            ),
            child: Stack(
              children: [
                // Wave Layer - gentle background waves
                Positioned.fill(
                  child: CustomPaint(
                    painter: BrightWavePainter(
                      animation: _waveAnimation.value,
                      screenSize: size,
                    ),
                  ),
                ),
                // Bubble Layer - floating colorful bubbles
                Positioned.fill(
                  child: CustomPaint(
                    painter: PlayfulBubblePainter(
                      bubbles: _bubbles,
                      animation: _bubbleAnimation.value,
                      screenSize: size,
                    ),
                  ),
                ),
                // Subtle center glow overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.2,
                        colors: [
                          Colors.white.withValues(alpha: 0.3),
                          Colors.white.withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  LinearGradient _buildBrightGradient() {
    final animationValue = _gradientAnimation.value;
    final hour = DateTime.now().hour;
    
    List<Color> baseColors;
    
    // Time-based bright colors
    if (hour >= 6 && hour < 12) {
      // Morning - energetic coral to yellow
      baseColors = AppTheme.getBrightMorningGradient();
    } else if (hour >= 12 && hour < 17) {
      // Day - fresh mint to sky
      baseColors = AppTheme.getBrightDayGradient();
    } else if (hour >= 17 && hour < 21) {
      // Evening - warm coral to lavender
      baseColors = AppTheme.getBrightEveningGradient();
    } else {
      // Night - gentle lavender to mint
      baseColors = AppTheme.getBrightNightGradient();
    }
    
    // Add gentle animation to the colors
    final animatedColors = baseColors.map((color) {
      final brightness = 0.8 + 0.2 * math.sin(animationValue * 2 * math.pi);
      return Color.lerp(color, Colors.white, (1.0 - brightness) * 0.2) ?? color;
    }).toList();
    
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: animatedColors,
      stops: const [0.0, 0.5, 1.0],
    );
  }
}

// ============================================================================
// DATA MODELS
// ============================================================================

/// Playful Bubble data model for bright theme
class PlayfulBubble {
  final Offset position; // Position as percentage (0.0 - 1.0)
  final double size; // Bubble size
  final Color color; // Bubble color
  final double floatOffset; // Phase offset for floating animation
  final double speed; // Animation speed multiplier

  const PlayfulBubble({
    required this.position,
    required this.size,
    required this.color,
    required this.floatOffset,
    required this.speed,
  });
}

// ============================================================================
// CUSTOM PAINTERS
// ============================================================================

/// Bright Wave Painter - Draws gentle animated waves for background
class BrightWavePainter extends CustomPainter {
  final double animation;
  final Size screenSize;

  BrightWavePainter({
    required this.animation,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final wavePaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

    // Draw multiple gentle waves
    _drawWave(canvas, size, wavePaint, 0.3, AppColors.coral.withValues(alpha: 0.1));
    _drawWave(canvas, size, wavePaint, 0.5, AppColors.mint.withValues(alpha: 0.08));
    _drawWave(canvas, size, wavePaint, 0.7, AppColors.lavender.withValues(alpha: 0.06));
  }

  void _drawWave(Canvas canvas, Size size, Paint paint, double heightFactor, Color color) {
    paint.color = color;
    
    final path = Path();
    final waveHeight = size.height * heightFactor;
    final waveLength = size.width * 1.5;
    
    path.moveTo(0, size.height);
    
    for (double x = 0; x <= size.width; x += 6) { // Slightly less dense for better performance
      final y = waveHeight + 
          math.sin((x / waveLength * 2 * math.pi) + (animation * 2 * math.pi)) * 25 +
          math.sin((x / waveLength * 4 * math.pi) + (animation * 1.5 * math.pi)) * 12;
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(BrightWavePainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

/// Playful Bubble Painter - Draws floating colorful bubbles
class PlayfulBubblePainter extends CustomPainter {
  final List<PlayfulBubble> bubbles;
  final double animation;
  final Size screenSize;

  PlayfulBubblePainter({
    required this.bubbles,
    required this.animation,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bubblePaint = Paint()
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);

    for (final bubble in bubbles) {
      final basePosition = Offset(
        bubble.position.dx * size.width,
        bubble.position.dy * size.height,
      );

      // Gentle floating animation
      final floatX = math.sin(animation * 2 * math.pi * bubble.speed + bubble.floatOffset) * 15;
      final floatY = math.cos(animation * 1.5 * math.pi * bubble.speed + bubble.floatOffset) * 10;
      
      final animatedPosition = basePosition + Offset(floatX, floatY);

      // Gentle size pulsing
      final pulse = 1.0 + math.sin(animation * 3 * math.pi + bubble.floatOffset) * 0.1;
      final animatedSize = bubble.size * pulse;

      // Soft opacity variation
      final opacity = 0.6 + 0.3 * math.sin(animation * 2 * math.pi + bubble.floatOffset);

      // Draw bubble glow
      glowPaint.color = bubble.color.withValues(alpha: opacity * 0.3);
      canvas.drawCircle(animatedPosition, animatedSize * 1.5, glowPaint);

      // Draw main bubble with gradient effect
      final bubbleGradient = RadialGradient(
        colors: [
          bubble.color.withValues(alpha: opacity * 0.4),
          bubble.color.withValues(alpha: opacity * 0.2),
          bubble.color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.7, 1.0],
      );

      bubblePaint.shader = bubbleGradient.createShader(
        Rect.fromCircle(center: animatedPosition, radius: animatedSize),
      );
      
      canvas.drawCircle(animatedPosition, animatedSize, bubblePaint);

      // Draw highlight for depth
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: opacity * 0.4)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        animatedPosition + Offset(-animatedSize * 0.3, -animatedSize * 0.3),
        animatedSize * 0.2,
        highlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(PlayfulBubblePainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
