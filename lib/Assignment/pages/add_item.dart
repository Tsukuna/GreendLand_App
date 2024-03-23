import 'dart:io';
import 'package:assignment_hml/Assignment/models/productModels.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(ProductAddFormApp());
}

class ProductAddFormApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Add Product'),
          backgroundColor: Colors.greenAccent,
        ),
        body: SingleChildScrollView(
          child: ProductAddForm(),
        ),
      ),
    );
  }
}

class ProductAddForm extends StatefulWidget {
  get purchasePriceController => null;

  @override
  _ProductAddFormState createState() => _ProductAddFormState();
}

class _ProductAddFormState extends State<ProductAddForm> {
  TextEditingController productNameController = TextEditingController();
  TextEditingController productIDController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController purchasePriceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController salePriceController = TextEditingController();

  File? image;

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future<void> addProductToFirestore() async {
    try {
      // Get references to Firestore and Firebase Storage
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      FirebaseStorage storage = FirebaseStorage.instance;

      // Upload image to Firebase Storage
      String imagePath =
          'product_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      UploadTask uploadTask = storage.ref().child(imagePath).putFile(image!);
      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      // Create a new ProductModels instance
      ProductModels product = ProductModels(
        productName: productNameController.text,
        productID: productIDController.text,
        category: categoryController.text,
        quantity: int.parse(quantityController.text),
        purchasePrice: double.parse(purchasePriceController.text),
        salePrice: double.parse(salePriceController.text),
        prodcutDescription: descriptionController.text,
        imageURL: imageUrl,
        docId: '',
      );

      // Add product data to Firestore
      await firestore.collection('products').add(product.toMap());

      // Clear all text controllers
      productNameController.clear();
      productIDController.clear();
      categoryController.clear();
      quantityController.clear();
      purchasePriceController.clear();
      salePriceController.clear();
      descriptionController.clear();

      // Show success message
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Product added successfully.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      print('Error adding product: $error');
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to add product. Please try again later.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            controller: productIDController,
            labelText: 'Product ID',
            keyboardType: TextInputType.text,
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
            readOnly: true,
          ),
          SizedBox(height: 20.0),
          InputField(
            controller: descriptionController,
            keyboardType: TextInputType.multiline,
            labelText: 'Product Description',
          ),
          SizedBox(height: 20.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload Product Image',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              GestureDetector(
                onTap: () {
                  pickImage();
                },
                child: Container(
                  width: double.infinity,
                  height: 150.0,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: image != null
                      ? Image.file(
                          image!,
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: Icon(
                            Icons.add_a_photo,
                            size: 50.0,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () async {
              // Call function to add product to Firestore
              await addProductToFirestore();
            },
            child: Text('Add Product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
            ),
          ),
        ],
      ),
    );
  }

  void calculateSalePrice() {
    double purchasePrice = double.tryParse(purchasePriceController.text) ?? 0.0;
    double salePrice = purchasePrice + (0.4 * purchasePrice);
    salePriceController.text = salePrice.toStringAsFixed(0);
  }
}

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final bool readOnly;

  const InputField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.readOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      readOnly: readOnly,
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
