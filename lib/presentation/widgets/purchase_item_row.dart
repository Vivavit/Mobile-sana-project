import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_camsme_sana_project/core/constants/app_color.dart';
import 'package:mobile_camsme_sana_project/core/models/product.dart';

class PurchaseItemRow extends StatefulWidget {
  final Product product;
  final double purchasePrice;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<double> onPriceChanged;
  final VoidCallback onRemove;

  const PurchaseItemRow({
    super.key,
    required this.product,
    required this.purchasePrice,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onPriceChanged,
    required this.onRemove,
  });

  @override
  State<PurchaseItemRow> createState() => _PurchaseItemRowState();
}

class _PurchaseItemRowState extends State<PurchaseItemRow> {
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late FocusNode _quantityFocusNode;
  late FocusNode _priceFocusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _quantityController =
        TextEditingController(text: widget.quantity.toString());
    _priceController = TextEditingController(
        text: widget.purchasePrice.toStringAsFixed(2));
    _quantityFocusNode = FocusNode();
    _priceFocusNode = FocusNode();

    _quantityFocusNode.addListener(_onFocusChange);
    _priceFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused =
          _quantityFocusNode.hasFocus || _priceFocusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _quantityFocusNode.dispose();
    _priceFocusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PurchaseItemRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quantity != widget.quantity &&
        !_quantityFocusNode.hasFocus) {
      _quantityController.text = widget.quantity.toString();
    }
    if (oldWidget.purchasePrice != widget.purchasePrice &&
        !_priceFocusNode.hasFocus) {
      _priceController.text =
          widget.purchasePrice.toStringAsFixed(2);
    }
  }

  void _decrement() {
    final current = int.tryParse(_quantityController.text) ?? 1;
    if (current > 1) {
      _quantityController.text = '${current - 1}';
      widget.onQuantityChanged(current - 1);
    }
  }

  void _increment() {
    final current = int.tryParse(_quantityController.text) ?? 1;
    _quantityController.text = '${current + 1}';
    widget.onQuantityChanged(current + 1);
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = widget.purchasePrice * widget.quantity;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isFocused
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.15),
          width: _isFocused ? 1.8 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _isFocused
                ? AppColors.primary.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: _isFocused ? 12 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header row: product name + subtotal badge + remove ──
          Padding(
            padding:
                const EdgeInsets.fromLTRB(12, 12, 8, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product colour dot
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 5, right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                // Product name
                Expanded(
                  child: Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // Subtotal pill
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '\$${subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Remove button
                GestureDetector(
                  onTap: widget.onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Colors.red[400],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, indent: 12, endIndent: 12),
          const SizedBox(height: 10),

          // ── Bottom row: qty stepper | price field ──
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                // Label + stepper
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quantity',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // ✅ FIX: stepper uses Row with fixed widths, no overflow
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary
                              .withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.primary
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            // Minus
                            _StepButton(
                              icon: Icons.remove,
                              onTap: _decrement,
                            ),
                            // Number field
                            Expanded(
                              child: TextField(
                                controller: _quantityController,
                                focusNode: _quantityFocusNode,
                                textAlign: TextAlign.center,
                                keyboardType:
                                    TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter
                                      .digitsOnly,
                                ],
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text,
                                ),
                                decoration:
                                    const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding:
                                      EdgeInsets.zero,
                                ),
                                onChanged: (value) {
                                  final qty =
                                      int.tryParse(value) ?? 1;
                                  if (qty >= 1) {
                                    widget
                                        .onQuantityChanged(qty);
                                  }
                                },
                              ),
                            ),
                            // Plus
                            _StepButton(
                              icon: Icons.add,
                              onTap: _increment,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Price field
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Unit Price',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 40,
                        child: TextField(
                          controller: _priceController,
                          focusNode: _priceFocusNode,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}')),
                          ],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                          decoration: InputDecoration(
                            prefixText: '\$ ',
                            prefixStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(
                                    horizontal: 10),
                            isDense: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: AppColors.primary
                                    .withValues(alpha: 0.2),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 1.8,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            final price =
                                double.tryParse(value) ?? 0.0;
                            widget.onPriceChanged(price);
                          },
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
}

/// Small +/- button used inside the quantity stepper
class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}