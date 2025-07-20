import 'package:flutter/material.dart';

class Person {
  final String name;
  final String type;
  final int age;
  final String info;
  final String phone;
  final String email;
  Person({
    required this.name,
    required this.type,
    required this.age,
    required this.info,
    required this.phone,
    required this.email,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: SearchScreen(), debugShowCheckedModeBanner: false);
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final List<Person> _persons = [
    Person(
      name: 'Alice Margaretha Santos',
      type: 'Senior Supervisor',
      age: 34,
      info: 'Alice is a senior supervisor with 10 years of experience.',
      phone: '0917-123-4567',
      email: 'alice.margaretha@gmail.com',
    ),
    Person(
      name: 'Carla Dela Peña',
      type: 'Scheduler',
      age: 29,
      info: 'Carla manages all schedules and logistics.',
      phone: '0917-123-4567',
      email: 'carla.delapena@gmail.com',
    ),
    Person(
      name: 'Bryan Matthew Cruz',
      type: 'Dock Worker',
      age: 26,
      info: 'Bryan is responsible for loading and unloading cargo.',
      phone: '0917-123-4567',
      email: 'bryan.matthew@gmail.com',
    ),
    Person(
      name: 'David Emmanuel Reyes',
      type: 'Mechanic',
      age: 31,
      info: 'David maintains and repairs all dock equipment.',
      phone: '0917-123-4567',
      email: 'david.emmanuel@gmail.com',
    ),
    // Added Dock Workers
    Person(
      name: 'Junnel, Cusi',
      type: 'Dock Worker',
      age: 28,
      info: 'Junnel is known for his efficiency and teamwork on the docks.',
      phone: '0917-123-4567',
      email: 'junnel.cusi@gmail.com',
    ),
    Person(
      name: 'Aljon, Dipasupil',
      type: 'Dock Worker',
      age: 27,
      info: 'Aljon specializes in cargo organization and safety procedures.',
      phone: '0917-123-4567',
      email: 'aljon.dipasupil@gmail.com',
    ),
    Person(
      name: 'Phil Allen, Eje',
      type: 'Dock Worker',
      age: 30,
      info: 'Phil Allen is a reliable worker with a keen eye for detail.',
      phone: '0917-123-4567',
      email: 'phil.allen@gmail.com',
    ),
    Person(
      name: 'Rhed, Escalon',
      type: 'Dock Worker',
      age: 25,
      info:
          'Rhed is always ready to assist and ensures smooth dock operations.',
      phone: '0917-123-4567',
      email: 'rhed.escalon@gmail.com',
    ),
    Person(
      name: 'Fortune, Garcia Jr.',
      type: 'Dock Worker',
      age: 32,
      info: 'Fortune brings years of experience and leadership to the team.',
      phone: '0917-123-4567',
      email: 'fortune.garcia@gmail.com',
    ),
    Person(
      name: 'Keith, Javier',
      type: 'Dock Worker',
      age: 26,
      info: 'Keith is skilled in operating heavy machinery and equipment.',
      phone: '0917-123-4567',
      email: 'keith.javier@gmail.com',
    ),
    Person(
      name: 'Ericson, Mendoza',
      type: 'Dock Worker',
      age: 29,
      info:
          'Ericson is dedicated to maintaining safety and order on the docks.',
      phone: '0917-123-4567',
      email: 'ericson.mendoza@gmail.com',
    ),
    Person(
      name: 'Alec, Sino-ag',
      type: 'Dock Worker',
      age: 24,
      info: 'Alec is a fast learner and always eager to take on new tasks.',
      phone: '0917-123-4567',
      email: 'alec.sinoag@gmail.com',
    ),
    Person(
      name: 'Romeo, Velasquez',
      type: 'Dock Worker',
      age: 31,
      info: 'Romeo is respected for his hard work and positive attitude.',
      phone: '0917-123-4567',
      email: 'romeo.velasquez@gmail.com',
    ),
    Person(
      name: 'Rodel, Maranan',
      type: 'Dock Worker',
      age: 28,
      info:
          'Rodel is dependable and ensures all shipments are handled properly.',
      phone: '0917-123-4567',
      email: 'rodel.maranan@gmail.com',
    ),
    Person(
      name: 'Alloi, Sino-ag',
      type: 'Dock Worker',
      age: 23,
      info: 'Alloi is energetic and helps keep the workflow efficient.',
      phone: '0917-123-4567',
      email: 'alloi.sinoag@gmail.com',
    ),
    Person(
      name: 'Renzy, Cantos',
      type: 'Dock Worker',
      age: 27,
      info: 'Renzy is known for his punctuality and strong work ethic.',
      phone: '0917-123-4567',
      email: 'renzy.cantos@gmail.com',
    ),
    Person(
      name: 'PJ, Cusi',
      type: 'Dock Worker',
      age: 25,
      info: 'PJ is a team player who always supports his fellow workers.',
      phone: '0917-123-4567',
      email: 'pj.cusi@gmail.com',
    ),
  ];

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final filteredPersons = _persons.where((person) {
      return person.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Opacity(
            opacity: 0.5,
            child: SizedBox.expand(
              child: Image.asset('images/ap.png', fit: BoxFit.cover),
            ),
          ),
          // Main content
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Search person...',
                    hintStyle: const TextStyle(color: Colors.black45),
                    prefixIcon: const Icon(Icons.search, color: Colors.black45),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 18,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1.2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredPersons.length,
                  itemBuilder: (context, index) {
                    final person = filteredPersons[index];
                    final isExpanded = _expandedIndex == index;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _expandedIndex = isExpanded ? null : index;
                            });
                          },
                          hoverColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.person),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            person.name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            person.type,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      isExpanded
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: Colors.grey.shade700,
                                    ),
                                  ],
                                ),
                                if (isExpanded) ...[
                                  const SizedBox(height: 12),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Information:',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Age: ${person.age}'),
                                  const SizedBox(height: 4),
                                  Text('Phone: ${person.phone}'),
                                  const SizedBox(height: 4),
                                  Text('Email: ${person.email}'),
                                  const SizedBox(height: 8),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
