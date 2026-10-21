// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CellarsTable extends Cellars with TableInfo<$CellarsTable, Cellar> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CellarsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
    'nom',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviseMeta = const VerificationMeta('devise');
  @override
  late final GeneratedColumn<String> devise = GeneratedColumn<String>(
    'devise',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('EUR'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    nom,
    devise,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cave';
  @override
  VerificationContext validateIntegrity(
    Insertable<Cellar> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('nom')) {
      context.handle(
        _nomMeta,
        nom.isAcceptableOrUnknown(data['nom']!, _nomMeta),
      );
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('devise')) {
      context.handle(
        _deviseMeta,
        devise.isAcceptableOrUnknown(data['devise']!, _deviseMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Cellar map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Cellar(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      nom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nom'],
      )!,
      devise: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}devise'],
      )!,
    );
  }

  @override
  $CellarsTable createAlias(String alias) {
    return $CellarsTable(attachedDatabase, alias);
  }
}

class Cellar extends DataClass implements Insertable<Cellar> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String nom;
  final String devise;
  const Cellar({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.nom,
    required this.devise,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['nom'] = Variable<String>(nom);
    map['devise'] = Variable<String>(devise);
    return map;
  }

  CellarsCompanion toCompanion(bool nullToAbsent) {
    return CellarsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      nom: Value(nom),
      devise: Value(devise),
    );
  }

  factory Cellar.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Cellar(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      nom: serializer.fromJson<String>(json['nom']),
      devise: serializer.fromJson<String>(json['devise']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'nom': serializer.toJson<String>(nom),
      'devise': serializer.toJson<String>(devise),
    };
  }

  Cellar copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? nom,
    String? devise,
  }) => Cellar(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    nom: nom ?? this.nom,
    devise: devise ?? this.devise,
  );
  Cellar copyWithCompanion(CellarsCompanion data) {
    return Cellar(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      nom: data.nom.present ? data.nom.value : this.nom,
      devise: data.devise.present ? data.devise.value : this.devise,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Cellar(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('nom: $nom, ')
          ..write('devise: $devise')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, updatedAt, deletedAt, nom, devise);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cellar &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.nom == this.nom &&
          other.devise == this.devise);
}

class CellarsCompanion extends UpdateCompanion<Cellar> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> nom;
  final Value<String> devise;
  final Value<int> rowid;
  const CellarsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.nom = const Value.absent(),
    this.devise = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CellarsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String nom,
    this.devise = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       nom = Value(nom);
  static Insertable<Cellar> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? nom,
    Expression<String>? devise,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (nom != null) 'nom': nom,
      if (devise != null) 'devise': devise,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CellarsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? nom,
    Value<String>? devise,
    Value<int>? rowid,
  }) {
    return CellarsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      nom: nom ?? this.nom,
      devise: devise ?? this.devise,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (devise.present) {
      map['devise'] = Variable<String>(devise.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CellarsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('nom: $nom, ')
          ..write('devise: $devise, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProducersTable extends Producers
    with TableInfo<$ProducersTable, Producer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProducersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caveIdMeta = const VerificationMeta('caveId');
  @override
  late final GeneratedColumn<String> caveId = GeneratedColumn<String>(
    'cave_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cave (id)',
    ),
  );
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
    'nom',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _siteOfficielMeta = const VerificationMeta(
    'siteOfficiel',
  );
  @override
  late final GeneratedColumn<String> siteOfficiel = GeneratedColumn<String>(
    'site_officiel',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commentaireMeta = const VerificationMeta(
    'commentaire',
  );
  @override
  late final GeneratedColumn<String> commentaire = GeneratedColumn<String>(
    'commentaire',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    caveId,
    nom,
    siteOfficiel,
    commentaire,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'domaine';
  @override
  VerificationContext validateIntegrity(
    Insertable<Producer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('cave_id')) {
      context.handle(
        _caveIdMeta,
        caveId.isAcceptableOrUnknown(data['cave_id']!, _caveIdMeta),
      );
    } else if (isInserting) {
      context.missing(_caveIdMeta);
    }
    if (data.containsKey('nom')) {
      context.handle(
        _nomMeta,
        nom.isAcceptableOrUnknown(data['nom']!, _nomMeta),
      );
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('site_officiel')) {
      context.handle(
        _siteOfficielMeta,
        siteOfficiel.isAcceptableOrUnknown(
          data['site_officiel']!,
          _siteOfficielMeta,
        ),
      );
    }
    if (data.containsKey('commentaire')) {
      context.handle(
        _commentaireMeta,
        commentaire.isAcceptableOrUnknown(
          data['commentaire']!,
          _commentaireMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Producer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Producer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      caveId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cave_id'],
      )!,
      nom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nom'],
      )!,
      siteOfficiel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_officiel'],
      ),
      commentaire: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}commentaire'],
      ),
    );
  }

  @override
  $ProducersTable createAlias(String alias) {
    return $ProducersTable(attachedDatabase, alias);
  }
}

class Producer extends DataClass implements Insertable<Producer> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String caveId;
  final String nom;
  final String? siteOfficiel;
  final String? commentaire;
  const Producer({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.caveId,
    required this.nom,
    this.siteOfficiel,
    this.commentaire,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['cave_id'] = Variable<String>(caveId);
    map['nom'] = Variable<String>(nom);
    if (!nullToAbsent || siteOfficiel != null) {
      map['site_officiel'] = Variable<String>(siteOfficiel);
    }
    if (!nullToAbsent || commentaire != null) {
      map['commentaire'] = Variable<String>(commentaire);
    }
    return map;
  }

  ProducersCompanion toCompanion(bool nullToAbsent) {
    return ProducersCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      caveId: Value(caveId),
      nom: Value(nom),
      siteOfficiel: siteOfficiel == null && nullToAbsent
          ? const Value.absent()
          : Value(siteOfficiel),
      commentaire: commentaire == null && nullToAbsent
          ? const Value.absent()
          : Value(commentaire),
    );
  }

  factory Producer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Producer(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      caveId: serializer.fromJson<String>(json['caveId']),
      nom: serializer.fromJson<String>(json['nom']),
      siteOfficiel: serializer.fromJson<String?>(json['siteOfficiel']),
      commentaire: serializer.fromJson<String?>(json['commentaire']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'caveId': serializer.toJson<String>(caveId),
      'nom': serializer.toJson<String>(nom),
      'siteOfficiel': serializer.toJson<String?>(siteOfficiel),
      'commentaire': serializer.toJson<String?>(commentaire),
    };
  }

  Producer copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? caveId,
    String? nom,
    Value<String?> siteOfficiel = const Value.absent(),
    Value<String?> commentaire = const Value.absent(),
  }) => Producer(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    caveId: caveId ?? this.caveId,
    nom: nom ?? this.nom,
    siteOfficiel: siteOfficiel.present ? siteOfficiel.value : this.siteOfficiel,
    commentaire: commentaire.present ? commentaire.value : this.commentaire,
  );
  Producer copyWithCompanion(ProducersCompanion data) {
    return Producer(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      caveId: data.caveId.present ? data.caveId.value : this.caveId,
      nom: data.nom.present ? data.nom.value : this.nom,
      siteOfficiel: data.siteOfficiel.present
          ? data.siteOfficiel.value
          : this.siteOfficiel,
      commentaire: data.commentaire.present
          ? data.commentaire.value
          : this.commentaire,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Producer(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('caveId: $caveId, ')
          ..write('nom: $nom, ')
          ..write('siteOfficiel: $siteOfficiel, ')
          ..write('commentaire: $commentaire')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    caveId,
    nom,
    siteOfficiel,
    commentaire,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Producer &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.caveId == this.caveId &&
          other.nom == this.nom &&
          other.siteOfficiel == this.siteOfficiel &&
          other.commentaire == this.commentaire);
}

class ProducersCompanion extends UpdateCompanion<Producer> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> caveId;
  final Value<String> nom;
  final Value<String?> siteOfficiel;
  final Value<String?> commentaire;
  final Value<int> rowid;
  const ProducersCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.caveId = const Value.absent(),
    this.nom = const Value.absent(),
    this.siteOfficiel = const Value.absent(),
    this.commentaire = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProducersCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String caveId,
    required String nom,
    this.siteOfficiel = const Value.absent(),
    this.commentaire = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       caveId = Value(caveId),
       nom = Value(nom);
  static Insertable<Producer> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? caveId,
    Expression<String>? nom,
    Expression<String>? siteOfficiel,
    Expression<String>? commentaire,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (caveId != null) 'cave_id': caveId,
      if (nom != null) 'nom': nom,
      if (siteOfficiel != null) 'site_officiel': siteOfficiel,
      if (commentaire != null) 'commentaire': commentaire,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProducersCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? caveId,
    Value<String>? nom,
    Value<String?>? siteOfficiel,
    Value<String?>? commentaire,
    Value<int>? rowid,
  }) {
    return ProducersCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      caveId: caveId ?? this.caveId,
      nom: nom ?? this.nom,
      siteOfficiel: siteOfficiel ?? this.siteOfficiel,
      commentaire: commentaire ?? this.commentaire,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (caveId.present) {
      map['cave_id'] = Variable<String>(caveId.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (siteOfficiel.present) {
      map['site_officiel'] = Variable<String>(siteOfficiel.value);
    }
    if (commentaire.present) {
      map['commentaire'] = Variable<String>(commentaire.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProducersCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('caveId: $caveId, ')
          ..write('nom: $nom, ')
          ..write('siteOfficiel: $siteOfficiel, ')
          ..write('commentaire: $commentaire, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CuveesTable extends Cuvees with TableInfo<$CuveesTable, Cuvee> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CuveesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caveIdMeta = const VerificationMeta('caveId');
  @override
  late final GeneratedColumn<String> caveId = GeneratedColumn<String>(
    'cave_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cave (id)',
    ),
  );
  static const VerificationMeta _domaineIdMeta = const VerificationMeta(
    'domaineId',
  );
  @override
  late final GeneratedColumn<String> domaineId = GeneratedColumn<String>(
    'domaine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES domaine (id)',
    ),
  );
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
    'nom',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paysMeta = const VerificationMeta('pays');
  @override
  late final GeneratedColumn<String> pays = GeneratedColumn<String>(
    'pays',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _regionMeta = const VerificationMeta('region');
  @override
  late final GeneratedColumn<String> region = GeneratedColumn<String>(
    'region',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sousRegionMeta = const VerificationMeta(
    'sousRegion',
  );
  @override
  late final GeneratedColumn<String> sousRegion = GeneratedColumn<String>(
    'sous_region',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _appellationMeta = const VerificationMeta(
    'appellation',
  );
  @override
  late final GeneratedColumn<String> appellation = GeneratedColumn<String>(
    'appellation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _signeQualiteMeta = const VerificationMeta(
    'signeQualite',
  );
  @override
  late final GeneratedColumn<String> signeQualite = GeneratedColumn<String>(
    'signe_qualite',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _classementMeta = const VerificationMeta(
    'classement',
  );
  @override
  late final GeneratedColumn<String> classement = GeneratedColumn<String>(
    'classement',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lieuDitMeta = const VerificationMeta(
    'lieuDit',
  );
  @override
  late final GeneratedColumn<String> lieuDit = GeneratedColumn<String>(
    'lieu_dit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _couleurMeta = const VerificationMeta(
    'couleur',
  );
  @override
  late final GeneratedColumn<String> couleur = GeneratedColumn<String>(
    'couleur',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeVinMeta = const VerificationMeta(
    'typeVin',
  );
  @override
  late final GeneratedColumn<String> typeVin = GeneratedColumn<String>(
    'type_vin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _certificationMeta = const VerificationMeta(
    'certification',
  );
  @override
  late final GeneratedColumn<String> certification = GeneratedColumn<String>(
    'certification',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    caveId,
    domaineId,
    nom,
    pays,
    region,
    sousRegion,
    appellation,
    signeQualite,
    classement,
    lieuDit,
    couleur,
    typeVin,
    certification,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cuvee';
  @override
  VerificationContext validateIntegrity(
    Insertable<Cuvee> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('cave_id')) {
      context.handle(
        _caveIdMeta,
        caveId.isAcceptableOrUnknown(data['cave_id']!, _caveIdMeta),
      );
    } else if (isInserting) {
      context.missing(_caveIdMeta);
    }
    if (data.containsKey('domaine_id')) {
      context.handle(
        _domaineIdMeta,
        domaineId.isAcceptableOrUnknown(data['domaine_id']!, _domaineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_domaineIdMeta);
    }
    if (data.containsKey('nom')) {
      context.handle(
        _nomMeta,
        nom.isAcceptableOrUnknown(data['nom']!, _nomMeta),
      );
    }
    if (data.containsKey('pays')) {
      context.handle(
        _paysMeta,
        pays.isAcceptableOrUnknown(data['pays']!, _paysMeta),
      );
    } else if (isInserting) {
      context.missing(_paysMeta);
    }
    if (data.containsKey('region')) {
      context.handle(
        _regionMeta,
        region.isAcceptableOrUnknown(data['region']!, _regionMeta),
      );
    }
    if (data.containsKey('sous_region')) {
      context.handle(
        _sousRegionMeta,
        sousRegion.isAcceptableOrUnknown(data['sous_region']!, _sousRegionMeta),
      );
    }
    if (data.containsKey('appellation')) {
      context.handle(
        _appellationMeta,
        appellation.isAcceptableOrUnknown(
          data['appellation']!,
          _appellationMeta,
        ),
      );
    }
    if (data.containsKey('signe_qualite')) {
      context.handle(
        _signeQualiteMeta,
        signeQualite.isAcceptableOrUnknown(
          data['signe_qualite']!,
          _signeQualiteMeta,
        ),
      );
    }
    if (data.containsKey('classement')) {
      context.handle(
        _classementMeta,
        classement.isAcceptableOrUnknown(data['classement']!, _classementMeta),
      );
    }
    if (data.containsKey('lieu_dit')) {
      context.handle(
        _lieuDitMeta,
        lieuDit.isAcceptableOrUnknown(data['lieu_dit']!, _lieuDitMeta),
      );
    }
    if (data.containsKey('couleur')) {
      context.handle(
        _couleurMeta,
        couleur.isAcceptableOrUnknown(data['couleur']!, _couleurMeta),
      );
    } else if (isInserting) {
      context.missing(_couleurMeta);
    }
    if (data.containsKey('type_vin')) {
      context.handle(
        _typeVinMeta,
        typeVin.isAcceptableOrUnknown(data['type_vin']!, _typeVinMeta),
      );
    }
    if (data.containsKey('certification')) {
      context.handle(
        _certificationMeta,
        certification.isAcceptableOrUnknown(
          data['certification']!,
          _certificationMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Cuvee map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Cuvee(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      caveId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cave_id'],
      )!,
      domaineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domaine_id'],
      )!,
      nom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nom'],
      ),
      pays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pays'],
      )!,
      region: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region'],
      ),
      sousRegion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sous_region'],
      ),
      appellation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}appellation'],
      ),
      signeQualite: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}signe_qualite'],
      ),
      classement: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}classement'],
      ),
      lieuDit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lieu_dit'],
      ),
      couleur: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}couleur'],
      )!,
      typeVin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_vin'],
      ),
      certification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}certification'],
      ),
    );
  }

  @override
  $CuveesTable createAlias(String alias) {
    return $CuveesTable(attachedDatabase, alias);
  }
}

class Cuvee extends DataClass implements Insertable<Cuvee> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String caveId;
  final String domaineId;
  final String? nom;
  final String pays;
  final String? region;
  final String? sousRegion;
  final String? appellation;
  final String? signeQualite;
  final String? classement;
  final String? lieuDit;
  final String couleur;
  final String? typeVin;
  final String? certification;
  const Cuvee({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.caveId,
    required this.domaineId,
    this.nom,
    required this.pays,
    this.region,
    this.sousRegion,
    this.appellation,
    this.signeQualite,
    this.classement,
    this.lieuDit,
    required this.couleur,
    this.typeVin,
    this.certification,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['cave_id'] = Variable<String>(caveId);
    map['domaine_id'] = Variable<String>(domaineId);
    if (!nullToAbsent || nom != null) {
      map['nom'] = Variable<String>(nom);
    }
    map['pays'] = Variable<String>(pays);
    if (!nullToAbsent || region != null) {
      map['region'] = Variable<String>(region);
    }
    if (!nullToAbsent || sousRegion != null) {
      map['sous_region'] = Variable<String>(sousRegion);
    }
    if (!nullToAbsent || appellation != null) {
      map['appellation'] = Variable<String>(appellation);
    }
    if (!nullToAbsent || signeQualite != null) {
      map['signe_qualite'] = Variable<String>(signeQualite);
    }
    if (!nullToAbsent || classement != null) {
      map['classement'] = Variable<String>(classement);
    }
    if (!nullToAbsent || lieuDit != null) {
      map['lieu_dit'] = Variable<String>(lieuDit);
    }
    map['couleur'] = Variable<String>(couleur);
    if (!nullToAbsent || typeVin != null) {
      map['type_vin'] = Variable<String>(typeVin);
    }
    if (!nullToAbsent || certification != null) {
      map['certification'] = Variable<String>(certification);
    }
    return map;
  }

  CuveesCompanion toCompanion(bool nullToAbsent) {
    return CuveesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      caveId: Value(caveId),
      domaineId: Value(domaineId),
      nom: nom == null && nullToAbsent ? const Value.absent() : Value(nom),
      pays: Value(pays),
      region: region == null && nullToAbsent
          ? const Value.absent()
          : Value(region),
      sousRegion: sousRegion == null && nullToAbsent
          ? const Value.absent()
          : Value(sousRegion),
      appellation: appellation == null && nullToAbsent
          ? const Value.absent()
          : Value(appellation),
      signeQualite: signeQualite == null && nullToAbsent
          ? const Value.absent()
          : Value(signeQualite),
      classement: classement == null && nullToAbsent
          ? const Value.absent()
          : Value(classement),
      lieuDit: lieuDit == null && nullToAbsent
          ? const Value.absent()
          : Value(lieuDit),
      couleur: Value(couleur),
      typeVin: typeVin == null && nullToAbsent
          ? const Value.absent()
          : Value(typeVin),
      certification: certification == null && nullToAbsent
          ? const Value.absent()
          : Value(certification),
    );
  }

  factory Cuvee.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Cuvee(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      caveId: serializer.fromJson<String>(json['caveId']),
      domaineId: serializer.fromJson<String>(json['domaineId']),
      nom: serializer.fromJson<String?>(json['nom']),
      pays: serializer.fromJson<String>(json['pays']),
      region: serializer.fromJson<String?>(json['region']),
      sousRegion: serializer.fromJson<String?>(json['sousRegion']),
      appellation: serializer.fromJson<String?>(json['appellation']),
      signeQualite: serializer.fromJson<String?>(json['signeQualite']),
      classement: serializer.fromJson<String?>(json['classement']),
      lieuDit: serializer.fromJson<String?>(json['lieuDit']),
      couleur: serializer.fromJson<String>(json['couleur']),
      typeVin: serializer.fromJson<String?>(json['typeVin']),
      certification: serializer.fromJson<String?>(json['certification']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'caveId': serializer.toJson<String>(caveId),
      'domaineId': serializer.toJson<String>(domaineId),
      'nom': serializer.toJson<String?>(nom),
      'pays': serializer.toJson<String>(pays),
      'region': serializer.toJson<String?>(region),
      'sousRegion': serializer.toJson<String?>(sousRegion),
      'appellation': serializer.toJson<String?>(appellation),
      'signeQualite': serializer.toJson<String?>(signeQualite),
      'classement': serializer.toJson<String?>(classement),
      'lieuDit': serializer.toJson<String?>(lieuDit),
      'couleur': serializer.toJson<String>(couleur),
      'typeVin': serializer.toJson<String?>(typeVin),
      'certification': serializer.toJson<String?>(certification),
    };
  }

  Cuvee copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? caveId,
    String? domaineId,
    Value<String?> nom = const Value.absent(),
    String? pays,
    Value<String?> region = const Value.absent(),
    Value<String?> sousRegion = const Value.absent(),
    Value<String?> appellation = const Value.absent(),
    Value<String?> signeQualite = const Value.absent(),
    Value<String?> classement = const Value.absent(),
    Value<String?> lieuDit = const Value.absent(),
    String? couleur,
    Value<String?> typeVin = const Value.absent(),
    Value<String?> certification = const Value.absent(),
  }) => Cuvee(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    caveId: caveId ?? this.caveId,
    domaineId: domaineId ?? this.domaineId,
    nom: nom.present ? nom.value : this.nom,
    pays: pays ?? this.pays,
    region: region.present ? region.value : this.region,
    sousRegion: sousRegion.present ? sousRegion.value : this.sousRegion,
    appellation: appellation.present ? appellation.value : this.appellation,
    signeQualite: signeQualite.present ? signeQualite.value : this.signeQualite,
    classement: classement.present ? classement.value : this.classement,
    lieuDit: lieuDit.present ? lieuDit.value : this.lieuDit,
    couleur: couleur ?? this.couleur,
    typeVin: typeVin.present ? typeVin.value : this.typeVin,
    certification: certification.present
        ? certification.value
        : this.certification,
  );
  Cuvee copyWithCompanion(CuveesCompanion data) {
    return Cuvee(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      caveId: data.caveId.present ? data.caveId.value : this.caveId,
      domaineId: data.domaineId.present ? data.domaineId.value : this.domaineId,
      nom: data.nom.present ? data.nom.value : this.nom,
      pays: data.pays.present ? data.pays.value : this.pays,
      region: data.region.present ? data.region.value : this.region,
      sousRegion: data.sousRegion.present
          ? data.sousRegion.value
          : this.sousRegion,
      appellation: data.appellation.present
          ? data.appellation.value
          : this.appellation,
      signeQualite: data.signeQualite.present
          ? data.signeQualite.value
          : this.signeQualite,
      classement: data.classement.present
          ? data.classement.value
          : this.classement,
      lieuDit: data.lieuDit.present ? data.lieuDit.value : this.lieuDit,
      couleur: data.couleur.present ? data.couleur.value : this.couleur,
      typeVin: data.typeVin.present ? data.typeVin.value : this.typeVin,
      certification: data.certification.present
          ? data.certification.value
          : this.certification,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Cuvee(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('caveId: $caveId, ')
          ..write('domaineId: $domaineId, ')
          ..write('nom: $nom, ')
          ..write('pays: $pays, ')
          ..write('region: $region, ')
          ..write('sousRegion: $sousRegion, ')
          ..write('appellation: $appellation, ')
          ..write('signeQualite: $signeQualite, ')
          ..write('classement: $classement, ')
          ..write('lieuDit: $lieuDit, ')
          ..write('couleur: $couleur, ')
          ..write('typeVin: $typeVin, ')
          ..write('certification: $certification')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    caveId,
    domaineId,
    nom,
    pays,
    region,
    sousRegion,
    appellation,
    signeQualite,
    classement,
    lieuDit,
    couleur,
    typeVin,
    certification,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cuvee &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.caveId == this.caveId &&
          other.domaineId == this.domaineId &&
          other.nom == this.nom &&
          other.pays == this.pays &&
          other.region == this.region &&
          other.sousRegion == this.sousRegion &&
          other.appellation == this.appellation &&
          other.signeQualite == this.signeQualite &&
          other.classement == this.classement &&
          other.lieuDit == this.lieuDit &&
          other.couleur == this.couleur &&
          other.typeVin == this.typeVin &&
          other.certification == this.certification);
}

class CuveesCompanion extends UpdateCompanion<Cuvee> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> caveId;
  final Value<String> domaineId;
  final Value<String?> nom;
  final Value<String> pays;
  final Value<String?> region;
  final Value<String?> sousRegion;
  final Value<String?> appellation;
  final Value<String?> signeQualite;
  final Value<String?> classement;
  final Value<String?> lieuDit;
  final Value<String> couleur;
  final Value<String?> typeVin;
  final Value<String?> certification;
  final Value<int> rowid;
  const CuveesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.caveId = const Value.absent(),
    this.domaineId = const Value.absent(),
    this.nom = const Value.absent(),
    this.pays = const Value.absent(),
    this.region = const Value.absent(),
    this.sousRegion = const Value.absent(),
    this.appellation = const Value.absent(),
    this.signeQualite = const Value.absent(),
    this.classement = const Value.absent(),
    this.lieuDit = const Value.absent(),
    this.couleur = const Value.absent(),
    this.typeVin = const Value.absent(),
    this.certification = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CuveesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String caveId,
    required String domaineId,
    this.nom = const Value.absent(),
    required String pays,
    this.region = const Value.absent(),
    this.sousRegion = const Value.absent(),
    this.appellation = const Value.absent(),
    this.signeQualite = const Value.absent(),
    this.classement = const Value.absent(),
    this.lieuDit = const Value.absent(),
    required String couleur,
    this.typeVin = const Value.absent(),
    this.certification = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       caveId = Value(caveId),
       domaineId = Value(domaineId),
       pays = Value(pays),
       couleur = Value(couleur);
  static Insertable<Cuvee> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? caveId,
    Expression<String>? domaineId,
    Expression<String>? nom,
    Expression<String>? pays,
    Expression<String>? region,
    Expression<String>? sousRegion,
    Expression<String>? appellation,
    Expression<String>? signeQualite,
    Expression<String>? classement,
    Expression<String>? lieuDit,
    Expression<String>? couleur,
    Expression<String>? typeVin,
    Expression<String>? certification,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (caveId != null) 'cave_id': caveId,
      if (domaineId != null) 'domaine_id': domaineId,
      if (nom != null) 'nom': nom,
      if (pays != null) 'pays': pays,
      if (region != null) 'region': region,
      if (sousRegion != null) 'sous_region': sousRegion,
      if (appellation != null) 'appellation': appellation,
      if (signeQualite != null) 'signe_qualite': signeQualite,
      if (classement != null) 'classement': classement,
      if (lieuDit != null) 'lieu_dit': lieuDit,
      if (couleur != null) 'couleur': couleur,
      if (typeVin != null) 'type_vin': typeVin,
      if (certification != null) 'certification': certification,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CuveesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? caveId,
    Value<String>? domaineId,
    Value<String?>? nom,
    Value<String>? pays,
    Value<String?>? region,
    Value<String?>? sousRegion,
    Value<String?>? appellation,
    Value<String?>? signeQualite,
    Value<String?>? classement,
    Value<String?>? lieuDit,
    Value<String>? couleur,
    Value<String?>? typeVin,
    Value<String?>? certification,
    Value<int>? rowid,
  }) {
    return CuveesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      caveId: caveId ?? this.caveId,
      domaineId: domaineId ?? this.domaineId,
      nom: nom ?? this.nom,
      pays: pays ?? this.pays,
      region: region ?? this.region,
      sousRegion: sousRegion ?? this.sousRegion,
      appellation: appellation ?? this.appellation,
      signeQualite: signeQualite ?? this.signeQualite,
      classement: classement ?? this.classement,
      lieuDit: lieuDit ?? this.lieuDit,
      couleur: couleur ?? this.couleur,
      typeVin: typeVin ?? this.typeVin,
      certification: certification ?? this.certification,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (caveId.present) {
      map['cave_id'] = Variable<String>(caveId.value);
    }
    if (domaineId.present) {
      map['domaine_id'] = Variable<String>(domaineId.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (pays.present) {
      map['pays'] = Variable<String>(pays.value);
    }
    if (region.present) {
      map['region'] = Variable<String>(region.value);
    }
    if (sousRegion.present) {
      map['sous_region'] = Variable<String>(sousRegion.value);
    }
    if (appellation.present) {
      map['appellation'] = Variable<String>(appellation.value);
    }
    if (signeQualite.present) {
      map['signe_qualite'] = Variable<String>(signeQualite.value);
    }
    if (classement.present) {
      map['classement'] = Variable<String>(classement.value);
    }
    if (lieuDit.present) {
      map['lieu_dit'] = Variable<String>(lieuDit.value);
    }
    if (couleur.present) {
      map['couleur'] = Variable<String>(couleur.value);
    }
    if (typeVin.present) {
      map['type_vin'] = Variable<String>(typeVin.value);
    }
    if (certification.present) {
      map['certification'] = Variable<String>(certification.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CuveesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('caveId: $caveId, ')
          ..write('domaineId: $domaineId, ')
          ..write('nom: $nom, ')
          ..write('pays: $pays, ')
          ..write('region: $region, ')
          ..write('sousRegion: $sousRegion, ')
          ..write('appellation: $appellation, ')
          ..write('signeQualite: $signeQualite, ')
          ..write('classement: $classement, ')
          ..write('lieuDit: $lieuDit, ')
          ..write('couleur: $couleur, ')
          ..write('typeVin: $typeVin, ')
          ..write('certification: $certification, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WinesTable extends Wines with TableInfo<$WinesTable, Wine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caveIdMeta = const VerificationMeta('caveId');
  @override
  late final GeneratedColumn<String> caveId = GeneratedColumn<String>(
    'cave_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cave (id)',
    ),
  );
  static const VerificationMeta _cuveeIdMeta = const VerificationMeta(
    'cuveeId',
  );
  @override
  late final GeneratedColumn<String> cuveeId = GeneratedColumn<String>(
    'cuvee_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cuvee (id)',
    ),
  );
  static const VerificationMeta _millesimeMeta = const VerificationMeta(
    'millesime',
  );
  @override
  late final GeneratedColumn<String> millesime = GeneratedColumn<String>(
    'millesime',
    aliasedName,
    false,
    check: () =>
        millesime.equals('NM') |
        (StringExpressionOperators(millesime).like('____') &
            ComparableExpr(millesime).isBetweenValues('1900', '2999')),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cepagesMeta = const VerificationMeta(
    'cepages',
  );
  @override
  late final GeneratedColumn<String> cepages = GeneratedColumn<String>(
    'cepages',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _degreMeta = const VerificationMeta('degre');
  @override
  late final GeneratedColumn<double> degre = GeneratedColumn<double>(
    'degre',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commentaireMillesimeMeta =
      const VerificationMeta('commentaireMillesime');
  @override
  late final GeneratedColumn<String> commentaireMillesime =
      GeneratedColumn<String>(
        'commentaire_millesime',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _gardeDebutMeta = const VerificationMeta(
    'gardeDebut',
  );
  @override
  late final GeneratedColumn<int> gardeDebut = GeneratedColumn<int>(
    'garde_debut',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gardeApogeeMeta = const VerificationMeta(
    'gardeApogee',
  );
  @override
  late final GeneratedColumn<int> gardeApogee = GeneratedColumn<int>(
    'garde_apogee',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gardeFinMeta = const VerificationMeta(
    'gardeFin',
  );
  @override
  late final GeneratedColumn<int> gardeFin = GeneratedColumn<int>(
    'garde_fin',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gardeSourceMeta = const VerificationMeta(
    'gardeSource',
  );
  @override
  late final GeneratedColumn<String> gardeSource = GeneratedColumn<String>(
    'garde_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accordsMeta = const VerificationMeta(
    'accords',
  );
  @override
  late final GeneratedColumn<String> accords = GeneratedColumn<String>(
    'accords',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eanMeta = const VerificationMeta('ean');
  @override
  late final GeneratedColumn<String> ean = GeneratedColumn<String>(
    'ean',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lwinMeta = const VerificationMeta('lwin');
  @override
  late final GeneratedColumn<String> lwin = GeneratedColumn<String>(
    'lwin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commentairePersoMeta = const VerificationMeta(
    'commentairePerso',
  );
  @override
  late final GeneratedColumn<String> commentairePerso = GeneratedColumn<String>(
    'commentaire_perso',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _favoriMeta = const VerificationMeta('favori');
  @override
  late final GeneratedColumn<bool> favori = GeneratedColumn<bool>(
    'favori',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("favori" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _statutEnrichissementMeta =
      const VerificationMeta('statutEnrichissement');
  @override
  late final GeneratedColumn<String> statutEnrichissement =
      GeneratedColumn<String>(
        'statut_enrichissement',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('brouillon'),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    caveId,
    cuveeId,
    millesime,
    cepages,
    degre,
    commentaireMillesime,
    gardeDebut,
    gardeApogee,
    gardeFin,
    gardeSource,
    accords,
    ean,
    lwin,
    commentairePerso,
    favori,
    statutEnrichissement,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fiche_vin';
  @override
  VerificationContext validateIntegrity(
    Insertable<Wine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('cave_id')) {
      context.handle(
        _caveIdMeta,
        caveId.isAcceptableOrUnknown(data['cave_id']!, _caveIdMeta),
      );
    } else if (isInserting) {
      context.missing(_caveIdMeta);
    }
    if (data.containsKey('cuvee_id')) {
      context.handle(
        _cuveeIdMeta,
        cuveeId.isAcceptableOrUnknown(data['cuvee_id']!, _cuveeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cuveeIdMeta);
    }
    if (data.containsKey('millesime')) {
      context.handle(
        _millesimeMeta,
        millesime.isAcceptableOrUnknown(data['millesime']!, _millesimeMeta),
      );
    } else if (isInserting) {
      context.missing(_millesimeMeta);
    }
    if (data.containsKey('cepages')) {
      context.handle(
        _cepagesMeta,
        cepages.isAcceptableOrUnknown(data['cepages']!, _cepagesMeta),
      );
    }
    if (data.containsKey('degre')) {
      context.handle(
        _degreMeta,
        degre.isAcceptableOrUnknown(data['degre']!, _degreMeta),
      );
    }
    if (data.containsKey('commentaire_millesime')) {
      context.handle(
        _commentaireMillesimeMeta,
        commentaireMillesime.isAcceptableOrUnknown(
          data['commentaire_millesime']!,
          _commentaireMillesimeMeta,
        ),
      );
    }
    if (data.containsKey('garde_debut')) {
      context.handle(
        _gardeDebutMeta,
        gardeDebut.isAcceptableOrUnknown(data['garde_debut']!, _gardeDebutMeta),
      );
    }
    if (data.containsKey('garde_apogee')) {
      context.handle(
        _gardeApogeeMeta,
        gardeApogee.isAcceptableOrUnknown(
          data['garde_apogee']!,
          _gardeApogeeMeta,
        ),
      );
    }
    if (data.containsKey('garde_fin')) {
      context.handle(
        _gardeFinMeta,
        gardeFin.isAcceptableOrUnknown(data['garde_fin']!, _gardeFinMeta),
      );
    }
    if (data.containsKey('garde_source')) {
      context.handle(
        _gardeSourceMeta,
        gardeSource.isAcceptableOrUnknown(
          data['garde_source']!,
          _gardeSourceMeta,
        ),
      );
    }
    if (data.containsKey('accords')) {
      context.handle(
        _accordsMeta,
        accords.isAcceptableOrUnknown(data['accords']!, _accordsMeta),
      );
    }
    if (data.containsKey('ean')) {
      context.handle(
        _eanMeta,
        ean.isAcceptableOrUnknown(data['ean']!, _eanMeta),
      );
    }
    if (data.containsKey('lwin')) {
      context.handle(
        _lwinMeta,
        lwin.isAcceptableOrUnknown(data['lwin']!, _lwinMeta),
      );
    }
    if (data.containsKey('commentaire_perso')) {
      context.handle(
        _commentairePersoMeta,
        commentairePerso.isAcceptableOrUnknown(
          data['commentaire_perso']!,
          _commentairePersoMeta,
        ),
      );
    }
    if (data.containsKey('favori')) {
      context.handle(
        _favoriMeta,
        favori.isAcceptableOrUnknown(data['favori']!, _favoriMeta),
      );
    }
    if (data.containsKey('statut_enrichissement')) {
      context.handle(
        _statutEnrichissementMeta,
        statutEnrichissement.isAcceptableOrUnknown(
          data['statut_enrichissement']!,
          _statutEnrichissementMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Wine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Wine(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      caveId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cave_id'],
      )!,
      cuveeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cuvee_id'],
      )!,
      millesime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}millesime'],
      )!,
      cepages: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cepages'],
      ),
      degre: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}degre'],
      ),
      commentaireMillesime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}commentaire_millesime'],
      ),
      gardeDebut: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}garde_debut'],
      ),
      gardeApogee: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}garde_apogee'],
      ),
      gardeFin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}garde_fin'],
      ),
      gardeSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}garde_source'],
      ),
      accords: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accords'],
      ),
      ean: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ean'],
      ),
      lwin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lwin'],
      ),
      commentairePerso: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}commentaire_perso'],
      ),
      favori: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}favori'],
      ),
      statutEnrichissement: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}statut_enrichissement'],
      ),
    );
  }

  @override
  $WinesTable createAlias(String alias) {
    return $WinesTable(attachedDatabase, alias);
  }
}

