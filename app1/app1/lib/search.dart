import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  List<String> _allCourses = [
    "Flutter for Beginners",
    "Advanced Flutter Development",
    "Introduction to Dart",
    "Building UI in Flutter",
    "State Management in Flutter",
    "Firebase with Flutter",
    "React Native Basics",
    "Android Development with Kotlin"
  ];
  List<String> _filteredCourses = [];
  @override
  void initState() {
    super.initState();
    _filteredCourses = _allCourses;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCourses = _allCourses
          .where((course) => course.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Courses'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search for a course...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _filteredCourses.isNotEmpty
                  ? ListView.builder(
                      itemCount: _filteredCourses.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_filteredCourses[index]),
                        );
                      },
                    )
                  : Center(child: Text('No courses found')),
            ),
          ],
        ),
      ),
    );
  }
}
