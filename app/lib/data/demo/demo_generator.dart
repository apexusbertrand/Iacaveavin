import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:uuid/data.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';

/// Identifiant fixe de la cave de démonstration. Toutes les lignes du jeu
/// portent ce cave_id, ce qui permet de l'effacer sans toucher aux autres caves.
const demoCellarId = '00000000-0000-4000-8000-00000000d3e0';

/// Nombre de fiches exigé par CMP-07.
const demoWineTarget = 200;
const demoFirstVintage = 2005;
const demoLastVintage = 2024;

/// Jeu de démonstration prêt à insérer.
class DemoDataSet {
  DemoDataSet({
    required this.cellar,
    required this.owners,
    required this.locations,
    required this.producers,
    required this.cuvees,
    required this.wines,
    required this.lots,
    required this.movements,
  });

  final CellarsCompanion cellar;
  final List<OwnersCompanion> owners;
  final List<StorageLocationsCompanion> locations;
  final List<ProducersCompanion> producers;
  final List<CuveesCompanion> cuvees;
  final List<WinesCompanion> wines;
  final List<StockLotsCompanion> lots;
  final List<StockMovementsCompanion> movements;
}

/// Modèle d'un vin de démonstration. Les codes renvoient aux référentiels
/// embarqués (assets/referentiels/), vérifiés par test/data/demo_test.dart.
class _Template {
  const _Template(
    this.pays,
    this.region,
    this.sousRegion,
    this.appellation,
    this.couleur,
    this.typeVin,
    this.signe,
    this.cepages,
  );

  final String pays;
  final String? region;
  final String? sousRegion;
  final String? appellation;
  final String couleur;
  final String typeVin;
  final String? signe;
  final List<(String, int)> cepages;
}

