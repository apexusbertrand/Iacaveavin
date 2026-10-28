/// AJO-13 : cadre de l'étiquette dans une photo, en fractions de l'image
/// (contrat 1.1, `resultat.cadrages`). Fonctions pures, sans Flutter.
library;

import 'dart:convert';
import 'dart:math' as math;

/// Côté minimal d'un cadre, en fraction de l'image (même borne que le flux).
const minFrameSide = 0.1;

/// Types de photo de la bouteille, envoyés au flux (requete-enrichissement).
const bottlePhotoTypes = {
  'etiquette',
  'contre_etiquette',
  'capsule',
  'collerette',
  'autre',
};

/// FIC-11 : photos de la bibliothèque, jamais envoyées au flux.
const libraryPhotoTypes = ['degustation', 'repas', 'evenement'];

bool isLibraryPhoto(String type) => libraryPhotoTypes.contains(type);

class PhotoFrame {
  const PhotoFrame({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  /// Photo entière.
  static const full = PhotoFrame(x: 0, y: 0, width: 1, height: 1);

  factory PhotoFrame.fromJson(Map<String, dynamic> j) => PhotoFrame(
    x: (j['x'] as num).toDouble(),
    y: (j['y'] as num).toDouble(),
    width: (j['largeur'] as num).toDouble(),
    height: (j['hauteur'] as num).toDouble(),
  ).clamped();

  static PhotoFrame? decode(String? text) => text == null || text.isEmpty
      ? null
      : PhotoFrame.fromJson(jsonDecode(text) as Map<String, dynamic>);

  final double x;
  final double y;
  final double width;
  final double height;

  bool get isFull => x <= 0 && y <= 0 && width >= 1 && height >= 1;

  /// Cadre ramené dans l'image, côtés d'au moins [minFrameSide].
  PhotoFrame clamped() {
    final w = width.clamp(minFrameSide, 1.0);
    final h = height.clamp(minFrameSide, 1.0);
    return PhotoFrame(
      x: x.clamp(0.0, 1 - w),
      y: y.clamp(0.0, 1 - h),
      width: w,
      height: h,
    );
  }

  /// Rectangle en pixels dans une image de [w] × [h].
  ({int left, int top, int width, int height}) toPixels(int w, int h) {
    final left = (x * w).round().clamp(0, w - 1);
    final top = (y * h).round().clamp(0, h - 1);
    return (
      left: left,
      top: top,
      width: math.max(1, math.min((width * w).round(), w - left)),
      height: math.max(1, math.min((height * h).round(), h - top)),
    );
  }

  Map<String, Object> toJson() => {
    'x': x,
    'y': y,
    'largeur': width,
    'hauteur': height,
  };

  String encode() => jsonEncode(toJson());

  @override
  bool operator ==(Object other) =>
      other is PhotoFrame &&
      (other.x - x).abs() < 1e-9 &&
      (other.y - y).abs() < 1e-9 &&
      (other.width - width).abs() < 1e-9 &&
      (other.height - height).abs() < 1e-9;

  @override
  int get hashCode => Object.hash(x, y, width, height);

  @override
  String toString() => 'PhotoFrame($x, $y, $width, $height)';
}

/// Cadre proposé par le flux pour la photo d'index [index] (0 à 3) ;
/// [frame] null : aucune étiquette identifiable, la photo reste entière.
class LabelFrame {
  const LabelFrame({required this.index, this.frame});

  factory LabelFrame.fromJson(Map<String, dynamic> j) => LabelFrame(
    index: (j['index'] as num).toInt(),
    frame: j['cadre'] == null
        ? null
        : PhotoFrame.fromJson(j['cadre'] as Map<String, dynamic>),
  );

  final int index;
  final PhotoFrame? frame;
}
