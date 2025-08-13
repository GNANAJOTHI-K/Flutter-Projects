import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../models/pokemon_detail.dart';

class PokemonDetailScreen extends StatefulWidget {
  final String pokemonUrl;

  const PokemonDetailScreen({super.key, required this.pokemonUrl});

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  final Dio _dio = Dio();

  PokemonDetail? _pokemonDetail;
  Species? _species;
  EvolutionChain? _evolutionChain;

  bool _loading = true;
  String? _error;

  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final pokemonResp = await _dio.get(widget.pokemonUrl);
      _pokemonDetail = PokemonDetail.fromJson(pokemonResp.data);

      final speciesResp = await _dio.get(_pokemonDetail!.speciesUrl);
      _species = Species.fromJson(speciesResp.data);

      final evoChainResp = await _dio.get(_species!.evolutionChainUrl);
      _evolutionChain = EvolutionChain.fromJson(evoChainResp.data);

      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Failed to load Pokémon details or evolution chain.';
      });
    }
  }

  // Helper: Convert species URL to pokemon URL by changing /species/ to /pokemon/
  String _speciesUrlToPokemonUrl(String speciesUrl) {
    // Example: https://pokeapi.co/api/v2/pokemon-species/1/
    // Convert to: https://pokeapi.co/api/v2/pokemon/1/
    if (speciesUrl.contains('/pokemon-species/')) {
      return speciesUrl.replaceAll('/pokemon-species/', '/pokemon/');
    }
    return speciesUrl;
  }

  Widget _buildStatRow(String statName, int baseStat) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
              width: 110,
              child: Text(statName.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: baseStat / 150,
                backgroundColor: Colors.grey.shade300,
                color: Colors.blue.shade600,
                minHeight: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            baseStat.toString(),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.8),
          ),
          const SizedBox(width: 8),
          Expanded(
              child: Divider(
            color: Colors.blue.shade300,
            thickness: 1.5,
          )),
        ],
      ),
    );
  }

  Widget _buildChipList(List<String> items,
      {Color? color, bool isHiddenMarker = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            (color ?? Colors.blue.shade200).withOpacity(0.15),
            (color ?? Colors.blue.shade200).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items.map((item) {
          return Chip(
            label: Text(item),
            backgroundColor: (color ?? Colors.blue.shade200).withOpacity(0.35),
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            side: isHiddenMarker && item.toLowerCase().contains('(hidden)')
                ? const BorderSide(color: Colors.orange, width: 1.5)
                : null,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEvolutionChain() {
    if (_evolutionChain == null || _evolutionChain!.chain.isEmpty) {
      return const Text('No evolution data available');
    }
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _evolutionChain!.chain.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final evo = _evolutionChain!.chain[index];
          final imageUrl =
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${_getIdFromUrl(evo.url)}.png';

          return GestureDetector(
            onTap: () {
              final pokemonUrl = _speciesUrlToPokemonUrl(evo.url);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => PokemonDetailScreen(
                    pokemonUrl: pokemonUrl,
                  ),
                ),
              );
            },
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade400,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      )
                    ],
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      height: 90,
                      width: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.error),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 90,
                  child: Text(
                    evo.name[0].toUpperCase() + evo.name.substring(1),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  int _getIdFromUrl(String url) {
    final parts = url.split('/');
    return int.parse(parts[parts.length - 2]);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(child: Text(_error!)),
      );
    }

    final pd = _pokemonDetail!;
    final species = _species!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${pd.name[0].toUpperCase()}${pd.name.substring(1)}'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carousel images + name below each + dot indicator
            SizedBox(
              height: 320,
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: pd.sprites.allImages.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final imageUrl = pd.sprites.allImages[index];
                        return Center(
                          child: Container(
                            width: 360,
                            height: 280,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade400,
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDotsIndicator(pd.sprites.allImages.length),
                  const SizedBox(height: 8),
                  Text(
                    '${pd.name[0].toUpperCase()}${pd.name.substring(1)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Basic info card
            Card(
              elevation: 6,
              margin: const EdgeInsets.only(top: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 28),
                child: Wrap(
                  spacing: 48,
                  runSpacing: 28,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    _infoItem(Icons.confirmation_number_outlined, 'ID',
                        pd.id.toString()),
                    _infoItem(Icons.star_rate, 'Base XP',
                        pd.baseExperience.toString()),
                    _infoItem(Icons.height, 'Height',
                        '${(pd.height / 10).toStringAsFixed(1)} m'),
                    _infoItem(Icons.fitness_center, 'Weight',
                        '${(pd.weight / 10).toStringAsFixed(1)} kg'),
                  ],
                ),
              ),
            ),

            _buildSectionTitle('Types'),
            _buildChipList(pd.types.map((e) => e.toUpperCase()).toList()),

            _buildSectionTitle('Abilities'),
            _buildChipList(
              pd.abilities
                  .map((a) =>
                      '${a.name.toUpperCase()}${a.isHidden ? ' (Hidden)' : ''}')
                  .toList(),
              color: Colors.green.shade300,
              isHiddenMarker: true,
            ),

            _buildSectionTitle('Stats'),
            Card(
              elevation: 3,
              margin: const EdgeInsets.only(top: 8),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: pd.stats
                      .map((s) => _buildStatRow(s.name, s.baseStat))
                      .toList(),
                ),
              ),
            ),

            _buildSectionTitle('Moves'),
            Card(
              elevation: 3,
              margin: const EdgeInsets.only(top: 8),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 180),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Scrollbar(
                  thumbVisibility: true,
                  child: ListView.separated(
                    itemCount: pd.moves.length > 20 ? 20 : pd.moves.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 12, color: Colors.grey),
                    itemBuilder: (context, index) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(
                                fontSize: 20,
                                height: 1.5,
                                color: Colors.blueAccent),
                          ),
                          Expanded(
                            child: Text(
                              pd.moves[index],
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            _buildSectionTitle('Held Items'),
            Card(
              elevation: 3,
              margin: const EdgeInsets.only(top: 8),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: pd.heldItems.isEmpty
                    ? const Text('None')
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: pd.heldItems
                            .map((item) => Chip(
                                  label: Text(item.name.toUpperCase()),
                                ))
                            .toList(),
                      ),
              ),
            ),

            _buildSectionTitle('Forms'),
            _buildChipList(pd.forms.map((f) => f.toUpperCase()).toList()),

            _buildSectionTitle('Species Info'),
            Card(
              elevation: 3,
              margin: const EdgeInsets.only(top: 8),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Description:', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(species.description, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    _infoItem(Icons.nature_people, 'Habitat', species.habitat),
                    _infoItem(Icons.egg, 'Egg Groups', species.eggGroups.join(', ')),
                  ],
                ),
              ),
            ),

            _buildSectionTitle('Evolution Chain'),
            Card(
              elevation: 3,
              margin: const EdgeInsets.only(top: 8, bottom: 24),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: _error != null
                    ? Text(
                        'Evolution data not available',
                        style: TextStyle(color: Colors.red.shade700),
                      )
                    : _buildEvolutionChain(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDotsIndicator(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          height: 8,
          width: _currentImageIndex == index ? 22 : 8,
          decoration: BoxDecoration(
            color:
                _currentImageIndex == index ? Colors.blue.shade700 : Colors.grey,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: Colors.blue.shade700),
        const SizedBox(width: 6),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(value),
      ],
    );
  }
}
