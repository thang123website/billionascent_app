import 'package:flutter/material.dart';
import 'package:martfury/src/theme/app_fonts.dart';
import 'package:martfury/src/theme/app_colors.dart';
import 'package:martfury/src/service/product_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:martfury/src/utils/dimensions.dart';

class FilterScreen extends StatefulWidget {
  final int? categoryId;
  final int? brandId;

  const FilterScreen({super.key, this.categoryId, this.brandId});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  RangeValues _priceRange = const RangeValues(0, 0);

  bool _isLoadingFilters = true;
  String? _filtersError;
  Map<String, dynamic> _filterData = {};
  final ProductService _productService = ProductService();
  final Map<String, List<String>> _selectedFilters = {};

  final Map<String, bool> _expandedSections = {};
  double _maxPrice = 5000.0;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categoryId;
    _fetchFilterData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchFilterData() async {
    try {
      setState(() {
        _isLoadingFilters = true;
        _filtersError = null;
      });
      final filters = await _productService.getFilters(_selectedCategoryId);

      if (mounted) {
        setState(() {
          _filterData = filters;
          final rawMaxPrice = _filterData['max_price'];
          if (rawMaxPrice is num) {
            _maxPrice = rawMaxPrice.toDouble();
          }
          _priceRange = RangeValues(
            _priceRange.start.clamp(0, _maxPrice),
            _maxPrice,
          );
          _isLoadingFilters = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _filtersError = e.toString();
          _isLoadingFilters = false;
        });
      }
    }
  }

  void _handleBrandSelection(String brandId) {
    setState(() {
      const filterKey = 'brands';
      if (!_selectedFilters.containsKey(filterKey)) {
        _selectedFilters[filterKey] = [];
      }

      if (_selectedFilters[filterKey]!.contains(brandId)) {
        _selectedFilters[filterKey]!.remove(brandId);
        if (_selectedFilters[filterKey]!.isEmpty) {
          _selectedFilters.remove(filterKey);
        }
      } else {
        _selectedFilters[filterKey]!.add(brandId);
      }
    });
  }

  void _handleTagSelection(String tagId) {
    setState(() {
      const filterKey = 'tags';
      if (!_selectedFilters.containsKey(filterKey)) {
        _selectedFilters[filterKey] = [];
      }

      if (_selectedFilters[filterKey]!.contains(tagId)) {
        _selectedFilters[filterKey]!.remove(tagId);
        if (_selectedFilters[filterKey]!.isEmpty) {
          _selectedFilters.remove(filterKey);
        }
      } else {
        _selectedFilters[filterKey]!.add(tagId);
      }
    });
  }

  void _handleAttributeSetSelection(
    String attributeSetKey,
    String attributeValueId,
  ) {
    setState(() {
      final String filterKey = 'attr_set_$attributeSetKey';
      if (!_selectedFilters.containsKey(filterKey)) {
        _selectedFilters[filterKey] = [];
      }

      if (_selectedFilters[filterKey]!.contains(attributeValueId)) {
        _selectedFilters[filterKey]!.remove(attributeValueId);
        if (_selectedFilters[filterKey]!.isEmpty) {
          _selectedFilters.remove(filterKey);
        }
      } else {
        _selectedFilters[filterKey]!.add(attributeValueId);
      }
    });
  }

