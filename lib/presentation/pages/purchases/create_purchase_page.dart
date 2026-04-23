import 'package:flutter/material.dart';
import 'package:mobile_camsme_sana_project/core/constants/app_color.dart';
import 'package:mobile_camsme_sana_project/core/models/purchase.dart';
import 'package:mobile_camsme_sana_project/core/models/product.dart';
import 'package:mobile_camsme_sana_project/core/services/purchase_service.dart';
import 'package:mobile_camsme_sana_project/presentation/widgets/purchase_item_row.dart';
import 'package:mobile_camsme_sana_project/presentation/widgets/supplier_picker.dart';

class CreatePurchasePage extends StatefulWidget {
  const CreatePurchasePage({super.key});

  @override
  State<CreatePurchasePage> createState() => _CreatePurchasePageState();
}

class _CreatePurchasePageState extends State<CreatePurchasePage> {
  final PurchaseService _purchaseService = PurchaseService();
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  Supplier? _selectedSupplier;
  List<PurchaseItem> _items = [];
  bool _isLoading = false;
  bool _isSubmitting = false;

  // Get all suppliers
  List<Supplier> get _suppliers => _purchaseService.suppliers;
  // Get available products (for demo, returning all)
  List<Product> get _availableProducts => _purchaseService.getProductsForSupplier(_selectedSupplier?.id ?? 0);

  // Computed total
  double get _totalAmount => _items.fold<double>(0, (sum, item) => sum + (item.price * item.quantity));

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectSupplier() async {
    await SupplierPicker.show(
      context,
      suppliers: _suppliers,
      selectedSupplier: _selectedSupplier,
      onSupplierSelected: (supplier) {
        setState(() {
          _selectedSupplier = supplier;
        });
      },
      onAddNewSupplier: () {
        // In a full implementation, this would open a form to add a new supplier
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Add new supplier feature coming soon!'),
            duration: Duration(seconds: 2),
          ),
        );
      },
    );
  }

  void _addProduct() {
    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a supplier first'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // For demo: Add first available product with default values
    if (_availableProducts.isNotEmpty) {
      setState(() {
        _items.add(PurchaseItem(
          product: _availableProducts.first,
          price: _availableProducts.first.price,
          quantity: 1,
        ));
      });
    }
  }

  void _removeProduct(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _updateQuantity(int index, int quantity) {
    setState(() {
      _items[index] = _items[index].copyWith(quantity: quantity);
    });
  }

  void _updatePrice(int index, double price) {
    setState(() {
      _items[index] = _items[index].copyWith(price: price);
    });
  }

  Future<void> _savePurchase() async {
    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a supplier'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one product'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final purchase = Purchase(
          supplier: _selectedSupplier!,
          date: DateTime.now(),
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          items: List.from(_items),
          total: _totalAmount,
          status: 'completed',
          createdAt: DateTime.now(),
        );

        await _purchaseService.createPurchase(purchase);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Purchase created successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context, true); // Return success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating purchase: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Create Purchase',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(25),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Supplier selection card
                    _buildSectionCard(
                      title: 'Supplier Information',
                      child: _buildSupplierSelector(),
                    ),

                    const SizedBox(height: 16),

                    // Products section
                    _buildSectionCard(
                      title: 'Products',
                      child: Column(
                        children: [
                          if (_items.isEmpty) ...[
                            _buildEmptyProductsState(),
                          ] else ...[
                            ...List.generate(_items.length, (index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: PurchaseItemRow(
                                  product: _items[index].product,
                                  purchasePrice: _items[index].price,
                                  quantity: _items[index].quantity,
                                  onQuantityChanged: (qty) => _updateQuantity(index, qty),
                                  onPriceChanged: (price) => _updatePrice(index, price),
                                  onRemove: () => _removeProduct(index),
                                ),
                              );
                            }),
                            const Divider(height: 24),
                          ],
                          _buildAddProductButton(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Notes section
                    _buildSectionCard(
                      title: 'Notes (Optional)',
                      child: TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Add any additional notes...',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: const TextStyle(fontSize: 14),
                        validator: (value) {
                          return null; // Optional field
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Total and Save button
                    _buildTotalAndSave(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildSupplierSelector() {
    return GestureDetector(
      onTap: _selectSupplier,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _selectedSupplier != null
              ? AppColors.secondary
              : AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _selectedSupplier != null
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _selectedSupplier != null
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.business_rounded,
                color: _selectedSupplier != null
                    ? AppColors.primary
                    : Colors.grey[500],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _selectedSupplier != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedSupplier!.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                        if (_selectedSupplier!.contactPerson != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _selectedSupplier!.contactPerson!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                        if (_selectedSupplier!.phone != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.phone,
                                size: 12,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _selectedSupplier!.phone!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    )
                  : const Text(
                      'Tap to select supplier',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                    ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: _selectedSupplier != null
                  ? AppColors.primary
                  : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyProductsState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'No products added yet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap the button below to add products',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddProductButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _addProduct,
        icon: Icon(
          Icons.add_rounded,
          size: 20,
          color: AppColors.primary,
        ),
        label: const Text(
          'Add Product',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalAndSave() {
    return Column(
      children: [
        // Total summary
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.1),
                AppColors.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.text,
                    ),
                  ),
                  Text(
                    '\$${_totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${_items.length} item${_items.length > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Save button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _savePurchase,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[400],
              elevation: 3,
              shadowColor: AppColors.primary.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Save Purchase',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
