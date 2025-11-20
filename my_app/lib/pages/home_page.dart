import 'package:flutter/material.dart';
import 'login_page.dart';
import '../database/contact_db.dart';

// ====================== Modèle Contact ======================
class Contact {
  int? id;
  String nom;
  String email;
  String telephone;

  Contact({
    this.id,
    required this.nom,
    required this.email,
    required this.telephone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'email': email,
      'telephone': telephone,
    };
  }

  static Contact fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] as int?,
      nom: map['nom'] as String,
      email: map['email'] as String,
      telephone: map['telephone'] as String,
    );
  }
}

// ====================== Page Home (fusionnée avec contacts) ======================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Contact> contacts = [];
  List<Contact> contactsFiltres = [];

  final TextEditingController nomController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telController = TextEditingController();
  final TextEditingController rechercheController = TextEditingController();

  @override
  void initState() {
    super.initState();
    chargerContacts();
  }

  // Charger les contacts depuis SQLite
  Future<void> chargerContacts() async {
    final data = await ContactDB.instance.getContacts();
    setState(() {
      contacts
        ..clear()
        ..addAll(data.map((e) => Contact.fromMap(e)));
      contactsFiltres = List.from(contacts);
    });
  }

  // AJOUT
  Future<void> ajouterContact() async {
    if (nomController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        telController.text.isNotEmpty) {
      final contact = Contact(
        nom: nomController.text,
        email: emailController.text,
        telephone: telController.text,
      );

      await ContactDB.instance.insertContact(contact.toMap());

      nomController.clear();
      emailController.clear();
      telController.clear();

      await chargerContacts();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contact ajouté en base SQLite ✅")),
      );
    }
  }

  // SUPPRESSION
  Future<void> supprimerContact(Contact contact) async {
    if (contact.id != null) {
      await ContactDB.instance.deleteContact(contact.id!);
      await chargerContacts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contact supprimé 🗑️")),
      );
    }
  }

  // MODIFICATION
  void modifierContact(Contact contact) {
    nomController.text = contact.nom;
    emailController.text = contact.email;
    telController.text = contact.telephone;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Modifier le contact"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomController,
                decoration: const InputDecoration(labelText: "Nom"),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: telController,
                decoration: const InputDecoration(labelText: "Téléphone"),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                nomController.clear();
                emailController.clear();
                telController.clear();
                Navigator.pop(context);
              },
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (contact.id != null) {
                  final modif = Contact(
                    id: contact.id,
                    nom: nomController.text,
                    email: emailController.text,
                    telephone: telController.text,
                  );
                  await ContactDB.instance
                      .updateContact(modif.id!, modif.toMap());
                  await chargerContacts();
                  nomController.clear();
                  emailController.clear();
                  telController.clear();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Contact modifié ✏️")),
                  );
                }
              },
              child: const Text("Enregistrer"),
            ),
          ],
        );
      },
    );
  }

  // RECHERCHE
  void rechercherContact(String query) {
    setState(() {
      if (query.isEmpty) {
        contactsFiltres = List.from(contacts);
      } else {
        contactsFiltres = contacts
            .where((c) =>
                c.nom.toLowerCase().contains(query.toLowerCase()) ||
                c.email.toLowerCase().contains(query.toLowerCase()) ||
                c.telephone.contains(query))
            .toList();
      }
    });
  }

  // DÉCONNEXION
  void deconnexion() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion des contacts"),
        actions: [
          IconButton(
            onPressed: deconnexion,
            icon: const Icon(Icons.logout),
            tooltip: "Se déconnecter",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Ajouter un contact",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nomController,
              decoration: const InputDecoration(
                  labelText: "Nom", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                  labelText: "Email", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: telController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                  labelText: "Téléphone", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: ajouterContact,
              child: const Text("Ajouter"),
            ),

            const Divider(),

            TextField(
              controller: rechercheController,
              decoration: const InputDecoration(
                  labelText: "Rechercher un contact",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder()),
              onChanged: rechercherContact,
            ),
            const SizedBox(height: 10),

            Expanded(
              child: contactsFiltres.isEmpty
                  ? const Center(
                      child: Text(
                        "Aucun contact trouvé 😕",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: contactsFiltres.length,
                      itemBuilder: (context, index) {
                        final contact = contactsFiltres[index];
                        return Card(
                          child: ListTile(
                            title: Text(contact.nom),
                            subtitle: Text(
                                "${contact.email}\n${contact.telephone}"),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.orange),
                                  onPressed: () => modifierContact(contact),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => supprimerContact(contact),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
