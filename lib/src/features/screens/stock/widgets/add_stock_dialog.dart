// widgets/add_stock_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../model/stock_model.dart';
import '../provider/stock_provider.dart';

class AddStockDialog extends StatefulWidget {
  final Stock? stock; // null for add, Stock object for edit

  const AddStockDialog({Key? key, this.stock}) : super(key: key);

  @override
  State<AddStockDialog> createState() => _AddStockDialogState();
}

class _AddStockDialogState extends State<AddStockDialog> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _buyingPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _minStockController = TextEditingController();
  final _supplierController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedUnit = 'pieces';
  DateTime? _expiryDate;
  bool _isLoading = false;

  final List<String> _units = [
    'pieces', 'kg', 'grams', 'liters', 'ml', 'boxes', 'packs', 'bottles'
  ];

  final List<String> _commonCategories = [
    'Electronics', 'Clothing', 'Food', 'Beverages', 'Health', 'Beauty',
    'Home & Garden', 'Sports', 'Books', 'Toys', 'Others'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.stock != null) {
      _populateFields();
    } else {
      _minStockController.text = '5'; // Default min stock level
    }
  }

  void _populateFields() {
    final stock = widget.stock!;
    _productNameController.text = stock.productName;
    _categoryController.text = stock.category;
    _buyingPriceController.text = stock.buyingPrice.toString();
    _sellingPriceController.text = stock.sellingPrice.toString();
    _quantityController.text = stock.quantity.toString();
    _minStockController.text = stock.minStockLevel.toString();
    _selectedUnit = stock.unit;
    _expiryDate = stock.expiryDate;
    _supplierController.text = stock.supplier ?? '';
    _descriptionController.text = stock.description ?? '';
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _categoryController.dispose();
    _buyingPriceController.dispose();
    _sellingPriceController.dispose();
    _quantityController.dispose();
    _minStockController.dispose();
    _supplierController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final isEditing = widget.stock != null;

    return Dialog(
      backgroundColor: isDark ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.blue[700] : Colors.blue,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit : Icons.add,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEditing ? 'Edit Stock' : 'Add New Stock',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      _buildTextField(
                        controller: _productNameController,
                        label: 'Product Name',
                        hint: 'Enter product name',
                        icon: Icons.inventory,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter product name';
                          }
                          return null;
                        },
                        isDark: isDark,
                      ),

                      const SizedBox(height: 16),

                      // Category with dropdown
                      _buildCategoryField(isDark),

                      const SizedBox(height: 16),

                      // Price fields in a row
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _buyingPriceController,
                              label: 'Buying Price',
                              hint: '0.00',
                              icon: Icons.monetization_on,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid price';
                                }
                                return null;
                              },
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _sellingPriceController,
                              label: 'Selling Price',
                              hint: '0.00',
                              icon: Icons.attach_money,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid price';
                                }
                                return null;
                              },
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Quantity and Unit in a row
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildTextField(
                              controller: _quantityController,
                              label: 'Quantity',
                              hint: '0',
                              icon: Icons.numbers,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (int.tryParse(value) == null || int.parse(value) <= 0) {
                                  return 'Invalid quantity';
                                }
                                return null;
                              },
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildUnitDropdown(isDark),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Min Stock Level
                      _buildTextField(
                        controller: _minStockController,
                        label: 'Minimum Stock Level',
                        hint: '5',
                        icon: Icons.warning,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter minimum stock level';
                          }
                          if (int.tryParse(value) == null || int.parse(value) < 0) {
                            return 'Invalid stock level';
                          }
                          return null;
                        },
                        isDark: isDark,
                      ),

                      const SizedBox(height: 16),

                      // Expiry Date
                      _buildDateField(isDark),

                      const SizedBox(height: 16),

                      // Supplier
                      _buildTextField(
                        controller: _supplierController,
                        label: 'Supplier (Optional)',
                        hint: 'Enter supplier name',
                        icon: Icons.person,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 16),

                      // Description
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description (Optional)',
                        hint: 'Enter product description',
                        icon: Icons.description,
                        maxLines: 3,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                side: BorderSide(
                                  color: isDark ? Colors.white54 : Colors.black54,
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _saveStock,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: isDark ? Colors.blue[700] : Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                                  : Text(
                                isEditing ? 'Update' : 'Add Stock',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: isDark ? Colors.white54 : Colors.black54),
        labelStyle: TextStyle(
          color: isDark ? Colors.white70 : Colors.black54,
        ),
        hintStyle: TextStyle(
          color: isDark ? Colors.white54 : Colors.black54,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : Colors.black26,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : Colors.black26,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? Colors.blue[300]! : Colors.blue,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _categoryController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter category';
                  }
                  return null;
                },
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter or select category',
                  prefixIcon: Icon(Icons.category, color: isDark ? Colors.white54 : Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.arrow_drop_down,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
              onSelected: (value) {
                _categoryController.text = value;
              },
              itemBuilder: (context) => _commonCategories
                  .map((category) => PopupMenuItem(
                value: category,
                child: Text(category),
              ))
                  .toList(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUnitDropdown(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Unit',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedUnit,
          onChanged: (value) {
            setState(() {
              _selectedUnit = value!;
            });
          },
          items: _units.map((unit) {
            return DropdownMenuItem(
              value: unit,
              child: Text(unit),
            );
          }).toList(),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          dropdownColor: isDark ? Colors.grey[800] : Colors.white,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expiry Date (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectExpiryDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? Colors.white24 : Colors.black26,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
                const SizedBox(width: 12),
                Text(
                  _expiryDate != null
                      ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
                      : 'Select expiry date',
                  style: TextStyle(
                    color: _expiryDate != null
                        ? (isDark ? Colors.white : Colors.black87)
                        : (isDark ? Colors.white54 : Colors.black54),
                  ),
                ),
                const Spacer(),
                if (_expiryDate != null)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _expiryDate = null;
                      });
                    },
                    icon: Icon(
                      Icons.clear,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectExpiryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (date != null) {
      setState(() {
        _expiryDate = date;
      });
    }
  }

  Future<void> _saveStock() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final stock = Stock(
        id: widget.stock?.id,
        productName: _productNameController.text.trim(),
        category: _categoryController.text.trim(),
        buyingPrice: double.parse(_buyingPriceController.text),
        sellingPrice: double.parse(_sellingPriceController.text),
        quantity: int.parse(_quantityController.text),
        minStockLevel: int.parse(_minStockController.text),
        unit: _selectedUnit,
        dateAdded: widget.stock?.dateAdded ?? DateTime.now(),
        expiryDate: _expiryDate,
        supplier: _supplierController.text.trim().isEmpty
            ? null
            : _supplierController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        soldQuantity: widget.stock?.soldQuantity ?? 0,
      );

      final stockProvider = context.read<StockProvider>();
      bool success;

      if (widget.stock != null) {
        success = await stockProvider.updateStock(stock);
      } else {
        success = await stockProvider.addStock(stock);
      }

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.stock != null
                  ? 'Stock updated successfully'
                  : 'Stock added successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.stock != null
                  ? 'Failed to update stock'
                  : 'Failed to add stock',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}