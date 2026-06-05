import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:untitled/Alimenti.dart';
import 'package:untitled/app_ui.dart';
import 'package:untitled/giallo_zafferano_service.dart';
import 'package:url_launcher/url_launcher.dart';

class Tipi extends StatefulWidget {
  const Tipi({super.key, required this.day, required this.pasto});

  final String day;
  final String pasto;

  @override
  State<Tipi> createState() => _TipiState();
}

class _TipiState extends State<Tipi> {
  final Map<String, String> _selectedItemsByCategory = {};
  final Set<String> _enabledCategories = <String>{};
  final ScrollController _scrollController = ScrollController();

  void _preserveScroll(VoidCallback change) {
    final previousOffset =
        _scrollController.hasClients ? _scrollController.offset : 0.0;
    FocusManager.instance.primaryFocus?.unfocus();

    setState(change);

    void restore() {
      if (_scrollController.hasClients) {
        final position = _scrollController.position;
        final target = previousOffset.clamp(
          position.minScrollExtent,
          position.maxScrollExtent,
        );
        _scrollController.jumpTo(target);
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      restore();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        restore();
      });
    });
    Future<void>.delayed(const Duration(milliseconds: 40), restore);
    Future<void>.delayed(const Duration(milliseconds: 120), restore);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      eyebrow: prettifyLabel(widget.day),
      title: prettifyLabel(widget.pasto),
      subtitle: '',
      scrollStorageKey: 'tipi-${widget.day}-${widget.pasto}',
      scrollController: _scrollController,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Diet')
            .where('giorno', isEqualTo: widget.day)
            .where('pasto', isEqualTo: widget.pasto)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingCard();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const EmptyStateCard(
              title: 'No categories found',
              message: 'This meal does not have food groups configured yet.',
              icon: Icons.category_outlined,
            );
          }

          final docs = snapshot.data!.docs;
          final itemsByCategory = <String, List<String>>{};
          for (final doc in docs) {
            final category = doc['tipo'].toString();
            final item = doc['alimento'].toString();
            itemsByCategory.putIfAbsent(category, () => <String>[]);
            if (!itemsByCategory[category]!.contains(item)) {
              itemsByCategory[category]!.add(item);
            }
          }

          final categories = itemsByCategory.keys.toList();
          if (_enabledCategories.isEmpty) {
            _enabledCategories.addAll(categories);
          } else {
            _enabledCategories.removeWhere(
              (category) => !categories.contains(category),
            );
            for (final category in categories) {
              if (!_enabledCategories.contains(category) &&
                  !_selectedItemsByCategory.containsKey(category)) {
                _enabledCategories.add(category);
              }
            }
          }

          for (final category in categories) {
            final items = itemsByCategory[category]!;
            if (items.isNotEmpty &&
                (!_selectedItemsByCategory.containsKey(category) ||
                    !items.contains(_selectedItemsByCategory[category]))) {
              _selectedItemsByCategory[category] = items.first;
            }
          }

          final selectedIngredients = categories
              .where((category) => _enabledCategories.contains(category))
              .map((category) => _selectedItemsByCategory[category])
              .whereType<String>()
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                title: 'Categories',
                caption: 'Open a category to inspect the foods inside it.',
              ),
              for (final category in categories)
                ContentCard(
                  title: prettifyLabel(category),
                  subtitle: 'View foods and quantities in this category.',
                  icon: Icons.widgets_outlined,
                  accentColor: uiMint,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => Alimenti(
                          day: widget.day,
                          pasto: widget.pasto,
                          tipo: category,
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 18),
              const SectionTitle(
                title: 'Recipe query',
                caption:
                    'All categories are included by default. You can remove any category, choose one item inside each active category, and generate a GialloZafferano search link.',
              ),
              InfoPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final category in categories) ...[
                      _CategoryFilterRow(
                        category: category,
                        enabled: _enabledCategories.contains(category),
                        selectedItem: _selectedItemsByCategory[category]!,
                        items: itemsByCategory[category]!,
                        onToggle: (enabled) {
                          _preserveScroll(() {
                            if (enabled) {
                              _enabledCategories.add(category);
                            } else {
                              _enabledCategories.remove(category);
                            }
                          });
                        },
                        onItemChanged: (value) {
                          _preserveScroll(() {
                            _selectedItemsByCategory[category] = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 8),
                    _RecipeQueryPanel(
                      selectedIngredients: selectedIngredients,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryFilterRow extends StatelessWidget {
  const _CategoryFilterRow({
    required this.category,
    required this.enabled,
    required this.selectedItem,
    required this.items,
    required this.onToggle,
    required this.onItemChanged,
  });

  final String category;
  final bool enabled;
  final String selectedItem;
  final List<String> items;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String> onItemChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: enabled ? Colors.white : uiBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  prettifyLabel(category),
                  style: const TextStyle(
                    color: uiInk,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              Focus(
                canRequestFocus: false,
                skipTraversal: true,
                descendantsAreFocusable: false,
                child: Material(
                  color: uiBackground,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => onToggle(!enabled),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            enabled
                                ? Icons.remove_circle_outline
                                : Icons.add_circle_outline,
                            color: uiInk,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            enabled ? 'Remove' : 'Add',
                            style: const TextStyle(
                              color: uiInk,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _InlinePicker(
            label: 'Item',
            value: selectedItem,
            enabled: enabled,
            items: items,
            onSelected: onItemChanged,
          ),
        ],
      ),
    );
  }
}

class _RecipeQueryPanel extends StatelessWidget {
  const _RecipeQueryPanel({
    required this.selectedIngredients,
  });

  final List<String> selectedIngredients;

  @override
  Widget build(BuildContext context) {
    if (selectedIngredients.isEmpty) {
      return const EmptyStateCard(
        title: 'No active categories',
        message:
            'Enable at least one category to generate a GialloZafferano query.',
        icon: Icons.filter_alt_off_outlined,
      );
    }

    final query = GialloZafferanoService().buildQuery(
      ingredients: selectedIngredients,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final ingredient in selectedIngredients)
              AccentLabel(
                text: prettifyLabel(ingredient),
                color: uiPink,
              ),
          ],
        ),
        const SizedBox(height: 14),
        ContentCard(
          title: 'GialloZafferano query',
          subtitle: query.queryText,
          icon: Icons.travel_explore_outlined,
          accentColor: uiButter,
          onTap: () async {
            await launchUrl(
              Uri.parse(query.url),
              mode: LaunchMode.externalApplication,
            );
          },
        ),
      ],
    );
  }
}

class _InlinePicker extends StatelessWidget {
  const _InlinePicker({
    required this.label,
    required this.value,
    required this.enabled,
    required this.items,
    required this.onSelected,
  });

  final String label;
  final String value;
  final bool enabled;
  final List<String> items;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: enabled
              ? () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  final selected = await showModalBottomSheet<String>(
                    context: context,
                    backgroundColor: Colors.white,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    builder: (context) {
                      return SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                style: const TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: uiInk,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Flexible(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      for (final item in items)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: ContentCard(
                                            title: prettifyLabel(item),
                                            subtitle: item == value
                                                ? 'Selected'
                                                : 'Tap to choose this item',
                                            icon: Icons.check_circle_outline,
                                            accentColor:
                                                item == value ? uiMint : uiLilac,
                                            onTap: () {
                                              Navigator.of(context).pop(item);
                                            },
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );

                  if (selected != null) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    onSelected(selected);
                  }
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: uiMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        prettifyLabel(value),
                        style: const TextStyle(
                          color: uiInk,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: uiInk,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
