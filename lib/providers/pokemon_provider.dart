// lib/providers/pokemon_provider.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class Pokemon {
  final String name;
  final String url;
  final String imageUrl;

  Pokemon({required this.name, required this.url, required this.imageUrl});

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final url = json['url'];
    final id = url.split('/')[url.split('/').length - 2];
    final imageUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';

    return Pokemon(name: name, url: url, imageUrl: imageUrl);
  }
}

class PokemonProvider extends ChangeNotifier {
  final Dio _dio = Dio();

  List<Pokemon> _pokemons = [];
  List<Pokemon> get pokemons => _pokemons;

  int _offset = 0;
  final int _limit = 20;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _filterType = 'all';
  String get filterType => _filterType;

  String? _error;
  String? get error => _error;

  // Initialize or reset and fetch
  Future<void> fetchPokemons() async {
    _offset = 0;
    _pokemons = [];
    await _fetch();
  }

  // Fetch more for infinite scroll
  Future<void> fetchMorePokemons() async {
    if (_isLoading) return;
    _offset += _limit;
    await _fetch();
  }

  // Update search query and fetch
  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    fetchPokemons();
  }

  // Update filter type and fetch
  void setFilter(String type) {
    _filterType = type.toLowerCase();
    fetchPokemons();
  }

  // Internal fetch handler
  Future<void> _fetch() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_filterType == 'all') {
        // Fetch paginated Pokémon list
        final response = await _dio.get(
          'https://pokeapi.co/api/v2/pokemon',
          queryParameters: {'offset': _offset, 'limit': _limit},
        );

        final results = response.data['results'] as List;

        List<Pokemon> loaded = results
            .map((json) => Pokemon.fromJson(json))
            .where((poke) => poke.name.contains(_searchQuery))
            .toList();

        if (_offset == 0) {
          _pokemons = loaded;
        } else {
          _pokemons.addAll(loaded);
        }
      } else {
        // Fetch Pokémon by type
        final response = await _dio
            .get('https://pokeapi.co/api/v2/type/$_filterType');

        final pokemonList = response.data['pokemon'] as List;

        List<Pokemon> loaded = pokemonList
            .map((pokeJson) => Pokemon.fromJson(pokeJson['pokemon']))
            .where((poke) => poke.name.contains(_searchQuery))
            .toList();

        // Manual pagination on filtered list
        final start = _offset;
        final end = _offset + _limit;
        final sliced = loaded.sublist(
            start, end > loaded.length ? loaded.length : end);

        if (_offset == 0) {
          _pokemons = sliced;
        } else {
          _pokemons.addAll(sliced);
        }
      }
    } catch (e) {
      _error = 'Failed to load Pokémon. Please try again.';
      print('Error fetching pokemons: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
