/// Contrat app ↔ flux n8n (specs/contrat-n8n/), côté domaine.
///
/// Les objets sont construits uniquement à partir d'une réponse déjà validée
/// contre reponse-job.schema.json (AJO-12) : le parsing ne revérifie pas les
/// règles du schéma.
library;

import 'dart:convert';

import 'photo_frame.dart';

/// 1.1 : cadre de l'étiquette par photo (`resultat.cadrages`, AJO-13).
/// 1.2 : valeurs signalées fausses jointes à la requête (`signalements`,
/// PRV-R4).
const contractVersion = '1.2';

enum JobStatus {
  pending('en_attente'),
  running('en_cours'),
  done('termine'),
  partial('partiel'),
  error('erreur');

  const JobStatus(this.code);

  final String code;

  bool get isFinal => this == done || this == partial || this == error;

  static JobStatus fromCode(String? code) =>
      values.firstWhere((s) => s.code == code, orElse: () => error);
}

/// Étapes affichées en clair pendant l'attente (AJO-05).
const jobSteps = [
  'lecture_etiquette',
  'normalisation',
  'identification',
  'enrichissement',
  'notes',
  'prix',
  'controles',
  'termine',
];

/// Valeur proposée par l'agent, avec sa provenance.
class ProposedValue {
  const ProposedValue({
    required this.value,
    this.source,
    this.url,
    this.confidence,
    this.reason,
    this.note,
  });

  factory ProposedValue.fromJson(Map<String, dynamic> j) => ProposedValue(
    value: j['valeur'],
    source: j['source'] as String?,
    url: j['url'] as String?,
    confidence: (j['confiance'] as num?)?.toDouble(),
    reason: j['motif'] as String?,
    note: j['note'] as String?,
  );

  /// null : rien de trouvé, [reason] dit pourquoi.
  final Object? value;
  final String? source;
  final String? url;
  final double? confidence;
  final String? reason;
  final String? note;

  bool get isEmpty => value == null;

  /// AJO-06 : confiance sous 0,6 surlignée.
  bool get lowConfidence => confidence != null && confidence! < 0.6;

  Map<String, Object?> toJson() => {
    'valeur': value,
    'source': source,
    'url': url,
    'confiance': confidence,
    'motif': reason,
    'note': note,
  };
}

class ProposedScore {
  const ProposedScore({
    required this.critic,
    required this.score,
    required this.scale,
    required this.access,
    required this.url,
    required this.confidence,
    this.taster,
    this.date,
    this.windowStart,
    this.windowEnd,
    this.citedBy,
  });

  factory ProposedScore.fromJson(Map<String, dynamic> j) {
    final window = j['fenetre'] as Map<String, dynamic>?;
    return ProposedScore(
      critic: j['source_critique'] as String,
      score: (j['note'] as num).toDouble(),
      scale: (j['echelle'] as num).toInt(),
      access: j['acces'] as String,
      url: j['url'] as String,
      confidence: (j['confiance'] as num).toDouble(),
      taster: j['degustateur'] as String?,
      date: j['date_note'] as String?,
      windowStart: (window?['debut'] as num?)?.toInt(),
      windowEnd: (window?['fin'] as num?)?.toInt(),
      citedBy: j['citee_par'] as String?,
    );
  }

  final String critic;
  final double score;
  final int scale;

  /// `libre` ou `citee` (NOT-R3).
  final String access;
  final String url;
  final double confidence;
  final String? taster;
  final String? date;
  final int? windowStart;
  final int? windowEnd;
  final String? citedBy;
}

class PriceOffer {
  const PriceOffer({
    required this.site,
    required this.url,
    required this.price,
  });

  final String site;
  final String url;
  final double price;
}

class ProposedPrice {
  const ProposedPrice({
    required this.formatCl,
    required this.found,
    required this.currency,
    required this.date,
    this.price,
    this.nature,
    this.offers = const [],
    this.offerCount,
    this.site,
    this.url,
    this.reason,
  });