class Wine extends DataClass implements Insertable<Wine> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String caveId;
  final String cuveeId;

  /// Année sur 4 chiffres ou « NM » : l'ordre lexical suit l'ordre des années.
  final String millesime;
  final String? cepages;
  final double? degre;
  final String? commentaireMillesime;
  final int? gardeDebut;
  final int? gardeApogee;
  final int? gardeFin;
  final String? gardeSource;
  final String? accords;
  final String? ean;
  final String? lwin;
  final String? commentairePerso;
  final bool? favori;
  final String? statutEnrichissement;
  const Wine({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.caveId,
    required this.cuveeId,
    required this.millesime,
    this.cepages,
    this.degre,
    this.commentaireMillesime,
    this.gardeDebut,
    this.gardeApogee,
    this.gardeFin,
    this.gardeSource,
    this.accords,
    this.ean,
    this.lwin,
    this.commentairePerso,
    this.favori,
    this.statutEnrichissement,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['cave_id'] = Variable<String>(caveId);
    map['cuvee_id'] = Variable<String>(cuveeId);
    map['millesime'] = Variable<String>(millesime);
    if (!nullToAbsent || cepages != null) {
      map['cepages'] = Variable<String>(cepages);
    }
    if (!nullToAbsent || degre != null) {
      map['degre'] = Variable<double>(degre);
    }
    if (!nullToAbsent || commentaireMillesime != null) {
      map['commentaire_millesime'] = Variable<String>(commentaireMillesime);
    }
    if (!nullToAbsent || gardeDebut != null) {
      map['garde_debut'] = Variable<int>(gardeDebut);
    }
    if (!nullToAbsent || gardeApogee != null) {
      map['garde_apogee'] = Variable<int>(gardeApogee);
    }
    if (!nullToAbsent || gardeFin != null) {
      map['garde_fin'] = Variable<int>(gardeFin);
    }
    if (!nullToAbsent || gardeSource != null) {
      map['garde_source'] = Variable<String>(gardeSource);
    }
    if (!nullToAbsent || accords != null) {
      map['accords'] = Variable<String>(accords);
    }
    if (!nullToAbsent || ean != null) {
      map['ean'] = Variable<String>(ean);
    }
    if (!nullToAbsent || lwin != null) {
      map['lwin'] = Variable<String>(lwin);
    }
    if (!nullToAbsent || commentairePerso != null) {
      map['commentaire_perso'] = Variable<String>(commentairePerso);
    }
    if (!nullToAbsent || favori != null) {
      map['favori'] = Variable<bool>(favori);
    }
    if (!nullToAbsent || statutEnrichissement != null) {
      map['statut_enrichissement'] = Variable<String>(statutEnrichissement);
    }
    return map;
  }

  WinesCompanion toCompanion(bool nullToAbsent) {
    return WinesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      caveId: Value(caveId),
      cuveeId: Value(cuveeId),
      millesime: Value(millesime),
      cepages: cepages == null && nullToAbsent
          ? const Value.absent()
          : Value(cepages),
      degre: degre == null && nullToAbsent
          ? const Value.absent()
          : Value(degre),
      commentaireMillesime: commentaireMillesime == null && nullToAbsent
          ? const Value.absent()
          : Value(commentaireMillesime),
      gardeDebut: gardeDebut == null && nullToAbsent
          ? const Value.absent()
          : Value(gardeDebut),
      gardeApogee: gardeApogee == null && nullToAbsent
          ? const Value.absent()
          : Value(gardeApogee),
      gardeFin: gardeFin == null && nullToAbsent
          ? const Value.absent()
          : Value(gardeFin),
      gardeSource: gardeSource == null && nullToAbsent
          ? const Value.absent()
          : Value(gardeSource),
      accords: accords == null && nullToAbsent
          ? const Value.absent()
          : Value(accords),
      ean: ean == null && nullToAbsent ? const Value.absent() : Value(ean),
      lwin: lwin == null && nullToAbsent ? const Value.absent() : Value(lwin),
      commentairePerso: commentairePerso == null && nullToAbsent
          ? const Value.absent()
          : Value(commentairePerso),
      favori: favori == null && nullToAbsent
          ? const Value.absent()
          : Value(favori),
      statutEnrichissement: statutEnrichissement == null && nullToAbsent
          ? const Value.absent()
          : Value(statutEnrichissement),
    );
  }

  factory Wine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Wine(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      caveId: serializer.fromJson<String>(json['caveId']),
      cuveeId: serializer.fromJson<String>(json['cuveeId']),
      millesime: serializer.fromJson<String>(json['millesime']),
      cepages: serializer.fromJson<String?>(json['cepages']),
      degre: serializer.fromJson<double?>(json['degre']),
      commentaireMillesime: serializer.fromJson<String?>(
        json['commentaireMillesime'],
      ),
      gardeDebut: serializer.fromJson<int?>(json['gardeDebut']),
      gardeApogee: serializer.fromJson<int?>(json['gardeApogee']),
      gardeFin: serializer.fromJson<int?>(json['gardeFin']),
      gardeSource: serializer.fromJson<String?>(json['gardeSource']),
      accords: serializer.fromJson<String?>(json['accords']),
      ean: serializer.fromJson<String?>(json['ean']),
      lwin: serializer.fromJson<String?>(json['lwin']),
      commentairePerso: serializer.fromJson<String?>(json['commentairePerso']),
      favori: serializer.fromJson<bool?>(json['favori']),
      statutEnrichissement: serializer.fromJson<String?>(
        json['statutEnrichissement'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'caveId': serializer.toJson<String>(caveId),
      'cuveeId': serializer.toJson<String>(cuveeId),
      'millesime': serializer.toJson<String>(millesime),
      'cepages': serializer.toJson<String?>(cepages),
      'degre': serializer.toJson<double?>(degre),
      'commentaireMillesime': serializer.toJson<String?>(commentaireMillesime),
      'gardeDebut': serializer.toJson<int?>(gardeDebut),
      'gardeApogee': serializer.toJson<int?>(gardeApogee),
      'gardeFin': serializer.toJson<int?>(gardeFin),
      'gardeSource': serializer.toJson<String?>(gardeSource),
      'accords': serializer.toJson<String?>(accords),
      'ean': serializer.toJson<String?>(ean),
      'lwin': serializer.toJson<String?>(lwin),
      'commentairePerso': serializer.toJson<String?>(commentairePerso),
      'favori': serializer.toJson<bool?>(favori),
      'statutEnrichissement': serializer.toJson<String?>(statutEnrichissement),
    };
  }

  Wine copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? caveId,
    String? cuveeId,
    String? millesime,
    Value<String?> cepages = const Value.absent(),
    Value<double?> degre = const Value.absent(),
    Value<String?> commentaireMillesime = const Value.absent(),
    Value<int?> gardeDebut = const Value.absent(),
    Value<int?> gardeApogee = const Value.absent(),
    Value<int?> gardeFin = const Value.absent(),
    Value<String?> gardeSource = const Value.absent(),
    Value<String?> accords = const Value.absent(),
    Value<String?> ean = const Value.absent(),
    Value<String?> lwin = const Value.absent(),
    Value<String?> commentairePerso = const Value.absent(),
    Value<bool?> favori = const Value.absent(),
    Value<String?> statutEnrichissement = const Value.absent(),
  }) => Wine(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    caveId: caveId ?? this.caveId,
    cuveeId: cuveeId ?? this.cuveeId,
    millesime: millesime ?? this.millesime,
    cepages: cepages.present ? cepages.value : this.cepages,
    degre: degre.present ? degre.value : this.degre,
    commentaireMillesime: commentaireMillesime.present
        ? commentaireMillesime.value
        : this.commentaireMillesime,
    gardeDebut: gardeDebut.present ? gardeDebut.value : this.gardeDebut,
    gardeApogee: gardeApogee.present ? gardeApogee.value : this.gardeApogee,
    gardeFin: gardeFin.present ? gardeFin.value : this.gardeFin,
    gardeSource: gardeSource.present ? gardeSource.value : this.gardeSource,
    accords: accords.present ? accords.value : this.accords,
    ean: ean.present ? ean.value : this.ean,
    lwin: lwin.present ? lwin.value : this.lwin,
    commentairePerso: commentairePerso.present
        ? commentairePerso.value
        : this.commentairePerso,
    favori: favori.present ? favori.value : this.favori,
    statutEnrichissement: statutEnrichissement.present
        ? statutEnrichissement.value
        : this.statutEnrichissement,
  );
  Wine copyWithCompanion(WinesCompanion data) {
    return Wine(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      caveId: data.caveId.present ? data.caveId.value : this.caveId,
      cuveeId: data.cuveeId.present ? data.cuveeId.value : this.cuveeId,
      millesime: data.millesime.present ? data.millesime.value : this.millesime,
      cepages: data.cepages.present ? data.cepages.value : this.cepages,
      degre: data.degre.present ? data.degre.value : this.degre,
      commentaireMillesime: data.commentaireMillesime.present
          ? data.commentaireMillesime.value
          : this.commentaireMillesime,
      gardeDebut: data.gardeDebut.present
          ? data.gardeDebut.value
          : this.gardeDebut,
      gardeApogee: data.gardeApogee.present
          ? data.gardeApogee.value
          : this.gardeApogee,
      gardeFin: data.gardeFin.present ? data.gardeFin.value : this.gardeFin,
      gardeSource: data.gardeSource.present
          ? data.gardeSource.value
          : this.gardeSource,
      accords: data.accords.present ? data.accords.value : this.accords,
      ean: data.ean.present ? data.ean.value : this.ean,
      lwin: data.lwin.present ? data.lwin.value : this.lwin,
      commentairePerso: data.commentairePerso.present
          ? data.commentairePerso.value
          : this.commentairePerso,
      favori: data.favori.present ? data.favori.value : this.favori,
      statutEnrichissement: data.statutEnrichissement.present
          ? data.statutEnrichissement.value
          : this.statutEnrichissement,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Wine(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('caveId: $caveId, ')
          ..write('cuveeId: $cuveeId, ')
          ..write('millesime: $millesime, ')
          ..write('cepages: $cepages, ')
          ..write('degre: $degre, ')
          ..write('commentaireMillesime: $commentaireMillesime, ')
          ..write('gardeDebut: $gardeDebut, ')
          ..write('gardeApogee: $gardeApogee, ')
          ..write('gardeFin: $gardeFin, ')
          ..write('gardeSource: $gardeSource, ')
          ..write('accords: $accords, ')
          ..write('ean: $ean, ')
          ..write('lwin: $lwin, ')
          ..write('commentairePerso: $commentairePerso, ')
          ..write('favori: $favori, ')
          ..write('statutEnrichissement: $statutEnrichissement')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    caveId,
    cuveeId,
    millesime,
    cepages,
    degre,
    commentaireMillesime,
    gardeDebut,
    gardeApogee,
    gardeFin,
    gardeSource,
    accords,
    ean,
    lwin,
    commentairePerso,
    favori,
    statutEnrichissement,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Wine &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.caveId == this.caveId &&
          other.cuveeId == this.cuveeId &&
          other.millesime == this.millesime &&
          other.cepages == this.cepages &&
          other.degre == this.degre &&
          other.commentaireMillesime == this.commentaireMillesime &&
          other.gardeDebut == this.gardeDebut &&
          other.gardeApogee == this.gardeApogee &&
          other.gardeFin == this.gardeFin &&
          other.gardeSource == this.gardeSource &&
          other.accords == this.accords &&
          other.ean == this.ean &&
          other.lwin == this.lwin &&
          other.commentairePerso == this.commentairePerso &&
          other.favori == this.favori &&
          other.statutEnrichissement == this.statutEnrichissement);
}

class WinesCompanion extends UpdateCompanion<Wine> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> caveId;
  final Value<String> cuveeId;
  final Value<String> millesime;
  final Value<String?> cepages;
  final Value<double?> degre;
  final Value<String?> commentaireMillesime;
  final Value<int?> gardeDebut;
  final Value<int?> gardeApogee;
  final Value<int?> gardeFin;
  final Value<String?> gardeSource;
  final Value<String?> accords;
  final Value<String?> ean;
  final Value<String?> lwin;
  final Value<String?> commentairePerso;
  final Value<bool?> favori;
  final Value<String?> statutEnrichissement;
  final Value<int> rowid;
  const WinesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.caveId = const Value.absent(),
    this.cuveeId = const Value.absent(),
    this.millesime = const Value.absent(),
    this.cepages = const Value.absent(),
    this.degre = const Value.absent(),
    this.commentaireMillesime = const Value.absent(),
    this.gardeDebut = const Value.absent(),
    this.gardeApogee = const Value.absent(),
    this.gardeFin = const Value.absent(),
    this.gardeSource = const Value.absent(),
    this.accords = const Value.absent(),
    this.ean = const Value.absent(),
    this.lwin = const Value.absent(),
    this.commentairePerso = const Value.absent(),
    this.favori = const Value.absent(),
    this.statutEnrichissement = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WinesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String caveId,
    required String cuveeId,
    required String millesime,
    this.cepages = const Value.absent(),
    this.degre = const Value.absent(),
    this.commentaireMillesime = const Value.absent(),
    this.gardeDebut = const Value.absent(),
    this.gardeApogee = const Value.absent(),
    this.gardeFin = const Value.absent(),
    this.gardeSource = const Value.absent(),
    this.accords = const Value.absent(),
    this.ean = const Value.absent(),
    this.lwin = const Value.absent(),
    this.commentairePerso = const Value.absent(),
    this.favori = const Value.absent(),
    this.statutEnrichissement = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       caveId = Value(caveId),
       cuveeId = Value(cuveeId),
       millesime = Value(millesime);
  static Insertable<Wine> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? caveId,
    Expression<String>? cuveeId,
    Expression<String>? millesime,
    Expression<String>? cepages,
    Expression<double>? degre,
    Expression<String>? commentaireMillesime,
    Expression<int>? gardeDebut,
    Expression<int>? gardeApogee,
    Expression<int>? gardeFin,
    Expression<String>? gardeSource,
    Expression<String>? accords,
    Expression<String>? ean,
    Expression<String>? lwin,
    Expression<String>? commentairePerso,
    Expression<bool>? favori,
    Expression<String>? statutEnrichissement,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (caveId != null) 'cave_id': caveId,
      if (cuveeId != null) 'cuvee_id': cuveeId,
      if (millesime != null) 'millesime': millesime,
      if (cepages != null) 'cepages': cepages,
      if (degre != null) 'degre': degre,
      if (commentaireMillesime != null)
        'commentaire_millesime': commentaireMillesime,
      if (gardeDebut != null) 'garde_debut': gardeDebut,
      if (gardeApogee != null) 'garde_apogee': gardeApogee,
      if (gardeFin != null) 'garde_fin': gardeFin,
      if (gardeSource != null) 'garde_source': gardeSource,
      if (accords != null) 'accords': accords,
      if (ean != null) 'ean': ean,
      if (lwin != null) 'lwin': lwin,
      if (commentairePerso != null) 'commentaire_perso': commentairePerso,
      if (favori != null) 'favori': favori,
      if (statutEnrichissement != null)
        'statut_enrichissement': statutEnrichissement,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WinesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? caveId,
    Value<String>? cuveeId,
    Value<String>? millesime,
    Value<String?>? cepages,
    Value<double?>? degre,
    Value<String?>? commentaireMillesime,
    Value<int?>? gardeDebut,
    Value<int?>? gardeApogee,
    Value<int?>? gardeFin,
    Value<String?>? gardeSource,
    Value<String?>? accords,
    Value<String?>? ean,
    Value<String?>? lwin,
    Value<String?>? commentairePerso,
    Value<bool?>? favori,
    Value<String?>? statutEnrichissement,
    Value<int>? rowid,
  }) {
    return WinesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      caveId: caveId ?? this.caveId,
      cuveeId: cuveeId ?? this.cuveeId,
      millesime: millesime ?? this.millesime,
      cepages: cepages ?? this.cepages,
      degre: degre ?? this.degre,
      commentaireMillesime: commentaireMillesime ?? this.commentaireMillesime,
      gardeDebut: gardeDebut ?? this.gardeDebut,
      gardeApogee: gardeApogee ?? this.gardeApogee,
      gardeFin: gardeFin ?? this.gardeFin,
      gardeSource: gardeSource ?? this.gardeSource,
      accords: accords ?? this.accords,
      ean: ean ?? this.ean,
      lwin: lwin ?? this.lwin,
      commentairePerso: commentairePerso ?? this.commentairePerso,
      favori: favori ?? this.favori,
      statutEnrichissement: statutEnrichissement ?? this.statutEnrichissement,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (caveId.present) {
      map['cave_id'] = Variable<String>(caveId.value);
    }
    if (cuveeId.present) {
      map['cuvee_id'] = Variable<String>(cuveeId.value);
    }
    if (millesime.present) {
      map['millesime'] = Variable<String>(millesime.value);
    }
    if (cepages.present) {
      map['cepages'] = Variable<String>(cepages.value);
    }
    if (degre.present) {
      map['degre'] = Variable<double>(degre.value);
    }
    if (commentaireMillesime.present) {
      map['commentaire_millesime'] = Variable<String>(
        commentaireMillesime.value,
      );
    }
    if (gardeDebut.present) {
      map['garde_debut'] = Variable<int>(gardeDebut.value);
    }
    if (gardeApogee.present) {
      map['garde_apogee'] = Variable<int>(gardeApogee.value);
    }
    if (gardeFin.present) {
      map['garde_fin'] = Variable<int>(gardeFin.value);
    }
    if (gardeSource.present) {
      map['garde_source'] = Variable<String>(gardeSource.value);
    }
    if (accords.present) {
      map['accords'] = Variable<String>(accords.value);
    }
    if (ean.present) {
      map['ean'] = Variable<String>(ean.value);
    }
    if (lwin.present) {
      map['lwin'] = Variable<String>(lwin.value);
    }
    if (commentairePerso.present) {
      map['commentaire_perso'] = Variable<String>(commentairePerso.value);
    }
    if (favori.present) {
      map['favori'] = Variable<bool>(favori.value);
    }
    if (statutEnrichissement.present) {
      map['statut_enrichissement'] = Variable<String>(
        statutEnrichissement.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WinesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('caveId: $caveId, ')
          ..write('cuveeId: $cuveeId, ')
          ..write('millesime: $millesime, ')
          ..write('cepages: $cepages, ')
          ..write('degre: $degre, ')
          ..write('commentaireMillesime: $commentaireMillesime, ')
          ..write('gardeDebut: $gardeDebut, ')
          ..write('gardeApogee: $gardeApogee, ')
          ..write('gardeFin: $gardeFin, ')
          ..write('gardeSource: $gardeSource, ')
          ..write('accords: $accords, ')
          ..write('ean: $ean, ')
          ..write('lwin: $lwin, ')
          ..write('commentairePerso: $commentairePerso, ')
          ..write('favori: $favori, ')
          ..write('statutEnrichissement: $statutEnrichissement, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CriticScoresTable extends CriticScores
    with TableInfo<$CriticScoresTable, CriticScore> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CriticScoresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caveIdMeta = const VerificationMeta('caveId');
  @override
  late final GeneratedColumn<String> caveId = GeneratedColumn<String>(
    'cave_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cave (id)',
    ),
  );
  static const VerificationMeta _ficheIdMeta = const VerificationMeta(
    'ficheId',
  );
  @override
  late final GeneratedColumn<String> ficheId = GeneratedColumn<String>(
    'fiche_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES fiche_vin (id)',
    ),
  );
  static const VerificationMeta _critiqueMeta = const VerificationMeta(
    'critique',
  );
  @override
  late final GeneratedColumn<String> critique = GeneratedColumn<String>(
    'critique',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<double> note = GeneratedColumn<double>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _echelleMeta = const VerificationMeta(
    'echelle',
  );
  @override
  late final GeneratedColumn<int> echelle = GeneratedColumn<int>(
    'echelle',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _degustateurMeta = const VerificationMeta(
    'degustateur',
  );
  @override
  late final GeneratedColumn<String> degustateur = GeneratedColumn<String>(
    'degustateur',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateNoteMeta = const VerificationMeta(
    'dateNote',
  );
  @override
  late final GeneratedColumn<String> dateNote = GeneratedColumn<String>(
    'date_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fenetreDebutMeta = const VerificationMeta(
    'fenetreDebut',
  );
  @override
  late final GeneratedColumn<int> fenetreDebut = GeneratedColumn<int>(
    'fenetre_debut',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fenetreFinMeta = const VerificationMeta(
    'fenetreFin',
  );
  @override
  late final GeneratedColumn<int> fenetreFin = GeneratedColumn<int>(
    'fenetre_fin',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _citeeParMeta = const VerificationMeta(
    'citeePar',
  );
  @override
  late final GeneratedColumn<String> citeePar = GeneratedColumn<String>(
    'citee_par',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    caveId,
    ficheId,
    critique,
    note,
    echelle,
    degustateur,
    dateNote,
    fenetreDebut,
    fenetreFin,
    url,
    citeePar,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note_critique';
  @override
  VerificationContext validateIntegrity(
    Insertable<CriticScore> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('cave_id')) {
      context.handle(
        _caveIdMeta,
        caveId.isAcceptableOrUnknown(data['cave_id']!, _caveIdMeta),
      );
    } else if (isInserting) {
      context.missing(_caveIdMeta);
    }
    if (data.containsKey('fiche_id')) {
      context.handle(
        _ficheIdMeta,
        ficheId.isAcceptableOrUnknown(data['fiche_id']!, _ficheIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ficheIdMeta);
    }
    if (data.containsKey('critique')) {
      context.handle(
        _critiqueMeta,
        critique.isAcceptableOrUnknown(data['critique']!, _critiqueMeta),
      );
    } else if (isInserting) {
      context.missing(_critiqueMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('echelle')) {
      context.handle(
        _echelleMeta,
        echelle.isAcceptableOrUnknown(data['echelle']!, _echelleMeta),
      );
    } else if (isInserting) {
      context.missing(_echelleMeta);
    }
    if (data.containsKey('degustateur')) {
      context.handle(
        _degustateurMeta,
        degustateur.isAcceptableOrUnknown(
          data['degustateur']!,
          _degustateurMeta,
        ),
      );
    }
    if (data.containsKey('date_note')) {
      context.handle(
        _dateNoteMeta,
        dateNote.isAcceptableOrUnknown(data['date_note']!, _dateNoteMeta),
      );
    }
    if (data.containsKey('fenetre_debut')) {
      context.handle(
        _fenetreDebutMeta,
        fenetreDebut.isAcceptableOrUnknown(
          data['fenetre_debut']!,
          _fenetreDebutMeta,
        ),
      );
    }
    if (data.containsKey('fenetre_fin')) {
      context.handle(
        _fenetreFinMeta,
        fenetreFin.isAcceptableOrUnknown(data['fenetre_fin']!, _fenetreFinMeta),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('citee_par')) {
      context.handle(
        _citeeParMeta,
        citeePar.isAcceptableOrUnknown(data['citee_par']!, _citeeParMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CriticScore map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CriticScore(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      caveId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cave_id'],
      )!,
      ficheId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fiche_id'],
      )!,
      critique: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}critique'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}note'],
      )!,
      echelle: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}echelle'],
      )!,
      degustateur: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}degustateur'],
      ),
      dateNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_note'],
      ),
      fenetreDebut: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fenetre_debut'],
      ),
      fenetreFin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fenetre_fin'],
      ),
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
      citeePar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}citee_par'],
      ),
    );
  }

  @override
  $CriticScoresTable createAlias(String alias) {
    return $CriticScoresTable(attachedDatabase, alias);
  }
}

