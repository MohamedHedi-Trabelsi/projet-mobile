import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = true;
  int? _userId;
  List<dynamic> _contacts = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('userId');
    if (_userId == null) {
      if (!mounted) return;
      context.go('/login');
      return;
    }
    await _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    try {
      final contacts = await ApiService.getContacts(_userId!);
      setState(() {
        _contacts = contacts;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      _showError(e.toString());
    }
  }

  Future<void> _addContactDialog() async {
    final nomCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final telCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Ajouter un contact"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nomCtrl, decoration: const InputDecoration(labelText: "Nom")),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: telCtrl, decoration: const InputDecoration(labelText: "Téléphone")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Ajouter")),
        ],
      ),
    );

    if (ok == true) {
      try {
        await ApiService.addContact(
          userId: _userId!,
          nom: nomCtrl.text.trim(),
          email: emailCtrl.text.trim(),
          telephone: telCtrl.text.trim(),
        );
        await _reload();
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  Future<void> _delete(int contactId) async {
    try {
      await ApiService.deleteContact(contactId);
      await _reload();
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Erreur"),
        content: Text(msg.replaceFirst('Exception: ', '')),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
      ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Contacts"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _reload),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addContactDialog,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _contacts.isEmpty
              ? const Center(child: Text("Aucun contact trouvé"))
              : ListView.builder(
                  itemCount: _contacts.length,
                  itemBuilder: (_, i) {
                    final c = _contacts[i] as Map<String, dynamic>;
                    final id = c['id'] as int?;
                    final nom = (c['nom'] ?? '').toString();
                    final email = (c['email'] ?? '').toString();
                    final tel = (c['telephone'] ?? '').toString();

                    return Dismissible(
                      key: ValueKey(id ?? i),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (_) async {
                        return await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Supprimer ?"),
                                content: Text("Supprimer $nom ?"),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
                                  ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Supprimer")),
                                ],
                              ),
                            ) ??
                            false;
                      },
                      onDismissed: (_) {
                        if (id != null) _delete(id);
                      },
                      child: ListTile(
                        title: Text(nom),
                        subtitle: Text("$email • $tel"),
                      ),
                    );
                  },
                ),
    );
  }
}
