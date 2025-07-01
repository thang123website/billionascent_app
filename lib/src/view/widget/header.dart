import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:martfury/src/theme/app_fonts.dart';
import 'package:martfury/src/theme/app_colors.dart';
import 'package:martfury/src/service/cart_service.dart';
import 'dart:async';
import 'package:martfury/src/view/screen/search_screen.dart';
import 'package:martfury/src/view/screen/cart_screen.dart';
import 'dart:ui' as ui;

class Header extends StatefulWidget {
  final bool isCollapsed;
  const Header({super.key, this.isCollapsed = false});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  int _cartCount = 0;
  StreamSubscription<int>? _cartCountSubscription;

  @override
  void initState() {
    super.initState();
    _loadCartCount();
    _setupCartCountListener();
  }

  @override
  void dispose() {
    _cartCountSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadCartCount() async {
    final count = await CartService.getCartCount();
    if (mounted) {
      setState(() {
        _cartCount = count;
      });
    }
  }

  void _setupCartCountListener() {
    _cartCountSubscription = CartService.cartCountStream.listen((count) {
      if (mounted) {
        setState(() {
          _cartCount = count;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 32,
                  fit: BoxFit.contain,
                ),
                Row(
                  children: [
                    // Cart icon with badge
                    Stack(
                      children: [
                        IconButton(
                          icon: SvgPicture.asset(
                            'assets/images/icons/cart.svg',
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
                                builder: (context) => const CartScreen(),
                              ),
                            );
                          },
                        ),
                        if (_cartCount > 0)
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
                                _cartCount.toString(),
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
                    // Notification bell icon
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/images/icons/bell-solid.svg',
                        width: 30,
                        height: 30,
                        colorFilter: const ColorFilter.mode(
                          Colors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Notifications feature coming soon!',
                              style: kAppTextStyle(),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            if (!widget.isCollapsed) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchScreen(),
                    ),
                  );
                },
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.getSurfaceColor(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      if (isRtl) ...[
                        // In RTL: text first, then search button on the left
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              'common.search_placeholder'.tr(),
                              style: kAppTextStyle(
                                color: AppColors.getSecondaryTextColor(context),
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ),
                        Container(
                          height: 40,
                          width: 48,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.darkCardBackground
                                    : Colors.black,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                          child: IconButton(
                            icon: SvgPicture.asset(
                              'assets/images/icons/search.svg',
                              width: 20,
                              height: 20,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ] else ...[
                        // In LTR: text first, then search button on the right
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              'common.search_placeholder'.tr(),
                              style: kAppTextStyle(
                                color: AppColors.getSecondaryTextColor(context),
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        Container(
                          height: 40,
                          width: 48,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.darkCardBackground
                                    : Colors.black,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                          child: IconButton(
                            icon: SvgPicture.asset(
                              'assets/images/icons/search.svg',
                              width: 20,
                              height: 20,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
