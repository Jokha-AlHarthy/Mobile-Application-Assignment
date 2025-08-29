import 'package:flutter/material.dart';
import 'database.dart';

class SeeOrders extends StatefulWidget {
  const SeeOrders({super.key});

  @override
  State<SeeOrders> createState() => _SeeOrdersState();
}

class _SeeOrdersState extends State<SeeOrders> {
  List<Map<String, dynamic>> allOrders = [];
  final Database db = Database();

  @override
  void initState() {
    super.initState();
    fetchAllOrders();
  }

  Future<void> fetchAllOrders() async {
    try {
      List<Map<String, dynamic>> orders = await db.fetchAllOrders();
      setState(() {
        allOrders = orders;
      });
    } catch (e) {
      debugPrint("Error fetching orders: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Orders',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0E1B35),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: allOrders.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: allOrders.length,
        itemBuilder: (context, index) {
          var order = allOrders[index];

          final image = (order["summaryImage"] as String?) ?? "default.jpg";
          final summaryName = (order["summaryName"] as String?) ?? "N/A";
          final user = (order["userFullName"] as String?) ?? "No user";
          final email = (order["userEmail"] as String?) ?? "No email";
          final price = (order["summaryPrice"] as num?)?.toDouble() ?? 0.0;
          final quantity = (order["quantity"] as int?) ?? 0;
          final date = (order["orderDateTime"] as String?) ?? "Unknown date";
          final total = price * quantity;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: ListTile(
              leading:Image.asset('images/$image',
              width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.image_not_supported),
              ),
              title: Text(summaryName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('User: $user'),
                  Text('Email: $email'),
                  Text('Price: \$${price.toStringAsFixed(2)}'),
                  Text('Qty: $quantity'),
                  Text('Date: $date'),
                ],
              ),
              trailing: Text(
                'Total: \$${total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }
}
