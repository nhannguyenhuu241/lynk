import 'package:flutter/material.dart';
import 'package:lynk_an/common/theme.dart';
import 'package:lynk_an/data/model/zodiac_reading_model.dart';

class ZodiacReadingWidget extends StatelessWidget {
  final ZodiacReadingModel reading;
  final bool showFullContent;

  const ZodiacReadingWidget({
    super.key,
    required this.reading,
    this.showFullContent = true,
  });

  @override
  Widget build(BuildContext context) {
    print('🔍 ZodiacReadingWidget - Building...');
    print('📖 Reading palaceId: ${reading.palaceId}');
    print('📖 Reading palaceName: ${reading.palaceName}');
    print('📖 Reading month: ${reading.month}');
    print('📖 Reading year: ${reading.year}');
    print('📖 Reading sections count: ${reading.sections.length}');
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          if (showFullContent) ...[
            _buildOverview(),
            const SizedBox(height: 20),
            _buildHighlights(),
            const SizedBox(height: 20),
            _buildGoldenDays(),
            const SizedBox(height: 20),
            _buildWarningsAndTips(),
            const SizedBox(height: 20),
            _buildFengShuiTips(),
            const SizedBox(height: 20),
            _buildConclusion(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final header = reading.headerInfo;
    print('🔍 _buildHeader - header: $header');
    print('  - title: ${header['title']}');
    print('  - greeting: ${header['greeting']}');
    print('  - hook: ${header['hook']}');
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            header['title'] ?? '',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            header['greeting'] ?? '',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            header['hook'] ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview() {
    final overview = reading.overview;
    return _buildSection(
      title: '🌟 1. Tổng Quan ${reading.palaceName} Tháng Này',
      children: [
        _buildSubSection('Nửa đầu tháng:', overview['phase_1'] ?? ''),
        const SizedBox(height: 12),
        _buildSubSection('Nửa cuối tháng:', overview['phase_2'] ?? ''),
      ],
    );
  }

  Widget _buildHighlights() {
    final highlights = reading.highlights;
    final luckyElementsRaw = highlights['lucky_elements'];
    final Map<String, dynamic> luckyElements = luckyElementsRaw is Map 
        ? Map<String, dynamic>.from(luckyElementsRaw)
        : {};
    
    return _buildSection(
      title: '✨ 2. Highlight Đặc Biệt ${reading.palaceName}',
      children: [
        _buildSubSection('🤝 Điểm sáng 1:', highlights['highlight_1'] ?? ''),
        const SizedBox(height: 12),
        _buildSubSection('🎯 Điểm sáng 2:', highlights['highlight_2'] ?? ''),
        const SizedBox(height: 12),
        _buildLuckyElements(luckyElements),
      ],
    );
  }

  Widget _buildLuckyElements(Map<String, dynamic> luckyElements) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🍀 Yếu tố may mắn:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          if (luckyElements['colors'] != null)
            Text('• Màu may mắn: ${luckyElements['colors']}'),
          if (luckyElements['numbers'] != null)
            Text('• Con số may mắn: ${luckyElements['numbers']}'),
        ],
      ),
    );
  }

  Widget _buildGoldenDays() {
    final goldenDays = reading.goldenDays;
    
    return _buildSection(
      title: '🗓️ 3. Lịch Ngày Vàng Cho ${reading.palaceName}',
      children: goldenDays.map((day) => _buildGoldenDay(day)).toList(),
    );
  }

  Widget _buildGoldenDay(Map<String, dynamic> day) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '📅 ${day['date'] ?? ''}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                day['prosperity_level'] ?? '',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            day['action'] ?? '',
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningsAndTips() {
    final warnings = reading.warningsAndTips;
    
    return _buildSection(
      title: '⚠️ 4. Cảnh Báo & Tip Vượt "Thử Thách"',
      children: [
        _buildWarningItem('⚠️ Cảnh báo 1:', warnings['warning_1'] ?? ''),
        const SizedBox(height: 12),
        _buildWarningItem('⚠️ Cảnh báo 2:', warnings['warning_2'] ?? ''),
        const SizedBox(height: 12),
        _buildTipItem('💡 Tip/Mẹo:', warnings['tip'] ?? ''),
      ],
    );
  }

  Widget _buildWarningItem(String title, String content) {
    if (content.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String title, String content) {
    if (content.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFengShuiTips() {
    final tips = reading.fengShuiTips;
    
    return _buildSection(
      title: '🔮 5. Gợi Ý Nâng Cao Vận Khí',
      children: [
        _buildTipItem('🏠 Mẹo không gian:', tips['space_tip'] ?? ''),
        const SizedBox(height: 12),
        _buildTipItem('👤 Mẹo cá nhân:', tips['personal_tip'] ?? ''),
        const SizedBox(height: 12),
        _buildTipItem('🎯 Thử thách tháng này:', tips['challenge_tip'] ?? ''),
      ],
    );
  }

  Widget _buildConclusion() {
    final conclusion = reading.conclusion;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withValues(alpha: 0.8),
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            conclusion['mini_bonus'] ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            conclusion['closing_wish'] ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSubSection(String title, String content) {
    if (content.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(
            fontSize: 13,
            height: 1.5,
            color: AppColors.neutral700,
          ),
        ),
      ],
    );
  }
}