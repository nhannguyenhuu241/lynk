import 'package:lynk_an/common/localization/app_localizations.dart';
import 'package:lynk_an/common/lang_key.dart';
import 'package:lynk_an/common/globals.dart';
import 'package:lynk_an/data/local/shared_prefs/shared_prefs_key.dart';

/// Model cho 12 cung tử vi
class ZodiacModel {
  final String id;
  final String nameVi;
  final String nameEn;
  final String nameKo;
  final String symbol;
  final String dateRange;
  final String description;
  final String element;
  final String personality;
  final String color;

  const ZodiacModel({
    required this.id,
    required this.nameVi,
    required this.nameEn,
    required this.nameKo,
    required this.symbol,
    required this.dateRange,
    required this.description,
    required this.element,
    required this.personality,
    required this.color,
  });

  /// Get localized name based on current language
  String get localizedName {
    final currentLanguage = Globals.prefs.getString(SharedPrefsKey.language) ?? LangKey.langVi;
    if (currentLanguage == LangKey.langEn) {
      return nameEn;
    } else if (currentLanguage == LangKey.langKo) {
      return nameKo;
    }
    return nameVi;
  }

  /// Danh sách 12 cung tử vi với thông tin đầy đủ
  static const List<ZodiacModel> allZodiacs = [
    ZodiacModel(
      id: 'menh',
      nameVi: 'Mệnh',
      nameEn: 'Life Palace',
      nameKo: '명궁',
      symbol: '命',
      dateRange: 'Cung chủ yếu',
      description: 'Cung Mệnh quyết định tính cách, vận mệnh và định hướng cuộc đời của một người.',
      element: 'Chủ vận',
      personality: 'Bản thân, tính cách, vận mệnh',
      color: '#FF6B6B',
    ),
    ZodiacModel(
      id: 'phuhuuynh',
      nameVi: 'Phụ Huynh',
      nameEn: 'Parents Palace',
      nameKo: '부모궁',
      symbol: '父',
      dateRange: 'Gia đình',
      description: 'Cung Phụ Huynh thể hiện mối quan hệ với cha mẹ, gia đình và những người có ơn.',
      element: 'Gia đình',
      personality: 'Hiếu thảo, tình cảm gia đình',
      color: '#4ECDC4',
    ),
    ZodiacModel(
      id: 'phucdue',
      nameVi: 'Phúc Đức',
      nameEn: 'Fortune Palace',
      nameKo: '복덕궁',
      symbol: '福',
      dateRange: 'Phúc khí',
      description: 'Cung Phúc Đức thể hiện sự may mắn, phúc khí và khả năng tích đức làm phước.',
      element: 'Phúc khí',
      personality: 'May mắn, hạnh phúc, tâm linh',
      color: '#FFE66D',
    ),
    ZodiacModel(
      id: 'dientrach',
      nameVi: 'Điền Trạch',
      nameEn: 'Property Palace',
      nameKo: '전택궁',
      symbol: '田',
      dateRange: 'Tài sản',
      description: 'Cung Điền Trạch liên quan đến nhà cửa, đất đai, tài sản và sự ổn định.',
      element: 'Tài sản',
      personality: 'Ổn định, tích lũy, bất động sản',
      color: '#B39CD0',
    ),
    ZodiacModel(
      id: 'quan_loc',
      nameVi: 'Quan Lộc',
      nameEn: 'Career Palace',
      nameKo: '관록궁',
      symbol: '官',
      dateRange: 'Sự nghiệp',
      description: 'Cung Quan Lộc quyết định sự nghiệp, địa vị xã hội và thành tựu trong công việc.',
      element: 'Sự nghiệp',
      personality: 'Tham vọng, lãnh đạo, quyền lực',
      color: '#FF9F43',
    ),
    ZodiacModel(
      id: 'noboc',
      nameVi: 'Nô Bộc',
      nameEn: 'Servants Palace',
      nameKo: '노복궁',
      symbol: '奴',
      dateRange: 'Bạn bè',
      description: 'Cung Nô Bộc thể hiện mối quan hệ với bạn bè, đồng nghiệp và khả năng lãnh đạo.',
      element: 'Nhân duyên',
      personality: 'Giao tiếp, lãnh đạo, bạn bè',
      color: '#6BCF7F',
    ),
    ZodiacModel(
      id: 'thienkhoi',
      nameVi: 'Thiên Khôi',
      nameEn: 'Migration Palace',
      nameKo: '천이궁',
      symbol: '遷',
      dateRange: 'Di chuyển',
      description: 'Cung Thiên Khôi liên quan đến việc di chuyển, du lịch và thay đổi môi trường.',
      element: 'Biến động',
      personality: 'Linh hoạt, thích khám phá, thay đổi',
      color: '#FF6B9D',
    ),
    ZodiacModel(
      id: 'tatach',
      nameVi: 'Tật Ách',
      nameEn: 'Health Palace',
      nameKo: '질액궁',
      symbol: '疾',
      dateRange: 'Sức khỏe',
      description: 'Cung Tật Ách thể hiện tình trạng sức khỏe, bệnh tật và khả năng phục hồi.',
      element: 'Sức khỏe',
      personality: 'Chăm sóc bản thân, sức khỏe',
      color: '#8B5A2B',
    ),
    ZodiacModel(
      id: 'taibach',
      nameVi: 'Tài Bạch',
      nameEn: 'Wealth Palace',
      nameKo: '재백궁',
      symbol: '財',
      dateRange: 'Tài chính',
      description: 'Cung Tài Bạch quyết định tài lộc, khả năng kiếm tiền và quản lý tài chính.',
      element: 'Tài lộc',
      personality: 'Kinh doanh, tích lũy, đầu tư',
      color: '#9B59B6',
    ),
    ZodiacModel(
      id: 'tutuc',
      nameVi: 'Tử Tức',
      nameEn: 'Children Palace',
      nameKo: '자식궁',
      symbol: '子',
      dateRange: 'Con cái',
      description: 'Cung Tử Tức liên quan đến con cái, thế hệ trẻ và khả năng giáo dục.',
      element: 'Thế hệ',
      personality: 'Yêu thương, giáo dục, truyền đạt',
      color: '#34495E',
    ),
    ZodiacModel(
      id: 'phuthe',
      nameVi: 'Phu Thê',
      nameEn: 'Spouse Palace',
      nameKo: '부처궁',
      symbol: '夫',
      dateRange: 'Hôn nhân',
      description: 'Cung Phu Thê thể hiện tình duyên, hôn nhân và mối quan hệ vợ chồng.',
      element: 'Tình duyên',
      personality: 'Tình cảm, hôn nhân, đôi lứa',
      color: '#00CED1',
    ),
    ZodiacModel(
      id: 'huynhde',
      nameVi: 'Huynh Đệ',
      nameEn: 'Siblings Palace',
      nameKo: '형제궁',
      symbol: '兄',
      dateRange: 'Anh em',
      description: 'Cung Huynh Đệ thể hiện mối quan hệ với anh chị em và khả năng hợp tác.',
      element: 'Huynh đệ',
      personality: 'Đoàn kết, hỗ trợ, tình bạn',
      color: '#87CEEB',
    ),
  ];

