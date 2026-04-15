import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tcg_card.dart';

// ---------------------------------------------------------------------------
// Provider (manual — no build_runner step needed)
// ---------------------------------------------------------------------------

final pokemonTcgServiceProvider = Provider<PokemonTcgService>(
  (ref) => PokemonTcgService(),
);

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

class PokemonTcgService {
  PokemonTcgService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://api.pokemontcg.io/v2',
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );

  final Dio _dio;

  /// Search cards by name (and/or number / set name) as the user types.
  ///
  /// Uses wildcard matching so partial names like "chariz" match "Charizard".
  /// Pass [pageSize] to control how many suggestions are returned (default 25).
  Future<List<TcgCard>> searchCards(
    String query, {
    int pageSize = 25,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    // Build a combined query: name wildcard + optional number prefix.
    // E.g. "charizard 4" → name:*charizard* number:4*
    final tokens = trimmed.split(RegExp(r'\s+'));
    final parts = <String>[];

    // First token is always the name search
    parts.add('name:*${tokens.first}*');

    // Additional tokens: if purely numeric treat as card number, else set name
    for (var i = 1; i < tokens.length; i++) {
      final t = tokens[i];
      if (RegExp(r'^\d+$').hasMatch(t)) {
        parts.add('number:$t*');
      } else {
        parts.add('set.name:*$t*');
      }
    }

    try {
      final resp = await _dio.get<Map<String, dynamic>>(
        '/cards',
        queryParameters: {
          'q': parts.join(' '),
          'orderBy': 'set.releaseDate',
          'pageSize': pageSize,
          // Only request the fields the UI needs — faster response
          'select': 'id,name,number,rarity,set,images',
        },
      );

      final data = (resp.data?['data'] as List<dynamic>?) ?? [];
      return data
          .map((e) => TcgCard.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (_) {
      // Network / timeout errors: return empty rather than crashing the UI
      return [];
    }
  }
}
