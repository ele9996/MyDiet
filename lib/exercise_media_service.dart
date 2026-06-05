import 'dart:convert';

import 'package:http/http.dart' as http;

class ExerciseMediaService {
  static List<Map<String, dynamic>>? _cache;

  static const Map<String, String> _directFallbacks = {
    'camminata': 'https://upload.wikimedia.org/wikipedia/commons/d/de/Man_on_a_Treadmill_GIF_Animation_Loop.gif',
    'tapis roulant': 'https://upload.wikimedia.org/wikipedia/commons/d/de/Man_on_a_Treadmill_GIF_Animation_Loop.gif',
    'squat': 'https://upload.wikimedia.org/wikipedia/commons/a/ac/Squat-CDC_strength_training_for_older_adults.gif',
    'esercizi schiena': 'https://upload.wikimedia.org/wikipedia/commons/3/35/800px-RomanChairBackExtension.gif',
    'step macchina': 'https://upload.wikimedia.org/wikipedia/commons/7/72/Step_up-CDC_strength_training_for_older_adults.gif',
    'attività musicale': 'https://upload.wikimedia.org/wikipedia/commons/e/e9/Jumpingjacks.gif',
    'attivita musicale': 'https://upload.wikimedia.org/wikipedia/commons/e/e9/Jumpingjacks.gif',
    'dance': 'https://upload.wikimedia.org/wikipedia/commons/e/e9/Jumpingjacks.gif',
    'attack': 'https://upload.wikimedia.org/wikipedia/commons/6/6a/Highknees_wbs.gif',
  };

  static const Map<String, List<String>> _exerciseAliases = {
    'chest press': ['chest press'],
    'lat machine': ['lat pulldown'],
    'low row': ['seated row'],
    'dist. manubri p. inclinata 30 gradi': ['incline dumbbell press'],
    'alzate laterali manubri': ['dumbbell lateral raise'],
    'curl manubri': ['dumbbell biceps curl'],
    'addominali criss cross': ['criss cross'],
    'addominali crunch inverso': ['reverse crunch'],
    'bench press con manubri': ['dumbbell bench press'],
    'floor press con manubri': ['dumbbell floor press'],
    'kettlebell swing': ['kettlebell swing'],
    'kettlebell rematore o manubri': ['kettlebell row', 'dumbbell row'],
    'kettlebell twister': ['russian twist'],
  };

  Future<String> resolveGifUrl({
    required String exerciseName,
    required String existingUrl,
  }) async {
    if (existingUrl.trim().isNotEmpty) {
      return existingUrl.trim();
    }

    final lowerName = exerciseName.toLowerCase().trim();
    for (final entry in _directFallbacks.entries) {
      if (lowerName.contains(entry.key)) {
        return entry.value;
      }
    }

    final exercises = await _fetchExercises();
    final candidates = _buildCandidates(lowerName);
    for (final candidate in candidates) {
      final best = _findBestMatch(exercises, candidate);
      if (best != null) {
        final gifUrl = (best['gifUrl'] ?? '').toString().trim();
        if (gifUrl.isNotEmpty) {
          return gifUrl;
        }
      }
    }

    return 'https://upload.wikimedia.org/wikipedia/commons/e/e9/Jumpingjacks.gif';
  }

  Future<List<Map<String, dynamic>>> _fetchExercises() async {
    if (_cache != null) {
      return _cache!;
    }

    final uri = Uri.parse('https://oss.exercisedb.dev/api/v1/exercises');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      return _cache = <Map<String, dynamic>>[];
    }

    final data = jsonDecode(response.body);
    if (data is List) {
      _cache = data.cast<Map<String, dynamic>>();
    } else if (data is Map<String, dynamic> && data['data'] is List) {
      _cache = (data['data'] as List).cast<Map<String, dynamic>>();
    } else {
      _cache = <Map<String, dynamic>>[];
    }

    return _cache!;
  }

  List<String> _buildCandidates(String exerciseName) {
    final candidates = <String>[exerciseName];
    for (final entry in _exerciseAliases.entries) {
      if (exerciseName.contains(entry.key)) {
        candidates.addAll(entry.value);
      }
    }

    candidates.add(
      exerciseName
          .replaceAll('manubri', 'dumbbell')
          .replaceAll('rematore', 'row')
          .replaceAll('alzate laterali', 'lateral raise')
          .replaceAll('crunch inverso', 'reverse crunch')
          .replaceAll('addominali', '')
          .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim(),
    );

    return candidates.where((candidate) => candidate.isNotEmpty).toList();
  }

  Map<String, dynamic>? _findBestMatch(
    List<Map<String, dynamic>> exercises,
    String candidate,
  ) {
    Map<String, dynamic>? best;
    var bestScore = 0;
    final candidateTokens = candidate
        .split(' ')
        .where((token) => token.isNotEmpty)
        .toSet();

    for (final exercise in exercises) {
      final name = (exercise['name'] ?? '').toString().toLowerCase();
      if (name.isEmpty) {
        continue;
      }

      if (name == candidate) {
        return exercise;
      }

      var score = 0;
      for (final token in candidateTokens) {
        if (name.contains(token)) {
          score++;
        }
      }

      if (score > bestScore) {
        bestScore = score;
        best = exercise;
      }
    }

    return bestScore >= 1 ? best : null;
  }
}
