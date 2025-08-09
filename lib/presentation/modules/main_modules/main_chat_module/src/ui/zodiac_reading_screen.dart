import 'package:flutter/material.dart';
import 'package:lynk_an/common/theme.dart';
import 'package:lynk_an/data/model/zodiac_reading_model.dart';
import 'package:lynk_an/common/assets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lynk_an/common/localization/app_localizations.dart';
import 'package:lynk_an/common/lang_key.dart';

class ZodiacReadingScreen extends StatelessWidget {
  final String zodiacId;
  final String zodiacName;
  final String readingJson;

  const ZodiacReadingScreen({
    super.key,
    required this.zodiacId,
    required this.zodiacName,
    required this.readingJson,
  });

  @override
  Widget build(BuildContext context) {
    print('🔍 ZodiacReadingScreen - zodiacId: $zodiacId');
    print('🔍 ZodiacReadingScreen - zodiacName: $zodiacName');
    print('🔍 ZodiacReadingScreen - readingJson length: ${readingJson.length}');
    print('📄 ZodiacReadingScreen - readingJson preview: ${readingJson.substring(0, readingJson.length > 200 ? 200 : readingJson.length)}...');
    
    // Parse the reading JSON or handle plain text
    ZodiacReadingModel? reading;
    bool isPlainText = false;
    String plainTextContent = '';
    
    try {
      // First try to parse as JSON
      reading = ZodiacReadingModel.fromJsonString(readingJson);
      print('✅ Successfully parsed ZodiacReadingModel');
      print('📖 Reading sections count: ${reading.sections.length}');
      for (var section in reading.sections) {
        print('  - Section ${section.id}: ${section.title}');
      }
    } catch (e) {
      print('❌ Error parsing ZodiacReadingModel: $e');
      print('📝 Treating as plain text content');
      // If JSON parsing fails, treat it as plain text
      isPlainText = true;
      plainTextContent = readingJson;
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Image.asset(
            Assets.imgBackground2,
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header with back button
                _buildHeader(context),
                
                // Reading content
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: reading != null || isPlainText
                          ? _buildReadingContent(reading, isPlainText, plainTextContent)
                          : Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 64,
                                      color: Colors.red.withValues(alpha: 0.7),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Không thể tải dữ liệu tử vi',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Vui lòng thử lại sau',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingContent(ZodiacReadingModel? reading, bool isPlainText, String plainTextContent) {
    // If it's plain text, display it with markdown support
    if (isPlainText) {
      return Markdown(
        data: plainTextContent,
        padding: const EdgeInsets.all(20),
        styleSheet: MarkdownStyleSheet(
          h1: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            height: 1.4,
          ),
          h2: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
            height: 1.4,
          ),
          h3: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
            height: 1.3,
          ),
          p: const TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Colors.black87,
          ),
          strong: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
          em: const TextStyle(
            fontStyle: FontStyle.italic,
          ),
          blockquote: const TextStyle(
            fontSize: 17,
            fontStyle: FontStyle.italic,
            color: AppColors.primary,
            height: 1.5,
          ),
          listBullet: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
          blockquoteDecoration: BoxDecoration(
            color: AppColors.primarySoft.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(
                color: AppColors.primary,
                width: 4,
              ),
            ),
          ),
          blockquotePadding: const EdgeInsets.all(16),
          horizontalRuleDecoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppColors.neutral300,
                width: 1,
              ),
            ),
          ),
        ),
      );
    }
    
    // If reading is null, return empty container
    if (reading == null) {
      return const SizedBox.shrink();
    }

    // Legacy format with sections
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: reading.sections.map((section) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (section.title.isNotEmpty) ...[
                  Text(
                    section.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                ...section.content.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      entry.value.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Title
          Expanded(
            child: Text(
              AppLocalizations.text(LangKey.zodiac_reading_title).replaceAll('%s', zodiacName),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black45,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(width: 48), // Balance for back button
        ],
      ),
    );
  }
}