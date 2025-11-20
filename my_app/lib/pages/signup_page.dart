import 'package:flutter/material.dart';
import '../database/contact_db.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final nom = TextEditingController();
  final prenom = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();

  void register() async {
    if (_formKey.currentState!.validate()) {
      final user = {
        'nom': nom.text,
        'prenom': prenom.text,
        'email': email.text,
        'password': pass.text,
      };

      try {
        await ContactDB.instance.insertUser(user);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Compte créé avec succès ✅")),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email déjà utilisé ❌")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inscription")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nom,
                decoration: const InputDecoration(
                  labelText: "Nom",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Entrez votre nom" : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: prenom,
                decoration: const InputDecoration(
                  labelText: "Prénom",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Entrez votre prénom" : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: email,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v!.isEmpty ? "Entrez votre email" : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: pass,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Mot de passe",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v!.length < 4 ? "Minimum 4 caractères" : null,
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: register,
                child: const Text("S’inscrire"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
