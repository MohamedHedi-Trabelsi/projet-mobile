import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../database/contact_db.dart';

class Contact {
  int? id;
  String nom;
  String email;
  String telephone;

  Contact({this.id, required this.nom, required this.email, required this.telephone});

  Map<String, dynamic> toMap() => {
        'id': id,
        'nom': nom,
        'email': email,
        'telephone': telephone,
      };

  static Contact fromMap(Map<String, dynamic> map) => Contact(
        id: map['id'],
        nom: map['nom'],
        email: map['email'],
        telephone: map['telephone'],
      );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Contact> contacts = [];
  List<Contact> filtered = [];

  final nom = TextEditingController();
  final email = TextEditingController();
  final tel = TextEditingController();
  final search = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> loadContacts() async {
    final data = await ContactDB.instance.getContacts();
    setState(() {
      contacts = data.map((e) => Contact.fromMap(e)).toList();
      filtered = contacts;
    });
  }

  Future<void> addContact() async {
    if (nom.text.isEmpty || email.text.isEmpty || tel.text.isEmpty) return;

    final c = Contact(nom: nom.text, email: email.text, telephone: tel.text);
    await ContactDB.instance.insertContact(c.toMap());

    nom.clear();
    email.clear();
    tel.clear();

    await loadContacts();
  }

  Future<void> deleteContact(Contact c) async {
    await ContactDB.instance.deleteContact(c.id!);
    await loadContacts();
  }

  void editContact(Contact c) {
    nom.text = c.nom;
    email.text = c.email;
    tel.text = c.telephone;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Modifier Contact"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nom),
            TextField(controller: email),
            TextField(controller: tel),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              final updated = Contact(
                id: c.id,
                nom: nom.text,
                email: email.text,
                telephone: tel.text,
              );

              await ContactDB.instance.updateContact(updated.id!, updated.toMap());
              Navigator.pop(context);
              await loadContacts();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void filterSearch(String text) {
    setState(() {
      filtered = contacts
          .where((c) =>
              c.nom.toLowerCase().contains(text.toLowerCase()) ||
              c.email.toLowerCase().contains(text.toLowerCase()) ||
              c.telephone.contains(text))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contacts SQLite"),
        actions: [
          IconButton(
              onPressed: () => context.go('/login'),
              icon: const Icon(Icons.logout))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Ajouter Contact", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 10),

            TextField(controller: nom, decoration: const InputDecoration(labelText: "Nom")),
            const SizedBox(height: 10),
            TextField(controller: email, decoration: const InputDecoration(labelText: "Email")),
            const SizedBox(height: 10),
            TextField(controller: tel, decoration: const InputDecoration(labelText: "Téléphone")),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: addContact,
              child: const Text("Ajouter"),
            ),
            const Divider(),

            TextField(
              controller: search,
              onChanged: filterSearch,
              decoration: const InputDecoration(
                labelText: "Rechercher",
                prefixIcon: Icon(Icons.search),
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final c = filtered[i];
                  return Card(
                    child: ListTile(
                      title: Text(c.nom),
                      subtitle: Text("${c.email}\n${c.telephone}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => editContact(c)),
                          IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteContact(c)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
