import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/data/db/app_database.dart';
import 'package:iacaveavin/data/reference_repository.dart';
import 'package:iacaveavin/domain/garde_rules.dart';
import 'package:iacaveavin/domain/wine_detail.dart';

import '../fixture.dart';

void main() {
  final f = Fixture();
  setUp(f.setUp);

  test(
    'PAR-07 règles modifiées : seules les gardes estimées sont recalculées',
    () async {
      // La fiche du jeu (Bourgogne rouge 2019) porte une garde estimée.
      await (f.db.update(f.db.wines)..where((w) => w.id.equals(f.wine))).write(
        const WinesCompanion(
          gardeDebut: Value(2021),
          gardeApogee: Value(2023),
          gardeFin: Value(2027),
          gardeSource: Value('estimation'),
        ),
      );
      // Une garde saisie à la main n'est jamais touchée (règle 3).
      final manual = await f.repo.createWine(
        const WineDraft(
          producer: 'Domaine Main',
          country: 'FR',
          region: 'fr-bourgogne',
          color: 'rouge',
          vintage: '2019',
          gardeStart: 2022,
          gardePeak: 2025,
          gardeEnd: 2030,
        ),
        cellarId: f.cellar,
      );
      const rules = [
        GardeRule(
          id: 'perso',
          conditions: {
            'couleur': ['rouge'],
            'region': ['Bourgogne'],
          },
          start: 1,
          peak: 2,
          end: 3,
        ),
        GardeRule(id: 'defaut', conditions: {}, start: 0, peak: 1, end: 2),
      ];
      final labels = await ReferenceRepository(f.db).watchLabels().first;
      expect(await f.repo.reestimateGarde(rules, labels), 1);
      final w = (await f.repo.wine(f.wine))!;
      final d = w.draft;
      expect((d.gardeStart, d.gardePeak, d.gardeEnd), (2020, 2021, 2022));
      expect(w.gardeSource, 'estimation');
      final m = (await f.repo.wine(manual))!.draft;
      expect((m.gardeStart, m.gardePeak, m.gardeEnd), (2022, 2025, 2030));
      // Rien ne change au second passage.
      expect(await f.repo.reestimateGarde(rules, labels), 0);
    },
  );
}
