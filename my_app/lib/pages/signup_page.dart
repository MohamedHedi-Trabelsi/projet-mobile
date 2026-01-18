import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';

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
  final password = TextEditingController();
  bool _loading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final user = await ApiService.signup(
        nom: nom.text.trim(),
        prenom: prenom.text.trim(),
        email: email.text.trim(),
        password: password.text,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', user['id'] as int);

      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Erreur"),
        content: Text(msg.replaceFirst('Exception: ', '')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nom.dispose();
    prenom.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inscription")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: nom,
                  decoration: const InputDecoration(labelText: "Nom"),
                  validator: (v) => (v == null || v.isEmpty) ? "Nom requis" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: prenom,
                  decoration: const InputDecoration(labelText: "Prénom"),
                  validator: (v) => (v == null || v.isEmpty) ? "Prénom requis" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: email,
                  decoration: const InputDecoration(labelText: "Email"),
                  validator: (v) => (v == null || v.isEmpty) ? "Email requis" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: password,
                  decoration: const InputDecoration(labelText: "Mot de passe"),
                  obscureText: true,
                  validator: (v) => (v == null || v.length < 4) ? "Min 4 caractères" : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loading ? null : _register,
                  child: _loading
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text("S’inscrire"),
                ),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text("J'ai déjà un compte"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
