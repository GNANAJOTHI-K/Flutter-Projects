import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favorites_provider.dart';
import 'pokemon_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  int _getIdFromUrl(String url) {
    final parts = url.split('/');
    return int.parse(parts[parts.length - 2]);
  }

  String _getOfficialArtworkUrl(int id) {
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
  }

  String _getPokemonUrl(String name) {
    return 'https://pokeapi.co/api/v2/pokemon/$name';
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final favoritePokemons = favoritesProvider.favoritePokemons;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Favorite Pokémon'),
        centerTitle: true,
      ),
      body: favoritePokemons.isEmpty
          ? const Center(
              child: Text(
                'No favorites yet.\nGo add some Pokémon!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView.separated(
                itemCount: favoritePokemons.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final pokemon = favoritePokemons[index];
                  final pokemonId = _getIdFromUrl(pokemon.url);
                  final imageUrl = _getOfficialArtworkUrl(pokemonId);
                  final isFavorite = favoritesProvider.isFavorite(pokemon.name);

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      leading: Image.network(
                        imageUrl,
                        height: 60,
                        width: 60,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.error),
                      ),
                      title: Text(
                        pokemon.name[0].toUpperCase() + pokemon.name.substring(1),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                          size: 28,
                        ),
                        onPressed: () {
                          if (isFavorite) {
                            favoritesProvider.removeFavorite(pokemon.name);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${pokemon.name[0].toUpperCase() + pokemon.name.substring(1)} removed from favorites',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          } else {
                            favoritesProvider.addFavorite(pokemon);
                          }
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PokemonDetailScreen(
                              pokemonUrl: _getPokemonUrl(pokemon.name),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
