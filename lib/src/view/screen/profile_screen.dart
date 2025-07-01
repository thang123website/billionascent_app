import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:martfury/src/service/auth_service.dart';
import 'package:martfury/src/service/profile_service.dart';
import 'package:martfury/src/service/currency_service.dart';
import 'package:martfury/src/service/language_service.dart';
import 'package:martfury/src/service/compare_service.dart';
import 'package:martfury/src/service/wishlist_service.dart';
import 'package:martfury/src/theme/app_fonts.dart';
import 'package:martfury/src/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:martfury/src/view/widget/language_selection_modal.dart';
import 'package:martfury/src/view/widget/currency_selection_modal.dart';
import 'package:martfury/src/model/currency.dart';
import 'package:martfury/src/model/language.dart';
import 'package:martfury/src/service/token_service.dart';
import 'package:martfury/src/view/screen/sign_in_screen.dart';
import 'package:martfury/src/view/screen/edit_profile_screen.dart';
import 'package:martfury/src/view/screen/manage_address_screen.dart';
import 'package:martfury/src/view/screen/orders_screen.dart';
import 'package:martfury/src/view/screen/tracking_order_screen.dart';
import 'package:martfury/src/view/screen/reviews_screen.dart';
import 'package:martfury/src/view/screen/webview_screen.dart';
import 'package:martfury/src/view/screen/wishlist_screen.dart';
import 'package:martfury/src/view/screen/compare_screen.dart';
import 'package:martfury/src/utils/restart_widget.dart';
import 'package:martfury/core/app_config.dart';
import 'dart:async';
import 'dart:ui' as ui;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _profileData;
  Currency? _selectedCurrency;
  Language? _selectedLanguage;
  int _compareCount = 0;
  int _wishlistCount = 0;
  StreamSubscription<int>? _compareCountSubscription;
  StreamSubscription<int>? _wishlistCountSubscription;
  final CurrencyService _currencyService = CurrencyService();
  final LanguageService _languageService = LanguageService();
  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadCompareCount();
    _loadWishlistCount();
    _setupCompareCountListener();
    _setupWishlistCountListener();
  }

  @override
  void dispose() {
    _compareCountSubscription?.cancel();
    _wishlistCountSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadCompareCount() async {
    final count = await CompareService.getCompareCount();
    if (mounted) {
      setState(() {
        _compareCount = count;
      });
    }
  }

  void _setupCompareCountListener() {
    _compareCountSubscription = CompareService.compareCountStream.listen((
      count,
    ) {
      if (mounted) {
        setState(() {
          _compareCount = count;
        });
      }
    });
  }

  Future<void> _loadWishlistCount() async {
    final count = await WishlistService.getWishlistCount();
    if (mounted) {
      setState(() {
        _wishlistCount = count;
      });
    }
  }

  void _setupWishlistCountListener() {
    _wishlistCountSubscription = WishlistService.wishlistCountStream.listen((
      count,
    ) {
      if (mounted) {
        setState(() {
          _wishlistCount = count;
        });
      }
    });
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Try to load saved currency first
      _selectedCurrency = await CurrencyService.getSelectedCurrency();

      // If no saved currency, load the default currency
      if (_selectedCurrency == null) {
        final currencies = await _currencyService.getCurrencies();
        if (currencies.isNotEmpty) {
          _selectedCurrency = currencies.firstWhere(
            (Currency currency) => currency.isDefault,
            orElse: () => currencies.first,
          );
        }
      }

      // Try to load saved language first
      _selectedLanguage = await LanguageService.getSelectedLanguage();

      // If no saved language, load the default language
      if (_selectedLanguage == null) {
        final languages = await _languageService.getLanguages();
        if (languages.isNotEmpty) {
          _selectedLanguage = languages.firstWhere(
            (Language language) => language.isDefault,
            orElse: () => languages.first,
          );
        }
      }

      // Only load profile data if user is authenticated
      final token = await TokenService.getToken();
      if (token != null) {
        final data = await _profileService.getProfile();
        if (mounted) {
          setState(() {
            _profileData = data;
          });
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showCurrencySelection() async {
    final currencies = await _currencyService.getCurrencies();

    if (!mounted) return;

    final selectedCurrency = await showModalBottomSheet<Currency>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => CurrencySelectionModal(
            currencies: currencies,
            selectedCurrency: _selectedCurrency,
          ),
    );

    if (selectedCurrency != null && mounted) {
      setState(() {
        _selectedCurrency = selectedCurrency;
      });
      await CurrencyService.saveSelectedCurrency(selectedCurrency);

      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              title: Text('profile.currency_change_title'.tr()),
              content: Text('profile.currency_change_message'.tr()),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    RestartWidget.restartApp(context);
                  },
                  child: Text('common.submit'.tr()),
                ),
              ],
            ),
      );
    }
  }

  Future<void> _showLanguageSelection() async {
    final languages = await _languageService.getLanguages();

    if (!mounted) return;

    final selectedLanguage = await showModalBottomSheet<Language>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => LanguageSelectionModal(
            languages: languages,
            selectedLanguage: _selectedLanguage,
          ),
    );

    if (selectedLanguage != null && mounted) {
      setState(() {
        _selectedLanguage = selectedLanguage;
      });
      await LanguageService.saveSelectedLanguage(selectedLanguage);
      if (!mounted) return;

      // Update the locale and restart the app
      final newLocale = Locale(selectedLanguage.langLocale);

      // Try to set the locale, but handle the case where it might not be supported
      try {
        context.setLocale(newLocale);
      } catch (e) {
        // If setting locale fails, we'll still save the language selection
        // The RTL direction will be handled by our custom implementation
        // Silently continue - the language change will still work for RTL
      }

      // Show a dialog to inform the user about the restart
      // The dialog content will mention RTL support if the language is RTL
      final isRtl = selectedLanguage.isRtl;
      final dialogContent =
          isRtl
              ? 'profile.language_change_message_rtl'.tr()
              : 'profile.language_change_message'.tr();

      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              title: Text('profile.language_change_title'.tr()),
              content: Text(dialogContent),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    RestartWidget.restartApp(context);
                  },
                  child: Text('common.submit'.tr()),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.getBackgroundColor(context),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'profile.error_loading'.tr(),
                style: kAppTextStyle(fontSize: 16, color: AppColors.error),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loadProfile,
                child: Text('common.retry'.tr()),
              ),
            ],
          ),
        ),
      );
    }

    final isLoggedIn = _profileData != null;

    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'nav.profile.profile'.tr(),
          style: kAppTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
        actions: [
          // Wishlist button with badge
          Stack(
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  'assets/images/icons/wishlist.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.black,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WishlistScreen(),
                    ),
                  );
                },
              ),
              if (_wishlistCount > 0)
                Positioned(
                  right: isRtl ? null : 6,
                  left: isRtl ? 6 : null,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      _wishlistCount.toString(),
                      style: kAppTextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // Compare button with badge
          Stack(
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  'assets/images/icons/compare.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.black,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CompareScreen(),
                    ),
                  );
                },
              ),
              if (_compareCount > 0)
                Positioned(
                  right: isRtl ? null : 6,
                  left: isRtl ? 6 : null,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      _compareCount.toString(),
                      style: kAppTextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Profile header section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child:
                isLoggedIn
                    ? _buildLoggedInHeader(isRtl)
                    : _buildLoggedOutHeader(),
          ),
          // Menu items
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadProfile,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    if (!isLoggedIn) ...[
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            Text(
                              'profile.sign_in_to_access_all_features'.tr(),
                              style: kAppTextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.getPrimaryTextColor(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'profile.get_access_to_your_orders_wishlist_and_more'
                                  .tr(),
                              textAlign: TextAlign.center,
                              style: kAppTextStyle(
                                fontSize: 14,
                                color: AppColors.getSecondaryTextColor(context),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const SignInScreen(),
                                      ),
                                    ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'common.sign_in'.tr(),
                                  style: kAppTextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (isLoggedIn) ...[
                      const SizedBox(height: 24),
                      // My Orders Section
                      _buildMyOrdersSection(),
                      const SizedBox(height: 24),
                      _buildMenuItem(
                        'profile.manage_address'.tr(),
                        Icons.location_on_outlined,
                        onTap:
                            (context) => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const ManageAddressScreen(),
                              ),
                            ),
                      ),
                      _buildMenuItem(
                        'profile.sign_out'.tr(),
                        Icons.logout,
                        color: Colors.red,
                        onTap: (context) async {
                          final authService = AuthService();
                          await authService.signOut();
                        },
                      ),
                    ],
                    // Track order and support menu items - available for all users
                    const SizedBox(height: 24),
                    _buildMenuItem(
                      'orders.track_order'.tr(),
                      Icons.local_shipping_outlined,
                      onTap:
                          (context) => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TrackingOrderScreen(),
                            ),
                          ),
                    ),
                    const Divider(height: 32),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'profile.support'.tr(),
                          style: kAppTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.getPrimaryTextColor(context),
                          ),
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      'profile.help_center'.tr(),
                      Icons.help_outline,
                      onTap:
                          (context) => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => WebViewScreen(
                                    url: AppConfig.helpCenterUrl,
                                    title: 'profile.help_center'.tr(),
                                  ),
                            ),
                          ),
                    ),
                    _buildMenuItem(
                      'profile.customer_service'.tr(),
                      Icons.headset_mic_outlined,
                      onTap:
                          (context) => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => WebViewScreen(
                                    url: AppConfig.customerSupportUrl,
                                    title: 'profile.customer_service'.tr(),
                                  ),
                            ),
                          ),
                    ),
                    _buildMenuItem(
                      'profile.blog'.tr(),
                      Icons.article_outlined,
                      onTap:
                          (context) => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => WebViewScreen(
                                    url: AppConfig.blogUrl,
                                    title: 'profile.blog'.tr(),
                                  ),
                            ),
                          ),
                    ),
                    const Divider(height: 32),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'profile.settings'.tr(),
                          style: kAppTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.getPrimaryTextColor(context),
                          ),
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      _selectedCurrency?.title ?? 'profile.currencies'.tr(),
                      Icons.currency_exchange,
                      onTap: (context) => _showCurrencySelection(),
                    ),
                    _buildMenuItem(
                      _selectedLanguage?.name ?? 'profile.languages'.tr(),
                      Icons.language,
                      onTap: (context) => _showLanguageSelection(),
                    ),
                    // Add bottom padding to make language selection easier to click
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 32,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedInHeader(bool isRtl) {
    return Row(
      children: [
        // Profile image with edit button
        GestureDetector(
          onTap: () async {
            final updatedData = await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => EditProfileScreen(profileData: _profileData!),
              ),
            );
            if (updatedData != null && mounted) {
              setState(() {
                _profileData = updatedData;
              });
            }
          },
          child: Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  color: Colors.white,
                ),
                child: ClipOval(
                  child:
                      _profileData?['avatar'] != null &&
                              _profileData!['avatar'].isNotEmpty
                          ? Image.network(
                            _profileData!['avatar'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultAvatar();
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return _buildDefaultAvatar();
                            },
                          )
                          : _buildDefaultAvatar(),
                ),
              ),
              Positioned(
                right: isRtl ? null : 0,
                left: isRtl ? 0 : null,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // User info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _profileData?['name'] ?? 'profile.user'.tr(),
                style: kAppTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _profileData?['email'] ?? '',
                style: kAppTextStyle(
                  fontSize: 14,
                  color: Colors.black.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 28),
    );
  }

  Widget _buildLoggedOutHeader() {
    return Row(
      children: [
        // App logo
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(8),
          child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
        ),
        const SizedBox(width: 16),
        // Welcome text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'profile.welcome'.tr(),
                style: kAppTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'profile.sign_in_to_continue'.tr(),
                style: kAppTextStyle(
                  fontSize: 14,
                  color: Colors.black.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMyOrdersSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with "View All" link
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'profile.my_orders'.tr(),
                style: kAppTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getPrimaryTextColor(context),
                ),
              ),
              GestureDetector(
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrdersScreen(),
                      ),
                    ),
                child: Text(
                  'common.view_all'.tr(),
                  style: kAppTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Order status cards
          Row(
            children: [
              Expanded(
                child: _buildOrderStatusCard(
                  'orders.ongoing'.tr(),
                  Icons.access_time,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              const OrdersScreen(initialFilter: 'processing'),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOrderStatusCard(
                  'orders.completed'.tr(),
                  Icons.check_circle_outline,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              const OrdersScreen(initialFilter: 'completed'),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOrderStatusCard(
                  'common.reviews'.tr(),
                  Icons.star_outline,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReviewsScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOrderStatusCard(
                  'orders.returns'.tr(),
                  Icons.keyboard_return,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              const OrdersScreen(initialFilter: 'cancelled'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusCard(
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color:
              Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkCardBackground
                  : const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.getSurfaceColor(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: kAppTextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.getPrimaryTextColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    String title,
    IconData icon, {
    Color? color,
    void Function(BuildContext)? onTap,
  }) {
    return Builder(
      builder:
          (context) => InkWell(
            onTap: onTap != null ? () => onTap(context) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(icon, color: color ?? AppColors.primary, size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: kAppTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: color ?? AppColors.getPrimaryTextColor(context),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.getSecondaryTextColor(context),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: Column(
        children: [
          // Header skeleton
          _buildHeaderSkeleton(),
          // Menu items skeleton
          Expanded(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  // Sign in section skeleton
                  _buildSignInSectionSkeleton(),
                  const SizedBox(height: 24),
                  // Orders section skeleton
                  _buildOrdersSectionSkeleton(),
                  const SizedBox(height: 24),
                  // Menu items skeleton
                  _buildMenuItemsSkeleton(itemCount: 2),
                  const SizedBox(height: 32),
                  // Support section skeleton
                  _buildSectionHeaderSkeleton(),
                  _buildMenuItemsSkeleton(itemCount: 3),
                  const SizedBox(height: 32),
                  // Settings section skeleton
                  _buildSectionHeaderSkeleton(),
                  _buildMenuItemsSkeleton(itemCount: 2),
                  // Add bottom padding to match main screen
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSkeleton() {
    return Column(
      children: [
        // AppBar skeleton
        Container(
          height: kToolbarHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(color: AppColors.primary),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ],
          ),
        ),
        // Profile header skeleton
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              // Profile image skeleton
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.3),
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
              const SizedBox(width: 16),
              // User info skeleton
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 140,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 180,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignInSectionSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Title skeleton
          Container(
            width: double.infinity,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.getSkeletonColor(context),
              borderRadius: BorderRadius.circular(9),
            ),
          ),
          const SizedBox(height: 8),
          // Subtitle skeleton
          Container(
            width: 250,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.getSkeletonColor(context),
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 200,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.getSkeletonColor(context),
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          const SizedBox(height: 24),
          // Button skeleton
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.getSkeletonColor(context),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersSectionSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 100,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.getSkeletonColor(context),
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              Container(
                width: 60,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.getSkeletonColor(context),
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Order status cards skeleton
          Row(
            children: [
              Expanded(child: _buildOrderStatusCardSkeleton()),
              const SizedBox(width: 12),
              Expanded(child: _buildOrderStatusCardSkeleton()),
              const SizedBox(width: 12),
              Expanded(child: _buildOrderStatusCardSkeleton()),
              const SizedBox(width: 12),
              Expanded(child: _buildOrderStatusCardSkeleton()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusCardSkeleton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.getSkeletonColor(context).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.getSkeletonColor(context),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 50,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.getSkeletonColor(context),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeaderSkeleton() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 100,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.getSkeletonColor(context),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItemsSkeleton({int itemCount = 5}) {
    return Column(
      children: List.generate(itemCount, (index) => _buildMenuItemSkeleton()),
    );
  }

  Widget _buildMenuItemSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Icon skeleton
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.getSkeletonColor(context),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),
          // Title skeleton
          Expanded(
            child: Container(
              width: double.infinity,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.getSkeletonColor(context),
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Arrow skeleton
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
    );
  }
}
