class GialloZafferanoQuery {
  const GialloZafferanoQuery({
    required this.queryText,
    required this.url,
  });

  final String queryText;
  final String url;
}

class GialloZafferanoService {
  GialloZafferanoQuery buildQuery({
    required List<String> ingredients,
  }) {
    final cleanedIngredients = ingredients
        .map(_clean)
        .where((item) => item.isNotEmpty)
        .toList();
    final queryText = cleanedIngredients.join(', ');
    final slug = cleanedIngredients.join(' ');

    return GialloZafferanoQuery(
      queryText: queryText,
      url:
          'https://www.giallozafferano.it/ricerca-ricette/${Uri.encodeComponent(slug).replaceAll('%20', '%2B')}/',
    );
  }

  String _clean(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'\(.*?\)'), '')
        .replaceAll('/', ' ')
        .replaceAll('_', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
