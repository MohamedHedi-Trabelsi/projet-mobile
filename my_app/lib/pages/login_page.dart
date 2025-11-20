import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../database/contact_db.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passController = TextEditingController();

  void login() async {
    if (_formKey.currentState!.validate()) {
      final user = await ContactDB.instance.login(
        emailController.text.trim(),
        passController.text.trim(),
      );

      if (user != null) {
        context.go('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email ou mot de passe incorrect ❌")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Connexion",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Entrez votre email" : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: passController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Mot de passe",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Entrez votre mot de passe" : null,
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                  onPressed: login, child: const Text("Se connecter")),

              TextButton(
                onPressed: () => context.go('/signup'),
                child: const Text("Créer un compte"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
