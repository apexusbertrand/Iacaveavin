import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/core/features.dart';
import 'package:iacaveavin/domain/enrichment.dart';

void main() {
  test('PRX-08 relevé automatique des prix suspendu', () {
    expect(marketPriceLookup, isFalse);
    // La requête d'identification ne demande plus de prix au flux.
    const r = EnrichmentRequest(
      requestId: '8e2d3b0f-6c4a-4f7b-9d3e-2a1f0b9c8d7e',
      wineId: '3c9e1f4a-2b7d-4e8f-a1c3-5d6e7f8a9b0c',
      photos: [],
      clientDate: '2026-11-15',
      includePrices: marketPriceLookup,
    );
    expect(r.toJson()['inclure_prix'], isFalse);
  });
}
