import 'image_sizes.dart';
import 'store.dart';

class Product {
  final int id;
  final String slug;
  final String name;
  final String sku;
  final String description;
  final String content;
  final int? quantity;
  final bool isOutOfStock;
  final String stockStatusLabel;
  final String stockStatusHtml;
  final double price;
  final String priceFormatted;
  final double? originalPrice;
  final String originalPriceFormatted;
  final double? reviewsAvg;
  final int reviewsCount;
  final ImageSizes imageWithSizes;
  final int? weight;
  final int? height;
  final int? wide;
  final int? length;
  final String imageUrl;
  final List<dynamic> productOptions;
  final Store? store;

  Product({
    required this.id,
    required this.slug,
    required this.name,
    required this.sku,
    required this.description,
    required this.content,
    this.quantity,
    required this.isOutOfStock,
    required this.stockStatusLabel,
    required this.stockStatusHtml,
    required this.price,
    required this.priceFormatted,
    this.originalPrice,
    required this.originalPriceFormatted,
    this.reviewsAvg,
    required this.reviewsCount,
    required this.imageWithSizes,
    this.weight,
    this.height,
    this.wide,
    this.length,
    required this.imageUrl,
    required this.productOptions,
    this.store,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int? ?? 0,
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      description: json['description'] as String? ?? '',
      content: json['content'] as String? ?? '',
      quantity: json['quantity'] as int?,
      isOutOfStock: json['is_out_of_stock'] as bool? ?? false,
      stockStatusLabel: json['stock_status_label'] as String? ?? '',
      stockStatusHtml: json['stock_status_html'] as String? ?? '',
      price: _parseDouble(json['price']) ?? 0.0,
      priceFormatted: json['price_formatted'] as String? ?? '',
      originalPrice: _parseDouble(json['original_price']),
      originalPriceFormatted: json['original_price_formatted'] as String? ?? '',
      reviewsAvg: _parseDouble(json['reviews_avg']),
      reviewsCount: json['reviews_count'] as int? ?? 0,
      imageWithSizes: json['image_with_sizes'] != null
          ? ImageSizes.fromJson(json['image_with_sizes'] as Map<String, dynamic>)
          : ImageSizes.empty(),
      weight: json['weight'] as int?,
      height: json['height'] as int?,
      wide: json['wide'] as int?,
      length: json['length'] as int?,
      imageUrl: json['image_url'] as String? ?? '',
      productOptions: json['product_options'] as List<dynamic>? ?? [],
      store: json['store'] != null && json['store'] is Map<String, dynamic>
          ? Store.fromJson(json['store'] as Map<String, dynamic>)
          : null,
    );
  }

  // Helper method to safely parse doubles from dynamic values
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'name': name,
      'sku': sku,
      'description': description,
      'content': content,
      'quantity': quantity,
      'is_out_of_stock': isOutOfStock,
      'stock_status_label': stockStatusLabel,
      'stock_status_html': stockStatusHtml,
      'price': price,
      'price_formatted': priceFormatted,
      'original_price': originalPrice,
      'original_price_formatted': originalPriceFormatted,
      'reviews_avg': reviewsAvg,
      'reviews_count': reviewsCount,
      'image_with_sizes': imageWithSizes.toJson(),
      'weight': weight,
      'height': height,
      'wide': wide,
      'length': length,
      'image_url': imageUrl,
      'product_options': productOptions,
      'store': store?.toJson(),
    };
  }
}
