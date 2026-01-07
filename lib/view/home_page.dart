import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import '../services/local_storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? user;
  String? selectedCategory;

  User? get currentUser => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    Future.microtask(loadUserFromFirestore);
  }

  /* ================= USER ================= */

  Future<void> loadUserFromFirestore() async {
    final u = currentUser;
    if (u == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(u.uid).get();

    if (doc.exists) {
      user = doc.data();
      await LocalStorage.saveUser(
        name: user!['name'],
        email: user!['email'],
        provider: user!['provider'],
      );
    } else {
      user = {
        'name': u.displayName ?? 'Utilisateur',
        'email': u.email ?? '',
        'provider': 'email',
      };
    }

    if (mounted) setState(() {});
  }

  /* ================= ADD PRODUCT ================= */

  void addProductDialog() {
    final nameCtrl = TextEditingController();
    final catCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Ajouter un produit"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Nom")),
            TextField(controller: catCtrl, decoration: const InputDecoration(labelText: "Catégorie")),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Prix"),
            ),
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Quantité"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              final u = currentUser;
              if (u == null) return;

              await FirebaseFirestore.instance.collection('products').add({
                'name': nameCtrl.text,
                'category': catCtrl.text,
                'price': double.tryParse(priceCtrl.text) ?? 0,
                'quantity': int.tryParse(qtyCtrl.text) ?? 0,
                'userId': u.uid,
              });

              Navigator.pop(context);
            },
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
  }

  /* ================= EDIT PRODUCT ================= */

  void editProductDialog(DocumentSnapshot p) {
    final nameCtrl = TextEditingController(text: p['name']);
    final catCtrl = TextEditingController(text: p['category']);
    final priceCtrl = TextEditingController(text: p['price'].toString());
    final qtyCtrl = TextEditingController(text: p['quantity'].toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Modifier le produit"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Nom")),
            TextField(controller: catCtrl, decoration: const InputDecoration(labelText: "Catégorie")),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Prix"),
            ),
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Quantité"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('products')
                  .doc(p.id)
                  .update({
                'name': nameCtrl.text,
                'category': catCtrl.text,
                'price': double.tryParse(priceCtrl.text) ?? 0,
                'quantity': int.tryParse(qtyCtrl.text) ?? 0,
              });

              Navigator.pop(context);
            },
            child: const Text("Enregistrer"),
          ),
        ],
      ),
    );
  }

  /* ================= DELETE ================= */

  void deleteProduct(String id) async {
    await FirebaseFirestore.instance.collection('products').doc(id).delete();
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    final u = currentUser;
    if (u == null) {
      return const Scaffold(body: Center(child: Text("Utilisateur non connecté")));
    }

    Query productsQuery = FirebaseFirestore.instance
        .collection('products')
        .where('userId', isEqualTo: u.uid);

    if (selectedCategory != null) {
      productsQuery = productsQuery.where('category', isEqualTo: selectedCategory);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion des produits"),
        backgroundColor: Colors.blueAccent,
      ),

      /* ================= DRAWER ================= */

      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.blueAccent),
              accountName: Text(user?['name'] ?? 'Utilisateur'),
              accountEmail: Text(user?['email'] ?? ''),
              currentAccountPicture: const CircleAvatar(child: Icon(Icons.person)),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Déconnexion"),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                await LocalStorage.logout();
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                }
              },
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: addProductDialog,
        child: const Icon(Icons.add),
      ),

      /* ================= BODY ================= */

      body: Column(
        children: [

          /* ===== FILTER ===== */

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('products')
                .where('userId', isEqualTo: u.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();

              final categories = snapshot.data!.docs
                  .map((d) => d['category'] as String)
                  .toSet()
                  .toList();

              return Padding(
                padding: const EdgeInsets.all(12),
                child: DropdownButtonFormField<String>(
                  value: selectedCategory,
                  hint: const Text("Filtrer par catégorie"),
                  items: [
                    const DropdownMenuItem(value: null, child: Text("Toutes")),
                    ...categories.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                ),
              );
            },
          ),

          /* ===== PRODUCTS LIST ===== */

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: productsQuery.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text("Erreur Firestore"));
                }

                final products = snapshot.data?.docs ?? [];

                if (products.isEmpty) {
                  return const Center(child: Text("Aucun produit enregistré"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: products.length,
                  itemBuilder: (_, index) {
                    final p = products[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(p['name']),
                        subtitle: Text(
                          "${p['category']} • ${p['price']} \$ • Qté: ${p['quantity']}",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => editProductDialog(p),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteProduct(p.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
