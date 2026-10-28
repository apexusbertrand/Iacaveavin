import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/domain/vintage_reading.dart';

void main() {
  const year = 2026;

  test('AJO-14 millésime trouvé dans le texte de l\'étiquette', () {
    // Étiquette de la recette du 2026-10-28.
    const label =
        'Cave Historique 1395\nHospices de Strasbourg\n2015\nVin d\'Alsace\nPINOT GRIS';
    expect(vintageCandidates(label, currentYear: year), [2015]);
    expect(vintageFromText(label, currentYear: year), 2015);
  });

  test('AJO-14 dates de fondation, degrés, volumes et futur écartés', () {
    expect(
      vintageCandidates(
        'Domaine familial depuis 1919 · Fondé en 1880 · © 2024 Maison X\n'
        '13,5% vol · 750 ml · 2030 · 20150 · 2018',
        currentYear: year,
      ),
      [2018],
    );
    expect(vintageCandidates('Lot L2015/3', currentYear: year), isEmpty);
    expect(vintageCandidates('12.2019', currentYear: year), isEmpty);
  });

  test('AJO-14 photo : année dominante, ou rien si deux années à égalité', () {
    expect(vintageFromText('2016 · 2016 · 2012', currentYear: year), 2016);
    expect(vintageFromText('2016 · 2012', currentYear: year), isNull);
    expect(vintageFromText('Pinot Noir', currentYear: year), isNull);
  });

  test('AJO-14 à la volée : la même année lue seule deux fois de suite', () {
    final vote = VintageVote();
    expect(vote.add([2015]), isNull);
    expect(vote.current, 2015);
    expect(vote.add([2015, 2018]), isNull, reason: 'image ambiguë');
    expect(vote.add([2015]), isNull, reason: 'série recommencée');
    expect(vote.add([2015, 2015]), 2015);
    final other = VintageVote();
    other.add([2014]);
    expect(other.add([2015]), isNull, reason: 'lecture qui change');
    expect(other.add([2015]), 2015);
  });
}