class CriticScore extends DataClass implements Insertable<CriticScore> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String caveId;
  final String ficheId;
  final String critique;
  final double note;
  final int echelle;
  final String? degustateur;
  final String? dateNote;
  final int? fenetreDebut;
  final int? fenetreFin;
  final String? url;
  final String? citeePar;
  const CriticScore({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.caveId,
    required this.ficheId,
    required this.critique,
    required this.note,
    required this.echelle,
    this.degustateur,
    this.dateNote,
    this.fenetreDebut,
    this.fenetreFin,
    this.url,
    this.citeePar,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['cave_id'] = Variable<String>(caveId);
    map['fiche_id'] = Variable<String>(ficheId);
    map['critique'] = Variable<String>(critique);
    map['note'] = Variable<double>(note);
    map['echelle'] = Variable<int>(echelle);
    if (!nullToAbsent || degustateur != null) {
      map['degustateur'] = Variable<String>(degustateur);
    }
    if (!nullToAbsent || dateNote != null) {
      map['date_note'] = Variable<String>(dateNote);
    }
    if (!nullToAbsent || fenetreDebut != null) {
      map['fenetre_debut'] = Variable<int>(fenetreDebut);
    }
    if (!nullToAbsent || fenetreFin != null) {
      map['fenetre_fin'] = Variable<int>(fenetreFin);
    }
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    if (!nullToAbsent || citeePar != null) {
      map['citee_par'] = Variable<String>(citeePar);
    }
    return map;
  }

  CriticScoresCompanion toCompanion(bool nullToAbsent) {
    return CriticScoresCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      caveId: Value(caveId),
      ficheId: Value(ficheId),
      critique: Value(critique),
      note: Value(note),
      echelle: Value(echelle),
      degustateur: degustateur == null && nullToAbsent
          ? const Value.absent()
          : Value(degustateur),
      dateNote: dateNote == null && nullToAbsent
          ? const Value.absent()
          : Value(dateNote),
      fenetreDebut: fenetreDebut == null && nullToAbsent
          ? const Value.absent()
          : Value(fenetreDebut),
      fenetreFin: fenetreFin == null && nullToAbsent
          ? const Value.absent()
          : Value(fenetreFin),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      citeePar: citeePar == null && nullToAbsent
          ? const Value.absent()
          : Value(citeePar),
    );
  }

  factory CriticScore.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CriticScore(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      caveId: serializer.fromJson<String>(json['caveId']),
      ficheId: serializer.fromJson<String>(json['ficheId']),
      critique: serializer.fromJson<String>(json['critique']),
      note: serializer.fromJson<double>(json['note']),
      echelle: serializer.fromJson<int>(json['echelle']),
      degustateur: serializer.fromJson<String?>(json['degustateur']),
      dateNote: serializer.fromJson<String?>(json['dateNote']),
      fenetreDebut: serializer.fromJson<int?>(json['fenetreDebut']),
      fenetreFin: serializer.fromJson<int?>(json['fenetreFin']),
      url: serializer.fromJson<String?>(json['url']),
      citeePar: serializer.fromJson<String?>(json['citeePar']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'caveId': serializer.toJson<String>(caveId),
      'ficheId': serializer.toJson<String>(ficheId),
      'critique': serializer.toJson<String>(critique),
      'note': serializer.toJson<double>(note),
      'echelle': serializer.toJson<int>(echelle),
      'degustateur': serializer.toJson<String?>(degustateur),
      'dateNote': serializer.toJson<String?>(dateNote),
      'fenetreDebut': serializer.toJson<int?>(fenetreDebut),
      'fenetreFin': serializer.toJson<int?>(fenetreFin),
      'url': serializer.toJson<String?>(url),
      'citeePar': serializer.toJson<String?>(citeePar),
    };
  }

  CriticScore copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? caveId,
    String? ficheId,
    String? critique,
    double? note,
    int? echelle,
    Value<String?> degustateur = const Value.absent(),
    Value<String?> dateNote = const Value.absent(),
    Value<int?> fenetreDebut = const Value.absent(),
    Value<int?> fenetreFin = const Value.absent(),
    Value<String?> url = const Value.absent(),
    Value<String?> citeePar = const Value.absent(),
  }) => CriticScore(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    caveId: caveId ?? this.caveId,
    ficheId: ficheId ?? this.ficheId,
    critique: critique ?? this.critique,
    note: note ?? this.note,
    echelle: echelle ?? this.echelle,
    degustateur: degustateur.present ? degustateur.value : this.degustateur,
    dateNote: dateNote.present ? dateNote.value : this.dateNote,
    fenetreDebut: fenetreDebut.present ? fenetreDebut.value : this.fenetreDebut,
    fenetreFin: fenetreFin.present ? fenetreFin.value : this.fenetreFin,
    url: url.present ? url.value : this.url,
    citeePar: citeePar.present ? citeePar.value : this.citeePar,
  );
  CriticScore copyWithCompanion(CriticScoresCompanion data) {
    return CriticScore(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      caveId: data.caveId.present ? data.caveId.value : this.caveId,
      ficheId: data.ficheId.present ? data.ficheId.value : this.ficheId,
      critique: data.critique.present ? data.critique.value : this.critique,
      note: data.note.present ? data.note.value : this.note,
      echelle: data.echelle.present ? data.echelle.value : this.echelle,
      degustateur: data.degustateur.present
          ? data.degustateur.value
          : this.degustateur,
      dateNote: data.dateNote.present ? data.dateNote.value : this.dateNote,
      fenetreDebut: data.fenetreDebut.present
          ? data.fenetreDebut.value
          : this.fenetreDebut,
      fenetreFin: data.fenetreFin.present
          ? data.fenetreFin.value
          : this.fenetreFin,
      url: data.url.present ? data.url.value : this.url,
      citeePar: data.citeePar.present ? data.citeePar.value : this.citeePar,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CriticScore(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('caveId: $caveId, ')
          ..write('ficheId: $ficheId, ')
          ..write('critique: $critique, ')
          ..write('note: $note, ')
          ..write('echelle: $echelle, ')
          ..write('degustateur: $degustateur, ')
          ..write('dateNote: $dateNote, ')
          ..write('fenetreDebut: $fenetreDebut, ')
          ..write('fenetreFin: $fenetreFin, ')
          ..write('url: $url, ')
          ..write('citeePar: $citeePar')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    caveId,
    ficheId,
    critique,
    note,
    echelle,
    degustateur,
    dateNote,
    fenetreDebut,
    fenetreFin,
    url,
    citeePar,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CriticScore &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.caveId == this.caveId &&
          other.ficheId == this.ficheId &&
          other.critique == this.critique &&
          other.note == this.note &&
          other.echelle == this.echelle &&
          other.degustateur == this.degustateur &&
          other.dateNote == this.dateNote &&
          other.fenetreDebut == this.fenetreDebut &&
          other.fenetreFin == this.fenetreFin &&
          other.url == this.url &&
          other.citeePar == this.citeePar);
}

class CriticScoresCompanion extends UpdateCompanion<CriticScore> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> caveId;
  final Value<String> ficheId;
  final Value<String> critique;
  final Value<double> note;
  final Value<int> echelle;
  final Value<String?> degustateur;
  final Value<String?> dateNote;
  final Value<int?> fenetreDebut;
  final Value<int?> fenetreFin;
  final Value<String?> url;
  final Value<String?> citeePar;
  final Value<int> rowid;
  const CriticScoresCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.caveId = const Value.absent(),
    this.ficheId = const Value.absent(),
    this.critique = const Value.absent(),
    this.note = const Value.absent(),
    this.echelle = const Value.absent(),
    this.degustateur = const Value.absent(),
    this.dateNote = const Value.absent(),
    this.fenetreDebut = const Value.absent(),
    this.fenetreFin = const Value.absent(),
    this.url = const Value.absent(),
    this.citeePar = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CriticScoresCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String caveId,
    required String ficheId,
    required String critique,
    required double note,
    required int echelle,
    this.degustateur = const Value.absent(),
    this.dateNote = const Value.absent(),
    this.fenetreDebut = const Value.absent(),
    this.fenetreFin = const Value.absent(),
    this.url = const Value.absent(),
    this.citeePar = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       caveId = Value(caveId),
       ficheId = Value(ficheId),
       critique = Value(critique),
       note = Value(note),
       echelle = Value(echelle);
  static Insertable<CriticScore> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? caveId,
    Expression<String>? ficheId,
    Expression<String>? critique,
    Expression<double>? note,
    Expression<int>? echelle,
    Expression<String>? degustateur,
    Expression<String>? dateNote,
    Expression<int>? fenetreDebut,
    Expression<int>? fenetreFin,
    Expression<String>? url,
    Expression<String>? citeePar,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (caveId != null) 'cave_id': caveId,
      if (ficheId != null) 'fiche_id': ficheId,
      if (critique != null) 'critique': critique,
      if (note != null) 'note': note,
      if (echelle != null) 'echelle': echelle,
      if (degustateur != null) 'degustateur': degustateur,
      if (dateNote != null) 'date_note': dateNote,
      if (fenetreDebut != null) 'fenetre_debut': fenetreDebut,
      if (fenetreFin != null) 'fenetre_fin': fenetreFin,
      if (url != null) 'url': url,
      if (citeePar != null) 'citee_par': citeePar,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CriticScoresCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? caveId,
    Value<String>? ficheId,
    Value<String>? critique,
    Value<double>? note,
    Value<int>? echelle,
    Value<String?>? degustateur,
    Value<String?>? dateNote,
    Value<int?>? fenetreDebut,
    Value<int?>? fenetreFin,
    Value<String?>? url,
    Value<String?>? citeePar,
    Value<int>? rowid,
  }) {
    return CriticScoresCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      caveId: caveId ?? this.caveId,
      ficheId: ficheId ?? this.ficheId,
      critique: critique ?? this.critique,
      note: note ?? this.note,
      echelle: echelle ?? this.echelle,
      degustateur: degustateur ?? this.degustateur,
      dateNote: dateNote ?? this.dateNote,
      fenetreDebut: fenetreDebut ?? this.fenetreDebut,
      fenetreFin: fenetreFin ?? this.fenetreFin,
      url: url ?? this.url,
      citeePar: citeePar ?? this.citeePar,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (caveId.present) {
      map['cave_id'] = Variable<String>(caveId.value);
    }
    if (ficheId.present) {
      map['fiche_id'] = Variable<String>(ficheId.value);
    }
    if (critique.present) {
      map['critique'] = Variable<String>(critique.value);
    }
    if (note.present) {
      map['note'] = Variable<double>(note.value);
    }
    if (echelle.present) {
      map['echelle'] = Variable<int>(echelle.value);
    }
    if (degustateur.present) {
      map['degustateur'] = Variable<String>(degustateur.value);
    }
    if (dateNote.present) {
      map['date_note'] = Variable<String>(dateNote.value);
    }
    if (fenetreDebut.present) {
      map['fenetre_debut'] = Variable<int>(fenetreDebut.value);
    }
    if (fenetreFin.present) {
      map['fenetre_fin'] = Variable<int>(fenetreFin.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (citeePar.present) {
      map['citee_par'] = Variable<String>(citeePar.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CriticScoresCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('caveId: $caveId, ')
          ..write('ficheId: $ficheId, ')
          ..write('critique: $critique, ')
          ..write('note: $note, ')
          ..write('echelle: $echelle, ')
          ..write('degustateur: $degustateur, ')
          ..write('dateNote: $dateNote, ')
          ..write('fenetreDebut: $fenetreDebut, ')
          ..write('fenetreFin: $fenetreFin, ')
          ..write('url: $url, ')
          ..write('citeePar: $citeePar, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OwnersTable extends Owners with TableInfo<$OwnersTable, Owner> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OwnersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caveIdMeta = const VerificationMeta('caveId');
  @override
  late final GeneratedColumn<String> caveId = GeneratedColumn<String>(
    'cave_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cave (id)',
    ),
  );
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
    'nom',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _initialesMeta = const VerificationMeta(
    'initiales',
  );
  @override
  late final GeneratedColumn<String> initiales = GeneratedColumn<String>(
    'initiales',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _couleurMeta = const VerificationMeta(
    'couleur',
  );
  @override
  late final GeneratedColumn<String> couleur = GeneratedColumn<String>(
    'couleur',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parDefautMeta = const VerificationMeta(
    'parDefaut',
  );
  @override
  late final GeneratedColumn<bool> parDefaut = GeneratedColumn<bool>(
    'par_defaut',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("par_defaut" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    caveId,
    nom,
    initiales,
    couleur,
    parDefaut,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'proprietaire';
  @override
  VerificationContext validateIntegrity(
    Insertable<Owner> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('cave_id')) {
      context.handle(
        _caveIdMeta,
        caveId.isAcceptableOrUnknown(data['cave_id']!, _caveIdMeta),
      );
    } else if (isInserting) {
      context.missing(_caveIdMeta);
    }
    if (data.containsKey('nom')) {
      context.handle(
        _nomMeta,
        nom.isAcceptableOrUnknown(data['nom']!, _nomMeta),
      );
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('initiales')) {
      context.handle(
        _initialesMeta,
        initiales.isAcceptableOrUnknown(data['initiales']!, _initialesMeta),
      );
    }
    if (data.containsKey('couleur')) {
      context.handle(
        _couleurMeta,
        couleur.isAcceptableOrUnknown(data['couleur']!, _couleurMeta),
      );
    }
    if (data.containsKey('par_defaut')) {
      context.handle(
        _parDefautMeta,
        parDefaut.isAcceptableOrUnknown(data['par_defaut']!, _parDefautMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Owner map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Owner(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      caveId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cave_id'],
      )!,
      nom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nom'],
      )!,
      initiales: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}initiales'],
      ),
      couleur: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}couleur'],
      ),
      parDefaut: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}par_defaut'],
      ),
    );
  }

  @override
  $OwnersTable createAlias(String alias) {
    return $OwnersTable(attachedDatabase, alias);
  }
}

class Owner extends DataClass implements Insertable<Owner> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String caveId;
  final String nom;
  final String? initiales;
  final String? couleur;
  final bool? parDefaut;
  const Owner({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.caveId,
    required this.nom,
    this.initiales,
    this.couleur,
    this.parDefaut,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['cave_id'] = Variable<String>(caveId);
    map['nom'] = Variable<String>(nom);
    if (!nullToAbsent || initiales != null) {
      map['initiales'] = Variable<String>(initiales);
    }
    if (!nullToAbsent || couleur != null) {
      map['couleur'] = Variable<String>(couleur);
    }
    if (!nullToAbsent || parDefaut != null) {
      map['par_defaut'] = Variable<bool>(parDefaut);
    }
    return map;
  }

  OwnersCompanion toCompanion(bool nullToAbsent) {
    return OwnersCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      caveId: Value(caveId),
      nom: Value(nom),
      initiales: initiales == null && nullToAbsent
          ? const Value.absent()
          : Value(initiales),
      couleur: couleur == null && nullToAbsent
          ? const Value.absent()
          : Value(couleur),
      parDefaut: parDefaut == null && nullToAbsent
          ? const Value.absent()
          : Value(parDefaut),
    );
  }

  factory Owner.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Owner(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      caveId: serializer.fromJson<String>(json['caveId']),
      nom: serializer.fromJson<String>(json['nom']),
      initiales: serializer.fromJson<String?>(json['initiales']),
      couleur: serializer.fromJson<String?>(json['couleur']),
      parDefaut: serializer.fromJson<bool?>(json['parDefaut']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'caveId': serializer.toJson<String>(caveId),
      'nom': serializer.toJson<String>(nom),
      'initiales': serializer.toJson<String?>(initiales),
      'couleur': serializer.toJson<String?>(couleur),
      'parDefaut': serializer.toJson<bool?>(parDefaut),
    };
  }

  Owner copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? caveId,
    String? nom,
    Value<String?> initiales = const Value.absent(),
    Value<String?> couleur = const Value.absent(),
    Value<bool?> parDefaut = const Value.absent(),
  }) => Owner(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    caveId: caveId ?? this.caveId,
    nom: nom ?? this.nom,
    initiales: initiales.present ? initiales.value : this.initiales,
    couleur: couleur.present ? couleur.value : this.couleur,
    parDefaut: parDefaut.present ? parDefaut.value : this.parDefaut,
  );
  Owner copyWithCompanion(OwnersCompanion data) {
    return Owner(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      caveId: data.caveId.present ? data.caveId.value : this.caveId,
      nom: data.nom.present ? data.nom.value : this.nom,
      initiales: data.initiales.present ? data.initiales.value : this.initiales,
      couleur: data.couleur.present ? data.couleur.value : this.couleur,
      parDefaut: data.parDefaut.present ? data.parDefaut.value : this.parDefaut,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Owner(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('caveId: $caveId, ')
          ..write('nom: $nom, ')
          ..write('initiales: $initiales, ')
          ..write('couleur: $couleur, ')
          ..write('parDefaut: $parDefaut')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    caveId,
    nom,
    initiales,
    couleur,
    parDefaut,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Owner &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.caveId == this.caveId &&
          other.nom == this.nom &&
          other.initiales == this.initiales &&
          other.couleur == this.couleur &&
          other.parDefaut == this.parDefaut);
}

class OwnersCompanion extends UpdateCompanion<Owner> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> caveId;
  final Value<String> nom;
  final Value<String?> initiales;
  final Value<String?> couleur;
  final Value<bool?> parDefaut;
  final Value<int> rowid;
  const OwnersCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.caveId = const Value.absent(),
    this.nom = const Value.absent(),
    this.initiales = const Value.absent(),
    this.couleur = const Value.absent(),
    this.parDefaut = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OwnersCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String caveId,
    required String nom,
    this.initiales = const Value.absent(),
    this.couleur = const Value.absent(),
    this.parDefaut = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       caveId = Value(caveId),
       nom = Value(nom);
  static Insertable<Owner> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? caveId,
    Expression<String>? nom,
    Expression<String>? initiales,
    Expression<String>? couleur,
    Expression<bool>? parDefaut,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (caveId != null) 'cave_id': caveId,
      if (nom != null) 'nom': nom,
      if (initiales != null) 'initiales': initiales,
      if (couleur != null) 'couleur': couleur,
      if (parDefaut != null) 'par_defaut': parDefaut,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OwnersCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? caveId,
    Value<String>? nom,
    Value<String?>? initiales,
    Value<String?>? couleur,
    Value<bool?>? parDefaut,
    Value<int>? rowid,
  }) {
    return OwnersCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      caveId: caveId ?? this.caveId,
      nom: nom ?? this.nom,
      initiales: initiales ?? this.initiales,
      couleur: couleur ?? this.couleur,
      parDefaut: parDefaut ?? this.parDefaut,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (caveId.present) {
      map['cave_id'] = Variable<String>(caveId.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (initiales.present) {
      map['initiales'] = Variable<String>(initiales.value);
    }
    if (couleur.present) {
      map['couleur'] = Variable<String>(couleur.value);
    }
    if (parDefaut.present) {
      map['par_defaut'] = Variable<bool>(parDefaut.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OwnersCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('caveId: $caveId, ')
          ..write('nom: $nom, ')
          ..write('initiales: $initiales, ')
          ..write('couleur: $couleur, ')
          ..write('parDefaut: $parDefaut, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StorageLocationsTable extends StorageLocations
    with TableInfo<$StorageLocationsTable, StorageLocation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StorageLocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caveIdMeta = const VerificationMeta('caveId');
  @override
  late final GeneratedColumn<String> caveId = GeneratedColumn<String>(
    'cave_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cave (id)',
    ),
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES emplacement (id)',
    ),
  );
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
    'nom',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeEmplacementMeta = const VerificationMeta(
    'typeEmplacement',
  );
  @override
  late final GeneratedColumn<String> typeEmplacement = GeneratedColumn<String>(
    'type_emplacement',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lignesMeta = const VerificationMeta('lignes');
  @override
  late final GeneratedColumn<int> lignes = GeneratedColumn<int>(
    'lignes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colonnesMeta = const VerificationMeta(
    'colonnes',
  );
  @override
  late final GeneratedColumn<int> colonnes = GeneratedColumn<int>(
    'colonnes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capaciteMeta = const VerificationMeta(
    'capacite',
  );
  @override
  late final GeneratedColumn<int> capacite = GeneratedColumn<int>(
    'capacite',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    caveId,
    parentId,
    nom,
    typeEmplacement,
    lignes,
    colonnes,
    capacite,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'emplacement';
  @override
  VerificationContext validateIntegrity(
    Insertable<StorageLocation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('cave_id')) {
      context.handle(
        _caveIdMeta,
        caveId.isAcceptableOrUnknown(data['cave_id']!, _caveIdMeta),
      );
    } else if (isInserting) {
      context.missing(_caveIdMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('nom')) {
      context.handle(
        _nomMeta,
        nom.isAcceptableOrUnknown(data['nom']!, _nomMeta),
      );
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('type_emplacement')) {
      context.handle(
        _typeEmplacementMeta,
        typeEmplacement.isAcceptableOrUnknown(
          data['type_emplacement']!,
          _typeEmplacementMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_typeEmplacementMeta);
    }
    if (data.containsKey('lignes')) {
      context.handle(
        _lignesMeta,
        lignes.isAcceptableOrUnknown(data['lignes']!, _lignesMeta),
      );
    }
    if (data.containsKey('colonnes')) {
      context.handle(
        _colonnesMeta,
        colonnes.isAcceptableOrUnknown(data['colonnes']!, _colonnesMeta),
      );
    }
    if (data.containsKey('capacite')) {
      context.handle(
        _capaciteMeta,
        capacite.isAcceptableOrUnknown(data['capacite']!, _capaciteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StorageLocation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StorageLocation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      caveId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cave_id'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      nom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nom'],
      )!,
      typeEmplacement: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_emplacement'],
      )!,
      lignes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lignes'],
      ),
      colonnes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}colonnes'],
      ),
      capacite: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}capacite'],
      ),
    );
  }

  @override
  $StorageLocationsTable createAlias(String alias) {
    return $StorageLocationsTable(attachedDatabase, alias);
  }
}

