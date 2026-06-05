import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:untitled/Tipi.dart';
import 'package:untitled/app_ui.dart';

class Pasti extends StatelessWidget {
  const Pasti({super.key, required this.day});

  final String day;

  static const List<String> _mealOrder = [
    '0_Colazione',
    '1_Pranzo',
    '2_Merenda',
    '3_Cena',
    '4_Arco_Della_Giornata',
  ];

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      eyebrow: prettifyLabel(day),
      title: prettifyLabel(day),
      subtitle: '',
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Diet')
            .where('giorno', isEqualTo: day)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingCard();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const EmptyStateCard(
              title: 'No meals found',
              message: 'There are no meals configured for this day.',
              icon: Icons.lunch_dining_outlined,
            );
          }

          final meals =
              orderedDistinct(snapshot.data!.docs.map((doc) => doc['pasto']))
                ..sort((a, b) {
                  final indexA = _mealOrder.indexOf(a);
                  final indexB = _mealOrder.indexOf(b);

                  if (indexA == -1 && indexB == -1) {
                    return a.compareTo(b);
                  }
                  if (indexA == -1) {
                    return 1;
                  }
                  if (indexB == -1) {
                    return -1;
                  }
                  return indexA.compareTo(indexB);
                });

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                title: 'Meal list',
                caption: 'Open a meal to view categories and recipes.',
              ),
              for (final meal in meals)
                ContentCard(
                  title: prettifyLabel(meal),
                  subtitle: 'View categories and recipes for this meal.',
                  icon: Icons.restaurant_outlined,
                  accentColor: uiPink,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => Tipi(day: day, pasto: meal),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
