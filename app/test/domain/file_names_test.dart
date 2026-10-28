import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/domain/file_names.dart';

void main() {
  test('PDF-01 fichier de la fiche nommé d\'après le vin', () {
    expect(
      wineFileBase(
        producer: 'Cave Historique des Hospices de Strasbourg',
        cuvee: 'Pinot Gris',
        vintage: '2015',
      ),
      'Cave Historique des Hospices de Strasbourg - Pinot Gris - 2015',
    );
    expect(
      wineFileBase(producer: 'Mas Apogee', cuvee: '', vintage: '2018'),
      'Mas Apogee - 2018',
    );
    // Caractères interdits dans un nom de fichier remplacés.
    expect(
      wineFileBase(producer: 'Château A/B: "Réserve"?', vintage: 'NM'),
      'Château A B Réserve - NM',
    );
    // 80 caractères au plus, jamais vide.
    expect(wineFileBase(producer: 'x' * 200).length, 80);
    expect(wineFileBase(producer: ' / '), 'fiche');
  });
}
