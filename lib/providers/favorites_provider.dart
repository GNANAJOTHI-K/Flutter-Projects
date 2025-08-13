// lib/providers/favorites_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'auth_provider.dart'; // For user info
import 'pokemon_provider.dart';

class FavoritesProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Pokemon> _favoritePokemons = [];
  List<Pokemon> get favoritePokemons => _favoritePokemons;

  final AuthProvider _authProvider;

  FavoritesProvider(this._authProvider) {
    _loadFavorites();
    _authProvider.addListener(() {
      _loadFavorites();
    });
  }

  Future<void> _loadFavorites() async {
    final user = _authProvider.user;
    if (user == null) {
      _favoritePokemons = [];
      notifyListeners();
      return;
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .get();

    _favoritePokemons = snapshot.docs
        .map((doc) => Pokemon(
              name: doc.id,
              url: '',
              imageUrl: doc['imageUrl'],
            ))
        .toList();

    notifyListeners();
  }

  bool isFavorite(String name) {
    return _favoritePokemons.any((poke) => poke.name == name);
  }

  Future<void> addFavorite(Pokemon pokemon) async {
    final user = _authProvider.user;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(pokemon.name)
        .set({'imageUrl': pokemon.imageUrl});

    _favoritePokemons.add(pokemon);
    notifyListeners();
  }

  Future<void> removeFavorite(String name) async {
    final user = _authProvider.user;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(name)
        .delete();

    _favoritePokemons.removeWhere((poke) => poke.name == name);
    notifyListeners();
  }
}
