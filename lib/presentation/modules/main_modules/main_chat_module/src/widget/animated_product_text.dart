import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lynk_an/common/theme.dart';

class AnimatedProductText extends StatefulWidget {
  final String text;
  final Color color;
  final List<Shadow>? textShadow;
  final Duration typingSpeed;
  final TextStyle? style;

  const AnimatedProductText({
    Key? key,
    required this.text,
    required this.color,
    this.textShadow,
    this.typingSpeed = const Duration(milliseconds: 10),
    this.style,
  }) : super(key: key);

  @override
  State<AnimatedProductText> createState() => _AnimatedProductTextState();
}

class _AnimatedProductTextState extends State<AnimatedProductText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _characterCount;
  List<ProductLink> _productLinks = [];
  String _cleanText = '';

  @override
  void initState() {
    super.initState();
    _productLinks = _extractProductLinks(widget.text);
    _cleanText = _getCleanText(widget.text);
    
    _controller = AnimationController(
      duration: Duration(
        milliseconds: _cleanText.length * widget.typingSpeed.inMilliseconds,
      ),
      vsync: this,
    );

    _characterCount = StepTween(
      begin: 0,
      end: _cleanText.length,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _characterCount,
      builder: (context, child) {
        String animatedText = _characterCount.value < _cleanText.length
            ? _cleanText.substring(0, _characterCount.value)
            : _cleanText;

        // Thêm cursor nếu đang typing
        if (_characterCount.value < _cleanText.length) {
          animatedText += '|';
        }

        final textStyle = (widget.style ?? const TextStyle()).copyWith(
          color: widget.color,
          shadows: widget.textShadow,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị text với animation
            Text(
              animatedText,
              style: textStyle,
            ),
            
            // Hiển thị product buttons sau khi animation hoàn thành
            if (_controller.isCompleted && _productLinks.isNotEmpty) ...[
              const SizedBox(height: 12),
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.scale(
                      scale: 0.8 + (0.2 * value),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _productLinks.map((link) => _buildProductButton(context, link)).toList(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildProductButton(BuildContext context, ProductLink link) {
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: null, // URL launching removed
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primaryDark,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
            ],
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  size: 16,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  link.name,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_outward,
                size: 14,
                color: AppColors.white.withValues(alpha: 0.9),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<ProductLink> _extractProductLinks(String text) {
    final List<ProductLink> links = [];
    final RegExp regex = RegExp(r'\[PRODUCT_LINK\](.*?)\|(.*?)\[/PRODUCT_LINK\]');
    
    final matches = regex.allMatches(text);
    for (final match in matches) {
      final name = match.group(1) ?? '';
      final url = match.group(2) ?? '';
      if (name.isNotEmpty && url.isNotEmpty) {
        links.add(ProductLink(name: name, url: url));
      }
    }
    
    return links;
  }

  String _getCleanText(String text) {
    String cleanText = text;
    final RegExp regex = RegExp(r'\[PRODUCT_LINK\].*?\|.*?\[/PRODUCT_LINK\]');
    cleanText = cleanText.replaceAll(regex, '');
    return cleanText.trim();
  }

  Future<void> _launchUrl(String url) async {
    try {
      debugPrint('Attempting to launch URL: $url');
      final Uri uri = Uri.parse(url);
      
      final bool canLaunch = await canLaunchUrl(uri);
      debugPrint('Can launch URL: $canLaunch');
      
      if (canLaunch) {
        final bool launched = await launchUrl(
          uri, 
          mode: LaunchMode.externalApplication,
          webOnlyWindowName: '_blank',
        );
        debugPrint('URL launched successfully: $launched');
      } else {
        debugPrint('Cannot launch URL: $url');
        // Fallback: try to launch with different mode
        await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      // Show snackbar or toast to user
      try {
        // Alternative: try launching with browser mode
        final Uri uri = Uri.parse(url);
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
      } catch (e2) {
        debugPrint('Fallback launch also failed: $e2');
      }
    }
  }
}

class ProductLink {
  final String name;
  final String url;

  ProductLink({required this.name, required this.url});
}