  void _toggleSectionExpansion(String title) {
    setState(() {
      _expandedSections[title] = !(_expandedSections[title] ?? true);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> filterSections = [];

    if (_isLoadingFilters) {
      filterSections.addAll(_buildLoadingState());
    } else if (_filtersError != null) {
      filterSections.add(
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Error loading filters: $_filtersError'),
        ),
      );
    } else {
      if (_filterData.containsKey('categories') &&
          _filterData['categories'] is List &&
          (_filterData['categories'] as List).isNotEmpty) {
        filterSections.add(
          _buildSection(
            'By Category',
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.getBorderColor(context)),
                borderRadius: BorderRadius.circular(8),
                color: AppColors.getSurfaceColor(context),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedCategoryId?.toString(),
                  hint: Text(
                    'Select Category',
                    style: kAppTextStyle(
                      color: AppColors.getHintTextColor(context),
                      fontSize: 14,
                    ),
                  ),
                  items: [
                    DropdownMenuItem<String>(
                      value: '',
                      child: Row(
                        children: [
                          Spacer(),
                          Icon(Icons.clear, size: Dimensions.iconSize20(context), color: AppColors.primary),
                        ],
                      ),
                    ),
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text(
                        'All Categories',
                        style: kAppTextStyle(
                          fontSize: 14,
                          color: AppColors.getPrimaryTextColor(context),
                        ),
                      ),
                    ),
                    ..._buildCategoryDropdownItems(_filterData['categories'] as List<dynamic>),
                  ],

                  onChanged: (String? value) {
                    setState(() {
                      if (value == null) {
                        _selectedFilters.remove('categories');
                        _selectedCategoryId = null;
                      } else if (value == '') {
                        _selectedFilters.remove('categories');
                        _selectedCategoryId = null;
                      } else {
                        _selectedFilters['categories'] = [value];
                        _selectedCategoryId = int.tryParse(value);
                      }
                    });
                    _fetchFilterData();
                  },
                ),
              ),
            ),
          ),
        );
      }

      if (_filterData.containsKey('brands') &&
          _filterData['brands'] is List &&
          (_filterData['brands'] as List).isNotEmpty) {
        filterSections.add(
          _buildSection(
            'By Brand',
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  (_filterData['brands'] as List<dynamic>).map<Widget>((brand) {
                    final String name =
                        brand['name']?.toString() ?? 'Unnamed Brand';
                    final int id = brand['id'];

                    final bool isSelected =
                        _selectedFilters['brands']?.contains(id.toString()) ??
                        widget.brandId == id;
                    return _buildChip(
                      name,
                      isSelected,
                      (String chipLabel) =>
                          _handleBrandSelection(id.toString()),
                    );
                  }).toList(),
            ),
          ),
        );
      } else {
        filterSections.add(
          _buildSection(
            'By Brand',
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('No brands available.'),
            ),
          ),
        );
      }

      filterSections.add(
        _buildSection(
          'By Price',
          Column(
            children: [
              RangeSlider(
                values: _priceRange,
                min: 0,
                max: _maxPrice,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.getBorderColor(context),
                onChanged: (RangeValues values) {
                  setState(() {
                    _priceRange = values;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${_priceRange.start.toInt()}',
                      style: kAppTextStyle(
                        color: AppColors.getSecondaryTextColor(context),
                      ),
                    ),
                    Text(
                      '\$${_priceRange.end.toInt()}',
                      style: kAppTextStyle(
                        color: AppColors.getSecondaryTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

      if (_filterData.containsKey('tags') &&
          _filterData['tags'] is List &&
          (_filterData['tags'] as List).isNotEmpty) {
        filterSections.add(
          _buildSection(
            'By Tag',
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  (_filterData['tags'] as List<dynamic>).map<Widget>((tag) {
                    final String name =
                        tag['name']?.toString() ?? 'Unnamed Tag';
                    final String slug = tag['slug']?.toString() ?? '';
                    if (slug.isEmpty) return const SizedBox.shrink();
                    final bool isSelected =
                        _selectedFilters['tags']?.contains(slug) ?? false;
                    return _buildChip(
                      name,
                      isSelected,
                      (String chipLabel) => _handleTagSelection(slug),
                    );
                  }).toList(),
            ),
          ),
        );
      }

      if (_filterData.containsKey('attributes') &&
          _filterData['attributes'] is List) {
        for (var attributeSet in (_filterData['attributes'] as List<dynamic>)) {
          final String sectionTitle =
              attributeSet['title']?.toString() ?? 'Unknown Attribute';
          final String attributeSetKey =
              attributeSet['slug']?.toString() ??
              attributeSet['id']?.toString() ??
              sectionTitle.toLowerCase().replaceAll(' ', '_');
          final List<dynamic>? attributeValues =
              attributeSet['attributes'] as List<dynamic>?;

          if (attributeValues != null && attributeValues.isNotEmpty) {
            filterSections.add(
              _buildSection(
                'By $sectionTitle',
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      attributeValues.map<Widget>((attrValue) {
                        final String valueName =
                            attrValue['title']?.toString() ?? 'Unnamed';
                        final String valueId =
                            attrValue['slug']?.toString() ?? '';

                        if (valueId.isEmpty) return const SizedBox.shrink();

                        final String filterMapKey = 'attr_set_$attributeSetKey';
                        final bool isSelected =
                            _selectedFilters[filterMapKey]?.contains(valueId) ??
                            false;

                        return _buildChip(
                          valueName,
                          isSelected,
                          (String chipLabel) => _handleAttributeSetSelection(
                            attributeSetKey,
                            valueId,
                          ),
                        );
                      }).toList(),
                ),
              ),
            );
          } else {
            filterSections.add(
              _buildSection(
                'By $sectionTitle',
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('No $sectionTitle available.'),
                ),
              ),
            );
          }
        }
      }
    }

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'filter.title'.tr(),
          style: kAppTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [...filterSections, const SizedBox(height: 16)],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.getSurfaceColor(context),
              boxShadow: [
                BoxShadow(
                  color: AppColors.getBorderColor(
                    context,
                  ).withValues(alpha: 0.3),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedFilters.clear();
                        _priceRange = RangeValues(0, _maxPrice);
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.getPrimaryTextColor(context),
                      backgroundColor: AppColors.getSurfaceColor(context),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: AppColors.getBorderColor(context),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'filter.clear_all'.tr(),
                      style: kAppTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getPrimaryTextColor(context),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final Map<String, dynamic> appliedFilters = Map.from(
                        _selectedFilters,
                      );
                      appliedFilters['min_price'] = _priceRange.start;
                      appliedFilters['max_price'] = _priceRange.end;
                      Navigator.pop(context, appliedFilters);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'filter.view_results'.tr(),
                      style: kAppTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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

  Widget _buildSection(String title, Widget content) {
    final bool isExpanded = _expandedSections.putIfAbsent(title, () => true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _toggleSectionExpansion(title),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: kAppTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getPrimaryTextColor(context),
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.getSecondaryTextColor(context),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: content,
          ),
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildChip(
    String label,
    bool isSelected,
    ValueChanged<String> onSelected,
  ) {
    return FilterChip(
      label: Text(
        label,
        style: kAppTextStyle(
          color:
              isSelected
                  ? Colors.black
                  : AppColors.getSecondaryTextColor(context),
          fontSize: 14,
        ),
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        onSelected(label);
      },
      backgroundColor: AppColors.getSurfaceColor(context),
      selectedColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color:
              isSelected
                  ? AppColors.primary
                  : AppColors.getBorderColor(context),
        ),
      ),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  List<Widget> _buildLoadingState() {
    return [
      _buildCategorySkeletonSection(),
      _buildBrandSkeletonSection(),
      _buildPriceSkeletonSection(),
      _buildTagSkeletonSection(),
      _buildAttributeSkeletonSection(),
      _buildAttributeSkeletonSection(), // Second attribute section
    ];
  }

  Widget _buildCategorySkeletonSection() {
    return _buildSkeletonSection(
      'By Category',
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.getBorderColor(context)),
          borderRadius: BorderRadius.circular(8),
          color: AppColors.getSurfaceColor(context),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.getSkeletonColor(context),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.getSkeletonColor(context),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandSkeletonSection() {
    return _buildSkeletonSection(
      'By Brand',
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(
          6, // Show 6 skeleton chips
          (index) => _buildChipSkeleton(index),
        ),
      ),
    );
  }

  Widget _buildPriceSkeletonSection() {
    return _buildSkeletonSection(
      'By Price',
      Column(
        children: [
          // Slider skeleton
          Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              children: [
                // Slider track
                Positioned(
                  top: 18,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.getSkeletonColor(context),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Slider thumbs
                Positioned(
                  top: 12,
                  left: 20,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.getSkeletonColor(context),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 40,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.getSkeletonColor(context),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Price labels skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.getSkeletonColor(context),
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                Container(
                  width: 50,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.getSkeletonColor(context),
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagSkeletonSection() {
    return _buildSkeletonSection(
      'By Tag',
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(
          4, // Show 4 skeleton chips
          (index) => _buildChipSkeleton(index),
        ),
      ),
    );
  }

  Widget _buildAttributeSkeletonSection() {
    return _buildSkeletonSection(
      'By Attribute',
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(
          5, // Show 5 skeleton chips
          (index) => _buildChipSkeleton(index),
        ),
      ),
    );
  }

  Widget _buildSkeletonSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 120,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.getSkeletonColor(context),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.getSkeletonColor(context),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: content,
        ),
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildChipSkeleton(int index) {
    // Create varied widths for more realistic skeleton
    final widths = [50.0, 70.0, 60.0, 80.0, 55.0, 65.0];
    final width = widths[index % widths.length];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.getBorderColor(context)),
      ),
      child: Container(
        width: width,
        height: 14,
        decoration: BoxDecoration(
          color: AppColors.getSkeletonColor(context),
          borderRadius: BorderRadius.circular(7),
        ),
      ),
    );
  }
  List<DropdownMenuItem<String>> _buildCategoryDropdownItems(List<dynamic> categories) {
    List<DropdownMenuItem<String>> items = [];
    final Map<dynamic, List<dynamic>> childrenMap = {};
    for (var cat in categories) {
      final parentId = cat['parent_id'];
      if (!childrenMap.containsKey(parentId)) {
        childrenMap[parentId] = [];
      }
      childrenMap[parentId]!.add(cat);
    }

    void addItems(dynamic parentId, int depth) {
      final children = childrenMap[parentId] ?? [];
      for (var cat in children) {
        final String id = cat['id']?.toString() ?? '';
        final String name = cat['name']?.toString() ?? 'Unnamed Category';
        if (id.isEmpty) continue;
        items.add(DropdownMenuItem<String>(
          value: id,
          child: Padding(
            padding: EdgeInsets.only(left: 24.0 * depth),
            child: Text(
              name,
              style: kAppTextStyle(
                fontSize: 14,
                color: AppColors.getPrimaryTextColor(context),
              ),
            ),
          ),
        ));
        addItems(cat['id'], depth + 1);
      }
    }
    addItems(0, 0);
    return items;
  }
}
