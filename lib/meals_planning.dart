import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:untitled/app_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class MealsPlanning extends StatefulWidget {
  const MealsPlanning({super.key});

  @override
  State<MealsPlanning> createState() => _MealsPlanningState();
}

class _MealsPlanningState extends State<MealsPlanning> {
  DateTime _selectedDate = _normalizeDate(DateTime.now());
  bool _weekSectionExpanded = true;
  bool _grocerySectionExpanded = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _preserveMainScrollWhile(VoidCallback change) {
    final previousOffset =
        _scrollController.hasClients ? _scrollController.offset : 0.0;

    setState(change);
    _restoreMainScrollPosition(previousOffset);
  }

  void _restoreMainScrollPosition(double previousOffset) {
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
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Meals Planning',
      subtitle: '',
      scrollStorageKey: 'meals-planning',
      scrollController: _scrollController,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Diet')
            .orderBy('giorno')
            .snapshots(),
        builder: (context, dietSnapshot) {
          if (dietSnapshot.connectionState == ConnectionState.waiting) {
            return const LoadingCard();
          }

          if (!dietSnapshot.hasData || dietSnapshot.data!.docs.isEmpty) {
            return const EmptyStateCard(
              title: 'No meal catalog yet',
              message:
                  'Add data to the Diet collection before creating meal plans.',
              icon: Icons.edit_calendar_outlined,
            );
          }

          final catalog = MealTemplateCatalog.fromDocs(dietSnapshot.data!.docs);

          return StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('meal_plans').snapshots(),
            builder: (context, planSnapshot) {
              if (planSnapshot.connectionState == ConnectionState.waiting) {
                return const LoadingCard();
              }

              final savedPlans = <String, MealPlanEntry>{};
              if (planSnapshot.hasData) {
                for (final doc in planSnapshot.data!.docs) {
                  savedPlans[doc.id] = MealPlanEntry.fromDoc(doc);
                }
              }

              final selectedDayKey = catalog.dayKeyForDate(_selectedDate);
              if (selectedDayKey == null) {
                return const EmptyStateCard(
                  title: 'No day templates found',
                  message:
                      'The Diet collection needs at least one configured day.',
                  icon: Icons.event_busy_outlined,
                );
              }

              final weekDates = _weekDatesFor(_selectedDate);
              final weeklyPlans = _plansForWeek(
                weekDates: weekDates,
                savedPlans: savedPlans,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FoldableSection(
                    title: 'Grocery Tools',
                    caption:
                        'Build a grocery list for one meal, one day, this week, or any custom set of saved meals.',
                    expanded: _grocerySectionExpanded,
                    onToggle: () {
                      setState(() {
                        _grocerySectionExpanded = !_grocerySectionExpanded;
                      });
                    },
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _ActionPill(
                          label: 'Whole day',
                          icon: Icons.today_outlined,
                          onTap: () {
                            _openDaySelectionSheet(
                              context: context,
                              weekDates: weekDates,
                              catalog: catalog,
                              savedPlans: savedPlans,
                              fallbackDayKey: selectedDayKey,
                            );
                          },
                        ),
                        _ActionPill(
                          label: 'Whole week',
                          icon: Icons.date_range_outlined,
                          onTap: () {
                            _showGroceriesForSelections(
                              context: context,
                              title:
                                  'Groceries for ${_formatWeek(_selectedDate)}',
                              selections: weeklyPlans,
                              catalog: catalog,
                            );
                          },
                        ),
                        _ActionPill(
                          label: 'Custom set',
                          icon: Icons.checklist_rtl_outlined,
                          onTap: () {
                            _openCustomSelectionSheet(
                              context: context,
                              catalog: catalog,
                              savedPlans: savedPlans,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _FoldableSection(
                    title: 'This Week',
                    caption:
                        'You only see one week at a time. Use the arrows to move back and forward.',
                    expanded: _weekSectionExpanded,
                    onToggle: () {
                      setState(() {
                        _weekSectionExpanded = !_weekSectionExpanded;
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _WeekNavigator(
                          selectedDate: _selectedDate,
                          onPreviousWeek: () {
                            setState(() {
                              _selectedDate = _selectedDate.subtract(
                                const Duration(days: 7),
                              );
                            });
                          },
                          onNextWeek: () {
                            setState(() {
                              _selectedDate = _selectedDate.add(
                                const Duration(days: 7),
                              );
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        _ActionPill(
                          label: 'Clear week',
                          icon: Icons.delete_forever_outlined,
                          onTap: () async {
                            await _clearWholeWeek(
                              weekDates: weekDates,
                              catalog: catalog,
                              savedPlans: savedPlans,
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        for (final date in weekDates)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _WeekDayCard(
                              date: date,
                              templateDay:
                                  catalog.dayKeyForDate(date) ?? selectedDayKey,
                              plans: _daySelectionsForDate(
                                date: date,
                                catalog: catalog,
                                savedPlans: savedPlans,
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedDate = date;
                                });
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => DayMealSelectionScreen(
                                      initialDate: date,
                                      catalog: catalog,
                                      initialSavedPlans: savedPlans,
                                    ),
                                  ),
                                );
                              },
                              onClearDay: () async {
                                await _clearWholeDay(
                                  date: date,
                                  catalog: catalog,
                                  savedPlans: savedPlans,
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  MealPlanEntry _effectivePlanForMeal({
    required DateTime date,
    required String templateDay,
    required MealTemplate template,
    required Map<String, MealPlanEntry> savedPlans,
  }) {
    return _effectivePlanForMealStatic(
      date: date,
      templateDay: templateDay,
      template: template,
      savedPlans: savedPlans,
    );
  }

  List<PlannedMealSelection> _buildCurrentDaySelections({
    required DateTime selectedDate,
    required String templateDay,
    required List<MealTemplate> mealTemplates,
    required Map<String, MealPlanEntry> savedPlans,
  }) {
    final selections = <PlannedMealSelection>[];
    for (final mealTemplate in mealTemplates) {
      selections.add(
        PlannedMealSelection(
          date: selectedDate,
          plan: _effectivePlanForMeal(
            date: selectedDate,
            templateDay: templateDay,
            template: mealTemplate,
            savedPlans: savedPlans,
          ),
          expectedCategoryCount: mealTemplate.categories.length,
        ),
      );
    }
    return selections;
  }

  List<PlannedMealSelection> _plansForWeek({
    required List<DateTime> weekDates,
    required Map<String, MealPlanEntry> savedPlans,
  }) {
    final allowedKeys = weekDates.map(_dateKey).toSet();
    final result = <PlannedMealSelection>[];

    for (final plan in savedPlans.values) {
      final date = _parseDateKey(plan.dateKey);
      if (date == null || !allowedKeys.contains(plan.dateKey)) {
        continue;
      }

      result.add(
        PlannedMealSelection(
          date: date,
          plan: plan,
          expectedCategoryCount: plan.selectedItems.length,
        ),
      );
    }

    result.sort((a, b) {
      final byDate = a.plan.dateKey.compareTo(b.plan.dateKey);
      if (byDate != 0) {
        return byDate;
      }
      return MealTemplateCatalog.compareMeals(a.plan.meal, b.plan.meal);
    });
    return result;
  }

  List<PlannedMealSelection> _daySelectionsForDate({
    required DateTime date,
    required MealTemplateCatalog catalog,
    required Map<String, MealPlanEntry> savedPlans,
  }) {
    final templateDay = catalog.dayKeyForDate(date);
    if (templateDay == null) {
      return const <PlannedMealSelection>[];
    }

    return _buildCurrentDaySelections(
      selectedDate: date,
      templateDay: templateDay,
      mealTemplates: catalog.mealsForDay(templateDay),
      savedPlans: savedPlans,
    );
  }

  Future<void> _clearWholeDay({
    required DateTime date,
    required MealTemplateCatalog catalog,
    required Map<String, MealPlanEntry> savedPlans,
  }) async {
    final previousOffset =
        _scrollController.hasClients ? _scrollController.offset : 0.0;
    final templateDay = catalog.dayKeyForDate(date);
    if (templateDay == null) {
      return;
    }

    final mealTemplates = catalog.mealsForDay(templateDay);
    final clearedPlans = <MealPlanEntry>[];
    for (final mealTemplate in mealTemplates) {
      clearedPlans.add(
        _effectivePlanForMeal(
          date: date,
          templateDay: templateDay,
          template: mealTemplate,
          savedPlans: savedPlans,
        ).copyWith(
          eatingOut: false,
          boyfriendAtHome: false,
          selectedItems: <String, String>{},
        ),
      );
    }

    _preserveMainScrollWhile(() {
      for (final plan in clearedPlans) {
        savedPlans[plan.id] = plan;
      }
    });

    for (final plan in clearedPlans) {
      await FirebaseFirestore.instance
          .collection('meal_plans')
          .doc(plan.id)
          .set(plan.toMap(), SetOptions(merge: true));
    }

    if (mounted) {
      _restoreMainScrollPosition(previousOffset);
    }
  }

  Future<void> _clearWholeWeek({
    required List<DateTime> weekDates,
    required MealTemplateCatalog catalog,
    required Map<String, MealPlanEntry> savedPlans,
  }) async {
    final previousOffset =
        _scrollController.hasClients ? _scrollController.offset : 0.0;
    final clearedPlans = <MealPlanEntry>[];

    for (final date in weekDates) {
      final templateDay = catalog.dayKeyForDate(date);
      if (templateDay == null) {
        continue;
      }

      final mealTemplates = catalog.mealsForDay(templateDay);
      for (final mealTemplate in mealTemplates) {
        clearedPlans.add(
          _effectivePlanForMeal(
            date: date,
            templateDay: templateDay,
            template: mealTemplate,
            savedPlans: savedPlans,
          ).copyWith(
            eatingOut: false,
            boyfriendAtHome: false,
            selectedItems: <String, String>{},
          ),
        );
      }
    }

    _preserveMainScrollWhile(() {
      for (final plan in clearedPlans) {
        savedPlans[plan.id] = plan;
      }
    });

    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();
    for (final plan in clearedPlans) {
      batch.set(
        firestore.collection('meal_plans').doc(plan.id),
        plan.toMap(),
        SetOptions(merge: true),
      );
    }
    await batch.commit();

    if (mounted) {
      _restoreMainScrollPosition(previousOffset);
    }
  }

  void _openDaySelectionSheet({
    required BuildContext context,
    required List<DateTime> weekDates,
    required MealTemplateCatalog catalog,
    required Map<String, MealPlanEntry> savedPlans,
    required String fallbackDayKey,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose a day',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: uiInk,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Build the grocery list for one full day from the visible week.',
                  style: TextStyle(
                    color: uiMuted,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (final date in weekDates)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _SelectableMealCard(
                              title: _formatDate(date),
                              subtitle: _daySummaryLabel(
                                selections: _daySelectionsForDate(
                                  date: date,
                                  catalog: catalog,
                                  savedPlans: savedPlans,
                                ),
                              ),
                              selected: _isSameDate(date, _selectedDate),
                              onTap: () {
                                final templateDay =
                                    catalog.dayKeyForDate(date) ??
                                        fallbackDayKey;
                                Navigator.of(context).pop();
                                _showGroceriesForSelections(
                                  context: this.context,
                                  title: 'Groceries for ${_formatDate(date)}',
                                  selections: _buildCurrentDaySelections(
                                    selectedDate: date,
                                    templateDay: templateDay,
                                    mealTemplates:
                                        catalog.mealsForDay(templateDay),
                                    savedPlans: savedPlans,
                                  ),
                                  catalog: catalog,
                                );
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
  }

  String _daySummaryLabel({
    required List<PlannedMealSelection> selections,
  }) {
    final eatingOutCount =
        selections.where((item) => item.plan.eatingOut).length;
    final plannedCount = selections
        .where(
          (item) =>
              !item.plan.eatingOut &&
              item.plan.selectedItems.values.any(
                (value) => value.trim().isNotEmpty,
              ),
        )
        .length;
    final emptyCount = selections.length - eatingOutCount - plannedCount;

    final parts = <String>[];
    if (plannedCount > 0) {
      parts.add('$plannedCount planned');
    }
    if (eatingOutCount > 0) {
      parts.add('$eatingOutCount eating out');
    }
    if (emptyCount > 0) {
      parts.add('$emptyCount no selection');
    }
    return parts.isEmpty ? 'No meals yet' : parts.join(' • ');
  }

  void _openCustomSelectionSheet({
    required BuildContext context,
    required MealTemplateCatalog catalog,
    required Map<String, MealPlanEntry> savedPlans,
  }) {
    final selections = <PlannedMealSelection>[];
    for (final plan in savedPlans.values) {
      final date = _parseDateKey(plan.dateKey);
      if (date != null) {
        selections.add(
          PlannedMealSelection(
            date: date,
            plan: plan,
            expectedCategoryCount: plan.selectedItems.length,
          ),
        );
      }
    }
    selections.sort((a, b) {
      final byDate = a.plan.dateKey.compareTo(b.plan.dateKey);
      if (byDate != 0) {
        return byDate;
      }
      return MealTemplateCatalog.compareMeals(a.plan.meal, b.plan.meal);
    });

    if (selections.isEmpty) {
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        builder: (context) {
          return const SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(18, 18, 18, 24),
              child: EmptyStateCard(
                title: 'No saved meals yet',
                message:
                    'Save at least one planned meal before building a custom grocery list.',
                icon: Icons.bookmark_border_outlined,
              ),
            ),
          );
        },
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final selectedIds = selections.map((item) => item.plan.id).toSet();

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Choose saved meals',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: uiInk,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Select any combination of planned days and meals to build one combined grocery list.',
                      style: TextStyle(
                        color: uiMuted,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            for (final selection in selections)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _SelectableMealCard(
                                  title:
                                      '${_formatDate(selection.date)} - ${prettifyLabel(selection.plan.meal)}',
                                  subtitle: selection.plan.eatingOut
                                      ? 'Eating out'
                                      : selection.plan.boyfriendAtHome
                                          ? 'Boyfriend at home'
                                          : 'Home meal',
                                  selected:
                                      selectedIds.contains(selection.plan.id),
                                  onTap: () {
                                    setModalState(() {
                                      if (selectedIds
                                          .contains(selection.plan.id)) {
                                        selectedIds.remove(selection.plan.id);
                                      } else {
                                        selectedIds.add(selection.plan.id);
                                      }
                                    });
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: selectedIds.isEmpty
                            ? null
                            : () {
                                Navigator.of(context).pop();
                                _showGroceriesForSelections(
                                  context: this.context,
                                  title: 'Custom grocery list',
                                  selections: selections
                                      .where(
                                        (item) =>
                                            selectedIds.contains(item.plan.id),
                                      )
                                      .toList(),
                                  catalog: catalog,
                                );
                              },
                        style: FilledButton.styleFrom(
                          backgroundColor: uiPink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: const Text(
                          'Build grocery list',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showGroceriesForSelections({
    required BuildContext context,
    required String title,
    required List<PlannedMealSelection> selections,
    required MealTemplateCatalog catalog,
  }) {
    _showGroceriesBottomSheet(
      context: context,
      title: title,
      selections: selections,
      catalog: catalog,
    );
  }
}

class _FoldableSection extends StatelessWidget {
  const _FoldableSection({
    required this.title,
    required this.caption,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  final String title;
  final String caption;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InfoPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: uiInk,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          caption,
                          style: const TextStyle(
                            color: uiMuted,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: uiBackground,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: uiInk,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState:
                expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: child,
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _WeekNavigator extends StatelessWidget {
  const _WeekNavigator({
    required this.selectedDate,
    required this.onPreviousWeek,
    required this.onNextWeek,
  });

  final DateTime selectedDate;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconActionButton(
          icon: Icons.arrow_back_rounded,
          label: 'Previous',
          onTap: onPreviousWeek,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _formatWeek(selectedDate),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: uiInk,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tap a day card to edit that day.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: uiMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _IconActionButton(
          icon: Icons.arrow_forward_rounded,
          label: 'Next',
          onTap: onNextWeek,
        ),
      ],
    );
  }
}

class _SelectedDayHeader extends StatelessWidget {
  const _SelectedDayHeader({
    required this.date,
    required this.templateDay,
    required this.mealCount,
    required this.onPreviousDay,
    required this.onNextDay,
  });

  final DateTime date;
  final String templateDay;
  final int mealCount;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: uiBackground,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconActionButton(
                icon: Icons.chevron_left_rounded,
                label: 'Back',
                onTap: onPreviousDay,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      _formatDate(date),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: uiInk,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Template ${prettifyLabel(templateDay)} - $mealCount meals',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: uiMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _IconActionButton(
                icon: Icons.chevron_right_rounded,
                label: 'Next',
                onTap: onNextDay,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekDayCard extends StatelessWidget {
  const _WeekDayCard({
    required this.date,
    required this.templateDay,
    required this.plans,
    required this.onTap,
    required this.onClearDay,
  });

  final DateTime date;
  final String templateDay;
  final List<PlannedMealSelection> plans;
  final VoidCallback onTap;
  final VoidCallback onClearDay;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: _colorWithOpacity(uiInk, 0.05),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatShortDate(date),
                            style: const TextStyle(
                              color: uiInk,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            prettifyLabel(templateDay),
                            style: const TextStyle(
                              color: uiMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final plan in plans) _MealSummaryChip(plan: plan),
                  ],
                ),
                const SizedBox(height: 12),
                _ActionPill(
                  label: 'Clear day',
                  icon: Icons.delete_sweep_outlined,
                  onTap: onClearDay,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MealSummaryChip extends StatelessWidget {
  const _MealSummaryChip({
    required this.plan,
  });

  final PlannedMealSelection plan;

  @override
  Widget build(BuildContext context) {
    final itemCount = plan.plan.selectedItems.values
        .where((item) => item.trim().isNotEmpty)
        .length;
    final isComplete = !plan.plan.eatingOut &&
        plan.expectedCategoryCount > 0 &&
        itemCount == plan.expectedCategoryCount;
    final text = plan.plan.eatingOut
        ? 'Eating out'
        : plan.plan.boyfriendAtHome
            ? 'Boyfriend at home'
            : isComplete
                ? 'Ready'
                : itemCount == 0
                    ? 'No selection'
                    : 'Incomplete';
    final backgroundColor = plan.plan.eatingOut
        ? uiButter
        : plan.plan.boyfriendAtHome
            ? uiPink
            : isComplete
                ? uiMint
                : _colorWithOpacity(uiMuted, 0.18);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            prettifyLabel(plan.plan.meal),
            style: const TextStyle(
              color: uiInk,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            text,
            style: const TextStyle(
              color: uiMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class DayMealSelectionScreen extends StatefulWidget {
  const DayMealSelectionScreen({
    super.key,
    required this.initialDate,
    required this.catalog,
    required this.initialSavedPlans,
  });

  final DateTime initialDate;
  final MealTemplateCatalog catalog;
  final Map<String, MealPlanEntry> initialSavedPlans;

  @override
  State<DayMealSelectionScreen> createState() => _DayMealSelectionScreenState();
}

class _DayMealSelectionScreenState extends State<DayMealSelectionScreen> {
  late DateTime _selectedDate;
  late Map<String, MealPlanEntry> _savedPlans;
  final Set<String> _expandedMeals = <String>{};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedDate = _normalizeDate(widget.initialDate);
    _savedPlans = Map<String, MealPlanEntry>.from(widget.initialSavedPlans);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _preserveScrollWhile(VoidCallback change) {
    final previousOffset =
        _scrollController.hasClients ? _scrollController.offset : 0.0;

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
  }

  void _restoreScrollPosition(double previousOffset) {
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
  }

  @override
  Widget build(BuildContext context) {
    final templateDay = widget.catalog.dayKeyForDate(_selectedDate);
    if (templateDay == null) {
      return const Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(18),
            child: EmptyStateCard(
              title: 'No day template found',
              message: 'This date does not map to any configured meal day.',
              icon: Icons.event_busy_outlined,
            ),
          ),
        ),
      );
    }

    final mealTemplates = widget.catalog.mealsForDay(templateDay);

    return DetailScaffold(
      eyebrow: 'Item selection',
      title: 'Plan your day',
      subtitle: '',
      scrollStorageKey: 'day-plan-${_dateKey(_selectedDate)}',
      scrollController: _scrollController,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SelectedDayHeader(
            date: _selectedDate,
            templateDay: templateDay,
            mealCount: mealTemplates.length,
            onPreviousDay: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                _expandedMeals.clear();
              });
            },
            onNextDay: () {
              setState(() {
                _selectedDate = _selectedDate.add(const Duration(days: 1));
                _expandedMeals.clear();
              });
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ActionPill(
                label: 'Clear day',
                icon: Icons.delete_sweep_outlined,
                onTap: () async {
                  final previousOffset = _scrollController.hasClients
                      ? _scrollController.offset
                      : 0.0;
                  final clearedPlans = <MealPlanEntry>[];
                  for (final mealTemplate in mealTemplates) {
                    clearedPlans.add(
                      _effectivePlanForMealStatic(
                        date: _selectedDate,
                        templateDay: templateDay,
                        template: mealTemplate,
                        savedPlans: _savedPlans,
                      ).copyWith(
                        eatingOut: false,
                        boyfriendAtHome: false,
                        selectedItems: <String, String>{},
                      ),
                    );
                  }

                  _preserveScrollWhile(() {
                    for (final plan in clearedPlans) {
                      _savedPlans[plan.id] = plan;
                    }
                  });

                  for (final plan in clearedPlans) {
                    await FirebaseFirestore.instance
                        .collection('meal_plans')
                        .doc(plan.id)
                        .set(plan.toMap(), SetOptions(merge: true));
                  }

                  if (mounted) {
                    _restoreScrollPosition(previousOffset);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final mealTemplate in mealTemplates)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MealPlanCard(
                date: _selectedDate,
                templateDay: templateDay,
                template: mealTemplate,
                plan: _effectivePlanForMealStatic(
                  date: _selectedDate,
                  templateDay: templateDay,
                  template: mealTemplate,
                  savedPlans: _savedPlans,
                ),
                expanded: _expandedMeals.contains(mealTemplate.meal),
                onToggleExpanded: () {
                  setState(() {
                    if (_expandedMeals.contains(mealTemplate.meal)) {
                      _expandedMeals.remove(mealTemplate.meal);
                    } else {
                      _expandedMeals.add(mealTemplate.meal);
                    }
                  });
                },
                onPlanChanged: (plan) async {
                  setState(() {
                    _savedPlans[plan.id] = plan;
                  });
                  await FirebaseFirestore.instance
                      .collection('meal_plans')
                      .doc(plan.id)
                      .set(plan.toMap(), SetOptions(merge: true));
                },
                onClearMeal: () async {
                  final clearedPlan = _effectivePlanForMealStatic(
                    date: _selectedDate,
                    templateDay: templateDay,
                    template: mealTemplate,
                    savedPlans: _savedPlans,
                  ).copyWith(
                    eatingOut: false,
                    boyfriendAtHome: false,
                    selectedItems: <String, String>{},
                  );

                  setState(() {
                    _savedPlans[clearedPlan.id] = clearedPlan;
                  });

                  await FirebaseFirestore.instance
                      .collection('meal_plans')
                      .doc(clearedPlan.id)
                      .set(clearedPlan.toMap(), SetOptions(merge: true));
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _MealPlanCard extends StatelessWidget {
  const _MealPlanCard({
    required this.date,
    required this.templateDay,
    required this.template,
    required this.plan,
    required this.expanded,
    required this.onToggleExpanded,
    required this.onPlanChanged,
    required this.onClearMeal,
  });

  final DateTime date;
  final String templateDay;
  final MealTemplate template;
  final MealPlanEntry plan;
  final bool expanded;
  final VoidCallback onToggleExpanded;
  final ValueChanged<MealPlanEntry> onPlanChanged;
  final VoidCallback onClearMeal;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onToggleExpanded,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: _colorWithOpacity(uiInk, 0.05),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prettifyLabel(template.meal),
                            style: const TextStyle(
                              color: uiInk,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            plan.eatingOut
                                ? 'Eating out is on, so food selections are paused for this meal.'
                                : _mealSelectionSummary(plan),
                            style: const TextStyle(
                              color: uiMuted,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: uiBackground,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: uiInk,
                      ),
                    ),
                  ],
                ),
                if (expanded) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChipCard(
                        label: 'Boyfriend at home',
                        selected: plan.boyfriendAtHome,
                        onTap: () {
                          onPlanChanged(
                            plan.copyWith(
                              boyfriendAtHome: !plan.boyfriendAtHome,
                            ),
                          );
                        },
                      ),
                      ChoiceChipCard(
                        label: 'Eating out',
                        selected: plan.eatingOut,
                        onTap: () {
                          onPlanChanged(
                            plan.copyWith(
                              eatingOut: !plan.eatingOut,
                            ),
                          );
                        },
                      ),
                      _ActionPill(
                        label: 'Clear meal',
                        icon: Icons.remove_circle_outline,
                        onTap: onClearMeal,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (final category in template.categories) ...[
                    _PlannerPicker(
                      category: category,
                      value: plan.selectedItems[category] ?? '',
                      enabled: !plan.eatingOut,
                      options: template.optionsForCategory(category),
                      onSelected: (value) {
                        final updatedSelections = Map<String, String>.from(
                          plan.selectedItems,
                        );
                        updatedSelections[category] = value;
                        onPlanChanged(
                          plan.copyWith(
                            selectedItems: updatedSelections,
                            templateDay: templateDay,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (plan.boyfriendAtHome && !plan.eatingOut)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: uiMint,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Quantities from this meal will be counted twice in the grocery list.',
                        style: TextStyle(
                          color: uiInk,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                    ),
                  if (!plan.eatingOut)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (plan.selectedItems.entries
                              .where((entry) => entry.value.trim().isNotEmpty)
                              .isEmpty)
                            const AccentLabel(
                              text: 'No selection yet',
                              color: uiButter,
                            ),
                          for (final entry in plan.selectedItems.entries)
                            if (entry.value.trim().isNotEmpty)
                              AccentLabel(
                                text:
                                    '${prettifyLabel(entry.key)}: ${prettifyLabel(entry.value)}',
                                color: uiLilac,
                              ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _mealSelectionSummary(MealPlanEntry plan) {
    final selected = plan.selectedItems.values
        .where((item) => item.trim().isNotEmpty)
        .map(prettifyLabel)
        .toList();

    if (selected.isEmpty) {
      return 'No food selected yet.';
    }

    final preview = selected.take(2).join(', ');
    if (selected.length <= 2) {
      return plan.boyfriendAtHome
          ? '$preview. Double portions for boyfriend at home.'
          : preview;
    }
    final rest = selected.length - 2;
    final extraText = rest == 1 ? '1 more' : '$rest more';
    return plan.boyfriendAtHome
        ? '$preview, $extraText. Double portions for boyfriend at home.'
        : '$preview, $extraText.';
  }
}

class _PlannerPicker extends StatelessWidget {
  const _PlannerPicker({
    required this.category,
    required this.value,
    required this.enabled,
    required this.options,
    required this.onSelected,
  });

  final String category;
  final String value;
  final bool enabled;
  final List<MealOption> options;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final selectedOption = options.where((item) => item.name == value).toList();
    final selected = selectedOption.isNotEmpty ? selectedOption.first : null;

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: enabled
              ? () async {
                  final chosen = await showModalBottomSheet<String>(
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
                                prettifyLabel(category),
                                style: const TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: uiInk,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Choose the item you want to plan for this category.',
                                style: TextStyle(
                                  color: uiMuted,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Flexible(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      for (final option in options)
                                        ContentCard(
                                          title: prettifyLabel(option.name),
                                          subtitle: option.quantity,
                                          icon: Icons.restaurant_outlined,
                                          accentColor: option.name == value
                                              ? uiMint
                                              : uiLilac,
                                          onTap: () {
                                            Navigator.of(context)
                                                .pop(option.name);
                                          },
                                        ),
                                      ContentCard(
                                        title: 'No selection',
                                        subtitle:
                                            'Clear the current choice for this category.',
                                        icon: Icons.remove_circle_outline,
                                        accentColor: uiButter,
                                        onTap: () {
                                          Navigator.of(context).pop('');
                                        },
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

                  if (chosen != null) {
                    onSelected(chosen);
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
                        prettifyLabel(category),
                        style: const TextStyle(
                          color: uiMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        selected == null
                            ? 'No item selected'
                            : prettifyLabel(selected.name),
                        style: const TextStyle(
                          color: uiInk,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (selected != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          selected.quantity,
                          style: const TextStyle(
                            color: uiMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
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

class _SelectableMealCard extends StatelessWidget {
  const _SelectableMealCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: selected ? uiBackground : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: selected ? uiPink : _colorWithOpacity(uiInk, 0.06),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: uiInk,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: uiMuted,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? uiPink : uiMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: uiInk, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: uiInk,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  const _IconActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: uiInk, size: 20),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: uiInk,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MealTemplateCatalog {
  MealTemplateCatalog({
    required this.dayOrder,
    required this.templatesByDay,
  });

  final List<String> dayOrder;
  final Map<String, List<MealTemplate>> templatesByDay;

  static const List<String> _mealOrder = [
    '0_Colazione',
    '1_Pranzo',
    '2_Merenda',
    '3_Cena',
    '4_Arco_Della_Giornata',
  ];

  factory MealTemplateCatalog.fromDocs(List<QueryDocumentSnapshot> docs) {
    final dayOrder = orderedDistinct(
      docs.map((doc) => doc['giorno']),
    );
    final byDay = <String,
        LinkedHashMap<String, LinkedHashMap<String, List<MealOption>>>>{};

    for (final doc in docs) {
      final day = doc['giorno'].toString();
      final meal = doc['pasto'].toString();
      final category = doc['tipo'].toString();
      final item = doc['alimento'].toString();
      final quantity = doc['quantita'].toString();

      byDay.putIfAbsent(
        day,
        () => LinkedHashMap<String, LinkedHashMap<String, List<MealOption>>>(),
      );
      byDay[day]!.putIfAbsent(
        meal,
        () => LinkedHashMap<String, List<MealOption>>(),
      );
      byDay[day]![meal]!.putIfAbsent(category, () => <MealOption>[]);

      final options = byDay[day]![meal]![category]!;
      final alreadyExists = options.any((option) => option.name == item);
      if (!alreadyExists) {
        options.add(MealOption(name: item, quantity: quantity));
      }
    }

    final templatesByDay = <String, List<MealTemplate>>{};
    byDay.forEach((day, meals) {
      final mealTemplates = <MealTemplate>[];
      meals.forEach((meal, categories) {
        mealTemplates.add(
          MealTemplate(
            meal: meal,
            optionsByCategory: categories,
          ),
        );
      });
      mealTemplates.sort((a, b) => compareMeals(a.meal, b.meal));
      templatesByDay[day] = mealTemplates;
    });

    return MealTemplateCatalog(
      dayOrder: dayOrder,
      templatesByDay: templatesByDay,
    );
  }

  String? dayKeyForDate(DateTime date) {
    if (dayOrder.isEmpty) {
      return null;
    }
    final index = (date.weekday - 1) % dayOrder.length;
    return dayOrder[index];
  }

  List<MealTemplate> mealsForDay(String day) {
    return templatesByDay[day] ?? const <MealTemplate>[];
  }

  MealTemplate? mealTemplate({
    required String day,
    required String meal,
  }) {
    final meals = templatesByDay[day];
    if (meals == null) {
      return null;
    }
    for (final template in meals) {
      if (template.meal == meal) {
        return template;
      }
    }
    return null;
  }

  static int compareMeals(String a, String b) {
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
  }
}

class MealTemplate {
  MealTemplate({
    required this.meal,
    required LinkedHashMap<String, List<MealOption>> optionsByCategory,
  }) : _optionsByCategory = optionsByCategory;

  final String meal;
  final LinkedHashMap<String, List<MealOption>> _optionsByCategory;

  List<String> get categories => _optionsByCategory.keys.toList();

  List<MealOption> optionsForCategory(String category) {
    return _optionsByCategory[category] ?? const <MealOption>[];
  }

  MealOption? findOption(String category, String itemName) {
    final items = _optionsByCategory[category];
    if (items == null) {
      return null;
    }
    for (final item in items) {
      if (item.name == itemName) {
        return item;
      }
    }
    return null;
  }
}

class MealOption {
  const MealOption({
    required this.name,
    required this.quantity,
  });

  final String name;
  final String quantity;
}

class MealPlanEntry {
  MealPlanEntry({
    required this.dateKey,
    required this.meal,
    required this.templateDay,
    required this.boyfriendAtHome,
    required this.eatingOut,
    required this.selectedItems,
  });

  final String dateKey;
  final String meal;
  final String templateDay;
  final bool boyfriendAtHome;
  final bool eatingOut;
  final Map<String, String> selectedItems;

  String get id => buildId(dateKey, meal);

  static String buildId(String dateKey, String meal) {
    return '${dateKey}__$meal';
  }

  factory MealPlanEntry.fromDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final selected = <String, String>{};
    final selectedMap = data['selectedItems'];
    if (selectedMap is Map) {
      selectedMap.forEach((key, value) {
        if (key != null && value != null) {
          selected[key.toString()] = value.toString();
        }
      });
    }

    return MealPlanEntry(
      dateKey: data['dateKey']?.toString() ?? '',
      meal: data['meal']?.toString() ?? '',
      templateDay: data['templateDay']?.toString() ?? '',
      boyfriendAtHome: data['boyfriendAtHome'] == true,
      eatingOut: data['eatingOut'] == true,
      selectedItems: selected,
    );
  }

  MealPlanEntry copyWith({
    String? dateKey,
    String? meal,
    String? templateDay,
    bool? boyfriendAtHome,
    bool? eatingOut,
    Map<String, String>? selectedItems,
  }) {
    return MealPlanEntry(
      dateKey: dateKey ?? this.dateKey,
      meal: meal ?? this.meal,
      templateDay: templateDay ?? this.templateDay,
      boyfriendAtHome: boyfriendAtHome ?? this.boyfriendAtHome,
      eatingOut: eatingOut ?? this.eatingOut,
      selectedItems: selectedItems ?? this.selectedItems,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateKey': dateKey,
      'meal': meal,
      'templateDay': templateDay,
      'boyfriendAtHome': boyfriendAtHome,
      'eatingOut': eatingOut,
      'selectedItems': selectedItems,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class PlannedMealSelection {
  const PlannedMealSelection({
    required this.date,
    required this.plan,
    required this.expectedCategoryCount,
  });

  final DateTime date;
  final MealPlanEntry plan;
  final int expectedCategoryCount;
}

class GroceryAggregator {
  static List<GroceryListItem> aggregate({
    required List<PlannedMealSelection> selections,
    required MealTemplateCatalog catalog,
  }) {
    final items = <String, _GroceryBucket>{};

    for (final selection in selections) {
      if (selection.plan.eatingOut) {
        continue;
      }

      final fallbackDay = catalog.dayKeyForDate(selection.date);
      final templateDay = selection.plan.templateDay.isNotEmpty
          ? selection.plan.templateDay
          : fallbackDay;
      if (templateDay == null) {
        continue;
      }

      final template = catalog.mealTemplate(
        day: templateDay,
        meal: selection.plan.meal,
      );
      if (template == null) {
        continue;
      }

      final multiplier = selection.plan.boyfriendAtHome ? 2 : 1;
      for (final category in template.categories) {
        final itemName = selection.plan.selectedItems[category];
        if (itemName == null || itemName.isEmpty) {
          continue;
        }
        final option = template.findOption(category, itemName);
        if (option == null) {
          continue;
        }

        final key = itemName.trim().toLowerCase();
        final bucket = items.putIfAbsent(
          key,
          () => _GroceryBucket(name: itemName),
        );
        bucket.add(
          quantity: option.quantity,
          multiplier: multiplier,
          source:
              '${_formatDate(selection.date)} - ${prettifyLabel(selection.plan.meal)}',
        );
      }
    }

    final result = items.values.map((bucket) => bucket.toItem()).toList();
    result.sort((a, b) => a.name.compareTo(b.name));
    return result;
  }
}

class GroceryListItem {
  const GroceryListItem({
    required this.name,
    required this.totalLabel,
    required this.description,
  });

  final String name;
  final String totalLabel;
  final String description;
}

class _GrocerySheetItem extends StatelessWidget {
  const _GrocerySheetItem({
    required this.item,
  });

  final GroceryListItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _colorWithOpacity(uiInk, 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: uiButter,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.shopping_basket_outlined,
                  color: uiInk,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  prettifyLabel(item.name),
                  style: const TextStyle(
                    color: uiInk,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: uiMint,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              item.totalLabel,
              style: const TextStyle(
                color: uiInk,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.description,
            style: const TextStyle(
              color: uiMuted,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroceryBucket {
  _GroceryBucket({
    required this.name,
  });

  final String name;
  final LinkedHashMap<String, double> _numericTotals =
      LinkedHashMap<String, double>();
  final LinkedHashMap<String, int> _rawTotals = LinkedHashMap<String, int>();
  final List<String> _sources = <String>[];

  void add({
    required String quantity,
    required int multiplier,
    required String source,
  }) {
    _sources.add(source);
    final parsed = _QuantityParser.tryParse(quantity);
    if (parsed != null) {
      final unitKey = parsed.unit.toLowerCase();
      final previous = _numericTotals[unitKey] ?? 0;
      _numericTotals[unitKey] = previous + (parsed.value * multiplier);
      return;
    }

    final normalized = quantity.trim();
    final groupedQuantity = _rawTotals[normalized];
    if (groupedQuantity != null) {
      _rawTotals[normalized] = groupedQuantity + multiplier;
      return;
    }

    final compactMatch = RegExp(r'^\s*(\d+(?:[.,]\d+)?)x(\d+)\s*$')
        .firstMatch(normalized.toLowerCase());
    if (compactMatch != null) {
      final baseValue =
          double.tryParse(compactMatch.group(1)!.replaceAll(',', '.'));
      final embeddedMultiplier = int.tryParse(compactMatch.group(2)!);
      if (baseValue != null && embeddedMultiplier != null) {
        final computed = baseValue * embeddedMultiplier * multiplier;
        _rawTotals[_formatQuantityNumber(computed)] = 1;
        return;
      }
    }

    final spacedMatch = RegExp(r'^\s*(\d+(?:[.,]\d+)?)\s*x\s*(\d+)\s*(.*)$')
        .firstMatch(normalized.toLowerCase());
    if (spacedMatch != null) {
      final baseValue =
          double.tryParse(spacedMatch.group(1)!.replaceAll(',', '.'));
      final embeddedMultiplier = int.tryParse(spacedMatch.group(2)!);
      final unit = (spacedMatch.group(3) ?? '').trim();
      if (baseValue != null && embeddedMultiplier != null) {
        final total = baseValue * embeddedMultiplier * multiplier;
        final key = unit.isEmpty
            ? _formatQuantityNumber(total)
            : '${_formatQuantityNumber(total)} $unit';
        _rawTotals[key] = 1;
        return;
      }
    }

    final previousRaw = _rawTotals[normalized] ?? 0;
    _rawTotals[normalized] = previousRaw + multiplier;
  }

  GroceryListItem toItem() {
    final totals = <String>[];

    _numericTotals.forEach((unit, total) {
      totals.add(_formatNumericTotal(total, unit));
    });

    _rawTotals.forEach((quantity, occurrences) {
      if (occurrences <= 1) {
        totals.add(quantity);
      } else {
        final parsed = _QuantityParser.tryParse(quantity);
        if (parsed != null) {
          final total = parsed.value * occurrences;
          totals.add(
            parsed.unit.isEmpty
                ? _formatQuantityNumber(total)
                : '${_formatQuantityNumber(total)} ${parsed.unit}',
          );
        } else {
          totals.add(quantity);
        }
      }
    });

    return GroceryListItem(
      name: name,
      totalLabel: totals.join(' + '),
      description: _sources.toSet().join(', '),
    );
  }

  String _formatNumericTotal(double total, String unit) {
    final rounded = _formatQuantityNumber(total);
    return unit.isEmpty ? rounded : '$rounded $unit';
  }
}

class _QuantityParser {
  const _QuantityParser({
    required this.value,
    required this.unit,
  });

  final double value;
  final String unit;

  static _QuantityParser? tryParse(String raw) {
    final multipliedMatch = RegExp(
      r'(\d+(?:[.,]\d+)?)\s*x\s*(\d+)\s*(.*)',
      caseSensitive: false,
    ).firstMatch(raw);
    if (multipliedMatch != null) {
      final left = double.tryParse(
        multipliedMatch.group(1)!.replaceAll(',', '.'),
      );
      final right = int.tryParse(multipliedMatch.group(2)!);
      if (left != null && right != null) {
        return _QuantityParser(
          value: left * right,
          unit: (multipliedMatch.group(3) ?? '').trim(),
        );
      }
    }

    final match = RegExp(
      r'^[^\d]*(\d+(?:[.,]\d+)?)\s*(.*)$',
      caseSensitive: false,
    ).firstMatch(raw);
    if (match == null) {
      return null;
    }

    final value = double.tryParse(match.group(1)!.replaceAll(',', '.'));
    if (value == null) {
      return null;
    }

    return _QuantityParser(
      value: value,
      unit: (match.group(2) ?? '').trim(),
    );
  }
}

// ignore: unused_element
List<PlannedMealSelection> _buildCurrentDaySelectionsStatic({
  required DateTime selectedDate,
  required String templateDay,
  required List<MealTemplate> mealTemplates,
  required Map<String, MealPlanEntry> savedPlans,
}) {
  final selections = <PlannedMealSelection>[];
  for (final mealTemplate in mealTemplates) {
    selections.add(
      PlannedMealSelection(
        date: selectedDate,
        plan: _effectivePlanForMealStatic(
          date: selectedDate,
          templateDay: templateDay,
          template: mealTemplate,
          savedPlans: savedPlans,
        ),
        expectedCategoryCount: mealTemplate.categories.length,
      ),
    );
  }
  return selections;
}

// ignore: unused_element
String _daySelectionSummary({
  required List<PlannedMealSelection> selections,
}) {
  final eatingOutCount = selections.where((item) => item.plan.eatingOut).length;
  final plannedCount = selections
      .where(
        (item) =>
            !item.plan.eatingOut &&
            item.plan.selectedItems.values
                .any((value) => value.trim().isNotEmpty),
      )
      .length;
  final emptyCount = selections.length - eatingOutCount - plannedCount;

  final parts = <String>[];
  if (plannedCount > 0) {
    parts.add('$plannedCount planned');
  }
  if (eatingOutCount > 0) {
    parts.add('$eatingOutCount eating out');
  }
  if (emptyCount > 0) {
    parts.add('$emptyCount no selection');
  }
  return parts.isEmpty ? 'No meals yet' : parts.join(' • ');
}

void _showGroceriesBottomSheet({
  required BuildContext context,
  required String title,
  required List<PlannedMealSelection> selections,
  required MealTemplateCatalog catalog,
}) {
  final groceries = GroceryAggregator.aggregate(
    selections: selections,
    catalog: catalog,
  );
  final shareText = _buildGroceryShareText(
    title: title,
    groceries: groceries,
  );

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                title,
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: uiInk,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${selections.length} planned meal${selections.length == 1 ? '' : 's'} included.',
                style: const TextStyle(
                  color: uiMuted,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ActionPill(
                    label: 'Copy TXT',
                    icon: Icons.copy_all_outlined,
                    onTap: () async {
                      await Clipboard.setData(
                        ClipboardData(text: shareText),
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Grocery list copied as text'),
                          ),
                        );
                      }
                    },
                  ),
                  _ActionPill(
                    label: 'WhatsApp',
                    icon: Icons.chat_bubble_outline,
                    onTap: () async {
                      await _launchShareUrl(
                        context: context,
                        uri: Uri.parse(
                          'https://wa.me/?text=${Uri.encodeComponent(shareText)}',
                        ),
                      );
                    },
                  ),
                  _ActionPill(
                    label: 'Telegram',
                    icon: Icons.send_outlined,
                    onTap: () async {
                      await _launchShareUrl(
                        context: context,
                        uri: Uri.parse(
                          'https://t.me/share/url?url=${Uri.encodeComponent('https://mydiet.local/grocery')}&text=${Uri.encodeComponent(shareText)}',
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Flexible(
                child: SingleChildScrollView(
                  child: groceries.isEmpty
                      ? const EmptyStateCard(
                          title: 'Nothing to buy',
                          message:
                              'These meals are marked as eating out or do not contain selected ingredients.',
                          icon: Icons.shopping_cart_checkout_outlined,
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final item in groceries)
                              _GrocerySheetItem(item: item),
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
}

MealPlanEntry _effectivePlanForMealStatic({
  required DateTime date,
  required String templateDay,
  required MealTemplate template,
  required Map<String, MealPlanEntry> savedPlans,
}) {
  final id = MealPlanEntry.buildId(_dateKey(date), template.meal);
  final savedPlan = savedPlans[id];
  final selectedItems = <String, String>{};

  for (final category in template.categories) {
    final selectedItem = savedPlan?.selectedItems[category];
    if (selectedItem != null &&
        template
            .optionsForCategory(category)
            .any((item) => item.name == selectedItem)) {
      selectedItems[category] = selectedItem;
    }
  }

  return MealPlanEntry(
    dateKey: _dateKey(date),
    meal: template.meal,
    templateDay: savedPlan?.templateDay ?? templateDay,
    boyfriendAtHome: savedPlan?.boyfriendAtHome ?? false,
    eatingOut: savedPlan?.eatingOut ?? false,
    selectedItems: selectedItems,
  );
}

DateTime _normalizeDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

DateTime _startOfWeek(DateTime date) {
  final normalized = _normalizeDate(date);
  return normalized.subtract(Duration(days: normalized.weekday - 1));
}

List<DateTime> _weekDatesFor(DateTime date) {
  final start = _startOfWeek(date);
  return List<DateTime>.generate(
    7,
    (index) => start.add(Duration(days: index)),
  );
}

// ignore: unused_element
bool _isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _dateKey(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

DateTime? _parseDateKey(String raw) {
  final parts = raw.split('-');
  if (parts.length != 3) {
    return null;
  }
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (year == null || month == null || day == null) {
    return null;
  }
  return DateTime(year, month, day);
}

String _formatDate(DateTime date) {
  const weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return '${weekdays[date.weekday - 1]} ${date.day} ${months[date.month - 1]} ${date.year}';
}

String _formatShortDate(DateTime date) {
  const weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${weekdays[date.weekday - 1]} ${date.day} ${months[date.month - 1]}';
}

String _formatWeek(DateTime date) {
  final start = _startOfWeek(date);
  final end = start.add(const Duration(days: 6));
  return '${_formatShortDate(start)} - ${_formatShortDate(end)}';
}

Color _colorWithOpacity(Color color, double opacity) {
  // ignore: deprecated_member_use
  return color.withOpacity(opacity);
}

String _formatQuantityNumber(double value) {
  return value == value.roundToDouble()
      ? value.round().toString()
      : value.toStringAsFixed(1);
}

String _buildGroceryShareText({
  required String title,
  required List<GroceryListItem> groceries,
}) {
  if (groceries.isEmpty) {
    return '$title\n\nNothing to buy.';
  }

  final lines = <String>[title, ''];
  for (final item in groceries) {
    lines.add('- ${prettifyLabel(item.name)}: ${item.totalLabel}');
  }
  return lines.join('\n');
}

Future<void> _launchShareUrl({
  required BuildContext context,
  required Uri uri,
}) async {
  final launched = await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  );
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unable to open the sharing app on this device'),
      ),
    );
  }
}