  /// Tìm cung tử vi theo ID
  static ZodiacModel? findById(String id) {
    try {
      return allZodiacs.firstWhere((zodiac) => zodiac.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Lấy message giải thích của bot cho cung tử vi
  String getBotExplanation() {
    String langKey;
    switch (id) {
      case 'menh':
        langKey = LangKey.zodiac_menh_explanation;
        break;
      case 'phuhuuynh':
        langKey = LangKey.zodiac_phuhuuynh_explanation;
        break;
      case 'phucdue':
        langKey = LangKey.zodiac_phucdue_explanation;
        break;
      case 'dientrach':
        langKey = LangKey.zodiac_dientrach_explanation;
        break;
      case 'quan_loc':
        langKey = LangKey.zodiac_quan_loc_explanation;
        break;
      case 'noboc':
        langKey = LangKey.zodiac_noboc_explanation;
        break;
      case 'thienkhoi':
        langKey = LangKey.zodiac_thienkhoi_explanation;
        break;
      case 'tatach':
        langKey = LangKey.zodiac_tatach_explanation;
        break;
      case 'taibach':
        langKey = LangKey.zodiac_taibach_explanation;
        break;
      case 'tutuc':
        langKey = LangKey.zodiac_tutuc_explanation;
        break;
      case 'phuthe':
        langKey = LangKey.zodiac_phuthe_explanation;
        break;
      case 'huynhde':
        langKey = LangKey.zodiac_huynhde_explanation;
        break;
      default:
        return 'Wow! Cung tử vi thật đặc biệt! Hãy để Lynk khám phá thêm về bạn nhé! ✨';
    }
    return AppLocalizations.text(langKey);
  }

  /// Lấy danh sách màu sắc đẹp cho các chip (gradient colors)
  static List<List<String>> get chipGradientColors => [
    ['#FF6B6B', '#FF8E53'],
    ['#4ECDC4', '#44A08D'],
    ['#FFE66D', '#FF9A8B'],
    ['#B39CD0', '#C58AF9'],
    ['#FF9F43', '#FDBB2D'],
    ['#6BCF7F', '#4CB8C4'],
    ['#FF6B9D', '#C44569'],
    ['#8B5A2B', '#D2691E'],
    ['#9B59B6', '#8E44AD'],
    ['#34495E', '#2C3E50'],
    ['#00CED1', '#20B2AA'],
    ['#87CEEB', '#4682B4'],
  ];

  /// Lấy màu gradient cho chip dựa trên index
  List<String> getChipGradient(int index) {
    final colors = chipGradientColors;
    return colors[index % colors.length];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZodiacModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ZodiacModel(id: $id, name: $localizedName, symbol: $symbol)';
}