import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'database.dart';
import 'dart:async';

class OrdersScreen extends StatefulWidget {
  final String fullName;
  final String email;

  const OrdersScreen({super.key, required this.fullName, required this.email});

  @override
  State<OrdersScreen> createState() => OrdersScreenState();
}

class OrdersScreenState extends State<OrdersScreen> {
  List<Map<String, dynamic>> summaries = [];
  List<Map<String, dynamic>> myOrders = [];
  final Map<String, TextEditingController> quantityControllers = {};
  final Database db = Database();
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchAll();
  }

  // Fetch all summaries and orders from the database
  Future<void> fetchAll() async {
    try {
      var summaryList = await db.fetchsummaries();
      var orderList = await db.fetchOrders(widget.email);
      if (kDebugMode) {
        print('Fetched summaries: ${summaryList.length}');
        print('Fetched orders: ${orderList.length}');
      }

      setState(() {
        summaries = summaryList;
        myOrders = orderList;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching data: $e");
      }
    }
  }

  @override
  void dispose() {
    // Dispose all quantity controllers when screen is disposed
    for (var controller in quantityControllers.values) {
      controller.dispose();
    }
    searchController.dispose();
    super.dispose();
  }

  // Function to handle buying (reserving) a summary
  void buysummary(Map<String, dynamic> summary) async {
    try {
      final String key = summary['key'];
      final int available = (summary['quantity'] is int)
          ? summary['quantity']
          : int.tryParse(summary['quantity'].toString()) ?? 0;
      final controller = quantityControllers[key];
      int toBuy = int.tryParse(controller?.text ?? "") ?? 0;

      if (toBuy <= 0 || toBuy > available) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid quantity!')),
        );
        return;
      }

      await db.buysummary(
        userFullName: widget.fullName,
        userEmail: widget.email,
        summary: summary,
        quantity: toBuy,
      );
      controller?.clear();
      await fetchAll();
    } catch (e) {
      if (kDebugMode) {
        print('Error buying summary: $e');
      }
    }
  }

  // Filter summaries based on search query
  List<Map<String, dynamic>> get filteredSummaries {
    if (searchQuery.isEmpty) return summaries;
    return summaries
        .where((s) => (s['course'] ?? '')
        .toString()
        .toLowerCase()
        .contains(searchQuery.toLowerCase()))
        .toList();
  }

  // Build the screen UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Orders",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0E1B35),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar for filtering summaries
              TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: 'Search summaries by course',
                  prefixIcon: Icon(Icons.search, color: Colors.black,),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 12),

              const Text(
                "Available summaries",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              // Display filtered list of available summaries
              ...filteredSummaries.map((summary) {
                final key = summary['key'];
                quantityControllers.putIfAbsent(
                  key,
                      () => TextEditingController(),
                );
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: Image.asset(
                      'images/${summary["imageName"] ?? "default.png"}',
                      width: 50,
                      errorBuilder: (c, e, s) => const Icon(Icons.image),
                    ),
                    subtitle: Text(
                      'Course: ${summary["course"] ?? "N/A"}\nAvailable: ${summary["quantity"] ?? "0"}\nPrice: \$${summary["price"] ?? "0"}',
                    ),
                    trailing: SizedBox(
                      width: 150,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 40,
                            child: TextField(
                              controller: quantityControllers[key],
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'Qty',
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0E1B35),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              onPressed: () => buysummary(summary),
                              child: const Text(
                                'Reserve',
                                style: TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const Divider(),

              const Text(
                "My Orders",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              // Display list of user's orders
              ...myOrders.map((order) {
                final TextEditingController qtyCtrl = TextEditingController(
                  text: order['quantity'].toString(),
                );
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: Image.asset(
                      'images/${order["summaryImage"] ?? "default.png"}',
                      width: 40,
                      errorBuilder: (c, e, s) => const Icon(Icons.image),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Course: ${order["summaryName"] ?? "N/A"}'),
                        Text('Price: \$${order["summaryPrice"] ?? "0"}'),
                        Text('Qty: ${order["quantity"] ?? "0"}'),
                        Text('Date: ${order["orderDateTime"] ?? "N/A"}'),
                      ],
                    ),
                    trailing: Text(
                      'Total: \$${((order["quantity"] ?? 0) * (order["summaryPrice"] ?? 0)).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
