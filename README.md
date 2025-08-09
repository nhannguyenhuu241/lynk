# LynkAn-App

Ứng dụng di động đa nền tảng (Android/iOS) phát triển bằng Flutter, tích hợp AI (OpenAI), Firebase và hỗ trợ đa ngôn ngữ (Tiếng Việt & Tiếng Anh).

## 🚀 Tính năng nổi bật

- Onboarding, Splash Screen hiện đại
- Chatbot AI (OpenAI)
- Quản lý thông tin cá nhân (tên, ngày sinh, giới tính)
- Lưu trữ dữ liệu local (Shared Preferences)
- Tích hợp Firebase (Authentication, Analytics, ...)
- Giao diện đẹp, nhiều widget tuỳ biến
- Hỗ trợ đa ngôn ngữ (Tiếng Việt, Tiếng Anh)

## 🏗️ Cấu trúc dự án

```
lib/
  common/         # Tiện ích, widget, theme, localization dùng chung
  data/           # Model, lưu trữ local, quản lý dữ liệu
  domain/         # Xử lý logic nghiệp vụ, gọi API
  presentation/   # Giao diện, chia module theo tính năng
assets/           # Ảnh, icon, font, file json đa ngôn ngữ
android/          # Cấu hình & mã nguồn native Android
ios/              # Cấu hình & mã nguồn native iOS
```

## ⚙️ Cài đặt & chạy dự án

### 1. Cài đặt Flutter

- Yêu cầu Flutter >= 3.x.x
- [Hướng dẫn cài đặt Flutter](https://flutter.dev/docs/get-started/install)

### 2. Clone dự án

```bash
git clone <link-repo>
cd LynkAn-App
```

### 3. Cài đặt dependencies

```bash
flutter pub get
```

### 4. Cấu hình Firebase

- Thêm file `google-services.json` vào `android/app/`
- Thêm file `GoogleService-Info.plist` vào `ios/Runner/`

### 5. Chạy ứng dụng

```bash
flutter run
```

## 🛠️ Hướng dẫn build ứng dụng

### Build Android APK

```bash
flutter build apk --release
```
- File APK sẽ nằm ở: `build/app/outputs/flutter-apk/app-release.apk`

### Build Android App Bundle (AAB)

```bash
flutter build appbundle --release
```
- File AAB sẽ nằm ở: `build/app/outputs/bundle/release/app-release.aab`

### Build iOS (Yêu cầu máy Mac)

```bash
flutter build ios --release
```
- Mở thư mục `ios/` bằng Xcode để archive và upload lên App Store.

### Một số lưu ý khi build

- Đảm bảo đã cập nhật các file cấu hình Firebase đúng vị trí.
- Kiểm tra lại `pubspec.yaml` đã khai báo đủ assets, fonts.
- Nếu gặp lỗi về package, thử chạy:
  ```bash
  flutter clean
  flutter pub get
  ```
- Đối với iOS, có thể cần chạy:
  ```bash
  cd ios
  pod install
  cd ..
  ```

## 🌐 Đa ngôn ngữ

- File ngôn ngữ: `assets/json/en.json`, `assets/json/vi.json`
- Thay đổi ngôn ngữ trong phần cài đặt hoặc theo ngôn ngữ hệ thống

## 🧩 Công nghệ sử dụng

- [Flutter](https://flutter.dev/)
- [Firebase](https://firebase.google.com/)
- [OpenAI API](https://platform.openai.com/)
- Shared Preferences

## 📁 Một số file quan trọng

- `pubspec.yaml`: Khai báo dependencies, assets, fonts
- `lib/main.dart`: Điểm khởi động ứng dụng
- `lib/presentation/`: Giao diện, các module chức năng
- `lib/domain/`: Xử lý logic, gọi API
- `lib/data/`: Model, lưu trữ local

## 📝 Đóng góp

1. Fork dự án & tạo branch mới
2. Commit & tạo pull request
3. Mô tả rõ ràng thay đổi của bạn

## 📄 Giấy phép

Dự án sử dụng giấy phép MIT. Xem chi tiết tại [LICENSE](LICENSE) (nếu có).
