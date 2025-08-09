import 'dart:convert';

/// Model cho từng section trong đọc tử vi
class ZodiacReadingSection {
  final String id;
  final String title;
  final Map<String, dynamic> content;

  ZodiacReadingSection({
    required this.id,
    required this.title,
    required this.content,
  });

  factory ZodiacReadingSection.fromJson(String id, Map<String, dynamic> json) {
    return ZodiacReadingSection(
      id: id,
      title: json['section_title'] ?? json['title'] ?? '',
      content: json['content'] ?? json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
    };
  }
}

/// Model chính cho đọc tử vi
class ZodiacReadingModel {
  final String palaceId;
  final String palaceName;
  final String month;
  final String year;
  final List<ZodiacReadingSection> sections;

  ZodiacReadingModel({
    required this.palaceId,
    required this.palaceName,
    required this.month,
    required this.year,
    required this.sections,
  });

  /// Tạo ZodiacReadingModel từ template và thông tin cung
  factory ZodiacReadingModel.fromTemplate({
    required String palaceId,
    required Map<String, dynamic> template,
    required Map<String, dynamic> palaceInfo,
    required String month,
    required String year,
  }) {
    final structure = template['structure'] as Map<String, dynamic>;
    final List<ZodiacReadingSection> sections = [];

    // Parse từng section theo ID
    structure.forEach((sectionId, sectionData) {
      sections.add(ZodiacReadingSection.fromJson(sectionId, sectionData));
    });

    return ZodiacReadingModel(
      palaceId: palaceId,
      palaceName: palaceInfo['name'] ?? '',
      month: month,
      year: year,
      sections: sections,
    );
  }

