import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditablePage extends StatefulWidget {
  final Map<String, dynamic> productData;
  final String docId;

  const EditablePage({
    Key? key,
    required this.productData,
    required this.docId,
  }) : super(key: key);

  @override
  _EditablePageState createState() => _EditablePageState();
}

class _EditablePageState extends State<EditablePage> {
  late TextEditingController productNameController;
  late TextEditingController categoryController;
  late TextEditingController quantityController;
  late TextEditingController purchasePriceController;
  late TextEditingController salePriceController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with product data
    productNameController =
        TextEditingController(text: widget.productData['productName']);
    categoryController =
        TextEditingController(text: widget.productData['category']);
    quantityController =
        TextEditingController(text: widget.productData['quantity'].toString());
    purchasePriceController = TextEditingController(
        text: widget.productData['purchasesPrice'].toStringAsFixed(0));
    salePriceController = TextEditingController(
        text: widget.productData['salePrice'].toStringAsFixed(0));
    descriptionController =
        TextEditingController(text: widget.productData['prodcutDescription']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        backgroundColor: Colors.greenAccent,
      ),
      body: SingleChildScrollView(
        // Wrap the Column with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InputField(
                controller: productNameController,
                labelText: 'Product Name',
              ),
              SizedBox(height: 20.0),
              InputField(
                controller: categoryController,
                labelText: 'Category',
              ),
              SizedBox(height: 20.0),
              InputField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                labelText: 'Quantity',
              ),
              SizedBox(height: 20.0),
              InputField(
                controller: purchasePriceController,
                keyboardType: TextInputType.number,
                labelText: 'Purchase Price',
                onChanged: (value) {
                  calculateSalePrice();
                },
              ),
              SizedBox(height: 20.0),
              InputField(
                controller: salePriceController,
                keyboardType: TextInputType.number,
                labelText: 'Sale Price',
              ),
              SizedBox(height: 20.0),
              InputField(
                controller: descriptionController,
                keyboardType: TextInputType.multiline,
                labelText: 'Product Description',
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  // Handle saving changes here
                  saveChanges();
                },
                child: Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void calculateSalePrice() {
    double purchasePrice = double.tryParse(purchasePriceController.text) ?? 0.0;
    double salePrice = purchasePrice + (0.4 * purchasePrice);
    salePriceController.text = salePrice.toStringAsFixed(0);
  }

  Future<void> saveChanges() async {
    try {
      // Get the updated values from the text controllers
      String productName = productNameController.text;
      String category = categoryController.text;
      int quantity = int.tryParse(quantityController.text) ?? 0;
      double purchasePrice =
          double.tryParse(purchasePriceController.text) ?? 0.0;
      double salePrice = double.tryParse(salePriceController.text) ?? 0.0;
      String description = descriptionController.text;

      // Update Firestore document
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.docId)
          .update({
        'productName': productName,
        'category': category,
        'quantity': quantity,
        'purchasesPrice': purchasePrice,
        'salePrice': salePrice,
        'prodcutDescription': description,
      });

      // // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Changes saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      // Show an error message if updating fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving changes. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      print('Error saving changes: $error');
    }
  }
}

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputType keyboardType;
  final Function(String)? onChanged;

  const InputField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.greenAccent),
        ),
        labelStyle: TextStyle(color: Colors.black),
      ),
    );
  }
}
