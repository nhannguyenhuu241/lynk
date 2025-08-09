# Zodiac Selection Module

Màn hình chọn cung mệnh theo design đã được phê duyệt với đầy đủ chức năng và animations.

## ✨ Features

### 🎨 UI Components
- **Bot Avatar**: Sử dụng LynkFlameWidget với animations dynamic
- **Chat Bubble**: Typing effect với glassmorphism design  
- **Zodiac Grid**: 12 cung hoàng đạo layout 3x4 với staggered animations
- **Confirm Button**: Interactive button với pulse effects

### 🎭 Interactions
- **Tap cung**: Bot giải thích cung được chọn với typing effect
- **Selected state**: Visual feedback rõ ràng cho cung được chọn
- **Confirm**: Button chỉ active khi đã chọn cung

### 🎨 Visual Design
- **Theme Integration**: Sử dụng AppColors (coral, mint, lavender, sunnyYellow)
- **Responsive**: Adaptive design cho mọi screen size
- **Animations**: Smooth transitions với staggered effects
- **Glassmorphism**: Modern glass effects

## 📱 Usage

### Basic Implementation
```dart
import 'package:lynk_an/presentation/modules/authen_module/zodiac_selection/zodiac_selection.dart';

// Navigate to zodiac selection
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => ZodiacSelectionScreen(
      onZodiacSelected: (zodiac) {
        // Handle zodiac selection
        print('Selected: ${zodiac.nameVi} ${zodiac.symbol}');
        // Navigate to next screen or save to preferences
      },
    ),
  ),
);
```

### With Custom Callback
```dart
ZodiacSelectionScreen(
  onZodiacSelected: (ZodiacModel zodiac) {
    // Save to user profile
    UserPreferences.setZodiac(zodiac.id);
    
    // Navigate to next onboarding step
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => NextOnboardingScreen()),
    );
  },
)
```

## 🏗️ Architecture

### Bloc Pattern
```
ZodiacSelectionBloc
├── Events
│   ├── ZodiacSelectedEvent
│   ├── ZodiacConfirmedEvent
│   └── BotMessageDisplayedEvent
└── States
    ├── ZodiacSelectionInitial
    ├── ZodiacSelectionLoaded
    └── ZodiacSelectionConfirmed
```

### File Structure
```
zodiac_selection/
├── src/
│   ├── bloc/
│   │   └── zodiac_selection_bloc.dart
│   ├── model/
│   │   └── zodiac_model.dart
│   ├── ui/
│   │   └── zodiac_selection_screen.dart
│   └── widget/
│       ├── zodiac_item_widget.dart
│       ├── zodiac_chat_bubble.dart
│       └── zodiac_confirm_button.dart
├── zodiac_selection.dart (exports)
├── example_usage.dart
└── README.md
```

## 🎯 Bot Messages

### Default Message
"Chào bạn! 🌟 Lynk tặng bạn món quà đặc biệt - xem miễn phí 1 cung mệnh! Hãy chọn cung nào bạn muốn khám phá nhé! ✨"

### Zodiac Explanations
Mỗi cung có message riêng với emoji và personality phù hợp:
- 🔥 **Bạch Dương**: "Cung mệnh của những người dũng cảm và năng lượng bất tận!"
- 🌱 **Kim Ngưu**: "Cung mệnh của sự ổn định và vẻ đẹp!"
- 🌟 **Song Tử**: "Cung mệnh của sự thông minh và linh hoạt!"
- ... (và 9 cung còn lại)

## 🎨 Design System

### Colors by Element
- **Hỏa** (Bạch Dương, Sư Tử, Nhân Mã): `AppColors.coral`
- **Thổ** (Kim Ngưu, Xử Nữ, Ma Kết): `AppColors.mint`  
- **Khí** (Song Tử, Thiên Bình, Bảo Bình): `AppColors.sunnyYellow`
- **Thủy** (Cự Giải, Bọ Cạp, Song Ngư): `AppColors.lavender`

### Animations
- **Staggered Entry**: Các cung xuất hiện tuần tự
- **Scale & Bounce**: Feedback khi tap
- **Typing Effect**: Bot message với typing animation
- **Pulse Effect**: Confirm button khi enabled
- **Background**: Rotating gradient theo time of day

## 🔧 Dependencies

Make sure these are added to `pubspec.yaml`:
```yaml
dependencies:
  flutter_bloc: ^8.1.6
  equatable: ^2.0.5
  flame: ^1.17.0 # Already exists
```

## 📊 Data Model

### ZodiacModel
```dart
class ZodiacModel {
  final String id;           // 'aries', 'taurus', etc.
  final String nameVi;       // 'Bạch Dương'
  final String nameEn;       // 'Aries'  
  final String symbol;       // '♈'
  final String dateRange;    // '21/3 - 19/4'
  final String description;  // Detailed description
  final String element;      // 'Hỏa', 'Thổ', 'Khí', 'Thủy'
  final String personality;  // Key traits
  final String color;        // Hex color
}
```

## 🚀 Integration Notes

1. **Bot States**: Sử dụng `LynkState.welcoming` và `LynkState.happy`
2. **Theme**: Fully integrated với existing AppColors và AppFonts
3. **Navigation**: Sử dụng callback pattern để flexible integration
4. **Responsive**: Tested trên multiple screen sizes
5. **Performance**: Optimized animations và memory usage

## 🎪 Animation Details

### Entry Animations
- Bot avatar: Scale + bounce
- Chat bubble: Slide from left + fade
- Zodiac items: Staggered scale với elastic curve
- Confirm button: Slide from bottom

### Interaction Animations  
- Zodiac selection: Scale + color change + shadow
- Button press: Scale down feedback
- Message typing: Character-by-character reveal
- Background: Slow rotation gradient

## 🔮 Future Enhancements

- **Sound Effects**: Tap sounds và background music
- **Haptic Feedback**: Vibration on selections
- **3D Effects**: Parallax scrolling
- **Personalization**: Custom zodiac colors
- **Analytics**: Track most selected zodiacs