class StorageLocation extends DataClass implements Insertable<StorageLocation> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String caveId;
  final String? parentId;
  final String nom;
  final String typeEmplacement;
  final int? lignes;
  final int? colonnes;
  final int? capacite;
  const StorageLocation({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.caveId,
    this.parentId,
    required this.nom,
    required this.typeEmplacement,
    this.lignes,
    this.colonnes,
    this.capacite,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['cave_id'] = Variable<String>(caveId);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['nom'] = Variable<String>(nom);
    map['type_emplacement'] = Variable<String>(typeEmplacement);
    if (!nullToAbsent || lignes != null) {
      map['lignes'] = Variable<int>(lignes);
    }
    if (!nullToAbsent || colonnes != null) {
      map['colonnes'] = Variable<int>(colonnes);
    }
    if (!nullToAbsent || capacite != null) {
      map['capacite'] = Variable<int>(capacite);
    }
    return map;
  }

  StorageLocationsCompanion toCompanion(bool nullToAbsent) {
    return StorageLocationsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      caveId: Value(caveId),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      nom: Value(nom),
      typeEmplacement: Value(typeEmplacement),
      lignes: lignes == null && nullToAbsent
          ? const Value.absent()
          : Value(lignes),
      colonnes: colonnes == null && nullToAbsent
          ? const Value.absent()
          : Value(colonnes),
      capacite: capacite == null && nullToAbsent
          ? const Value.absent()
          : Value(capacite),
    );
  }

  factory StorageLocation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StorageLocation(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      caveId: serializer.fromJson<String>(json['caveId']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      nom: serializer.fromJson<String>(json['nom']),
      typeEmplacement: serializer.fromJson<String>(json['typeEmplacement']),
      lignes: serializer.fromJson<int?>(json['lignes']),
      colonnes: serializer.fromJson<int?>(json['colonnes']),
      capacite: serializer.fromJson<int?>(json['capacite']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'caveId': serializer.toJson<String>(caveId),
      'parentId': serializer.toJson<String?>(parentId),
      'nom': serializer.toJson<String>(nom),
      'typeEmplacement': serializer.toJson<String>(typeEmplacement),
      'lignes': serializer.toJson<int?>(lignes),
      'colonnes': serializer.toJson<int?>(colonnes),
      'capacite': serializer.toJson<int?>(capacite),
    };
  }

  StorageLocation copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? caveId,
    Value<String?> parentId = const Value.absent(),
    String? nom,
    String? typeEmplacement,
    Value<int?> lignes = const Value.absent(),
    Value<int?> colonnes = const Value.absent(),
    Value<int?> capacite = const Value.absent(),
  }) => StorageLocation(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    caveId: caveId ?? this.caveId,
    parentId: parentId.present ? parentId.value : this.parentId,
    nom: nom ?? this.nom,
    typeEmplacement: typeEmplacement ?? this.typeEmplacement,
    lignes: lignes.present ? lignes.value : this.lignes,
    colonnes: colonnes.present ? colonnes.value : this.colonnes,
    capacite: capacite.present ? capacite.value : this.capacite,
  );
  StorageLocation copyWithCompanion(StorageLocationsCompanion data) {
    return StorageLocation(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      caveId: data.caveId.present ? data.caveId.value : this.caveId,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      nom: data.nom.present ? data.nom.value : this.nom,
      typeEmplacement: data.typeEmplacement.present
          ? data.typeEmplacement.value
          : this.typeEmplacement,
      lignes: data.lignes.present ? data.lignes.value : this.lignes,
      colonnes: data.colonnes.present ? data.colonnes.value : this.colonnes,
      capacite: data.capacite.present ? data.capacite.value : this.capacite,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StorageLocation(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('caveId: $caveId, ')
          ..write('parentId: $parentId, ')
          ..write('nom: $nom, ')
          ..write('typeEmplacement: $typeEmplacement, ')
          ..write('lignes: $lignes, ')
          ..write('colonnes: $colonnes, ')
          ..write('capacite: $capacite')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    caveId,
    parentId,
    nom,
    typeEmplacement,
    lignes,
    colonnes,
    capacite,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StorageLocation &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.caveId == this.caveId &&
          other.parentId == this.parentId &&
          other.nom == this.nom &&
          other.typeEmplacement == this.typeEmplacement &&
          other.lignes == this.lignes &&
          other.colonnes == this.colonnes &&
          other.capacite == this.capacite);
}

class StorageLocationsCompanion extends UpdateCompanion<StorageLocation> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> caveId;
  final Value<String?> parentId;
  final Value<String> nom;
  final Value<String> typeEmplacement;
  final Value<int?> lignes;
  final Value<int?> colonnes;
  final Value<int?> capacite;
  final Value<int> rowid;
  const StorageLocationsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.caveId = const Value.absent(),
    this.parentId = const Value.absent(),
    this.nom = const Value.absent(),
    this.typeEmplacement = const Value.absent(),
    this.lignes = const Value.absent(),
    this.colonnes = const Value.absent(),
    this.capacite = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StorageLocationsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String caveId,
    this.parentId = const Value.absent(),
    required String nom,
    required String typeEmplacement,
    this.lignes = const Value.absent(),
    this.colonnes = const Value.absent(),
    this.capacite = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       caveId = Value(caveId),
       nom = Value(nom),
       typeEmplacement = Value(typeEmplacement);
  static Insertable<StorageLocation> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? caveId,
    Expression<String>? parentId,
    Expression<String>? nom,
    Expression<String>? typeEmplacement,
    Expression<int>? lignes,
    Expression<int>? colonnes,
    Expression<int>? capacite,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (caveId != null) 'cave_id': caveId,
      if (parentId != null) 'parent_id': parentId,
      if (nom != null) 'nom': nom,
      if (typeEmplacement != null) 'type_emplacement': typeEmplacement,
      if (lignes != null) 'lignes': lignes,
      if (colonnes != null) 'colonnes': colonnes,
      if (capacite != null) 'capacite': capacite,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StorageLocationsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? caveId,
    Value<String?>? parentId,
    Value<String>? nom,
    Value<String>? typeEmplacement,
    Value<int?>? lignes,
    Value<int?>? colonnes,
    Value<int?>? capacite,
    Value<int>? rowid,
  }) {
    return StorageLocationsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      caveId: caveId ?? this.caveId,
      parentId: parentId ?? this.parentId,
      nom: nom ?? this.nom,
      typeEmplacement: typeEmplacement ?? this.typeEmplacement,
      lignes: lignes ?? this.lignes,
      colonnes: colonnes ?? this.colonnes,
      capacite: capacite ?? this.capacite,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (caveId.present) {
      map['cave_id'] = Variable<String>(caveId.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (typeEmplacement.present) {
      map['type_emplacement'] = Variable<String>(typeEmplacement.value);
    }
    if (lignes.present) {
      map['lignes'] = Variable<int>(lignes.value);
    }
    if (colonnes.present) {
      map['colonnes'] = Variable<int>(colonnes.value);
    }
    if (capacite.present) {
      map['capacite'] = Variable<int>(capacite.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StorageLocationsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('caveId: $caveId, ')
          ..write('parentId: $parentId, ')
          ..write('nom: $nom, ')
          ..write('typeEmplacement: $typeEmplacement, ')
          ..write('lignes: $lignes, ')
          ..write('colonnes: $colonnes, ')
          ..write('capacite: $capacite, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockLotsTable extends StockLots
    with TableInfo<$StockLotsTable, StockLot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockLotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caveIdMeta = const VerificationMeta('caveId');
  @override
  late final GeneratedColumn<String> caveId = GeneratedColumn<String>(
    'cave_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cave (id)',
    ),
  );
  static const VerificationMeta _ficheIdMeta = const VerificationMeta(
    'ficheId',
  );
  @override
  late final GeneratedColumn<String> ficheId = GeneratedColumn<String>(
    'fiche_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES fiche_vin (id)',
    ),
  );
  static const VerificationMeta _formatClMeta = const VerificationMeta(
    'formatCl',
  );
  @override
  late final GeneratedColumn<double> formatCl = GeneratedColumn<double>(
    'format_cl',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(75),
  );
  static const VerificationMeta _proprietaireIdMeta = const VerificationMeta(
    'proprietaireId',
  );
  @override
  late final GeneratedColumn<String> proprietaireId = GeneratedColumn<String>(
    'proprietaire_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES proprietaire (id)',
    ),
  );
  static const VerificationMeta _emplacementIdMeta = const VerificationMeta(
    'emplacementId',
  );
  @override
  late final GeneratedColumn<String> emplacementId = GeneratedColumn<String>(
    'emplacement_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES emplacement (id)',
    ),
  );
  static const VerificationMeta _positionsMeta = const VerificationMeta(
    'positions',
  );
  @override
  late final GeneratedColumn<String> positions = GeneratedColumn<String>(
    'positions',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _prixAchatUnitaireMeta = const VerificationMeta(
    'prixAchatUnitaire',
  );
  @override
  late final GeneratedColumn<double> prixAchatUnitaire =
      GeneratedColumn<double>(
        'prix_achat_unitaire',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _dateAchatMeta = const VerificationMeta(
    'dateAchat',
  );
  @override
  late final GeneratedColumn<String> dateAchat = GeneratedColumn<String>(
    'date_achat',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fournisseurMeta = const VerificationMeta(
    'fournisseur',
  );
  @override
  late final GeneratedColumn<String> fournisseur = GeneratedColumn<String>(
    'fournisseur',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    caveId,
    ficheId,
    formatCl,
    proprietaireId,
    emplacementId,
    positions,
    prixAchatUnitaire,
    dateAchat,
    fournisseur,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lot';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockLot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('cave_id')) {
      context.handle(
        _caveIdMeta,
        caveId.isAcceptableOrUnknown(data['cave_id']!, _caveIdMeta),
      );
    } else if (isInserting) {
      context.missing(_caveIdMeta);
    }
    if (data.containsKey('fiche_id')) {
      context.handle(
        _ficheIdMeta,
        ficheId.isAcceptableOrUnknown(data['fiche_id']!, _ficheIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ficheIdMeta);
    }
    if (data.containsKey('format_cl')) {
      context.handle(
        _formatClMeta,
        formatCl.isAcceptableOrUnknown(data['format_cl']!, _formatClMeta),
      );
    }
    if (data.containsKey('proprietaire_id')) {
      context.handle(
        _proprietaireIdMeta,
        proprietaireId.isAcceptableOrUnknown(
          data['proprietaire_id']!,
          _proprietaireIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_proprietaireIdMeta);
    }
    if (data.containsKey('emplacement_id')) {
      context.handle(
        _emplacementIdMeta,
        emplacementId.isAcceptableOrUnknown(
          data['emplacement_id']!,
          _emplacementIdMeta,
        ),
      );
    }
    if (data.containsKey('positions')) {
      context.handle(
        _positionsMeta,
        positions.isAcceptableOrUnknown(data['positions']!, _positionsMeta),
      );
    }
    if (data.containsKey('prix_achat_unitaire')) {
      context.handle(
        _prixAchatUnitaireMeta,
        prixAchatUnitaire.isAcceptableOrUnknown(
          data['prix_achat_unitaire']!,
          _prixAchatUnitaireMeta,
        ),
      );
    }
    if (data.containsKey('date_achat')) {
      context.handle(
        _dateAchatMeta,
        dateAchat.isAcceptableOrUnknown(data['date_achat']!, _dateAchatMeta),
      );
    }
    if (data.containsKey('fournisseur')) {
      context.handle(
        _fournisseurMeta,
        fournisseur.isAcceptableOrUnknown(
          data['fournisseur']!,
          _fournisseurMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockLot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockLot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      caveId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cave_id'],
      )!,
      ficheId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fiche_id'],
      )!,
      formatCl: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}format_cl'],
      )!,
      proprietaireId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}proprietaire_id'],
      )!,
      emplacementId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emplacement_id'],
      ),
      positions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}positions'],
      ),
      prixAchatUnitaire: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}prix_achat_unitaire'],
      ),
      dateAchat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_achat'],
      ),
      fournisseur: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fournisseur'],
      ),
    );
  }

  @override
  $StockLotsTable createAlias(String alias) {
    return $StockLotsTable(attachedDatabase, alias);
  }
}

class StockLot extends DataClass implements Insertable<StockLot> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String caveId;
  final String ficheId;
  final double formatCl;
  final String proprietaireId;
  final String? emplacementId;
  final String? positions;
  final double? prixAchatUnitaire;
  final String? dateAchat;
  final String? fournisseur;
  const StockLot({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.caveId,
    required this.ficheId,
    required this.formatCl,
    required this.proprietaireId,
    this.emplacementId,
    this.positions,
    this.prixAchatUnitaire,
    this.dateAchat,
    this.fournisseur,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['cave_id'] = Variable<String>(caveId);
    map['fiche_id'] = Variable<String>(ficheId);
    map['format_cl'] = Variable<double>(formatCl);
    map['proprietaire_id'] = Variable<String>(proprietaireId);
    if (!nullToAbsent || emplacementId != null) {
      map['emplacement_id'] = Variable<String>(emplacementId);
    }
    if (!nullToAbsent || positions != null) {
      map['positions'] = Variable<String>(positions);
    }
    if (!nullToAbsent || prixAchatUnitaire != null) {
      map['prix_achat_unitaire'] = Variable<double>(prixAchatUnitaire);
    }
    if (!nullToAbsent || dateAchat != null) {
      map['date_achat'] = Variable<String>(dateAchat);
    }
    if (!nullToAbsent || fournisseur != null) {
      map['fournisseur'] = Variable<String>(fournisseur);
    }
    return map;
  }

  StockLotsCompanion toCompanion(bool nullToAbsent) {
    return StockLotsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      caveId: Value(caveId),
      ficheId: Value(ficheId),
      formatCl: Value(formatCl),
      proprietaireId: Value(proprietaireId),
      emplacementId: emplacementId == null && nullToAbsent
          ? const Value.absent()
          : Value(emplacementId),
      positions: positions == null && nullToAbsent
          ? const Value.absent()
          : Value(positions),
      prixAchatUnitaire: prixAchatUnitaire == null && nullToAbsent
          ? const Value.absent()
          : Value(prixAchatUnitaire),
      dateAchat: dateAchat == null && nullToAbsent
          ? const Value.absent()
          : Value(dateAchat),
      fournisseur: fournisseur == null && nullToAbsent
          ? const Value.absent()
          : Value(fournisseur),
    );
  }

  factory StockLot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockLot(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      caveId: serializer.fromJson<String>(json['caveId']),
      ficheId: serializer.fromJson<String>(json['ficheId']),
      formatCl: serializer.fromJson<double>(json['formatCl']),
      proprietaireId: serializer.fromJson<String>(json['proprietaireId']),
      emplacementId: serializer.fromJson<String?>(json['emplacementId']),
      positions: serializer.fromJson<String?>(json['positions']),
      prixAchatUnitaire: serializer.fromJson<double?>(
        json['prixAchatUnitaire'],
      ),
      dateAchat: serializer.fromJson<String?>(json['dateAchat']),
      fournisseur: serializer.fromJson<String?>(json['fournisseur']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'caveId': serializer.toJson<String>(caveId),
      'ficheId': serializer.toJson<String>(ficheId),
      'formatCl': serializer.toJson<double>(formatCl),
      'proprietaireId': serializer.toJson<String>(proprietaireId),
      'emplacementId': serializer.toJson<String?>(emplacementId),
      'positions': serializer.toJson<String?>(positions),
      'prixAchatUnitaire': serializer.toJson<double?>(prixAchatUnitaire),
      'dateAchat': serializer.toJson<String?>(dateAchat),
      'fournisseur': serializer.toJson<String?>(fournisseur),
    };
  }

  StockLot copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? caveId,
    String? ficheId,
    double? formatCl,
    String? proprietaireId,
    Value<String?> emplacementId = const Value.absent(),
    Value<String?> positions = const Value.absent(),
    Value<double?> prixAchatUnitaire = const Value.absent(),
    Value<String?> dateAchat = const Value.absent(),
    Value<String?> fournisseur = const Value.absent(),
  }) => StockLot(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    caveId: caveId ?? this.caveId,
    ficheId: ficheId ?? this.ficheId,
    formatCl: formatCl ?? this.formatCl,
    proprietaireId: proprietaireId ?? this.proprietaireId,
    emplacementId: emplacementId.present
        ? emplacementId.value
        : this.emplacementId,
    positions: positions.present ? positions.value : this.positions,
    prixAchatUnitaire: prixAchatUnitaire.present
        ? prixAchatUnitaire.value
        : this.prixAchatUnitaire,
    dateAchat: dateAchat.present ? dateAchat.value : this.dateAchat,
    fournisseur: fournisseur.present ? fournisseur.value : this.fournisseur,
  );
  StockLot copyWithCompanion(StockLotsCompanion data) {
    return StockLot(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      caveId: data.caveId.present ? data.caveId.value : this.caveId,
      ficheId: data.ficheId.present ? data.ficheId.value : this.ficheId,
      formatCl: data.formatCl.present ? data.formatCl.value : this.formatCl,
      proprietaireId: data.proprietaireId.present
          ? data.proprietaireId.value
          : this.proprietaireId,
      emplacementId: data.emplacementId.present
          ? data.emplacementId.value
          : this.emplacementId,
      positions: data.positions.present ? data.positions.value : this.positions,
      prixAchatUnitaire: data.prixAchatUnitaire.present
          ? data.prixAchatUnitaire.value
          : this.prixAchatUnitaire,
      dateAchat: data.dateAchat.present ? data.dateAchat.value : this.dateAchat,
      fournisseur: data.fournisseur.present
          ? data.fournisseur.value
          : this.fournisseur,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockLot(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('caveId: $caveId, ')
          ..write('ficheId: $ficheId, ')
          ..write('formatCl: $formatCl, ')
          ..write('proprietaireId: $proprietaireId, ')
          ..write('emplacementId: $emplacementId, ')
          ..write('positions: $positions, ')
          ..write('prixAchatUnitaire: $prixAchatUnitaire, ')
          ..write('dateAchat: $dateAchat, ')
          ..write('fournisseur: $fournisseur')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    caveId,
    ficheId,
    formatCl,
    proprietaireId,
    emplacementId,
    positions,
    prixAchatUnitaire,
    dateAchat,
    fournisseur,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockLot &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.caveId == this.caveId &&
          other.ficheId == this.ficheId &&
          other.formatCl == this.formatCl &&
          other.proprietaireId == this.proprietaireId &&
          other.emplacementId == this.emplacementId &&
          other.positions == this.positions &&
          other.prixAchatUnitaire == this.prixAchatUnitaire &&
          other.dateAchat == this.dateAchat &&
          other.fournisseur == this.fournisseur);
}

class StockLotsCompanion extends UpdateCompanion<StockLot> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> caveId;
  final Value<String> ficheId;
  final Value<double> formatCl;
  final Value<String> proprietaireId;
  final Value<String?> emplacementId;
  final Value<String?> positions;
  final Value<double?> prixAchatUnitaire;
  final Value<String?> dateAchat;
  final Value<String?> fournisseur;
  final Value<int> rowid;
  const StockLotsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.caveId = const Value.absent(),
    this.ficheId = const Value.absent(),
    this.formatCl = const Value.absent(),
    this.proprietaireId = const Value.absent(),
    this.emplacementId = const Value.absent(),
    this.positions = const Value.absent(),
    this.prixAchatUnitaire = const Value.absent(),
    this.dateAchat = const Value.absent(),
    this.fournisseur = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockLotsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String caveId,
    required String ficheId,
    this.formatCl = const Value.absent(),
    required String proprietaireId,
    this.emplacementId = const Value.absent(),
    this.positions = const Value.absent(),
    this.prixAchatUnitaire = const Value.absent(),
    this.dateAchat = const Value.absent(),
    this.fournisseur = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       caveId = Value(caveId),
       ficheId = Value(ficheId),
       proprietaireId = Value(proprietaireId);
  static Insertable<StockLot> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? caveId,
    Expression<String>? ficheId,
    Expression<double>? formatCl,
    Expression<String>? proprietaireId,
    Expression<String>? emplacementId,
    Expression<String>? positions,
    Expression<double>? prixAchatUnitaire,
    Expression<String>? dateAchat,
    Expression<String>? fournisseur,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (caveId != null) 'cave_id': caveId,
      if (ficheId != null) 'fiche_id': ficheId,
      if (formatCl != null) 'format_cl': formatCl,
      if (proprietaireId != null) 'proprietaire_id': proprietaireId,
      if (emplacementId != null) 'emplacement_id': emplacementId,
      if (positions != null) 'positions': positions,
      if (prixAchatUnitaire != null) 'prix_achat_unitaire': prixAchatUnitaire,
      if (dateAchat != null) 'date_achat': dateAchat,
      if (fournisseur != null) 'fournisseur': fournisseur,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockLotsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? caveId,
    Value<String>? ficheId,
    Value<double>? formatCl,
    Value<String>? proprietaireId,
    Value<String?>? emplacementId,
    Value<String?>? positions,
    Value<double?>? prixAchatUnitaire,
    Value<String?>? dateAchat,
    Value<String?>? fournisseur,
    Value<int>? rowid,
  }) {
    return StockLotsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      caveId: caveId ?? this.caveId,
      ficheId: ficheId ?? this.ficheId,
      formatCl: formatCl ?? this.formatCl,
      proprietaireId: proprietaireId ?? this.proprietaireId,
      emplacementId: emplacementId ?? this.emplacementId,
      positions: positions ?? this.positions,
      prixAchatUnitaire: prixAchatUnitaire ?? this.prixAchatUnitaire,
      dateAchat: dateAchat ?? this.dateAchat,
      fournisseur: fournisseur ?? this.fournisseur,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (caveId.present) {
      map['cave_id'] = Variable<String>(caveId.value);
    }
    if (ficheId.present) {
      map['fiche_id'] = Variable<String>(ficheId.value);
    }
    if (formatCl.present) {
      map['format_cl'] = Variable<double>(formatCl.value);
    }
    if (proprietaireId.present) {
      map['proprietaire_id'] = Variable<String>(proprietaireId.value);
    }
    if (emplacementId.present) {
      map['emplacement_id'] = Variable<String>(emplacementId.value);
    }
    if (positions.present) {
      map['positions'] = Variable<String>(positions.value);
    }
    if (prixAchatUnitaire.present) {
      map['prix_achat_unitaire'] = Variable<double>(prixAchatUnitaire.value);
    }
    if (dateAchat.present) {
      map['date_achat'] = Variable<String>(dateAchat.value);
    }
    if (fournisseur.present) {
      map['fournisseur'] = Variable<String>(fournisseur.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockLotsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('caveId: $caveId, ')
          ..write('ficheId: $ficheId, ')
          ..write('formatCl: $formatCl, ')
          ..write('proprietaireId: $proprietaireId, ')
          ..write('emplacementId: $emplacementId, ')
          ..write('positions: $positions, ')
          ..write('prixAchatUnitaire: $prixAchatUnitaire, ')
          ..write('dateAchat: $dateAchat, ')
          ..write('fournisseur: $fournisseur, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockMovementsTable extends StockMovements
    with TableInfo<$StockMovementsTable, StockMovement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caveIdMeta = const VerificationMeta('caveId');
  @override
  late final GeneratedColumn<String> caveId = GeneratedColumn<String>(
    'cave_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cave (id)',
    ),
  );
  static const VerificationMeta _lotIdMeta = const VerificationMeta('lotId');
  @override
  late final GeneratedColumn<String> lotId = GeneratedColumn<String>(
    'lot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES lot (id)',
    ),
  );
  static const VerificationMeta _typeMouvementMeta = const VerificationMeta(
    'typeMouvement',
  );
  @override
  late final GeneratedColumn<String> typeMouvement = GeneratedColumn<String>(
    'type_mouvement',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantiteMeta = const VerificationMeta(
    'quantite',
  );
  @override
  late final GeneratedColumn<int> quantite = GeneratedColumn<int>(
    'quantite',
    aliasedName,
    false,
    check: () => BooleanExpressionOperators(quantite.equals(0)).not(),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMouvementMeta = const VerificationMeta(
    'dateMouvement',
  );
  @override
  late final GeneratedColumn<String> dateMouvement = GeneratedColumn<String>(
    'date_mouvement',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _motifMeta = const VerificationMeta('motif');
  @override
  late final GeneratedColumn<String> motif = GeneratedColumn<String>(
    'motif',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commentaireMeta = const VerificationMeta(
    'commentaire',
  );
  @override
  late final GeneratedColumn<String> commentaire = GeneratedColumn<String>(
    'commentaire',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lotLieIdMeta = const VerificationMeta(
    'lotLieId',
  );
  @override
  late final GeneratedColumn<String> lotLieId = GeneratedColumn<String>(
    'lot_lie_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES lot (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    caveId,
    lotId,
    typeMouvement,
    quantite,
    dateMouvement,
    motif,
    commentaire,
    lotLieId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mouvement';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockMovement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('cave_id')) {
      context.handle(
        _caveIdMeta,
        caveId.isAcceptableOrUnknown(data['cave_id']!, _caveIdMeta),
      );
    } else if (isInserting) {
      context.missing(_caveIdMeta);
    }
    if (data.containsKey('lot_id')) {
      context.handle(
        _lotIdMeta,
        lotId.isAcceptableOrUnknown(data['lot_id']!, _lotIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lotIdMeta);
    }
    if (data.containsKey('type_mouvement')) {
      context.handle(
        _typeMouvementMeta,
        typeMouvement.isAcceptableOrUnknown(
          data['type_mouvement']!,
          _typeMouvementMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_typeMouvementMeta);
    }
    if (data.containsKey('quantite')) {
      context.handle(
        _quantiteMeta,
        quantite.isAcceptableOrUnknown(data['quantite']!, _quantiteMeta),
      );
    } else if (isInserting) {
      context.missing(_quantiteMeta);
    }
    if (data.containsKey('date_mouvement')) {
      context.handle(
        _dateMouvementMeta,
        dateMouvement.isAcceptableOrUnknown(
          data['date_mouvement']!,
          _dateMouvementMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateMouvementMeta);
    }
    if (data.containsKey('motif')) {
      context.handle(
        _motifMeta,
        motif.isAcceptableOrUnknown(data['motif']!, _motifMeta),
      );
    }
    if (data.containsKey('commentaire')) {
      context.handle(
        _commentaireMeta,
        commentaire.isAcceptableOrUnknown(
          data['commentaire']!,
          _commentaireMeta,
        ),
      );
    }
    if (data.containsKey('lot_lie_id')) {
      context.handle(
        _lotLieIdMeta,
        lotLieId.isAcceptableOrUnknown(data['lot_lie_id']!, _lotLieIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockMovement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockMovement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      caveId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cave_id'],
      )!,
      lotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lot_id'],
      )!,
      typeMouvement: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_mouvement'],
      )!,
      quantite: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantite'],
      )!,
      dateMouvement: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_mouvement'],
      )!,
      motif: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}motif'],
      ),
      commentaire: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}commentaire'],
      ),
      lotLieId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lot_lie_id'],
      ),
    );
  }

  @override
  $StockMovementsTable createAlias(String alias) {
    return $StockMovementsTable(attachedDatabase, alias);
  }
}

