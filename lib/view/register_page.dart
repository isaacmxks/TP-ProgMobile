import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import '../services/local_storage.dart';
import '../controller/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  Future<void> registerWithEmail() async {
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text.trim(),
      );

      final uid = userCredential.user!.uid;

      // Mettre à jour le displayName
      await userCredential.user!.updateDisplayName(nameController.text.trim());

      // Ajouter à Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'provider': 'email',
      });

      // Sauvegarder LocalStorage
      await LocalStorage.saveUser(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        provider: 'email',
      );

      if (context.mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Erreur")),
        );
      }
    }
  }

  Future<void> socialRegister(Future<User?> Function() loginMethod, String provider) async {
    final user = await loginMethod();
    if (user == null) return;

    final uid = user.uid;

    // Vérifier si l'utilisateur existe déjà
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!userDoc.exists) {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': user.displayName ?? 'Utilisateur',
        'email': user.email ?? '',
        'provider': provider,
      });
    }

    final userData = (await FirebaseFirestore.instance.collection('users').doc(uid).get()).data()!;

    // Sauvegarde LocalStorage
    await LocalStorage.saveUser(
      name: userData['name'],
      email: userData['email'],
      provider: userData['provider'],
    );

    if (context.mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inscription"), backgroundColor: Colors.blueAccent),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(controller: nameController, decoration: const InputDecoration(labelText: "Nom")),
                    const SizedBox(height: 15),
                    TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
                    const SizedBox(height: 15),
                    TextField(controller: passController, obscureText: true, decoration: const InputDecoration(labelText: "Mot de passe")),
                    const SizedBox(height: 30),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: registerWithEmail,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                        child: const Text("S'inscrire", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Center(child: Text("— Inscription Sociale —", style: TextStyle(color: Colors.grey))),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => socialRegister(() => AuthService().signInWithGoogle(), 'google'),
                        child: const Text("S'inscrire avec Google", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => socialRegister(() => AuthService().signInWithTwitter(), 'twitter'),
                        child: const Text("S'inscrire avec Twitter", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
