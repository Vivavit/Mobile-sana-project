import 'package:flutter/material.dart';
import 'package:mobile_camsme_sana_project/core/models/order_model.dart';

class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;

  const OrderStatusBadge({
    super.key,
    required this.status,
    this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(status.color);
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: fontSize ?? 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
