// .where('giorno', isEqualTo: '0_Monday')
// .where('pasto', isEqualTo: '1_Pranzo')
//.where('tipo', isEqualTo: 'Frutta_Fresca')

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Pasti.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DaysOfTheWeek extends StatefulWidget {
  const DaysOfTheWeek({super.key});

  @override
  State<DaysOfTheWeek> createState() => _DaysOfTheWeekState();
}

class _DaysOfTheWeekState extends State<DaysOfTheWeek> {
  //Dichiaro variabili qui
  int _selectedIndex = 0;
  final ScrollController _homeController = ScrollController();

  Widget _listViewBody() {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Day\n",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Diet')
                  .orderBy('giorno')
                  .snapshots(), //parametrizzo query
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  final snap = snapshot.data!.docs
                      .map((doc) => doc.data())
                      .toList() as List;
                  final distinctItems =
                      snap.map((da) => da['giorno']).toSet(); //parametrizzo qui
                  return ListView.builder(
                    shrinkWrap: true,
                    primary: false,
                    itemCount: distinctItems.length,
                    itemBuilder: (context, index) {
                      return Container(
                        height: 70,
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(2, 2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 20),
                              alignment: Alignment.centerLeft,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              Pasti(
                                                  day: distinctItems
                                                      .toList()[index]
                                                      .toString())));
                                },
                                child: Text(
                                  distinctItems.toList()[index],
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  return const SizedBox();
                }
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Diet'),
      ),
      body: _listViewBody(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.open_in_new_rounded),
            label: 'Open Dialog',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: (int index) {
          switch (index) {
            case 0:
              // only scroll to top when current index is selected.
              if (_selectedIndex == index) {
                _homeController.animateTo(
                  0.0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                );
              }
              break;
            case 1:
              showModal(context);
          }
          setState(
            () {
              _selectedIndex = index;
            },
          );
        },
      ),
    );
  }

  void showModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: const Text('Example Dialog'),
        actions: <TextButton>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          )
        ],
      ),
    );
  }
}