const _templates = <_Template>[
  _Template(
    'FR',
    'fr-bordeaux',
    'fr-bordeaux--medoc',
    'fr-pauillac',
    'rouge',
    'tranquille',
    'AOP',
    [('cabernet-sauvignon', 70), ('merlot', 30)],
  ),
  _Template(
    'FR',
    'fr-bordeaux',
    'fr-bordeaux--medoc',
    'fr-margaux',
    'rouge',
    'tranquille',
    'AOP',
    [('cabernet-sauvignon', 60), ('merlot', 35), ('petit-verdot', 5)],
  ),
  _Template(
    'FR',
    'fr-bordeaux',
    'fr-bordeaux--libournais',
    'fr-saint-emilion-grand-cru',
    'rouge',
    'tranquille',
    'AOP',
    [('merlot', 75), ('cabernet-franc', 25)],
  ),
  _Template(
    'FR',
    'fr-bordeaux',
    'fr-bordeaux--libournais',
    'fr-pomerol',
    'rouge',
    'tranquille',
    'AOP',
    [('merlot', 85), ('cabernet-franc', 15)],
  ),
  _Template(
    'FR',
    'fr-bordeaux',
    'fr-bordeaux--graves',
    'fr-pessac-leognan',
    'blanc',
    'tranquille',
    'AOP',
    [('sauvignon-blanc', 60), ('semillon', 40)],
  ),
  _Template(
    'FR',
    'fr-bordeaux',
    'fr-bordeaux--sauternais',
    'fr-sauternes',
    'liquoreux',
    'liquoreux',
    'AOP',
    [('semillon', 85), ('sauvignon-blanc', 15)],
  ),
  _Template(
    'FR',
    'fr-bordeaux',
    null,
    'fr-cremant-de-bordeaux',
    'effervescent',
    'effervescent',
    'AOP',
    [('semillon', 50), ('cabernet-franc', 50)],
  ),
  _Template(
    'FR',
    'fr-bourgogne',
    'fr-bourgogne--cote-de-nuits',
    'fr-gevrey-chambertin',
    'rouge',
    'tranquille',
    'AOP',
    [('pinot-noir', 100)],
  ),
  _Template(
    'FR',
    'fr-bourgogne',
    'fr-bourgogne--cote-de-beaune',
    'fr-meursault',
    'blanc',
    'tranquille',
    'AOP',
    [('chardonnay', 100)],
  ),
  _Template(
    'FR',
    'fr-bourgogne',
    'fr-bourgogne--cote-de-beaune',
    'fr-volnay',
    'rouge',
    'tranquille',
    'AOP',
    [('pinot-noir', 100)],
  ),
  _Template(
    'FR',
    'fr-bourgogne',
    'fr-bourgogne--chablis-et-grand-auxerrois',
    'fr-chablis',
    'blanc',
    'tranquille',
    'AOP',
    [('chardonnay', 100)],
  ),
  _Template(
    'FR',
    'fr-bourgogne',
    'fr-bourgogne--maconnais',
    'fr-pouilly-fuisse',
    'blanc',
    'tranquille',
    'AOP',
    [('chardonnay', 100)],
  ),
  _Template(
    'FR',
    'fr-champagne',
    null,
    'fr-champagne',
    'champagne',
    'effervescent',
    'AOP',
    [('chardonnay', 40), ('pinot-noir', 40), ('meunier', 20)],
  ),
  _Template(
    'FR',
    'fr-champagne',
    'fr-champagne--cote-des-blancs',
    'fr-champagne',
    'champagne',
    'effervescent',
    'AOP',
    [('chardonnay', 100)],
  ),
  _Template(
    'FR',
    'fr-vallee-du-rhone',
    'fr-vallee-du-rhone--rhone-septentrional',
    'fr-cote-rotie',
    'rouge',
    'tranquille',
    'AOP',
    [('syrah', 95), ('viognier', 5)],
  ),
  _Template(
    'FR',
    'fr-vallee-du-rhone',
    'fr-vallee-du-rhone--rhone-septentrional',
    'fr-condrieu',
    'blanc',
    'tranquille',
    'AOP',
    [('viognier', 100)],
  ),
  _Template(
    'FR',
    'fr-vallee-du-rhone',
    'fr-vallee-du-rhone--rhone-meridional',
    'fr-chateauneuf-du-pape',
    'rouge',
    'tranquille',
    'AOP',
    [('grenache', 70), ('syrah', 15), ('mourvedre', 15)],
  ),
  _Template(
    'FR',
    'fr-vallee-du-rhone',
    'fr-vallee-du-rhone--rhone-meridional',
    'fr-tavel',
    'rose',
    'tranquille',
    'AOP',
    [('grenache', 60), ('cinsault', 40)],
  ),
  _Template(
    'FR',
    'fr-provence',
    null,
    'fr-cotes-de-provence',
    'rose',
    'tranquille',
    'AOP',
    [('grenache', 50), ('cinsault', 30), ('tibouren', 20)],
  ),
  _Template(
    'FR',
    'fr-provence',
    null,
    'fr-bandol',
    'rouge',
    'tranquille',
    'AOP',
    [('mourvedre', 80), ('grenache', 20)],
  ),
  _Template(
    'FR',
    'fr-vallee-de-la-loire',
    'fr-vallee-de-la-loire--centre-loire',
    'fr-sancerre',
    'blanc',
    'tranquille',
    'AOP',
    [('sauvignon-blanc', 100)],
  ),
  _Template(
    'FR',
    'fr-vallee-de-la-loire',
    'fr-vallee-de-la-loire--touraine',
    'fr-chinon',
    'rouge',
    'tranquille',
    'AOP',
    [('cabernet-franc', 100)],
  ),
  _Template(
    'FR',
    'fr-vallee-de-la-loire',
    'fr-vallee-de-la-loire--touraine',
    'fr-vouvray',
    'blanc',
    'tranquille',
    'AOP',
    [('chenin', 100)],
  ),
  _Template(
    'FR',
    'fr-vallee-de-la-loire',
    'fr-vallee-de-la-loire--anjou-saumur',
    'fr-coteaux-du-layon',
    'liquoreux',
    'liquoreux',
    'AOP',
    [('chenin', 100)],
  ),
  _Template(
    'FR',
    'fr-alsace',
    null,
    'fr-alsace',
    'blanc',
    'tranquille',
    'AOP',
    [('riesling', 100)],
  ),
  _Template(
    'FR',
    'fr-alsace',
    null,
    'fr-cremant-d-alsace',
    'effervescent',
    'effervescent',
    'AOP',
    [('pinot-blanc', 60), ('auxerrois', 40)],
  ),
  _Template(
    'FR',
    'fr-beaujolais',
    null,
    'fr-morgon',
    'rouge',
    'tranquille',
    'AOP',
    [('gamay', 100)],
  ),
  _Template('FR', 'fr-jura', null, 'fr-arbois', 'blanc', 'tranquille', 'AOP', [
    ('savagnin', 100),
  ]),
  _Template('FR', 'fr-languedoc', null, null, 'orange', 'tranquille', 'IGP', [
    ('grenache-blanc', 60),
    ('muscat-a-petits-grains', 40),
  ]),
  _Template(
    'FR',
    'fr-sud-ouest',
    null,
    'fr-cahors',
    'rouge',
    'tranquille',
    'AOP',
    [('malbec', 90), ('merlot', 10)],
  ),
  _Template(
    'FR',
    'fr-sud-ouest',
    null,
    'fr-jurancon',
    'liquoreux',
    'moelleux',
    'AOP',
    [('petit-manseng', 80), ('gros-manseng', 20)],
  ),
  _Template('FR', 'fr-roussillon', null, 'fr-banyuls', 'rouge', 'mute', 'AOP', [
    ('grenache', 100),
  ]),
  _Template(
    'FR',
    'fr-jura',
    null,
    'fr-macvin-du-jura',
    'autre',
    'mute',
    'AOP',
    [('savagnin', 50), ('chardonnay', 50)],
  ),
  _Template(
    'IT',
    'it-piemont',
    null,
    'it-barolo',
    'rouge',
    'tranquille',
    'DOCG',
    [('nebbiolo', 100)],
  ),
  _Template(
    'IT',
    'it-venetie',
    null,
    'it-prosecco',
    'effervescent',
    'effervescent',
    'DOC',
    [('glera', 100)],
  ),
  _Template('ES', 'es-rioja', null, 'es-rioja', 'rouge', 'tranquille', 'DOC', [
    ('tempranillo', 85),
    ('graciano', 15),
  ]),
  _Template('PT', 'pt-douro', null, 'pt-porto', 'rouge', 'mute', 'DO', [
    ('touriga-nacional', 60),
    ('touriga-franca', 40),
  ]),
  _Template(
    'DE',
    'de-moselle',
    null,
    'de-mosel',
    'blanc',
    'tranquille',
    'autre',
    [('riesling', 100)],
  ),
  _Template(
    'AR',
    'ar-mendoza',
    null,
    'ar-mendoza',
    'rouge',
    'tranquille',
    'autre',
    [('malbec', 100)],
  ),
];

