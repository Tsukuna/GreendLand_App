import 'package:assignment_hml/Assignment/pages/edit_product.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(ECommerceCardApp());
}

class ECommerceCardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ECommerceCard(),
    );
  }
}

class ECommerceCard extends StatefulWidget {
  const ECommerceCard({Key? key}) : super(key: key);

  @override
  _ECommerceCardState createState() => _ECommerceCardState();
}

class _ECommerceCardState extends State<ECommerceCard> {
  List<DocumentSnapshot> productsData = [];
  Future<List<DocumentSnapshot>> getProductsData() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('products').get();
    return snapshot.docs;
  }

  Future<void> deleteProduct(String docId, String imageURL) async {
    try {
      // Delete document from Firestore
      await FirebaseFirestore.instance
          .collection('products')
          .doc(docId)
          .delete();

      // Delete image from Firebase Storage
      await FirebaseStorage.instance.refFromURL(imageURL).delete();

      // Remove the deleted product from the list
      setState(() {
        productsData.removeWhere((product) => product.id == docId);
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product deleted successfully')),
      );
    } catch (error) {
      print('Error deleting product: $error');
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete product')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.greenAccent,
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: getProductsData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final List<DocumentSnapshot> productsData = snapshot.data!;

            return ListView.builder(
              itemCount: productsData.length,
              itemBuilder: (context, index) {
                final productData =
                    productsData[index].data() as Map<String, dynamic>;
                final docId = productsData[index].id;
                final imageURL = productData['imageURL'];

                return GestureDetector(
                  onTap: () {
                    // Navigate to the editable page with the product data
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditablePage(
                          productData: productData,
                          docId: docId,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.all(10.0),
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image
                          GestureDetector(
                            onTap: () {
                              // Navigate to ProductDetailPage
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailPage(
                                      productData: productData),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              child: SizedBox(
                                width: 150.0,
                                height: 170,
                                child: Image.network(
                                  productData['imageURL'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product Name
                                Text(
                                  productData['productName'],
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                // Category
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 4.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.greenAccent,
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Text(
                                    productData['category'],
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Product ID: ',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: productData['productID'],
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                // Product Price
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Sale Price: ',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            '\$${productData['salePrice'].toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20.0),
                                // Buttons: Edit and Delete
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // Edit Button
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // Handle edit action
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return EditablePage(
                                                    productData: productData,
                                                    docId: docId);
                                              },
                                            ),
                                          );
                                        },
                                        child: Text('Edit'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.greenAccent,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.0),
                                    // Delete Button
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // Show confirmation dialog
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Confirm Delete'),
                                                content: Text(
                                                    'Are you sure you want to delete this product?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: Text('Cancel',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black)),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      // Perform delete action
                                                      deleteProduct(
                                                          docId, imageURL);
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(
                                                      'Delete',
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child: Text('Delete'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> productData;

  const ProductDetailPage({Key? key, required this.productData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Detail'),
        backgroundColor: Colors.greenAccent,
      ),
      body: SingleChildScrollView(
        child: ProductDetail(productData: productData),
      ),
    );
  }
}

class ProductDetail extends StatelessWidget {
  final Map<String, dynamic> productData;

  const ProductDetail({Key? key, required this.productData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Image
        Image.network(
          productData['imageURL'],
          height: 200,
          fit: BoxFit.cover,
        ),
        SizedBox(height: 5.0),
        // Product Details
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Product Name',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5.0),
              Text(productData['productName'], style: TextStyle(fontSize: 16)),
              SizedBox(height: 20.0),
              Text(
                'Product ID',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5.0),
              Text(productData['productID'], style: TextStyle(fontSize: 16)),
              SizedBox(height: 20.0),
              Text(
                'Category',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5.0),
              Text(productData['category'], style: TextStyle(fontSize: 16)),
              SizedBox(height: 20.0),
              Text(
                'Quantity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5.0),
              Text(productData['quantity'].toString(),
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 20.0),
              Text(
                'Purchased Price',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5.0),
              Text('\$${productData['purchasesPrice'].toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 20.0),
              Text(
                'Sale Price',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5.0),
              Text('\$${productData['salePrice'].toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 20.0),
              Text(
                'Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5.0),
              Text(productData['prodcutDescription'],
                  style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }
}
