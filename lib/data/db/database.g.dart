// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SpacesTable extends Spaces with TableInfo<$SpacesTable, SpaceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<SpaceKind, String> kind =
      GeneratedColumn<String>('kind', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<SpaceKind>($SpacesTable.$converterkind);
  static const VerificationMeta _xMeta = const VerificationMeta('x');
  @override
  late final GeneratedColumn<double> x = GeneratedColumn<double>(
      'x', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _yMeta = const VerificationMeta('y');
  @override
  late final GeneratedColumn<double> y = GeneratedColumn<double>(
      'y', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<double> width = GeneratedColumn<double>(
      'width', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<double> height = GeneratedColumn<double>(
      'height', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, kind, x, y, width, height];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'spaces';
  @override
  VerificationContext validateIntegrity(Insertable<SpaceRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('x')) {
      context.handle(_xMeta, x.isAcceptableOrUnknown(data['x']!, _xMeta));
    } else if (isInserting) {
      context.missing(_xMeta);
    }
    if (data.containsKey('y')) {
      context.handle(_yMeta, y.isAcceptableOrUnknown(data['y']!, _yMeta));
    } else if (isInserting) {
      context.missing(_yMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
          _widthMeta, width.isAcceptableOrUnknown(data['width']!, _widthMeta));
    } else if (isInserting) {
      context.missing(_widthMeta);
    }
    if (data.containsKey('height')) {
      context.handle(_heightMeta,
          height.isAcceptableOrUnknown(data['height']!, _heightMeta));
    } else if (isInserting) {
      context.missing(_heightMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SpaceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpaceRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      kind: $SpacesTable.$converterkind.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!),
      x: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}x'])!,
      y: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}y'])!,
      width: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}width'])!,
      height: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}height'])!,
    );
  }

  @override
  $SpacesTable createAlias(String alias) {
    return $SpacesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SpaceKind, String, String> $converterkind =
      const EnumNameConverter<SpaceKind>(SpaceKind.values);
}

class SpaceRow extends DataClass implements Insertable<SpaceRow> {
  final String id;
  final String name;
  final SpaceKind kind;
  final double x;
  final double y;
  final double width;
  final double height;
  const SpaceRow(
      {required this.id,
      required this.name,
      required this.kind,
      required this.x,
      required this.y,
      required this.width,
      required this.height});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['kind'] = Variable<String>($SpacesTable.$converterkind.toSql(kind));
    }
    map['x'] = Variable<double>(x);
    map['y'] = Variable<double>(y);
    map['width'] = Variable<double>(width);
    map['height'] = Variable<double>(height);
    return map;
  }

  SpacesCompanion toCompanion(bool nullToAbsent) {
    return SpacesCompanion(
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      x: Value(x),
      y: Value(y),
      width: Value(width),
      height: Value(height),
    );
  }

  factory SpaceRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpaceRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: $SpacesTable.$converterkind
          .fromJson(serializer.fromJson<String>(json['kind'])),
      x: serializer.fromJson<double>(json['x']),
      y: serializer.fromJson<double>(json['y']),
      width: serializer.fromJson<double>(json['width']),
      height: serializer.fromJson<double>(json['height']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'kind':
          serializer.toJson<String>($SpacesTable.$converterkind.toJson(kind)),
      'x': serializer.toJson<double>(x),
      'y': serializer.toJson<double>(y),
      'width': serializer.toJson<double>(width),
      'height': serializer.toJson<double>(height),
    };
  }

  SpaceRow copyWith(
          {String? id,
          String? name,
          SpaceKind? kind,
          double? x,
          double? y,
          double? width,
          double? height}) =>
      SpaceRow(
        id: id ?? this.id,
        name: name ?? this.name,
        kind: kind ?? this.kind,
        x: x ?? this.x,
        y: y ?? this.y,
        width: width ?? this.width,
        height: height ?? this.height,
      );
  SpaceRow copyWithCompanion(SpacesCompanion data) {
    return SpaceRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      x: data.x.present ? data.x.value : this.x,
      y: data.y.present ? data.y.value : this.y,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpaceRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('width: $width, ')
          ..write('height: $height')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, kind, x, y, width, height);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpaceRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.x == this.x &&
          other.y == this.y &&
          other.width == this.width &&
          other.height == this.height);
}

class SpacesCompanion extends UpdateCompanion<SpaceRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<SpaceKind> kind;
  final Value<double> x;
  final Value<double> y;
  final Value<double> width;
  final Value<double> height;
  final Value<int> rowid;
  const SpacesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.x = const Value.absent(),
    this.y = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SpacesCompanion.insert({
    required String id,
    required String name,
    required SpaceKind kind,
    required double x,
    required double y,
    required double width,
    required double height,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        kind = Value(kind),
        x = Value(x),
        y = Value(y),
        width = Value(width),
        height = Value(height);
  static Insertable<SpaceRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<double>? x,
    Expression<double>? y,
    Expression<double>? width,
    Expression<double>? height,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SpacesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<SpaceKind>? kind,
      Value<double>? x,
      Value<double>? y,
      Value<double>? width,
      Value<double>? height,
      Value<int>? rowid}) {
    return SpacesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] =
          Variable<String>($SpacesTable.$converterkind.toSql(kind.value));
    }
    if (x.present) {
      map['x'] = Variable<double>(x.value);
    }
    if (y.present) {
      map['y'] = Variable<double>(y.value);
    }
    if (width.present) {
      map['width'] = Variable<double>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<double>(height.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpacesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OpeningsTable extends Openings
    with TableInfo<$OpeningsTable, OpeningRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OpeningsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _spaceIdMeta =
      const VerificationMeta('spaceId');
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
      'space_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES spaces (id) ON DELETE CASCADE'));
  @override
  late final GeneratedColumnWithTypeConverter<OpeningKind, String> kind =
      GeneratedColumn<String>('kind', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<OpeningKind>($OpeningsTable.$converterkind);
  static const VerificationMeta _wallMeta = const VerificationMeta('wall');
  @override
  late final GeneratedColumn<int> wall = GeneratedColumn<int>(
      'wall', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _offsetMeta = const VerificationMeta('offset');
  @override
  late final GeneratedColumn<double> offset = GeneratedColumn<double>(
      'offset', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _lengthMeta = const VerificationMeta('length');
  @override
  late final GeneratedColumn<double> length = GeneratedColumn<double>(
      'length', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, spaceId, kind, wall, offset, length];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'openings';
  @override
  VerificationContext validateIntegrity(Insertable<OpeningRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(_spaceIdMeta,
          spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta));
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('wall')) {
      context.handle(
          _wallMeta, wall.isAcceptableOrUnknown(data['wall']!, _wallMeta));
    } else if (isInserting) {
      context.missing(_wallMeta);
    }
    if (data.containsKey('offset')) {
      context.handle(_offsetMeta,
          offset.isAcceptableOrUnknown(data['offset']!, _offsetMeta));
    } else if (isInserting) {
      context.missing(_offsetMeta);
    }
    if (data.containsKey('length')) {
      context.handle(_lengthMeta,
          length.isAcceptableOrUnknown(data['length']!, _lengthMeta));
    } else if (isInserting) {
      context.missing(_lengthMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OpeningRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OpeningRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      spaceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}space_id'])!,
      kind: $OpeningsTable.$converterkind.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!),
      wall: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}wall'])!,
      offset: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}offset'])!,
      length: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}length'])!,
    );
  }

  @override
  $OpeningsTable createAlias(String alias) {
    return $OpeningsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<OpeningKind, String, String> $converterkind =
      const EnumNameConverter<OpeningKind>(OpeningKind.values);
}

class OpeningRow extends DataClass implements Insertable<OpeningRow> {
  final String id;
  final String spaceId;
  final OpeningKind kind;
  final int wall;
  final double offset;
  final double length;
  const OpeningRow(
      {required this.id,
      required this.spaceId,
      required this.kind,
      required this.wall,
      required this.offset,
      required this.length});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['space_id'] = Variable<String>(spaceId);
    {
      map['kind'] = Variable<String>($OpeningsTable.$converterkind.toSql(kind));
    }
    map['wall'] = Variable<int>(wall);
    map['offset'] = Variable<double>(offset);
    map['length'] = Variable<double>(length);
    return map;
  }

  OpeningsCompanion toCompanion(bool nullToAbsent) {
    return OpeningsCompanion(
      id: Value(id),
      spaceId: Value(spaceId),
      kind: Value(kind),
      wall: Value(wall),
      offset: Value(offset),
      length: Value(length),
    );
  }

  factory OpeningRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OpeningRow(
      id: serializer.fromJson<String>(json['id']),
      spaceId: serializer.fromJson<String>(json['spaceId']),
      kind: $OpeningsTable.$converterkind
          .fromJson(serializer.fromJson<String>(json['kind'])),
      wall: serializer.fromJson<int>(json['wall']),
      offset: serializer.fromJson<double>(json['offset']),
      length: serializer.fromJson<double>(json['length']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'spaceId': serializer.toJson<String>(spaceId),
      'kind':
          serializer.toJson<String>($OpeningsTable.$converterkind.toJson(kind)),
      'wall': serializer.toJson<int>(wall),
      'offset': serializer.toJson<double>(offset),
      'length': serializer.toJson<double>(length),
    };
  }

  OpeningRow copyWith(
          {String? id,
          String? spaceId,
          OpeningKind? kind,
          int? wall,
          double? offset,
          double? length}) =>
      OpeningRow(
        id: id ?? this.id,
        spaceId: spaceId ?? this.spaceId,
        kind: kind ?? this.kind,
        wall: wall ?? this.wall,
        offset: offset ?? this.offset,
        length: length ?? this.length,
      );
  OpeningRow copyWithCompanion(OpeningsCompanion data) {
    return OpeningRow(
      id: data.id.present ? data.id.value : this.id,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      kind: data.kind.present ? data.kind.value : this.kind,
      wall: data.wall.present ? data.wall.value : this.wall,
      offset: data.offset.present ? data.offset.value : this.offset,
      length: data.length.present ? data.length.value : this.length,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OpeningRow(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('kind: $kind, ')
          ..write('wall: $wall, ')
          ..write('offset: $offset, ')
          ..write('length: $length')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, spaceId, kind, wall, offset, length);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OpeningRow &&
          other.id == this.id &&
          other.spaceId == this.spaceId &&
          other.kind == this.kind &&
          other.wall == this.wall &&
          other.offset == this.offset &&
          other.length == this.length);
}