  factory ProposedPrice.fromJson(Map<String, dynamic> j) => ProposedPrice(
    formatCl: (j['format_cl'] as num).toDouble(),
    found: j['trouve'] as bool,
    currency: j['devise'] as String,
    date: j['date'] as String,
    price: (j['prix'] as num?)?.toDouble(),
    nature: j['nature'] as String?,
    offerCount: (j['nb_offres'] as num?)?.toInt(),
    offers: [
      for (final o
          in (j['offres'] as List? ?? const []).cast<Map<String, dynamic>>())
        PriceOffer(
          site: o['site'] as String,
          url: o['url'] as String,
          price: (o['prix'] as num).toDouble(),
        ),
    ],
    site: j['site'] as String?,
    url: j['url'] as String?,
    reason: j['motif'] as String?,
  );

  final double formatCl;
  final bool found;
  final String currency;
  final String date;
  final double? price;
  final String? nature;
  final List<PriceOffer> offers;
  final int? offerCount;
  final String? site;
  final String? url;
  final String? reason;
}

class EnrichmentAlert {
  const EnrichmentAlert({
    required this.code,
    required this.message,
    this.field,
  });

  final String code;
  final String message;
  final String? field;
}

/// Résultat d'un enrichissement : champs de la fiche (noms du contrat),
/// notes, prix et alertes.
class EnrichmentResult {
  const EnrichmentResult({
    required this.fields,
    this.scores = const [],
    this.prices = const [],
    this.alerts = const [],
    this.cacheHit = false,
    this.frames = const [],
  });

  factory EnrichmentResult.fromJson(Map<String, dynamic> j) => EnrichmentResult(
    fields: {
      for (final e in (j['fiche'] as Map<String, dynamic>? ?? const {}).entries)
        e.key: ProposedValue.fromJson(e.value as Map<String, dynamic>),
    },
    scores: [
      for (final s
          in (j['notes_critiques'] as List? ?? const [])
              .cast<Map<String, dynamic>>())
        ProposedScore.fromJson(s),
    ],
    prices: [
      for (final p
          in (j['prix'] as List? ?? const []).cast<Map<String, dynamic>>())
        ProposedPrice.fromJson(p),
    ],
    alerts: [
      for (final a
          in (j['alertes'] as List? ?? const []).cast<Map<String, dynamic>>())
        EnrichmentAlert(
          code: a['code'] as String,
          message: a['message'] as String,
          field: a['champ'] as String?,
        ),
    ],
    cacheHit: (j['cache'] as Map?)?['hit'] == true,
    frames: [
      for (final c
          in (j['cadrages'] as List? ?? const []).cast<Map<String, dynamic>>())
        LabelFrame.fromJson(c),
    ],
  );

  final Map<String, ProposedValue> fields;
  final List<ProposedScore> scores;
  final List<ProposedPrice> prices;
  final List<EnrichmentAlert> alerts;
  final bool cacheHit;

  /// AJO-13 : cadre de l'étiquette par photo envoyée (contrat 1.1).
  final List<LabelFrame> frames;

  /// AJO-06 : champs en désaccord entre l'étiquette et une source.
  Set<String> get disagreements => {
    for (final a in alerts)
      if (a.code == 'desaccord_etiquette_source' && a.field != null) a.field!,
  };
}

class JobError {
  const JobError({
    required this.code,
    required this.message,
    this.retryable = true,
  });

  final String code;
  final String message;
  final bool retryable;
}

/// Réponse du flux (création ou suivi d'un job).
class JobResponse {
  const JobResponse({
    required this.jobId,
    required this.requestId,
    required this.type,
    required this.status,
    required this.raw,
    this.wineId,
    this.step,
    this.enrichmentsLeft,
    this.pricesLeft,
    this.result,
    this.prices = const [],
    this.error,
  });

