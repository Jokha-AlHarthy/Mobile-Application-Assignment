import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'database.dart';
import 'addsummary.dart';
import 'updatesummary.dart';

class Listsummary extends StatefulWidget {
  const Listsummary({super.key});

  @override
  ListsummaryState createState() => ListsummaryState();
}

class ListsummaryState extends State<Listsummary> {
  final Database database = Database();
  List<Map<String, dynamic>> summarys = [];
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchsummarys();
  }

  Future<void> fetchsummarys() async {
    try {
      List<Map<String, dynamic>> summarysData = await database.fetchsummaries();

      summarysData = summarysData.map((summary) {
        return {
          "key": summary["key"],
          "course": summary["course"] ?? "Unknown",
          "quantity": summary["quantity"] is int
              ? summary["quantity"]
              : int.tryParse(summary["quantity"].toString()) ?? 0,
          "price": summary["price"] is double
              ? summary["price"]
              : double.tryParse(summary["price"].toString())?.toDouble() ?? 0.0,
          "imageName": summary["imageName"] ?? "placeholder.png",
        };
      }).toList();

      if (searchQuery.isNotEmpty) {
        summarysData = summarysData
            .where((summary) => summary["course"]
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
            .toList();
      }

      setState(() {
        summarys = summarysData;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching summary: $e');
      }
    }
  }

  Future<void> deletesummary(String key) async {
    try {
      await database.deletesummary(key);
      fetchsummarys();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting summary: $e');
      }
    }
  }

  double calculateTotalPrice(int quantity, double price) {
    return quantity * price;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'List Summaries',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color(0xFF0E1B35),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by course name',
                prefixIcon: const Icon(Icons.search, color: Colors.black,),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.black,),
                  onPressed: () {
                    _searchController.clear();
                    searchQuery = '';
                    fetchsummarys();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                searchQuery = value;
                fetchsummarys();
              },
            ),
          ),
          Expanded(
            child: summarys.isEmpty
                ? const Center(child: Text('No summaries found.'))
                : ListView.builder(
              itemCount: summarys.length,
              itemBuilder: (context, index) {
                var summary = summarys[index];
                return ListTile(
                  leading: ClipOval(
                    child: Image.asset(
                      'images/${summary["imageName"]}',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image, size: 50);
                      },
                    ),
                  ),
                  title: Text(
                    summary["course"],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quantity: ${summary["quantity"]}, Price: \$${summary["price"].toStringAsFixed(2)}',
                      ),
                      Text(
                        'Total: \$${calculateTotalPrice(summary["quantity"], summary["price"]).toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.black),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Updatesummary(
                              summaryKey: summary["key"],
                              summaryDetails: summary,
                            ),
                          ),
                        ).then((_) => fetchsummarys()),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.black),
                        onPressed: () => deletesummary(summary["key"]),
                      ),
                    ],
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Updatesummary(
                        summaryKey: summary["key"],
                        summaryDetails: summary,
                      ),
                    ),
                  ).then((_) => fetchsummarys()),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF0E1B35),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Addsummary()),
        ).then((_) => fetchsummarys()),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
