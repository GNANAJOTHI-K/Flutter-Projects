class PokemonDetail {
  final int id;
  final String name;
  final int baseExperience;
  final int height;
  final int weight;
  final List<String> types;
  final List<Ability> abilities;
  final List<Stat> stats;
  final List<String> moves;
  final List<HeldItem> heldItems;
  final List<String> forms;
  final Sprites sprites;
  final String speciesUrl;

  PokemonDetail({
    required this.id,
    required this.name,
    required this.baseExperience,
    required this.height,
    required this.weight,
    required this.types,
    required this.abilities,
    required this.stats,
    required this.moves,
    required this.heldItems,
    required this.forms,
    required this.sprites,
    required this.speciesUrl,
  });

  factory PokemonDetail.fromJson(Map<String, dynamic> json) {
    return PokemonDetail(
      id: json['id'],
      name: json['name'],
      baseExperience: json['base_experience'],
      height: json['height'],
      weight: json['weight'],
      types: (json['types'] as List).map<String>((t) => t['type']['name'] as String).toList(),
      abilities: (json['abilities'] as List).map((a) => Ability.fromJson(a)).toList(),
      stats: (json['stats'] as List).map((s) => Stat.fromJson(s)).toList(),
      moves: (json['moves'] as List).map<String>((m) => m['move']['name'] as String).toList(),
      heldItems: (json['held_items'] as List).map((h) => HeldItem.fromJson(h)).toList(),
      forms: (json['forms'] as List).map<String>((f) => f['name'] as String).toList(),
      sprites: Sprites.fromJson(json['sprites']),
      speciesUrl: json['species']['url'],
    );
  }
}

class Ability {
  final String name;
  final bool isHidden;

  Ability({required this.name, required this.isHidden});

  factory Ability.fromJson(Map<String, dynamic> json) {
    return Ability(
      name: json['ability']['name'],
      isHidden: json['is_hidden'],
    );
  }
}

class Stat {
  final String name;
  final int baseStat;

  Stat({required this.name, required this.baseStat});

  factory Stat.fromJson(Map<String, dynamic> json) {
    return Stat(
      name: json['stat']['name'],
      baseStat: json['base_stat'],
    );
  }
}

class HeldItem {
  final String name;

  HeldItem({required this.name});

  factory HeldItem.fromJson(Map<String, dynamic> json) {
    return HeldItem(
      name: json['item']['name'],
    );
  }
}

class Sprites {
  final String? frontDefault;
  final String? backDefault;
  final String? frontShiny;
  final String? backShiny;
  final String? officialArtwork;

  Sprites({
    this.frontDefault,
    this.backDefault,
    this.frontShiny,
    this.backShiny,
    this.officialArtwork,
  });

  factory Sprites.fromJson(Map<String, dynamic> json) {
    return Sprites(
      frontDefault: json['front_default'],
      backDefault: json['back_default'],
      frontShiny: json['front_shiny'],
      backShiny: json['back_shiny'],
      officialArtwork: json['other']?['official-artwork']?['front_default'],
    );
  }

  List<String> get allImages {
    final images = <String>[];
    if (officialArtwork != null) images.add(officialArtwork!);
    if (frontDefault != null) images.add(frontDefault!);
    if (backDefault != null) images.add(backDefault!);
    if (frontShiny != null) images.add(frontShiny!);
    if (backShiny != null) images.add(backShiny!);
    return images.toSet().toList(); // unique only
  }
}

class Species {
  final String description;
  final String habitat;
  final List<String> eggGroups;
  final String evolutionChainUrl;

  Species({
    required this.description,
    required this.habitat,
    required this.eggGroups,
    required this.evolutionChainUrl,
  });

  factory Species.fromJson(Map<String, dynamic> json) {
    // Get English description from flavor_text_entries
    String desc = '';
    for (var entry in (json['flavor_text_entries'] as List)) {
      if (entry['language']['name'] == 'en') {
        desc = entry['flavor_text'].replaceAll('\n', ' ').replaceAll('\f', ' ');
        break;
      }
    }

    return Species(
      description: desc,
      habitat: json['habitat'] != null ? json['habitat']['name'] : 'unknown',
      eggGroups: (json['egg_groups'] as List).map<String>((e) => e['name'] as String).toList(),
      evolutionChainUrl: json['evolution_chain']['url'],
    );
  }
}

class EvolutionChain {
  final List<EvolutionDetail> chain;

  EvolutionChain({required this.chain});

  factory EvolutionChain.fromJson(Map<String, dynamic> json) {
    List<EvolutionDetail> parseChain(dynamic chainData) {
      final List<EvolutionDetail> evolutions = [];

      void recursiveParse(dynamic node) {
        evolutions.add(EvolutionDetail(name: node['species']['name'], url: node['species']['url']));
        if (node['evolves_to'] != null && (node['evolves_to'] as List).isNotEmpty) {
          for (var evo in node['evolves_to']) {
            recursiveParse(evo);
          }
        }
      }

      recursiveParse(json['chain']);
      return evolutions;
    }

    return EvolutionChain(chain: parseChain(json));
  }
}

class EvolutionDetail {
  final String name;
  final String url;

  EvolutionDetail({required this.name, required this.url});
}
