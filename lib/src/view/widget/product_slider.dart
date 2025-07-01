import 'package:flutter/material.dart';
import 'package:martfury/src/theme/app_colors.dart';
import 'package:martfury/src/view/screen/product_detail_screen.dart';
import 'package:martfury/src/service/product_service.dart';
import 'package:martfury/src/view/widget/product_card.dart';
import 'package:martfury/src/view/widget/section_header.dart';

class ProductSlider extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> products;
  final VoidCallback? onViewAll;

  const ProductSlider({
    super.key,
    required this.title,
    required this.products,
    this.onViewAll,
  });

  @override
  State<ProductSlider> createState() => _ProductSliderState();
}

class _ProductSliderState extends State<ProductSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToProduct(
    BuildContext context,
    Map<String, dynamic> product,
  ) async {
    // Add to recently viewed before navigation
    await ProductService.addToRecentlyViewed({
      'id': product['id'],
      'slug': product['slug'],
      'image': product['imageUrl'],
    });

    if (context.mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  ProductDetailScreen(product: {'slug': product['url']}),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total pages based on number of products
    final bool showTwoRows = widget.products.length > 2;
    final int productsPerPage = showTwoRows ? 4 : 2;
    final int totalPages = (widget.products.length / productsPerPage).ceil();

    return Column(
      children: [
        SectionHeader(title: widget.title, onViewAll: widget.onViewAll),
        SizedBox(
          height: showTwoRows ? 658 : 329, // Adjust height based on rows
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemCount: totalPages,
                  itemBuilder: (context, pageIndex) {
                    if (showTwoRows) {
                      // Two rows layout (4 products per page)
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            // First row
                            Expanded(
                              child: Row(
                                children: List.generate(2, (index) {
                                  final productIndex = pageIndex * 4 + index;
                                  if (productIndex >= widget.products.length) {
                                    return const Spacer();
                                  }

                                  final product = widget.products[productIndex];
                                  return Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        right: index == 0 ? 8.0 : 0.0,
                                        left: index == 1 ? 8.0 : 0.0,
                                      ),
                                      child: GestureDetector(
                                        onTap:
                                            () => _navigateToProduct(
                                              context,
                                              product,
                                            ),
                                        child: ProductCard(
                                          imageUrl: product['imageUrl'],
                                          title: product['title'],
                                          price: product['price'],
                                          originalPrice:
                                              product['originalPrice'],
                                          rating: product['rating'],
                                          reviewsCount: product['reviews'],
                                          seller: product['seller'],
                                          priceFormatted:
                                              product['priceFormatted'],
                                          originalPriceFormatted:
                                              product['originalPriceFormatted'],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Second row
                            Expanded(
                              child: Row(
                                children: List.generate(2, (index) {
                                  final productIndex =
                                      pageIndex * 4 + index + 2;
                                  if (productIndex >= widget.products.length) {
                                    return const Spacer();
                                  }

                                  final product = widget.products[productIndex];
                                  return Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        right: index == 0 ? 8.0 : 0.0,
                                        left: index == 1 ? 8.0 : 0.0,
                                      ),
                                      child: GestureDetector(
                                        onTap:
                                            () => _navigateToProduct(
                                              context,
                                              product,
                                            ),
                                        child: ProductCard(
                                          imageUrl: product['imageUrl'],
                                          title: product['title'],
                                          price: product['price'],
                                          originalPrice:
                                              product['originalPrice'],
                                          rating: product['rating'],
                                          reviewsCount: product['reviews'],
                                          seller: product['seller'],
                                          priceFormatted:
                                              product['priceFormatted'],
                                          originalPriceFormatted:
                                              product['originalPriceFormatted'],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      // Single row layout (2 products per page)
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: List.generate(2, (index) {
                            final productIndex = pageIndex * 2 + index;
                            if (productIndex >= widget.products.length) {
                              return const Spacer();
                            }

                            final product = widget.products[productIndex];
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: index == 0 ? 8.0 : 0.0,
                                  left: index == 1 ? 8.0 : 0.0,
                                ),
                                child: GestureDetector(
                                  onTap:
                                      () =>
                                          _navigateToProduct(context, product),
                                  child: ProductCard(
                                    imageUrl: product['imageUrl'],
                                    title: product['title'],
                                    price: product['price'],
                                    originalPrice: product['originalPrice'],
                                    rating: product['rating'],
                                    reviewsCount: product['reviews'],
                                    seller: product['seller'],
                                    priceFormatted: product['priceFormatted'],
                                    originalPriceFormatted:
                                        product['originalPriceFormatted'],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      );
                    }
                  },
                ),
              ),
              // Only show dots if there are multiple pages
              if (totalPages > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(totalPages, (index) {
                      return Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              _currentPage == index
                                  ? AppColors.primary
                                  : Colors.grey[300],
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
