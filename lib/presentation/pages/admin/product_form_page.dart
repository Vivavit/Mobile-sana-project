import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_camsme_sana_project/core/constants/app_color.dart';
import 'package:mobile_camsme_sana_project/core/models/product_form_data.dart';
import 'package:mobile_camsme_sana_project/core/services/api_service.dart';
import 'package:mobile_camsme_sana_project/core/services/product_cache_service.dart';
import 'package:mobile_camsme_sana_project/core/utils/permission_checker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';

class ProductFormPage extends StatefulWidget {
  final int? productId;

  const ProductFormPage({super.key, this.productId});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  ProductFormData _formData = ProductFormData(
    name: '',
    sku: '',
    categoryId: 0,
    price: 0.0,
  );

  List<dynamic> _categories = [];
  List<dynamic> _brands = [];
  List<dynamic> _warehouses = [];

  bool _isLoading = false;
  bool _isInitialLoad = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (!PermissionChecker.canManageProducts()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission denied'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      });
      return;
    }
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final results = await Future.wait([
        ApiService.fetchCategories(),
        ApiService.fetchBrands(),
        ApiService.fetchWarehouses(),
      ]);

      List<dynamic> ensureList(dynamic data) {
        if (data is List) return data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final d = data['data'];
          if (d is List) return d;
          if (d != null) return [d];
        }
        return [];
      }

      if (mounted) {
        setState(() {
          _categories = ensureList(results[0]);
          _brands = ensureList(results[1]);
          _warehouses = ensureList(results[2]);
        });
      }

      if (widget.productId != null) {
        final productData = await ApiService.fetchProduct(widget.productId!);
        if (mounted) {
          setState(() {
            _formData = ProductFormData.fromProduct(productData);
            _isInitialLoad = false;
            _isLoading = false;
          });
        }
      } else {
        final initialWarehouseStock = _warehouses.map((w) {
          return {
            'warehouse_id': w['id'],
            'quantity': 0,
            'location_code': '',
          };
        }).toList();
        if (mounted) {
          setState(() {
            _formData = ProductFormData(
              name: '',
              sku: '',
              categoryId: 0,
              price: 0.0,
              warehouseStock: initialWarehouseStock,
            );
            _isInitialLoad = false;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isInitialLoad = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _formData.images = [picked];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeImage() async {
    setState(() {
      _formData.images = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final warehouseStockMap = _formData.toWarehouseStockMap();
    final locationCodeMap = _formData.toLocationCodeMap();

    final data = Map<String, dynamic>.from(_formData.toApiMap());
    data['warehouse_stock'] = warehouseStockMap;
    if (locationCodeMap.isNotEmpty) {
      data['location_code'] = locationCodeMap;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.productId != null) {
        await ApiService.updateProduct(widget.productId!, data, _formData.images);
        await ProductCacheService.clearCache();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product updated successfully')),
          );
          Navigator.pop(context, true);
        }
      } else {
        await ApiService.createProduct(data, _formData.images);
        await ProductCacheService.clearCache();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product created successfully')),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ─────────────────────────────────────────────
  // Shared decoration helpers
  // ─────────────────────────────────────────────

  /// Input field decoration – outlined, border weight 1, primary colour
  InputDecoration _fieldDecoration({
    required String label,
    String? hint,
    String? prefixText,
    String? suffixText,
    Widget? suffixIcon,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.primary, width: 1),
    );
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefixText,
      suffixText: suffixText,
      suffixIcon: suffixIcon,
      prefixStyle: TextStyle(
        fontWeight: FontWeight.w500,
        color: AppColors.primary,
        fontSize: 14,
      ),
      suffixStyle: TextStyle(
        fontWeight: FontWeight.w500,
        color: Colors.grey.shade500,
        fontSize: 13,
      ),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Colors.grey.shade600,
      ),
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      filled: true,
      fillColor: Colors.grey.shade50,
      counterText: '',
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded,
            size: 18, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        widget.productId != null ? 'Edit Product' : 'Add Product',
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.3,
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          height: 1,
          thickness: 1,
          color: AppColors.primary.withOpacity(0.12),
        ),
      ),
      actions: [
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _submit,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isInitialLoad) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Loading…',
              style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error_outline_rounded,
                    size: 36, color: Colors.red.shade400),
              ),
              const SizedBox(height: 20),
              const Text(
                'Something went wrong',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E)),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    height: 1.5),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                  textStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImagePicker(),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Basic Information',
              icon: Icons.layers_outlined,
              child: Column(
                children: [
                  _buildTextField(
                    label: 'Product Name *',
                    hint: 'Enter product name',
                    initialValue: _formData.name,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                    onSaved: (v) => _formData.name = v!.trim(),
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    label: 'SKU *',
                    hint: 'Enter SKU code',
                    initialValue: _formData.sku,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                    onSaved: (v) => _formData.sku = v!.trim(),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          label: 'Category *',
                          value: _formData.categoryId == 0
                              ? null
                              : _formData.categoryId,
                          items: _categories,
                          displayValue: (cat) => cat['name'] ?? 'Unnamed',
                          onChanged: (val) =>
                              setState(() => _formData.categoryId = val!),
                          validator: (v) =>
                              v == null ? 'Select a category' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown(
                          label: 'Brand',
                          value: _formData.brandId,
                          items: _brands,
                          displayValue: (b) => b['name'] ?? 'Unnamed',
                          onChanged: (val) =>
                              setState(() => _formData.brandId = val),
                          includeEmpty: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Pricing',
              icon: Icons.sell_outlined,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Price *',
                          hint: '0.00',
                          initialValue:
                              _formData.price.toStringAsFixed(2),
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                          prefixText: '\$',
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            final n = double.tryParse(v);
                            if (n == null) return 'Invalid';
                            if (n < 0) return '≥ 0';
                            return null;
                          },
                          onSaved: (v) =>
                              _formData.price = double.parse(v!.trim()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          label: 'Cost Price',
                          hint: '0.00',
                          initialValue:
                              _formData.costPrice?.toStringAsFixed(2) ?? '',
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                          prefixText: '\$',
                          validator: (v) {
                            if (v != null && v.isNotEmpty) {
                              if (double.tryParse(v) == null)
                                return 'Invalid';
                            }
                            return null;
                          },
                          onSaved: (v) => _formData.costPrice =
                              v!.isNotEmpty
                                  ? double.parse(v.trim())
                                  : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    label: 'Compare Price',
                    hint: '0.00',
                    initialValue:
                        _formData.comparePrice?.toStringAsFixed(2) ?? '',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    prefixText: '\$',
                    validator: (v) {
                      if (v != null && v.isNotEmpty) {
                        final n = double.tryParse(v);
                        if (n == null) return 'Invalid';
                        if (n < 0) return '≥ 0';
                      }
                      return null;
                    },
                    onSaved: (v) => _formData.comparePrice =
                        v!.isNotEmpty ? double.parse(v.trim()) : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Description',
              icon: Icons.notes_rounded,
              child: Column(
                children: [
                  _buildTextField(
                    label: 'Short Description',
                    hint: 'Brief product description (max 500 chars)',
                    initialValue: _formData.shortDescription ?? '',
                    maxLength: 500,
                    maxLines: 2,
                    validator: (_) => null,
                    onSaved: (v) => _formData.shortDescription =
                        v!.trim().isNotEmpty ? v.trim() : null,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    label: 'Full Description',
                    hint: 'Detailed product description',
                    initialValue: _formData.description ?? '',
                    maxLines: 4,
                    validator: (_) => null,
                    onSaved: (v) => _formData.description =
                        v!.trim().isNotEmpty ? v.trim() : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Additional Details',
              icon: Icons.tune_rounded,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Weight',
                          hint: '0.0',
                          initialValue:
                              _formData.weight?.toString() ?? '',
                          keyboardType: TextInputType.number,
                          suffixText: 'kg',
                          validator: (v) {
                            if (v != null && v.isNotEmpty) {
                              final n = double.tryParse(v);
                              if (n == null) return 'Invalid';
                              if (n < 0) return '≥ 0';
                            }
                            return null;
                          },
                          onSaved: (v) => _formData.weight =
                              v!.isNotEmpty
                                  ? double.parse(v.trim())
                                  : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          label: 'Low Stock Alert',
                          hint: 'e.g. 10',
                          initialValue:
                              _formData.defaultLowStockThreshold
                                      ?.toString() ??
                                  '',
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v != null && v.isNotEmpty) {
                              final n = int.tryParse(v);
                              if (n == null) return 'Invalid';
                              if (n < 0) return '≥ 0';
                            }
                            return null;
                          },
                          onSaved: (v) =>
                              _formData.defaultLowStockThreshold =
                                  v!.isNotEmpty
                                      ? int.parse(v.trim())
                                      : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildToggleTile(
                    title: 'Manage Stock',
                    subtitle: 'Track inventory levels for this product',
                    value: _formData.manageStock,
                    onChanged: (v) =>
                        setState(() => _formData.manageStock = v),
                  ),
                  _buildDivider(),
                  _buildToggleTile(
                    title: 'Active',
                    subtitle: 'Make this product visible to customers',
                    value: _formData.isActive,
                    onChanged: (v) =>
                        setState(() => _formData.isActive = v),
                  ),
                  _buildDivider(),
                  _buildToggleTile(
                    title: 'Featured',
                    subtitle: 'Highlight product on the homepage',
                    value: _formData.isFeatured,
                    onChanged: (v) =>
                        setState(() => _formData.isFeatured = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Warehouse Stock',
              icon: Icons.inventory_2_outlined,
              child: Column(
                children: _buildWarehouseStockFields(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Section card
  // ─────────────────────────────────────────────

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          Divider(
              height: 1,
              thickness: 1,
              color: AppColors.primary.withOpacity(0.15)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Divider(
        height: 20,
        thickness: 1,
        color: AppColors.primary.withOpacity(0.08),
      );

  // ─────────────────────────────────────────────
  // Text field
  // ─────────────────────────────────────────────

  Widget _buildTextField({
    required String label,
    required String hint,
    required String initialValue,
    TextInputType? keyboardType,
    String? prefixText,
    String? suffixText,
    int? maxLength,
    int? maxLines,
    required String? Function(String?) validator,
    required dynamic onSaved,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: _fieldDecoration(
        label: label,
        hint: hint,
        prefixText: prefixText,
        suffixText: suffixText,
      ),
      keyboardType: keyboardType,
      maxLength: maxLength,
      maxLines: maxLines ?? 1,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      validator: validator,
      onSaved: onSaved,
    );
  }

  // ─────────────────────────────────────────────
  // Dropdown
  // ─────────────────────────────────────────────

  Widget _buildDropdown({
    required String label,
    int? value,
    required List<dynamic> items,
    required String Function(dynamic) displayValue,
    required ValueChanged<int?> onChanged,
    bool includeEmpty = false,
    String? Function(int?)? validator,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.primary, width: 1),
    );
    return DropdownButtonFormField<int>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade600,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF1A1A2E),
      ),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      icon: Icon(Icons.keyboard_arrow_down_rounded,
          color: AppColors.primary, size: 20),
      isExpanded: true,
      items: [
        if (includeEmpty)
          DropdownMenuItem(
            value: null,
            child: Text('None',
                style: TextStyle(color: Colors.grey.shade400)),
          ),
        ...items.map<DropdownMenuItem<int>>((item) {
          return DropdownMenuItem(
            value: item['id'] as int,
            child: Text(displayValue(item)),
          );
        }),
      ],
      onChanged: onChanged,
      validator: validator,
    );
  }

  // ─────────────────────────────────────────────
  // Toggle tile
  // ─────────────────────────────────────────────

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => onChanged(!value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 24,
                decoration: BoxDecoration(
                  color: value
                      ? AppColors.primary
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: value
                        ? AppColors.primary
                        : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  alignment: value
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Warehouse stock fields
  // ─────────────────────────────────────────────

  List<Widget> _buildWarehouseStockFields() {
    if (_warehouses.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 16, color: Colors.grey.shade400),
              const SizedBox(width: 8),
              Text(
                'No warehouses available',
                style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade400),
              ),
            ],
          ),
        )
      ];
    }

    final stockMap = {
      for (var item in _formData.warehouseStock)
        item['warehouse_id'] as int: item
    };

    final List<Map<String, dynamic>> allStocks = _warehouses.map((wh) {
      final wid = wh['id'] as int;
      return stockMap[wid] ??
          {'warehouse_id': wid, 'quantity': 0, 'location_code': ''};
    }).toList();

    return allStocks.asMap().entries.map((entry) {
      final index = entry.key;
      final stock = entry.value;
      final warehouseName =
          _warehouses.firstWhere(
                  (wh) => wh['id'] == stock['warehouse_id'])['name'] ??
              'Warehouse';

      return Padding(
        padding: EdgeInsets.only(bottom: index < allStocks.length - 1 ? 12 : 0),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.02),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primary, width: 1),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warehouse_outlined,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      warehouseName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                          width: 1),
                    ),
                    child: Text(
                      'ID ${stock['warehouse_id']}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: TextFormField(
                      initialValue: stock['quantity'].toString(),
                      decoration: _fieldDecoration(
                        label: 'Qty',
                        hint: '0',
                      ),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
                      onSaved: (v) {
                        stock['quantity'] =
                            v!.isNotEmpty ? int.parse(v.trim()) : 0;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      initialValue: stock['location_code'] ?? '',
                      decoration: _fieldDecoration(
                        label: 'Location Code',
                        hint: 'e.g. A-01-02',
                      ),
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
                      onSaved: (v) {
                        stock['location_code'] =
                            (v ?? '').trim().isNotEmpty
                                ? v!.trim()
                                : '';
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  // ─────────────────────────────────────────────
  // Image picker
  // ─────────────────────────────────────────────

  Widget _buildImagePicker() {
    final hasImage = (_formData.images != null &&
            _formData.images!.isNotEmpty) ||
        (_formData.existingImageUrl != null &&
            _formData.existingImageUrl!.isNotEmpty);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Image box
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 1),
                borderRadius: BorderRadius.circular(10),
                color: AppColors.primary.withOpacity(0.03),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: _buildImagePreview(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Product Image',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 6),
                _buildGuidelineItem(
                    Icons.image_outlined, 'JPG, PNG or GIF · max 2 MB'),
                _buildGuidelineItem(
                    Icons.crop_square_rounded, '800 × 800 px recommended'),
                _buildGuidelineItem(
                    Icons.aspect_ratio_rounded, 'Square ratio works best'),
                if (hasImage) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _removeImage,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 14, color: Colors.red.shade400),
                        const SizedBox(width: 4),
                        Text(
                          'Remove image',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade400,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade400),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_formData.images != null && _formData.images!.isNotEmpty) {
      final image = _formData.images![0];
      final file = image is File ? image : File(image.path);
      return Image.file(file, fit: BoxFit.cover);
    }
    if (_formData.existingImageUrl != null &&
        _formData.existingImageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: _formData.existingImageUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          color: Colors.grey.shade100,
          child: Center(
            child: CircularProgressIndicator(
                strokeWidth: 1.5, color: AppColors.primary),
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          color: Colors.grey.shade100,
          child: Icon(Icons.broken_image_outlined,
              color: Colors.grey.shade400),
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined,
            size: 32, color: AppColors.primary.withOpacity(0.4)),
        const SizedBox(height: 6),
        Text(
          'Tap to add',
          style: TextStyle(
              fontSize: 11,
              color: AppColors.primary.withOpacity(0.5),
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}