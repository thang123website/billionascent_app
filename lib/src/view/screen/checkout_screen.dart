import 'package:flutter/material.dart';
import 'package:martfury/src/theme/app_fonts.dart';
import 'package:martfury/src/theme/app_colors.dart';
import 'package:martfury/src/view/screen/cart_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:martfury/src/service/token_service.dart';
import 'package:martfury/core/app_config.dart';
import 'package:martfury/src/service/cart_service.dart';

class CheckoutScreen extends StatefulWidget {
  final String cartId;

  const CheckoutScreen({super.key, required this.cartId});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  WebViewController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _handleCheckoutComplete() async {
    // Clear cart data since checkout is complete
    await CartService.clearCartId();
    await CartService.clearCartProducts();

    if (mounted) {
      // Pop back to home page
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _initializeWebView() async {
    final token = await TokenService.getToken();
    if (!mounted) return;

    final controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.white)
          // Clear cookies and cache
          ..clearCache()
          ..clearLocalStorage()
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                if (mounted) {
                  setState(() {
                    _isLoading = true;
                  });
                }
              },
              onPageFinished: (String url) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              onNavigationRequest: (NavigationRequest request) {
                // Check if URL matches base URL
                if (request.url == AppConfig.apiBaseUrl ||
                    request.url == '${AppConfig.apiBaseUrl}/' ||
                    request.url.startsWith(
                      '${AppConfig.apiBaseUrl}/thank-you',
                    )) {
                  _handleCheckoutComplete();
                  return NavigationDecision.prevent;
                }
                // Check if URL is cart page and redirect to cart screen
                if (request.url.startsWith('${AppConfig.apiBaseUrl}/cart')) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                  // Navigator.of(context).pushReplacementNamed('/cart');
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
              onWebResourceError: (WebResourceError error) {
                debugPrint('WebView error: ${error.description}');
              },
            ),
          )
          ..loadRequest(
            Uri.parse(
              '${AppConfig.apiBaseUrl}/api/v1/ecommerce/checkout/cart/${widget.cartId}',
            ),
            headers: {'Authorization': 'Bearer $token'},
          );

    if (mounted) {
      setState(() {
        _controller = controller;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Checkout',
          style: kAppTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Stack(
        children: [
          if (_controller != null)
            WebViewWidget(controller: _controller!)
          else
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          if (_isLoading && _controller != null)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}
