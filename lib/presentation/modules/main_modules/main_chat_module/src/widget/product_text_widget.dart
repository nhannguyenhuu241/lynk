import 'package:flutter/material.dart';

class ProductTextWidget extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;

  const ProductTextWidget({
    super.key,
    required this.text,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final productLinks = _extractProductLinks(text);
    
    if (productLinks.isEmpty) {
      return Text(
        text,
        style: textStyle,
      );
    }

    // Tách text thành các phần: text thường và product links
    String cleanText = text;
    
    // Loại bỏ tất cả product link tags để có text sạch
    for (final link in productLinks) {
      cleanText = cleanText.replaceAll(
        '[PRODUCT_LINK]${link.name}|${link.url}[/PRODUCT_LINK]',
        '',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hiển thị text chính
        if (cleanText.trim().isNotEmpty)
          Text(
            cleanText.trim(),
            style: textStyle,
          ),
        
        // Hiển thị các nút sản phẩm
        if (productLinks.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: productLinks.map((link) => _buildProductButton(context, link)).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildProductButton(BuildContext context, ProductLink link) {
    return InkWell(
      onTap: null, // URL launching removed
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF6C63FF), // Vibrant purple
              const Color(0xFF5A52FF), // Deeper purple
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 18,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              link.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14, // Tăng từ 13 lên 14
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.open_in_new,
              size: 16,
              color: Colors.white,
            ),
          ],
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
}

class ProductLink {
  final String name;
  final String url;

  ProductLink({required this.name, required this.url});
}