  /// Lấy section theo ID
  ZodiacReadingSection? getSectionById(String id) {
    try {
      return sections.firstWhere((section) => section.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Lấy nội dung của ID1 (tiêu đề và hook)
  Map<String, String> get headerInfo {
    final id1 = getSectionById('ID1');
    if (id1 == null) return {};
    
    return {
      'title': id1.content['title'] ?? '',
      'greeting': id1.content['greeting'] ?? '',
      'hook': id1.content['hook'] ?? '',
    };
  }

  /// Lấy tổng quan vận trình (ID2)
  Map<String, String> get overview {
    final id2 = getSectionById('ID2');
    if (id2 == null) return {};
    
    final contentRaw = id2.content['content'];
    final content = contentRaw is Map 
        ? Map<String, dynamic>.from(contentRaw)
        : <String, dynamic>{};
    return {
      'phase_1': content['phase_1'] ?? '',
      'phase_2': content['phase_2'] ?? '',
    };
  }

  /// Lấy highlight đặc biệt (ID3)
  Map<String, dynamic> get highlights {
    final id3 = getSectionById('ID3');
    if (id3 == null) return {};
    
    final contentRaw = id3.content['content'];
    final content = contentRaw is Map 
        ? Map<String, dynamic>.from(contentRaw)
        : <String, dynamic>{};
    return {
      'highlight_1': content['highlight_1'] ?? '',
      'highlight_2': content['highlight_2'] ?? '',
      'lucky_elements': content['lucky_elements'] ?? {},
    };
  }

  /// Lấy ngày vàng (ID4)
  List<Map<String, dynamic>> get goldenDays {
    final id4 = getSectionById('ID4');
    if (id4 == null) return [];
    
    final contentRaw = id4.content['content'];
    final content = contentRaw is Map 
        ? Map<String, dynamic>.from(contentRaw)
        : <String, dynamic>{};
    final days = content['golden_days'] as List<dynamic>? ?? [];
    
    return days.map((day) => day is Map ? Map<String, dynamic>.from(day) : <String, dynamic>{}).toList();
  }

  /// Lấy cảnh báo và tips (ID5)
  Map<String, String> get warningsAndTips {
    final id5 = getSectionById('ID5');
    if (id5 == null) return {};
    
    final contentRaw = id5.content['content'];
    final content = contentRaw is Map 
        ? Map<String, dynamic>.from(contentRaw)
        : <String, dynamic>{};
    return {
      'warning_1': content['warning_1'] ?? '',
      'warning_2': content['warning_2'] ?? '',
      'tip': content['tip'] ?? '',
    };
  }

  /// Lấy gợi ý phong thủy (ID6)
  Map<String, String> get fengShuiTips {
    final id6 = getSectionById('ID6');
    if (id6 == null) return {};
    
    final contentRaw = id6.content['content'];
    final content = contentRaw is Map 
        ? Map<String, dynamic>.from(contentRaw)
        : <String, dynamic>{};
    return {
      'space_tip': content['space_tip'] ?? '',
      'personal_tip': content['personal_tip'] ?? '',
      'challenge_tip': content['challenge_tip'] ?? '',
    };
  }

  /// Lấy phần kết (ID7)
  Map<String, String> get conclusion {
    final id7 = getSectionById('ID7');
    if (id7 == null) return {};
    
    return {
      'mini_bonus': id7.content['mini_bonus'] ?? '',
      'closing_wish': id7.content['closing_wish'] ?? '',
    };
  }

  /// Convert sang JSON
  Map<String, dynamic> toJson() {
    return {
      'palaceId': palaceId,
      'palaceName': palaceName,
      'month': month,
      'year': year,
      'sections': sections.map((section) => section.toJson()).toList(),
    };
  }

  /// Tạo từ JSON
  factory ZodiacReadingModel.fromJson(Map<String, dynamic> json) {
    final sectionsJson = json['sections'] as List<dynamic>? ?? [];
    final sections = sectionsJson.map((sectionJson) {
      final section = sectionJson as Map<String, dynamic>;
      return ZodiacReadingSection(
        id: section['id'],
        title: section['title'],
        content: section['content'],
      );
    }).toList();

    return ZodiacReadingModel(
      palaceId: json['palaceId'] ?? '',
      palaceName: json['palaceName'] ?? '',
      month: json['month'] ?? '',
      year: json['year'] ?? '',
      sections: sections,
    );
  }

  /// Convert sang JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Tạo từ JSON string
  factory ZodiacReadingModel.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return ZodiacReadingModel.fromJson(json);
  }
}

/// Service để load và xử lý template đọc tử vi
class ZodiacReadingService {
  static Map<String, dynamic>? _template;

  /// Load template từ JSON file
  static Future<void> loadTemplate(String jsonString) async {
    _template = jsonDecode(jsonString);
  }

  /// Tạo đọc tử vi cho cung cụ thể
  static ZodiacReadingModel? generateReading({
    required String palaceId,
    required String month,
    required String year,
  }) {
    if (_template == null) return null;

    final palaces = _template!['palaces'] as Map<String, dynamic>? ?? {};
    final palaceInfo = palaces[palaceId] as Map<String, dynamic>?;
    
    if (palaceInfo == null) return null;

    // Lấy sample prompt cho cung này hoặc sử dụng template chung
    final samplePrompts = _template!['sample_prompts'] as Map<String, dynamic>? ?? {};
    final templateData = samplePrompts[palaceId] ?? _template!['template'];

    return ZodiacReadingModel.fromTemplate(
      palaceId: palaceId,
      template: templateData,
      palaceInfo: palaceInfo,
      month: month,
      year: year,
    );
  }

  /// Lấy thông tin cung
  static Map<String, dynamic>? getPalaceInfo(String palaceId) {
    if (_template == null) return null;
    
    final palaces = _template!['palaces'] as Map<String, dynamic>? ?? {};
    return palaces[palaceId];
  }

  /// Lấy danh sách tất cả các cung
  static List<String> getAllPalaceIds() {
    if (_template == null) return [];
    
    final palaces = _template!['palaces'] as Map<String, dynamic>? ?? {};
    return palaces.keys.toList();
  }
}