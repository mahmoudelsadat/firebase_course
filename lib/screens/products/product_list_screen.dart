import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/product_service.dart';
import '../../services/firebase_auth_service.dart';
import '../../models/product_model.dart';
import '../../models/user_model.dart';

class ProductListScreen extends StatefulWidget {
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
    setState(() => _user = userData);
  }

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Product Name')),
            TextField(controller: descController, decoration: InputDecoration(labelText: 'Description')),
            TextField(controller: priceController, decoration: InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final product = ProductModel(
                id: '',
                name: nameController.text,
                description: descController.text,
                price: double.tryParse(priceController.text) ?? 0.0,
                isAvailable: true,
              );
              _productService.addProduct(product);
              Navigator.pop(context);
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isPharmacist = _user?.role == UserRole.pharmacist;

    return Scaffold(
      body: StreamBuilder<List<ProductModel>>(
        stream: _productService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());

          final products = snapshot.data ?? [];
          if (products.isEmpty) return Center(child: Text('No products available.'));

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading: Icon(Icons.medication, color: Colors.blue),
                title: Text(product.name),
                subtitle: Text(product.description),
                trailing: Text('\$${product.price}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              );
            },
          );
        },
      ),
      floatingActionButton: isPharmacist
          ? FloatingActionButton(
              onPressed: _showAddProductDialog,
              child: Icon(Icons.add),
              tooltip: 'Add Product',
            )
          : null,
    );
  }
}
