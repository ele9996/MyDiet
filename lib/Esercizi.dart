import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:untitled/app_ui.dart';
import 'package:untitled/exercise_media_service.dart';

class Esercizi extends StatelessWidget {
  const Esercizi({super.key, required this.sessione});

  final String sessione;

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      eyebrow: 'Workout session',
      title: 'Session ${prettifyLabel(sessione)}',
      subtitle:
          'Each exercise now opens a concrete movement GIF. Missing links are replaced with stronger fallback matches and then saved back to your data.',
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Palestra')
            .where('sessione', isEqualTo: sessione)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingCard();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const EmptyStateCard(
              title: 'No exercises found',
              message: 'This session has not been populated yet.',
              icon: Icons.format_list_bulleted_outlined,
            );
          }

          final exercises = snapshot.data!.docs;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                title: 'Exercise flow',
                caption:
                    'Open an exercise to see its movement reference and keep the session easier to follow.',
              ),
              for (final exercise in exercises)
                ContentCard(
                  title: exercise['esercizio'].toString(),
                  subtitle:
                      '${exercise['serie']} sets | ${exercise['ripetizioni']} reps | ${exercise['tempo']} tempo',
                  icon: Icons.fitness_center_outlined,
                  accentColor: uiPink,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: uiLilac,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      exercise['peso'].toString(),
                      style: const TextStyle(
                        color: uiInk,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  onTap: () {
                    showDialog<void>(
                      context: context,
                      builder: (context) => _ExerciseGifDialog(
                        exerciseName: exercise['esercizio'].toString(),
                        existingUrl:
                            exercise['spiegazioneEsercizio'].toString(),
                        reference: exercise.reference,
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

class _ExerciseGifDialog extends StatelessWidget {
  const _ExerciseGifDialog({
    required this.exerciseName,
    required this.existingUrl,
    required this.reference,
  });

  final String exerciseName;
  final String existingUrl;
  final DocumentReference reference;

  @override
  Widget build(BuildContext context) {
    final mediaService = ExerciseMediaService();

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: FutureBuilder<String>(
        future: mediaService.resolveGifUrl(
          exerciseName: exerciseName,
          existingUrl: existingUrl,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(28),
              child: SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          final gifUrl = snapshot.data ??
              'https://upload.wikimedia.org/wikipedia/commons/e/e9/Jumpingjacks.gif';

          if (existingUrl.trim().isEmpty && snapshot.hasData) {
            reference.update({'spiegazioneEsercizio': gifUrl});
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        child: Image.network(
                          gifUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.network(
                              'https://upload.wikimedia.org/wikipedia/commons/e/e9/Jumpingjacks.gif',
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: IconButton.filledTonal(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exerciseName,
                          style: const TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: uiInk,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'This GIF is loaded from the stored exercise link or a stronger fallback source and then persisted back when needed.',
                          style: TextStyle(
                            color: Color(0xFF6B5D89),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
