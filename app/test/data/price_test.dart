import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/data/db/app_database.dart';
import 'package:iacaveavin/data/enrichment/enrichment_gateway.dart';
import 'package:iacaveavin/data/enrichment/enrichment_queue.dart';
import 'package:iacaveavin/data/files/photo_service.dart';
import 'package:iacaveavin/domain/enrichment.dart';
import 'package:iacaveavin/domain/price_trend.dart';
import 'package:iacaveavin/domain/wine_detail.dart';

import '../fixture.dart';
import 'contract_test.dart' show example, readExample, validator;

/// Faux flux dont le relevé final est [finalJson] (prix-termine.json par
/// défaut).
class PriceGateway extends FakeGateway {
  PriceGateway()
    : super(
        validator: validator(),
        readExample: readExample,
        pollsBeforeDone: 1,
      );

  Map<String, dynamic>? finalJson;

  @override
  Future<JobResponse> followJob(String jobId) async {
    if (finalJson == null) return super.followJob(jobId);
    calls++;
    return JobResponse.fromJson(
      validator().checkResponse(jsonEncode(finalJson)),
    );
  }
}

void main() {
  final f = Fixture();
  late PriceGateway gateway;
  late EnrichmentQueue queue;
  late Directory root;
  var now = DateTime.utc(2026, 11, 20, 9);

  setUp(() async {
    await f.setUp();
    root = Directory.systemTemp.createTempSync('iacav-prix-');
    gateway = PriceGateway();
    queue = EnrichmentQueue(
      f.db,
      gateway: gateway,
      photos: PhotoService(f.db, appDir: () async => root, clock: () => now),
      clock: () => now,
    );
  });
  tearDown(() async {
    await f.db.close();
    root.deleteSync(recursive: true);
  });

  Future<List<MarketPrice>> prices() => (f.db.select(
    f.db.marketPrices,
  )..orderBy([(p) => OrderingTerm.asc(p.createdAt)])).get();

  Future<void> runUntilDone() async {
    for (var i = 0; i < 4 && (await queue.pendingJobs()).isNotEmpty; i++) {
      await queue.process();
    }
  }

  test(
    'PRX-02 relevé à la demande : identité de la fiche envoyée, prix rangé',
    () async {
      expect(await queue.enqueuePrice(f.wine), PriceEnqueue.queued);
      await runUntilDone();
      final req = gateway.lastPriceRequest!;
      expect(req.domain, 'Domaine Test');
      expect(req.cuvee, 'Les Essais');
      expect(req.vintage, 2019);
      expect(req.colour, 'rouge');
      expect(req.formatCl, 75);
      expect(req.force, false);
      final p = (await prices()).single;
      expect(p.trouve, true);
      expect(p.prix, 25.0);
      expect(p.nbOffres, 2);
      expect(p.url, 'https://exemple-caviste-a.fr/produit/1');
      // Le statut d'enrichissement de la fiche n'est pas touché par un relevé.
      final w = await (f.db.select(
        f.db.wines,
      )..where((w) => w.id.equals(f.wine))).getSingle();
      expect(w.statutEnrichissement, isNot('erreur'));
    },
  );

  test(
    'PRX-03 un relevé par 24 heures sauf forcer, historique jamais écrasé',
    () async {
      await queue.enqueuePrice(f.wine);
      await runUntilDone();
      now = now.add(const Duration(hours: 2));
      expect(await queue.enqueuePrice(f.wine), PriceEnqueue.tooRecent);
      expect(
        await queue.enqueuePrice(f.wine, force: true),
        PriceEnqueue.queued,
      );
      expect(
        await queue.enqueuePrice(f.wine, force: true),
        PriceEnqueue.alreadyQueued,
      );
      await runUntilDone();
      expect(
        gateway.lastPriceRequest!.force,
        true,
        reason: 'forcer transmis au flux',
      );
      expect((await prices()).length, 2);
      now = now.add(const Duration(hours: 25));
      expect(await queue.enqueuePrice(f.wine), PriceEnqueue.queued);
    },
  );

  test('PRX-04 prix introuvable enregistré « non trouvé » avec la date, jamais estimé', () async {
    final e = example('prix-termine.json');
    gateway.finalJson = {
      ...e,
      'resultat': {
        'prix': [
          {
            'format_cl': 75,
            'trouve': false,
            'prix': null,
            'devise': 'EUR',
            'date': '2026-11-20',
            'motif': 'Aucun site marchand vérifié n\'est encore actif.',
          },
        ],
        'alertes': [],
        'sources_consultees': [],
      },
    };
    await queue.enqueuePrice(f.wine);
    await runUntilDone();
    final p = (await prices()).single;
    expect(p.trouve, false);
    expect(p.prix, isNull);
    expect(p.dateReleve, '2026-11-20');
  });

  test(
    'PRX-02 toute la cave : décompte avant envoi, fiches récentes écartées',
    () async {
      expect(await queue.countPricesToRefresh(), 1);
      expect(await queue.enqueueAllPrices(), 1);
      await runUntilDone();
      expect(await queue.countPricesToRefresh(), 0);
      expect(await queue.enqueueAllPrices(), 0);
      expect(
        await queue.lastKnownPricesLeft(),
        isNull,
        reason: 'exemple sans quota',
      );
    },
  );

  test('PRX-05 tendance et courbe : relevés trouvés seulement', () {
    MarketPriceView v(String d, double? p) =>
        MarketPriceView(date: d, formatCl: 75, found: p != null, price: p);
    final h = [v('2026-01-01', 20), v('2026-02-01', null), v('2026-03-01', 25)];
    expect(priceTrend(h), closeTo(0.25, 1e-9));
    expect(priceSeries(h), [20, 25]);
    expect(priceTrend([v('2026-01-01', 20)]), isNull);
    expect(priceTrend([v('2026-01-01', null), v('2026-02-01', null)]), isNull);
  });

  test(
    'PRX-06 rafraîchissement mensuel : désactivé par défaut, tous les 30 jours',
    () {
      final t = DateTime.utc(2026, 11, 20);
      expect(autoPriceRefreshDue(enabled: false, last: null, now: t), false);
      expect(autoPriceRefreshDue(enabled: true, last: null, now: t), true);
      expect(
        autoPriceRefreshDue(
          enabled: true,
          last: t.subtract(const Duration(days: 29)),
          now: t,
        ),
        false,
      );
      expect(
        autoPriceRefreshDue(
          enabled: true,
          last: t.subtract(const Duration(days: 30)),
          now: t,
        ),
        true,
      );
    },
  );
}