class StockMovement extends DataClass implements Insertable<StockMovement> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String caveId;
  final String lotId;
  final String typeMouvement;

  /// Signée, jamais 0 (STK-R1 à STK-R4).
  final int quantite;
  final String dateMouvement;
  final String? motif;
  final String? commentaire;
  final String? lotLieId;
  const StockMovement({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.caveId,
    required this.lotId,
    required this.typeMouvement,
    required this.quantite,
    required this.dateMouvement,
    this.motif,
    this.commentaire,
    this.lotLieId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['cave_id'] = Variable<String>(caveId);
    map['lot_id'] = Variable<String>(lotId);
    map['type_mouvement'] = Variable<String>(typeMouvement);
    map['quantite'] = Variable<int>(quantite);
    map['date_mouvement'] = Variable<String>(dateMouvement);
    if (!nullToAbsent || motif != null) {
      map['motif'] = Variable<String>(motif);
    }
    if (!nullToAbsent || commentaire != null) {
      map['commentaire'] = Variable<String>(commentaire);
    }
    if (!nullToAbsent || lotLieId != null) {
      map['lot_lie_id'] = Variable<String>(lotLieId);
    }
    return map;
  }

  StockMovementsCompanion toCompanion(bool nullToAbsent) {
    return StockMovementsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      caveId: Value(caveId),
      lotId: Value(lotId),
      typeMouvement: Value(typeMouvement),
      quantite: Value(quantite),
      dateMouvement: Value(dateMouvement),
      motif: motif == null && nullToAbsent
          ? const Value.absent()
          : Value(motif),
      commentaire: commentaire == null && nullToAbsent
          ? const Value.absent()
          : Value(commentaire),
      lotLieId: lotLieId == null && nullToAbsent
          ? const Value.absent()
          : Value(lotLieId),
    );
  }

  factory StockMovement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockMovement(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      caveId: serializer.fromJson<String>(json['caveId']),
      lotId: serializer.fromJson<String>(json['lotId']),
      typeMouvement: serializer.fromJson<String>(json['typeMouvement']),
      quantite: serializer.fromJson<int>(json['quantite']),
      dateMouvement: serializer.fromJson<String>(json['dateMouvement']),
      motif: serializer.fromJson<String?>(json['motif']),
      commentaire: serializer.fromJson<String?>(json['commentaire']),
      lotLieId: serializer.fromJson<String?>(json['lotLieId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'caveId': serializer.toJson<String>(caveId),
      'lotId': serializer.toJson<String>(lotId),
      'typeMouvement': serializer.toJson<String>(typeMouvement),
      'quantite': serializer.toJson<int>(quantite),
      'dateMouvement': serializer.toJson<String>(dateMouvement),
      'motif': serializer.toJson<String?>(motif),
      'commentaire': serializer.toJson<String?>(commentaire),
      'lotLieId': serializer.toJson<String?>(lotLieId),
    };
  }

  StockMovement copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? caveId,
    String? lotId,
    String? typeMouvement,
    int? quantite,
    String? dateMouvement,
    Value<String?> motif = const Value.absent(),
    Value<String?> commentaire = const Value.absent(),
    Value<String?> lotLieId = const Value.absent(),
  }) => StockMovement(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    caveId: caveId ?? this.caveId,
    lotId: lotId ?? this.lotId,
    typeMouvement: typeMouvement ?? this.typeMouvement,
    quantite: quantite ?? this.quantite,
    dateMouvement: dateMouvement ?? this.dateMouvement,
    motif: motif.present ? motif.value : this.motif,
    commentaire: commentaire.present ? commentaire.value : this.commentaire,
    lotLieId: lotLieId.present ? lotLieId.value : this.lotLieId,
  );
  StockMovement copyWithCompanion(StockMovementsCompanion data) {
    return StockMovement(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      caveId: data.caveId.present ? data.caveId.value : this.caveId,
      lotId: data.lotId.present ? data.lotId.value : this.lotId,
      typeMouvement: data.typeMouvement.present
          ? data.typeMouvement.value
          : this.typeMouvement,
      quantite: data.quantite.present ? data.quantite.value : this.quantite,
      dateMouvement: data.dateMouvement.present
          ? data.dateMouvement.value
          : this.dateMouvement,
      motif: data.motif.present ? data.motif.value : this.motif,
      commentaire: data.commentaire.present
          ? data.commentaire.value
          : this.commentaire,
      lotLieId: data.lotLieId.present ? data.lotLieId.value : this.lotLieId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockMovement(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('caveId: $caveId, ')
          ..write('lotId: $lotId, ')
          ..write('typeMouvement: $typeMouvement, ')
          ..write('quantite: $quantite, ')
          ..write('dateMouvement: $dateMouvement, ')
          ..write('motif: $motif, ')
          ..write('commentaire: $commentaire, ')
          ..write('lotLieId: $lotLieId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    caveId,
    lotId,
    typeMouvement,
    quantite,
    dateMouvement,
    motif,
    commentaire,
    lotLieId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockMovement &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.caveId == this.caveId &&
          other.lotId == this.lotId &&
          other.typeMouvement == this.typeMouvement &&
          other.quantite == this.quantite &&
          other.dateMouvement == this.dateMouvement &&
          other.motif == this.motif &&
          other.commentaire == this.commentaire &&
          other.lotLieId == this.lotLieId);
}

class StockMovementsCompanion extends UpdateCompanion<StockMovement> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> caveId;
  final Value<String> lotId;
  final Value<String> typeMouvement;
  final Value<int> quantite;
  final Value<String> dateMouvement;
  final Value<String?> motif;
  final Value<String?> commentaire;
  final Value<String?> lotLieId;
  final Value<int> rowid;
  const StockMovementsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.caveId = const Value.absent(),
    this.lotId = const Value.absent(),
    this.typeMouvement = const Value.absent(),
    this.quantite = const Value.absent(),
    this.dateMouvement = const Value.absent(),
    this.motif = const Value.absent(),
    this.commentaire = const Value.absent(),
    this.lotLieId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockMovementsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String caveId,
    required String lotId,
    required String typeMouvement,
    required int quantite,
    required String dateMouvement,
    this.motif = const Value.absent(),
    this.commentaire = const Value.absent(),
    this.lotLieId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       caveId = Value(caveId),
       lotId = Value(lotId),
       typeMouvement = Value(typeMouvement),
       quantite = Value(quantite),
       dateMouvement = Value(dateMouvement);
  static Insertable<StockMovement> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? caveId,
    Expression<String>? lotId,
    Expression<String>? typeMouvement,
    Expression<int>? quantite,
    Expression<String>? dateMouvement,
    Expression<String>? motif,
    Expression<String>? commentaire,
    Expression<String>? lotLieId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (caveId != null) 'cave_id': caveId,
      if (lotId != null) 'lot_id': lotId,
      if (typeMouvement != null) 'type_mouvement': typeMouvement,
      if (quantite != null) 'quantite': quantite,
      if (dateMouvement != null) 'date_mouvement': dateMouvement,
      if (motif != null) 'motif': motif,
      if (commentaire != null) 'commentaire': commentaire,
      if (lotLieId != null) 'lot_lie_id': lotLieId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockMovementsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? caveId,
    Value<String>? lotId,
    Value<String>? typeMouvement,
    Value<int>? quantite,
    Value<String>? dateMouvement,
    Value<String?>? motif,
    Value<String?>? commentaire,
    Value<String?>? lotLieId,
    Value<int>? rowid,
  }) {
    return StockMovementsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      caveId: caveId ?? this.caveId,
      lotId: lotId ?? this.lotId,
      typeMouvement: typeMouvement ?? this.typeMouvement,
      quantite: quantite ?? this.quantite,
      dateMouvement: dateMouvement ?? this.dateMouvement,
      motif: motif ?? this.motif,
      commentaire: commentaire ?? this.commentaire,
      lotLieId: lotLieId ?? this.lotLieId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (caveId.present) {
      map['cave_id'] = Variable<String>(caveId.value);
    }
    if (lotId.present) {
      map['lot_id'] = Variable<String>(lotId.value);
    }
    if (typeMouvement.present) {
      map['type_mouvement'] = Variable<String>(typeMouvement.value);
    }
    if (quantite.present) {
      map['quantite'] = Variable<int>(quantite.value);
    }
    if (dateMouvement.present) {
      map['date_mouvement'] = Variable<String>(dateMouvement.value);
    }
    if (motif.present) {
      map['motif'] = Variable<String>(motif.value);
    }
    if (commentaire.present) {
      map['commentaire'] = Variable<String>(commentaire.value);
    }
    if (lotLieId.present) {
      map['lot_lie_id'] = Variable<String>(lotLieId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockMovementsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('caveId: $caveId, ')
          ..write('lotId: $lotId, ')
          ..write('typeMouvement: $typeMouvement, ')
          ..write('quantite: $quantite, ')
          ..write('dateMouvement: $dateMouvement, ')
          ..write('motif: $motif, ')
          ..write('commentaire: $commentaire, ')
          ..write('lotLieId: $lotLieId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TastingsTable extends Tastings with TableInfo<$TastingsTable, Tasting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TastingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caveIdMeta = const VerificationMeta('caveId');
  @override
  late final GeneratedColumn<String> caveId = GeneratedColumn<String>(
    'cave_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cave (id)',
    ),
  );
  static const VerificationMeta _ficheIdMeta = const VerificationMeta(
    'ficheId',
  );
  @override
  late final GeneratedColumn<String> ficheId = GeneratedColumn<String>(
    'fiche_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES fiche_vin (id)',
    ),
  );
  static const VerificationMeta _dateDegustationMeta = const VerificationMeta(
    'dateDegustation',
  );
  @override
  late final GeneratedColumn<String> dateDegustation = GeneratedColumn<String>(
    'date_degustation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notePersoMeta = const VerificationMeta(
    'notePerso',
  );
  @override
  late final GeneratedColumn<double> notePerso = GeneratedColumn<double>(
    'note_perso',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commentaireMeta = const VerificationMeta(
    'commentaire',
  );
  @override
  late final GeneratedColumn<String> commentaire = GeneratedColumn<String>(
    'commentaire',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _platMeta = const VerificationMeta('plat');
  @override
  late final GeneratedColumn<String> plat = GeneratedColumn<String>(
    'plat',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mouvementIdMeta = const VerificationMeta(
    'mouvementId',
  );
  @override
  late final GeneratedColumn<String> mouvementId = GeneratedColumn<String>(
    'mouvement_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES mouvement (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    caveId,
    ficheId,
    dateDegustation,
    notePerso,
    commentaire,
    plat,
    mouvementId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'degustation';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tasting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('cave_id')) {
      context.handle(
        _caveIdMeta,
        caveId.isAcceptableOrUnknown(data['cave_id']!, _caveIdMeta),
      );
    } else if (isInserting) {
      context.missing(_caveIdMeta);
    }
    if (data.containsKey('fiche_id')) {
      context.handle(
        _ficheIdMeta,
        ficheId.isAcceptableOrUnknown(data['fiche_id']!, _ficheIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ficheIdMeta);
    }
    if (data.containsKey('date_degustation')) {
      context.handle(
        _dateDegustationMeta,
        dateDegustation.isAcceptableOrUnknown(
          data['date_degustation']!,
          _dateDegustationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateDegustationMeta);
    }
    if (data.containsKey('note_perso')) {
      context.handle(
        _notePersoMeta,
        notePerso.isAcceptableOrUnknown(data['note_perso']!, _notePersoMeta),
      );
    }
    if (data.containsKey('commentaire')) {
      context.handle(
        _commentaireMeta,
        commentaire.isAcceptableOrUnknown(
          data['commentaire']!,
          _commentaireMeta,
        ),
      );
    }
    if (data.containsKey('plat')) {
      context.handle(
        _platMeta,
        plat.isAcceptableOrUnknown(data['plat']!, _platMeta),
      );
    }
    if (data.containsKey('mouvement_id')) {
      context.handle(
        _mouvementIdMeta,
        mouvementId.isAcceptableOrUnknown(
          data['mouvement_id']!,
          _mouvementIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tasting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tasting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      caveId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cave_id'],
      )!,
      ficheId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fiche_id'],
      )!,
      dateDegustation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_degustation'],
      )!,
      notePerso: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}note_perso'],
      ),
      commentaire: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}commentaire'],
      ),
      plat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plat'],
      ),
      mouvementId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mouvement_id'],
      ),
    );
  }

  @override
  $TastingsTable createAlias(String alias) {
    return $TastingsTable(attachedDatabase, alias);
  }
}

class Tasting extends DataClass implements Insertable<Tasting> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String caveId;
  final String ficheId;
  final String dateDegustation;
  final double? notePerso;
  final String? commentaire;
  final String? plat;
  final String? mouvementId;
  const Tasting({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.caveId,
    required this.ficheId,
    required this.dateDegustation,
    this.notePerso,
    this.commentaire,
    this.plat,
    this.mouvementId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['cave_id'] = Variable<String>(caveId);
    map['fiche_id'] = Variable<String>(ficheId);
    map['date_degustation'] = Variable<String>(dateDegustation);
    if (!nullToAbsent || notePerso != null) {
      map['note_perso'] = Variable<double>(notePerso);
    }
    if (!nullToAbsent || commentaire != null) {
      map['commentaire'] = Variable<String>(commentaire);
    }
    if (!nullToAbsent || plat != null) {
      map['plat'] = Variable<String>(plat);
    }
    if (!nullToAbsent || mouvementId != null) {
      map['mouvement_id'] = Variable<String>(mouvementId);
    }
    return map;
  }

  TastingsCompanion toCompanion(bool nullToAbsent) {
    return TastingsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      caveId: Value(caveId),
      ficheId: Value(ficheId),
      dateDegustation: Value(dateDegustation),
      notePerso: notePerso == null && nullToAbsent
          ? const Value.absent()
          : Value(notePerso),
      commentaire: commentaire == null && nullToAbsent
          ? const Value.absent()
          : Value(commentaire),
      plat: plat == null && nullToAbsent ? const Value.absent() : Value(plat),
      mouvementId: mouvementId == null && nullToAbsent
          ? const Value.absent()
          : Value(mouvementId),
    );
  }

  factory Tasting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tasting(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      caveId: serializer.fromJson<String>(json['caveId']),
      ficheId: serializer.fromJson<String>(json['ficheId']),
      dateDegustation: serializer.fromJson<String>(json['dateDegustation']),
      notePerso: serializer.fromJson<double?>(json['notePerso']),
      commentaire: serializer.fromJson<String?>(json['commentaire']),
      plat: serializer.fromJson<String?>(json['plat']),
      mouvementId: serializer.fromJson<String?>(json['mouvementId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'caveId': serializer.toJson<String>(caveId),
      'ficheId': serializer.toJson<String>(ficheId),
      'dateDegustation': serializer.toJson<String>(dateDegustation),
      'notePerso': serializer.toJson<double?>(notePerso),
      'commentaire': serializer.toJson<String?>(commentaire),
      'plat': serializer.toJson<String?>(plat),
      'mouvementId': serializer.toJson<String?>(mouvementId),
    };
  }

  Tasting copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? caveId,
    String? ficheId,
    String? dateDegustation,
    Value<double?> notePerso = const Value.absent(),
    Value<String?> commentaire = const Value.absent(),
    Value<String?> plat = const Value.absent(),
    Value<String?> mouvementId = const Value.absent(),
  }) => Tasting(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    caveId: caveId ?? this.caveId,
    ficheId: ficheId ?? this.ficheId,
    dateDegustation: dateDegustation ?? this.dateDegustation,
    notePerso: notePerso.present ? notePerso.value : this.notePerso,
    commentaire: commentaire.present ? commentaire.value : this.commentaire,
    plat: plat.present ? plat.value : this.plat,
    mouvementId: mouvementId.present ? mouvementId.value : this.mouvementId,
  );
  Tasting copyWithCompanion(TastingsCompanion data) {
    return Tasting(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      caveId: data.caveId.present ? data.caveId.value : this.caveId,
      ficheId: data.ficheId.present ? data.ficheId.value : this.ficheId,
      dateDegustation: data.dateDegustation.present
          ? data.dateDegustation.value
          : this.dateDegustation,
      notePerso: data.notePerso.present ? data.notePerso.value : this.notePerso,
      commentaire: data.commentaire.present
          ? data.commentaire.value
          : this.commentaire,
      plat: data.plat.present ? data.plat.value : this.plat,
      mouvementId: data.mouvementId.present
          ? data.mouvementId.value
          : this.mouvementId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tasting(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('caveId: $caveId, ')
          ..write('ficheId: $ficheId, ')
          ..write('dateDegustation: $dateDegustation, ')
          ..write('notePerso: $notePerso, ')
          ..write('commentaire: $commentaire, ')
          ..write('plat: $plat, ')
          ..write('mouvementId: $mouvementId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    caveId,
    ficheId,
    dateDegustation,
    notePerso,
    commentaire,
    plat,
    mouvementId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tasting &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.caveId == this.caveId &&
          other.ficheId == this.ficheId &&
          other.dateDegustation == this.dateDegustation &&
          other.notePerso == this.notePerso &&
          other.commentaire == this.commentaire &&
          other.plat == this.plat &&
          other.mouvementId == this.mouvementId);
}

class TastingsCompanion extends UpdateCompanion<Tasting> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> caveId;
  final Value<String> ficheId;
  final Value<String> dateDegustation;
  final Value<double?> notePerso;
  final Value<String?> commentaire;
  final Value<String?> plat;
  final Value<String?> mouvementId;
  final Value<int> rowid;
  const TastingsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.caveId = const Value.absent(),
    this.ficheId = const Value.absent(),
    this.dateDegustation = const Value.absent(),
    this.notePerso = const Value.absent(),
    this.commentaire = const Value.absent(),
    this.plat = const Value.absent(),
    this.mouvementId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TastingsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String caveId,
    required String ficheId,
    required String dateDegustation,
    this.notePerso = const Value.absent(),
    this.commentaire = const Value.absent(),
    this.plat = const Value.absent(),
    this.mouvementId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       caveId = Value(caveId),
       ficheId = Value(ficheId),
       dateDegustation = Value(dateDegustation);
  static Insertable<Tasting> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? caveId,
    Expression<String>? ficheId,
    Expression<String>? dateDegustation,
    Expression<double>? notePerso,
    Expression<String>? commentaire,
    Expression<String>? plat,
    Expression<String>? mouvementId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (caveId != null) 'cave_id': caveId,
      if (ficheId != null) 'fiche_id': ficheId,
      if (dateDegustation != null) 'date_degustation': dateDegustation,
      if (notePerso != null) 'note_perso': notePerso,
      if (commentaire != null) 'commentaire': commentaire,
      if (plat != null) 'plat': plat,
      if (mouvementId != null) 'mouvement_id': mouvementId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TastingsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? caveId,
    Value<String>? ficheId,
    Value<String>? dateDegustation,
    Value<double?>? notePerso,
    Value<String?>? commentaire,
    Value<String?>? plat,
    Value<String?>? mouvementId,
    Value<int>? rowid,
  }) {
    return TastingsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      caveId: caveId ?? this.caveId,
      ficheId: ficheId ?? this.ficheId,
      dateDegustation: dateDegustation ?? this.dateDegustation,
      notePerso: notePerso ?? this.notePerso,
      commentaire: commentaire ?? this.commentaire,
      plat: plat ?? this.plat,
      mouvementId: mouvementId ?? this.mouvementId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (caveId.present) {
      map['cave_id'] = Variable<String>(caveId.value);
    }
    if (ficheId.present) {
      map['fiche_id'] = Variable<String>(ficheId.value);
    }
    if (dateDegustation.present) {
      map['date_degustation'] = Variable<String>(dateDegustation.value);
    }
    if (notePerso.present) {
      map['note_perso'] = Variable<double>(notePerso.value);
    }
    if (commentaire.present) {
      map['commentaire'] = Variable<String>(commentaire.value);
    }
    if (plat.present) {
      map['plat'] = Variable<String>(plat.value);
    }
    if (mouvementId.present) {
      map['mouvement_id'] = Variable<String>(mouvementId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TastingsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('caveId: $caveId, ')
          ..write('ficheId: $ficheId, ')
          ..write('dateDegustation: $dateDegustation, ')
          ..write('notePerso: $notePerso, ')
          ..write('commentaire: $commentaire, ')
          ..write('plat: $plat, ')
          ..write('mouvementId: $mouvementId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MarketPricesTable extends MarketPrices
    with TableInfo<$MarketPricesTable, MarketPrice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MarketPricesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caveIdMeta = const VerificationMeta('caveId');
  @override
  late final GeneratedColumn<String> caveId = GeneratedColumn<String>(
    'cave_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cave (id)',
    ),
  );
  static const VerificationMeta _ficheIdMeta = const VerificationMeta(
    'ficheId',
  );
  @override
  late final GeneratedColumn<String> ficheId = GeneratedColumn<String>(
    'fiche_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES fiche_vin (id)',
    ),
  );
  static const VerificationMeta _formatClMeta = const VerificationMeta(
    'formatCl',
  );
  @override
  late final GeneratedColumn<double> formatCl = GeneratedColumn<double>(
    'format_cl',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateReleveMeta = const VerificationMeta(
    'dateReleve',
  );
  @override
  late final GeneratedColumn<String> dateReleve = GeneratedColumn<String>(
    'date_releve',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prixMeta = const VerificationMeta('prix');
  @override
  late final GeneratedColumn<double> prix = GeneratedColumn<double>(
    'prix',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviseMeta = const VerificationMeta('devise');
  @override
  late final GeneratedColumn<String> devise = GeneratedColumn<String>(
    'devise',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _natureMeta = const VerificationMeta('nature');
  @override
  late final GeneratedColumn<String> nature = GeneratedColumn<String>(
    'nature',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nbOffresMeta = const VerificationMeta(
    'nbOffres',
  );
  @override
  late final GeneratedColumn<int> nbOffres = GeneratedColumn<int>(
    'nb_offres',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _siteMeta = const VerificationMeta('site');
  @override
  late final GeneratedColumn<String> site = GeneratedColumn<String>(
    'site',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trouveMeta = const VerificationMeta('trouve');
  @override
  late final GeneratedColumn<bool> trouve = GeneratedColumn<bool>(
    'trouve',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("trouve" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    caveId,
    ficheId,
    formatCl,
    dateReleve,
    prix,
    devise,
    nature,
    nbOffres,
    site,
    url,
    trouve,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prix_marche';
  @override
  VerificationContext validateIntegrity(
    Insertable<MarketPrice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('cave_id')) {
      context.handle(
        _caveIdMeta,
        caveId.isAcceptableOrUnknown(data['cave_id']!, _caveIdMeta),
      );
    } else if (isInserting) {
      context.missing(_caveIdMeta);
    }
    if (data.containsKey('fiche_id')) {
      context.handle(
        _ficheIdMeta,
        ficheId.isAcceptableOrUnknown(data['fiche_id']!, _ficheIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ficheIdMeta);
    }
    if (data.containsKey('format_cl')) {
      context.handle(
        _formatClMeta,
        formatCl.isAcceptableOrUnknown(data['format_cl']!, _formatClMeta),
      );
    } else if (isInserting) {
      context.missing(_formatClMeta);
    }
    if (data.containsKey('date_releve')) {
      context.handle(
        _dateReleveMeta,
        dateReleve.isAcceptableOrUnknown(data['date_releve']!, _dateReleveMeta),
      );
    } else if (isInserting) {
      context.missing(_dateReleveMeta);
    }
    if (data.containsKey('prix')) {
      context.handle(
        _prixMeta,
        prix.isAcceptableOrUnknown(data['prix']!, _prixMeta),
      );
    }
    if (data.containsKey('devise')) {
      context.handle(
        _deviseMeta,
        devise.isAcceptableOrUnknown(data['devise']!, _deviseMeta),
      );
    } else if (isInserting) {
      context.missing(_deviseMeta);
    }
    if (data.containsKey('nature')) {
      context.handle(
        _natureMeta,
        nature.isAcceptableOrUnknown(data['nature']!, _natureMeta),
      );
    }
    if (data.containsKey('nb_offres')) {
      context.handle(
        _nbOffresMeta,
        nbOffres.isAcceptableOrUnknown(data['nb_offres']!, _nbOffresMeta),
      );
    }
    if (data.containsKey('site')) {
      context.handle(
        _siteMeta,
        site.isAcceptableOrUnknown(data['site']!, _siteMeta),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('trouve')) {
      context.handle(
        _trouveMeta,
        trouve.isAcceptableOrUnknown(data['trouve']!, _trouveMeta),
      );
    } else if (isInserting) {
      context.missing(_trouveMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MarketPrice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MarketPrice(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      caveId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cave_id'],
      )!,
      ficheId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fiche_id'],
      )!,
      formatCl: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}format_cl'],
      )!,
      dateReleve: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_releve'],
      )!,
      prix: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}prix'],
      ),
      devise: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}devise'],
      )!,
      nature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nature'],
      ),
      nbOffres: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}nb_offres'],
      ),
      site: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site'],
      ),
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
      trouve: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}trouve'],
      )!,
    );
  }

  @override
  $MarketPricesTable createAlias(String alias) {
    return $MarketPricesTable(attachedDatabase, alias);
  }
}

