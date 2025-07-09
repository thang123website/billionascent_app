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

  void _showErrorDialog(String errorDescription, String? failedUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Lỗi tải trang',
            style: kAppTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Có lỗi xảy ra khi tải trang thanh toán:',
                style: kAppTextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorDescription,
                style: kAppTextStyle(
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
              if (failedUrl != null) ...[
                const SizedBox(height: 8),
                Text(
                  'URL: $failedUrl',
                  style: kAppTextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
                // Reload WebView
                if (_controller != null) {
                  _controller!.reload();
                }
              },
              child: Text(
                'Thử lại',
                style: kAppTextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
                Navigator.of(context).pop(); // Quay lại trang trước
              },
              child: Text(
                'Quay lại',
                style: kAppTextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        );
      },
    );
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
          // Add user agent to help with compatibility
          ..setUserAgent('BillionascentApp/1.0 (iOS)')
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                debugPrint('WebView started loading: $url');
                if (mounted) {
                  setState(() {
                    _isLoading = true;
                  });
                }
              },
              onPageFinished: (String url) {
                debugPrint('WebView finished loading: $url');
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              onNavigationRequest: (NavigationRequest request) {
                debugPrint('WebView navigation request: ${request.url}');
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
                debugPrint('Error code: ${error.errorCode}');
                debugPrint('Error type: ${error.errorType}');
                debugPrint('Failed URL: ${error.url}');
                
                // Only show dialog for main frame errors (not sub-resources like images, ads, etc.)
                if (mounted && error.errorType == WebResourceErrorType.hostLookup ||
                    error.errorType == WebResourceErrorType.timeout ||
                    error.errorType == WebResourceErrorType.connect ||
                    error.errorType == WebResourceErrorType.authentication) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showErrorDialog(error.description, error.url);
                  });
                }
              },
            ),
          );

    // Load the checkout URL
    final checkoutUrl = '${AppConfig.apiBaseUrl}/api/v1/ecommerce/checkout/cart/${widget.cartId}';
    debugPrint('Loading checkout URL: $checkoutUrl');
    
    controller.loadRequest(
      Uri.parse(checkoutUrl),
      headers: {'Authorization': 'Bearer $token','X-API-KEY': AppConfig.apiKey,},
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
