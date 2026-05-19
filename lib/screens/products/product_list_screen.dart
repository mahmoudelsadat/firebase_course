import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/product_service.dart';
import '../../services/firebase_auth_service.dart';
import '../../models/product_model.dart';
import '../../models/user_model.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductService _productService = ProductService();
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final auth = Provider.of<FirebaseAuthService>(context, listen: false);
    final userData = await auth.getUserData(FirebaseAuth.instance.currentUser!.uid);
    if (mounted) setState(() => _user = userData);
  }

  void _showAddProductSheet() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();

    // Dynamic Theme Variables
    bool isLight = Theme.of(context).brightness == Brightness.light;
    Color surfaceColor = Theme.of(context).colorScheme.surface;
    Color accentColor = isLight ? Theme.of(context).primaryColor : const Color(0xFF4ADE80);
    Color textColor = isLight ? Colors.black87 : const Color(0xFFF8FAFC);
    Color buttonTextColor = isLight ? Colors.white : const Color(0xFF064E3B);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 32,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add New Inventory', style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _buildModernInput(nameController, 'Product Name', Icons.medication_outlined),
              const SizedBox(height: 16),
              _buildModernInput(descController, 'Description', Icons.description_outlined, maxLines: 2),
              const SizedBox(height: 16),
              _buildModernInput(priceController, 'Price (\$)', Icons.attach_money, isNumber: true),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: buttonTextColor,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: isLight ? 4 : 0,
                  shadowColor: accentColor.withOpacity(0.4),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  final product = ProductModel(
                    id: '',
                    name: nameController.text,
                    description: descController.text,
                    price: double.parse(priceController.text),
                    isAvailable: true,
                  );
                  _productService.addProduct(product);
                  Navigator.pop(context);
                },
                child: const Text('Save Product'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernInput(TextEditingController controller, String label, IconData icon, {int maxLines = 1, bool isNumber = false}) {
    bool isLight = Theme.of(context).brightness == Brightness.light;
    Color bgColor = isLight ? Theme.of(context).scaffoldBackgroundColor : const Color(0xFF0B141A);
    Color accentColor = isLight ? Theme.of(context).primaryColor : const Color(0xFF4ADE80);
    Color textColor = isLight ? Colors.black87 : const Color(0xFFF8FAFC);
    Color textMutedColor = isLight ? Colors.black54 : const Color(0xFF94A3B8);
    Color borderColor = isLight ? Colors.black12 : Colors.transparent;

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      style: TextStyle(color: textColor),
      validator: (val) {
        if (val == null || val.isEmpty) return 'Required field';
        if (isNumber && double.tryParse(val) == null) return 'Enter a valid number';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textMutedColor),
        prefixIcon: Icon(icon, color: textMutedColor),
        filled: true,
        fillColor: bgColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: accentColor, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isPharmacist = _user?.role == UserRole.pharmacist;
    bool isLight = Theme.of(context).brightness == Brightness.light;

    // Dynamic Theme Palettes
    Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    Color surfaceColor = Theme.of(context).colorScheme.surface;
    Color accentColor = isLight ? Theme.of(context).primaryColor : const Color(0xFF4ADE80);
    Color textColor = isLight ? Colors.black87 : const Color(0xFFF8FAFC);
    Color textMutedColor = isLight ? Colors.black54 : const Color(0xFF94A3B8);
    Color buttonTextColor = isLight ? Colors.white : const Color(0xFF064E3B);
    Color cardBorderColor = isLight ? Colors.black12 : const Color(0xFF1E293B).withOpacity(0.5);
    Color shadowColor = isLight ? Colors.black.withOpacity(0.05) : Colors.black.withOpacity(0.2);

    return Scaffold(
      backgroundColor: bgColor,
      body: StreamBuilder<List<ProductModel>>(
        stream: _productService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: accentColor));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
          }

          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 80, color: textMutedColor.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text('Inventory is empty.', style: TextStyle(color: textMutedColor, fontSize: 16)),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: cardBorderColor),
                  boxShadow: [
                    BoxShadow(color: shadowColor, blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isLight ? bgColor : const Color(0xFF0B141A),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              shape: BoxShape.circle,
                              boxShadow: isLight ? [BoxShadow(color: shadowColor, blurRadius: 8, spreadRadius: 1)] : [],
                            ),
                            child: Icon(Icons.medical_services_outlined, size: 40, color: accentColor),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 16),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  product.description,
                                  style: TextStyle(color: textMutedColor, fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: TextStyle(fontWeight: FontWeight.w900, color: accentColor, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: isPharmacist
          ? FloatingActionButton.extended(
              onPressed: _showAddProductSheet,
              backgroundColor: accentColor,
              elevation: 4,
              icon: Icon(Icons.add_rounded, color: buttonTextColor),
              label: Text('Add Product', style: TextStyle(color: buttonTextColor, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }
}