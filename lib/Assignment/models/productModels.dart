import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModels {
  final String productName;
  final String productID;
  final String category;
  final int quantity;
  final double purchasePrice;
  final double salePrice;
  final String prodcutDescription;
  String imageURL;
  String docId;

  ProductModels({
    required this.productName,
    required this.productID,
    required this.category,
    required this.quantity,
    required this.purchasePrice,
    required this.salePrice,
    required this.prodcutDescription,
    required this.imageURL,
    required this.docId, File? image,
  });

  

  get image => null;
  // Method to convert the model to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'productID': productID,
      'category': category,
      'purchasesPrice': purchasePrice,
      'salePrice': salePrice,
      'quantity': quantity,
      'prodcutDescription': prodcutDescription,
      'imageURL': imageURL,
      'docId': docId,
    };
  }

  factory ProductModels.fromSnapshot(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>;
    return ProductModels(
      productName: data['productName'] ?? '',
      productID: data['productID'] ?? '',
      category: data['category'] ?? '',
      quantity: data['quantity'] ?? 0,
      purchasePrice:
          data['purchasePrice'] ?? 0.0, // Get purchasePrice from data
      salePrice: data['salePrice'] ?? 0.0,
      prodcutDescription: data['prodcutDescription'] ?? '',
      imageURL: data['imageURL'] ?? '',
      docId: snapshot.id, // Get document ID
    );
  }
}
