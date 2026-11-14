import 'package:drift/drift.dart';
import 'package:iacaveavin/data/cellar_repository.dart';
import 'package:iacaveavin/data/db/app_database.dart';
import 'package:iacaveavin/domain/stock_rules.dart';
import 'package:iacaveavin/domain/wine_detail.dart' show manualPriceNature;

/// Sources consultables sur le web : une URL est exigée (recette transverse,
/// docs/08 : « aucune valeur enrichie sans source consultable en un tap »).
const _webSources = {
  'site_officiel',
  'organisme_officiel',
  'interprofession',
  'critique',
  'marchand',
  'tiers',
};

bool _blank(String? s) => s == null || s.trim().isEmpty;

/// Recette transverse du lot 5 (docs/08-lots-recette.md), contrôlée sur la
/// base : liste des écarts, vide si tout est conforme.
Future<List<String>> recetteViolations(AppDatabase db) async {
  final out = <String>[];

  // Le stock affiché égale toujours la somme des mouvements, aucun lot
  // n'est négatif.
  final lots = await (db.select(
    db.stockLots,
  )..where((l) => l.deletedAt.isNull())).get();
  final moves = await (db.select(
    db.stockMovements,
  )..where((m) => m.deletedAt.isNull())).get();
  final byLot = <String, int>{};
  for (final m in moves) {
    byLot[m.lotId] =
        (byLot[m.lotId] ?? 0) +
        signedQuantity(MovementType.fromCode(m.typeMouvement), m.quantite);
  }
  final byWine = <String, int>{};
  for (final l in lots) {
    final q = byLot[l.id] ?? 0;
    if (q < 0) out.add('lot ${l.id} négatif : $q');
    byWine[l.ficheId] = (byWine[l.ficheId] ?? 0) + q;
  }
  for (final w in await CellarRepository(db).wineItems()) {
    final expected = byWine[w.id] ?? 0;
    if (w.bottles != expected) {
      out.add('fiche ${w.id} : affiché ${w.bottles}, mouvements $expected');
    }
  }

  // Aucune note critique ni aucun prix relevé sans URL vérifiable. Un prix
  // saisi à la main (PRX-07) est une valeur de l'utilisateur, sans URL.
  for (final s in await (db.select(
    db.criticScores,
  )..where((s) => s.deletedAt.isNull())).get()) {
    if (_blank(s.url)) out.add('note ${s.id} (${s.critique}) sans URL');
  }
  for (final p in await (db.select(
    db.marketPrices,
  )..where((p) => p.deletedAt.isNull() & p.trouve.equals(true))).get()) {
    if (p.nature != manualPriceNature && _blank(p.url)) {
      out.add('prix ${p.id} trouvé sans URL');
    }
  }

  // Aucune valeur tirée du web sans URL consultable.
  for (final p in await db.select(db.provenances).get()) {
    if (_webSources.contains(p.source) && _blank(p.url)) {
      out.add('provenance ${p.champ} (${p.source}) sans URL');
    }
  }

  // Aucune clé technique (type « wine_0 ») dans les libellés de listes.
  final technical = RegExp(r'_\d');
  for (final v in await db.select(db.listValues).get()) {
    if (technical.hasMatch(v.libelle)) {
      out.add('libellé technique ${v.liste}:${v.code} « ${v.libelle} »');
    }
  }
  return out;
}
