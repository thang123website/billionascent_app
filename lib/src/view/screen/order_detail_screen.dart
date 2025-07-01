import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:martfury/src/model/order.dart';
import 'package:martfury/src/theme/app_fonts.dart';
import 'package:martfury/src/theme/app_colors.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFB800);
      case 'processing':
        return const Color(0xFF2196F3);
      case 'completed':
        return const Color(0xFF4CAF50);
      case 'cancelled':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'processing':
        return Icons.local_shipping;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'orders.status_pending'.tr();
      case 'processing':
        return 'orders.status_processing'.tr();
      case 'completed':
        return 'orders.status_completed'.tr();
      case 'cancelled':
        return 'orders.status_cancelled'.tr();
      default:
        return status;
    }
  }

  void _copyOrderNumber() {
    Clipboard.setData(ClipboardData(text: widget.order.code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('orders.order_number_copied'.tr()),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getRelativeDate(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return DateFormat('dd MMM yyyy').format(date);
    } else if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'orders.time_days_ago_single'.tr();
      } else {
        return 'orders.time_days_ago_multiple'.tr(
          namedArgs: {'count': difference.inDays.toString()},
        );
      }
    } else if (difference.inHours > 0) {
      if (difference.inHours == 1) {
        return 'orders.time_hours_ago_single'.tr();
      } else {
        return 'orders.time_hours_ago_multiple'.tr(
          namedArgs: {'count': difference.inHours.toString()},
        );
      }
    } else if (difference.inMinutes > 0) {
      if (difference.inMinutes == 1) {
        return 'orders.time_minutes_ago_single'.tr();
      } else {
        return 'orders.time_minutes_ago_multiple'.tr(
          namedArgs: {'count': difference.inMinutes.toString()},
        );
      }
    } else {
      return 'orders.time_just_now'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(widget.order.status.value);
    final statusIcon = _getStatusIcon(widget.order.status.value);

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'orders.order_details'.tr(),
          style: kAppTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Order Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    statusColor.withValues(alpha: 0.1),
                    statusColor.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(statusIcon, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getStatusText(widget.order.status.value),
                              style: kAppTextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Order ${widget.order.code}',
                              style: kAppTextStyle(
                                fontSize: 14,
                                color: AppColors.getSecondaryTextColor(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: _copyOrderNumber,
                        color: statusColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildOrderProgress(),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Order Information Card
            _buildSectionCard(
              title: 'orders.order_information'.tr(),
              icon: Icons.receipt_long,
              child: Column(
                children: [
                  _buildInfoRow(
                    'orders.order_number_label'.tr(),
                    widget.order.code,
                    icon: Icons.tag,
                  ),
                  _buildInfoRow(
                    'orders.order_date_label'.tr(),
                    _getRelativeDate(widget.order.createdAt),
                    icon: Icons.calendar_today,
                  ),
                  _buildInfoRow(
                    'orders.tax_amount_label'.tr(),
                    widget.order.taxAmountFormatted,
                    icon: Icons.account_balance,
                  ),
                  _buildInfoRow(
                    'orders.shipping_amount_label'.tr(),
                    widget.order.shippingAmountFormatted,
                    icon: Icons.local_shipping,
                  ),
                  _buildInfoRow(
                    'orders.total_amount_label'.tr(),
                    widget.order.amountFormatted,
                    icon: Icons.attach_money,
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Customer Information Card
            _buildSectionCard(
              title: 'orders.customer_information'.tr(),
              icon: Icons.person,
              child: Column(
                children: [
                  _buildInfoRow(
                    'orders.customer_name'.tr(),
                    widget.order.customer.name,
                    icon: Icons.person_outline,
                  ),
                  _buildInfoRow(
                    'common.email'.tr(),
                    widget.order.customer.email,
                    icon: Icons.email_outlined,
                  ),
                  _buildInfoRow(
                    'orders.customer_phone'.tr(),
                    widget.order.customer.phone,
                    icon: Icons.phone_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Shipping Information Card
            _buildSectionCard(
              title: 'orders.shipping_information'.tr(),
              icon: Icons.local_shipping,
              child: Column(
                children: [
                  _buildInfoRow(
                    'orders.shipping_method'.tr(),
                    widget.order.shippingMethod.label,
                    icon: Icons.local_shipping_outlined,
                  ),
                  _buildInfoRow(
                    'orders.shipping_status'.tr(),
                    widget.order.shippingStatus.label,
                    icon: Icons.track_changes,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Payment Information Card
            _buildSectionCard(
              title: 'orders.payment_information'.tr(),
              icon: Icons.payment,
              child: Column(
                children: [
                  _buildInfoRow(
                    'orders.payment_method'.tr(),
                    widget.order.paymentMethod.label,
                    icon: Icons.credit_card,
                  ),
                  _buildInfoRow(
                    'orders.payment_status'.tr(),
                    widget.order.paymentStatus.label,
                    icon: Icons.account_balance_wallet,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Products Card
            _buildSectionCard(
              title: 'orders.products'.tr(),
              icon: Icons.shopping_bag,
              child:
                  widget.order.products.isNotEmpty
                      ? Column(
                        children:
                            widget.order.products
                                .asMap()
                                .entries
                                .map(
                                  (entry) => Padding(
                                    padding: EdgeInsets.only(
                                      bottom:
                                          entry.key <
                                                  widget.order.products.length -
                                                      1
                                              ? 16
                                              : 0,
                                    ),
                                    child: _buildProductItem(entry.value),
                                  ),
                                )
                                .toList(),
                      )
                      : Container(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 48,
                              color: AppColors.getSecondaryTextColor(context),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'orders.no_products_in_order'.tr(),
                              style: kAppTextStyle(
                                fontSize: 16,
                                color: AppColors.getSecondaryTextColor(context),
                              ),
                            ),
                          ],
                        ),
                      ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderProgress() {
    final statuses = ['pending', 'processing', 'completed'];
    final currentStatusIndex = statuses.indexOf(
      widget.order.status.value.toLowerCase(),
    );

    return Row(
      children:
          statuses.asMap().entries.map((entry) {
            final index = entry.key;
            final status = entry.value;
            final isActive = index <= currentStatusIndex;
            final isCurrent = index == currentStatusIndex;

            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color:
                                isActive
                                    ? _getStatusColor(widget.order.status.value)
                                    : AppColors.getBorderColor(context),
                            shape: BoxShape.circle,
                            border:
                                isCurrent
                                    ? Border.all(
                                      color: _getStatusColor(
                                        widget.order.status.value,
                                      ),
                                      width: 3,
                                    )
                                    : null,
                          ),
                          child: Icon(
                            _getStatusIcon(status),
                            color: isActive ? Colors.white : AppColors.getSecondaryTextColor(context),
                            size: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getStatusText(status),
                          style: kAppTextStyle(
                            fontSize: 12,
                            fontWeight:
                                isCurrent ? FontWeight.bold : FontWeight.normal,
                            color:
                                isActive
                                    ? _getStatusColor(widget.order.status.value)
                                    : AppColors.getSecondaryTextColor(context),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (index < statuses.length - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        color:
                            index < currentStatusIndex
                                ? _getStatusColor(widget.order.status.value)
                                : AppColors.getBorderColor(context),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.getSkeletonColor(context).withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: kAppTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    IconData? icon,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppColors.getSecondaryTextColor(context)),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: kAppTextStyle(
                fontSize: 14,
                color: AppColors.getSecondaryTextColor(context),
                fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: kAppTextStyle(
                fontSize: 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                color: isTotal ? AppColors.primary : AppColors.getPrimaryTextColor(context),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(dynamic product) {
    final String imageUrl = product['product_image'] ?? '';
    final String productName = product['product_name'] ?? 'N/A';
    final String attributes = product['attributes']?.toString() ?? '';
    final int quantity = product['quantity'] ?? 0;
    final String amountFormatted = product['amount_formatted'] ?? 'N/A';
    final String totalFormatted = product['total_formatted'] ?? 'N/A';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorderColor(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.getCardBackgroundColor(context),
              boxShadow: [
                BoxShadow(
                  color: AppColors.getSkeletonColor(context).withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  imageUrl.isNotEmpty
                      ? Image.network(
                        imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              color: AppColors.getSkeletonColor(context),
                              child: Icon(
                                Icons.image_not_supported,
                                size: 32,
                                color: AppColors.getSecondaryTextColor(context),
                              ),
                            ),
                      )
                      : Container(
                        color: AppColors.getSkeletonColor(context),
                        child: Icon(
                          Icons.image_not_supported,
                          size: 32,
                          color: AppColors.getSecondaryTextColor(context),
                        ),
                      ),
            ),
          ),
          const SizedBox(width: 16),
          // Enhanced Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: kAppTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getPrimaryTextColor(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (attributes.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.blue[900]!.withValues(alpha: 0.2)
                          : Colors.blue[50],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      attributes,
                      style: kAppTextStyle(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.blue[300]
                            : Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildProductDetailChip(
                      'orders.quantity_label'.tr(),
                      quantity.toString(),
                      Icons.inventory_2_outlined,
                    ),
                    _buildProductDetailChip(
                      'orders.price_label'.tr(),
                      amountFormatted,
                      Icons.attach_money,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calculate,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${'orders.total_label'.tr()}: $totalFormatted',
                        style: kAppTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetailChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.getBorderColor(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.getSecondaryTextColor(context)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '$label: $value',
              style: kAppTextStyle(
                fontSize: 12,
                color: AppColors.getSecondaryTextColor(context),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
