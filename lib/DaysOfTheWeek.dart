import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:untitled/Pasti.dart';
import 'package:untitled/app_ui.dart';

class DaysOfTheWeek extends StatelessWidget {
  const DaysOfTheWeek({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      headerBadge: null,
      title: 'Meals',
      subtitle: '',
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Diet')
            .orderBy('giorno')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingCard();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const EmptyStateCard(
              title: 'No meal plan yet',
              message: 'Add data to the Diet collection to see your meals.',
              icon: Icons.calendar_month_outlined,
            );
          }

          final docs = snapshot.data!.docs;
          final days = orderedDistinct(docs.map((doc) => doc['giorno']));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                title: 'Days',
                caption: 'Open a day to view the meals inside it.',
              ),
              for (final day in days)
                ContentCard(
                  title: prettifyLabel(day),
                  subtitle: 'View meals for this day.',
                  icon: Icons.wb_sunny_outlined,
                  accentColor: uiLilac,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => Pasti(day: day),
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
