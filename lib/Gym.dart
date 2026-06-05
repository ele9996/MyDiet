import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:untitled/Esercizi.dart';
import 'package:untitled/app_ui.dart';

class Gym extends StatelessWidget {
  const Gym({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      headerBadge: null,
      title: 'Training',
      subtitle: '',
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Palestra')
            .orderBy('sessione')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingCard();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const EmptyStateCard(
              title: 'No training sessions yet',
              message: 'Add data to the Palestra collection to show workouts.',
              icon: Icons.fitness_center_outlined,
            );
          }

          final docs = snapshot.data!.docs;
          final sessions = orderedDistinct(docs.map((doc) => doc['sessione']));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                title: 'Sessions',
                caption: 'Open a session to view all exercises.',
              ),
              for (final session in sessions)
                ContentCard(
                  title: 'Session ${prettifyLabel(session)}',
                  subtitle: 'View exercises for this session.',
                  icon: Icons.sports_gymnastics_outlined,
                  accentColor: uiMint,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => Esercizi(sessione: session),
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
