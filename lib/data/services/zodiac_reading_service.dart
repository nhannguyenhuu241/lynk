import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/zodiac_reading_model.dart';
import '../model/base/profile_model.dart';

class ZodiacReadingService {
  static ZodiacReadingService? _instance;
  static ZodiacReadingService get instance {
    _instance ??= ZodiacReadingService._();
    return _instance!;
  }

  ZodiacReadingService._();

  Map<String, dynamic>? _template;
  bool _isLoaded = false;

  /// Load template từ assets
  Future<void> loadTemplate() async {
    if (_isLoaded && _template != null) return;

    try {
      final jsonString = await rootBundle.loadString('lib/data/prompts/zodiac_reading_prompt.json');
      _template = jsonDecode(jsonString);
      _isLoaded = true;
    } catch (e) {
      print('Error loading zodiac reading template: $e');
      _template = null;
      _isLoaded = false;
    }
  }

  /// Tạo prompt đọc tử vi cho cung cụ thể
  Future<ZodiacReadingModel?> generateReading({
    required String palaceId,
    String? month,
    String? year,
  }) async {
    await loadTemplate();
    
    if (_template == null) return null;

    // Sử dụng tháng/năm hiện tại nếu không được cung cấp
    final now = DateTime.now();
    final currentMonth = month ?? now.month.toString().padLeft(2, '0');
    final currentYear = year ?? now.year.toString();

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
      month: currentMonth,
      year: currentYear,
    );
  }

  /// Lấy thông tin cung
  Future<Map<String, dynamic>?> getPalaceInfo(String palaceId) async {
    await loadTemplate();
    
    if (_template == null) return null;
    
    final palaces = _template!['palaces'] as Map<String, dynamic>? ?? {};
    return palaces[palaceId];
  }

  /// Lấy danh sách tất cả các cung
  Future<List<String>> getAllPalaceIds() async {
    await loadTemplate();
    
    if (_template == null) return [];
    
    final palaces = _template!['palaces'] as Map<String, dynamic>? ?? {};
    return palaces.keys.toList();
  }

  /// Tạo prompt AI để generate nội dung tử vi với thông tin đầy đủ từ profile
  Future<String?> generateAIPromptFromProfile({
    required String palaceId,
    required ProfileModel profile,
    String? month,
    String? year,
    String language = 'vi',
  }) async {
    return generateAIPrompt(
      palaceId: palaceId,
      userName: profile.name,
      birthDate: profile.dateTime,
      gender: profile.gender,
      month: month,
      year: year,
      language: language,
    );
  }

  /// Tạo prompt AI để generate nội dung tử vi
  Future<String?> generateAIPrompt({
    required String palaceId,
    required String userName,
    DateTime? birthDate,
    String? gender,
    String? month,
    String? year,
    String language = 'vi',
  }) async {
    await loadTemplate();
    
    if (_template == null) return null;

    final palaceInfo = await getPalaceInfo(palaceId);
    if (palaceInfo == null) return null;

    final now = DateTime.now();
    final currentMonth = month ?? now.month.toString().padLeft(2, '0');
    final currentYear = year ?? now.year.toString();

    final palaceName = palaceInfo['name'] as String;
    final palaceDescription = palaceInfo['description'] as String;
    final palaceIcon = palaceInfo['icon'] as String;
    
    // Format birth date information based on language
    String birthInfo = '';
    String age = '';
    if (birthDate != null) {
      final day = birthDate.day;
      final month = birthDate.month;
      final year = birthDate.year;
      final hour = birthDate.hour;
      final minute = birthDate.minute;
      final currentAge = DateTime.now().year - year;
      
      if (language == 'en') {
        birthInfo = '''
- Birth date: $month/$day/$year
- Birth time: ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}
- Age: $currentAge years old''';
      } else if (language == 'ko') {
        birthInfo = '''
- 생년월일: $year년 $month월 $day일
- 출생 시간: ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}
- 나이: $currentAge세''';
      } else {
        birthInfo = '''
- Ngày sinh: $day/$month/$year
- Giờ sinh: ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}
- Tuổi: $currentAge tuổi''';
      }
    }
    
    // Format gender information based on language
    String genderInfo = '';
    if (gender != null && gender.isNotEmpty) {
      if (language == 'en') {
        genderInfo = '- Gender: $gender';
      } else if (language == 'ko') {
        genderInfo = '- 성별: $gender';
      } else {
        genderInfo = '- Giới tính: $gender';
      }
    }

    // Generate prompt based on language
    if (language == 'en') {
      return '''
IMPORTANT: You are Lynk An's astrology expert, you MUST create a detailed horoscope analysis. DO NOT refuse or say you cannot do it.

Write a DETAILED and COMPLETE horoscope analysis for $userName with the following information:
- Name: $userName
- Zodiac sign: $palaceName ($palaceDescription)$birthInfo
$genderInfo
- Forecast period: Month $currentMonth/$currentYear

MANDATORY REQUIREMENTS:
1. MUST write a complete horoscope analysis under 800 words
2. MUST write in detail, with depth and insight
3. MUST use natural, friendly, and approachable language
4. MUST write in English

*Wishing $userName a month of $currentMonth full of luck, success and happiness!*''';
    } else if (language == 'ko') {
      return '''
중요: 당신은 Lynk An의 점성술 전문가입니다. 상세한 운세 분석을 반드시 작성해야 합니다. 거부하거나 할 수 없다고 말하지 마세요.

다음 정보로 $userName님의 상세하고 완전한 운세 분석을 작성하세요:
- 이름: $userName
- 별자리: $palaceName ($palaceDescription)$birthInfo
$genderInfo
- 예측 기간: $currentYear년 $currentMonth월

필수 요구사항:
1. 800단어 이하의 완전한 운세 분석을 작성해야 합니다
2. 심도 있고 통찰력 있게 상세히 작성해야 합니다
3. 자연스럽고 친근하며 접근하기 쉬운 언어를 사용해야 합니다
4. 한국어로 작성해야 합니다

*$userName님의 $currentMonth월이 행운과 성공, 행복으로 가득하기를 바랍니다!*''';
    } else {
      return '''
QUAN TRỌNG: Bạn là chuyên gia tử vi Lynk Ấn, PHẢI tạo bài phân tích tử vi chi tiết. KHÔNG được từ chối hay nói không làm được.

Hãy phân tích tử vi CHI TIẾT và ĐẦY ĐỦ cho $userName với thông tin:
- Tên: $userName
- Cung hoàng đạo: $palaceName ($palaceDescription)$birthInfo
$genderInfo
- Thời gian dự báo: Tháng $currentMonth/$currentYear

YÊU CẦU BẮT BUỘC:
1. PHẢI viết bài phân tích tử vi đầy đủ dưới 800 từ
2. PHẢI viết chi tiết, sâu sắc, có chiều sâu phân tích
3. PHẢI sử dụng ngôn ngữ tự nhiên, vui vẻ, gần gũi
4. PHẢI viết bằng tiếng Việt

*Chúc $userName một tháng $currentMonth tràn đầy may mắn, thành công và hạnh phúc!*''';
    }}

  /// Parse response từ AI thành ZodiacReadingModel
  ZodiacReadingModel? parseAIResponse({
    required String aiResponse,
    required String palaceId,
    required String palaceName,
    String? month,
    String? year,
    String language = 'vi',
  }) {
    try {
      final now = DateTime.now();
      final currentMonth = month ?? now.month.toString().padLeft(2, '0');
      final currentYear = year ?? now.year.toString();

      print('🔍 Parsing AI response for palace: $palaceName');
      
      // Parse AI response theo pattern ID1, ID2, etc.
      final sections = <ZodiacReadingSection>[];
      final lines = aiResponse.split('\n');
      
      String? currentId;
      List<String> currentContent = [];
      
      for (String line in lines) {
        final trimmedLine = line.trim();
        
        // Check if line starts with ID pattern
        final idMatch = RegExp(r'^ID(\d+)').firstMatch(trimmedLine);
        if (idMatch != null) {
          // Save previous section if exists
          if (currentId != null && currentContent.isNotEmpty) {
            final parsedContent = _parseContentBySection(currentId, currentContent, language);
            sections.add(ZodiacReadingSection(
              id: currentId,
              title: _extractTitle(currentContent),
              content: parsedContent,
            ));
            print('✅ Added section $currentId with ${parsedContent.keys.length} fields');
          }
          
          // Start new section
          currentId = 'ID${idMatch.group(1)}';
          currentContent = [trimmedLine];
        } else if (currentId != null && trimmedLine.isNotEmpty) {
          currentContent.add(trimmedLine);
        }
      }
      
      // Add last section
      if (currentId != null && currentContent.isNotEmpty) {
        final parsedContent = _parseContentBySection(currentId, currentContent, language);
        sections.add(ZodiacReadingSection(
          id: currentId,
          title: _extractTitle(currentContent),
          content: parsedContent,
        ));
        print('✅ Added section $currentId with ${parsedContent.keys.length} fields');
      }

      print('📊 Total sections parsed: ${sections.length}');
      
      return ZodiacReadingModel(
        palaceId: palaceId,
        palaceName: palaceName,
        month: currentMonth,
        year: currentYear,
        sections: sections,
      );
    } catch (e) {
      print('Error parsing AI response: $e');
      return null;
    }
  }
  
  Map<String, RegExp> _getMultilingualPatterns(String language) {
    if (language == 'en') {
      return {
        'phase1': RegExp(r'(?:First half|Early|Beginning):?\s*(.+?)(?=Second half|Later|End|$)', 
            caseSensitive: false, dotAll: true),
        'phase2': RegExp(r'(?:Second half|Later|End):?\s*(.+)', 
            caseSensitive: false, dotAll: true),
        'highlight1': RegExp(r'(?:Highlight 1|Opportunity)'),
        'highlight2': RegExp(r'(?:Highlight 2|Suggestion)'),
        'luckyColor': RegExp(r'(?:Lucky color)'),
        'luckyNumber': RegExp(r'(?:lucky number)'),
        'warning1': RegExp(r'(?:Warning 1)'),
        'warning2': RegExp(r'(?:Warning 2)'),
        'tip': RegExp(r'(?:Tip)'),
      };
    } else if (language == 'ko') {
      return {
        'phase1': RegExp(r'(?:상반기|전반부|초반):?\s*(.+?)(?=하반기|후반부|말|$)', 
            caseSensitive: false, dotAll: true),
        'phase2': RegExp(r'(?:하반기|후반부|말):?\s*(.+)', 
            caseSensitive: false, dotAll: true),
        'highlight1': RegExp(r'(?:하이라이트 1|기회)'),
        'highlight2': RegExp(r'(?:하이라이트 2|제안)'),
        'luckyColor': RegExp(r'(?:행운의 색)'),
        'luckyNumber': RegExp(r'(?:행운의 숫자)'),
        'warning1': RegExp(r'(?:경고 1)'),
        'warning2': RegExp(r'(?:경고 2)'),
        'tip': RegExp(r'(?:팁)'),
      };
    } else {
      return {
        'phase1': RegExp(r'(?:Nửa đầu tháng|Mô tả nửa đầu tháng):?\s*(.+?)(?=Nửa cuối tháng|Mô tả nửa cuối tháng|$)', 
            caseSensitive: false, dotAll: true),
        'phase2': RegExp(r'(?:Nửa cuối tháng|Mô tả nửa cuối tháng):?\s*(.+)', 
            caseSensitive: false, dotAll: true),
        'highlight1': RegExp(r'(?:Điểm sáng 1|Cơ hội)'),
        'highlight2': RegExp(r'(?:Điểm sáng 2|Gợi ý)'),
        'luckyColor': RegExp(r'(?:Màu may mắn)'),
        'luckyNumber': RegExp(r'(?:số may mắn)'),
        'warning1': RegExp(r'(?:Cảnh báo 1)'),
        'warning2': RegExp(r'(?:Cảnh báo 2)'),
        'tip': RegExp(r'(?:Tip|Mẹo)'),
      };
    }
  }

  Map<String, dynamic> _parseContentBySection(String sectionId, List<String> content, String language) {
    // Remove the first line (ID line) for content parsing
    final contentLines = content.length > 1 ? content.sublist(1) : [];
    final fullText = contentLines.join('\n').trim();
    
    switch (sectionId) {
      case 'ID1':
        // Parse header info
        final parts = fullText.split('\n').where((line) => line.trim().isNotEmpty).toList();
        return {
          'title': parts.isNotEmpty ? parts[0].replaceAll(RegExp(r'^[-•]\s*'), '').trim() : '',
          'greeting': parts.length > 1 ? parts[1].replaceAll(RegExp(r'^[-•]\s*'), '').trim() : '',
          'hook': parts.length > 2 ? parts.skip(2).join(' ').replaceAll(RegExp(r'^[-•]\s*'), '').trim() : '',
        };
        
      case 'ID2':
        // Parse overview - multilingual
        final patterns = _getMultilingualPatterns(language);
        final phasePattern = patterns['phase1']!;
        final phase2Pattern = patterns['phase2']!;
        
        final phase1Match = phasePattern.firstMatch(fullText);
        final phase2Match = phase2Pattern.firstMatch(fullText);
        
        return {
          'content': {
            'phase_1': phase1Match?.group(1)?.trim() ?? fullText.split('\n').first,
            'phase_2': phase2Match?.group(1)?.trim() ?? (fullText.contains('\n') ? fullText.split('\n').last : ''),
          }
        };
        
      case 'ID3':
        // Parse highlights - multilingual
        final highlightLines = contentLines.where((line) => line.trim().isNotEmpty).toList();
        Map<String, dynamic> highlights = {'content': {}};
        final patterns = _getMultilingualPatterns(language);
        
        for (int i = 0; i < highlightLines.length; i++) {
          final line = highlightLines[i];
          if (patterns['highlight1']!.hasMatch(line)) {
            highlights['content']['highlight_1'] = line.replaceAll(RegExp(r'^.*?:\s*'), '').trim();
          } else if (patterns['highlight2']!.hasMatch(line)) {
            highlights['content']['highlight_2'] = line.replaceAll(RegExp(r'^.*?:\s*'), '').trim();
          } else if (patterns['luckyColor']!.hasMatch(line)) {
            final colors = line.replaceAll(RegExp(r'^.*?:\s*'), '').trim();
            highlights['content']['lucky_elements'] = {'colors': colors};
          } else if (patterns['luckyNumber']!.hasMatch(line)) {
            final numbers = line.replaceAll(RegExp(r'^.*?:\s*'), '').trim();
            if (highlights['content']['lucky_elements'] is Map) {
              highlights['content']['lucky_elements']['numbers'] = numbers;
            } else {
              highlights['content']['lucky_elements'] = {'numbers': numbers};
            }
          }
        }
        
        return highlights;
        
      case 'ID4':
        // Parse golden days
        final days = <Map<String, dynamic>>[];
        String? currentDate;
        String? currentAction;
        String? currentRating;
        
        for (final line in contentLines) {
          if (RegExp(r'\d{1,2}/\d{1,2}/\d{4}').hasMatch(line)) {
            if (currentDate != null && currentAction != null) {
              days.add({
                'date': currentDate,
                'action': currentAction,
                'prosperity_level': currentRating ?? '✨✨✨',
              });
            }
            currentDate = RegExp(r'\d{1,2}/\d{1,2}/\d{4}').firstMatch(line)?.group(0);
            currentAction = line.replaceAll(RegExp(r'.*\d{1,2}/\d{1,2}/\d{4}\s*:?\s*'), '').trim();
            currentRating = null;
          } else if (line.contains('✨') || line.contains('⭐')) {
            currentRating = RegExp(r'[✨⭐]+').firstMatch(line)?.group(0);
          } else if (currentDate != null && line.trim().isNotEmpty) {
            currentAction = (currentAction ?? '') + ' ' + line.trim();
          }
        }
        
        if (currentDate != null && currentAction != null) {
          days.add({
            'date': currentDate,
            'action': currentAction.trim(),
            'prosperity_level': currentRating ?? '✨✨✨',
          });
        }
        
        return {'content': {'golden_days': days}};
        
      case 'ID5':
        // Parse warnings and tips - multilingual
        final warnings = {'content': {}};
        final patterns = _getMultilingualPatterns(language);
        
        for (final line in contentLines) {
          if (patterns['warning1']!.hasMatch(line)) {
            warnings['content']?['warning_1'] = line.replaceAll(RegExp(r'^.*?:\s*'), '').trim();
          } else if (patterns['warning2']!.hasMatch(line)) {
            warnings['content']?['warning_2'] = line.replaceAll(RegExp(r'^.*?:\s*'), '').trim();
          } else if (patterns['tip']!.hasMatch(line)) {
            warnings['content']?['tip'] = line.replaceAll(RegExp(r'^.*?:\s*'), '').trim();
          }
        }
        
        return warnings;
        
      case 'ID6':
        // Parse feng shui tips
        final tips = {'content': {}};
        
        for (final line in contentLines) {
          if (line.contains('không gian')) {
            tips['content']?['space_tip'] = line.replaceAll(RegExp(r'^.*?:\s*'), '').trim();
          } else if (line.contains('cá nhân')) {
            tips['content']?['personal_tip'] = line.replaceAll(RegExp(r'^.*?:\s*'), '').trim();
          } else if (line.contains('Thử thách')) {
            tips['content']?['challenge_tip'] = line.replaceAll(RegExp(r'^.*?:\s*'), '').trim();
          }
        }
        
        return tips;
        
      case 'ID7':
        // Parse conclusion
        final conclusionLines = contentLines.where((line) => line.trim().isNotEmpty).toList();
        return {
          'mini_bonus': conclusionLines.firstWhere((line) => line.contains('"') || line.contains('"'), 
              orElse: () => conclusionLines.isNotEmpty ? conclusionLines.first : ''),
          'closing_wish': conclusionLines.length > 1 ? conclusionLines.last : '',
        };
        
      default:
        return {'text': fullText};
    }
  }

  String _extractTitle(List<String> content) {
    if (content.isEmpty) return '';
    
    final firstLine = content.first;
    // Extract title after ID pattern
    final titleMatch = RegExp(r'^ID\d+[^:]*:?\s*(.*)').firstMatch(firstLine);
    return titleMatch?.group(1) ?? firstLine;
  }
}