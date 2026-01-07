import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class FirestoreService {
  final CollectionReference productsRef =
      FirebaseFirestore.instance.collection('products');

  Future<void> addProduct(Product product) async {
    await productsRef.add(product.toMap());
  }

  Future<void> deleteProduct(String id) async {
    await productsRef.doc(id).delete();
  }

  Stream<List<Product>> getProducts() {
    return productsRef.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Product.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList());
  }
}
