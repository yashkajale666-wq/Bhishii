import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const BhishiiApp());
}

class BhishiiApp extends StatelessWidget {
  const BhishiiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bhishii',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const HomePage(),
    );
  }
}

class Member {
  String name;
  String mobile;
  bool paid;
  Member({required this.name, this.mobile = '', this.paid = false});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Member> members = [];
  String bhishiiName = 'Bhishii';
  int monthlyAmount = 1000;
  int currentMonth = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      bhishiiName = p.getString('name') ?? 'Bhishii';
      monthlyAmount = p.getInt('amount') ?? 1000;
    });
  }

  Future<void> _saveSettings() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('name', bhishiiName);
    await p.setInt('amount', monthlyAmount);
  }

  void _addMember() {
    final name = TextEditingController();
    final mobile = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('सभासद जोडा'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'नाव')),
            TextField(controller: mobile, keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'मोबाइल नंबर')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('रद्द')),
          FilledButton(
            onPressed: () {
              if (name.text.trim().isNotEmpty) {
                setState(() => members.add(Member(name: name.text.trim(), mobile: mobile.text.trim())));
                Navigator.pop(context);
              }
            },
            child: const Text('जोडा'),
          ),
        ],
      ),
    );
  }

  void _settings() {
    final name = TextEditingController(text: bhishiiName);
    final amount = TextEditingController(text: monthlyAmount.toString());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('भिशी सेटिंग'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'भिशीचे नाव')),
            TextField(controller: amount, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'मासिक रक्कम')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('रद्द')),
          FilledButton(
            onPressed: () async {
              setState(() {
                bhishiiName = name.text.trim().isEmpty ? 'Bhishii' : name.text.trim();
                monthlyAmount = int.tryParse(amount.text) ?? 1000;
              });
              await _saveSettings();
              if (mounted) Navigator.pop(context);
            },
            child: const Text('सेव्ह'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paid = members.where((m) => m.paid).length;
    final total = members.length * monthlyAmount;
    return Scaffold(
      appBar: AppBar(
        title: Text(bhishiiName),
        actions: [
          IconButton(onPressed: _settings, icon: const Icon(Icons.settings)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addMember,
        icon: const Icon(Icons.person_add),
        label: const Text('सभासद जोडा'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('महिना $currentMonth', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('मासिक भिशी: ₹$monthlyAmount'),
                  Text('एकूण सभासद: ${members.length}'),
                  Text('या महिन्याची जमा: ₹${paid * monthlyAmount} / ₹$total'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _stat('सभासद', '${members.length}', Icons.people)),
              const SizedBox(width: 10),
              Expanded(child: _stat('Paid', '$paid', Icons.check_circle)),
              const SizedBox(width: 10),
              Expanded(child: _stat('बाकी', '${members.length - paid}', Icons.pending)),
            ],
          ),
          const SizedBox(height: 18),
          Text('सभासदांची यादी', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (members.isEmpty)
            const Card(child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: Text('अजून सभासद जोडलेले नाहीत.')),
            )),
          ...members.asMap().entries.map((e) {
            final i = e.key;
            final m = e.value;
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${i + 1}')),
                title: Text(m.name),
                subtitle: Text(m.mobile.isEmpty ? 'मोबाइल नंबर नाही' : m.mobile),
                trailing: Switch(
                  value: m.paid,
                  onChanged: (v) => setState(() => m.paid = v),
                ),
              ),
            );
          }),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _stat(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 5),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title),
          ],
        ),
      ),
    );
  }
}
