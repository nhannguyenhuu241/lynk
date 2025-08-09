enum LynkState {
  /// Trạng thái bình thường thở mặc định
  idle,
  /// Trạng thái ngủ sẽ nhắm mắt 2 tay nằm 1 bên như bé đang nằm dựa vào và có chữ zzz như đang ngủ
  sleeping,
  /// Cảm xúc hạnh phúc tươi cười và 2 tay hoạt động phấn khởi
  happy,
  /// Bé nắm mắt 2 tay chập lại con mắt thứ 3 trên tráng mở ra suy nghĩ
  thinking,
  /// 2 tay từ trong thân thể hiện ra và chào mừng
  welcoming,
  /// Bé chuyển màu đỏ mắt miệng và tay thể hiện tức giận
  angry,
  /// Bé sẽ thể hiện ngạc nhiên
  amazed,
  /// Đeo mắt kính tay say hi
  trolling,
  /// Mặt xụ xuống buồn bã bé chuyển màu tái nhạt , mắt có nước mắt trên đầu có cục mây xám có tia điện sét
  sadboi,
  /// Trạng thái lắng nghe câu hỏi (khi người dùng đang gõ)
  listening,
  /// Cảm thấy sốc sợ hãi
  scared,
  /// Cảm thấy chóng mặt, đôi mắt là xoắn ốc xoay xoay miện chảy nước miếng
  dizzy,
  /// Ngáp ngủ giống mới thức dậy
  sleepy,
  /// Trạng thái màu xanh lá, mặt buồn hết sức sống
  lowenergy,
  /// Trạng thái cầm cờ quốc gia - vui vẻ và tự hào
  holdingFlag,
}

enum TimeOfDayState {
  sunrise,
  day,
  sunset,
  night
}

enum WeatherState {
  clear,
  sunnyWithClouds,
  raining,
  drizzle, // Mưa nhỏ
  stormy, // Bão có sấm sét
  snowing, // Tuyết rơi
  foggy, // Sương mù
}

enum TailDirection { left, top, right, bottom }
enum BotReplyLayout { short, medium, long }
