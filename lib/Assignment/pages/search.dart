import 'package:assignment_hml/Assignment/pages/edit_product.dart';
import 'package:assignment_hml/Assignment/pages/landProduct.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchComponent extends StatefulWidget {
  @override
  _SearchComponentState createState() => _SearchComponentState();
}

class _SearchComponentState extends State<SearchComponent> {
  final TextEditingController searchController = TextEditingController();
  List<DocumentSnapshot> filteredProducts = [];

  Future<void> searchProducts(String searchTerm) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('productName', isGreaterThanOrEqualTo: searchTerm)
        .where('productName', isLessThan: searchTerm + 'z')
        .get();

    final QuerySnapshot idSnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('productID', isEqualTo: searchTerm)
        .get();

    final List<DocumentSnapshot> combinedSnapshots = [
      ...snapshot.docs,
      ...idSnapshot.docs
    ];

    setState(() {
      filteredProducts = combinedSnapshots;
    });
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
        filteredProducts.removeWhere((product) => product.id == docId);
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
          title: Text(
            'Search Products',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.greenAccent,
          automaticallyImplyLeading: false, // Remove back icon
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Enter your search item...',
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.greenAccent),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  SearchButton(
                    onPressed: () {
                      String searchTerm = searchController.text.trim();
                      if (searchTerm.isNotEmpty) {
                        searchProducts(searchTerm);
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final productData =
                      filteredProducts[index].data() as Map<String, dynamic>;
                  final docId = filteredProducts[index].id;
                  final imageURL = productData['imageURL'];

                  return Card(
                    margin: EdgeInsets.all(10.0),
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: Colors.white, // Set card background to white

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
                                width: 143.0,
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
                                        text: '\$${productData['salePrice']}',
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
                                        child: Text(
                                          'Edit',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.greenAccent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                4.0), // Set button shape
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 5.0),
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
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                4.0), // Set button shape
                                          ),
                                        ),
                                        child: Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.white),
                                        ),
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
                  );
                },
              ),
            ),
          ],
        ));
  }
}

class SearchButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SearchButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        'Search',
        style: TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.greenAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
      ),
    );
  }
}