class MarketPrice extends DataClass implements Insertable<MarketPrice> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String caveId;
  final String ficheId;
  final double formatCl;
  final String dateReleve;
  final double? prix;
  final String devise;
  final String? nature;
  final int? nbOffres;
  final String? site;
  final String? url;
  final bool trouve;
  const MarketPrice({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.caveId,
    required this.ficheId,
    required this.formatCl,
    required this.dateReleve,
    this.prix,
    required this.devise,
    this.nature,
    this.nbOffres,
    this.site,
    this.url,
    required this.trouve,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['cave_id'] = Variable<String>(caveId);
    map['fiche_id'] = Variable<String>(ficheId);
    map['format_cl'] = Variable<double>(formatCl);
    map['date_releve'] = Variable<String>(dateReleve);
    if (!nullToAbsent || prix != null) {
      map['prix'] = Variable<double>(prix);
    }
    map['devise'] = Variable<String>(devise);
    if (!nullToAbsent || nature != null) {
      map['nature'] = Variable<String>(nature);
    }
    if (!nullToAbsent || nbOffres != null) {
      map['nb_offres'] = Variable<int>(nbOffres);
    }
    if (!nullToAbsent || site != null) {
      map['site'] = Variable<String>(site);
    }
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    map['trouve'] = Variable<bool>(trouve);
    return map;
  }

  MarketPricesCompanion toCompanion(bool nullToAbsent) {
    return MarketPricesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      caveId: Value(caveId),
      ficheId: Value(ficheId),
      formatCl: Value(formatCl),
      dateReleve: Value(dateReleve),
      prix: prix == null && nullToAbsent ? const Value.absent() : Value(prix),
      devise: Value(devise),
      nature: nature == null && nullToAbsent
          ? const Value.absent()
          : Value(nature),
      nbOffres: nbOffres == null && nullToAbsent
          ? const Value.absent()
          : Value(nbOffres),
      site: site == null && nullToAbsent ? const Value.absent() : Value(site),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      trouve: Value(trouve),
    );
  }

  factory MarketPrice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MarketPrice(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      caveId: serializer.fromJson<String>(json['caveId']),
      ficheId: serializer.fromJson<String>(json['ficheId']),
      formatCl: serializer.fromJson<double>(json['formatCl']),
      dateReleve: serializer.fromJson<String>(json['dateReleve']),
      prix: serializer.fromJson<double?>(json['prix']),
      devise: serializer.fromJson<String>(json['devise']),
      nature: serializer.fromJson<String?>(json['nature']),
      nbOffres: serializer.fromJson<int?>(json['nbOffres']),
      site: serializer.fromJson<String?>(json['site']),
      url: serializer.fromJson<String?>(json['url']),
      trouve: serializer.fromJson<bool>(json['trouve']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'caveId': serializer.toJson<String>(caveId),
      'ficheId': serializer.toJson<String>(ficheId),
      'formatCl': serializer.toJson<double>(formatCl),
      'dateReleve': serializer.toJson<String>(dateReleve),
      'prix': serializer.toJson<double?>(prix),
      'devise': serializer.toJson<String>(devise),
      'nature': serializer.toJson<String?>(nature),
      'nbOffres': serializer.toJson<int?>(nbOffres),
      'site': serializer.toJson<String?>(site),
      'url': serializer.toJson<String?>(url),
      'trouve': serializer.toJson<bool>(trouve),
    };
  }

  MarketPrice copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? caveId,
    String? ficheId,
    double? formatCl,
    String? dateReleve,
    Value<double?> prix = const Value.absent(),
    String? devise,
    Value<String?> nature = const Value.absent(),
    Value<int?> nbOffres = const Value.absent(),
    Value<String?> site = const Value.absent(),
    Value<String?> url = const Value.absent(),
    bool? trouve,
  }) => MarketPrice(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    caveId: caveId ?? this.caveId,
    ficheId: ficheId ?? this.ficheId,
    formatCl: formatCl ?? this.formatCl,
    dateReleve: dateReleve ?? this.dateReleve,
    prix: prix.present ? prix.value : this.prix,
    devise: devise ?? this.devise,
    nature: nature.present ? nature.value : this.nature,
    nbOffres: nbOffres.present ? nbOffres.value : this.nbOffres,
    site: site.present ? site.value : this.site,
    url: url.present ? url.value : this.url,
    trouve: trouve ?? this.trouve,
  );
  MarketPrice copyWithCompanion(MarketPricesCompanion data) {
    return MarketPrice(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      caveId: data.caveId.present ? data.caveId.value : this.caveId,
      ficheId: data.ficheId.present ? data.ficheId.value : this.ficheId,
      formatCl: data.formatCl.present ? data.formatCl.value : this.formatCl,
      dateReleve: data.dateReleve.present
          ? data.dateReleve.value
          : this.dateReleve,
      prix: data.prix.present ? data.prix.value : this.prix,
      devise: data.devise.present ? data.devise.value : this.devise,
      nature: data.nature.present ? data.nature.value : this.nature,
      nbOffres: data.nbOffres.present ? data.nbOffres.value : this.nbOffres,
      site: data.site.present ? data.site.value : this.site,
      url: data.url.present ? data.url.value : this.url,
      trouve: data.trouve.present ? data.trouve.value : this.trouve,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MarketPrice(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('caveId: $caveId, ')
          ..write('ficheId: $ficheId, ')
          ..write('formatCl: $formatCl, ')
          ..write('dateReleve: $dateReleve, ')
          ..write('prix: $prix, ')
          ..write('devise: $devise, ')
          ..write('nature: $nature, ')
          ..write('nbOffres: $nbOffres, ')
          ..write('site: $site, ')
          ..write('url: $url, ')
          ..write('trouve: $trouve')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    caveId,
    ficheId,
    formatCl,
    dateReleve,
    prix,
    devise,
    nature,
    nbOffres,
    site,
    url,
    trouve,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MarketPrice &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.caveId == this.caveId &&
          other.ficheId == this.ficheId &&
          other.formatCl == this.formatCl &&
          other.dateReleve == this.dateReleve &&
          other.prix == this.prix &&
          other.devise == this.devise &&
          other.nature == this.nature &&
          other.nbOffres == this.nbOffres &&
          other.site == this.site &&
          other.url == this.url &&
          other.trouve == this.trouve);
}

class MarketPricesCompanion extends UpdateCompanion<MarketPrice> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> caveId;
  final Value<String> ficheId;
  final Value<double> formatCl;
  final Value<String> dateReleve;
  final Value<double?> prix;
  final Value<String> devise;
  final Value<String?> nature;
  final Value<int?> nbOffres;
  final Value<String?> site;
  final Value<String?> url;
  final Value<bool> trouve;
  final Value<int> rowid;
  const MarketPricesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.caveId = const Value.absent(),
    this.ficheId = const Value.absent(),
    this.formatCl = const Value.absent(),
    this.dateReleve = const Value.absent(),
    this.prix = const Value.absent(),
    this.devise = const Value.absent(),
    this.nature = const Value.absent(),
    this.nbOffres = const Value.absent(),
    this.site = const Value.absent(),
    this.url = const Value.absent(),
    this.trouve = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MarketPricesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String caveId,
    required String ficheId,
    required double formatCl,
    required String dateReleve,
    this.prix = const Value.absent(),
    required String devise,
    this.nature = const Value.absent(),
    this.nbOffres = const Value.absent(),
    this.site = const Value.absent(),
    this.url = const Value.absent(),
    required bool trouve,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       caveId = Value(caveId),
       ficheId = Value(ficheId),
       formatCl = Value(formatCl),
       dateReleve = Value(dateReleve),
       devise = Value(devise),
       trouve = Value(trouve);
  static Insertable<MarketPrice> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? caveId,
    Expression<String>? ficheId,
    Expression<double>? formatCl,
    Expression<String>? dateReleve,
    Expression<double>? prix,
    Expression<String>? devise,
    Expression<String>? nature,
    Expression<int>? nbOffres,
    Expression<String>? site,
    Expression<String>? url,
    Expression<bool>? trouve,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (caveId != null) 'cave_id': caveId,
      if (ficheId != null) 'fiche_id': ficheId,
      if (formatCl != null) 'format_cl': formatCl,
      if (dateReleve != null) 'date_releve': dateReleve,
      if (prix != null) 'prix': prix,
      if (devise != null) 'devise': devise,
      if (nature != null) 'nature': nature,
      if (nbOffres != null) 'nb_offres': nbOffres,
      if (site != null) 'site': site,
      if (url != null) 'url': url,
      if (trouve != null) 'trouve': trouve,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MarketPricesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? caveId,
    Value<String>? ficheId,
    Value<double>? formatCl,
    Value<String>? dateReleve,
    Value<double?>? prix,
    Value<String>? devise,
    Value<String?>? nature,
    Value<int?>? nbOffres,
    Value<String?>? site,
    Value<String?>? url,
    Value<bool>? trouve,
    Value<int>? rowid,
  }) {
    return MarketPricesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      caveId: caveId ?? this.caveId,
      ficheId: ficheId ?? this.ficheId,
      formatCl: formatCl ?? this.formatCl,
      dateReleve: dateReleve ?? this.dateReleve,
      prix: prix ?? this.prix,
      devise: devise ?? this.devise,
      nature: nature ?? this.nature,
      nbOffres: nbOffres ?? this.nbOffres,
      site: site ?? this.site,
      url: url ?? this.url,
      trouve: trouve ?? this.trouve,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (caveId.present) {
      map['cave_id'] = Variable<String>(caveId.value);
    }
    if (ficheId.present) {
      map['fiche_id'] = Variable<String>(ficheId.value);
    }
    if (formatCl.present) {
      map['format_cl'] = Variable<double>(formatCl.value);
    }
    if (dateReleve.present) {
      map['date_releve'] = Variable<String>(dateReleve.value);
    }
    if (prix.present) {
      map['prix'] = Variable<double>(prix.value);
    }
    if (devise.present) {
      map['devise'] = Variable<String>(devise.value);
    }
    if (nature.present) {
      map['nature'] = Variable<String>(nature.value);
    }
    if (nbOffres.present) {
      map['nb_offres'] = Variable<int>(nbOffres.value);
    }
    if (site.present) {
      map['site'] = Variable<String>(site.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (trouve.present) {
      map['trouve'] = Variable<bool>(trouve.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MarketPricesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('caveId: $caveId, ')
          ..write('ficheId: $ficheId, ')
          ..write('formatCl: $formatCl, ')
          ..write('dateReleve: $dateReleve, ')
          ..write('prix: $prix, ')
          ..write('devise: $devise, ')
          ..write('nature: $nature, ')
          ..write('nbOffres: $nbOffres, ')
          ..write('site: $site, ')
          ..write('url: $url, ')
          ..write('trouve: $trouve, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhotosTable extends Photos with TableInfo<$PhotosTable, Photo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caveIdMeta = const VerificationMeta('caveId');
  @override
  late final GeneratedColumn<String> caveId = GeneratedColumn<String>(
    'cave_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cave (id)',
    ),
  );
  static const VerificationMeta _ficheIdMeta = const VerificationMeta(
    'ficheId',
  );
  @override
  late final GeneratedColumn<String> ficheId = GeneratedColumn<String>(
    'fiche_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES fiche_vin (id)',
    ),
  );
  static const VerificationMeta _cheminMeta = const VerificationMeta('chemin');
  @override
  late final GeneratedColumn<String> chemin = GeneratedColumn<String>(
    'chemin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typePhotoMeta = const VerificationMeta(
    'typePhoto',
  );
  @override
  late final GeneratedColumn<String> typePhoto = GeneratedColumn<String>(
    'type_photo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _principaleMeta = const VerificationMeta(
    'principale',
  );
  @override
  late final GeneratedColumn<bool> principale = GeneratedColumn<bool>(
    'principale',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("principale" IN (0, 1))',
    ),
  );
  static const VerificationMeta _largeurMeta = const VerificationMeta(
    'largeur',
  );
  @override
  late final GeneratedColumn<int> largeur = GeneratedColumn<int>(
    'largeur',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hauteurMeta = const VerificationMeta(
    'hauteur',
  );
  @override
  late final GeneratedColumn<int> hauteur = GeneratedColumn<int>(
    'hauteur',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _octetsMeta = const VerificationMeta('octets');
  @override
  late final GeneratedColumn<int> octets = GeneratedColumn<int>(
    'octets',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    caveId,
    ficheId,
    chemin,
    typePhoto,
    principale,
    largeur,
    hauteur,
    octets,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photo';
  @override
  VerificationContext validateIntegrity(
    Insertable<Photo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('cave_id')) {
      context.handle(
        _caveIdMeta,
        caveId.isAcceptableOrUnknown(data['cave_id']!, _caveIdMeta),
      );
    } else if (isInserting) {
      context.missing(_caveIdMeta);
    }
    if (data.containsKey('fiche_id')) {
      context.handle(
        _ficheIdMeta,
        ficheId.isAcceptableOrUnknown(data['fiche_id']!, _ficheIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ficheIdMeta);
    }
    if (data.containsKey('chemin')) {
      context.handle(
        _cheminMeta,
        chemin.isAcceptableOrUnknown(data['chemin']!, _cheminMeta),
      );
    } else if (isInserting) {
      context.missing(_cheminMeta);
    }
    if (data.containsKey('type_photo')) {
      context.handle(
        _typePhotoMeta,
        typePhoto.isAcceptableOrUnknown(data['type_photo']!, _typePhotoMeta),
      );
    } else if (isInserting) {
      context.missing(_typePhotoMeta);
    }
    if (data.containsKey('principale')) {
      context.handle(
        _principaleMeta,
        principale.isAcceptableOrUnknown(data['principale']!, _principaleMeta),
      );
    } else if (isInserting) {
      context.missing(_principaleMeta);
    }
    if (data.containsKey('largeur')) {
      context.handle(
        _largeurMeta,
        largeur.isAcceptableOrUnknown(data['largeur']!, _largeurMeta),
      );
    }
    if (data.containsKey('hauteur')) {
      context.handle(
        _hauteurMeta,
        hauteur.isAcceptableOrUnknown(data['hauteur']!, _hauteurMeta),
      );
    }
    if (data.containsKey('octets')) {
      context.handle(
        _octetsMeta,
        octets.isAcceptableOrUnknown(data['octets']!, _octetsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Photo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Photo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      caveId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cave_id'],
      )!,
      ficheId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fiche_id'],
      )!,
      chemin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chemin'],
      )!,
      typePhoto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_photo'],
      )!,
      principale: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}principale'],
      )!,
      largeur: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}largeur'],
      ),
      hauteur: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hauteur'],
      ),
      octets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}octets'],
      ),
    );
  }

  @override
  $PhotosTable createAlias(String alias) {
    return $PhotosTable(attachedDatabase, alias);
  }
}

