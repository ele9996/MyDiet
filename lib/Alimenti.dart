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
                _FoodPortionCard(
                  title: food['alimento'].toString(),
                  quantity: food['quantita'].toString(),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _FoodPortionCard extends StatelessWidget {
  const _FoodPortionCard({
    required this.title,
    required this.quantity,
  });

  final String title;
  final String quantity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: uiInk.withOpacity(0.05),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: uiLilac,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.eco_outlined,
                color: uiInk,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: uiInk,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: uiMint,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      quantity,
                      style: const TextStyle(
                        color: uiInk,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