  factory JobResponse.fromJson(Map<String, dynamic> j) {
    final quota = j['quota'] as Map<String, dynamic>?;
    final err = j['erreur'] as Map<String, dynamic>?;
    final type = j['type'] as String;
    return JobResponse(
      jobId: j['job_id'] as String,
      requestId: j['request_id'] as String,
      wineId: j['fiche_id'] as String?,
      type: type,
      status: JobStatus.fromCode(j['statut'] as String?),
      step: j['etape'] as String?,
      enrichmentsLeft: (quota?['enrichissements_restants_mois'] as num?)
          ?.toInt(),
      pricesLeft: (quota?['prix_restants_mois'] as num?)?.toInt(),
      result: type == 'enrichissement' && j['resultat'] is Map
          ? EnrichmentResult.fromJson(j['resultat'] as Map<String, dynamic>)
          : null,
      prices: type == 'prix' && j['resultat'] is Map
          ? [
              for (final p
                  in ((j['resultat'] as Map)['prix'] as List? ?? const [])
                      .cast<Map<String, dynamic>>())
                ProposedPrice.fromJson(p),
            ]
          : const [],
      error: err == null
          ? null
          : JobError(
              code: err['code'] as String,
              message: err['message'] as String,
              retryable: err['reessayable'] != false,
            ),
      raw: j,
    );
  }

  final String jobId;
  final String requestId;
  final String? wineId;
  final String type;
  final JobStatus status;
  final String? step;
  final int? enrichmentsLeft;
  final int? pricesLeft;
  final EnrichmentResult? result;

  /// Relevé d'un job de type `prix` (resultat_prix).
  final List<ProposedPrice> prices;
  final JobError? error;
  final Map<String, dynamic> raw;
}

/// POST /prix (requete-prix.schema.json) : identité déjà normalisée de la
/// fiche, aucune photo.
class PriceRequest {
  const PriceRequest({
    required this.requestId,
    required this.wineId,
    required this.domain,
    required this.vintage,
    required this.colour,
    required this.formatCl,
    required this.currency,
    required this.clientDate,
    this.cuvee,
    this.appellation,
    this.lwin,
    this.ean,
    this.force = false,
  });

  final String requestId;
  final String wineId;
  final String domain;

  /// Année ou « NM ».
  final Object vintage;
  final String colour;
  final double formatCl;
  final String currency;
  final String clientDate;
  final String? cuvee;
  final String? appellation;
  final String? lwin;
  final String? ean;

  /// PRX-03 : ignorer le cache de 24 heures.
  final bool force;

  Map<String, Object?> toJson() => {
    'version_contrat': contractVersion,
    'request_id': requestId,
    'fiche_id': wineId,
    'identite': {
      'domaine': domain,
      'cuvee': cuvee,
      'appellation': appellation,
      'millesime': vintage,
      'couleur': colour,
      'lwin': lwin,
      'ean': ean,
    },
    'format_cl': formatCl,
    'devise': currency,
    'forcer': force,
    'date_client': clientDate,
  };
}

/// AJO-11 : quota affiché quand il passe sous 20 % du quota mensuel (T10).
const monthlyEnrichmentQuota = 100;
const monthlyPriceQuota = 120;

bool quotaLow(int? left, int monthly) => left != null && left < monthly * 0.2;

/// Photo envoyée au flux (déjà compressée, 1 500 px, qualité 80).
class RequestPhoto {
  const RequestPhoto({
    required this.index,
    required this.type,
    required this.base64,
    this.mime = 'image/jpeg',
  });

  final int index;
  final String type;
  final String base64;
  final String mime;
}

/// PRV-R4 : une valeur signalée fausse, telle qu'affichée.
class ReportedValue {
  const ReportedValue(this.field, this.value);

  /// Nom du champ dans le contrat (`cepages`, `region`...).
  final String field;
  final String value;

  /// Texte lisible d'une valeur de provenance (JSON enregistré à
  /// l'enrichissement), 500 caractères au plus ; null si vide.
  static String? textOf(String? json) {
    if (json == null) return null;
    Object? v;
    try {
      v = jsonDecode(json);
    } on FormatException {
      v = json;
    }
    String part(Object? x) => switch (x) {
      {'cepage': final String c, 'pourcentage': final num p} => '$c ${_n(p)} %',
      {'cepage': final String c} => c,
      {'debut': final Object d, 'fin': final Object f} => '$d-$f',
      final List<Object?> l =>
        l.map(part).where((s) => s.isNotEmpty).join(', '),
      null => '',
      _ => '$x',
    };
    final t = part(v).trim();
    if (t.isEmpty) return null;
    return t.length > 500 ? t.substring(0, 500) : t;
  }