/// Décalages de garde fictifs par couleur (début, apogée, fin), en années.
const _gardeParCouleur = <String, (int, int, int)>{
  'rouge': (3, 8, 15),
  'blanc': (1, 4, 8),
  'rose': (0, 1, 2),
  'champagne': (3, 8, 15),
  'effervescent': (0, 1, 3),
  'liquoreux': (5, 15, 30),
  'orange': (1, 3, 6),
  'autre': (0, 5, 20),
};

// Syllabes pour des noms de domaines inventés.
const _debuts = [
  'Bral',
  'Corv',
  'Delm',
  'Fen',
  'Garl',
  'Lurm',
  'Mond',
  'Talv',
  'Vioz',
  'Zan',
  'Quer',
  'Hob',
];
const _fins = [
  'iac',
  'erel',
  'antine',
  'ouvaux',
  'izac',
  'olune',
  'essard',
  'ombe',
  'arigue',
  'eval',
];
const _types = ['Château', 'Domaine', 'Clos', 'Mas', 'Maison', 'Cave'];
const _cuveesGeneriques = [
  null,
  'Les Terrasses',
  'Vieilles Vignes',
  'Cuvée du Puits',
  'Les Galets',
  'Réserve',
  'Coteau Nord',
  'Les Combes',
];

/// Construit le jeu de démonstration de façon déterministe (même graine,
/// mêmes données) : 200 fiches, toutes les couleurs, millésimes 2005 à 2024,
/// 3 propriétaires, 6 emplacements sur 3 niveaux. Le stock de chaque lot
/// n'existe que par ses mouvements (STK-R1).
DemoDataSet buildDemoDataSet({int seed = 2026, DateTime? now}) {
  final rnd = Random(seed);
  const uuid = Uuid();
  final stamp = (now ?? DateTime.now()).toUtc();
  final thisYear = stamp.year;
  String id() => uuid.v4(
    config: V4Options(List.generate(16, (_) => rnd.nextInt(256)), null),
  );

  final cellar = CellarsCompanion.insert(
    id: demoCellarId,
    createdAt: stamp,
    updatedAt: stamp,
    nom: 'Cave de démonstration',
    devise: const Value('EUR'),
  );

  final owners = <OwnersCompanion>[];
  for (final (nom, initiales, couleur) in [
    ('Alex', 'AL', '#2F5D7C'),
    ('Camille', 'CA', '#8E1B2C'),
    ('Sam', 'SA', '#1E7A3A'),
  ]) {
    owners.add(
      OwnersCompanion.insert(
        id: id(),
        caveId: demoCellarId,
        createdAt: stamp,
        updatedAt: stamp,
        nom: nom,
        initiales: Value(initiales),
        couleur: Value(couleur),
        parDefaut: Value(owners.isEmpty),
      ),
    );
  }

  final locations = <StorageLocationsCompanion>[];
  String location(
    String nom,
    String type, {
    String? parent,
    int? lignes,
    int? colonnes,
  }) {
    final locId = id();
    locations.add(
      StorageLocationsCompanion.insert(
        id: locId,
        caveId: demoCellarId,
        createdAt: stamp,
        updatedAt: stamp,
        nom: nom,
        typeEmplacement: type,
        parentId: Value(parent),
        lignes: Value(lignes),
        colonnes: Value(colonnes),
        capacite: Value(lignes == null ? null : lignes * colonnes!),
      ),
    );
    return locId;
  }

  final cave = location('Cave', 'cave');
  final armoire1 = location('Armoire 1', 'meuble', parent: cave);
  final armoire2 = location('Armoire 2', 'meuble', parent: cave);
  final casierA = location(
    'Casier A',
    'casier',
    parent: armoire1,
    lignes: 6,
    colonnes: 8,
  );
  final casierB = location(
    'Casier B',
    'casier',
    parent: armoire1,
    lignes: 6,
    colonnes: 8,
  );
  final casierC = location(
    'Casier C',
    'casier',
    parent: armoire2,
    lignes: 8,
    colonnes: 10,
  );
  final cellier = location('Cellier', 'cave');
  final clayette = location('Clayette 1', 'clayette', parent: cellier);
  final leaves = [casierA, casierB, casierC, clayette];
  final grids = {casierA: (6, 8), casierB: (6, 8), casierC: (8, 10)};

  final producers = <ProducersCompanion>[];
  final producerNames = <String>{};
  while (producers.length < 48) {
    final name =
        '${_types[rnd.nextInt(_types.length)]} '
        '${_debuts[rnd.nextInt(_debuts.length)]}'
        '${_fins[rnd.nextInt(_fins.length)]}';
    if (!producerNames.add(name)) continue;
    producers.add(
      ProducersCompanion.insert(
        id: id(),
        caveId: demoCellarId,
        createdAt: stamp,
        updatedAt: stamp,
        nom: name,
      ),
    );
  }

  final cuvees = <CuveesCompanion>[];
  final wines = <WinesCompanion>[];
  final lots = <StockLotsCompanion>[];
  final movements = <StockMovementsCompanion>[];

  var cuveeIndex = 0;
  while (wines.length < demoWineTarget) {
    final t = _templates[cuveeIndex % _templates.length];
    final producer = producers[cuveeIndex % producers.length];
    final cuveeId = id();
    cuvees.add(
      CuveesCompanion.insert(
        id: cuveeId,
        caveId: demoCellarId,
        createdAt: stamp,
        updatedAt: stamp,
        domaineId: producer.id.value,
        nom: Value(_cuveesGeneriques[rnd.nextInt(_cuveesGeneriques.length)]),
        pays: t.pays,
        region: Value(t.region),
        sousRegion: Value(t.sousRegion),
        appellation: Value(t.appellation),
        signeQualite: Value(t.signe),
        couleur: t.couleur,
        typeVin: Value(t.typeVin),
        certification: Value(rnd.nextInt(5) == 0 ? 'bio' : 'aucune'),
      ),
    );

    final vintageCount = 2 + rnd.nextInt(3);
    final years = <int>{};
    // Les deux premières fiches fixent les bornes 2005 et 2024 exigées.
    if (wines.isEmpty) years.addAll([demoFirstVintage, demoLastVintage]);
    while (years.length < vintageCount) {
      years.add(
        demoFirstVintage + rnd.nextInt(demoLastVintage - demoFirstVintage + 1),
      );
    }

    for (final year in years) {
      if (wines.length >= demoWineTarget) break;
      final wineId = id();
      final garde = _gardeParCouleur[t.couleur]!;
      wines.add(
        WinesCompanion.insert(
          id: wineId,
          caveId: demoCellarId,
          createdAt: stamp,
          updatedAt: stamp,
          cuveeId: cuveeId,
          millesime: '$year',
          cepages: Value(
            jsonEncode([
              for (final (cepage, pct) in t.cepages)
                {'cepage': cepage, 'pourcentage': pct},
            ]),
          ),
          degre: Value(11.5 + rnd.nextInt(7) * 0.5),
          gardeDebut: Value(year + garde.$1),
          gardeApogee: Value(year + garde.$2),
          gardeFin: Value(year + garde.$3),
          gardeSource: const Value('estimation'),
          favori: Value(rnd.nextInt(8) == 0),
          statutEnrichissement: Value(
            rnd.nextInt(10) == 0 ? 'a_valider' : 'valide',
          ),
        ),
      );

      final lotCount = rnd.nextInt(4) == 0 ? 2 : 1;
      for (var l = 0; l < lotCount; l++) {
        final lotId = id();
        final leaf = leaves[rnd.nextInt(leaves.length)];
        final grid = grids[leaf];
        final purchaseYear = min(year + 1 + rnd.nextInt(5), thisYear);
        final purchaseDate =
            '$purchaseYear-${_two(1 + rnd.nextInt(12))}-${_two(1 + rnd.nextInt(28))}';
        final format = rnd.nextInt(12) == 0 ? 150.0 : 75.0;
        lots.add(
          StockLotsCompanion.insert(
            id: lotId,
            caveId: demoCellarId,
            createdAt: stamp,
            updatedAt: stamp,
            ficheId: wineId,
            formatCl: Value(format),
            proprietaireId: owners[rnd.nextInt(owners.length)].id.value,
            emplacementId: Value(leaf),
            positions: Value(
              grid == null
                  ? null
                  : '${String.fromCharCode(65 + rnd.nextInt(grid.$1))}'
                        '${1 + rnd.nextInt(grid.$2)}',
            ),
            prixAchatUnitaire: Value(
              rnd.nextInt(10) < 7 ? (16 + rnd.nextInt(280)) / 2 : null,
            ),
            dateAchat: Value(purchaseDate),
          ),
        );

        final bought = 1 + rnd.nextInt(12);
        movements.add(
          StockMovementsCompanion.insert(
            id: id(),
            caveId: demoCellarId,
            createdAt: stamp,
            updatedAt: stamp,
            lotId: lotId,
            typeMouvement: 'entree',
            quantite: bought,
            dateMouvement: purchaseDate,
            motif: const Value('achat'),
          ),
        );
        // Environ 40 % des lots ont des ouvertures, quelques-uns sont épuisés.
        if (rnd.nextInt(10) < 4) {
          final opened = rnd.nextInt(12) == 0
              ? bought
              : 1 + rnd.nextInt(bought);
          movements.add(
            StockMovementsCompanion.insert(
              id: id(),
              caveId: demoCellarId,
              createdAt: stamp,
              updatedAt: stamp,
              lotId: lotId,
              typeMouvement: 'ouverture',
              quantite: -opened,
              dateMouvement: '${min(purchaseYear + 1, thisYear)}-06-15',
              motif: const Value('ouverture'),
            ),
          );
        }
      }
    }
    cuveeIndex++;
  }

  return DemoDataSet(
    cellar: cellar,
    owners: owners,
    locations: locations,
    producers: producers,
    cuvees: cuvees,
    wines: wines,
    lots: lots,
    movements: movements,
  );
}

String _two(int v) => v.toString().padLeft(2, '0');
