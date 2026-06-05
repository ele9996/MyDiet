import 'dart:collection';

import 'package:flutter/material.dart';

const uiMint = Color(0xFFD3F8E2);
const uiLilac = Color(0xFFE4C1F9);
const uiPink = Color(0xFFF694C1);
const uiButter = Color(0xFFEDE7B1);
const uiSky = Color(0xFFA9DEF9);

const uiInk = Color(0xFF35264F);
const uiMuted = Color(0xFF6D5D89);
const uiBackground = Color(0xFFFFFCFF);

String prettifyLabel(String raw) {
  final withoutIndex = raw.replaceFirst(RegExp(r'^\d+_'), '');
  return withoutIndex
      .replaceAll('_', ' ')
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map(
        (part) => '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
      )
      .join(' ');
}

List<String> orderedDistinct(Iterable<dynamic> values) {
  final distinct = LinkedHashSet<String>();
  for (final value in values) {
    if (value != null) {
      distinct.add(value.toString());
    }
  }
  return distinct.toList();
}

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: child,
    );
  }
}

class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.body,
    this.headerBadge,
    this.scrollStorageKey,
    this.scrollController,
  });

  final String title;
  final String subtitle;
  final Widget body;
  final String? headerBadge;
  final String? scrollStorageKey;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: SafeArea(
        child: CustomScrollView(
          key: PageStorageKey<String>(scrollStorageKey ?? 'page-$title'),
          controller: scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: _PlayfulHeader(
                  title: title,
                  eyebrow: headerBadge,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 120),
              sliver: SliverToBoxAdapter(child: body),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailScaffold extends StatelessWidget {
  const DetailScaffold({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.body,
    this.scrollStorageKey,
    this.scrollController,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget body;
  final String? scrollStorageKey;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: CustomScrollView(
            key: PageStorageKey<String>(
              scrollStorageKey ?? 'detail-$title',
            ),
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => Navigator.of(context).pop(),
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: uiInk,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _PlayfulHeader(
                        title: title,
                        eyebrow: eyebrow,
                        compact: true,
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 36),
                sliver: SliverToBoxAdapter(child: body),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    required this.caption,
  });

  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 56,
            decoration: BoxDecoration(
              color: uiPink,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 12),
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
        ],
      ),
    );
  }
}

class ContentCard extends StatelessWidget {
  const ContentCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.icon,
    this.onTap,
    this.accentColor,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? uiLilac;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white,
        elevation: 0,
        borderRadius: BorderRadius.circular(32),
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: uiInk.withOpacity(0.05),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      icon ?? Icons.arrow_outward_rounded,
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
                          ),
                        ),
                        const SizedBox(height: 8),
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
                  trailing ??
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: uiBackground,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: uiInk,
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InfoPanel extends StatelessWidget {
  const InfoPanel({
    super.key,
    required this.child,
    this.color = Colors.white,
  });

  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(34),
        border: Border.all(
          color: uiInk.withOpacity(0.05),
        ),
      ),
      child: child,
    );
  }
}

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ContentCard(
      title: title,
      subtitle: message,
      icon: icon,
      trailing: const SizedBox.shrink(),
      accentColor: uiButter,
    );
  }
}

class LoadingCard extends StatelessWidget {
  const LoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoPanel(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class CapsuleBadge extends StatelessWidget {
  const CapsuleBadge({
    super.key,
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: uiInk,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class ChoiceChipCard extends StatelessWidget {
  const ChoiceChipCard({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: selected ? uiPink : Colors.white,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : uiInk,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class AccentLabel extends StatelessWidget {
  const AccentLabel({
    super.key,
    required this.text,
    this.color = uiMint,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: uiInk,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PlayfulHeader extends StatelessWidget {
  const _PlayfulHeader({
    required this.title,
    this.eyebrow,
    this.compact = false,
  });

  final String title;
  final String? eyebrow;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            compact ? 18 : 20,
            compact ? 18 : 22,
            compact ? 18 : 20,
            compact ? 18 : 22,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(compact ? 34 : 38),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null && eyebrow!.isNotEmpty) ...[
                CapsuleBadge(
                  text: eyebrow!,
                  color: uiSky,
                ),
                const SizedBox(height: 14),
              ],
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: compact ? 30 : 36,
                  fontWeight: FontWeight.w700,
                  height: 1.02,
                  color: uiInk,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 14,
          right: 18,
          child: Row(
            children: const [
              _Dot(color: uiMint),
              SizedBox(width: 8),
              _Dot(color: uiLilac),
              SizedBox(width: 8),
              _Dot(color: uiPink),
            ],
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