  static String _n(num p) => p == p.roundToDouble() ? '${p.toInt()}' : '$p';
}

/// 20 signalements au plus par requête (contrat 1.2).
const maxReports = 20;

/// POST /enrichissement (requete-enrichissement.schema.json).
class EnrichmentRequest {
  const EnrichmentRequest({
    required this.requestId,
    required this.photos,
    required this.clientDate,
    this.wineId,
    this.ean,
    this.vintageHint,
    this.formatCl,
    this.freeText,
    this.lockedFields = const [],
    this.reports = const [],
    this.includePrices = true,
  });

  final String requestId;
  final String? wineId;
  final List<RequestPhoto> photos;

  /// PRV-R4 : valeurs signalées fausses sur cette fiche (contrat 1.2).
  final List<ReportedValue> reports;

  /// AJO-10 : indice d'identification, jamais une clé.
  final String? ean;
  final Object? vintageHint;
  final double? formatCl;
  final String? freeText;

  /// PRV-R2 : champs saisis ou corrigés à la main (noms du contrat).
  final List<String> lockedFields;
  final bool includePrices;

  /// Date du jour côté téléphone (AAAA-MM-JJ).
  final String clientDate;

  Map<String, Object?> toJson() {
    final indices = <String, Object?>{
      if (ean != null) 'ean': ean,
      if (vintageHint != null) 'millesime': vintageHint,
      if (formatCl != null) 'format_cl': formatCl,
      if (freeText != null && freeText!.isNotEmpty) 'texte_libre': freeText,
    };
    return {
      'version_contrat': contractVersion,
      'request_id': requestId,
      if (wineId != null) 'fiche_id': wineId,
      'photos': [
        for (final p in photos)
          {
            'index': p.index,
            'type_photo': p.type,
            'mime': p.mime,
            'base64': p.base64,
          },
      ],
      if (indices.isNotEmpty) 'indices': indices,
      'champs_verrouilles': lockedFields.toSet().toList(),
      if (reports.isNotEmpty)
        'signalements': [
          for (final r in reports.take(maxReports))
            {'champ': r.field, 'valeur': r.value},
        ],
      'inclure_prix': includePrices,
      'langue': 'fr',
      'date_client': clientDate,
    };
  }
}

/// Correspondance entre champs du contrat et clés du dictionnaire
/// (clé `contrat` du dictionnaire) : (entité, clé).
const contractFieldMap = <String, (String, String)>{
  'domaine': ('domaine', 'nom'),
  'domaine_site_officiel': ('domaine', 'site_officiel'),
  'commentaire_domaine': ('domaine', 'commentaire'),
  'cuvee': ('cuvee', 'nom'),
  'pays': ('cuvee', 'pays'),
  'region': ('cuvee', 'region'),
  'sous_region': ('cuvee', 'sous_region'),
  'appellation': ('cuvee', 'appellation'),
  'signe_qualite': ('cuvee', 'signe_qualite'),
  'classement': ('cuvee', 'classement'),
  'lieu_dit': ('cuvee', 'lieu_dit'),
  'couleur': ('cuvee', 'couleur'),
  'type': ('cuvee', 'type_vin'),
  'certification': ('cuvee', 'certification'),
  'millesime': ('fiche_vin', 'millesime'),
  'cepages': ('fiche_vin', 'cepages'),
  'degre': ('fiche_vin', 'degre'),
  'commentaire_millesime': ('fiche_vin', 'commentaire_millesime'),
  'garde': ('fiche_vin', 'garde'),
  'accords': ('fiche_vin', 'accords'),
  'lwin': ('fiche_vin', 'lwin'),
};
