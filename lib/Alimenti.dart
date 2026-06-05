import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:untitled/app_ui.dart';

class Alimenti extends StatelessWidget {
  const Alimenti({
    super.key,
    required this.day,
    required this.pasto,
    required this.tipo,
  });

  final String day;
  final String pasto;
  final String tipo;

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      eyebrow: prettifyLabel(pasto),
      title: prettifyLabel(tipo),
      subtitle: 'Exact foods and portions for this category.',
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Diet')
            .where('giorno', isEqualTo: day)
            .where('pasto', isEqualTo: pasto)
            .where('tipo', isEqualTo: tipo)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingCard();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const EmptyStateCard(
              title: 'No foods found',
              message: 'There are no foods in this category yet.',
              icon: Icons.local_dining_outlined,
            );
          }

          final foods = snapshot.data!.docs;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                title: 'Portion guide',
                caption:
                    'Simple, readable quantities with the item name kept front and center.',
              ),
              for (final food in foods)
                ContentCard(
                  title: food['alimento'].toString(),
                  subtitle: 'Recommended portion',
                  icon: Icons.eco_outlined,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7F1EC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      food['quantita'].toString(),
                      style: const TextStyle(
                        color: Color(0xFF244B3C),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