class OpeningsCompanion extends UpdateCompanion<OpeningRow> {
  final Value<String> id;
  final Value<String> spaceId;
  final Value<OpeningKind> kind;
  final Value<int> wall;
  final Value<double> offset;
  final Value<double> length;
  final Value<int> rowid;
  const OpeningsCompanion({
    this.id = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.kind = const Value.absent(),
    this.wall = const Value.absent(),
    this.offset = const Value.absent(),
    this.length = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OpeningsCompanion.insert({
    required String id,
    required String spaceId,
    required OpeningKind kind,
    required int wall,
    required double offset,
    required double length,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        spaceId = Value(spaceId),
        kind = Value(kind),
        wall = Value(wall),
        offset = Value(offset),
        length = Value(length);
  static Insertable<OpeningRow> custom({
    Expression<String>? id,
    Expression<String>? spaceId,
    Expression<String>? kind,
    Expression<int>? wall,
    Expression<double>? offset,
    Expression<double>? length,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (spaceId != null) 'space_id': spaceId,
      if (kind != null) 'kind': kind,
      if (wall != null) 'wall': wall,
      if (offset != null) 'offset': offset,
      if (length != null) 'length': length,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OpeningsCompanion copyWith(
      {Value<String>? id,
      Value<String>? spaceId,
      Value<OpeningKind>? kind,
      Value<int>? wall,
      Value<double>? offset,
      Value<double>? length,
      Value<int>? rowid}) {
    return OpeningsCompanion(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      kind: kind ?? this.kind,
      wall: wall ?? this.wall,
      offset: offset ?? this.offset,
      length: length ?? this.length,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (kind.present) {
      map['kind'] =
          Variable<String>($OpeningsTable.$converterkind.toSql(kind.value));
    }
    if (wall.present) {
      map['wall'] = Variable<int>(wall.value);
    }
    if (offset.present) {
      map['offset'] = Variable<double>(offset.value);
    }
    if (length.present) {
      map['length'] = Variable<double>(length.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OpeningsCompanion(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('kind: $kind, ')
          ..write('wall: $wall, ')
          ..write('offset: $offset, ')
          ..write('length: $length, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LightReadingsTable extends LightReadings
    with TableInfo<$LightReadingsTable, LightReadingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LightReadingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _spaceIdMeta =
      const VerificationMeta('spaceId');
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
      'space_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES spaces (id) ON DELETE CASCADE'));
  static const VerificationMeta _xMeta = const VerificationMeta('x');
  @override
  late final GeneratedColumn<double> x = GeneratedColumn<double>(
      'x', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _yMeta = const VerificationMeta('y');
  @override
  late final GeneratedColumn<double> y = GeneratedColumn<double>(
      'y', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<DayMoment, String> moment =
      GeneratedColumn<String>('moment', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<DayMoment>($LightReadingsTable.$convertermoment);
  static const VerificationMeta _estimatedLuxMeta =
      const VerificationMeta('estimatedLux');
  @override
  late final GeneratedColumn<double> estimatedLux = GeneratedColumn<double>(
      'estimated_lux', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _takenAtMeta =
      const VerificationMeta('takenAt');
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
      'taken_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, spaceId, x, y, moment, estimatedLux, takenAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'light_readings';
  @override
  VerificationContext validateIntegrity(Insertable<LightReadingRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(_spaceIdMeta,
          spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta));
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('x')) {
      context.handle(_xMeta, x.isAcceptableOrUnknown(data['x']!, _xMeta));
    } else if (isInserting) {
      context.missing(_xMeta);
    }
    if (data.containsKey('y')) {
      context.handle(_yMeta, y.isAcceptableOrUnknown(data['y']!, _yMeta));
    } else if (isInserting) {
      context.missing(_yMeta);
    }
    if (data.containsKey('estimated_lux')) {
      context.handle(
          _estimatedLuxMeta,
          estimatedLux.isAcceptableOrUnknown(
              data['estimated_lux']!, _estimatedLuxMeta));
    } else if (isInserting) {
      context.missing(_estimatedLuxMeta);
    }
    if (data.containsKey('taken_at')) {
      context.handle(_takenAtMeta,
          takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta));
    } else if (isInserting) {
      context.missing(_takenAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LightReadingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LightReadingRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      spaceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}space_id'])!,
      x: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}x'])!,
      y: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}y'])!,
      moment: $LightReadingsTable.$convertermoment.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}moment'])!),
      estimatedLux: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}estimated_lux'])!,
      takenAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}taken_at'])!,
    );
  }

  @override
  $LightReadingsTable createAlias(String alias) {
    return $LightReadingsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DayMoment, String, String> $convertermoment =
      const EnumNameConverter<DayMoment>(DayMoment.values);
}

class LightReadingRow extends DataClass implements Insertable<LightReadingRow> {
  final String id;
  final String spaceId;
  final double x;
  final double y;
  final DayMoment moment;
  final double estimatedLux;
  final DateTime takenAt;
  const LightReadingRow(
      {required this.id,
      required this.spaceId,
      required this.x,
      required this.y,
      required this.moment,
      required this.estimatedLux,
      required this.takenAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['space_id'] = Variable<String>(spaceId);
    map['x'] = Variable<double>(x);
    map['y'] = Variable<double>(y);
    {
      map['moment'] =
          Variable<String>($LightReadingsTable.$convertermoment.toSql(moment));
    }
    map['estimated_lux'] = Variable<double>(estimatedLux);
    map['taken_at'] = Variable<DateTime>(takenAt);
    return map;
  }

  LightReadingsCompanion toCompanion(bool nullToAbsent) {
    return LightReadingsCompanion(
      id: Value(id),
      spaceId: Value(spaceId),
      x: Value(x),
      y: Value(y),
      moment: Value(moment),
      estimatedLux: Value(estimatedLux),
      takenAt: Value(takenAt),
    );
  }

  factory LightReadingRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LightReadingRow(
      id: serializer.fromJson<String>(json['id']),
      spaceId: serializer.fromJson<String>(json['spaceId']),
      x: serializer.fromJson<double>(json['x']),
      y: serializer.fromJson<double>(json['y']),
      moment: $LightReadingsTable.$convertermoment
          .fromJson(serializer.fromJson<String>(json['moment'])),
      estimatedLux: serializer.fromJson<double>(json['estimatedLux']),
      takenAt: serializer.fromJson<DateTime>(json['takenAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'spaceId': serializer.toJson<String>(spaceId),
      'x': serializer.toJson<double>(x),
      'y': serializer.toJson<double>(y),
      'moment': serializer
          .toJson<String>($LightReadingsTable.$convertermoment.toJson(moment)),
      'estimatedLux': serializer.toJson<double>(estimatedLux),
      'takenAt': serializer.toJson<DateTime>(takenAt),
    };
  }

  LightReadingRow copyWith(
          {String? id,
          String? spaceId,
          double? x,
          double? y,
          DayMoment? moment,
          double? estimatedLux,
          DateTime? takenAt}) =>
      LightReadingRow(
        id: id ?? this.id,
        spaceId: spaceId ?? this.spaceId,
        x: x ?? this.x,
        y: y ?? this.y,
        moment: moment ?? this.moment,
        estimatedLux: estimatedLux ?? this.estimatedLux,
        takenAt: takenAt ?? this.takenAt,
      );
  LightReadingRow copyWithCompanion(LightReadingsCompanion data) {
    return LightReadingRow(
      id: data.id.present ? data.id.value : this.id,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      x: data.x.present ? data.x.value : this.x,
      y: data.y.present ? data.y.value : this.y,
      moment: data.moment.present ? data.moment.value : this.moment,
      estimatedLux: data.estimatedLux.present
          ? data.estimatedLux.value
          : this.estimatedLux,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LightReadingRow(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('moment: $moment, ')
          ..write('estimatedLux: $estimatedLux, ')
          ..write('takenAt: $takenAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, spaceId, x, y, moment, estimatedLux, takenAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LightReadingRow &&
          other.id == this.id &&
          other.spaceId == this.spaceId &&
          other.x == this.x &&
          other.y == this.y &&
          other.moment == this.moment &&
          other.estimatedLux == this.estimatedLux &&
          other.takenAt == this.takenAt);
}

class LightReadingsCompanion extends UpdateCompanion<LightReadingRow> {
  final Value<String> id;
  final Value<String> spaceId;
  final Value<double> x;
  final Value<double> y;
  final Value<DayMoment> moment;
  final Value<double> estimatedLux;
  final Value<DateTime> takenAt;
  final Value<int> rowid;
  const LightReadingsCompanion({
    this.id = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.x = const Value.absent(),
    this.y = const Value.absent(),
    this.moment = const Value.absent(),
    this.estimatedLux = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LightReadingsCompanion.insert({
    required String id,
    required String spaceId,
    required double x,
    required double y,
    required DayMoment moment,
    required double estimatedLux,
    required DateTime takenAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        spaceId = Value(spaceId),
        x = Value(x),
        y = Value(y),
        moment = Value(moment),
        estimatedLux = Value(estimatedLux),
        takenAt = Value(takenAt);
  static Insertable<LightReadingRow> custom({
    Expression<String>? id,
    Expression<String>? spaceId,
    Expression<double>? x,
    Expression<double>? y,
    Expression<String>? moment,
    Expression<double>? estimatedLux,
    Expression<DateTime>? takenAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (spaceId != null) 'space_id': spaceId,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (moment != null) 'moment': moment,
      if (estimatedLux != null) 'estimated_lux': estimatedLux,
      if (takenAt != null) 'taken_at': takenAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LightReadingsCompanion copyWith(
      {Value<String>? id,
      Value<String>? spaceId,
      Value<double>? x,
      Value<double>? y,
      Value<DayMoment>? moment,
      Value<double>? estimatedLux,
      Value<DateTime>? takenAt,
      Value<int>? rowid}) {
    return LightReadingsCompanion(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      x: x ?? this.x,
      y: y ?? this.y,
      moment: moment ?? this.moment,
      estimatedLux: estimatedLux ?? this.estimatedLux,
      takenAt: takenAt ?? this.takenAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (x.present) {
      map['x'] = Variable<double>(x.value);
    }
    if (y.present) {
      map['y'] = Variable<double>(y.value);
    }
    if (moment.present) {
      map['moment'] = Variable<String>(
          $LightReadingsTable.$convertermoment.toSql(moment.value));
    }
    if (estimatedLux.present) {
      map['estimated_lux'] = Variable<double>(estimatedLux.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LightReadingsCompanion(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('moment: $moment, ')
          ..write('estimatedLux: $estimatedLux, ')
          ..write('takenAt: $takenAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlantSpeciesTableTable extends PlantSpeciesTable
    with TableInfo<$PlantSpeciesTableTable, PlantSpeciesRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlantSpeciesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scientificNameMeta =
      const VerificationMeta('scientificName');
  @override
  late final GeneratedColumn<String> scientificName = GeneratedColumn<String>(
      'scientific_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _commonNameMeta =
      const VerificationMeta('commonName');
  @override
  late final GeneratedColumn<String> commonName = GeneratedColumn<String>(
      'common_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<List<LightLevel>, String> light =
      GeneratedColumn<String>('light', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<List<LightLevel>>(
              $PlantSpeciesTableTable.$converterlight);
  static const VerificationMeta _minTempCMeta =
      const VerificationMeta('minTempC');
  @override
  late final GeneratedColumn<double> minTempC = GeneratedColumn<double>(
      'min_temp_c', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _maxTempCMeta =
      const VerificationMeta('maxTempC');
  @override
  late final GeneratedColumn<double> maxTempC = GeneratedColumn<double>(
      'max_temp_c', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _soilMeta = const VerificationMeta('soil');
  @override
  late final GeneratedColumn<String> soil = GeneratedColumn<String>(
      'soil', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<CareSchedule, String> watering =
      GeneratedColumn<String>('watering', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<CareSchedule>(
              $PlantSpeciesTableTable.$converterwatering);
  @override
  late final GeneratedColumnWithTypeConverter<CareSchedule, String>
      fertilizing = GeneratedColumn<String>('fertilizing', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<CareSchedule>(
              $PlantSpeciesTableTable.$converterfertilizing);
  @override
  late final GeneratedColumnWithTypeConverter<List<Diagnostic>, String>
      diagnostics = GeneratedColumn<String>('diagnostics', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<List<Diagnostic>>(
              $PlantSpeciesTableTable.$converterdiagnostics);
  @override
  late final GeneratedColumnWithTypeConverter<PropagationInfo?, String>
      cutting = GeneratedColumn<String>('cutting', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<PropagationInfo?>(
              $PlantSpeciesTableTable.$convertercuttingn);
  @override
  late final GeneratedColumnWithTypeConverter<RepottingInfo?, String>
      repotting = GeneratedColumn<String>('repotting', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<RepottingInfo?>(
              $PlantSpeciesTableTable.$converterrepottingn);
  @override
  late final GeneratedColumnWithTypeConverter<List<int>, String> sowingMonths =
      GeneratedColumn<String>('sowing_months', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('[]'))
          .withConverter<List<int>>(
              $PlantSpeciesTableTable.$convertersowingMonths);
  static const VerificationMeta _rowSpacingCmMeta =
      const VerificationMeta('rowSpacingCm');
  @override
  late final GeneratedColumn<int> rowSpacingCm = GeneratedColumn<int>(
      'row_spacing_cm', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _plantSpacingCmMeta =
      const VerificationMeta('plantSpacingCm');
  @override
  late final GeneratedColumn<int> plantSpacingCm = GeneratedColumn<int>(
      'plant_spacing_cm', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        scientificName,
        commonName,
        imageUrl,
        light,
        minTempC,
        maxTempC,
        soil,
        watering,
        fertilizing,
        diagnostics,
        cutting,
        repotting,
        sowingMonths,
        rowSpacingCm,
        plantSpacingCm,
        notes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plant_species';
  @override
  VerificationContext validateIntegrity(Insertable<PlantSpeciesRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('scientific_name')) {
      context.handle(
          _scientificNameMeta,
          scientificName.isAcceptableOrUnknown(
              data['scientific_name']!, _scientificNameMeta));
    } else if (isInserting) {
      context.missing(_scientificNameMeta);
    }
    if (data.containsKey('common_name')) {
      context.handle(
          _commonNameMeta,
          commonName.isAcceptableOrUnknown(
              data['common_name']!, _commonNameMeta));
    } else if (isInserting) {
      context.missing(_commonNameMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    if (data.containsKey('min_temp_c')) {
      context.handle(_minTempCMeta,
          minTempC.isAcceptableOrUnknown(data['min_temp_c']!, _minTempCMeta));
    } else if (isInserting) {
      context.missing(_minTempCMeta);
    }
    if (data.containsKey('max_temp_c')) {
      context.handle(_maxTempCMeta,
          maxTempC.isAcceptableOrUnknown(data['max_temp_c']!, _maxTempCMeta));
    } else if (isInserting) {
      context.missing(_maxTempCMeta);
    }
    if (data.containsKey('soil')) {
      context.handle(
          _soilMeta, soil.isAcceptableOrUnknown(data['soil']!, _soilMeta));
    } else if (isInserting) {
      context.missing(_soilMeta);
    }
    if (data.containsKey('row_spacing_cm')) {
      context.handle(
          _rowSpacingCmMeta,
          rowSpacingCm.isAcceptableOrUnknown(
              data['row_spacing_cm']!, _rowSpacingCmMeta));
    }
    if (data.containsKey('plant_spacing_cm')) {
      context.handle(
          _plantSpacingCmMeta,
          plantSpacingCm.isAcceptableOrUnknown(
              data['plant_spacing_cm']!, _plantSpacingCmMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlantSpeciesRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlantSpeciesRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      scientificName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}scientific_name'])!,
      commonName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}common_name'])!,
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url']),
      light: $PlantSpeciesTableTable.$converterlight.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}light'])!),
      minTempC: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}min_temp_c'])!,
      maxTempC: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}max_temp_c'])!,
      soil: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}soil'])!,
      watering: $PlantSpeciesTableTable.$converterwatering.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}watering'])!),
      fertilizing: $PlantSpeciesTableTable.$converterfertilizing.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}fertilizing'])!),
      diagnostics: $PlantSpeciesTableTable.$converterdiagnostics.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}diagnostics'])!),
      cutting: $PlantSpeciesTableTable.$convertercuttingn.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}cutting'])),
      repotting: $PlantSpeciesTableTable.$converterrepottingn.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}repotting'])),
      sowingMonths: $PlantSpeciesTableTable.$convertersowingMonths.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}sowing_months'])!),
      rowSpacingCm: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}row_spacing_cm']),
      plantSpacingCm: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}plant_spacing_cm']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $PlantSpeciesTableTable createAlias(String alias) {
    return $PlantSpeciesTableTable(attachedDatabase, alias);
  }

  static TypeConverter<List<LightLevel>, String> $converterlight =
      const LightLevelsConverter();
  static TypeConverter<CareSchedule, String> $converterwatering =
      const CareScheduleConverter();
  static TypeConverter<CareSchedule, String> $converterfertilizing =
      const CareScheduleConverter();
  static TypeConverter<List<Diagnostic>, String> $converterdiagnostics =
      const DiagnosticsConverter();
  static TypeConverter<PropagationInfo, String> $convertercutting =
      const PropagationConverter();
  static TypeConverter<PropagationInfo?, String?> $convertercuttingn =
      NullAwareTypeConverter.wrap($convertercutting);
  static TypeConverter<RepottingInfo, String> $converterrepotting =
      const RepottingConverter();
  static TypeConverter<RepottingInfo?, String?> $converterrepottingn =
      NullAwareTypeConverter.wrap($converterrepotting);
  static TypeConverter<List<int>, String> $convertersowingMonths =
      const MonthsConverter();
}

class PlantSpeciesRow extends DataClass implements Insertable<PlantSpeciesRow> {
  final String id;
  final String scientificName;
  final String commonName;
  final String? imageUrl;
  final List<LightLevel> light;
  final double minTempC;
  final double maxTempC;
  final String soil;
  final CareSchedule watering;
  final CareSchedule fertilizing;
  final List<Diagnostic> diagnostics;
  final PropagationInfo? cutting;
  final RepottingInfo? repotting;
  final List<int> sowingMonths;
  final int? rowSpacingCm;
  final int? plantSpacingCm;
  final String? notes;
  const PlantSpeciesRow(
      {required this.id,
      required this.scientificName,
      required this.commonName,
      this.imageUrl,
      required this.light,
      required this.minTempC,
      required this.maxTempC,
      required this.soil,
      required this.watering,
      required this.fertilizing,
      required this.diagnostics,
      this.cutting,
      this.repotting,
      required this.sowingMonths,
      this.rowSpacingCm,
      this.plantSpacingCm,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['scientific_name'] = Variable<String>(scientificName);
    map['common_name'] = Variable<String>(commonName);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    {
      map['light'] = Variable<String>(
          $PlantSpeciesTableTable.$converterlight.toSql(light));
    }
    map['min_temp_c'] = Variable<double>(minTempC);
    map['max_temp_c'] = Variable<double>(maxTempC);
    map['soil'] = Variable<String>(soil);
    {
      map['watering'] = Variable<String>(
          $PlantSpeciesTableTable.$converterwatering.toSql(watering));
    }
    {
      map['fertilizing'] = Variable<String>(
          $PlantSpeciesTableTable.$converterfertilizing.toSql(fertilizing));
    }
    {
      map['diagnostics'] = Variable<String>(
          $PlantSpeciesTableTable.$converterdiagnostics.toSql(diagnostics));
    }
    if (!nullToAbsent || cutting != null) {
      map['cutting'] = Variable<String>(
          $PlantSpeciesTableTable.$convertercuttingn.toSql(cutting));
    }
    if (!nullToAbsent || repotting != null) {
      map['repotting'] = Variable<String>(
          $PlantSpeciesTableTable.$converterrepottingn.toSql(repotting));
    }
    {
      map['sowing_months'] = Variable<String>(
          $PlantSpeciesTableTable.$convertersowingMonths.toSql(sowingMonths));
    }
    if (!nullToAbsent || rowSpacingCm != null) {
      map['row_spacing_cm'] = Variable<int>(rowSpacingCm);
    }
    if (!nullToAbsent || plantSpacingCm != null) {
      map['plant_spacing_cm'] = Variable<int>(plantSpacingCm);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  PlantSpeciesTableCompanion toCompanion(bool nullToAbsent) {
    return PlantSpeciesTableCompanion(
      id: Value(id),
      scientificName: Value(scientificName),
      commonName: Value(commonName),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      light: Value(light),
      minTempC: Value(minTempC),
      maxTempC: Value(maxTempC),
      soil: Value(soil),
      watering: Value(watering),
      fertilizing: Value(fertilizing),
      diagnostics: Value(diagnostics),
      cutting: cutting == null && nullToAbsent
          ? const Value.absent()
          : Value(cutting),
      repotting: repotting == null && nullToAbsent
          ? const Value.absent()
          : Value(repotting),
      sowingMonths: Value(sowingMonths),
      rowSpacingCm: rowSpacingCm == null && nullToAbsent
          ? const Value.absent()
          : Value(rowSpacingCm),
      plantSpacingCm: plantSpacingCm == null && nullToAbsent
          ? const Value.absent()
          : Value(plantSpacingCm),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory PlantSpeciesRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlantSpeciesRow(
      id: serializer.fromJson<String>(json['id']),
      scientificName: serializer.fromJson<String>(json['scientificName']),
      commonName: serializer.fromJson<String>(json['commonName']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      light: serializer.fromJson<List<LightLevel>>(json['light']),
      minTempC: serializer.fromJson<double>(json['minTempC']),
      maxTempC: serializer.fromJson<double>(json['maxTempC']),
      soil: serializer.fromJson<String>(json['soil']),
      watering: serializer.fromJson<CareSchedule>(json['watering']),
      fertilizing: serializer.fromJson<CareSchedule>(json['fertilizing']),
      diagnostics: serializer.fromJson<List<Diagnostic>>(json['diagnostics']),
      cutting: serializer.fromJson<PropagationInfo?>(json['cutting']),
      repotting: serializer.fromJson<RepottingInfo?>(json['repotting']),
      sowingMonths: serializer.fromJson<List<int>>(json['sowingMonths']),
      rowSpacingCm: serializer.fromJson<int?>(json['rowSpacingCm']),
      plantSpacingCm: serializer.fromJson<int?>(json['plantSpacingCm']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'scientificName': serializer.toJson<String>(scientificName),
      'commonName': serializer.toJson<String>(commonName),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'light': serializer.toJson<List<LightLevel>>(light),
      'minTempC': serializer.toJson<double>(minTempC),
      'maxTempC': serializer.toJson<double>(maxTempC),
      'soil': serializer.toJson<String>(soil),
      'watering': serializer.toJson<CareSchedule>(watering),
      'fertilizing': serializer.toJson<CareSchedule>(fertilizing),
      'diagnostics': serializer.toJson<List<Diagnostic>>(diagnostics),
      'cutting': serializer.toJson<PropagationInfo?>(cutting),
      'repotting': serializer.toJson<RepottingInfo?>(repotting),
      'sowingMonths': serializer.toJson<List<int>>(sowingMonths),
      'rowSpacingCm': serializer.toJson<int?>(rowSpacingCm),
      'plantSpacingCm': serializer.toJson<int?>(plantSpacingCm),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  PlantSpeciesRow copyWith(
          {String? id,
          String? scientificName,
          String? commonName,
          Value<String?> imageUrl = const Value.absent(),
          List<LightLevel>? light,
          double? minTempC,
          double? maxTempC,
          String? soil,
          CareSchedule? watering,
          CareSchedule? fertilizing,
          List<Diagnostic>? diagnostics,
          Value<PropagationInfo?> cutting = const Value.absent(),
          Value<RepottingInfo?> repotting = const Value.absent(),
          List<int>? sowingMonths,
          Value<int?> rowSpacingCm = const Value.absent(),
          Value<int?> plantSpacingCm = const Value.absent(),
          Value<String?> notes = const Value.absent()}) =>
      PlantSpeciesRow(
        id: id ?? this.id,
        scientificName: scientificName ?? this.scientificName,
        commonName: commonName ?? this.commonName,
        imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
        light: light ?? this.light,
        minTempC: minTempC ?? this.minTempC,
        maxTempC: maxTempC ?? this.maxTempC,
        soil: soil ?? this.soil,
        watering: watering ?? this.watering,
        fertilizing: fertilizing ?? this.fertilizing,
        diagnostics: diagnostics ?? this.diagnostics,
        cutting: cutting.present ? cutting.value : this.cutting,
        repotting: repotting.present ? repotting.value : this.repotting,
        sowingMonths: sowingMonths ?? this.sowingMonths,
        rowSpacingCm:
            rowSpacingCm.present ? rowSpacingCm.value : this.rowSpacingCm,
        plantSpacingCm:
            plantSpacingCm.present ? plantSpacingCm.value : this.plantSpacingCm,
        notes: notes.present ? notes.value : this.notes,
      );
  PlantSpeciesRow copyWithCompanion(PlantSpeciesTableCompanion data) {
    return PlantSpeciesRow(
      id: data.id.present ? data.id.value : this.id,
      scientificName: data.scientificName.present
          ? data.scientificName.value
          : this.scientificName,
      commonName:
          data.commonName.present ? data.commonName.value : this.commonName,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      light: data.light.present ? data.light.value : this.light,
      minTempC: data.minTempC.present ? data.minTempC.value : this.minTempC,
      maxTempC: data.maxTempC.present ? data.maxTempC.value : this.maxTempC,
      soil: data.soil.present ? data.soil.value : this.soil,
      watering: data.watering.present ? data.watering.value : this.watering,
      fertilizing:
          data.fertilizing.present ? data.fertilizing.value : this.fertilizing,
      diagnostics:
          data.diagnostics.present ? data.diagnostics.value : this.diagnostics,
      cutting: data.cutting.present ? data.cutting.value : this.cutting,
      repotting: data.repotting.present ? data.repotting.value : this.repotting,
      sowingMonths: data.sowingMonths.present
          ? data.sowingMonths.value
          : this.sowingMonths,
      rowSpacingCm: data.rowSpacingCm.present
          ? data.rowSpacingCm.value
          : this.rowSpacingCm,
      plantSpacingCm: data.plantSpacingCm.present
          ? data.plantSpacingCm.value
          : this.plantSpacingCm,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlantSpeciesRow(')
          ..write('id: $id, ')
          ..write('scientificName: $scientificName, ')
          ..write('commonName: $commonName, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('light: $light, ')
          ..write('minTempC: $minTempC, ')
          ..write('maxTempC: $maxTempC, ')
          ..write('soil: $soil, ')
          ..write('watering: $watering, ')
          ..write('fertilizing: $fertilizing, ')
          ..write('diagnostics: $diagnostics, ')
          ..write('cutting: $cutting, ')
          ..write('repotting: $repotting, ')
          ..write('sowingMonths: $sowingMonths, ')
          ..write('rowSpacingCm: $rowSpacingCm, ')
          ..write('plantSpacingCm: $plantSpacingCm, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      scientificName,
      commonName,
      imageUrl,
      light,
      minTempC,
      maxTempC,
      soil,
      watering,
      fertilizing,
      diagnostics,
      cutting,
      repotting,
      sowingMonths,
      rowSpacingCm,
      plantSpacingCm,
      notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlantSpeciesRow &&
          other.id == this.id &&
          other.scientificName == this.scientificName &&
          other.commonName == this.commonName &&
          other.imageUrl == this.imageUrl &&
          other.light == this.light &&
          other.minTempC == this.minTempC &&
          other.maxTempC == this.maxTempC &&
          other.soil == this.soil &&
          other.watering == this.watering &&
          other.fertilizing == this.fertilizing &&
          other.diagnostics == this.diagnostics &&
          other.cutting == this.cutting &&
          other.repotting == this.repotting &&
          other.sowingMonths == this.sowingMonths &&
          other.rowSpacingCm == this.rowSpacingCm &&
          other.plantSpacingCm == this.plantSpacingCm &&
          other.notes == this.notes);
}

class PlantSpeciesTableCompanion extends UpdateCompanion<PlantSpeciesRow> {
  final Value<String> id;
  final Value<String> scientificName;
  final Value<String> commonName;
  final Value<String?> imageUrl;
  final Value<List<LightLevel>> light;
  final Value<double> minTempC;
  final Value<double> maxTempC;
  final Value<String> soil;
  final Value<CareSchedule> watering;
  final Value<CareSchedule> fertilizing;
  final Value<List<Diagnostic>> diagnostics;
  final Value<PropagationInfo?> cutting;
  final Value<RepottingInfo?> repotting;
  final Value<List<int>> sowingMonths;
  final Value<int?> rowSpacingCm;
  final Value<int?> plantSpacingCm;
  final Value<String?> notes;
  final Value<int> rowid;
  const PlantSpeciesTableCompanion({
    this.id = const Value.absent(),
    this.scientificName = const Value.absent(),
    this.commonName = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.light = const Value.absent(),
    this.minTempC = const Value.absent(),
    this.maxTempC = const Value.absent(),
    this.soil = const Value.absent(),
    this.watering = const Value.absent(),
    this.fertilizing = const Value.absent(),
    this.diagnostics = const Value.absent(),
    this.cutting = const Value.absent(),
    this.repotting = const Value.absent(),
    this.sowingMonths = const Value.absent(),
    this.rowSpacingCm = const Value.absent(),
    this.plantSpacingCm = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlantSpeciesTableCompanion.insert({
    required String id,
    required String scientificName,
    required String commonName,
    this.imageUrl = const Value.absent(),
    required List<LightLevel> light,
    required double minTempC,
    required double maxTempC,
    required String soil,
    required CareSchedule watering,
    required CareSchedule fertilizing,
    required List<Diagnostic> diagnostics,
    this.cutting = const Value.absent(),
    this.repotting = const Value.absent(),
    this.sowingMonths = const Value.absent(),
    this.rowSpacingCm = const Value.absent(),
    this.plantSpacingCm = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        scientificName = Value(scientificName),
        commonName = Value(commonName),
        light = Value(light),
        minTempC = Value(minTempC),
        maxTempC = Value(maxTempC),
        soil = Value(soil),
        watering = Value(watering),
        fertilizing = Value(fertilizing),
        diagnostics = Value(diagnostics);
  static Insertable<PlantSpeciesRow> custom({
    Expression<String>? id,
    Expression<String>? scientificName,
    Expression<String>? commonName,
    Expression<String>? imageUrl,
    Expression<String>? light,
    Expression<double>? minTempC,
    Expression<double>? maxTempC,
    Expression<String>? soil,
    Expression<String>? watering,
    Expression<String>? fertilizing,
    Expression<String>? diagnostics,
    Expression<String>? cutting,
    Expression<String>? repotting,
    Expression<String>? sowingMonths,
    Expression<int>? rowSpacingCm,
    Expression<int>? plantSpacingCm,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scientificName != null) 'scientific_name': scientificName,
      if (commonName != null) 'common_name': commonName,
      if (imageUrl != null) 'image_url': imageUrl,
      if (light != null) 'light': light,
      if (minTempC != null) 'min_temp_c': minTempC,
      if (maxTempC != null) 'max_temp_c': maxTempC,
      if (soil != null) 'soil': soil,
      if (watering != null) 'watering': watering,
      if (fertilizing != null) 'fertilizing': fertilizing,
      if (diagnostics != null) 'diagnostics': diagnostics,
      if (cutting != null) 'cutting': cutting,
      if (repotting != null) 'repotting': repotting,
      if (sowingMonths != null) 'sowing_months': sowingMonths,
      if (rowSpacingCm != null) 'row_spacing_cm': rowSpacingCm,
      if (plantSpacingCm != null) 'plant_spacing_cm': plantSpacingCm,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlantSpeciesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? scientificName,
      Value<String>? commonName,
      Value<String?>? imageUrl,
      Value<List<LightLevel>>? light,
      Value<double>? minTempC,
      Value<double>? maxTempC,
      Value<String>? soil,
      Value<CareSchedule>? watering,
      Value<CareSchedule>? fertilizing,
      Value<List<Diagnostic>>? diagnostics,
      Value<PropagationInfo?>? cutting,
      Value<RepottingInfo?>? repotting,
      Value<List<int>>? sowingMonths,
      Value<int?>? rowSpacingCm,
      Value<int?>? plantSpacingCm,
      Value<String?>? notes,
      Value<int>? rowid}) {
    return PlantSpeciesTableCompanion(
      id: id ?? this.id,
      scientificName: scientificName ?? this.scientificName,
      commonName: commonName ?? this.commonName,
      imageUrl: imageUrl ?? this.imageUrl,
      light: light ?? this.light,
      minTempC: minTempC ?? this.minTempC,
      maxTempC: maxTempC ?? this.maxTempC,
      soil: soil ?? this.soil,
      watering: watering ?? this.watering,
      fertilizing: fertilizing ?? this.fertilizing,
      diagnostics: diagnostics ?? this.diagnostics,
      cutting: cutting ?? this.cutting,
      repotting: repotting ?? this.repotting,
      sowingMonths: sowingMonths ?? this.sowingMonths,
      rowSpacingCm: rowSpacingCm ?? this.rowSpacingCm,
      plantSpacingCm: plantSpacingCm ?? this.plantSpacingCm,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (scientificName.present) {
      map['scientific_name'] = Variable<String>(scientificName.value);
    }
    if (commonName.present) {
      map['common_name'] = Variable<String>(commonName.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (light.present) {
      map['light'] = Variable<String>(
          $PlantSpeciesTableTable.$converterlight.toSql(light.value));
    }
    if (minTempC.present) {
      map['min_temp_c'] = Variable<double>(minTempC.value);
    }
    if (maxTempC.present) {
      map['max_temp_c'] = Variable<double>(maxTempC.value);
    }
    if (soil.present) {
      map['soil'] = Variable<String>(soil.value);
    }
    if (watering.present) {
      map['watering'] = Variable<String>(
          $PlantSpeciesTableTable.$converterwatering.toSql(watering.value));
    }
    if (fertilizing.present) {
      map['fertilizing'] = Variable<String>($PlantSpeciesTableTable
          .$converterfertilizing
          .toSql(fertilizing.value));
    }
    if (diagnostics.present) {
      map['diagnostics'] = Variable<String>($PlantSpeciesTableTable
          .$converterdiagnostics
          .toSql(diagnostics.value));
    }
    if (cutting.present) {
      map['cutting'] = Variable<String>(
          $PlantSpeciesTableTable.$convertercuttingn.toSql(cutting.value));
    }
    if (repotting.present) {
      map['repotting'] = Variable<String>(
          $PlantSpeciesTableTable.$converterrepottingn.toSql(repotting.value));
    }
    if (sowingMonths.present) {
      map['sowing_months'] = Variable<String>($PlantSpeciesTableTable
          .$convertersowingMonths
          .toSql(sowingMonths.value));
    }
    if (rowSpacingCm.present) {
      map['row_spacing_cm'] = Variable<int>(rowSpacingCm.value);
    }
    if (plantSpacingCm.present) {
      map['plant_spacing_cm'] = Variable<int>(plantSpacingCm.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlantSpeciesTableCompanion(')
          ..write('id: $id, ')
          ..write('scientificName: $scientificName, ')
          ..write('commonName: $commonName, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('light: $light, ')
          ..write('minTempC: $minTempC, ')
          ..write('maxTempC: $maxTempC, ')
          ..write('soil: $soil, ')
          ..write('watering: $watering, ')
          ..write('fertilizing: $fertilizing, ')
          ..write('diagnostics: $diagnostics, ')
          ..write('cutting: $cutting, ')
          ..write('repotting: $repotting, ')
          ..write('sowingMonths: $sowingMonths, ')
          ..write('rowSpacingCm: $rowSpacingCm, ')
          ..write('plantSpacingCm: $plantSpacingCm, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OwnedPlantsTable extends OwnedPlants
    with TableInfo<$OwnedPlantsTable, OwnedPlantRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OwnedPlantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _speciesIdMeta =
      const VerificationMeta('speciesId');
  @override
  late final GeneratedColumn<String> speciesId = GeneratedColumn<String>(
      'species_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES plant_species (id)'));
  static const VerificationMeta _nicknameMeta =
      const VerificationMeta('nickname');
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
      'nickname', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _spaceIdMeta =
      const VerificationMeta('spaceId');
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
      'space_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES spaces (id) ON DELETE SET NULL'));
  static const VerificationMeta _xMeta = const VerificationMeta('x');
  @override
  late final GeneratedColumn<double> x = GeneratedColumn<double>(
      'x', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _yMeta = const VerificationMeta('y');
  @override
  late final GeneratedColumn<double> y = GeneratedColumn<double>(
      'y', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, speciesId, nickname, spaceId, x, y];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'owned_plants';
  @override
  VerificationContext validateIntegrity(Insertable<OwnedPlantRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('species_id')) {
      context.handle(_speciesIdMeta,
          speciesId.isAcceptableOrUnknown(data['species_id']!, _speciesIdMeta));
    } else if (isInserting) {
      context.missing(_speciesIdMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(_nicknameMeta,
          nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta));
    } else if (isInserting) {
      context.missing(_nicknameMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(_spaceIdMeta,
          spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta));
    }
    if (data.containsKey('x')) {
      context.handle(_xMeta, x.isAcceptableOrUnknown(data['x']!, _xMeta));
    }
    if (data.containsKey('y')) {
      context.handle(_yMeta, y.isAcceptableOrUnknown(data['y']!, _yMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OwnedPlantRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OwnedPlantRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      speciesId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}species_id'])!,
      nickname: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nickname'])!,
      spaceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}space_id']),
      x: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}x']),
      y: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}y']),
    );
  }

  @override
  $OwnedPlantsTable createAlias(String alias) {
    return $OwnedPlantsTable(attachedDatabase, alias);
  }
}

class OwnedPlantRow extends DataClass implements Insertable<OwnedPlantRow> {
  final String id;
  final String speciesId;
  final String nickname;
  final String? spaceId;
  final double? x;
  final double? y;
  const OwnedPlantRow(
      {required this.id,
      required this.speciesId,
      required this.nickname,
      this.spaceId,
      this.x,
      this.y});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['species_id'] = Variable<String>(speciesId);
    map['nickname'] = Variable<String>(nickname);
    if (!nullToAbsent || spaceId != null) {
      map['space_id'] = Variable<String>(spaceId);
    }
    if (!nullToAbsent || x != null) {
      map['x'] = Variable<double>(x);
    }
    if (!nullToAbsent || y != null) {
      map['y'] = Variable<double>(y);
    }
    return map;
  }

  OwnedPlantsCompanion toCompanion(bool nullToAbsent) {
    return OwnedPlantsCompanion(
      id: Value(id),
      speciesId: Value(speciesId),
      nickname: Value(nickname),
      spaceId: spaceId == null && nullToAbsent
          ? const Value.absent()
          : Value(spaceId),
      x: x == null && nullToAbsent ? const Value.absent() : Value(x),
      y: y == null && nullToAbsent ? const Value.absent() : Value(y),
    );
  }

  factory OwnedPlantRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OwnedPlantRow(
      id: serializer.fromJson<String>(json['id']),
      speciesId: serializer.fromJson<String>(json['speciesId']),
      nickname: serializer.fromJson<String>(json['nickname']),
      spaceId: serializer.fromJson<String?>(json['spaceId']),
      x: serializer.fromJson<double?>(json['x']),
      y: serializer.fromJson<double?>(json['y']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'speciesId': serializer.toJson<String>(speciesId),
      'nickname': serializer.toJson<String>(nickname),
      'spaceId': serializer.toJson<String?>(spaceId),
      'x': serializer.toJson<double?>(x),
      'y': serializer.toJson<double?>(y),
    };
  }

  OwnedPlantRow copyWith(
          {String? id,
          String? speciesId,
          String? nickname,
          Value<String?> spaceId = const Value.absent(),
          Value<double?> x = const Value.absent(),
          Value<double?> y = const Value.absent()}) =>
      OwnedPlantRow(
        id: id ?? this.id,
        speciesId: speciesId ?? this.speciesId,
        nickname: nickname ?? this.nickname,
        spaceId: spaceId.present ? spaceId.value : this.spaceId,
        x: x.present ? x.value : this.x,
        y: y.present ? y.value : this.y,
      );
  OwnedPlantRow copyWithCompanion(OwnedPlantsCompanion data) {
    return OwnedPlantRow(
      id: data.id.present ? data.id.value : this.id,
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      x: data.x.present ? data.x.value : this.x,
      y: data.y.present ? data.y.value : this.y,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OwnedPlantRow(')
          ..write('id: $id, ')
          ..write('speciesId: $speciesId, ')
          ..write('nickname: $nickname, ')
          ..write('spaceId: $spaceId, ')
          ..write('x: $x, ')
          ..write('y: $y')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, speciesId, nickname, spaceId, x, y);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OwnedPlantRow &&
          other.id == this.id &&
          other.speciesId == this.speciesId &&
          other.nickname == this.nickname &&
          other.spaceId == this.spaceId &&
          other.x == this.x &&
          other.y == this.y);
}

class OwnedPlantsCompanion extends UpdateCompanion<OwnedPlantRow> {
  final Value<String> id;
  final Value<String> speciesId;
  final Value<String> nickname;
  final Value<String?> spaceId;
  final Value<double?> x;
  final Value<double?> y;
  final Value<int> rowid;
  const OwnedPlantsCompanion({
    this.id = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.nickname = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.x = const Value.absent(),
    this.y = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OwnedPlantsCompanion.insert({
    required String id,
    required String speciesId,
    required String nickname,
    this.spaceId = const Value.absent(),
    this.x = const Value.absent(),
    this.y = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        speciesId = Value(speciesId),
        nickname = Value(nickname);
  static Insertable<OwnedPlantRow> custom({
    Expression<String>? id,
    Expression<String>? speciesId,
    Expression<String>? nickname,
    Expression<String>? spaceId,
    Expression<double>? x,
    Expression<double>? y,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (speciesId != null) 'species_id': speciesId,
      if (nickname != null) 'nickname': nickname,
      if (spaceId != null) 'space_id': spaceId,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OwnedPlantsCompanion copyWith(
      {Value<String>? id,
      Value<String>? speciesId,
      Value<String>? nickname,
      Value<String?>? spaceId,
      Value<double?>? x,
      Value<double?>? y,
      Value<int>? rowid}) {
    return OwnedPlantsCompanion(
      id: id ?? this.id,
      speciesId: speciesId ?? this.speciesId,
      nickname: nickname ?? this.nickname,
      spaceId: spaceId ?? this.spaceId,
      x: x ?? this.x,
      y: y ?? this.y,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (speciesId.present) {
      map['species_id'] = Variable<String>(speciesId.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (x.present) {
      map['x'] = Variable<double>(x.value);
    }
    if (y.present) {
      map['y'] = Variable<double>(y.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OwnedPlantsCompanion(')
          ..write('id: $id, ')
          ..write('speciesId: $speciesId, ')
          ..write('nickname: $nickname, ')
          ..write('spaceId: $spaceId, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CareTasksTable extends CareTasks
    with TableInfo<$CareTasksTable, CareTaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CareTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _plantIdMeta =
      const VerificationMeta('plantId');
  @override
  late final GeneratedColumn<String> plantId = GeneratedColumn<String>(
      'plant_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES owned_plants (id) ON DELETE CASCADE'));
  @override
  late final GeneratedColumnWithTypeConverter<CareType, String> type =
      GeneratedColumn<String>('type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<CareType>($CareTasksTable.$convertertype);
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
      'due_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _doneAtMeta = const VerificationMeta('doneAt');
  @override
  late final GeneratedColumn<DateTime> doneAt = GeneratedColumn<DateTime>(
      'done_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, plantId, type, dueAt, doneAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'care_tasks';
  @override
  VerificationContext validateIntegrity(Insertable<CareTaskRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('plant_id')) {
      context.handle(_plantIdMeta,
          plantId.isAcceptableOrUnknown(data['plant_id']!, _plantIdMeta));
    } else if (isInserting) {
      context.missing(_plantIdMeta);
    }
    if (data.containsKey('due_at')) {
      context.handle(
          _dueAtMeta, dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta));
    } else if (isInserting) {
      context.missing(_dueAtMeta);
    }
    if (data.containsKey('done_at')) {
      context.handle(_doneAtMeta,
          doneAt.isAcceptableOrUnknown(data['done_at']!, _doneAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CareTaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CareTaskRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      plantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}plant_id'])!,
      type: $CareTasksTable.$convertertype.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!),
      dueAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_at'])!,
      doneAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}done_at']),
    );
  }

  @override
  $CareTasksTable createAlias(String alias) {
    return $CareTasksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CareType, String, String> $convertertype =
      const EnumNameConverter<CareType>(CareType.values);
}

class CareTaskRow extends DataClass implements Insertable<CareTaskRow> {
  final String id;
  final String plantId;
  final CareType type;
  final DateTime dueAt;
  final DateTime? doneAt;
  const CareTaskRow(
      {required this.id,
      required this.plantId,
      required this.type,
      required this.dueAt,
      this.doneAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plant_id'] = Variable<String>(plantId);
    {
      map['type'] =
          Variable<String>($CareTasksTable.$convertertype.toSql(type));
    }
    map['due_at'] = Variable<DateTime>(dueAt);
    if (!nullToAbsent || doneAt != null) {
      map['done_at'] = Variable<DateTime>(doneAt);
    }
    return map;
  }

  CareTasksCompanion toCompanion(bool nullToAbsent) {
    return CareTasksCompanion(
      id: Value(id),
      plantId: Value(plantId),
      type: Value(type),
      dueAt: Value(dueAt),
      doneAt:
          doneAt == null && nullToAbsent ? const Value.absent() : Value(doneAt),
    );
  }

  factory CareTaskRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CareTaskRow(
      id: serializer.fromJson<String>(json['id']),
      plantId: serializer.fromJson<String>(json['plantId']),
      type: $CareTasksTable.$convertertype
          .fromJson(serializer.fromJson<String>(json['type'])),
      dueAt: serializer.fromJson<DateTime>(json['dueAt']),
      doneAt: serializer.fromJson<DateTime?>(json['doneAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'plantId': serializer.toJson<String>(plantId),
      'type': serializer
          .toJson<String>($CareTasksTable.$convertertype.toJson(type)),
      'dueAt': serializer.toJson<DateTime>(dueAt),
      'doneAt': serializer.toJson<DateTime?>(doneAt),
    };
  }

  CareTaskRow copyWith(
          {String? id,
          String? plantId,
          CareType? type,
          DateTime? dueAt,
          Value<DateTime?> doneAt = const Value.absent()}) =>
      CareTaskRow(
        id: id ?? this.id,
        plantId: plantId ?? this.plantId,
        type: type ?? this.type,
        dueAt: dueAt ?? this.dueAt,
        doneAt: doneAt.present ? doneAt.value : this.doneAt,
      );
  CareTaskRow copyWithCompanion(CareTasksCompanion data) {
    return CareTaskRow(
      id: data.id.present ? data.id.value : this.id,
      plantId: data.plantId.present ? data.plantId.value : this.plantId,
      type: data.type.present ? data.type.value : this.type,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      doneAt: data.doneAt.present ? data.doneAt.value : this.doneAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CareTaskRow(')
          ..write('id: $id, ')
          ..write('plantId: $plantId, ')
          ..write('type: $type, ')
          ..write('dueAt: $dueAt, ')
          ..write('doneAt: $doneAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, plantId, type, dueAt, doneAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CareTaskRow &&
          other.id == this.id &&
          other.plantId == this.plantId &&
          other.type == this.type &&
          other.dueAt == this.dueAt &&
          other.doneAt == this.doneAt);
}

class CareTasksCompanion extends UpdateCompanion<CareTaskRow> {
  final Value<String> id;
  final Value<String> plantId;
  final Value<CareType> type;
  final Value<DateTime> dueAt;
  final Value<DateTime?> doneAt;
  final Value<int> rowid;
  const CareTasksCompanion({
    this.id = const Value.absent(),
    this.plantId = const Value.absent(),
    this.type = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.doneAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CareTasksCompanion.insert({
    required String id,
    required String plantId,
    required CareType type,
    required DateTime dueAt,
    this.doneAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        plantId = Value(plantId),
        type = Value(type),
        dueAt = Value(dueAt);
  static Insertable<CareTaskRow> custom({
    Expression<String>? id,
    Expression<String>? plantId,
    Expression<String>? type,
    Expression<DateTime>? dueAt,
    Expression<DateTime>? doneAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (plantId != null) 'plant_id': plantId,
      if (type != null) 'type': type,
      if (dueAt != null) 'due_at': dueAt,
      if (doneAt != null) 'done_at': doneAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CareTasksCompanion copyWith(
      {Value<String>? id,
      Value<String>? plantId,
      Value<CareType>? type,
      Value<DateTime>? dueAt,
      Value<DateTime?>? doneAt,
      Value<int>? rowid}) {
    return CareTasksCompanion(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      type: type ?? this.type,
      dueAt: dueAt ?? this.dueAt,
      doneAt: doneAt ?? this.doneAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (plantId.present) {
      map['plant_id'] = Variable<String>(plantId.value);
    }
    if (type.present) {
      map['type'] =
          Variable<String>($CareTasksTable.$convertertype.toSql(type.value));
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (doneAt.present) {
      map['done_at'] = Variable<DateTime>(doneAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CareTasksCompanion(')
          ..write('id: $id, ')
          ..write('plantId: $plantId, ')
          ..write('type: $type, ')
          ..write('dueAt: $dueAt, ')
          ..write('doneAt: $doneAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ApiCacheEntriesTable extends ApiCacheEntries
    with TableInfo<$ApiCacheEntriesTable, ApiCacheRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ApiCacheEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fetchedAtMeta =
      const VerificationMeta('fetchedAt');
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
      'fetched_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, body, fetchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'api_cache_entries';
  @override
  VerificationContext validateIntegrity(Insertable<ApiCacheRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(_fetchedAtMeta,
          fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta));
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  ApiCacheRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ApiCacheRow(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      fetchedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fetched_at'])!,
    );
  }

  @override
  $ApiCacheEntriesTable createAlias(String alias) {
    return $ApiCacheEntriesTable(attachedDatabase, alias);
  }
}

class ApiCacheRow extends DataClass implements Insertable<ApiCacheRow> {
  final String key;
  final String body;
  final DateTime fetchedAt;
  const ApiCacheRow(
      {required this.key, required this.body, required this.fetchedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['body'] = Variable<String>(body);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  ApiCacheEntriesCompanion toCompanion(bool nullToAbsent) {
    return ApiCacheEntriesCompanion(
      key: Value(key),
      body: Value(body),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory ApiCacheRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ApiCacheRow(
      key: serializer.fromJson<String>(json['key']),
      body: serializer.fromJson<String>(json['body']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'body': serializer.toJson<String>(body),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  ApiCacheRow copyWith({String? key, String? body, DateTime? fetchedAt}) =>
      ApiCacheRow(
        key: key ?? this.key,
        body: body ?? this.body,
        fetchedAt: fetchedAt ?? this.fetchedAt,
      );
  ApiCacheRow copyWithCompanion(ApiCacheEntriesCompanion data) {
    return ApiCacheRow(
      key: data.key.present ? data.key.value : this.key,
      body: data.body.present ? data.body.value : this.body,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ApiCacheRow(')
          ..write('key: $key, ')
          ..write('body: $body, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, body, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ApiCacheRow &&
          other.key == this.key &&
          other.body == this.body &&
          other.fetchedAt == this.fetchedAt);
}

class ApiCacheEntriesCompanion extends UpdateCompanion<ApiCacheRow> {
  final Value<String> key;
  final Value<String> body;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const ApiCacheEntriesCompanion({
    this.key = const Value.absent(),
    this.body = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ApiCacheEntriesCompanion.insert({
    required String key,
    required String body,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        body = Value(body),
        fetchedAt = Value(fetchedAt);
  static Insertable<ApiCacheRow> custom({
    Expression<String>? key,
    Expression<String>? body,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (body != null) 'body': body,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ApiCacheEntriesCompanion copyWith(
      {Value<String>? key,
      Value<String>? body,
      Value<DateTime>? fetchedAt,
      Value<int>? rowid}) {
    return ApiCacheEntriesCompanion(
      key: key ?? this.key,
      body: body ?? this.body,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ApiCacheEntriesCompanion(')
          ..write('key: $key, ')
          ..write('body: $body, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SpacesTable spaces = $SpacesTable(this);
  late final $OpeningsTable openings = $OpeningsTable(this);
  late final $LightReadingsTable lightReadings = $LightReadingsTable(this);
  late final $PlantSpeciesTableTable plantSpeciesTable =
      $PlantSpeciesTableTable(this);
  late final $OwnedPlantsTable ownedPlants = $OwnedPlantsTable(this);
  late final $CareTasksTable careTasks = $CareTasksTable(this);
  late final $ApiCacheEntriesTable apiCacheEntries =
      $ApiCacheEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        spaces,
        openings,
        lightReadings,
        plantSpeciesTable,
        ownedPlants,
        careTasks,
        apiCacheEntries
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('spaces',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('openings', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('spaces',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('light_readings', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('spaces',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('owned_plants', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('owned_plants',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('care_tasks', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$SpacesTableCreateCompanionBuilder = SpacesCompanion Function({
  required String id,
  required String name,
  required SpaceKind kind,
  required double x,
  required double y,
  required double width,
  required double height,
  Value<int> rowid,
});
typedef $$SpacesTableUpdateCompanionBuilder = SpacesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<SpaceKind> kind,
  Value<double> x,
  Value<double> y,
  Value<double> width,
  Value<double> height,
  Value<int> rowid,
});

final class $$SpacesTableReferences
    extends BaseReferences<_$AppDatabase, $SpacesTable, SpaceRow> {
  $$SpacesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$OpeningsTable, List<OpeningRow>>
      _openingsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.openings,
              aliasName: 'spaces__id__openings__space_id');

  $$OpeningsTableProcessedTableManager get openingsRefs {
    final manager = $$OpeningsTableTableManager($_db, $_db.openings)
        .filter((f) => f.spaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_openingsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$LightReadingsTable, List<LightReadingRow>>
      _lightReadingsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.lightReadings,
              aliasName: 'spaces__id__light_readings__space_id');

  $$LightReadingsTableProcessedTableManager get lightReadingsRefs {
    final manager = $$LightReadingsTableTableManager($_db, $_db.lightReadings)
        .filter((f) => f.spaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_lightReadingsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$OwnedPlantsTable, List<OwnedPlantRow>>
      _ownedPlantsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.ownedPlants,
              aliasName: 'spaces__id__owned_plants__space_id');

  $$OwnedPlantsTableProcessedTableManager get ownedPlantsRefs {
    final manager = $$OwnedPlantsTableTableManager($_db, $_db.ownedPlants)
        .filter((f) => f.spaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_ownedPlantsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SpacesTableFilterComposer
    extends Composer<_$AppDatabase, $SpacesTable> {
  $$SpacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<SpaceKind, SpaceKind, String> get kind =>
      $composableBuilder(
          column: $table.kind,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<double> get x => $composableBuilder(
      column: $table.x, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get y => $composableBuilder(
      column: $table.y, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get width => $composableBuilder(
      column: $table.width, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get height => $composableBuilder(
      column: $table.height, builder: (column) => ColumnFilters(column));

  Expression<bool> openingsRefs(
      Expression<bool> Function($$OpeningsTableFilterComposer f) f) {
    final $$OpeningsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.openings,
        getReferencedColumn: (t) => t.spaceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OpeningsTableFilterComposer(
              $db: $db,
              $table: $db.openings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> lightReadingsRefs(
      Expression<bool> Function($$LightReadingsTableFilterComposer f) f) {
    final $$LightReadingsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.lightReadings,
        getReferencedColumn: (t) => t.spaceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LightReadingsTableFilterComposer(
              $db: $db,
              $table: $db.lightReadings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> ownedPlantsRefs(
      Expression<bool> Function($$OwnedPlantsTableFilterComposer f) f) {
    final $$OwnedPlantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.ownedPlants,
        getReferencedColumn: (t) => t.spaceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OwnedPlantsTableFilterComposer(
              $db: $db,
              $table: $db.ownedPlants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SpacesTableOrderingComposer
    extends Composer<_$AppDatabase, $SpacesTable> {
  $$SpacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get x => $composableBuilder(
      column: $table.x, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get y => $composableBuilder(
      column: $table.y, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get width => $composableBuilder(
      column: $table.width, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get height => $composableBuilder(
      column: $table.height, builder: (column) => ColumnOrderings(column));
}

class $$SpacesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SpacesTable> {
  $$SpacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SpaceKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<double> get x =>
      $composableBuilder(column: $table.x, builder: (column) => column);

  GeneratedColumn<double> get y =>
      $composableBuilder(column: $table.y, builder: (column) => column);

  GeneratedColumn<double> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<double> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  Expression<T> openingsRefs<T extends Object>(
      Expression<T> Function($$OpeningsTableAnnotationComposer a) f) {
    final $$OpeningsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.openings,
        getReferencedColumn: (t) => t.spaceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OpeningsTableAnnotationComposer(
              $db: $db,
              $table: $db.openings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> lightReadingsRefs<T extends Object>(
      Expression<T> Function($$LightReadingsTableAnnotationComposer a) f) {
    final $$LightReadingsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.lightReadings,
        getReferencedColumn: (t) => t.spaceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LightReadingsTableAnnotationComposer(
              $db: $db,
              $table: $db.lightReadings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> ownedPlantsRefs<T extends Object>(
      Expression<T> Function($$OwnedPlantsTableAnnotationComposer a) f) {
    final $$OwnedPlantsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.ownedPlants,
        getReferencedColumn: (t) => t.spaceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OwnedPlantsTableAnnotationComposer(
              $db: $db,
              $table: $db.ownedPlants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SpacesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SpacesTable,
    SpaceRow,
    $$SpacesTableFilterComposer,
    $$SpacesTableOrderingComposer,
    $$SpacesTableAnnotationComposer,
    $$SpacesTableCreateCompanionBuilder,
    $$SpacesTableUpdateCompanionBuilder,
    (SpaceRow, $$SpacesTableReferences),
    SpaceRow,
    PrefetchHooks Function(
        {bool openingsRefs, bool lightReadingsRefs, bool ownedPlantsRefs})> {
  $$SpacesTableTableManager(_$AppDatabase db, $SpacesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<SpaceKind> kind = const Value.absent(),
            Value<double> x = const Value.absent(),
            Value<double> y = const Value.absent(),
            Value<double> width = const Value.absent(),
            Value<double> height = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SpacesCompanion(
            id: id,
            name: name,
            kind: kind,
            x: x,
            y: y,
            width: width,
            height: height,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required SpaceKind kind,
            required double x,
            required double y,
            required double width,
            required double height,
            Value<int> rowid = const Value.absent(),
          }) =>
              SpacesCompanion.insert(
            id: id,
            name: name,
            kind: kind,
            x: x,
            y: y,
            width: width,
            height: height,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SpacesTable, SpaceRow>(table),
                    $$SpacesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {openingsRefs = false,
              lightReadingsRefs = false,
              ownedPlantsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (openingsRefs) db.openings,
                if (lightReadingsRefs) db.lightReadings,
                if (ownedPlantsRefs) db.ownedPlants
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (openingsRefs)
                    await $_getPrefetchedData<SpaceRow, $SpacesTable,
                            OpeningRow>(
                        currentTable: table,
                        referencedTable:
                            $$SpacesTableReferences._openingsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SpacesTableReferences(db, table, p0).openingsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.spaceId == item.id),
                        typedResults: items),
                  if (lightReadingsRefs)
                    await $_getPrefetchedData<SpaceRow, $SpacesTable,
                            LightReadingRow>(
                        currentTable: table,
                        referencedTable:
                            $$SpacesTableReferences._lightReadingsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SpacesTableReferences(db, table, p0)
                                .lightReadingsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.spaceId == item.id),
                        typedResults: items),
                  if (ownedPlantsRefs)
                    await $_getPrefetchedData<SpaceRow, $SpacesTable,
                            OwnedPlantRow>(
                        currentTable: table,
                        referencedTable:
                            $$SpacesTableReferences._ownedPlantsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SpacesTableReferences(db, table, p0)
                                .ownedPlantsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.spaceId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SpacesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SpacesTable,
    SpaceRow,
    $$SpacesTableFilterComposer,
    $$SpacesTableOrderingComposer,
    $$SpacesTableAnnotationComposer,
    $$SpacesTableCreateCompanionBuilder,
    $$SpacesTableUpdateCompanionBuilder,
    (SpaceRow, $$SpacesTableReferences),
    SpaceRow,
    PrefetchHooks Function(
        {bool openingsRefs, bool lightReadingsRefs, bool ownedPlantsRefs})>;
typedef $$OpeningsTableCreateCompanionBuilder = OpeningsCompanion Function({
  required String id,
  required String spaceId,
  required OpeningKind kind,
  required int wall,
  required double offset,
  required double length,
  Value<int> rowid,
});
typedef $$OpeningsTableUpdateCompanionBuilder = OpeningsCompanion Function({
  Value<String> id,
  Value<String> spaceId,
  Value<OpeningKind> kind,
  Value<int> wall,
  Value<double> offset,
  Value<double> length,
  Value<int> rowid,
});

final class $$OpeningsTableReferences
    extends BaseReferences<_$AppDatabase, $OpeningsTable, OpeningRow> {
  $$OpeningsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SpacesTable _spaceIdTable(_$AppDatabase db) =>
      db.spaces.createAlias('openings__space_id__spaces__id');

  $$SpacesTableProcessedTableManager get spaceId {
    final $_column = $_itemColumn<String>('space_id')!;

    final manager = $$SpacesTableTableManager($_db, $_db.spaces)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_spaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$OpeningsTableFilterComposer
    extends Composer<_$AppDatabase, $OpeningsTable> {
  $$OpeningsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<OpeningKind, OpeningKind, String> get kind =>
      $composableBuilder(
          column: $table.kind,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get wall => $composableBuilder(
      column: $table.wall, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get offset => $composableBuilder(
      column: $table.offset, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get length => $composableBuilder(
      column: $table.length, builder: (column) => ColumnFilters(column));

  $$SpacesTableFilterComposer get spaceId {
    final $$SpacesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.spaceId,
        referencedTable: $db.spaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SpacesTableFilterComposer(
              $db: $db,
              $table: $db.spaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$OpeningsTableOrderingComposer
    extends Composer<_$AppDatabase, $OpeningsTable> {
  $$OpeningsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wall => $composableBuilder(
      column: $table.wall, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get offset => $composableBuilder(
      column: $table.offset, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get length => $composableBuilder(
      column: $table.length, builder: (column) => ColumnOrderings(column));

  $$SpacesTableOrderingComposer get spaceId {
    final $$SpacesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.spaceId,
        referencedTable: $db.spaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SpacesTableOrderingComposer(
              $db: $db,
              $table: $db.spaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$OpeningsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OpeningsTable> {
  $$OpeningsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<OpeningKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get wall =>
      $composableBuilder(column: $table.wall, builder: (column) => column);

  GeneratedColumn<double> get offset =>
      $composableBuilder(column: $table.offset, builder: (column) => column);

  GeneratedColumn<double> get length =>
      $composableBuilder(column: $table.length, builder: (column) => column);

  $$SpacesTableAnnotationComposer get spaceId {
    final $$SpacesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.spaceId,
        referencedTable: $db.spaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SpacesTableAnnotationComposer(
              $db: $db,
              $table: $db.spaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$OpeningsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OpeningsTable,
    OpeningRow,
    $$OpeningsTableFilterComposer,
    $$OpeningsTableOrderingComposer,
    $$OpeningsTableAnnotationComposer,
    $$OpeningsTableCreateCompanionBuilder,
    $$OpeningsTableUpdateCompanionBuilder,
    (OpeningRow, $$OpeningsTableReferences),
    OpeningRow,
    PrefetchHooks Function({bool spaceId})> {
  $$OpeningsTableTableManager(_$AppDatabase db, $OpeningsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OpeningsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OpeningsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OpeningsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> spaceId = const Value.absent(),
            Value<OpeningKind> kind = const Value.absent(),
            Value<int> wall = const Value.absent(),
            Value<double> offset = const Value.absent(),
            Value<double> length = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OpeningsCompanion(
            id: id,
            spaceId: spaceId,
            kind: kind,
            wall: wall,
            offset: offset,
            length: length,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String spaceId,
            required OpeningKind kind,
            required int wall,
            required double offset,
            required double length,
            Value<int> rowid = const Value.absent(),
          }) =>
              OpeningsCompanion.insert(
            id: id,
            spaceId: spaceId,
            kind: kind,
            wall: wall,
            offset: offset,
            length: length,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$OpeningsTable, OpeningRow>(table),
                    $$OpeningsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({spaceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (spaceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.spaceId,
                    referencedTable:
                        $$OpeningsTableReferences._spaceIdTable(db),
                    referencedColumn:
                        $$OpeningsTableReferences._spaceIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$OpeningsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OpeningsTable,
    OpeningRow,
    $$OpeningsTableFilterComposer,
    $$OpeningsTableOrderingComposer,
    $$OpeningsTableAnnotationComposer,
    $$OpeningsTableCreateCompanionBuilder,
    $$OpeningsTableUpdateCompanionBuilder,
    (OpeningRow, $$OpeningsTableReferences),
    OpeningRow,
    PrefetchHooks Function({bool spaceId})>;
typedef $$LightReadingsTableCreateCompanionBuilder = LightReadingsCompanion
    Function({
  required String id,
  required String spaceId,
  required double x,
  required double y,
  required DayMoment moment,
  required double estimatedLux,
  required DateTime takenAt,
  Value<int> rowid,
});
typedef $$LightReadingsTableUpdateCompanionBuilder = LightReadingsCompanion
    Function({
  Value<String> id,
  Value<String> spaceId,
  Value<double> x,
  Value<double> y,
  Value<DayMoment> moment,
  Value<double> estimatedLux,
  Value<DateTime> takenAt,
  Value<int> rowid,
});

final class $$LightReadingsTableReferences extends BaseReferences<_$AppDatabase,
    $LightReadingsTable, LightReadingRow> {
  $$LightReadingsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $SpacesTable _spaceIdTable(_$AppDatabase db) =>
      db.spaces.createAlias('light_readings__space_id__spaces__id');

  $$SpacesTableProcessedTableManager get spaceId {
    final $_column = $_itemColumn<String>('space_id')!;

    final manager = $$SpacesTableTableManager($_db, $_db.spaces)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_spaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$LightReadingsTableFilterComposer
    extends Composer<_$AppDatabase, $LightReadingsTable> {
  $$LightReadingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get x => $composableBuilder(
      column: $table.x, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get y => $composableBuilder(
      column: $table.y, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DayMoment, DayMoment, String> get moment =>
      $composableBuilder(
          column: $table.moment,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<double> get estimatedLux => $composableBuilder(
      column: $table.estimatedLux, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get takenAt => $composableBuilder(
      column: $table.takenAt, builder: (column) => ColumnFilters(column));

  $$SpacesTableFilterComposer get spaceId {
    final $$SpacesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.spaceId,
        referencedTable: $db.spaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SpacesTableFilterComposer(
              $db: $db,
              $table: $db.spaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LightReadingsTableOrderingComposer
    extends Composer<_$AppDatabase, $LightReadingsTable> {
  $$LightReadingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get x => $composableBuilder(
      column: $table.x, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get y => $composableBuilder(
      column: $table.y, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get moment => $composableBuilder(
      column: $table.moment, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get estimatedLux => $composableBuilder(
      column: $table.estimatedLux,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get takenAt => $composableBuilder(
      column: $table.takenAt, builder: (column) => ColumnOrderings(column));

  $$SpacesTableOrderingComposer get spaceId {
    final $$SpacesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.spaceId,
        referencedTable: $db.spaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SpacesTableOrderingComposer(
              $db: $db,
              $table: $db.spaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LightReadingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LightReadingsTable> {
  $$LightReadingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get x =>
      $composableBuilder(column: $table.x, builder: (column) => column);

  GeneratedColumn<double> get y =>
      $composableBuilder(column: $table.y, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DayMoment, String> get moment =>
      $composableBuilder(column: $table.moment, builder: (column) => column);

  GeneratedColumn<double> get estimatedLux => $composableBuilder(
      column: $table.estimatedLux, builder: (column) => column);

  GeneratedColumn<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  $$SpacesTableAnnotationComposer get spaceId {
    final $$SpacesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.spaceId,
        referencedTable: $db.spaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SpacesTableAnnotationComposer(
              $db: $db,
              $table: $db.spaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LightReadingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LightReadingsTable,
    LightReadingRow,
    $$LightReadingsTableFilterComposer,
    $$LightReadingsTableOrderingComposer,
    $$LightReadingsTableAnnotationComposer,
    $$LightReadingsTableCreateCompanionBuilder,
    $$LightReadingsTableUpdateCompanionBuilder,
    (LightReadingRow, $$LightReadingsTableReferences),
    LightReadingRow,
    PrefetchHooks Function({bool spaceId})> {
  $$LightReadingsTableTableManager(_$AppDatabase db, $LightReadingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LightReadingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LightReadingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LightReadingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> spaceId = const Value.absent(),
            Value<double> x = const Value.absent(),
            Value<double> y = const Value.absent(),
            Value<DayMoment> moment = const Value.absent(),
            Value<double> estimatedLux = const Value.absent(),
            Value<DateTime> takenAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LightReadingsCompanion(
            id: id,
            spaceId: spaceId,
            x: x,
            y: y,
            moment: moment,
            estimatedLux: estimatedLux,
            takenAt: takenAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String spaceId,
            required double x,
            required double y,
            required DayMoment moment,
            required double estimatedLux,
            required DateTime takenAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              LightReadingsCompanion.insert(
            id: id,
            spaceId: spaceId,
            x: x,
            y: y,
            moment: moment,
            estimatedLux: estimatedLux,
            takenAt: takenAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$LightReadingsTable, LightReadingRow>(table),
                    $$LightReadingsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({spaceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (spaceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.spaceId,
                    referencedTable:
                        $$LightReadingsTableReferences._spaceIdTable(db),
                    referencedColumn:
                        $$LightReadingsTableReferences._spaceIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$LightReadingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LightReadingsTable,
    LightReadingRow,
    $$LightReadingsTableFilterComposer,
    $$LightReadingsTableOrderingComposer,
    $$LightReadingsTableAnnotationComposer,
    $$LightReadingsTableCreateCompanionBuilder,
    $$LightReadingsTableUpdateCompanionBuilder,
    (LightReadingRow, $$LightReadingsTableReferences),
    LightReadingRow,
    PrefetchHooks Function({bool spaceId})>;
typedef $$PlantSpeciesTableTableCreateCompanionBuilder
    = PlantSpeciesTableCompanion Function({
  required String id,
  required String scientificName,
  required String commonName,
  Value<String?> imageUrl,
  required List<LightLevel> light,
  required double minTempC,
  required double maxTempC,
  required String soil,
  required CareSchedule watering,
  required CareSchedule fertilizing,
  required List<Diagnostic> diagnostics,
  Value<PropagationInfo?> cutting,
  Value<RepottingInfo?> repotting,
  Value<List<int>> sowingMonths,
  Value<int?> rowSpacingCm,
  Value<int?> plantSpacingCm,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$PlantSpeciesTableTableUpdateCompanionBuilder
    = PlantSpeciesTableCompanion Function({
  Value<String> id,
  Value<String> scientificName,
  Value<String> commonName,
  Value<String?> imageUrl,
  Value<List<LightLevel>> light,
  Value<double> minTempC,
  Value<double> maxTempC,
  Value<String> soil,
  Value<CareSchedule> watering,
  Value<CareSchedule> fertilizing,
  Value<List<Diagnostic>> diagnostics,
  Value<PropagationInfo?> cutting,
  Value<RepottingInfo?> repotting,
  Value<List<int>> sowingMonths,
  Value<int?> rowSpacingCm,
  Value<int?> plantSpacingCm,
  Value<String?> notes,
  Value<int> rowid,
});

final class $$PlantSpeciesTableTableReferences extends BaseReferences<
    _$AppDatabase, $PlantSpeciesTableTable, PlantSpeciesRow> {
  $$PlantSpeciesTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$OwnedPlantsTable, List<OwnedPlantRow>>
      _ownedPlantsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.ownedPlants,
              aliasName: 'plant_species__id__owned_plants__species_id');

  $$OwnedPlantsTableProcessedTableManager get ownedPlantsRefs {
    final manager = $$OwnedPlantsTableTableManager($_db, $_db.ownedPlants)
        .filter((f) => f.speciesId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_ownedPlantsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PlantSpeciesTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlantSpeciesTableTable> {
  $$PlantSpeciesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scientificName => $composableBuilder(
      column: $table.scientificName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get commonName => $composableBuilder(
      column: $table.commonName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<LightLevel>, List<LightLevel>, String>
      get light => $composableBuilder(
          column: $table.light,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<double> get minTempC => $composableBuilder(
      column: $table.minTempC, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get maxTempC => $composableBuilder(
      column: $table.maxTempC, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get soil => $composableBuilder(
      column: $table.soil, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<CareSchedule, CareSchedule, String>
      get watering => $composableBuilder(
          column: $table.watering,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<CareSchedule, CareSchedule, String>
      get fertilizing => $composableBuilder(
          column: $table.fertilizing,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<List<Diagnostic>, List<Diagnostic>, String>
      get diagnostics => $composableBuilder(
          column: $table.diagnostics,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<PropagationInfo?, PropagationInfo, String>
      get cutting => $composableBuilder(
          column: $table.cutting,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<RepottingInfo?, RepottingInfo, String>
      get repotting => $composableBuilder(
          column: $table.repotting,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<List<int>, List<int>, String>
      get sowingMonths => $composableBuilder(
          column: $table.sowingMonths,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get rowSpacingCm => $composableBuilder(
      column: $table.rowSpacingCm, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get plantSpacingCm => $composableBuilder(
      column: $table.plantSpacingCm,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  Expression<bool> ownedPlantsRefs(
      Expression<bool> Function($$OwnedPlantsTableFilterComposer f) f) {
    final $$OwnedPlantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.ownedPlants,
        getReferencedColumn: (t) => t.speciesId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OwnedPlantsTableFilterComposer(
              $db: $db,
              $table: $db.ownedPlants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PlantSpeciesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlantSpeciesTableTable> {
  $$PlantSpeciesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scientificName => $composableBuilder(
      column: $table.scientificName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get commonName => $composableBuilder(
      column: $table.commonName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get light => $composableBuilder(
      column: $table.light, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get minTempC => $composableBuilder(
      column: $table.minTempC, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get maxTempC => $composableBuilder(
      column: $table.maxTempC, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get soil => $composableBuilder(
      column: $table.soil, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get watering => $composableBuilder(
      column: $table.watering, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fertilizing => $composableBuilder(
      column: $table.fertilizing, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get diagnostics => $composableBuilder(
      column: $table.diagnostics, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cutting => $composableBuilder(
      column: $table.cutting, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get repotting => $composableBuilder(
      column: $table.repotting, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sowingMonths => $composableBuilder(
      column: $table.sowingMonths,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rowSpacingCm => $composableBuilder(
      column: $table.rowSpacingCm,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get plantSpacingCm => $composableBuilder(
      column: $table.plantSpacingCm,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$PlantSpeciesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlantSpeciesTableTable> {
  $$PlantSpeciesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scientificName => $composableBuilder(
      column: $table.scientificName, builder: (column) => column);

  GeneratedColumn<String> get commonName => $composableBuilder(
      column: $table.commonName, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<LightLevel>, String> get light =>
      $composableBuilder(column: $table.light, builder: (column) => column);

  GeneratedColumn<double> get minTempC =>
      $composableBuilder(column: $table.minTempC, builder: (column) => column);

  GeneratedColumn<double> get maxTempC =>
      $composableBuilder(column: $table.maxTempC, builder: (column) => column);

  GeneratedColumn<String> get soil =>
      $composableBuilder(column: $table.soil, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CareSchedule, String> get watering =>
      $composableBuilder(column: $table.watering, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CareSchedule, String> get fertilizing =>
      $composableBuilder(
          column: $table.fertilizing, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<Diagnostic>, String> get diagnostics =>
      $composableBuilder(
          column: $table.diagnostics, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PropagationInfo?, String> get cutting =>
      $composableBuilder(column: $table.cutting, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RepottingInfo?, String> get repotting =>
      $composableBuilder(column: $table.repotting, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<int>, String> get sowingMonths =>
      $composableBuilder(
          column: $table.sowingMonths, builder: (column) => column);

  GeneratedColumn<int> get rowSpacingCm => $composableBuilder(
      column: $table.rowSpacingCm, builder: (column) => column);

  GeneratedColumn<int> get plantSpacingCm => $composableBuilder(
      column: $table.plantSpacingCm, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> ownedPlantsRefs<T extends Object>(
      Expression<T> Function($$OwnedPlantsTableAnnotationComposer a) f) {
    final $$OwnedPlantsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.ownedPlants,
        getReferencedColumn: (t) => t.speciesId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OwnedPlantsTableAnnotationComposer(
              $db: $db,
              $table: $db.ownedPlants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PlantSpeciesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlantSpeciesTableTable,
    PlantSpeciesRow,
    $$PlantSpeciesTableTableFilterComposer,
    $$PlantSpeciesTableTableOrderingComposer,
    $$PlantSpeciesTableTableAnnotationComposer,
    $$PlantSpeciesTableTableCreateCompanionBuilder,
    $$PlantSpeciesTableTableUpdateCompanionBuilder,
    (PlantSpeciesRow, $$PlantSpeciesTableTableReferences),
    PlantSpeciesRow,
    PrefetchHooks Function({bool ownedPlantsRefs})> {
  $$PlantSpeciesTableTableTableManager(
      _$AppDatabase db, $PlantSpeciesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlantSpeciesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlantSpeciesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlantSpeciesTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> scientificName = const Value.absent(),
            Value<String> commonName = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<List<LightLevel>> light = const Value.absent(),
            Value<double> minTempC = const Value.absent(),
            Value<double> maxTempC = const Value.absent(),
            Value<String> soil = const Value.absent(),
            Value<CareSchedule> watering = const Value.absent(),
            Value<CareSchedule> fertilizing = const Value.absent(),
            Value<List<Diagnostic>> diagnostics = const Value.absent(),
            Value<PropagationInfo?> cutting = const Value.absent(),
            Value<RepottingInfo?> repotting = const Value.absent(),
            Value<List<int>> sowingMonths = const Value.absent(),
            Value<int?> rowSpacingCm = const Value.absent(),
            Value<int?> plantSpacingCm = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlantSpeciesTableCompanion(
            id: id,
            scientificName: scientificName,
            commonName: commonName,
            imageUrl: imageUrl,
            light: light,
            minTempC: minTempC,
            maxTempC: maxTempC,
            soil: soil,
            watering: watering,
            fertilizing: fertilizing,
            diagnostics: diagnostics,
            cutting: cutting,
            repotting: repotting,
            sowingMonths: sowingMonths,
            rowSpacingCm: rowSpacingCm,
            plantSpacingCm: plantSpacingCm,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String scientificName,
            required String commonName,
            Value<String?> imageUrl = const Value.absent(),
            required List<LightLevel> light,
            required double minTempC,
            required double maxTempC,
            required String soil,
            required CareSchedule watering,
            required CareSchedule fertilizing,
            required List<Diagnostic> diagnostics,
            Value<PropagationInfo?> cutting = const Value.absent(),
            Value<RepottingInfo?> repotting = const Value.absent(),
            Value<List<int>> sowingMonths = const Value.absent(),
            Value<int?> rowSpacingCm = const Value.absent(),
            Value<int?> plantSpacingCm = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlantSpeciesTableCompanion.insert(
            id: id,
            scientificName: scientificName,
            commonName: commonName,
            imageUrl: imageUrl,
            light: light,
            minTempC: minTempC,
            maxTempC: maxTempC,
            soil: soil,
            watering: watering,
            fertilizing: fertilizing,
            diagnostics: diagnostics,
            cutting: cutting,
            repotting: repotting,
            sowingMonths: sowingMonths,
            rowSpacingCm: rowSpacingCm,
            plantSpacingCm: plantSpacingCm,
            notes: notes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$PlantSpeciesTableTable, PlantSpeciesRow>(
                        table),
                    $$PlantSpeciesTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({ownedPlantsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (ownedPlantsRefs) db.ownedPlants],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (ownedPlantsRefs)
                    await $_getPrefetchedData<PlantSpeciesRow,
                            $PlantSpeciesTableTable, OwnedPlantRow>(
                        currentTable: table,
                        referencedTable: $$PlantSpeciesTableTableReferences
                            ._ownedPlantsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PlantSpeciesTableTableReferences(db, table, p0)
                                .ownedPlantsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.speciesId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PlantSpeciesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlantSpeciesTableTable,
    PlantSpeciesRow,
    $$PlantSpeciesTableTableFilterComposer,
    $$PlantSpeciesTableTableOrderingComposer,
    $$PlantSpeciesTableTableAnnotationComposer,
    $$PlantSpeciesTableTableCreateCompanionBuilder,
    $$PlantSpeciesTableTableUpdateCompanionBuilder,
    (PlantSpeciesRow, $$PlantSpeciesTableTableReferences),
    PlantSpeciesRow,
    PrefetchHooks Function({bool ownedPlantsRefs})>;
typedef $$OwnedPlantsTableCreateCompanionBuilder = OwnedPlantsCompanion
    Function({
  required String id,
  required String speciesId,
  required String nickname,
  Value<String?> spaceId,
  Value<double?> x,
  Value<double?> y,
  Value<int> rowid,
});
typedef $$OwnedPlantsTableUpdateCompanionBuilder = OwnedPlantsCompanion
    Function({
  Value<String> id,
  Value<String> speciesId,
  Value<String> nickname,
  Value<String?> spaceId,
  Value<double?> x,
  Value<double?> y,
  Value<int> rowid,
});

final class $$OwnedPlantsTableReferences
    extends BaseReferences<_$AppDatabase, $OwnedPlantsTable, OwnedPlantRow> {
  $$OwnedPlantsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlantSpeciesTableTable _speciesIdTable(_$AppDatabase db) =>
      db.plantSpeciesTable
          .createAlias('owned_plants__species_id__plant_species__id');

  $$PlantSpeciesTableTableProcessedTableManager get speciesId {
    final $_column = $_itemColumn<String>('species_id')!;

    final manager =
        $$PlantSpeciesTableTableTableManager($_db, $_db.plantSpeciesTable)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_speciesIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $SpacesTable _spaceIdTable(_$AppDatabase db) =>
      db.spaces.createAlias('owned_plants__space_id__spaces__id');

  $$SpacesTableProcessedTableManager? get spaceId {
    final $_column = $_itemColumn<String>('space_id');
    if ($_column == null) return null;
    final manager = $$SpacesTableTableManager($_db, $_db.spaces)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_spaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$CareTasksTable, List<CareTaskRow>>
      _careTasksRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.careTasks,
              aliasName: 'owned_plants__id__care_tasks__plant_id');

  $$CareTasksTableProcessedTableManager get careTasksRefs {
    final manager = $$CareTasksTableTableManager($_db, $_db.careTasks)
        .filter((f) => f.plantId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_careTasksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$OwnedPlantsTableFilterComposer
    extends Composer<_$AppDatabase, $OwnedPlantsTable> {
  $$OwnedPlantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nickname => $composableBuilder(
      column: $table.nickname, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get x => $composableBuilder(
      column: $table.x, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get y => $composableBuilder(
      column: $table.y, builder: (column) => ColumnFilters(column));

  $$PlantSpeciesTableTableFilterComposer get speciesId {
    final $$PlantSpeciesTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.speciesId,
        referencedTable: $db.plantSpeciesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlantSpeciesTableTableFilterComposer(
              $db: $db,
              $table: $db.plantSpeciesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SpacesTableFilterComposer get spaceId {
    final $$SpacesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.spaceId,
        referencedTable: $db.spaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SpacesTableFilterComposer(
              $db: $db,
              $table: $db.spaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> careTasksRefs(
      Expression<bool> Function($$CareTasksTableFilterComposer f) f) {
    final $$CareTasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.careTasks,
        getReferencedColumn: (t) => t.plantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CareTasksTableFilterComposer(
              $db: $db,
              $table: $db.careTasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$OwnedPlantsTableOrderingComposer
    extends Composer<_$AppDatabase, $OwnedPlantsTable> {
  $$OwnedPlantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nickname => $composableBuilder(
      column: $table.nickname, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get x => $composableBuilder(
      column: $table.x, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get y => $composableBuilder(
      column: $table.y, builder: (column) => ColumnOrderings(column));

  $$PlantSpeciesTableTableOrderingComposer get speciesId {
    final $$PlantSpeciesTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.speciesId,
        referencedTable: $db.plantSpeciesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlantSpeciesTableTableOrderingComposer(
              $db: $db,
              $table: $db.plantSpeciesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SpacesTableOrderingComposer get spaceId {
    final $$SpacesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.spaceId,
        referencedTable: $db.spaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SpacesTableOrderingComposer(
              $db: $db,
              $table: $db.spaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$OwnedPlantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OwnedPlantsTable> {
  $$OwnedPlantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<double> get x =>
      $composableBuilder(column: $table.x, builder: (column) => column);

  GeneratedColumn<double> get y =>
      $composableBuilder(column: $table.y, builder: (column) => column);

  $$PlantSpeciesTableTableAnnotationComposer get speciesId {
    final $$PlantSpeciesTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.speciesId,
            referencedTable: $db.plantSpeciesTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PlantSpeciesTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.plantSpeciesTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$SpacesTableAnnotationComposer get spaceId {
    final $$SpacesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.spaceId,
        referencedTable: $db.spaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SpacesTableAnnotationComposer(
              $db: $db,
              $table: $db.spaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> careTasksRefs<T extends Object>(
      Expression<T> Function($$CareTasksTableAnnotationComposer a) f) {
    final $$CareTasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.careTasks,
        getReferencedColumn: (t) => t.plantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CareTasksTableAnnotationComposer(
              $db: $db,
              $table: $db.careTasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$OwnedPlantsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OwnedPlantsTable,
    OwnedPlantRow,
    $$OwnedPlantsTableFilterComposer,
    $$OwnedPlantsTableOrderingComposer,
    $$OwnedPlantsTableAnnotationComposer,
    $$OwnedPlantsTableCreateCompanionBuilder,
    $$OwnedPlantsTableUpdateCompanionBuilder,
    (OwnedPlantRow, $$OwnedPlantsTableReferences),
    OwnedPlantRow,
    PrefetchHooks Function(
        {bool speciesId, bool spaceId, bool careTasksRefs})> {
  $$OwnedPlantsTableTableManager(_$AppDatabase db, $OwnedPlantsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OwnedPlantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OwnedPlantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OwnedPlantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> speciesId = const Value.absent(),
            Value<String> nickname = const Value.absent(),
            Value<String?> spaceId = const Value.absent(),
            Value<double?> x = const Value.absent(),
            Value<double?> y = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OwnedPlantsCompanion(
            id: id,
            speciesId: speciesId,
            nickname: nickname,
            spaceId: spaceId,
            x: x,
            y: y,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String speciesId,
            required String nickname,
            Value<String?> spaceId = const Value.absent(),
            Value<double?> x = const Value.absent(),
            Value<double?> y = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OwnedPlantsCompanion.insert(
            id: id,
            speciesId: speciesId,
            nickname: nickname,
            spaceId: spaceId,
            x: x,
            y: y,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$OwnedPlantsTable, OwnedPlantRow>(table),
                    $$OwnedPlantsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {speciesId = false, spaceId = false, careTasksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (careTasksRefs) db.careTasks],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (speciesId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.speciesId,
                    referencedTable:
                        $$OwnedPlantsTableReferences._speciesIdTable(db),
                    referencedColumn:
                        $$OwnedPlantsTableReferences._speciesIdTable(db).id,
                  ) as T;
                }
                if (spaceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.spaceId,
                    referencedTable:
                        $$OwnedPlantsTableReferences._spaceIdTable(db),
                    referencedColumn:
                        $$OwnedPlantsTableReferences._spaceIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (careTasksRefs)
                    await $_getPrefetchedData<OwnedPlantRow, $OwnedPlantsTable,
                            CareTaskRow>(
                        currentTable: table,
                        referencedTable: $$OwnedPlantsTableReferences
                            ._careTasksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$OwnedPlantsTableReferences(db, table, p0)
                                .careTasksRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.plantId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$OwnedPlantsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OwnedPlantsTable,
    OwnedPlantRow,
    $$OwnedPlantsTableFilterComposer,
    $$OwnedPlantsTableOrderingComposer,
    $$OwnedPlantsTableAnnotationComposer,
    $$OwnedPlantsTableCreateCompanionBuilder,
    $$OwnedPlantsTableUpdateCompanionBuilder,
    (OwnedPlantRow, $$OwnedPlantsTableReferences),
    OwnedPlantRow,
    PrefetchHooks Function({bool speciesId, bool spaceId, bool careTasksRefs})>;
typedef $$CareTasksTableCreateCompanionBuilder = CareTasksCompanion Function({
  required String id,
  required String plantId,
  required CareType type,
  required DateTime dueAt,
  Value<DateTime?> doneAt,
  Value<int> rowid,
});
typedef $$CareTasksTableUpdateCompanionBuilder = CareTasksCompanion Function({
  Value<String> id,
  Value<String> plantId,
  Value<CareType> type,
  Value<DateTime> dueAt,
  Value<DateTime?> doneAt,
  Value<int> rowid,
});

final class $$CareTasksTableReferences
    extends BaseReferences<_$AppDatabase, $CareTasksTable, CareTaskRow> {
  $$CareTasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OwnedPlantsTable _plantIdTable(_$AppDatabase db) =>
      db.ownedPlants.createAlias('care_tasks__plant_id__owned_plants__id');

  $$OwnedPlantsTableProcessedTableManager get plantId {
    final $_column = $_itemColumn<String>('plant_id')!;

    final manager = $$OwnedPlantsTableTableManager($_db, $_db.ownedPlants)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_plantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CareTasksTableFilterComposer
    extends Composer<_$AppDatabase, $CareTasksTable> {
  $$CareTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<CareType, CareType, String> get type =>
      $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
      column: $table.dueAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get doneAt => $composableBuilder(
      column: $table.doneAt, builder: (column) => ColumnFilters(column));

  $$OwnedPlantsTableFilterComposer get plantId {
    final $$OwnedPlantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.plantId,
        referencedTable: $db.ownedPlants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OwnedPlantsTableFilterComposer(
              $db: $db,
              $table: $db.ownedPlants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CareTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $CareTasksTable> {
  $$CareTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
      column: $table.dueAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get doneAt => $composableBuilder(
      column: $table.doneAt, builder: (column) => ColumnOrderings(column));

  $$OwnedPlantsTableOrderingComposer get plantId {
    final $$OwnedPlantsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.plantId,
        referencedTable: $db.ownedPlants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OwnedPlantsTableOrderingComposer(
              $db: $db,
              $table: $db.ownedPlants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CareTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $CareTasksTable> {
  $$CareTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CareType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<DateTime> get doneAt =>
      $composableBuilder(column: $table.doneAt, builder: (column) => column);

  $$OwnedPlantsTableAnnotationComposer get plantId {
    final $$OwnedPlantsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.plantId,
        referencedTable: $db.ownedPlants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OwnedPlantsTableAnnotationComposer(
              $db: $db,
              $table: $db.ownedPlants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CareTasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CareTasksTable,
    CareTaskRow,
    $$CareTasksTableFilterComposer,
    $$CareTasksTableOrderingComposer,
    $$CareTasksTableAnnotationComposer,
    $$CareTasksTableCreateCompanionBuilder,
    $$CareTasksTableUpdateCompanionBuilder,
    (CareTaskRow, $$CareTasksTableReferences),
    CareTaskRow,
    PrefetchHooks Function({bool plantId})> {
  $$CareTasksTableTableManager(_$AppDatabase db, $CareTasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CareTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CareTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CareTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> plantId = const Value.absent(),
            Value<CareType> type = const Value.absent(),
            Value<DateTime> dueAt = const Value.absent(),
            Value<DateTime?> doneAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CareTasksCompanion(
            id: id,
            plantId: plantId,
            type: type,
            dueAt: dueAt,
            doneAt: doneAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String plantId,
            required CareType type,
            required DateTime dueAt,
            Value<DateTime?> doneAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CareTasksCompanion.insert(
            id: id,
            plantId: plantId,
            type: type,
            dueAt: dueAt,
            doneAt: doneAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CareTasksTable, CareTaskRow>(table),
                    $$CareTasksTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({plantId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (plantId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.plantId,
                    referencedTable:
                        $$CareTasksTableReferences._plantIdTable(db),
                    referencedColumn:
                        $$CareTasksTableReferences._plantIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$CareTasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CareTasksTable,
    CareTaskRow,
    $$CareTasksTableFilterComposer,
    $$CareTasksTableOrderingComposer,
    $$CareTasksTableAnnotationComposer,
    $$CareTasksTableCreateCompanionBuilder,
    $$CareTasksTableUpdateCompanionBuilder,
    (CareTaskRow, $$CareTasksTableReferences),
    CareTaskRow,
    PrefetchHooks Function({bool plantId})>;
typedef $$ApiCacheEntriesTableCreateCompanionBuilder = ApiCacheEntriesCompanion
    Function({
  required String key,
  required String body,
  required DateTime fetchedAt,
  Value<int> rowid,
});
typedef $$ApiCacheEntriesTableUpdateCompanionBuilder = ApiCacheEntriesCompanion
    Function({
  Value<String> key,
  Value<String> body,
  Value<DateTime> fetchedAt,
  Value<int> rowid,
});

class $$ApiCacheEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ApiCacheEntriesTable> {
  $$ApiCacheEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
      column: $table.fetchedAt, builder: (column) => ColumnFilters(column));
}

class $$ApiCacheEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ApiCacheEntriesTable> {
  $$ApiCacheEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
      column: $table.fetchedAt, builder: (column) => ColumnOrderings(column));
}

class $$ApiCacheEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ApiCacheEntriesTable> {
  $$ApiCacheEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$ApiCacheEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ApiCacheEntriesTable,
    ApiCacheRow,
    $$ApiCacheEntriesTableFilterComposer,
    $$ApiCacheEntriesTableOrderingComposer,
    $$ApiCacheEntriesTableAnnotationComposer,
    $$ApiCacheEntriesTableCreateCompanionBuilder,
    $$ApiCacheEntriesTableUpdateCompanionBuilder,
    (
      ApiCacheRow,
      BaseReferences<_$AppDatabase, $ApiCacheEntriesTable, ApiCacheRow>
    ),
    ApiCacheRow,
    PrefetchHooks Function()> {
  $$ApiCacheEntriesTableTableManager(
      _$AppDatabase db, $ApiCacheEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ApiCacheEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ApiCacheEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ApiCacheEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> body = const Value.absent(),
            Value<DateTime> fetchedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ApiCacheEntriesCompanion(
            key: key,
            body: body,
            fetchedAt: fetchedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String body,
            required DateTime fetchedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ApiCacheEntriesCompanion.insert(
            key: key,
            body: body,
            fetchedAt: fetchedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ApiCacheEntriesTable, ApiCacheRow>(table),
                    BaseReferences<_$AppDatabase, $ApiCacheEntriesTable,
                        ApiCacheRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ApiCacheEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ApiCacheEntriesTable,
    ApiCacheRow,
    $$ApiCacheEntriesTableFilterComposer,
    $$ApiCacheEntriesTableOrderingComposer,
    $$ApiCacheEntriesTableAnnotationComposer,
    $$ApiCacheEntriesTableCreateCompanionBuilder,
    $$ApiCacheEntriesTableUpdateCompanionBuilder,
    (
      ApiCacheRow,
      BaseReferences<_$AppDatabase, $ApiCacheEntriesTable, ApiCacheRow>
    ),
    ApiCacheRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SpacesTableTableManager get spaces =>
      $$SpacesTableTableManager(_db, _db.spaces);
  $$OpeningsTableTableManager get openings =>
      $$OpeningsTableTableManager(_db, _db.openings);
  $$LightReadingsTableTableManager get lightReadings =>
      $$LightReadingsTableTableManager(_db, _db.lightReadings);
  $$PlantSpeciesTableTableTableManager get plantSpeciesTable =>
      $$PlantSpeciesTableTableTableManager(_db, _db.plantSpeciesTable);
  $$OwnedPlantsTableTableManager get ownedPlants =>
      $$OwnedPlantsTableTableManager(_db, _db.ownedPlants);
  $$CareTasksTableTableManager get careTasks =>
      $$CareTasksTableTableManager(_db, _db.careTasks);
  $$ApiCacheEntriesTableTableManager get apiCacheEntries =>
      $$ApiCacheEntriesTableTableManager(_db, _db.apiCacheEntries);
}