class Photo extends DataClass implements Insertable<Photo> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String caveId;
  final String ficheId;
  final String chemin;
  final String typePhoto;
  final bool principale;
  final int? largeur;
  final int? hauteur;
  final int? octets;
  const Photo({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.caveId,
    required this.ficheId,
    required this.chemin,
    required this.typePhoto,
    required this.principale,
    this.largeur,
    this.hauteur,
    this.octets,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['cave_id'] = Variable<String>(caveId);
    map['fiche_id'] = Variable<String>(ficheId);
    map['chemin'] = Variable<String>(chemin);
    map['type_photo'] = Variable<String>(typePhoto);
    map['principale'] = Variable<bool>(principale);
    if (!nullToAbsent || largeur != null) {
      map['largeur'] = Variable<int>(largeur);
    }
    if (!nullToAbsent || hauteur != null) {
      map['hauteur'] = Variable<int>(hauteur);
    }
    if (!nullToAbsent || octets != null) {
      map['octets'] = Variable<int>(octets);
    }
    return map;
  }

  PhotosCompanion toCompanion(bool nullToAbsent) {
    return PhotosCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      caveId: Value(caveId),
      ficheId: Value(ficheId),
      chemin: Value(chemin),
      typePhoto: Value(typePhoto),
      principale: Value(principale),
      largeur: largeur == null && nullToAbsent
          ? const Value.absent()
          : Value(largeur),
      hauteur: hauteur == null && nullToAbsent
          ? const Value.absent()
          : Value(hauteur),
      octets: octets == null && nullToAbsent
          ? const Value.absent()
          : Value(octets),
    );
  }

  factory Photo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Photo(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      caveId: serializer.fromJson<String>(json['caveId']),
      ficheId: serializer.fromJson<String>(json['ficheId']),
      chemin: serializer.fromJson<String>(json['chemin']),
      typePhoto: serializer.fromJson<String>(json['typePhoto']),
      principale: serializer.fromJson<bool>(json['principale']),
      largeur: serializer.fromJson<int?>(json['largeur']),
      hauteur: serializer.fromJson<int?>(json['hauteur']),
      octets: serializer.fromJson<int?>(json['octets']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'caveId': serializer.toJson<String>(caveId),
      'ficheId': serializer.toJson<String>(ficheId),
      'chemin': serializer.toJson<String>(chemin),
      'typePhoto': serializer.toJson<String>(typePhoto),
      'principale': serializer.toJson<bool>(principale),
      'largeur': serializer.toJson<int?>(largeur),
      'hauteur': serializer.toJson<int?>(hauteur),
      'octets': serializer.toJson<int?>(octets),
    };
  }

  Photo copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? caveId,
    String? ficheId,
    String? chemin,
    String? typePhoto,
    bool? principale,
    Value<int?> largeur = const Value.absent(),
    Value<int?> hauteur = const Value.absent(),
    Value<int?> octets = const Value.absent(),
  }) => Photo(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    caveId: caveId ?? this.caveId,
    ficheId: ficheId ?? this.ficheId,
    chemin: chemin ?? this.chemin,
    typePhoto: typePhoto ?? this.typePhoto,
    principale: principale ?? this.principale,
    largeur: largeur.present ? largeur.value : this.largeur,
    hauteur: hauteur.present ? hauteur.value : this.hauteur,
    octets: octets.present ? octets.value : this.octets,
  );
  Photo copyWithCompanion(PhotosCompanion data) {
    return Photo(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      caveId: data.caveId.present ? data.caveId.value : this.caveId,
      ficheId: data.ficheId.present ? data.ficheId.value : this.ficheId,
      chemin: data.chemin.present ? data.chemin.value : this.chemin,
      typePhoto: data.typePhoto.present ? data.typePhoto.value : this.typePhoto,
      principale: data.principale.present
          ? data.principale.value
          : this.principale,
      largeur: data.largeur.present ? data.largeur.value : this.largeur,
      hauteur: data.hauteur.present ? data.hauteur.value : this.hauteur,
      octets: data.octets.present ? data.octets.value : this.octets,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Photo(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('caveId: $caveId, ')
          ..write('ficheId: $ficheId, ')
          ..write('chemin: $chemin, ')
          ..write('typePhoto: $typePhoto, ')
          ..write('principale: $principale, ')
          ..write('largeur: $largeur, ')
          ..write('hauteur: $hauteur, ')
          ..write('octets: $octets')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    caveId,
    ficheId,
    chemin,
    typePhoto,
    principale,
    largeur,
    hauteur,
    octets,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Photo &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.caveId == this.caveId &&
          other.ficheId == this.ficheId &&
          other.chemin == this.chemin &&
          other.typePhoto == this.typePhoto &&
          other.principale == this.principale &&
          other.largeur == this.largeur &&
          other.hauteur == this.hauteur &&
          other.octets == this.octets);
}

class PhotosCompanion extends UpdateCompanion<Photo> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> caveId;
  final Value<String> ficheId;
  final Value<String> chemin;
  final Value<String> typePhoto;
  final Value<bool> principale;
  final Value<int?> largeur;
  final Value<int?> hauteur;
  final Value<int?> octets;
  final Value<int> rowid;
  const PhotosCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.caveId = const Value.absent(),
    this.ficheId = const Value.absent(),
    this.chemin = const Value.absent(),
    this.typePhoto = const Value.absent(),
    this.principale = const Value.absent(),
    this.largeur = const Value.absent(),
    this.hauteur = const Value.absent(),
    this.octets = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhotosCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String caveId,
    required String ficheId,
    required String chemin,
    required String typePhoto,
    required bool principale,
    this.largeur = const Value.absent(),
    this.hauteur = const Value.absent(),
    this.octets = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       caveId = Value(caveId),
       ficheId = Value(ficheId),
       chemin = Value(chemin),
       typePhoto = Value(typePhoto),
       principale = Value(principale);
  static Insertable<Photo> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? caveId,
    Expression<String>? ficheId,
    Expression<String>? chemin,
    Expression<String>? typePhoto,
    Expression<bool>? principale,
    Expression<int>? largeur,
    Expression<int>? hauteur,
    Expression<int>? octets,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (caveId != null) 'cave_id': caveId,
      if (ficheId != null) 'fiche_id': ficheId,
      if (chemin != null) 'chemin': chemin,
      if (typePhoto != null) 'type_photo': typePhoto,
      if (principale != null) 'principale': principale,
      if (largeur != null) 'largeur': largeur,
      if (hauteur != null) 'hauteur': hauteur,
      if (octets != null) 'octets': octets,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhotosCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? caveId,
    Value<String>? ficheId,
    Value<String>? chemin,
    Value<String>? typePhoto,
    Value<bool>? principale,
    Value<int?>? largeur,
    Value<int?>? hauteur,
    Value<int?>? octets,
    Value<int>? rowid,
  }) {
    return PhotosCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      caveId: caveId ?? this.caveId,
      ficheId: ficheId ?? this.ficheId,
      chemin: chemin ?? this.chemin,
      typePhoto: typePhoto ?? this.typePhoto,
      principale: principale ?? this.principale,
      largeur: largeur ?? this.largeur,
      hauteur: hauteur ?? this.hauteur,
      octets: octets ?? this.octets,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (caveId.present) {
      map['cave_id'] = Variable<String>(caveId.value);
    }
    if (ficheId.present) {
      map['fiche_id'] = Variable<String>(ficheId.value);
    }
    if (chemin.present) {
      map['chemin'] = Variable<String>(chemin.value);
    }
    if (typePhoto.present) {
      map['type_photo'] = Variable<String>(typePhoto.value);
    }
    if (principale.present) {
      map['principale'] = Variable<bool>(principale.value);
    }
    if (largeur.present) {
      map['largeur'] = Variable<int>(largeur.value);
    }
    if (hauteur.present) {
      map['hauteur'] = Variable<int>(hauteur.value);
    }
    if (octets.present) {
      map['octets'] = Variable<int>(octets.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhotosCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('caveId: $caveId, ')
          ..write('ficheId: $ficheId, ')
          ..write('chemin: $chemin, ')
          ..write('typePhoto: $typePhoto, ')
          ..write('principale: $principale, ')
          ..write('largeur: $largeur, ')
          ..write('hauteur: $hauteur, ')
          ..write('octets: $octets, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProvenancesTable extends Provenances
    with TableInfo<$ProvenancesTable, Provenance> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProvenancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caveIdMeta = const VerificationMeta('caveId');
  @override
  late final GeneratedColumn<String> caveId = GeneratedColumn<String>(
    'cave_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cave (id)',
    ),
  );
  static const VerificationMeta _entiteMeta = const VerificationMeta('entite');
  @override
  late final GeneratedColumn<String> entite = GeneratedColumn<String>(
    'entite',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entiteIdMeta = const VerificationMeta(
    'entiteId',
  );
  @override
  late final GeneratedColumn<String> entiteId = GeneratedColumn<String>(
    'entite_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _champMeta = const VerificationMeta('champ');
  @override
  late final GeneratedColumn<String> champ = GeneratedColumn<String>(
    'champ',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valeurMeta = const VerificationMeta('valeur');
  @override
  late final GeneratedColumn<String> valeur = GeneratedColumn<String>(
    'valeur',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confianceMeta = const VerificationMeta(
    'confiance',
  );
  @override
  late final GeneratedColumn<double> confiance = GeneratedColumn<double>(
    'confiance',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateCollecteMeta = const VerificationMeta(
    'dateCollecte',
  );
  @override
  late final GeneratedColumn<String> dateCollecte = GeneratedColumn<String>(
    'date_collecte',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statutMeta = const VerificationMeta('statut');
  @override
  late final GeneratedColumn<String> statut = GeneratedColumn<String>(
    'statut',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _signaleMeta = const VerificationMeta(
    'signale',
  );
  @override
  late final GeneratedColumn<bool> signale = GeneratedColumn<bool>(
    'signale',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("signale" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    caveId,
    entite,
    entiteId,
    champ,
    valeur,
    source,
    url,
    confiance,
    dateCollecte,
    statut,
    signale,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'provenance';
  @override
  VerificationContext validateIntegrity(
    Insertable<Provenance> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('cave_id')) {
      context.handle(
        _caveIdMeta,
        caveId.isAcceptableOrUnknown(data['cave_id']!, _caveIdMeta),
      );
    } else if (isInserting) {
      context.missing(_caveIdMeta);
    }
    if (data.containsKey('entite')) {
      context.handle(
        _entiteMeta,
        entite.isAcceptableOrUnknown(data['entite']!, _entiteMeta),
      );
    } else if (isInserting) {
      context.missing(_entiteMeta);
    }
    if (data.containsKey('entite_id')) {
      context.handle(
        _entiteIdMeta,
        entiteId.isAcceptableOrUnknown(data['entite_id']!, _entiteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entiteIdMeta);
    }
    if (data.containsKey('champ')) {
      context.handle(
        _champMeta,
        champ.isAcceptableOrUnknown(data['champ']!, _champMeta),
      );
    } else if (isInserting) {
      context.missing(_champMeta);
    }
    if (data.containsKey('valeur')) {
      context.handle(
        _valeurMeta,
        valeur.isAcceptableOrUnknown(data['valeur']!, _valeurMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('confiance')) {
      context.handle(
        _confianceMeta,
        confiance.isAcceptableOrUnknown(data['confiance']!, _confianceMeta),
      );
    }
    if (data.containsKey('date_collecte')) {
      context.handle(
        _dateCollecteMeta,
        dateCollecte.isAcceptableOrUnknown(
          data['date_collecte']!,
          _dateCollecteMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateCollecteMeta);
    }
    if (data.containsKey('statut')) {
      context.handle(
        _statutMeta,
        statut.isAcceptableOrUnknown(data['statut']!, _statutMeta),
      );
    } else if (isInserting) {
      context.missing(_statutMeta);
    }
    if (data.containsKey('signale')) {
      context.handle(
        _signaleMeta,
        signale.isAcceptableOrUnknown(data['signale']!, _signaleMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Provenance map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Provenance(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      caveId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cave_id'],
      )!,
      entite: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entite'],
      )!,
      entiteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entite_id'],
      )!,
      champ: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}champ'],
      )!,
      valeur: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valeur'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
      confiance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confiance'],
      ),
      dateCollecte: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_collecte'],
      )!,
      statut: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}statut'],
      )!,
      signale: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}signale'],
      ),
    );
  }

  @override
  $ProvenancesTable createAlias(String alias) {
    return $ProvenancesTable(attachedDatabase, alias);
  }
}

class Provenance extends DataClass implements Insertable<Provenance> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String caveId;
  final String entite;
  final String entiteId;
  final String champ;
  final String? valeur;
  final String source;
  final String? url;
  final double? confiance;
  final String dateCollecte;
  final String statut;
  final bool? signale;
  const Provenance({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.caveId,
    required this.entite,
    required this.entiteId,
    required this.champ,
    this.valeur,
    required this.source,
    this.url,
    this.confiance,
    required this.dateCollecte,
    required this.statut,
    this.signale,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['cave_id'] = Variable<String>(caveId);
    map['entite'] = Variable<String>(entite);
    map['entite_id'] = Variable<String>(entiteId);
    map['champ'] = Variable<String>(champ);
    if (!nullToAbsent || valeur != null) {
      map['valeur'] = Variable<String>(valeur);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    if (!nullToAbsent || confiance != null) {
      map['confiance'] = Variable<double>(confiance);
    }
    map['date_collecte'] = Variable<String>(dateCollecte);
    map['statut'] = Variable<String>(statut);
    if (!nullToAbsent || signale != null) {
      map['signale'] = Variable<bool>(signale);
    }
    return map;
  }

  ProvenancesCompanion toCompanion(bool nullToAbsent) {
    return ProvenancesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      caveId: Value(caveId),
      entite: Value(entite),
      entiteId: Value(entiteId),
      champ: Value(champ),
      valeur: valeur == null && nullToAbsent
          ? const Value.absent()
          : Value(valeur),
      source: Value(source),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      confiance: confiance == null && nullToAbsent
          ? const Value.absent()
          : Value(confiance),
      dateCollecte: Value(dateCollecte),
      statut: Value(statut),
      signale: signale == null && nullToAbsent
          ? const Value.absent()
          : Value(signale),
    );
  }

  factory Provenance.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Provenance(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      caveId: serializer.fromJson<String>(json['caveId']),
      entite: serializer.fromJson<String>(json['entite']),
      entiteId: serializer.fromJson<String>(json['entiteId']),
      champ: serializer.fromJson<String>(json['champ']),
      valeur: serializer.fromJson<String?>(json['valeur']),
      source: serializer.fromJson<String>(json['source']),
      url: serializer.fromJson<String?>(json['url']),
      confiance: serializer.fromJson<double?>(json['confiance']),
      dateCollecte: serializer.fromJson<String>(json['dateCollecte']),
      statut: serializer.fromJson<String>(json['statut']),
      signale: serializer.fromJson<bool?>(json['signale']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'caveId': serializer.toJson<String>(caveId),
      'entite': serializer.toJson<String>(entite),
      'entiteId': serializer.toJson<String>(entiteId),
      'champ': serializer.toJson<String>(champ),
      'valeur': serializer.toJson<String?>(valeur),
      'source': serializer.toJson<String>(source),
      'url': serializer.toJson<String?>(url),
      'confiance': serializer.toJson<double?>(confiance),
      'dateCollecte': serializer.toJson<String>(dateCollecte),
      'statut': serializer.toJson<String>(statut),
      'signale': serializer.toJson<bool?>(signale),
    };
  }

  Provenance copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? caveId,
    String? entite,
    String? entiteId,
    String? champ,
    Value<String?> valeur = const Value.absent(),
    String? source,
    Value<String?> url = const Value.absent(),
    Value<double?> confiance = const Value.absent(),
    String? dateCollecte,
    String? statut,
    Value<bool?> signale = const Value.absent(),
  }) => Provenance(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    caveId: caveId ?? this.caveId,
    entite: entite ?? this.entite,
    entiteId: entiteId ?? this.entiteId,
    champ: champ ?? this.champ,
    valeur: valeur.present ? valeur.value : this.valeur,
    source: source ?? this.source,
    url: url.present ? url.value : this.url,
    confiance: confiance.present ? confiance.value : this.confiance,
    dateCollecte: dateCollecte ?? this.dateCollecte,
    statut: statut ?? this.statut,
    signale: signale.present ? signale.value : this.signale,
  );
  Provenance copyWithCompanion(ProvenancesCompanion data) {
    return Provenance(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      caveId: data.caveId.present ? data.caveId.value : this.caveId,
      entite: data.entite.present ? data.entite.value : this.entite,
      entiteId: data.entiteId.present ? data.entiteId.value : this.entiteId,
      champ: data.champ.present ? data.champ.value : this.champ,
      valeur: data.valeur.present ? data.valeur.value : this.valeur,
      source: data.source.present ? data.source.value : this.source,
      url: data.url.present ? data.url.value : this.url,
      confiance: data.confiance.present ? data.confiance.value : this.confiance,
      dateCollecte: data.dateCollecte.present
          ? data.dateCollecte.value
          : this.dateCollecte,
      statut: data.statut.present ? data.statut.value : this.statut,
      signale: data.signale.present ? data.signale.value : this.signale,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Provenance(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('caveId: $caveId, ')
          ..write('entite: $entite, ')
          ..write('entiteId: $entiteId, ')
          ..write('champ: $champ, ')
          ..write('valeur: $valeur, ')
          ..write('source: $source, ')
          ..write('url: $url, ')
          ..write('confiance: $confiance, ')
          ..write('dateCollecte: $dateCollecte, ')
          ..write('statut: $statut, ')
          ..write('signale: $signale')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    caveId,
    entite,
    entiteId,
    champ,
    valeur,
    source,
    url,
    confiance,
    dateCollecte,
    statut,
    signale,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Provenance &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.caveId == this.caveId &&
          other.entite == this.entite &&
          other.entiteId == this.entiteId &&
          other.champ == this.champ &&
          other.valeur == this.valeur &&
          other.source == this.source &&
          other.url == this.url &&
          other.confiance == this.confiance &&
          other.dateCollecte == this.dateCollecte &&
          other.statut == this.statut &&
          other.signale == this.signale);
}

class ProvenancesCompanion extends UpdateCompanion<Provenance> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> caveId;
  final Value<String> entite;
  final Value<String> entiteId;
  final Value<String> champ;
  final Value<String?> valeur;
  final Value<String> source;
  final Value<String?> url;
  final Value<double?> confiance;
  final Value<String> dateCollecte;
  final Value<String> statut;
  final Value<bool?> signale;
  final Value<int> rowid;
  const ProvenancesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.caveId = const Value.absent(),
    this.entite = const Value.absent(),
    this.entiteId = const Value.absent(),
    this.champ = const Value.absent(),
    this.valeur = const Value.absent(),
    this.source = const Value.absent(),
    this.url = const Value.absent(),
    this.confiance = const Value.absent(),
    this.dateCollecte = const Value.absent(),
    this.statut = const Value.absent(),
    this.signale = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProvenancesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String caveId,
    required String entite,
    required String entiteId,
    required String champ,
    this.valeur = const Value.absent(),
    required String source,
    this.url = const Value.absent(),
    this.confiance = const Value.absent(),
    required String dateCollecte,
    required String statut,
    this.signale = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       caveId = Value(caveId),
       entite = Value(entite),
       entiteId = Value(entiteId),
       champ = Value(champ),
       source = Value(source),
       dateCollecte = Value(dateCollecte),
       statut = Value(statut);
  static Insertable<Provenance> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? caveId,
    Expression<String>? entite,
    Expression<String>? entiteId,
    Expression<String>? champ,
    Expression<String>? valeur,
    Expression<String>? source,
    Expression<String>? url,
    Expression<double>? confiance,
    Expression<String>? dateCollecte,
    Expression<String>? statut,
    Expression<bool>? signale,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (caveId != null) 'cave_id': caveId,
      if (entite != null) 'entite': entite,
      if (entiteId != null) 'entite_id': entiteId,
      if (champ != null) 'champ': champ,
      if (valeur != null) 'valeur': valeur,
      if (source != null) 'source': source,
      if (url != null) 'url': url,
      if (confiance != null) 'confiance': confiance,
      if (dateCollecte != null) 'date_collecte': dateCollecte,
      if (statut != null) 'statut': statut,
      if (signale != null) 'signale': signale,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProvenancesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? caveId,
    Value<String>? entite,
    Value<String>? entiteId,
    Value<String>? champ,
    Value<String?>? valeur,
    Value<String>? source,
    Value<String?>? url,
    Value<double?>? confiance,
    Value<String>? dateCollecte,
    Value<String>? statut,
    Value<bool?>? signale,
    Value<int>? rowid,
  }) {
    return ProvenancesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      caveId: caveId ?? this.caveId,
      entite: entite ?? this.entite,
      entiteId: entiteId ?? this.entiteId,
      champ: champ ?? this.champ,
      valeur: valeur ?? this.valeur,
      source: source ?? this.source,
      url: url ?? this.url,
      confiance: confiance ?? this.confiance,
      dateCollecte: dateCollecte ?? this.dateCollecte,
      statut: statut ?? this.statut,
      signale: signale ?? this.signale,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (caveId.present) {
      map['cave_id'] = Variable<String>(caveId.value);
    }
    if (entite.present) {
      map['entite'] = Variable<String>(entite.value);
    }
    if (entiteId.present) {
      map['entite_id'] = Variable<String>(entiteId.value);
    }
    if (champ.present) {
      map['champ'] = Variable<String>(champ.value);
    }
    if (valeur.present) {
      map['valeur'] = Variable<String>(valeur.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (confiance.present) {
      map['confiance'] = Variable<double>(confiance.value);
    }
    if (dateCollecte.present) {
      map['date_collecte'] = Variable<String>(dateCollecte.value);
    }
    if (statut.present) {
      map['statut'] = Variable<String>(statut.value);
    }
    if (signale.present) {
      map['signale'] = Variable<bool>(signale.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProvenancesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('caveId: $caveId, ')
          ..write('entite: $entite, ')
          ..write('entiteId: $entiteId, ')
          ..write('champ: $champ, ')
          ..write('valeur: $valeur, ')
          ..write('source: $source, ')
          ..write('url: $url, ')
          ..write('confiance: $confiance, ')
          ..write('dateCollecte: $dateCollecte, ')
          ..write('statut: $statut, ')
          ..write('signale: $signale, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ListValuesTable extends ListValues
    with TableInfo<$ListValuesTable, ListValue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ListValuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caveIdMeta = const VerificationMeta('caveId');
  @override
  late final GeneratedColumn<String> caveId = GeneratedColumn<String>(
    'cave_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cave (id)',
    ),
  );
  static const VerificationMeta _listeMeta = const VerificationMeta('liste');
  @override
  late final GeneratedColumn<String> liste = GeneratedColumn<String>(
    'liste',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _libelleMeta = const VerificationMeta(
    'libelle',
  );
  @override
  late final GeneratedColumn<String> libelle = GeneratedColumn<String>(
    'libelle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentCodeMeta = const VerificationMeta(
    'parentCode',
  );
  @override
  late final GeneratedColumn<String> parentCode = GeneratedColumn<String>(
    'parent_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ordreMeta = const VerificationMeta('ordre');
  @override
  late final GeneratedColumn<int> ordre = GeneratedColumn<int>(
    'ordre',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actifMeta = const VerificationMeta('actif');
  @override
  late final GeneratedColumn<bool> actif = GeneratedColumn<bool>(
    'actif',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("actif" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    caveId,
    liste,
    code,
    libelle,
    parentCode,
    ordre,
    actif,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'valeur_liste';
  @override
  VerificationContext validateIntegrity(
    Insertable<ListValue> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('cave_id')) {
      context.handle(
        _caveIdMeta,
        caveId.isAcceptableOrUnknown(data['cave_id']!, _caveIdMeta),
      );
    } else if (isInserting) {
      context.missing(_caveIdMeta);
    }
    if (data.containsKey('liste')) {
      context.handle(
        _listeMeta,
        liste.isAcceptableOrUnknown(data['liste']!, _listeMeta),
      );
    } else if (isInserting) {
      context.missing(_listeMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('libelle')) {
      context.handle(
        _libelleMeta,
        libelle.isAcceptableOrUnknown(data['libelle']!, _libelleMeta),
      );
    } else if (isInserting) {
      context.missing(_libelleMeta);
    }
    if (data.containsKey('parent_code')) {
      context.handle(
        _parentCodeMeta,
        parentCode.isAcceptableOrUnknown(data['parent_code']!, _parentCodeMeta),
      );
    }
    if (data.containsKey('ordre')) {
      context.handle(
        _ordreMeta,
        ordre.isAcceptableOrUnknown(data['ordre']!, _ordreMeta),
      );
    }
    if (data.containsKey('actif')) {
      context.handle(
        _actifMeta,
        actif.isAcceptableOrUnknown(data['actif']!, _actifMeta),
      );
    } else if (isInserting) {
      context.missing(_actifMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ListValue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ListValue(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      caveId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cave_id'],
      )!,
      liste: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}liste'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      libelle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}libelle'],
      )!,
      parentCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_code'],
      ),
      ordre: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordre'],
      ),
      actif: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}actif'],
      )!,
    );
  }

  @override
  $ListValuesTable createAlias(String alias) {
    return $ListValuesTable(attachedDatabase, alias);
  }
}

class ListValue extends DataClass implements Insertable<ListValue> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String caveId;
  final String liste;
  final String code;
  final String libelle;
  final String? parentCode;
  final int? ordre;
  final bool actif;
  const ListValue({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.caveId,
    required this.liste,
    required this.code,
    required this.libelle,
    this.parentCode,
    this.ordre,
    required this.actif,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['cave_id'] = Variable<String>(caveId);
    map['liste'] = Variable<String>(liste);
    map['code'] = Variable<String>(code);
    map['libelle'] = Variable<String>(libelle);
    if (!nullToAbsent || parentCode != null) {
      map['parent_code'] = Variable<String>(parentCode);
    }
    if (!nullToAbsent || ordre != null) {
      map['ordre'] = Variable<int>(ordre);
    }
    map['actif'] = Variable<bool>(actif);
    return map;
  }

  ListValuesCompanion toCompanion(bool nullToAbsent) {
    return ListValuesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      caveId: Value(caveId),
      liste: Value(liste),
      code: Value(code),
      libelle: Value(libelle),
      parentCode: parentCode == null && nullToAbsent
          ? const Value.absent()
          : Value(parentCode),
      ordre: ordre == null && nullToAbsent
          ? const Value.absent()
          : Value(ordre),
      actif: Value(actif),
    );
  }

  factory ListValue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ListValue(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      caveId: serializer.fromJson<String>(json['caveId']),
      liste: serializer.fromJson<String>(json['liste']),
      code: serializer.fromJson<String>(json['code']),
      libelle: serializer.fromJson<String>(json['libelle']),
      parentCode: serializer.fromJson<String?>(json['parentCode']),
      ordre: serializer.fromJson<int?>(json['ordre']),
      actif: serializer.fromJson<bool>(json['actif']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'caveId': serializer.toJson<String>(caveId),
      'liste': serializer.toJson<String>(liste),
      'code': serializer.toJson<String>(code),
      'libelle': serializer.toJson<String>(libelle),
      'parentCode': serializer.toJson<String?>(parentCode),
      'ordre': serializer.toJson<int?>(ordre),
      'actif': serializer.toJson<bool>(actif),
    };
  }

  ListValue copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? caveId,
    String? liste,
    String? code,
    String? libelle,
    Value<String?> parentCode = const Value.absent(),
    Value<int?> ordre = const Value.absent(),
    bool? actif,
  }) => ListValue(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    caveId: caveId ?? this.caveId,
    liste: liste ?? this.liste,
    code: code ?? this.code,
    libelle: libelle ?? this.libelle,
    parentCode: parentCode.present ? parentCode.value : this.parentCode,
    ordre: ordre.present ? ordre.value : this.ordre,
    actif: actif ?? this.actif,
  );
  ListValue copyWithCompanion(ListValuesCompanion data) {
    return ListValue(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      caveId: data.caveId.present ? data.caveId.value : this.caveId,
      liste: data.liste.present ? data.liste.value : this.liste,
      code: data.code.present ? data.code.value : this.code,
      libelle: data.libelle.present ? data.libelle.value : this.libelle,
      parentCode: data.parentCode.present
          ? data.parentCode.value
          : this.parentCode,
      ordre: data.ordre.present ? data.ordre.value : this.ordre,
      actif: data.actif.present ? data.actif.value : this.actif,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ListValue(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('caveId: $caveId, ')
          ..write('liste: $liste, ')
          ..write('code: $code, ')
          ..write('libelle: $libelle, ')
          ..write('parentCode: $parentCode, ')
          ..write('ordre: $ordre, ')
          ..write('actif: $actif')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    caveId,
    liste,
    code,
    libelle,
    parentCode,
    ordre,
    actif,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ListValue &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.caveId == this.caveId &&
          other.liste == this.liste &&
          other.code == this.code &&
          other.libelle == this.libelle &&
          other.parentCode == this.parentCode &&
          other.ordre == this.ordre &&
          other.actif == this.actif);
}

class ListValuesCompanion extends UpdateCompanion<ListValue> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> caveId;
  final Value<String> liste;
  final Value<String> code;
  final Value<String> libelle;
  final Value<String?> parentCode;
  final Value<int?> ordre;
  final Value<bool> actif;
  final Value<int> rowid;
  const ListValuesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.caveId = const Value.absent(),
    this.liste = const Value.absent(),
    this.code = const Value.absent(),
    this.libelle = const Value.absent(),
    this.parentCode = const Value.absent(),
    this.ordre = const Value.absent(),
    this.actif = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ListValuesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String caveId,
    required String liste,
    required String code,
    required String libelle,
    this.parentCode = const Value.absent(),
    this.ordre = const Value.absent(),
    required bool actif,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       caveId = Value(caveId),
       liste = Value(liste),
       code = Value(code),
       libelle = Value(libelle),
       actif = Value(actif);
  static Insertable<ListValue> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? caveId,
    Expression<String>? liste,
    Expression<String>? code,
    Expression<String>? libelle,
    Expression<String>? parentCode,
    Expression<int>? ordre,
    Expression<bool>? actif,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (caveId != null) 'cave_id': caveId,
      if (liste != null) 'liste': liste,
      if (code != null) 'code': code,
      if (libelle != null) 'libelle': libelle,
      if (parentCode != null) 'parent_code': parentCode,
      if (ordre != null) 'ordre': ordre,
      if (actif != null) 'actif': actif,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ListValuesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? caveId,
    Value<String>? liste,
    Value<String>? code,
    Value<String>? libelle,
    Value<String?>? parentCode,
    Value<int?>? ordre,
    Value<bool>? actif,
    Value<int>? rowid,
  }) {
    return ListValuesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      caveId: caveId ?? this.caveId,
      liste: liste ?? this.liste,
      code: code ?? this.code,
      libelle: libelle ?? this.libelle,
      parentCode: parentCode ?? this.parentCode,
      ordre: ordre ?? this.ordre,
      actif: actif ?? this.actif,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (caveId.present) {
      map['cave_id'] = Variable<String>(caveId.value);
    }
    if (liste.present) {
      map['liste'] = Variable<String>(liste.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (libelle.present) {
      map['libelle'] = Variable<String>(libelle.value);
    }
    if (parentCode.present) {
      map['parent_code'] = Variable<String>(parentCode.value);
    }
    if (ordre.present) {
      map['ordre'] = Variable<int>(ordre.value);
    }
    if (actif.present) {
      map['actif'] = Variable<bool>(actif.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ListValuesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('caveId: $caveId, ')
          ..write('liste: $liste, ')
          ..write('code: $code, ')
          ..write('libelle: $libelle, ')
          ..write('parentCode: $parentCode, ')
          ..write('ordre: $ordre, ')
          ..write('actif: $actif, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JobsTable extends Jobs with TableInfo<$JobsTable, Job> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caveIdMeta = const VerificationMeta('caveId');
  @override
  late final GeneratedColumn<String> caveId = GeneratedColumn<String>(
    'cave_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cave (id)',
    ),
  );
  static const VerificationMeta _ficheIdMeta = const VerificationMeta(
    'ficheId',
  );
  @override
  late final GeneratedColumn<String> ficheId = GeneratedColumn<String>(
    'fiche_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES fiche_vin (id)',
    ),
  );
  static const VerificationMeta _typeJobMeta = const VerificationMeta(
    'typeJob',
  );
  @override
  late final GeneratedColumn<String> typeJob = GeneratedColumn<String>(
    'type_job',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestIdMeta = const VerificationMeta(
    'requestId',
  );
  @override
  late final GeneratedColumn<String> requestId = GeneratedColumn<String>(
    'request_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _jobIdDistantMeta = const VerificationMeta(
    'jobIdDistant',
  );
  @override
  late final GeneratedColumn<String> jobIdDistant = GeneratedColumn<String>(
    'job_id_distant',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statutMeta = const VerificationMeta('statut');
  @override
  late final GeneratedColumn<String> statut = GeneratedColumn<String>(
    'statut',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tentativesMeta = const VerificationMeta(
    'tentatives',
  );
  @override
  late final GeneratedColumn<int> tentatives = GeneratedColumn<int>(
    'tentatives',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _erreurMeta = const VerificationMeta('erreur');
  @override
  late final GeneratedColumn<String> erreur = GeneratedColumn<String>(
    'erreur',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _envoyeLeMeta = const VerificationMeta(
    'envoyeLe',
  );
  @override
  late final GeneratedColumn<String> envoyeLe = GeneratedColumn<String>(
    'envoye_le',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reponseMeta = const VerificationMeta(
    'reponse',
  );
  @override
  late final GeneratedColumn<String> reponse = GeneratedColumn<String>(
    'reponse',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    caveId,
    ficheId,
    typeJob,
    requestId,
    jobIdDistant,
    statut,
    tentatives,
    erreur,
    envoyeLe,
    reponse,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'job';
  @override
  VerificationContext validateIntegrity(
    Insertable<Job> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('cave_id')) {
      context.handle(
        _caveIdMeta,
        caveId.isAcceptableOrUnknown(data['cave_id']!, _caveIdMeta),
      );
    } else if (isInserting) {
      context.missing(_caveIdMeta);
    }
    if (data.containsKey('fiche_id')) {
      context.handle(
        _ficheIdMeta,
        ficheId.isAcceptableOrUnknown(data['fiche_id']!, _ficheIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ficheIdMeta);
    }
    if (data.containsKey('type_job')) {
      context.handle(
        _typeJobMeta,
        typeJob.isAcceptableOrUnknown(data['type_job']!, _typeJobMeta),
      );
    } else if (isInserting) {
      context.missing(_typeJobMeta);
    }
    if (data.containsKey('request_id')) {
      context.handle(
        _requestIdMeta,
        requestId.isAcceptableOrUnknown(data['request_id']!, _requestIdMeta),
      );
    } else if (isInserting) {
      context.missing(_requestIdMeta);
    }
    if (data.containsKey('job_id_distant')) {
      context.handle(
        _jobIdDistantMeta,
        jobIdDistant.isAcceptableOrUnknown(
          data['job_id_distant']!,
          _jobIdDistantMeta,
        ),
      );
    }
    if (data.containsKey('statut')) {
      context.handle(
        _statutMeta,
        statut.isAcceptableOrUnknown(data['statut']!, _statutMeta),
      );
    } else if (isInserting) {
      context.missing(_statutMeta);
    }
    if (data.containsKey('tentatives')) {
      context.handle(
        _tentativesMeta,
        tentatives.isAcceptableOrUnknown(data['tentatives']!, _tentativesMeta),
      );
    }
    if (data.containsKey('erreur')) {
      context.handle(
        _erreurMeta,
        erreur.isAcceptableOrUnknown(data['erreur']!, _erreurMeta),
      );
    }
    if (data.containsKey('envoye_le')) {
      context.handle(
        _envoyeLeMeta,
        envoyeLe.isAcceptableOrUnknown(data['envoye_le']!, _envoyeLeMeta),
      );
    }
    if (data.containsKey('reponse')) {
      context.handle(
        _reponseMeta,
        reponse.isAcceptableOrUnknown(data['reponse']!, _reponseMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Job map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Job(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      caveId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cave_id'],
      )!,
      ficheId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fiche_id'],
      )!,
      typeJob: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_job'],
      )!,
      requestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_id'],
      )!,
      jobIdDistant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job_id_distant'],
      ),
      statut: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}statut'],
      )!,
      tentatives: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tentatives'],
      ),
      erreur: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}erreur'],
      ),
      envoyeLe: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}envoye_le'],
      ),
      reponse: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reponse'],
      ),
    );
  }

  @override
  $JobsTable createAlias(String alias) {
    return $JobsTable(attachedDatabase, alias);
  }
}

class Job extends DataClass implements Insertable<Job> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String caveId;
  final String ficheId;
  final String typeJob;
  final String requestId;
  final String? jobIdDistant;
  final String statut;
  final int? tentatives;
  final String? erreur;

  /// Ajouté en version 2 du schéma.
  final String? envoyeLe;

  /// Ajouté en version 2 du schéma.
  final String? reponse;
  const Job({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.caveId,
    required this.ficheId,
    required this.typeJob,
    required this.requestId,
    this.jobIdDistant,
    required this.statut,
    this.tentatives,
    this.erreur,
    this.envoyeLe,
    this.reponse,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['cave_id'] = Variable<String>(caveId);
    map['fiche_id'] = Variable<String>(ficheId);
    map['type_job'] = Variable<String>(typeJob);
    map['request_id'] = Variable<String>(requestId);
    if (!nullToAbsent || jobIdDistant != null) {
      map['job_id_distant'] = Variable<String>(jobIdDistant);
    }
    map['statut'] = Variable<String>(statut);
    if (!nullToAbsent || tentatives != null) {
      map['tentatives'] = Variable<int>(tentatives);
    }
    if (!nullToAbsent || erreur != null) {
      map['erreur'] = Variable<String>(erreur);
    }
    if (!nullToAbsent || envoyeLe != null) {
      map['envoye_le'] = Variable<String>(envoyeLe);
    }
    if (!nullToAbsent || reponse != null) {
      map['reponse'] = Variable<String>(reponse);
    }
    return map;
  }

  JobsCompanion toCompanion(bool nullToAbsent) {
    return JobsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      caveId: Value(caveId),
      ficheId: Value(ficheId),
      typeJob: Value(typeJob),
      requestId: Value(requestId),
      jobIdDistant: jobIdDistant == null && nullToAbsent
          ? const Value.absent()
          : Value(jobIdDistant),
      statut: Value(statut),
      tentatives: tentatives == null && nullToAbsent
          ? const Value.absent()
          : Value(tentatives),
      erreur: erreur == null && nullToAbsent
          ? const Value.absent()
          : Value(erreur),
      envoyeLe: envoyeLe == null && nullToAbsent
          ? const Value.absent()
          : Value(envoyeLe),
      reponse: reponse == null && nullToAbsent
          ? const Value.absent()
          : Value(reponse),
    );
  }

  factory Job.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Job(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      caveId: serializer.fromJson<String>(json['caveId']),
      ficheId: serializer.fromJson<String>(json['ficheId']),
      typeJob: serializer.fromJson<String>(json['typeJob']),
      requestId: serializer.fromJson<String>(json['requestId']),
      jobIdDistant: serializer.fromJson<String?>(json['jobIdDistant']),
      statut: serializer.fromJson<String>(json['statut']),
      tentatives: serializer.fromJson<int?>(json['tentatives']),
      erreur: serializer.fromJson<String?>(json['erreur']),
      envoyeLe: serializer.fromJson<String?>(json['envoyeLe']),
      reponse: serializer.fromJson<String?>(json['reponse']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'caveId': serializer.toJson<String>(caveId),
      'ficheId': serializer.toJson<String>(ficheId),
      'typeJob': serializer.toJson<String>(typeJob),
      'requestId': serializer.toJson<String>(requestId),
      'jobIdDistant': serializer.toJson<String?>(jobIdDistant),
      'statut': serializer.toJson<String>(statut),
      'tentatives': serializer.toJson<int?>(tentatives),
      'erreur': serializer.toJson<String?>(erreur),
      'envoyeLe': serializer.toJson<String?>(envoyeLe),
      'reponse': serializer.toJson<String?>(reponse),
    };
  }

  Job copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? caveId,
    String? ficheId,
    String? typeJob,
    String? requestId,
    Value<String?> jobIdDistant = const Value.absent(),
    String? statut,
    Value<int?> tentatives = const Value.absent(),
    Value<String?> erreur = const Value.absent(),
    Value<String?> envoyeLe = const Value.absent(),
    Value<String?> reponse = const Value.absent(),
  }) => Job(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    caveId: caveId ?? this.caveId,
    ficheId: ficheId ?? this.ficheId,
    typeJob: typeJob ?? this.typeJob,
    requestId: requestId ?? this.requestId,
    jobIdDistant: jobIdDistant.present ? jobIdDistant.value : this.jobIdDistant,
    statut: statut ?? this.statut,
    tentatives: tentatives.present ? tentatives.value : this.tentatives,
    erreur: erreur.present ? erreur.value : this.erreur,
    envoyeLe: envoyeLe.present ? envoyeLe.value : this.envoyeLe,
    reponse: reponse.present ? reponse.value : this.reponse,
  );
  Job copyWithCompanion(JobsCompanion data) {
    return Job(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      caveId: data.caveId.present ? data.caveId.value : this.caveId,
      ficheId: data.ficheId.present ? data.ficheId.value : this.ficheId,
      typeJob: data.typeJob.present ? data.typeJob.value : this.typeJob,
      requestId: data.requestId.present ? data.requestId.value : this.requestId,
      jobIdDistant: data.jobIdDistant.present
          ? data.jobIdDistant.value
          : this.jobIdDistant,
      statut: data.statut.present ? data.statut.value : this.statut,
      tentatives: data.tentatives.present
          ? data.tentatives.value
          : this.tentatives,
      erreur: data.erreur.present ? data.erreur.value : this.erreur,
      envoyeLe: data.envoyeLe.present ? data.envoyeLe.value : this.envoyeLe,
      reponse: data.reponse.present ? data.reponse.value : this.reponse,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Job(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('caveId: $caveId, ')
          ..write('ficheId: $ficheId, ')
          ..write('typeJob: $typeJob, ')
          ..write('requestId: $requestId, ')
          ..write('jobIdDistant: $jobIdDistant, ')
          ..write('statut: $statut, ')
          ..write('tentatives: $tentatives, ')
          ..write('erreur: $erreur, ')
          ..write('envoyeLe: $envoyeLe, ')
          ..write('reponse: $reponse')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    caveId,
    ficheId,
    typeJob,
    requestId,
    jobIdDistant,
    statut,
    tentatives,
    erreur,
    envoyeLe,
    reponse,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Job &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.caveId == this.caveId &&
          other.ficheId == this.ficheId &&
          other.typeJob == this.typeJob &&
          other.requestId == this.requestId &&
          other.jobIdDistant == this.jobIdDistant &&
          other.statut == this.statut &&
          other.tentatives == this.tentatives &&
          other.erreur == this.erreur &&
          other.envoyeLe == this.envoyeLe &&
          other.reponse == this.reponse);
}

class JobsCompanion extends UpdateCompanion<Job> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> caveId;
  final Value<String> ficheId;
  final Value<String> typeJob;
  final Value<String> requestId;
  final Value<String?> jobIdDistant;
  final Value<String> statut;
  final Value<int?> tentatives;
  final Value<String?> erreur;
  final Value<String?> envoyeLe;
  final Value<String?> reponse;
  final Value<int> rowid;
  const JobsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.caveId = const Value.absent(),
    this.ficheId = const Value.absent(),
    this.typeJob = const Value.absent(),
    this.requestId = const Value.absent(),
    this.jobIdDistant = const Value.absent(),
    this.statut = const Value.absent(),
    this.tentatives = const Value.absent(),
    this.erreur = const Value.absent(),
    this.envoyeLe = const Value.absent(),
    this.reponse = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JobsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String caveId,
    required String ficheId,
    required String typeJob,
    required String requestId,
    this.jobIdDistant = const Value.absent(),
    required String statut,
    this.tentatives = const Value.absent(),
    this.erreur = const Value.absent(),
    this.envoyeLe = const Value.absent(),
    this.reponse = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       caveId = Value(caveId),
       ficheId = Value(ficheId),
       typeJob = Value(typeJob),
       requestId = Value(requestId),
       statut = Value(statut);
  static Insertable<Job> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? caveId,
    Expression<String>? ficheId,
    Expression<String>? typeJob,
    Expression<String>? requestId,
    Expression<String>? jobIdDistant,
    Expression<String>? statut,
    Expression<int>? tentatives,
    Expression<String>? erreur,
    Expression<String>? envoyeLe,
    Expression<String>? reponse,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (caveId != null) 'cave_id': caveId,
      if (ficheId != null) 'fiche_id': ficheId,
      if (typeJob != null) 'type_job': typeJob,
      if (requestId != null) 'request_id': requestId,
      if (jobIdDistant != null) 'job_id_distant': jobIdDistant,
      if (statut != null) 'statut': statut,
      if (tentatives != null) 'tentatives': tentatives,
      if (erreur != null) 'erreur': erreur,
      if (envoyeLe != null) 'envoye_le': envoyeLe,
      if (reponse != null) 'reponse': reponse,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JobsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? caveId,
    Value<String>? ficheId,
    Value<String>? typeJob,
    Value<String>? requestId,
    Value<String?>? jobIdDistant,
    Value<String>? statut,
    Value<int?>? tentatives,
    Value<String?>? erreur,
    Value<String?>? envoyeLe,
    Value<String?>? reponse,
    Value<int>? rowid,
  }) {
    return JobsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      caveId: caveId ?? this.caveId,
      ficheId: ficheId ?? this.ficheId,
      typeJob: typeJob ?? this.typeJob,
      requestId: requestId ?? this.requestId,
      jobIdDistant: jobIdDistant ?? this.jobIdDistant,
      statut: statut ?? this.statut,
      tentatives: tentatives ?? this.tentatives,
      erreur: erreur ?? this.erreur,
      envoyeLe: envoyeLe ?? this.envoyeLe,
      reponse: reponse ?? this.reponse,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (caveId.present) {
      map['cave_id'] = Variable<String>(caveId.value);
    }
    if (ficheId.present) {
      map['fiche_id'] = Variable<String>(ficheId.value);
    }
    if (typeJob.present) {
      map['type_job'] = Variable<String>(typeJob.value);
    }
    if (requestId.present) {
      map['request_id'] = Variable<String>(requestId.value);
    }
    if (jobIdDistant.present) {
      map['job_id_distant'] = Variable<String>(jobIdDistant.value);
    }
    if (statut.present) {
      map['statut'] = Variable<String>(statut.value);
    }
    if (tentatives.present) {
      map['tentatives'] = Variable<int>(tentatives.value);
    }
    if (erreur.present) {
      map['erreur'] = Variable<String>(erreur.value);
    }
    if (envoyeLe.present) {
      map['envoye_le'] = Variable<String>(envoyeLe.value);
    }
    if (reponse.present) {
      map['reponse'] = Variable<String>(reponse.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JobsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('caveId: $caveId, ')
          ..write('ficheId: $ficheId, ')
          ..write('typeJob: $typeJob, ')
          ..write('requestId: $requestId, ')
          ..write('jobIdDistant: $jobIdDistant, ')
          ..write('statut: $statut, ')
          ..write('tentatives: $tentatives, ')
          ..write('erreur: $erreur, ')
          ..write('envoyeLe: $envoyeLe, ')
          ..write('reponse: $reponse, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavedStatViewsTable extends SavedStatViews
    with TableInfo<$SavedStatViewsTable, SavedStatView> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedStatViewsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caveIdMeta = const VerificationMeta('caveId');
  @override
  late final GeneratedColumn<String> caveId = GeneratedColumn<String>(
    'cave_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cave (id)',
    ),
  );
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
    'nom',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mesureMeta = const VerificationMeta('mesure');
  @override
  late final GeneratedColumn<String> mesure = GeneratedColumn<String>(
    'mesure',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dimension1Meta = const VerificationMeta(
    'dimension1',
  );
  @override
  late final GeneratedColumn<String> dimension1 = GeneratedColumn<String>(
    'dimension_1',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dimension2Meta = const VerificationMeta(
    'dimension2',
  );
  @override
  late final GeneratedColumn<String> dimension2 = GeneratedColumn<String>(
    'dimension_2',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _filtresMeta = const VerificationMeta(
    'filtres',
  );
  @override
  late final GeneratedColumn<String> filtres = GeneratedColumn<String>(
    'filtres',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _graphiqueMeta = const VerificationMeta(
    'graphique',
  );
  @override
  late final GeneratedColumn<String> graphique = GeneratedColumn<String>(
    'graphique',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    caveId,
    nom,
    mesure,
    dimension1,
    dimension2,
    filtres,
    graphique,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vue_statistique';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedStatView> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('cave_id')) {
      context.handle(
        _caveIdMeta,
        caveId.isAcceptableOrUnknown(data['cave_id']!, _caveIdMeta),
      );
    } else if (isInserting) {
      context.missing(_caveIdMeta);
    }
    if (data.containsKey('nom')) {
      context.handle(
        _nomMeta,
        nom.isAcceptableOrUnknown(data['nom']!, _nomMeta),
      );
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('mesure')) {
      context.handle(
        _mesureMeta,
        mesure.isAcceptableOrUnknown(data['mesure']!, _mesureMeta),
      );
    } else if (isInserting) {
      context.missing(_mesureMeta);
    }
    if (data.containsKey('dimension_1')) {
      context.handle(
        _dimension1Meta,
        dimension1.isAcceptableOrUnknown(data['dimension_1']!, _dimension1Meta),
      );
    } else if (isInserting) {
      context.missing(_dimension1Meta);
    }
    if (data.containsKey('dimension_2')) {
      context.handle(
        _dimension2Meta,
        dimension2.isAcceptableOrUnknown(data['dimension_2']!, _dimension2Meta),
      );
    }
    if (data.containsKey('filtres')) {
      context.handle(
        _filtresMeta,
        filtres.isAcceptableOrUnknown(data['filtres']!, _filtresMeta),
      );
    }
    if (data.containsKey('graphique')) {
      context.handle(
        _graphiqueMeta,
        graphique.isAcceptableOrUnknown(data['graphique']!, _graphiqueMeta),
      );
    } else if (isInserting) {
      context.missing(_graphiqueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedStatView map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedStatView(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      caveId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cave_id'],
      )!,
      nom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nom'],
      )!,
      mesure: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mesure'],
      )!,
      dimension1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dimension_1'],
      )!,
      dimension2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dimension_2'],
      ),
      filtres: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filtres'],
      ),
      graphique: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}graphique'],
      )!,
    );
  }

  @override
  $SavedStatViewsTable createAlias(String alias) {
    return $SavedStatViewsTable(attachedDatabase, alias);
  }
}

