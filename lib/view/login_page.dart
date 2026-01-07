import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'register_page.dart';
import '../services/local_storage.dart';
import '../controller/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  Future<void> signInWithEmail() async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text.trim(),
      );

      final uid = userCredential.user!.uid;

      // Récupérer ou créer utilisateur Firestore
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final userData = userDoc.exists
          ? userDoc.data()!
          : {
              'name': userCredential.user!.displayName ?? 'Utilisateur',
              'email': emailController.text.trim(),
              'provider': 'email',
            };

      // Sauvegarde Firestore si pas existant
      if (!userDoc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set(userData);
      }

      // Sauvegarde LocalStorage
      await LocalStorage.saveUser(
        name: userData['name'],
        email: userData['email'],
        provider: userData['provider'],
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

  Future<void> socialLogin(Future<User?> Function() loginMethod, String provider) async {
    final user = await loginMethod();
    if (user == null) return;

    final uid = user.uid;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!userDoc.exists) {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': user.displayName ?? 'Utilisateur',
        'email': user.email ?? '',
        'provider': provider,
      });
    }

    final userData = (await FirebaseFirestore.instance.collection('users').doc(uid).get()).data()!;

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
    const double maxFormWidth = 400.0;

    return Scaffold(
      appBar: AppBar(title: const Text("Connexion"), backgroundColor: Colors.blueAccent),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxFormWidth),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text("Bienvenue !",
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 30),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: "Adresse Email", prefixIcon: Icon(Icons.email)),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: passController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "Mot de passe", prefixIcon: Icon(Icons.lock)),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                        onPressed: signInWithEmail,
                        child: const Text("Se connecter", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Center(child: Text("— Connexion Sociale —", style: TextStyle(color: Colors.grey))),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => socialLogin(() => AuthService().signInWithGoogle(), 'google'),
                        child: const Text("Se connecter avec Google", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => socialLogin(() => AuthService().signInWithTwitter(), 'twitter'),
                        child: const Text("Se connecter avec Twitter", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
                      child: const Text("Créer un compte", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
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
