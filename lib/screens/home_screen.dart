import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pokemon_provider.dart';
import '../providers/favorites_provider.dart';
import 'pokemon_detail_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';  // Import your login page here


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _pokemonTypes = [
    'All', 'Normal', 'Fire', 'Water', 'Electric', 'Grass', 'Ice', 'Fighting', 'Poison',
    'Ground', 'Flying', 'Psychic', 'Bug', 'Rock', 'Ghost', 'Dragon', 'Dark', 'Steel', 'Fairy',
  ];

  String _selectedType = 'All';

  @override
  void initState() {
    super.initState();

    final pokemonProvider = Provider.of<PokemonProvider>(context, listen: false);
    pokemonProvider.fetchPokemons();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          !pokemonProvider.isLoading) {
        pokemonProvider.fetchMorePokemons();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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

  void _handleLogout() async {
  try {
    await FirebaseAuth.instance.signOut();
    // Navigate to login page and clear the navigation stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  } catch (e) {
    // Optionally show error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logout failed: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final pokemonProvider = Provider.of<PokemonProvider>(context);
    final favoritesProvider = Provider.of<FavoritesProvider>(context);

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Pokémon World'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.favorite),
        tooltip: 'Go to Favorites',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const FavoritesScreenWithCustomBack(),
            ),
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Column(
              children: const [
                SizedBox(height: 8),
                Text(
                  'Welcome to Pokémon World',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Catch \'em all! Search, discover, and save your favorite Pokémon with ease.',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search Bar with lighter border
            TextField(
              controller: _searchController,
              cursorColor: Colors.blue,
              decoration: InputDecoration(
                hintText: 'Search Pokémon...',
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.blue.shade100, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.blue.shade300, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              onChanged: (value) {
                pokemonProvider.setSearchQuery(value.trim());
              },
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _pokemonTypes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final type = _pokemonTypes[index];
                  final isSelected = type == _selectedType;
                  return ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    selectedColor: Colors.blue.shade300,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.blue.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedType = type;
                          pokemonProvider.setFilter(type.toLowerCase());
                        });
                      }
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: pokemonProvider.pokemons.isEmpty && !pokemonProvider.isLoading
                  ? const Center(
                      child: Text(
                        'No Pokémon found.',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : GridView.builder(
                      controller: _scrollController,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 3 / 4,
                      ),
                      itemCount: pokemonProvider.pokemons.length +
                          (pokemonProvider.isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == pokemonProvider.pokemons.length) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.blue,
                            ),
                          );
                        }
                        final pokemon = pokemonProvider.pokemons[index];
                        final isFavorite = favoritesProvider.isFavorite(pokemon.name);

                        final pokemonId = _getIdFromUrl(pokemon.url);
                        final imageUrl = _getOfficialArtworkUrl(pokemonId);

                        return GestureDetector(
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
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 3,
                            child: Stack(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.network(
                                          imageUrl,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Text(
                                        pokemon.name[0].toUpperCase() + pokemon.name.substring(1),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                    ),
                                  ],
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    icon: Icon(
                                      isFavorite ? Icons.favorite : Icons.favorite_border,
                                      color: isFavorite ? Colors.red : Colors.grey,
                                    ),
                                    onPressed: () {
                                      if (isFavorite) {
                                        favoritesProvider.removeFavorite(pokemon.name);
                                      } else {
                                        favoritesProvider.addFavorite(pokemon);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Favorites screen with blue appbar and white back icon & blue background on icon buttons
class FavoritesScreenWithCustomBack extends StatelessWidget {
  const FavoritesScreenWithCustomBack({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);

    final favoritePokemons = favoritesProvider.favoritePokemons;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white), // white back icon
        title: const Text('Favorite Pokémon'),
      ),
      body: favoritePokemons.isEmpty
          ? const Center(
              child: Text(
                'No favorites yet.\nGo add some Pokémon!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: favoritePokemons.length,
              itemBuilder: (context, index) {
                final pokemon = favoritePokemons[index];
                return ListTile(
                  leading: Image.network(pokemon.imageUrl),
                  title: Text(
                    pokemon.name[0].toUpperCase() + pokemon.name.substring(1),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: IconButton(
                    icon: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      favoritesProvider.removeFavorite(pokemon.name);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${pokemon.name[0].toUpperCase() + pokemon.name.substring(1)} removed from favorites'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PokemonDetailScreen(
                          pokemonUrl: 'https://pokeapi.co/api/v2/pokemon/${pokemon.name}',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