class SavedStatView extends DataClass implements Insertable<SavedStatView> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String caveId;
  final String nom;
  final String mesure;
  final String dimension1;
  final String? dimension2;
  final String? filtres;
  final String graphique;
  const SavedStatView({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.caveId,
    required this.nom,
    required this.mesure,
    required this.dimension1,
    this.dimension2,
    this.filtres,
    required this.graphique,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['cave_id'] = Variable<String>(caveId);
    map['nom'] = Variable<String>(nom);
    map['mesure'] = Variable<String>(mesure);
    map['dimension_1'] = Variable<String>(dimension1);
    if (!nullToAbsent || dimension2 != null) {
      map['dimension_2'] = Variable<String>(dimension2);
    }
    if (!nullToAbsent || filtres != null) {
      map['filtres'] = Variable<String>(filtres);
    }
    map['graphique'] = Variable<String>(graphique);
    return map;
  }

  SavedStatViewsCompanion toCompanion(bool nullToAbsent) {
    return SavedStatViewsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      caveId: Value(caveId),
      nom: Value(nom),
      mesure: Value(mesure),
      dimension1: Value(dimension1),
      dimension2: dimension2 == null && nullToAbsent
          ? const Value.absent()
          : Value(dimension2),
      filtres: filtres == null && nullToAbsent
          ? const Value.absent()
          : Value(filtres),
      graphique: Value(graphique),
    );
  }

  factory SavedStatView.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedStatView(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      caveId: serializer.fromJson<String>(json['caveId']),
      nom: serializer.fromJson<String>(json['nom']),
      mesure: serializer.fromJson<String>(json['mesure']),
      dimension1: serializer.fromJson<String>(json['dimension1']),
      dimension2: serializer.fromJson<String?>(json['dimension2']),
      filtres: serializer.fromJson<String?>(json['filtres']),
      graphique: serializer.fromJson<String>(json['graphique']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'caveId': serializer.toJson<String>(caveId),
      'nom': serializer.toJson<String>(nom),
      'mesure': serializer.toJson<String>(mesure),
      'dimension1': serializer.toJson<String>(dimension1),
      'dimension2': serializer.toJson<String?>(dimension2),
      'filtres': serializer.toJson<String?>(filtres),
      'graphique': serializer.toJson<String>(graphique),
    };
  }

  SavedStatView copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? caveId,
    String? nom,
    String? mesure,
    String? dimension1,
    Value<String?> dimension2 = const Value.absent(),
    Value<String?> filtres = const Value.absent(),
    String? graphique,
  }) => SavedStatView(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    caveId: caveId ?? this.caveId,
    nom: nom ?? this.nom,
    mesure: mesure ?? this.mesure,
    dimension1: dimension1 ?? this.dimension1,
    dimension2: dimension2.present ? dimension2.value : this.dimension2,
    filtres: filtres.present ? filtres.value : this.filtres,
    graphique: graphique ?? this.graphique,
  );
  SavedStatView copyWithCompanion(SavedStatViewsCompanion data) {
    return SavedStatView(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      caveId: data.caveId.present ? data.caveId.value : this.caveId,
      nom: data.nom.present ? data.nom.value : this.nom,
      mesure: data.mesure.present ? data.mesure.value : this.mesure,
      dimension1: data.dimension1.present
          ? data.dimension1.value
          : this.dimension1,
      dimension2: data.dimension2.present
          ? data.dimension2.value
          : this.dimension2,
      filtres: data.filtres.present ? data.filtres.value : this.filtres,
      graphique: data.graphique.present ? data.graphique.value : this.graphique,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedStatView(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('caveId: $caveId, ')
          ..write('nom: $nom, ')
          ..write('mesure: $mesure, ')
          ..write('dimension1: $dimension1, ')
          ..write('dimension2: $dimension2, ')
          ..write('filtres: $filtres, ')
          ..write('graphique: $graphique')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    caveId,
    nom,
    mesure,
    dimension1,
    dimension2,
    filtres,
    graphique,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedStatView &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.caveId == this.caveId &&
          other.nom == this.nom &&
          other.mesure == this.mesure &&
          other.dimension1 == this.dimension1 &&
          other.dimension2 == this.dimension2 &&
          other.filtres == this.filtres &&
          other.graphique == this.graphique);
}

class SavedStatViewsCompanion extends UpdateCompanion<SavedStatView> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> caveId;
  final Value<String> nom;
  final Value<String> mesure;
  final Value<String> dimension1;
  final Value<String?> dimension2;
  final Value<String?> filtres;
  final Value<String> graphique;
  final Value<int> rowid;
  const SavedStatViewsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.caveId = const Value.absent(),
    this.nom = const Value.absent(),
    this.mesure = const Value.absent(),
    this.dimension1 = const Value.absent(),
    this.dimension2 = const Value.absent(),
    this.filtres = const Value.absent(),
    this.graphique = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedStatViewsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String caveId,
    required String nom,
    required String mesure,
    required String dimension1,
    this.dimension2 = const Value.absent(),
    this.filtres = const Value.absent(),
    required String graphique,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       caveId = Value(caveId),
       nom = Value(nom),
       mesure = Value(mesure),
       dimension1 = Value(dimension1),
       graphique = Value(graphique);
  static Insertable<SavedStatView> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? caveId,
    Expression<String>? nom,
    Expression<String>? mesure,
    Expression<String>? dimension1,
    Expression<String>? dimension2,
    Expression<String>? filtres,
    Expression<String>? graphique,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (caveId != null) 'cave_id': caveId,
      if (nom != null) 'nom': nom,
      if (mesure != null) 'mesure': mesure,
      if (dimension1 != null) 'dimension_1': dimension1,
      if (dimension2 != null) 'dimension_2': dimension2,
      if (filtres != null) 'filtres': filtres,
      if (graphique != null) 'graphique': graphique,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedStatViewsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? caveId,
    Value<String>? nom,
    Value<String>? mesure,
    Value<String>? dimension1,
    Value<String?>? dimension2,
    Value<String?>? filtres,
    Value<String>? graphique,
    Value<int>? rowid,
  }) {
    return SavedStatViewsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      caveId: caveId ?? this.caveId,
      nom: nom ?? this.nom,
      mesure: mesure ?? this.mesure,
      dimension1: dimension1 ?? this.dimension1,
      dimension2: dimension2 ?? this.dimension2,
      filtres: filtres ?? this.filtres,
      graphique: graphique ?? this.graphique,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (caveId.present) {
      map['cave_id'] = Variable<String>(caveId.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (mesure.present) {
      map['mesure'] = Variable<String>(mesure.value);
    }
    if (dimension1.present) {
      map['dimension_1'] = Variable<String>(dimension1.value);
    }
    if (dimension2.present) {
      map['dimension_2'] = Variable<String>(dimension2.value);
    }
    if (filtres.present) {
      map['filtres'] = Variable<String>(filtres.value);
    }
    if (graphique.present) {
      map['graphique'] = Variable<String>(graphique.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedStatViewsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('caveId: $caveId, ')
          ..write('nom: $nom, ')
          ..write('mesure: $mesure, ')
          ..write('dimension1: $dimension1, ')
          ..write('dimension2: $dimension2, ')
          ..write('filtres: $filtres, ')
          ..write('graphique: $graphique, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $CellarsTable cellars = $CellarsTable(this);
  late final $ProducersTable producers = $ProducersTable(this);
  late final $CuveesTable cuvees = $CuveesTable(this);
  late final $WinesTable wines = $WinesTable(this);
  late final $CriticScoresTable criticScores = $CriticScoresTable(this);
  late final $OwnersTable owners = $OwnersTable(this);
  late final $StorageLocationsTable storageLocations = $StorageLocationsTable(
    this,
  );
  late final $StockLotsTable stockLots = $StockLotsTable(this);
  late final $StockMovementsTable stockMovements = $StockMovementsTable(this);
  late final $TastingsTable tastings = $TastingsTable(this);
  late final $MarketPricesTable marketPrices = $MarketPricesTable(this);
  late final $PhotosTable photos = $PhotosTable(this);
  late final $ProvenancesTable provenances = $ProvenancesTable(this);
  late final $ListValuesTable listValues = $ListValuesTable(this);
  late final $JobsTable jobs = $JobsTable(this);
  late final $SavedStatViewsTable savedStatViews = $SavedStatViewsTable(this);
  late final Index idxDomaineNom = Index(
    'idx_domaine_nom',
    'CREATE INDEX idx_domaine_nom ON domaine (nom)',
  );
  late final Index idxCuveeDomaine = Index(
    'idx_cuvee_domaine',
    'CREATE INDEX idx_cuvee_domaine ON cuvee (domaine_id)',
  );
  late final Index idxCuveeNom = Index(
    'idx_cuvee_nom',
    'CREATE INDEX idx_cuvee_nom ON cuvee (nom)',
  );
  late final Index idxCuveePays = Index(
    'idx_cuvee_pays',
    'CREATE INDEX idx_cuvee_pays ON cuvee (pays)',
  );
  late final Index idxCuveeRegion = Index(
    'idx_cuvee_region',
    'CREATE INDEX idx_cuvee_region ON cuvee (region)',
  );
  late final Index idxCuveeAppellation = Index(
    'idx_cuvee_appellation',
    'CREATE INDEX idx_cuvee_appellation ON cuvee (appellation)',
  );
  late final Index idxCuveeCouleur = Index(
    'idx_cuvee_couleur',
    'CREATE INDEX idx_cuvee_couleur ON cuvee (couleur)',
  );
  late final Index idxCuveeTypeVin = Index(
    'idx_cuvee_type_vin',
    'CREATE INDEX idx_cuvee_type_vin ON cuvee (type_vin)',
  );
  late final Index idxFicheCuvee = Index(
    'idx_fiche_cuvee',
    'CREATE INDEX idx_fiche_cuvee ON fiche_vin (cuvee_id)',
  );
  late final Index idxFicheMillesime = Index(
    'idx_fiche_millesime',
    'CREATE INDEX idx_fiche_millesime ON fiche_vin (millesime)',
  );
  late final Index idxFicheGardeDebut = Index(
    'idx_fiche_garde_debut',
    'CREATE INDEX idx_fiche_garde_debut ON fiche_vin (garde_debut)',
  );
  late final Index idxFicheGardeFin = Index(
    'idx_fiche_garde_fin',
    'CREATE INDEX idx_fiche_garde_fin ON fiche_vin (garde_fin)',
  );
  late final Index idxFicheGardeApogee = Index(
    'idx_fiche_garde_apogee',
    'CREATE INDEX idx_fiche_garde_apogee ON fiche_vin (garde_apogee)',
  );
  late final Index idxFicheStatut = Index(
    'idx_fiche_statut',
    'CREATE INDEX idx_fiche_statut ON fiche_vin (statut_enrichissement)',
  );
  late final Index idxFicheFavori = Index(
    'idx_fiche_favori',
    'CREATE INDEX idx_fiche_favori ON fiche_vin (favori)',
  );
  late final Index idxFicheCreated = Index(
    'idx_fiche_created',
    'CREATE INDEX idx_fiche_created ON fiche_vin (created_at)',
  );
  late final Index idxNoteFiche = Index(
    'idx_note_fiche',
    'CREATE INDEX idx_note_fiche ON note_critique (fiche_id)',
  );
  late final Index idxLotFiche = Index(
    'idx_lot_fiche',
    'CREATE INDEX idx_lot_fiche ON lot (fiche_id)',
  );
  late final Index idxLotProprietaire = Index(
    'idx_lot_proprietaire',
    'CREATE INDEX idx_lot_proprietaire ON lot (proprietaire_id)',
  );
  late final Index idxLotEmplacement = Index(
    'idx_lot_emplacement',
    'CREATE INDEX idx_lot_emplacement ON lot (emplacement_id)',
  );
  late final Index idxLotPrix = Index(
    'idx_lot_prix',
    'CREATE INDEX idx_lot_prix ON lot (prix_achat_unitaire)',
  );
  late final Index idxMouvementLot = Index(
    'idx_mouvement_lot',
    'CREATE INDEX idx_mouvement_lot ON mouvement (lot_id)',
  );
  late final Index idxMouvementType = Index(
    'idx_mouvement_type',
    'CREATE INDEX idx_mouvement_type ON mouvement (type_mouvement)',
  );
  late final Index idxPrixFiche = Index(
    'idx_prix_fiche',
    'CREATE INDEX idx_prix_fiche ON prix_marche (fiche_id)',
  );
  late final Index idxPhotoFiche = Index(
    'idx_photo_fiche',
    'CREATE INDEX idx_photo_fiche ON photo (fiche_id)',
  );
  late final Index idxProvenanceEntite = Index(
    'idx_provenance_entite',
    'CREATE INDEX idx_provenance_entite ON provenance (entite, entite_id)',
  );
  late final Index idxEmplacementParent = Index(
    'idx_emplacement_parent',
    'CREATE INDEX idx_emplacement_parent ON emplacement (parent_id)',
  );
  late final Index idxValeurListe = Index(
    'idx_valeur_liste',
    'CREATE INDEX idx_valeur_liste ON valeur_liste (liste, code)',
  );
  late final Index idxJobFiche = Index(
    'idx_job_fiche',
    'CREATE INDEX idx_job_fiche ON job (fiche_id)',
  );
  late final Index idxJobStatut = Index(
    'idx_job_statut',
    'CREATE INDEX idx_job_statut ON job (statut)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cellars,
    producers,
    cuvees,
    wines,
    criticScores,
    owners,
    storageLocations,
    stockLots,
    stockMovements,
    tastings,
    marketPrices,
    photos,
    provenances,
    listValues,
    jobs,
    savedStatViews,
    idxDomaineNom,
    idxCuveeDomaine,
    idxCuveeNom,
    idxCuveePays,
    idxCuveeRegion,
    idxCuveeAppellation,
    idxCuveeCouleur,
    idxCuveeTypeVin,
    idxFicheCuvee,
    idxFicheMillesime,
    idxFicheGardeDebut,
    idxFicheGardeFin,
    idxFicheGardeApogee,
    idxFicheStatut,
    idxFicheFavori,
    idxFicheCreated,
    idxNoteFiche,
    idxLotFiche,
    idxLotProprietaire,
    idxLotEmplacement,
    idxLotPrix,
    idxMouvementLot,
    idxMouvementType,
    idxPrixFiche,
    idxPhotoFiche,
    idxProvenanceEntite,
    idxEmplacementParent,
    idxValeurListe,
    idxJobFiche,
    idxJobStatut,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}
