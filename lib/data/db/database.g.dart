// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $FoodsTable extends Foods with TableInfo<$FoodsTable, Food> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<FoodSource, int> source =
      GeneratedColumn<int>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<FoodSource>($FoodsTable.$convertersource);
  static const VerificationMeta _externalIdMeta = const VerificationMeta(
    'externalId',
  );
  @override
  late final GeneratedColumn<String> externalId = GeneratedColumn<String>(
    'external_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 400,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _servingGMeta = const VerificationMeta(
    'servingG',
  );
  @override
  late final GeneratedColumn<double> servingG = GeneratedColumn<double>(
    'serving_g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _servingLabelMeta = const VerificationMeta(
    'servingLabel',
  );
  @override
  late final GeneratedColumn<String> servingLabel = GeneratedColumn<String>(
    'serving_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kcal100Meta = const VerificationMeta(
    'kcal100',
  );
  @override
  late final GeneratedColumn<double> kcal100 = GeneratedColumn<double>(
    'kcal100',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _protein100Meta = const VerificationMeta(
    'protein100',
  );
  @override
  late final GeneratedColumn<double> protein100 = GeneratedColumn<double>(
    'protein100',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _carb100Meta = const VerificationMeta(
    'carb100',
  );
  @override
  late final GeneratedColumn<double> carb100 = GeneratedColumn<double>(
    'carb100',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fat100Meta = const VerificationMeta('fat100');
  @override
  late final GeneratedColumn<double> fat100 = GeneratedColumn<double>(
    'fat100',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fiber100Meta = const VerificationMeta(
    'fiber100',
  );
  @override
  late final GeneratedColumn<double> fiber100 = GeneratedColumn<double>(
    'fiber100',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sugar100Meta = const VerificationMeta(
    'sugar100',
  );
  @override
  late final GeneratedColumn<double> sugar100 = GeneratedColumn<double>(
    'sugar100',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _satFat100Meta = const VerificationMeta(
    'satFat100',
  );
  @override
  late final GeneratedColumn<double> satFat100 = GeneratedColumn<double>(
    'sat_fat100',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sodiumMg100Meta = const VerificationMeta(
    'sodiumMg100',
  );
  @override
  late final GeneratedColumn<double> sodiumMg100 = GeneratedColumn<double>(
    'sodium_mg100',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _saltG100Meta = const VerificationMeta(
    'saltG100',
  );
  @override
  late final GeneratedColumn<double> saltG100 = GeneratedColumn<double>(
    'salt_g100',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _microsJsonMeta = const VerificationMeta(
    'microsJson',
  );
  @override
  late final GeneratedColumn<String> microsJson = GeneratedColumn<String>(
    'micros_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _usageCountMeta = const VerificationMeta(
    'usageCount',
  );
  @override
  late final GeneratedColumn<int> usageCount = GeneratedColumn<int>(
    'usage_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    source,
    externalId,
    barcode,
    name,
    brand,
    locale,
    servingG,
    servingLabel,
    kcal100,
    protein100,
    carb100,
    fat100,
    fiber100,
    sugar100,
    satFat100,
    sodiumMg100,
    saltG100,
    microsJson,
    isFavorite,
    usageCount,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'foods';
  @override
  VerificationContext validateIntegrity(
    Insertable<Food> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('external_id')) {
      context.handle(
        _externalIdMeta,
        externalId.isAcceptableOrUnknown(data['external_id']!, _externalIdMeta),
      );
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
      );
    }
    if (data.containsKey('serving_g')) {
      context.handle(
        _servingGMeta,
        servingG.isAcceptableOrUnknown(data['serving_g']!, _servingGMeta),
      );
    }
    if (data.containsKey('serving_label')) {
      context.handle(
        _servingLabelMeta,
        servingLabel.isAcceptableOrUnknown(
          data['serving_label']!,
          _servingLabelMeta,
        ),
      );
    }
    if (data.containsKey('kcal100')) {
      context.handle(
        _kcal100Meta,
        kcal100.isAcceptableOrUnknown(data['kcal100']!, _kcal100Meta),
      );
    } else if (isInserting) {
      context.missing(_kcal100Meta);
    }
    if (data.containsKey('protein100')) {
      context.handle(
        _protein100Meta,
        protein100.isAcceptableOrUnknown(data['protein100']!, _protein100Meta),
      );
    }
    if (data.containsKey('carb100')) {
      context.handle(
        _carb100Meta,
        carb100.isAcceptableOrUnknown(data['carb100']!, _carb100Meta),
      );
    }
    if (data.containsKey('fat100')) {
      context.handle(
        _fat100Meta,
        fat100.isAcceptableOrUnknown(data['fat100']!, _fat100Meta),
      );
    }
    if (data.containsKey('fiber100')) {
      context.handle(
        _fiber100Meta,
        fiber100.isAcceptableOrUnknown(data['fiber100']!, _fiber100Meta),
      );
    }
    if (data.containsKey('sugar100')) {
      context.handle(
        _sugar100Meta,
        sugar100.isAcceptableOrUnknown(data['sugar100']!, _sugar100Meta),
      );
    }
    if (data.containsKey('sat_fat100')) {
      context.handle(
        _satFat100Meta,
        satFat100.isAcceptableOrUnknown(data['sat_fat100']!, _satFat100Meta),
      );
    }
    if (data.containsKey('sodium_mg100')) {
      context.handle(
        _sodiumMg100Meta,
        sodiumMg100.isAcceptableOrUnknown(
          data['sodium_mg100']!,
          _sodiumMg100Meta,
        ),
      );
    }
    if (data.containsKey('salt_g100')) {
      context.handle(
        _saltG100Meta,
        saltG100.isAcceptableOrUnknown(data['salt_g100']!, _saltG100Meta),
      );
    }
    if (data.containsKey('micros_json')) {
      context.handle(
        _microsJsonMeta,
        microsJson.isAcceptableOrUnknown(data['micros_json']!, _microsJsonMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('usage_count')) {
      context.handle(
        _usageCountMeta,
        usageCount.isAcceptableOrUnknown(data['usage_count']!, _usageCountMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {source, externalId},
  ];
  @override
  Food map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Food(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      source: $FoodsTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}source'],
        )!,
      ),
      externalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_id'],
      ),
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      ),
      servingG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}serving_g'],
      ),
      servingLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serving_label'],
      ),
      kcal100: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal100'],
      )!,
      protein100: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein100'],
      ),
      carb100: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carb100'],
      ),
      fat100: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat100'],
      ),
      fiber100: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fiber100'],
      ),
      sugar100: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sugar100'],
      ),
      satFat100: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sat_fat100'],
      ),
      sodiumMg100: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sodium_mg100'],
      ),
      saltG100: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}salt_g100'],
      ),
      microsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}micros_json'],
      ),
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      usageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}usage_count'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FoodsTable createAlias(String alias) {
    return $FoodsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<FoodSource, int, int> $convertersource =
      const EnumIndexConverter<FoodSource>(FoodSource.values);
}

class Food extends DataClass implements Insertable<Food> {
  final int id;
  final FoodSource source;

  /// Stable id within the source: barcode for OFF, fdcId for USDA, null for custom.
  final String? externalId;
  final String? barcode;
  final String name;
  final String? brand;
  final String? locale;

  /// Optional serving size for the "1 serving = N g" quick-pick chips.
  final double? servingG;
  final String? servingLabel;
  final double kcal100;
  final double? protein100;
  final double? carb100;
  final double? fat100;
  final double? fiber100;
  final double? sugar100;
  final double? satFat100;
  final double? sodiumMg100;
  final double? saltG100;

  /// Extra micronutrients as a JSON map (nutrient key -> per-100g amount).
  final String? microsJson;
  final bool isFavorite;
  final int usageCount;
  final DateTime updatedAt;
  const Food({
    required this.id,
    required this.source,
    this.externalId,
    this.barcode,
    required this.name,
    this.brand,
    this.locale,
    this.servingG,
    this.servingLabel,
    required this.kcal100,
    this.protein100,
    this.carb100,
    this.fat100,
    this.fiber100,
    this.sugar100,
    this.satFat100,
    this.sodiumMg100,
    this.saltG100,
    this.microsJson,
    required this.isFavorite,
    required this.usageCount,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['source'] = Variable<int>($FoodsTable.$convertersource.toSql(source));
    }
    if (!nullToAbsent || externalId != null) {
      map['external_id'] = Variable<String>(externalId);
    }
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    if (!nullToAbsent || locale != null) {
      map['locale'] = Variable<String>(locale);
    }
    if (!nullToAbsent || servingG != null) {
      map['serving_g'] = Variable<double>(servingG);
    }
    if (!nullToAbsent || servingLabel != null) {
      map['serving_label'] = Variable<String>(servingLabel);
    }
    map['kcal100'] = Variable<double>(kcal100);
    if (!nullToAbsent || protein100 != null) {
      map['protein100'] = Variable<double>(protein100);
    }
    if (!nullToAbsent || carb100 != null) {
      map['carb100'] = Variable<double>(carb100);
    }
    if (!nullToAbsent || fat100 != null) {
      map['fat100'] = Variable<double>(fat100);
    }
    if (!nullToAbsent || fiber100 != null) {
      map['fiber100'] = Variable<double>(fiber100);
    }
    if (!nullToAbsent || sugar100 != null) {
      map['sugar100'] = Variable<double>(sugar100);
    }
    if (!nullToAbsent || satFat100 != null) {
      map['sat_fat100'] = Variable<double>(satFat100);
    }
    if (!nullToAbsent || sodiumMg100 != null) {
      map['sodium_mg100'] = Variable<double>(sodiumMg100);
    }
    if (!nullToAbsent || saltG100 != null) {
      map['salt_g100'] = Variable<double>(saltG100);
    }
    if (!nullToAbsent || microsJson != null) {
      map['micros_json'] = Variable<String>(microsJson);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['usage_count'] = Variable<int>(usageCount);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FoodsCompanion toCompanion(bool nullToAbsent) {
    return FoodsCompanion(
      id: Value(id),
      source: Value(source),
      externalId: externalId == null && nullToAbsent
          ? const Value.absent()
          : Value(externalId),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      name: Value(name),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      locale: locale == null && nullToAbsent
          ? const Value.absent()
          : Value(locale),
      servingG: servingG == null && nullToAbsent
          ? const Value.absent()
          : Value(servingG),
      servingLabel: servingLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(servingLabel),
      kcal100: Value(kcal100),
      protein100: protein100 == null && nullToAbsent
          ? const Value.absent()
          : Value(protein100),
      carb100: carb100 == null && nullToAbsent
          ? const Value.absent()
          : Value(carb100),
      fat100: fat100 == null && nullToAbsent
          ? const Value.absent()
          : Value(fat100),
      fiber100: fiber100 == null && nullToAbsent
          ? const Value.absent()
          : Value(fiber100),
      sugar100: sugar100 == null && nullToAbsent
          ? const Value.absent()
          : Value(sugar100),
      satFat100: satFat100 == null && nullToAbsent
          ? const Value.absent()
          : Value(satFat100),
      sodiumMg100: sodiumMg100 == null && nullToAbsent
          ? const Value.absent()
          : Value(sodiumMg100),
      saltG100: saltG100 == null && nullToAbsent
          ? const Value.absent()
          : Value(saltG100),
      microsJson: microsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(microsJson),
      isFavorite: Value(isFavorite),
      usageCount: Value(usageCount),
      updatedAt: Value(updatedAt),
    );
  }

  factory Food.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Food(
      id: serializer.fromJson<int>(json['id']),
      source: $FoodsTable.$convertersource.fromJson(
        serializer.fromJson<int>(json['source']),
      ),
      externalId: serializer.fromJson<String?>(json['externalId']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String?>(json['brand']),
      locale: serializer.fromJson<String?>(json['locale']),
      servingG: serializer.fromJson<double?>(json['servingG']),
      servingLabel: serializer.fromJson<String?>(json['servingLabel']),
      kcal100: serializer.fromJson<double>(json['kcal100']),
      protein100: serializer.fromJson<double?>(json['protein100']),
      carb100: serializer.fromJson<double?>(json['carb100']),
      fat100: serializer.fromJson<double?>(json['fat100']),
      fiber100: serializer.fromJson<double?>(json['fiber100']),
      sugar100: serializer.fromJson<double?>(json['sugar100']),
      satFat100: serializer.fromJson<double?>(json['satFat100']),
      sodiumMg100: serializer.fromJson<double?>(json['sodiumMg100']),
      saltG100: serializer.fromJson<double?>(json['saltG100']),
      microsJson: serializer.fromJson<String?>(json['microsJson']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      usageCount: serializer.fromJson<int>(json['usageCount']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'source': serializer.toJson<int>(
        $FoodsTable.$convertersource.toJson(source),
      ),
      'externalId': serializer.toJson<String?>(externalId),
      'barcode': serializer.toJson<String?>(barcode),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String?>(brand),
      'locale': serializer.toJson<String?>(locale),
      'servingG': serializer.toJson<double?>(servingG),
      'servingLabel': serializer.toJson<String?>(servingLabel),
      'kcal100': serializer.toJson<double>(kcal100),
      'protein100': serializer.toJson<double?>(protein100),
      'carb100': serializer.toJson<double?>(carb100),
      'fat100': serializer.toJson<double?>(fat100),
      'fiber100': serializer.toJson<double?>(fiber100),
      'sugar100': serializer.toJson<double?>(sugar100),
      'satFat100': serializer.toJson<double?>(satFat100),
      'sodiumMg100': serializer.toJson<double?>(sodiumMg100),
      'saltG100': serializer.toJson<double?>(saltG100),
      'microsJson': serializer.toJson<String?>(microsJson),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'usageCount': serializer.toJson<int>(usageCount),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Food copyWith({
    int? id,
    FoodSource? source,
    Value<String?> externalId = const Value.absent(),
    Value<String?> barcode = const Value.absent(),
    String? name,
    Value<String?> brand = const Value.absent(),
    Value<String?> locale = const Value.absent(),
    Value<double?> servingG = const Value.absent(),
    Value<String?> servingLabel = const Value.absent(),
    double? kcal100,
    Value<double?> protein100 = const Value.absent(),
    Value<double?> carb100 = const Value.absent(),
    Value<double?> fat100 = const Value.absent(),
    Value<double?> fiber100 = const Value.absent(),
    Value<double?> sugar100 = const Value.absent(),
    Value<double?> satFat100 = const Value.absent(),
    Value<double?> sodiumMg100 = const Value.absent(),
    Value<double?> saltG100 = const Value.absent(),
    Value<String?> microsJson = const Value.absent(),
    bool? isFavorite,
    int? usageCount,
    DateTime? updatedAt,
  }) => Food(
    id: id ?? this.id,
    source: source ?? this.source,
    externalId: externalId.present ? externalId.value : this.externalId,
    barcode: barcode.present ? barcode.value : this.barcode,
    name: name ?? this.name,
    brand: brand.present ? brand.value : this.brand,
    locale: locale.present ? locale.value : this.locale,
    servingG: servingG.present ? servingG.value : this.servingG,
    servingLabel: servingLabel.present ? servingLabel.value : this.servingLabel,
    kcal100: kcal100 ?? this.kcal100,
    protein100: protein100.present ? protein100.value : this.protein100,
    carb100: carb100.present ? carb100.value : this.carb100,
    fat100: fat100.present ? fat100.value : this.fat100,
    fiber100: fiber100.present ? fiber100.value : this.fiber100,
    sugar100: sugar100.present ? sugar100.value : this.sugar100,
    satFat100: satFat100.present ? satFat100.value : this.satFat100,
    sodiumMg100: sodiumMg100.present ? sodiumMg100.value : this.sodiumMg100,
    saltG100: saltG100.present ? saltG100.value : this.saltG100,
    microsJson: microsJson.present ? microsJson.value : this.microsJson,
    isFavorite: isFavorite ?? this.isFavorite,
    usageCount: usageCount ?? this.usageCount,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Food copyWithCompanion(FoodsCompanion data) {
    return Food(
      id: data.id.present ? data.id.value : this.id,
      source: data.source.present ? data.source.value : this.source,
      externalId: data.externalId.present
          ? data.externalId.value
          : this.externalId,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      locale: data.locale.present ? data.locale.value : this.locale,
      servingG: data.servingG.present ? data.servingG.value : this.servingG,
      servingLabel: data.servingLabel.present
          ? data.servingLabel.value
          : this.servingLabel,
      kcal100: data.kcal100.present ? data.kcal100.value : this.kcal100,
      protein100: data.protein100.present
          ? data.protein100.value
          : this.protein100,
      carb100: data.carb100.present ? data.carb100.value : this.carb100,
      fat100: data.fat100.present ? data.fat100.value : this.fat100,
      fiber100: data.fiber100.present ? data.fiber100.value : this.fiber100,
      sugar100: data.sugar100.present ? data.sugar100.value : this.sugar100,
      satFat100: data.satFat100.present ? data.satFat100.value : this.satFat100,
      sodiumMg100: data.sodiumMg100.present
          ? data.sodiumMg100.value
          : this.sodiumMg100,
      saltG100: data.saltG100.present ? data.saltG100.value : this.saltG100,
      microsJson: data.microsJson.present
          ? data.microsJson.value
          : this.microsJson,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      usageCount: data.usageCount.present
          ? data.usageCount.value
          : this.usageCount,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Food(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('externalId: $externalId, ')
          ..write('barcode: $barcode, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('locale: $locale, ')
          ..write('servingG: $servingG, ')
          ..write('servingLabel: $servingLabel, ')
          ..write('kcal100: $kcal100, ')
          ..write('protein100: $protein100, ')
          ..write('carb100: $carb100, ')
          ..write('fat100: $fat100, ')
          ..write('fiber100: $fiber100, ')
          ..write('sugar100: $sugar100, ')
          ..write('satFat100: $satFat100, ')
          ..write('sodiumMg100: $sodiumMg100, ')
          ..write('saltG100: $saltG100, ')
          ..write('microsJson: $microsJson, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('usageCount: $usageCount, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    source,
    externalId,
    barcode,
    name,
    brand,
    locale,
    servingG,
    servingLabel,
    kcal100,
    protein100,
    carb100,
    fat100,
    fiber100,
    sugar100,
    satFat100,
    sodiumMg100,
    saltG100,
    microsJson,
    isFavorite,
    usageCount,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Food &&
          other.id == this.id &&
          other.source == this.source &&
          other.externalId == this.externalId &&
          other.barcode == this.barcode &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.locale == this.locale &&
          other.servingG == this.servingG &&
          other.servingLabel == this.servingLabel &&
          other.kcal100 == this.kcal100 &&
          other.protein100 == this.protein100 &&
          other.carb100 == this.carb100 &&
          other.fat100 == this.fat100 &&
          other.fiber100 == this.fiber100 &&
          other.sugar100 == this.sugar100 &&
          other.satFat100 == this.satFat100 &&
          other.sodiumMg100 == this.sodiumMg100 &&
          other.saltG100 == this.saltG100 &&
          other.microsJson == this.microsJson &&
          other.isFavorite == this.isFavorite &&
          other.usageCount == this.usageCount &&
          other.updatedAt == this.updatedAt);
}

class FoodsCompanion extends UpdateCompanion<Food> {
  final Value<int> id;
  final Value<FoodSource> source;
  final Value<String?> externalId;
  final Value<String?> barcode;
  final Value<String> name;
  final Value<String?> brand;
  final Value<String?> locale;
  final Value<double?> servingG;
  final Value<String?> servingLabel;
  final Value<double> kcal100;
  final Value<double?> protein100;
  final Value<double?> carb100;
  final Value<double?> fat100;
  final Value<double?> fiber100;
  final Value<double?> sugar100;
  final Value<double?> satFat100;
  final Value<double?> sodiumMg100;
  final Value<double?> saltG100;
  final Value<String?> microsJson;
  final Value<bool> isFavorite;
  final Value<int> usageCount;
  final Value<DateTime> updatedAt;
  const FoodsCompanion({
    this.id = const Value.absent(),
    this.source = const Value.absent(),
    this.externalId = const Value.absent(),
    this.barcode = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.locale = const Value.absent(),
    this.servingG = const Value.absent(),
    this.servingLabel = const Value.absent(),
    this.kcal100 = const Value.absent(),
    this.protein100 = const Value.absent(),
    this.carb100 = const Value.absent(),
    this.fat100 = const Value.absent(),
    this.fiber100 = const Value.absent(),
    this.sugar100 = const Value.absent(),
    this.satFat100 = const Value.absent(),
    this.sodiumMg100 = const Value.absent(),
    this.saltG100 = const Value.absent(),
    this.microsJson = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  FoodsCompanion.insert({
    this.id = const Value.absent(),
    required FoodSource source,
    this.externalId = const Value.absent(),
    this.barcode = const Value.absent(),
    required String name,
    this.brand = const Value.absent(),
    this.locale = const Value.absent(),
    this.servingG = const Value.absent(),
    this.servingLabel = const Value.absent(),
    required double kcal100,
    this.protein100 = const Value.absent(),
    this.carb100 = const Value.absent(),
    this.fat100 = const Value.absent(),
    this.fiber100 = const Value.absent(),
    this.sugar100 = const Value.absent(),
    this.satFat100 = const Value.absent(),
    this.sodiumMg100 = const Value.absent(),
    this.saltG100 = const Value.absent(),
    this.microsJson = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : source = Value(source),
       name = Value(name),
       kcal100 = Value(kcal100);
  static Insertable<Food> custom({
    Expression<int>? id,
    Expression<int>? source,
    Expression<String>? externalId,
    Expression<String>? barcode,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<String>? locale,
    Expression<double>? servingG,
    Expression<String>? servingLabel,
    Expression<double>? kcal100,
    Expression<double>? protein100,
    Expression<double>? carb100,
    Expression<double>? fat100,
    Expression<double>? fiber100,
    Expression<double>? sugar100,
    Expression<double>? satFat100,
    Expression<double>? sodiumMg100,
    Expression<double>? saltG100,
    Expression<String>? microsJson,
    Expression<bool>? isFavorite,
    Expression<int>? usageCount,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (source != null) 'source': source,
      if (externalId != null) 'external_id': externalId,
      if (barcode != null) 'barcode': barcode,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (locale != null) 'locale': locale,
      if (servingG != null) 'serving_g': servingG,
      if (servingLabel != null) 'serving_label': servingLabel,
      if (kcal100 != null) 'kcal100': kcal100,
      if (protein100 != null) 'protein100': protein100,
      if (carb100 != null) 'carb100': carb100,
      if (fat100 != null) 'fat100': fat100,
      if (fiber100 != null) 'fiber100': fiber100,
      if (sugar100 != null) 'sugar100': sugar100,
      if (satFat100 != null) 'sat_fat100': satFat100,
      if (sodiumMg100 != null) 'sodium_mg100': sodiumMg100,
      if (saltG100 != null) 'salt_g100': saltG100,
      if (microsJson != null) 'micros_json': microsJson,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (usageCount != null) 'usage_count': usageCount,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  FoodsCompanion copyWith({
    Value<int>? id,
    Value<FoodSource>? source,
    Value<String?>? externalId,
    Value<String?>? barcode,
    Value<String>? name,
    Value<String?>? brand,
    Value<String?>? locale,
    Value<double?>? servingG,
    Value<String?>? servingLabel,
    Value<double>? kcal100,
    Value<double?>? protein100,
    Value<double?>? carb100,
    Value<double?>? fat100,
    Value<double?>? fiber100,
    Value<double?>? sugar100,
    Value<double?>? satFat100,
    Value<double?>? sodiumMg100,
    Value<double?>? saltG100,
    Value<String?>? microsJson,
    Value<bool>? isFavorite,
    Value<int>? usageCount,
    Value<DateTime>? updatedAt,
  }) {
    return FoodsCompanion(
      id: id ?? this.id,
      source: source ?? this.source,
      externalId: externalId ?? this.externalId,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      locale: locale ?? this.locale,
      servingG: servingG ?? this.servingG,
      servingLabel: servingLabel ?? this.servingLabel,
      kcal100: kcal100 ?? this.kcal100,
      protein100: protein100 ?? this.protein100,
      carb100: carb100 ?? this.carb100,
      fat100: fat100 ?? this.fat100,
      fiber100: fiber100 ?? this.fiber100,
      sugar100: sugar100 ?? this.sugar100,
      satFat100: satFat100 ?? this.satFat100,
      sodiumMg100: sodiumMg100 ?? this.sodiumMg100,
      saltG100: saltG100 ?? this.saltG100,
      microsJson: microsJson ?? this.microsJson,
      isFavorite: isFavorite ?? this.isFavorite,
      usageCount: usageCount ?? this.usageCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (source.present) {
      map['source'] = Variable<int>(
        $FoodsTable.$convertersource.toSql(source.value),
      );
    }
    if (externalId.present) {
      map['external_id'] = Variable<String>(externalId.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (servingG.present) {
      map['serving_g'] = Variable<double>(servingG.value);
    }
    if (servingLabel.present) {
      map['serving_label'] = Variable<String>(servingLabel.value);
    }
    if (kcal100.present) {
      map['kcal100'] = Variable<double>(kcal100.value);
    }
    if (protein100.present) {
      map['protein100'] = Variable<double>(protein100.value);
    }
    if (carb100.present) {
      map['carb100'] = Variable<double>(carb100.value);
    }
    if (fat100.present) {
      map['fat100'] = Variable<double>(fat100.value);
    }
    if (fiber100.present) {
      map['fiber100'] = Variable<double>(fiber100.value);
    }
    if (sugar100.present) {
      map['sugar100'] = Variable<double>(sugar100.value);
    }
    if (satFat100.present) {
      map['sat_fat100'] = Variable<double>(satFat100.value);
    }
    if (sodiumMg100.present) {
      map['sodium_mg100'] = Variable<double>(sodiumMg100.value);
    }
    if (saltG100.present) {
      map['salt_g100'] = Variable<double>(saltG100.value);
    }
    if (microsJson.present) {
      map['micros_json'] = Variable<String>(microsJson.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (usageCount.present) {
      map['usage_count'] = Variable<int>(usageCount.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodsCompanion(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('externalId: $externalId, ')
          ..write('barcode: $barcode, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('locale: $locale, ')
          ..write('servingG: $servingG, ')
          ..write('servingLabel: $servingLabel, ')
          ..write('kcal100: $kcal100, ')
          ..write('protein100: $protein100, ')
          ..write('carb100: $carb100, ')
          ..write('fat100: $fat100, ')
          ..write('fiber100: $fiber100, ')
          ..write('sugar100: $sugar100, ')
          ..write('satFat100: $satFat100, ')
          ..write('sodiumMg100: $sodiumMg100, ')
          ..write('saltG100: $saltG100, ')
          ..write('microsJson: $microsJson, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('usageCount: $usageCount, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $EntryGroupsTable extends EntryGroups
    with TableInfo<$EntryGroupsTable, EntryGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntryGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, day, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entry_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntryGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntryGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntryGroup(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $EntryGroupsTable createAlias(String alias) {
    return $EntryGroupsTable(attachedDatabase, alias);
  }
}

class EntryGroup extends DataClass implements Insertable<EntryGroup> {
  final int id;
  final String day;
  final String name;
  final DateTime createdAt;
  const EntryGroup({
    required this.id,
    required this.day,
    required this.name,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['day'] = Variable<String>(day);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  EntryGroupsCompanion toCompanion(bool nullToAbsent) {
    return EntryGroupsCompanion(
      id: Value(id),
      day: Value(day),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory EntryGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntryGroup(
      id: serializer.fromJson<int>(json['id']),
      day: serializer.fromJson<String>(json['day']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'day': serializer.toJson<String>(day),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  EntryGroup copyWith({
    int? id,
    String? day,
    String? name,
    DateTime? createdAt,
  }) => EntryGroup(
    id: id ?? this.id,
    day: day ?? this.day,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
  );
  EntryGroup copyWithCompanion(EntryGroupsCompanion data) {
    return EntryGroup(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntryGroup(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, day, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntryGroup &&
          other.id == this.id &&
          other.day == this.day &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class EntryGroupsCompanion extends UpdateCompanion<EntryGroup> {
  final Value<int> id;
  final Value<String> day;
  final Value<String> name;
  final Value<DateTime> createdAt;
  const EntryGroupsCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  EntryGroupsCompanion.insert({
    this.id = const Value.absent(),
    required String day,
    required String name,
    this.createdAt = const Value.absent(),
  }) : day = Value(day),
       name = Value(name);
  static Insertable<EntryGroup> custom({
    Expression<int>? id,
    Expression<String>? day,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  EntryGroupsCompanion copyWith({
    Value<int>? id,
    Value<String>? day,
    Value<String>? name,
    Value<DateTime>? createdAt,
  }) {
    return EntryGroupsCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntryGroupsCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $EntriesTable extends Entries with TableInfo<$EntriesTable, Entry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MealType, int> mealType =
      GeneratedColumn<int>(
        'meal_type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<MealType>($EntriesTable.$convertermealType);
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<int> groupId = GeneratedColumn<int>(
    'group_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES entry_groups (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  @override
  late final GeneratedColumn<int> foodId = GeneratedColumn<int>(
    'food_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES foods (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _gramsMeta = const VerificationMeta('grams');
  @override
  late final GeneratedColumn<double> grams = GeneratedColumn<double>(
    'grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sNameMeta = const VerificationMeta('sName');
  @override
  late final GeneratedColumn<String> sName = GeneratedColumn<String>(
    's_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sKcal100Meta = const VerificationMeta(
    'sKcal100',
  );
  @override
  late final GeneratedColumn<double> sKcal100 = GeneratedColumn<double>(
    's_kcal100',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sProtein100Meta = const VerificationMeta(
    'sProtein100',
  );
  @override
  late final GeneratedColumn<double> sProtein100 = GeneratedColumn<double>(
    's_protein100',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sCarb100Meta = const VerificationMeta(
    'sCarb100',
  );
  @override
  late final GeneratedColumn<double> sCarb100 = GeneratedColumn<double>(
    's_carb100',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sFat100Meta = const VerificationMeta(
    'sFat100',
  );
  @override
  late final GeneratedColumn<double> sFat100 = GeneratedColumn<double>(
    's_fat100',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sMicrosJsonMeta = const VerificationMeta(
    'sMicrosJson',
  );
  @override
  late final GeneratedColumn<String> sMicrosJson = GeneratedColumn<String>(
    's_micros_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortIndexMeta = const VerificationMeta(
    'sortIndex',
  );
  @override
  late final GeneratedColumn<int> sortIndex = GeneratedColumn<int>(
    'sort_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    day,
    mealType,
    groupId,
    foodId,
    grams,
    sName,
    sKcal100,
    sProtein100,
    sCarb100,
    sFat100,
    sMicrosJson,
    sortIndex,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<Entry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    }
    if (data.containsKey('food_id')) {
      context.handle(
        _foodIdMeta,
        foodId.isAcceptableOrUnknown(data['food_id']!, _foodIdMeta),
      );
    }
    if (data.containsKey('grams')) {
      context.handle(
        _gramsMeta,
        grams.isAcceptableOrUnknown(data['grams']!, _gramsMeta),
      );
    } else if (isInserting) {
      context.missing(_gramsMeta);
    }
    if (data.containsKey('s_name')) {
      context.handle(
        _sNameMeta,
        sName.isAcceptableOrUnknown(data['s_name']!, _sNameMeta),
      );
    } else if (isInserting) {
      context.missing(_sNameMeta);
    }
    if (data.containsKey('s_kcal100')) {
      context.handle(
        _sKcal100Meta,
        sKcal100.isAcceptableOrUnknown(data['s_kcal100']!, _sKcal100Meta),
      );
    } else if (isInserting) {
      context.missing(_sKcal100Meta);
    }
    if (data.containsKey('s_protein100')) {
      context.handle(
        _sProtein100Meta,
        sProtein100.isAcceptableOrUnknown(
          data['s_protein100']!,
          _sProtein100Meta,
        ),
      );
    }
    if (data.containsKey('s_carb100')) {
      context.handle(
        _sCarb100Meta,
        sCarb100.isAcceptableOrUnknown(data['s_carb100']!, _sCarb100Meta),
      );
    }
    if (data.containsKey('s_fat100')) {
      context.handle(
        _sFat100Meta,
        sFat100.isAcceptableOrUnknown(data['s_fat100']!, _sFat100Meta),
      );
    }
    if (data.containsKey('s_micros_json')) {
      context.handle(
        _sMicrosJsonMeta,
        sMicrosJson.isAcceptableOrUnknown(
          data['s_micros_json']!,
          _sMicrosJsonMeta,
        ),
      );
    }
    if (data.containsKey('sort_index')) {
      context.handle(
        _sortIndexMeta,
        sortIndex.isAcceptableOrUnknown(data['sort_index']!, _sortIndexMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Entry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Entry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      mealType: $EntriesTable.$convertermealType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}meal_type'],
        )!,
      ),
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group_id'],
      ),
      foodId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}food_id'],
      ),
      grams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grams'],
      )!,
      sName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}s_name'],
      )!,
      sKcal100: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}s_kcal100'],
      )!,
      sProtein100: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}s_protein100'],
      ),
      sCarb100: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}s_carb100'],
      ),
      sFat100: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}s_fat100'],
      ),
      sMicrosJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}s_micros_json'],
      ),
      sortIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_index'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $EntriesTable createAlias(String alias) {
    return $EntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MealType, int, int> $convertermealType =
      const EnumIndexConverter<MealType>(MealType.values);
}

class Entry extends DataClass implements Insertable<Entry> {
  final int id;

  /// Local calendar day as 'YYYY-MM-DD'.
  final String day;
  final MealType mealType;

  /// In track-by-day mode, the ad-hoc group this entry belongs to (null in
  /// meal mode, where mealType organizes the day instead).
  final int? groupId;

  /// Convenience link back to the catalog food (nullable; snapshot is the source of truth).
  final int? foodId;
  final double grams;
  final String sName;
  final double sKcal100;
  final double? sProtein100;
  final double? sCarb100;
  final double? sFat100;
  final String? sMicrosJson;
  final int sortIndex;
  final DateTime createdAt;
  const Entry({
    required this.id,
    required this.day,
    required this.mealType,
    this.groupId,
    this.foodId,
    required this.grams,
    required this.sName,
    required this.sKcal100,
    this.sProtein100,
    this.sCarb100,
    this.sFat100,
    this.sMicrosJson,
    required this.sortIndex,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['day'] = Variable<String>(day);
    {
      map['meal_type'] = Variable<int>(
        $EntriesTable.$convertermealType.toSql(mealType),
      );
    }
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<int>(groupId);
    }
    if (!nullToAbsent || foodId != null) {
      map['food_id'] = Variable<int>(foodId);
    }
    map['grams'] = Variable<double>(grams);
    map['s_name'] = Variable<String>(sName);
    map['s_kcal100'] = Variable<double>(sKcal100);
    if (!nullToAbsent || sProtein100 != null) {
      map['s_protein100'] = Variable<double>(sProtein100);
    }
    if (!nullToAbsent || sCarb100 != null) {
      map['s_carb100'] = Variable<double>(sCarb100);
    }
    if (!nullToAbsent || sFat100 != null) {
      map['s_fat100'] = Variable<double>(sFat100);
    }
    if (!nullToAbsent || sMicrosJson != null) {
      map['s_micros_json'] = Variable<String>(sMicrosJson);
    }
    map['sort_index'] = Variable<int>(sortIndex);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  EntriesCompanion toCompanion(bool nullToAbsent) {
    return EntriesCompanion(
      id: Value(id),
      day: Value(day),
      mealType: Value(mealType),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
      foodId: foodId == null && nullToAbsent
          ? const Value.absent()
          : Value(foodId),
      grams: Value(grams),
      sName: Value(sName),
      sKcal100: Value(sKcal100),
      sProtein100: sProtein100 == null && nullToAbsent
          ? const Value.absent()
          : Value(sProtein100),
      sCarb100: sCarb100 == null && nullToAbsent
          ? const Value.absent()
          : Value(sCarb100),
      sFat100: sFat100 == null && nullToAbsent
          ? const Value.absent()
          : Value(sFat100),
      sMicrosJson: sMicrosJson == null && nullToAbsent
          ? const Value.absent()
          : Value(sMicrosJson),
      sortIndex: Value(sortIndex),
      createdAt: Value(createdAt),
    );
  }

  factory Entry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Entry(
      id: serializer.fromJson<int>(json['id']),
      day: serializer.fromJson<String>(json['day']),
      mealType: $EntriesTable.$convertermealType.fromJson(
        serializer.fromJson<int>(json['mealType']),
      ),
      groupId: serializer.fromJson<int?>(json['groupId']),
      foodId: serializer.fromJson<int?>(json['foodId']),
      grams: serializer.fromJson<double>(json['grams']),
      sName: serializer.fromJson<String>(json['sName']),
      sKcal100: serializer.fromJson<double>(json['sKcal100']),
      sProtein100: serializer.fromJson<double?>(json['sProtein100']),
      sCarb100: serializer.fromJson<double?>(json['sCarb100']),
      sFat100: serializer.fromJson<double?>(json['sFat100']),
      sMicrosJson: serializer.fromJson<String?>(json['sMicrosJson']),
      sortIndex: serializer.fromJson<int>(json['sortIndex']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'day': serializer.toJson<String>(day),
      'mealType': serializer.toJson<int>(
        $EntriesTable.$convertermealType.toJson(mealType),
      ),
      'groupId': serializer.toJson<int?>(groupId),
      'foodId': serializer.toJson<int?>(foodId),
      'grams': serializer.toJson<double>(grams),
      'sName': serializer.toJson<String>(sName),
      'sKcal100': serializer.toJson<double>(sKcal100),
      'sProtein100': serializer.toJson<double?>(sProtein100),
      'sCarb100': serializer.toJson<double?>(sCarb100),
      'sFat100': serializer.toJson<double?>(sFat100),
      'sMicrosJson': serializer.toJson<String?>(sMicrosJson),
      'sortIndex': serializer.toJson<int>(sortIndex),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Entry copyWith({
    int? id,
    String? day,
    MealType? mealType,
    Value<int?> groupId = const Value.absent(),
    Value<int?> foodId = const Value.absent(),
    double? grams,
    String? sName,
    double? sKcal100,
    Value<double?> sProtein100 = const Value.absent(),
    Value<double?> sCarb100 = const Value.absent(),
    Value<double?> sFat100 = const Value.absent(),
    Value<String?> sMicrosJson = const Value.absent(),
    int? sortIndex,
    DateTime? createdAt,
  }) => Entry(
    id: id ?? this.id,
    day: day ?? this.day,
    mealType: mealType ?? this.mealType,
    groupId: groupId.present ? groupId.value : this.groupId,
    foodId: foodId.present ? foodId.value : this.foodId,
    grams: grams ?? this.grams,
    sName: sName ?? this.sName,
    sKcal100: sKcal100 ?? this.sKcal100,
    sProtein100: sProtein100.present ? sProtein100.value : this.sProtein100,
    sCarb100: sCarb100.present ? sCarb100.value : this.sCarb100,
    sFat100: sFat100.present ? sFat100.value : this.sFat100,
    sMicrosJson: sMicrosJson.present ? sMicrosJson.value : this.sMicrosJson,
    sortIndex: sortIndex ?? this.sortIndex,
    createdAt: createdAt ?? this.createdAt,
  );
  Entry copyWithCompanion(EntriesCompanion data) {
    return Entry(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      mealType: data.mealType.present ? data.mealType.value : this.mealType,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
      grams: data.grams.present ? data.grams.value : this.grams,
      sName: data.sName.present ? data.sName.value : this.sName,
      sKcal100: data.sKcal100.present ? data.sKcal100.value : this.sKcal100,
      sProtein100: data.sProtein100.present
          ? data.sProtein100.value
          : this.sProtein100,
      sCarb100: data.sCarb100.present ? data.sCarb100.value : this.sCarb100,
      sFat100: data.sFat100.present ? data.sFat100.value : this.sFat100,
      sMicrosJson: data.sMicrosJson.present
          ? data.sMicrosJson.value
          : this.sMicrosJson,
      sortIndex: data.sortIndex.present ? data.sortIndex.value : this.sortIndex,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Entry(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('mealType: $mealType, ')
          ..write('groupId: $groupId, ')
          ..write('foodId: $foodId, ')
          ..write('grams: $grams, ')
          ..write('sName: $sName, ')
          ..write('sKcal100: $sKcal100, ')
          ..write('sProtein100: $sProtein100, ')
          ..write('sCarb100: $sCarb100, ')
          ..write('sFat100: $sFat100, ')
          ..write('sMicrosJson: $sMicrosJson, ')
          ..write('sortIndex: $sortIndex, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    day,
    mealType,
    groupId,
    foodId,
    grams,
    sName,
    sKcal100,
    sProtein100,
    sCarb100,
    sFat100,
    sMicrosJson,
    sortIndex,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Entry &&
          other.id == this.id &&
          other.day == this.day &&
          other.mealType == this.mealType &&
          other.groupId == this.groupId &&
          other.foodId == this.foodId &&
          other.grams == this.grams &&
          other.sName == this.sName &&
          other.sKcal100 == this.sKcal100 &&
          other.sProtein100 == this.sProtein100 &&
          other.sCarb100 == this.sCarb100 &&
          other.sFat100 == this.sFat100 &&
          other.sMicrosJson == this.sMicrosJson &&
          other.sortIndex == this.sortIndex &&
          other.createdAt == this.createdAt);
}

class EntriesCompanion extends UpdateCompanion<Entry> {
  final Value<int> id;
  final Value<String> day;
  final Value<MealType> mealType;
  final Value<int?> groupId;
  final Value<int?> foodId;
  final Value<double> grams;
  final Value<String> sName;
  final Value<double> sKcal100;
  final Value<double?> sProtein100;
  final Value<double?> sCarb100;
  final Value<double?> sFat100;
  final Value<String?> sMicrosJson;
  final Value<int> sortIndex;
  final Value<DateTime> createdAt;
  const EntriesCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.mealType = const Value.absent(),
    this.groupId = const Value.absent(),
    this.foodId = const Value.absent(),
    this.grams = const Value.absent(),
    this.sName = const Value.absent(),
    this.sKcal100 = const Value.absent(),
    this.sProtein100 = const Value.absent(),
    this.sCarb100 = const Value.absent(),
    this.sFat100 = const Value.absent(),
    this.sMicrosJson = const Value.absent(),
    this.sortIndex = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  EntriesCompanion.insert({
    this.id = const Value.absent(),
    required String day,
    required MealType mealType,
    this.groupId = const Value.absent(),
    this.foodId = const Value.absent(),
    required double grams,
    required String sName,
    required double sKcal100,
    this.sProtein100 = const Value.absent(),
    this.sCarb100 = const Value.absent(),
    this.sFat100 = const Value.absent(),
    this.sMicrosJson = const Value.absent(),
    this.sortIndex = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : day = Value(day),
       mealType = Value(mealType),
       grams = Value(grams),
       sName = Value(sName),
       sKcal100 = Value(sKcal100);
  static Insertable<Entry> custom({
    Expression<int>? id,
    Expression<String>? day,
    Expression<int>? mealType,
    Expression<int>? groupId,
    Expression<int>? foodId,
    Expression<double>? grams,
    Expression<String>? sName,
    Expression<double>? sKcal100,
    Expression<double>? sProtein100,
    Expression<double>? sCarb100,
    Expression<double>? sFat100,
    Expression<String>? sMicrosJson,
    Expression<int>? sortIndex,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (mealType != null) 'meal_type': mealType,
      if (groupId != null) 'group_id': groupId,
      if (foodId != null) 'food_id': foodId,
      if (grams != null) 'grams': grams,
      if (sName != null) 's_name': sName,
      if (sKcal100 != null) 's_kcal100': sKcal100,
      if (sProtein100 != null) 's_protein100': sProtein100,
      if (sCarb100 != null) 's_carb100': sCarb100,
      if (sFat100 != null) 's_fat100': sFat100,
      if (sMicrosJson != null) 's_micros_json': sMicrosJson,
      if (sortIndex != null) 'sort_index': sortIndex,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  EntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? day,
    Value<MealType>? mealType,
    Value<int?>? groupId,
    Value<int?>? foodId,
    Value<double>? grams,
    Value<String>? sName,
    Value<double>? sKcal100,
    Value<double?>? sProtein100,
    Value<double?>? sCarb100,
    Value<double?>? sFat100,
    Value<String?>? sMicrosJson,
    Value<int>? sortIndex,
    Value<DateTime>? createdAt,
  }) {
    return EntriesCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      mealType: mealType ?? this.mealType,
      groupId: groupId ?? this.groupId,
      foodId: foodId ?? this.foodId,
      grams: grams ?? this.grams,
      sName: sName ?? this.sName,
      sKcal100: sKcal100 ?? this.sKcal100,
      sProtein100: sProtein100 ?? this.sProtein100,
      sCarb100: sCarb100 ?? this.sCarb100,
      sFat100: sFat100 ?? this.sFat100,
      sMicrosJson: sMicrosJson ?? this.sMicrosJson,
      sortIndex: sortIndex ?? this.sortIndex,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (mealType.present) {
      map['meal_type'] = Variable<int>(
        $EntriesTable.$convertermealType.toSql(mealType.value),
      );
    }
    if (groupId.present) {
      map['group_id'] = Variable<int>(groupId.value);
    }
    if (foodId.present) {
      map['food_id'] = Variable<int>(foodId.value);
    }
    if (grams.present) {
      map['grams'] = Variable<double>(grams.value);
    }
    if (sName.present) {
      map['s_name'] = Variable<String>(sName.value);
    }
    if (sKcal100.present) {
      map['s_kcal100'] = Variable<double>(sKcal100.value);
    }
    if (sProtein100.present) {
      map['s_protein100'] = Variable<double>(sProtein100.value);
    }
    if (sCarb100.present) {
      map['s_carb100'] = Variable<double>(sCarb100.value);
    }
    if (sFat100.present) {
      map['s_fat100'] = Variable<double>(sFat100.value);
    }
    if (sMicrosJson.present) {
      map['s_micros_json'] = Variable<String>(sMicrosJson.value);
    }
    if (sortIndex.present) {
      map['sort_index'] = Variable<int>(sortIndex.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntriesCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('mealType: $mealType, ')
          ..write('groupId: $groupId, ')
          ..write('foodId: $foodId, ')
          ..write('grams: $grams, ')
          ..write('sName: $sName, ')
          ..write('sKcal100: $sKcal100, ')
          ..write('sProtein100: $sProtein100, ')
          ..write('sCarb100: $sCarb100, ')
          ..write('sFat100: $sFat100, ')
          ..write('sMicrosJson: $sMicrosJson, ')
          ..write('sortIndex: $sortIndex, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TargetsTable extends Targets with TableInfo<$TargetsTable, Target> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TargetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _weekdayMeta = const VerificationMeta(
    'weekday',
  );
  @override
  late final GeneratedColumn<int> weekday = GeneratedColumn<int>(
    'weekday',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<double> kcal = GeneratedColumn<double>(
    'kcal',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kcalMinMeta = const VerificationMeta(
    'kcalMin',
  );
  @override
  late final GeneratedColumn<double> kcalMin = GeneratedColumn<double>(
    'kcal_min',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kcalMaxMeta = const VerificationMeta(
    'kcalMax',
  );
  @override
  late final GeneratedColumn<double> kcalMax = GeneratedColumn<double>(
    'kcal_max',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _proteinMeta = const VerificationMeta(
    'protein',
  );
  @override
  late final GeneratedColumn<double> protein = GeneratedColumn<double>(
    'protein',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _carbMeta = const VerificationMeta('carb');
  @override
  late final GeneratedColumn<double> carb = GeneratedColumn<double>(
    'carb',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<double> fat = GeneratedColumn<double>(
    'fat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    weekday,
    kcal,
    kcalMin,
    kcalMax,
    protein,
    carb,
    fat,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'targets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Target> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('weekday')) {
      context.handle(
        _weekdayMeta,
        weekday.isAcceptableOrUnknown(data['weekday']!, _weekdayMeta),
      );
    }
    if (data.containsKey('kcal')) {
      context.handle(
        _kcalMeta,
        kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta),
      );
    }
    if (data.containsKey('kcal_min')) {
      context.handle(
        _kcalMinMeta,
        kcalMin.isAcceptableOrUnknown(data['kcal_min']!, _kcalMinMeta),
      );
    }
    if (data.containsKey('kcal_max')) {
      context.handle(
        _kcalMaxMeta,
        kcalMax.isAcceptableOrUnknown(data['kcal_max']!, _kcalMaxMeta),
      );
    }
    if (data.containsKey('protein')) {
      context.handle(
        _proteinMeta,
        protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta),
      );
    }
    if (data.containsKey('carb')) {
      context.handle(
        _carbMeta,
        carb.isAcceptableOrUnknown(data['carb']!, _carbMeta),
      );
    }
    if (data.containsKey('fat')) {
      context.handle(
        _fatMeta,
        fat.isAcceptableOrUnknown(data['fat']!, _fatMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {weekday};
  @override
  Target map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Target(
      weekday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekday'],
      )!,
      kcal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal'],
      ),
      kcalMin: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal_min'],
      ),
      kcalMax: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal_max'],
      ),
      protein: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein'],
      ),
      carb: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carb'],
      ),
      fat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat'],
      ),
    );
  }

  @override
  $TargetsTable createAlias(String alias) {
    return $TargetsTable(attachedDatabase, alias);
  }
}

class Target extends DataClass implements Insertable<Target> {
  final int weekday;
  final double? kcal;
  final double? kcalMin;
  final double? kcalMax;
  final double? protein;
  final double? carb;
  final double? fat;
  const Target({
    required this.weekday,
    this.kcal,
    this.kcalMin,
    this.kcalMax,
    this.protein,
    this.carb,
    this.fat,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['weekday'] = Variable<int>(weekday);
    if (!nullToAbsent || kcal != null) {
      map['kcal'] = Variable<double>(kcal);
    }
    if (!nullToAbsent || kcalMin != null) {
      map['kcal_min'] = Variable<double>(kcalMin);
    }
    if (!nullToAbsent || kcalMax != null) {
      map['kcal_max'] = Variable<double>(kcalMax);
    }
    if (!nullToAbsent || protein != null) {
      map['protein'] = Variable<double>(protein);
    }
    if (!nullToAbsent || carb != null) {
      map['carb'] = Variable<double>(carb);
    }
    if (!nullToAbsent || fat != null) {
      map['fat'] = Variable<double>(fat);
    }
    return map;
  }

  TargetsCompanion toCompanion(bool nullToAbsent) {
    return TargetsCompanion(
      weekday: Value(weekday),
      kcal: kcal == null && nullToAbsent ? const Value.absent() : Value(kcal),
      kcalMin: kcalMin == null && nullToAbsent
          ? const Value.absent()
          : Value(kcalMin),
      kcalMax: kcalMax == null && nullToAbsent
          ? const Value.absent()
          : Value(kcalMax),
      protein: protein == null && nullToAbsent
          ? const Value.absent()
          : Value(protein),
      carb: carb == null && nullToAbsent ? const Value.absent() : Value(carb),
      fat: fat == null && nullToAbsent ? const Value.absent() : Value(fat),
    );
  }

  factory Target.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Target(
      weekday: serializer.fromJson<int>(json['weekday']),
      kcal: serializer.fromJson<double?>(json['kcal']),
      kcalMin: serializer.fromJson<double?>(json['kcalMin']),
      kcalMax: serializer.fromJson<double?>(json['kcalMax']),
      protein: serializer.fromJson<double?>(json['protein']),
      carb: serializer.fromJson<double?>(json['carb']),
      fat: serializer.fromJson<double?>(json['fat']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'weekday': serializer.toJson<int>(weekday),
      'kcal': serializer.toJson<double?>(kcal),
      'kcalMin': serializer.toJson<double?>(kcalMin),
      'kcalMax': serializer.toJson<double?>(kcalMax),
      'protein': serializer.toJson<double?>(protein),
      'carb': serializer.toJson<double?>(carb),
      'fat': serializer.toJson<double?>(fat),
    };
  }

  Target copyWith({
    int? weekday,
    Value<double?> kcal = const Value.absent(),
    Value<double?> kcalMin = const Value.absent(),
    Value<double?> kcalMax = const Value.absent(),
    Value<double?> protein = const Value.absent(),
    Value<double?> carb = const Value.absent(),
    Value<double?> fat = const Value.absent(),
  }) => Target(
    weekday: weekday ?? this.weekday,
    kcal: kcal.present ? kcal.value : this.kcal,
    kcalMin: kcalMin.present ? kcalMin.value : this.kcalMin,
    kcalMax: kcalMax.present ? kcalMax.value : this.kcalMax,
    protein: protein.present ? protein.value : this.protein,
    carb: carb.present ? carb.value : this.carb,
    fat: fat.present ? fat.value : this.fat,
  );
  Target copyWithCompanion(TargetsCompanion data) {
    return Target(
      weekday: data.weekday.present ? data.weekday.value : this.weekday,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
      kcalMin: data.kcalMin.present ? data.kcalMin.value : this.kcalMin,
      kcalMax: data.kcalMax.present ? data.kcalMax.value : this.kcalMax,
      protein: data.protein.present ? data.protein.value : this.protein,
      carb: data.carb.present ? data.carb.value : this.carb,
      fat: data.fat.present ? data.fat.value : this.fat,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Target(')
          ..write('weekday: $weekday, ')
          ..write('kcal: $kcal, ')
          ..write('kcalMin: $kcalMin, ')
          ..write('kcalMax: $kcalMax, ')
          ..write('protein: $protein, ')
          ..write('carb: $carb, ')
          ..write('fat: $fat')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(weekday, kcal, kcalMin, kcalMax, protein, carb, fat);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Target &&
          other.weekday == this.weekday &&
          other.kcal == this.kcal &&
          other.kcalMin == this.kcalMin &&
          other.kcalMax == this.kcalMax &&
          other.protein == this.protein &&
          other.carb == this.carb &&
          other.fat == this.fat);
}

class TargetsCompanion extends UpdateCompanion<Target> {
  final Value<int> weekday;
  final Value<double?> kcal;
  final Value<double?> kcalMin;
  final Value<double?> kcalMax;
  final Value<double?> protein;
  final Value<double?> carb;
  final Value<double?> fat;
  const TargetsCompanion({
    this.weekday = const Value.absent(),
    this.kcal = const Value.absent(),
    this.kcalMin = const Value.absent(),
    this.kcalMax = const Value.absent(),
    this.protein = const Value.absent(),
    this.carb = const Value.absent(),
    this.fat = const Value.absent(),
  });
  TargetsCompanion.insert({
    this.weekday = const Value.absent(),
    this.kcal = const Value.absent(),
    this.kcalMin = const Value.absent(),
    this.kcalMax = const Value.absent(),
    this.protein = const Value.absent(),
    this.carb = const Value.absent(),
    this.fat = const Value.absent(),
  });
  static Insertable<Target> custom({
    Expression<int>? weekday,
    Expression<double>? kcal,
    Expression<double>? kcalMin,
    Expression<double>? kcalMax,
    Expression<double>? protein,
    Expression<double>? carb,
    Expression<double>? fat,
  }) {
    return RawValuesInsertable({
      if (weekday != null) 'weekday': weekday,
      if (kcal != null) 'kcal': kcal,
      if (kcalMin != null) 'kcal_min': kcalMin,
      if (kcalMax != null) 'kcal_max': kcalMax,
      if (protein != null) 'protein': protein,
      if (carb != null) 'carb': carb,
      if (fat != null) 'fat': fat,
    });
  }

  TargetsCompanion copyWith({
    Value<int>? weekday,
    Value<double?>? kcal,
    Value<double?>? kcalMin,
    Value<double?>? kcalMax,
    Value<double?>? protein,
    Value<double?>? carb,
    Value<double?>? fat,
  }) {
    return TargetsCompanion(
      weekday: weekday ?? this.weekday,
      kcal: kcal ?? this.kcal,
      kcalMin: kcalMin ?? this.kcalMin,
      kcalMax: kcalMax ?? this.kcalMax,
      protein: protein ?? this.protein,
      carb: carb ?? this.carb,
      fat: fat ?? this.fat,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (weekday.present) {
      map['weekday'] = Variable<int>(weekday.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<double>(kcal.value);
    }
    if (kcalMin.present) {
      map['kcal_min'] = Variable<double>(kcalMin.value);
    }
    if (kcalMax.present) {
      map['kcal_max'] = Variable<double>(kcalMax.value);
    }
    if (protein.present) {
      map['protein'] = Variable<double>(protein.value);
    }
    if (carb.present) {
      map['carb'] = Variable<double>(carb.value);
    }
    if (fat.present) {
      map['fat'] = Variable<double>(fat.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TargetsCompanion(')
          ..write('weekday: $weekday, ')
          ..write('kcal: $kcal, ')
          ..write('kcalMin: $kcalMin, ')
          ..write('kcalMax: $kcalMax, ')
          ..write('protein: $protein, ')
          ..write('carb: $carb, ')
          ..write('fat: $fat')
          ..write(')'))
        .toString();
  }
}

class $RecipesTable extends Recipes with TableInfo<$RecipesTable, Recipe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _servingsMeta = const VerificationMeta(
    'servings',
  );
  @override
  late final GeneratedColumn<double> servings = GeneratedColumn<double>(
    'servings',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, servings, note, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Recipe> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('servings')) {
      context.handle(
        _servingsMeta,
        servings.isAcceptableOrUnknown(data['servings']!, _servingsMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Recipe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Recipe(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      servings: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}servings'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RecipesTable createAlias(String alias) {
    return $RecipesTable(attachedDatabase, alias);
  }
}

class Recipe extends DataClass implements Insertable<Recipe> {
  final int id;
  final String name;
  final double servings;
  final String? note;
  final DateTime createdAt;
  const Recipe({
    required this.id,
    required this.name,
    required this.servings,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['servings'] = Variable<double>(servings);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RecipesCompanion toCompanion(bool nullToAbsent) {
    return RecipesCompanion(
      id: Value(id),
      name: Value(name),
      servings: Value(servings),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory Recipe.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Recipe(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      servings: serializer.fromJson<double>(json['servings']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'servings': serializer.toJson<double>(servings),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Recipe copyWith({
    int? id,
    String? name,
    double? servings,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => Recipe(
    id: id ?? this.id,
    name: name ?? this.name,
    servings: servings ?? this.servings,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  Recipe copyWithCompanion(RecipesCompanion data) {
    return Recipe(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      servings: data.servings.present ? data.servings.value : this.servings,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Recipe(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('servings: $servings, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, servings, note, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Recipe &&
          other.id == this.id &&
          other.name == this.name &&
          other.servings == this.servings &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class RecipesCompanion extends UpdateCompanion<Recipe> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> servings;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  const RecipesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.servings = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  RecipesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.servings = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Recipe> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? servings,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (servings != null) 'servings': servings,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  RecipesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<double>? servings,
    Value<String?>? note,
    Value<DateTime>? createdAt,
  }) {
    return RecipesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      servings: servings ?? this.servings,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (servings.present) {
      map['servings'] = Variable<double>(servings.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('servings: $servings, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $RecipeItemsTable extends RecipeItems
    with TableInfo<$RecipeItemsTable, RecipeItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<int> recipeId = GeneratedColumn<int>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recipes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sNameMeta = const VerificationMeta('sName');
  @override
  late final GeneratedColumn<String> sName = GeneratedColumn<String>(
    's_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gramsMeta = const VerificationMeta('grams');
  @override
  late final GeneratedColumn<double> grams = GeneratedColumn<double>(
    'grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sKcal100Meta = const VerificationMeta(
    'sKcal100',
  );
  @override
  late final GeneratedColumn<double> sKcal100 = GeneratedColumn<double>(
    's_kcal100',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sProtein100Meta = const VerificationMeta(
    'sProtein100',
  );
  @override
  late final GeneratedColumn<double> sProtein100 = GeneratedColumn<double>(
    's_protein100',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sCarb100Meta = const VerificationMeta(
    'sCarb100',
  );
  @override
  late final GeneratedColumn<double> sCarb100 = GeneratedColumn<double>(
    's_carb100',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sFat100Meta = const VerificationMeta(
    'sFat100',
  );
  @override
  late final GeneratedColumn<double> sFat100 = GeneratedColumn<double>(
    's_fat100',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sMicrosJsonMeta = const VerificationMeta(
    'sMicrosJson',
  );
  @override
  late final GeneratedColumn<String> sMicrosJson = GeneratedColumn<String>(
    's_micros_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortIndexMeta = const VerificationMeta(
    'sortIndex',
  );
  @override
  late final GeneratedColumn<int> sortIndex = GeneratedColumn<int>(
    'sort_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recipeId,
    sName,
    grams,
    sKcal100,
    sProtein100,
    sCarb100,
    sFat100,
    sMicrosJson,
    sortIndex,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipeItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('s_name')) {
      context.handle(
        _sNameMeta,
        sName.isAcceptableOrUnknown(data['s_name']!, _sNameMeta),
      );
    } else if (isInserting) {
      context.missing(_sNameMeta);
    }
    if (data.containsKey('grams')) {
      context.handle(
        _gramsMeta,
        grams.isAcceptableOrUnknown(data['grams']!, _gramsMeta),
      );
    } else if (isInserting) {
      context.missing(_gramsMeta);
    }
    if (data.containsKey('s_kcal100')) {
      context.handle(
        _sKcal100Meta,
        sKcal100.isAcceptableOrUnknown(data['s_kcal100']!, _sKcal100Meta),
      );
    } else if (isInserting) {
      context.missing(_sKcal100Meta);
    }
    if (data.containsKey('s_protein100')) {
      context.handle(
        _sProtein100Meta,
        sProtein100.isAcceptableOrUnknown(
          data['s_protein100']!,
          _sProtein100Meta,
        ),
      );
    }
    if (data.containsKey('s_carb100')) {
      context.handle(
        _sCarb100Meta,
        sCarb100.isAcceptableOrUnknown(data['s_carb100']!, _sCarb100Meta),
      );
    }
    if (data.containsKey('s_fat100')) {
      context.handle(
        _sFat100Meta,
        sFat100.isAcceptableOrUnknown(data['s_fat100']!, _sFat100Meta),
      );
    }
    if (data.containsKey('s_micros_json')) {
      context.handle(
        _sMicrosJsonMeta,
        sMicrosJson.isAcceptableOrUnknown(
          data['s_micros_json']!,
          _sMicrosJsonMeta,
        ),
      );
    }
    if (data.containsKey('sort_index')) {
      context.handle(
        _sortIndexMeta,
        sortIndex.isAcceptableOrUnknown(data['sort_index']!, _sortIndexMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecipeItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recipe_id'],
      )!,
      sName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}s_name'],
      )!,
      grams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grams'],
      )!,
      sKcal100: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}s_kcal100'],
      )!,
      sProtein100: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}s_protein100'],
      ),
      sCarb100: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}s_carb100'],
      ),
      sFat100: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}s_fat100'],
      ),
      sMicrosJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}s_micros_json'],
      ),
      sortIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_index'],
      )!,
    );
  }

  @override
  $RecipeItemsTable createAlias(String alias) {
    return $RecipeItemsTable(attachedDatabase, alias);
  }
}

class RecipeItem extends DataClass implements Insertable<RecipeItem> {
  final int id;
  final int recipeId;
  final String sName;
  final double grams;
  final double sKcal100;
  final double? sProtein100;
  final double? sCarb100;
  final double? sFat100;
  final String? sMicrosJson;
  final int sortIndex;
  const RecipeItem({
    required this.id,
    required this.recipeId,
    required this.sName,
    required this.grams,
    required this.sKcal100,
    this.sProtein100,
    this.sCarb100,
    this.sFat100,
    this.sMicrosJson,
    required this.sortIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['recipe_id'] = Variable<int>(recipeId);
    map['s_name'] = Variable<String>(sName);
    map['grams'] = Variable<double>(grams);
    map['s_kcal100'] = Variable<double>(sKcal100);
    if (!nullToAbsent || sProtein100 != null) {
      map['s_protein100'] = Variable<double>(sProtein100);
    }
    if (!nullToAbsent || sCarb100 != null) {
      map['s_carb100'] = Variable<double>(sCarb100);
    }
    if (!nullToAbsent || sFat100 != null) {
      map['s_fat100'] = Variable<double>(sFat100);
    }
    if (!nullToAbsent || sMicrosJson != null) {
      map['s_micros_json'] = Variable<String>(sMicrosJson);
    }
    map['sort_index'] = Variable<int>(sortIndex);
    return map;
  }

  RecipeItemsCompanion toCompanion(bool nullToAbsent) {
    return RecipeItemsCompanion(
      id: Value(id),
      recipeId: Value(recipeId),
      sName: Value(sName),
      grams: Value(grams),
      sKcal100: Value(sKcal100),
      sProtein100: sProtein100 == null && nullToAbsent
          ? const Value.absent()
          : Value(sProtein100),
      sCarb100: sCarb100 == null && nullToAbsent
          ? const Value.absent()
          : Value(sCarb100),
      sFat100: sFat100 == null && nullToAbsent
          ? const Value.absent()
          : Value(sFat100),
      sMicrosJson: sMicrosJson == null && nullToAbsent
          ? const Value.absent()
          : Value(sMicrosJson),
      sortIndex: Value(sortIndex),
    );
  }

  factory RecipeItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeItem(
      id: serializer.fromJson<int>(json['id']),
      recipeId: serializer.fromJson<int>(json['recipeId']),
      sName: serializer.fromJson<String>(json['sName']),
      grams: serializer.fromJson<double>(json['grams']),
      sKcal100: serializer.fromJson<double>(json['sKcal100']),
      sProtein100: serializer.fromJson<double?>(json['sProtein100']),
      sCarb100: serializer.fromJson<double?>(json['sCarb100']),
      sFat100: serializer.fromJson<double?>(json['sFat100']),
      sMicrosJson: serializer.fromJson<String?>(json['sMicrosJson']),
      sortIndex: serializer.fromJson<int>(json['sortIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recipeId': serializer.toJson<int>(recipeId),
      'sName': serializer.toJson<String>(sName),
      'grams': serializer.toJson<double>(grams),
      'sKcal100': serializer.toJson<double>(sKcal100),
      'sProtein100': serializer.toJson<double?>(sProtein100),
      'sCarb100': serializer.toJson<double?>(sCarb100),
      'sFat100': serializer.toJson<double?>(sFat100),
      'sMicrosJson': serializer.toJson<String?>(sMicrosJson),
      'sortIndex': serializer.toJson<int>(sortIndex),
    };
  }

  RecipeItem copyWith({
    int? id,
    int? recipeId,
    String? sName,
    double? grams,
    double? sKcal100,
    Value<double?> sProtein100 = const Value.absent(),
    Value<double?> sCarb100 = const Value.absent(),
    Value<double?> sFat100 = const Value.absent(),
    Value<String?> sMicrosJson = const Value.absent(),
    int? sortIndex,
  }) => RecipeItem(
    id: id ?? this.id,
    recipeId: recipeId ?? this.recipeId,
    sName: sName ?? this.sName,
    grams: grams ?? this.grams,
    sKcal100: sKcal100 ?? this.sKcal100,
    sProtein100: sProtein100.present ? sProtein100.value : this.sProtein100,
    sCarb100: sCarb100.present ? sCarb100.value : this.sCarb100,
    sFat100: sFat100.present ? sFat100.value : this.sFat100,
    sMicrosJson: sMicrosJson.present ? sMicrosJson.value : this.sMicrosJson,
    sortIndex: sortIndex ?? this.sortIndex,
  );
  RecipeItem copyWithCompanion(RecipeItemsCompanion data) {
    return RecipeItem(
      id: data.id.present ? data.id.value : this.id,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      sName: data.sName.present ? data.sName.value : this.sName,
      grams: data.grams.present ? data.grams.value : this.grams,
      sKcal100: data.sKcal100.present ? data.sKcal100.value : this.sKcal100,
      sProtein100: data.sProtein100.present
          ? data.sProtein100.value
          : this.sProtein100,
      sCarb100: data.sCarb100.present ? data.sCarb100.value : this.sCarb100,
      sFat100: data.sFat100.present ? data.sFat100.value : this.sFat100,
      sMicrosJson: data.sMicrosJson.present
          ? data.sMicrosJson.value
          : this.sMicrosJson,
      sortIndex: data.sortIndex.present ? data.sortIndex.value : this.sortIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeItem(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('sName: $sName, ')
          ..write('grams: $grams, ')
          ..write('sKcal100: $sKcal100, ')
          ..write('sProtein100: $sProtein100, ')
          ..write('sCarb100: $sCarb100, ')
          ..write('sFat100: $sFat100, ')
          ..write('sMicrosJson: $sMicrosJson, ')
          ..write('sortIndex: $sortIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    recipeId,
    sName,
    grams,
    sKcal100,
    sProtein100,
    sCarb100,
    sFat100,
    sMicrosJson,
    sortIndex,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeItem &&
          other.id == this.id &&
          other.recipeId == this.recipeId &&
          other.sName == this.sName &&
          other.grams == this.grams &&
          other.sKcal100 == this.sKcal100 &&
          other.sProtein100 == this.sProtein100 &&
          other.sCarb100 == this.sCarb100 &&
          other.sFat100 == this.sFat100 &&
          other.sMicrosJson == this.sMicrosJson &&
          other.sortIndex == this.sortIndex);
}

class RecipeItemsCompanion extends UpdateCompanion<RecipeItem> {
  final Value<int> id;
  final Value<int> recipeId;
  final Value<String> sName;
  final Value<double> grams;
  final Value<double> sKcal100;
  final Value<double?> sProtein100;
  final Value<double?> sCarb100;
  final Value<double?> sFat100;
  final Value<String?> sMicrosJson;
  final Value<int> sortIndex;
  const RecipeItemsCompanion({
    this.id = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.sName = const Value.absent(),
    this.grams = const Value.absent(),
    this.sKcal100 = const Value.absent(),
    this.sProtein100 = const Value.absent(),
    this.sCarb100 = const Value.absent(),
    this.sFat100 = const Value.absent(),
    this.sMicrosJson = const Value.absent(),
    this.sortIndex = const Value.absent(),
  });
  RecipeItemsCompanion.insert({
    this.id = const Value.absent(),
    required int recipeId,
    required String sName,
    required double grams,
    required double sKcal100,
    this.sProtein100 = const Value.absent(),
    this.sCarb100 = const Value.absent(),
    this.sFat100 = const Value.absent(),
    this.sMicrosJson = const Value.absent(),
    this.sortIndex = const Value.absent(),
  }) : recipeId = Value(recipeId),
       sName = Value(sName),
       grams = Value(grams),
       sKcal100 = Value(sKcal100);
  static Insertable<RecipeItem> custom({
    Expression<int>? id,
    Expression<int>? recipeId,
    Expression<String>? sName,
    Expression<double>? grams,
    Expression<double>? sKcal100,
    Expression<double>? sProtein100,
    Expression<double>? sCarb100,
    Expression<double>? sFat100,
    Expression<String>? sMicrosJson,
    Expression<int>? sortIndex,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeId != null) 'recipe_id': recipeId,
      if (sName != null) 's_name': sName,
      if (grams != null) 'grams': grams,
      if (sKcal100 != null) 's_kcal100': sKcal100,
      if (sProtein100 != null) 's_protein100': sProtein100,
      if (sCarb100 != null) 's_carb100': sCarb100,
      if (sFat100 != null) 's_fat100': sFat100,
      if (sMicrosJson != null) 's_micros_json': sMicrosJson,
      if (sortIndex != null) 'sort_index': sortIndex,
    });
  }

  RecipeItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? recipeId,
    Value<String>? sName,
    Value<double>? grams,
    Value<double>? sKcal100,
    Value<double?>? sProtein100,
    Value<double?>? sCarb100,
    Value<double?>? sFat100,
    Value<String?>? sMicrosJson,
    Value<int>? sortIndex,
  }) {
    return RecipeItemsCompanion(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      sName: sName ?? this.sName,
      grams: grams ?? this.grams,
      sKcal100: sKcal100 ?? this.sKcal100,
      sProtein100: sProtein100 ?? this.sProtein100,
      sCarb100: sCarb100 ?? this.sCarb100,
      sFat100: sFat100 ?? this.sFat100,
      sMicrosJson: sMicrosJson ?? this.sMicrosJson,
      sortIndex: sortIndex ?? this.sortIndex,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<int>(recipeId.value);
    }
    if (sName.present) {
      map['s_name'] = Variable<String>(sName.value);
    }
    if (grams.present) {
      map['grams'] = Variable<double>(grams.value);
    }
    if (sKcal100.present) {
      map['s_kcal100'] = Variable<double>(sKcal100.value);
    }
    if (sProtein100.present) {
      map['s_protein100'] = Variable<double>(sProtein100.value);
    }
    if (sCarb100.present) {
      map['s_carb100'] = Variable<double>(sCarb100.value);
    }
    if (sFat100.present) {
      map['s_fat100'] = Variable<double>(sFat100.value);
    }
    if (sMicrosJson.present) {
      map['s_micros_json'] = Variable<String>(sMicrosJson.value);
    }
    if (sortIndex.present) {
      map['sort_index'] = Variable<int>(sortIndex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeItemsCompanion(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('sName: $sName, ')
          ..write('grams: $grams, ')
          ..write('sKcal100: $sKcal100, ')
          ..write('sProtein100: $sProtein100, ')
          ..write('sCarb100: $sCarb100, ')
          ..write('sFat100: $sFat100, ')
          ..write('sMicrosJson: $sMicrosJson, ')
          ..write('sortIndex: $sortIndex')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String? value;
  const Setting({required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
    );
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
    };
  }

  Setting copyWith({
    String? key,
    Value<String?> value = const Value.absent(),
  }) => Setting(
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
  );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String?> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String?>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InstalledPacksTable extends InstalledPacks
    with TableInfo<$InstalledPacksTable, InstalledPack> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstalledPacksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productsMeta = const VerificationMeta(
    'products',
  );
  @override
  late final GeneratedColumn<int> products = GeneratedColumn<int>(
    'products',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _installedAtMeta = const VerificationMeta(
    'installedAt',
  );
  @override
  late final GeneratedColumn<DateTime> installedAt = GeneratedColumn<DateTime>(
    'installed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    code,
    name,
    version,
    products,
    sizeBytes,
    installedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'installed_packs';
  @override
  VerificationContext validateIntegrity(
    Insertable<InstalledPack> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('products')) {
      context.handle(
        _productsMeta,
        products.isAcceptableOrUnknown(data['products']!, _productsMeta),
      );
    } else if (isInserting) {
      context.missing(_productsMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('installed_at')) {
      context.handle(
        _installedAtMeta,
        installedAt.isAcceptableOrUnknown(
          data['installed_at']!,
          _installedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  InstalledPack map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InstalledPack(
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      )!,
      products: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}products'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      installedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}installed_at'],
      )!,
    );
  }

  @override
  $InstalledPacksTable createAlias(String alias) {
    return $InstalledPacksTable(attachedDatabase, alias);
  }
}

class InstalledPack extends DataClass implements Insertable<InstalledPack> {
  final String code;
  final String name;
  final String version;
  final int products;
  final int sizeBytes;
  final DateTime installedAt;
  const InstalledPack({
    required this.code,
    required this.name,
    required this.version,
    required this.products,
    required this.sizeBytes,
    required this.installedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['version'] = Variable<String>(version);
    map['products'] = Variable<int>(products);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['installed_at'] = Variable<DateTime>(installedAt);
    return map;
  }

  InstalledPacksCompanion toCompanion(bool nullToAbsent) {
    return InstalledPacksCompanion(
      code: Value(code),
      name: Value(name),
      version: Value(version),
      products: Value(products),
      sizeBytes: Value(sizeBytes),
      installedAt: Value(installedAt),
    );
  }

  factory InstalledPack.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InstalledPack(
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      version: serializer.fromJson<String>(json['version']),
      products: serializer.fromJson<int>(json['products']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      installedAt: serializer.fromJson<DateTime>(json['installedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'version': serializer.toJson<String>(version),
      'products': serializer.toJson<int>(products),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'installedAt': serializer.toJson<DateTime>(installedAt),
    };
  }

  InstalledPack copyWith({
    String? code,
    String? name,
    String? version,
    int? products,
    int? sizeBytes,
    DateTime? installedAt,
  }) => InstalledPack(
    code: code ?? this.code,
    name: name ?? this.name,
    version: version ?? this.version,
    products: products ?? this.products,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    installedAt: installedAt ?? this.installedAt,
  );
  InstalledPack copyWithCompanion(InstalledPacksCompanion data) {
    return InstalledPack(
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      version: data.version.present ? data.version.value : this.version,
      products: data.products.present ? data.products.value : this.products,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      installedAt: data.installedAt.present
          ? data.installedAt.value
          : this.installedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InstalledPack(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('version: $version, ')
          ..write('products: $products, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('installedAt: $installedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(code, name, version, products, sizeBytes, installedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InstalledPack &&
          other.code == this.code &&
          other.name == this.name &&
          other.version == this.version &&
          other.products == this.products &&
          other.sizeBytes == this.sizeBytes &&
          other.installedAt == this.installedAt);
}

class InstalledPacksCompanion extends UpdateCompanion<InstalledPack> {
  final Value<String> code;
  final Value<String> name;
  final Value<String> version;
  final Value<int> products;
  final Value<int> sizeBytes;
  final Value<DateTime> installedAt;
  final Value<int> rowid;
  const InstalledPacksCompanion({
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.version = const Value.absent(),
    this.products = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InstalledPacksCompanion.insert({
    required String code,
    required String name,
    required String version,
    required int products,
    required int sizeBytes,
    this.installedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       name = Value(name),
       version = Value(version),
       products = Value(products),
       sizeBytes = Value(sizeBytes);
  static Insertable<InstalledPack> custom({
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? version,
    Expression<int>? products,
    Expression<int>? sizeBytes,
    Expression<DateTime>? installedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (version != null) 'version': version,
      if (products != null) 'products': products,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (installedAt != null) 'installed_at': installedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InstalledPacksCompanion copyWith({
    Value<String>? code,
    Value<String>? name,
    Value<String>? version,
    Value<int>? products,
    Value<int>? sizeBytes,
    Value<DateTime>? installedAt,
    Value<int>? rowid,
  }) {
    return InstalledPacksCompanion(
      code: code ?? this.code,
      name: name ?? this.name,
      version: version ?? this.version,
      products: products ?? this.products,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      installedAt: installedAt ?? this.installedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (products.present) {
      map['products'] = Variable<int>(products.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (installedAt.present) {
      map['installed_at'] = Variable<DateTime>(installedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InstalledPacksCompanion(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('version: $version, ')
          ..write('products: $products, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('installedAt: $installedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OcrMappingsTable extends OcrMappings
    with TableInfo<$OcrMappingsTable, OcrMapping> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OcrMappingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  @override
  late final GeneratedColumn<int> foodId = GeneratedColumn<int>(
    'food_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES foods (id) ON DELETE CASCADE',
    ),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [normalizedName, foodId, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ocr_mappings';
  @override
  VerificationContext validateIntegrity(
    Insertable<OcrMapping> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('food_id')) {
      context.handle(
        _foodIdMeta,
        foodId.isAcceptableOrUnknown(data['food_id']!, _foodIdMeta),
      );
    } else if (isInserting) {
      context.missing(_foodIdMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {normalizedName};
  @override
  OcrMapping map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OcrMapping(
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      foodId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}food_id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $OcrMappingsTable createAlias(String alias) {
    return $OcrMappingsTable(attachedDatabase, alias);
  }
}

class OcrMapping extends DataClass implements Insertable<OcrMapping> {
  final String normalizedName;
  final int foodId;
  final DateTime updatedAt;
  const OcrMapping({
    required this.normalizedName,
    required this.foodId,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['normalized_name'] = Variable<String>(normalizedName);
    map['food_id'] = Variable<int>(foodId);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  OcrMappingsCompanion toCompanion(bool nullToAbsent) {
    return OcrMappingsCompanion(
      normalizedName: Value(normalizedName),
      foodId: Value(foodId),
      updatedAt: Value(updatedAt),
    );
  }

  factory OcrMapping.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OcrMapping(
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      foodId: serializer.fromJson<int>(json['foodId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'normalizedName': serializer.toJson<String>(normalizedName),
      'foodId': serializer.toJson<int>(foodId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  OcrMapping copyWith({
    String? normalizedName,
    int? foodId,
    DateTime? updatedAt,
  }) => OcrMapping(
    normalizedName: normalizedName ?? this.normalizedName,
    foodId: foodId ?? this.foodId,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  OcrMapping copyWithCompanion(OcrMappingsCompanion data) {
    return OcrMapping(
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OcrMapping(')
          ..write('normalizedName: $normalizedName, ')
          ..write('foodId: $foodId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(normalizedName, foodId, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OcrMapping &&
          other.normalizedName == this.normalizedName &&
          other.foodId == this.foodId &&
          other.updatedAt == this.updatedAt);
}

class OcrMappingsCompanion extends UpdateCompanion<OcrMapping> {
  final Value<String> normalizedName;
  final Value<int> foodId;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const OcrMappingsCompanion({
    this.normalizedName = const Value.absent(),
    this.foodId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OcrMappingsCompanion.insert({
    required String normalizedName,
    required int foodId,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : normalizedName = Value(normalizedName),
       foodId = Value(foodId);
  static Insertable<OcrMapping> custom({
    Expression<String>? normalizedName,
    Expression<int>? foodId,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (foodId != null) 'food_id': foodId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OcrMappingsCompanion copyWith({
    Value<String>? normalizedName,
    Value<int>? foodId,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return OcrMappingsCompanion(
      normalizedName: normalizedName ?? this.normalizedName,
      foodId: foodId ?? this.foodId,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (foodId.present) {
      map['food_id'] = Variable<int>(foodId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OcrMappingsCompanion(')
          ..write('normalizedName: $normalizedName, ')
          ..write('foodId: $foodId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FoodsTable foods = $FoodsTable(this);
  late final $EntryGroupsTable entryGroups = $EntryGroupsTable(this);
  late final $EntriesTable entries = $EntriesTable(this);
  late final $TargetsTable targets = $TargetsTable(this);
  late final $RecipesTable recipes = $RecipesTable(this);
  late final $RecipeItemsTable recipeItems = $RecipeItemsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $InstalledPacksTable installedPacks = $InstalledPacksTable(this);
  late final $OcrMappingsTable ocrMappings = $OcrMappingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    foods,
    entryGroups,
    entries,
    targets,
    recipes,
    recipeItems,
    settings,
    installedPacks,
    ocrMappings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'entry_groups',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'foods',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('entries', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'recipes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('recipe_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'foods',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('ocr_mappings', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$FoodsTableCreateCompanionBuilder =
    FoodsCompanion Function({
      Value<int> id,
      required FoodSource source,
      Value<String?> externalId,
      Value<String?> barcode,
      required String name,
      Value<String?> brand,
      Value<String?> locale,
      Value<double?> servingG,
      Value<String?> servingLabel,
      required double kcal100,
      Value<double?> protein100,
      Value<double?> carb100,
      Value<double?> fat100,
      Value<double?> fiber100,
      Value<double?> sugar100,
      Value<double?> satFat100,
      Value<double?> sodiumMg100,
      Value<double?> saltG100,
      Value<String?> microsJson,
      Value<bool> isFavorite,
      Value<int> usageCount,
      Value<DateTime> updatedAt,
    });
typedef $$FoodsTableUpdateCompanionBuilder =
    FoodsCompanion Function({
      Value<int> id,
      Value<FoodSource> source,
      Value<String?> externalId,
      Value<String?> barcode,
      Value<String> name,
      Value<String?> brand,
      Value<String?> locale,
      Value<double?> servingG,
      Value<String?> servingLabel,
      Value<double> kcal100,
      Value<double?> protein100,
      Value<double?> carb100,
      Value<double?> fat100,
      Value<double?> fiber100,
      Value<double?> sugar100,
      Value<double?> satFat100,
      Value<double?> sodiumMg100,
      Value<double?> saltG100,
      Value<String?> microsJson,
      Value<bool> isFavorite,
      Value<int> usageCount,
      Value<DateTime> updatedAt,
    });

final class $$FoodsTableReferences
    extends BaseReferences<_$AppDatabase, $FoodsTable, Food> {
  $$FoodsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EntriesTable, List<Entry>> _entriesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.entries,
    aliasName: 'foods__id__entries__food_id',
  );

  $$EntriesTableProcessedTableManager get entriesRefs {
    final manager = $$EntriesTableTableManager(
      $_db,
      $_db.entries,
    ).filter((f) => f.foodId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_entriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OcrMappingsTable, List<OcrMapping>>
  _ocrMappingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.ocrMappings,
    aliasName: 'foods__id__ocr_mappings__food_id',
  );

  $$OcrMappingsTableProcessedTableManager get ocrMappingsRefs {
    final manager = $$OcrMappingsTableTableManager(
      $_db,
      $_db.ocrMappings,
    ).filter((f) => f.foodId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ocrMappingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FoodsTableFilterComposer extends Composer<_$AppDatabase, $FoodsTable> {
  $$FoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<FoodSource, FoodSource, int> get source =>
      $composableBuilder(
        column: $table.source,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get servingG => $composableBuilder(
    column: $table.servingG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get servingLabel => $composableBuilder(
    column: $table.servingLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kcal100 => $composableBuilder(
    column: $table.kcal100,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get protein100 => $composableBuilder(
    column: $table.protein100,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carb100 => $composableBuilder(
    column: $table.carb100,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fat100 => $composableBuilder(
    column: $table.fat100,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fiber100 => $composableBuilder(
    column: $table.fiber100,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sugar100 => $composableBuilder(
    column: $table.sugar100,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get satFat100 => $composableBuilder(
    column: $table.satFat100,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sodiumMg100 => $composableBuilder(
    column: $table.sodiumMg100,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get saltG100 => $composableBuilder(
    column: $table.saltG100,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get microsJson => $composableBuilder(
    column: $table.microsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> entriesRefs(
    Expression<bool> Function($$EntriesTableFilterComposer f) f,
  ) {
    final $$EntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.foodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableFilterComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ocrMappingsRefs(
    Expression<bool> Function($$OcrMappingsTableFilterComposer f) f,
  ) {
    final $$OcrMappingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ocrMappings,
      getReferencedColumn: (t) => t.foodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OcrMappingsTableFilterComposer(
            $db: $db,
            $table: $db.ocrMappings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoodsTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodsTable> {
  $$FoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get servingG => $composableBuilder(
    column: $table.servingG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get servingLabel => $composableBuilder(
    column: $table.servingLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kcal100 => $composableBuilder(
    column: $table.kcal100,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get protein100 => $composableBuilder(
    column: $table.protein100,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carb100 => $composableBuilder(
    column: $table.carb100,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fat100 => $composableBuilder(
    column: $table.fat100,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fiber100 => $composableBuilder(
    column: $table.fiber100,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sugar100 => $composableBuilder(
    column: $table.sugar100,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get satFat100 => $composableBuilder(
    column: $table.satFat100,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sodiumMg100 => $composableBuilder(
    column: $table.sodiumMg100,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get saltG100 => $composableBuilder(
    column: $table.saltG100,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get microsJson => $composableBuilder(
    column: $table.microsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodsTable> {
  $$FoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FoodSource, int> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<double> get servingG =>
      $composableBuilder(column: $table.servingG, builder: (column) => column);

  GeneratedColumn<String> get servingLabel => $composableBuilder(
    column: $table.servingLabel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get kcal100 =>
      $composableBuilder(column: $table.kcal100, builder: (column) => column);

  GeneratedColumn<double> get protein100 => $composableBuilder(
    column: $table.protein100,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carb100 =>
      $composableBuilder(column: $table.carb100, builder: (column) => column);

  GeneratedColumn<double> get fat100 =>
      $composableBuilder(column: $table.fat100, builder: (column) => column);

  GeneratedColumn<double> get fiber100 =>
      $composableBuilder(column: $table.fiber100, builder: (column) => column);

  GeneratedColumn<double> get sugar100 =>
      $composableBuilder(column: $table.sugar100, builder: (column) => column);

  GeneratedColumn<double> get satFat100 =>
      $composableBuilder(column: $table.satFat100, builder: (column) => column);

  GeneratedColumn<double> get sodiumMg100 => $composableBuilder(
    column: $table.sodiumMg100,
    builder: (column) => column,
  );

  GeneratedColumn<double> get saltG100 =>
      $composableBuilder(column: $table.saltG100, builder: (column) => column);

  GeneratedColumn<String> get microsJson => $composableBuilder(
    column: $table.microsJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> entriesRefs<T extends Object>(
    Expression<T> Function($$EntriesTableAnnotationComposer a) f,
  ) {
    final $$EntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.foodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> ocrMappingsRefs<T extends Object>(
    Expression<T> Function($$OcrMappingsTableAnnotationComposer a) f,
  ) {
    final $$OcrMappingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ocrMappings,
      getReferencedColumn: (t) => t.foodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OcrMappingsTableAnnotationComposer(
            $db: $db,
            $table: $db.ocrMappings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoodsTable,
          Food,
          $$FoodsTableFilterComposer,
          $$FoodsTableOrderingComposer,
          $$FoodsTableAnnotationComposer,
          $$FoodsTableCreateCompanionBuilder,
          $$FoodsTableUpdateCompanionBuilder,
          (Food, $$FoodsTableReferences),
          Food,
          PrefetchHooks Function({bool entriesRefs, bool ocrMappingsRefs})
        > {
  $$FoodsTableTableManager(_$AppDatabase db, $FoodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<FoodSource> source = const Value.absent(),
                Value<String?> externalId = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String?> locale = const Value.absent(),
                Value<double?> servingG = const Value.absent(),
                Value<String?> servingLabel = const Value.absent(),
                Value<double> kcal100 = const Value.absent(),
                Value<double?> protein100 = const Value.absent(),
                Value<double?> carb100 = const Value.absent(),
                Value<double?> fat100 = const Value.absent(),
                Value<double?> fiber100 = const Value.absent(),
                Value<double?> sugar100 = const Value.absent(),
                Value<double?> satFat100 = const Value.absent(),
                Value<double?> sodiumMg100 = const Value.absent(),
                Value<double?> saltG100 = const Value.absent(),
                Value<String?> microsJson = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> usageCount = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => FoodsCompanion(
                id: id,
                source: source,
                externalId: externalId,
                barcode: barcode,
                name: name,
                brand: brand,
                locale: locale,
                servingG: servingG,
                servingLabel: servingLabel,
                kcal100: kcal100,
                protein100: protein100,
                carb100: carb100,
                fat100: fat100,
                fiber100: fiber100,
                sugar100: sugar100,
                satFat100: satFat100,
                sodiumMg100: sodiumMg100,
                saltG100: saltG100,
                microsJson: microsJson,
                isFavorite: isFavorite,
                usageCount: usageCount,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required FoodSource source,
                Value<String?> externalId = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                required String name,
                Value<String?> brand = const Value.absent(),
                Value<String?> locale = const Value.absent(),
                Value<double?> servingG = const Value.absent(),
                Value<String?> servingLabel = const Value.absent(),
                required double kcal100,
                Value<double?> protein100 = const Value.absent(),
                Value<double?> carb100 = const Value.absent(),
                Value<double?> fat100 = const Value.absent(),
                Value<double?> fiber100 = const Value.absent(),
                Value<double?> sugar100 = const Value.absent(),
                Value<double?> satFat100 = const Value.absent(),
                Value<double?> sodiumMg100 = const Value.absent(),
                Value<double?> saltG100 = const Value.absent(),
                Value<String?> microsJson = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> usageCount = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => FoodsCompanion.insert(
                id: id,
                source: source,
                externalId: externalId,
                barcode: barcode,
                name: name,
                brand: brand,
                locale: locale,
                servingG: servingG,
                servingLabel: servingLabel,
                kcal100: kcal100,
                protein100: protein100,
                carb100: carb100,
                fat100: fat100,
                fiber100: fiber100,
                sugar100: sugar100,
                satFat100: satFat100,
                sodiumMg100: sodiumMg100,
                saltG100: saltG100,
                microsJson: microsJson,
                isFavorite: isFavorite,
                usageCount: usageCount,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$FoodsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({entriesRefs = false, ocrMappingsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (entriesRefs) db.entries,
                    if (ocrMappingsRefs) db.ocrMappings,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (entriesRefs)
                        await $_getPrefetchedData<Food, $FoodsTable, Entry>(
                          currentTable: table,
                          referencedTable: $$FoodsTableReferences
                              ._entriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FoodsTableReferences(db, table, p0).entriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.foodId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ocrMappingsRefs)
                        await $_getPrefetchedData<
                          Food,
                          $FoodsTable,
                          OcrMapping
                        >(
                          currentTable: table,
                          referencedTable: $$FoodsTableReferences
                              ._ocrMappingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FoodsTableReferences(
                                db,
                                table,
                                p0,
                              ).ocrMappingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.foodId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$FoodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoodsTable,
      Food,
      $$FoodsTableFilterComposer,
      $$FoodsTableOrderingComposer,
      $$FoodsTableAnnotationComposer,
      $$FoodsTableCreateCompanionBuilder,
      $$FoodsTableUpdateCompanionBuilder,
      (Food, $$FoodsTableReferences),
      Food,
      PrefetchHooks Function({bool entriesRefs, bool ocrMappingsRefs})
    >;
typedef $$EntryGroupsTableCreateCompanionBuilder =
    EntryGroupsCompanion Function({
      Value<int> id,
      required String day,
      required String name,
      Value<DateTime> createdAt,
    });
typedef $$EntryGroupsTableUpdateCompanionBuilder =
    EntryGroupsCompanion Function({
      Value<int> id,
      Value<String> day,
      Value<String> name,
      Value<DateTime> createdAt,
    });

final class $$EntryGroupsTableReferences
    extends BaseReferences<_$AppDatabase, $EntryGroupsTable, EntryGroup> {
  $$EntryGroupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EntriesTable, List<Entry>> _entriesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.entries,
    aliasName: 'entry_groups__id__entries__group_id',
  );

  $$EntriesTableProcessedTableManager get entriesRefs {
    final manager = $$EntriesTableTableManager(
      $_db,
      $_db.entries,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_entriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EntryGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $EntryGroupsTable> {
  $$EntryGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> entriesRefs(
    Expression<bool> Function($$EntriesTableFilterComposer f) f,
  ) {
    final $$EntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableFilterComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EntryGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $EntryGroupsTable> {
  $$EntryGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EntryGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntryGroupsTable> {
  $$EntryGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> entriesRefs<T extends Object>(
    Expression<T> Function($$EntriesTableAnnotationComposer a) f,
  ) {
    final $$EntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EntryGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntryGroupsTable,
          EntryGroup,
          $$EntryGroupsTableFilterComposer,
          $$EntryGroupsTableOrderingComposer,
          $$EntryGroupsTableAnnotationComposer,
          $$EntryGroupsTableCreateCompanionBuilder,
          $$EntryGroupsTableUpdateCompanionBuilder,
          (EntryGroup, $$EntryGroupsTableReferences),
          EntryGroup,
          PrefetchHooks Function({bool entriesRefs})
        > {
  $$EntryGroupsTableTableManager(_$AppDatabase db, $EntryGroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntryGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntryGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntryGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => EntryGroupsCompanion(
                id: id,
                day: day,
                name: name,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String day,
                required String name,
                Value<DateTime> createdAt = const Value.absent(),
              }) => EntryGroupsCompanion.insert(
                id: id,
                day: day,
                name: name,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EntryGroupsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({entriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (entriesRefs) db.entries],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (entriesRefs)
                    await $_getPrefetchedData<
                      EntryGroup,
                      $EntryGroupsTable,
                      Entry
                    >(
                      currentTable: table,
                      referencedTable: $$EntryGroupsTableReferences
                          ._entriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$EntryGroupsTableReferences(
                            db,
                            table,
                            p0,
                          ).entriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.groupId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$EntryGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntryGroupsTable,
      EntryGroup,
      $$EntryGroupsTableFilterComposer,
      $$EntryGroupsTableOrderingComposer,
      $$EntryGroupsTableAnnotationComposer,
      $$EntryGroupsTableCreateCompanionBuilder,
      $$EntryGroupsTableUpdateCompanionBuilder,
      (EntryGroup, $$EntryGroupsTableReferences),
      EntryGroup,
      PrefetchHooks Function({bool entriesRefs})
    >;
typedef $$EntriesTableCreateCompanionBuilder =
    EntriesCompanion Function({
      Value<int> id,
      required String day,
      required MealType mealType,
      Value<int?> groupId,
      Value<int?> foodId,
      required double grams,
      required String sName,
      required double sKcal100,
      Value<double?> sProtein100,
      Value<double?> sCarb100,
      Value<double?> sFat100,
      Value<String?> sMicrosJson,
      Value<int> sortIndex,
      Value<DateTime> createdAt,
    });
typedef $$EntriesTableUpdateCompanionBuilder =
    EntriesCompanion Function({
      Value<int> id,
      Value<String> day,
      Value<MealType> mealType,
      Value<int?> groupId,
      Value<int?> foodId,
      Value<double> grams,
      Value<String> sName,
      Value<double> sKcal100,
      Value<double?> sProtein100,
      Value<double?> sCarb100,
      Value<double?> sFat100,
      Value<String?> sMicrosJson,
      Value<int> sortIndex,
      Value<DateTime> createdAt,
    });

final class $$EntriesTableReferences
    extends BaseReferences<_$AppDatabase, $EntriesTable, Entry> {
  $$EntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EntryGroupsTable _groupIdTable(_$AppDatabase db) =>
      db.entryGroups.createAlias('entries__group_id__entry_groups__id');

  $$EntryGroupsTableProcessedTableManager? get groupId {
    final $_column = $_itemColumn<int>('group_id');
    if ($_column == null) return null;
    final manager = $$EntryGroupsTableTableManager(
      $_db,
      $_db.entryGroups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FoodsTable _foodIdTable(_$AppDatabase db) =>
      db.foods.createAlias('entries__food_id__foods__id');

  $$FoodsTableProcessedTableManager? get foodId {
    final $_column = $_itemColumn<int>('food_id');
    if ($_column == null) return null;
    final manager = $$FoodsTableTableManager(
      $_db,
      $_db.foods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_foodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EntriesTableFilterComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MealType, MealType, int> get mealType =>
      $composableBuilder(
        column: $table.mealType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sName => $composableBuilder(
    column: $table.sName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sKcal100 => $composableBuilder(
    column: $table.sKcal100,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sProtein100 => $composableBuilder(
    column: $table.sProtein100,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sCarb100 => $composableBuilder(
    column: $table.sCarb100,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sFat100 => $composableBuilder(
    column: $table.sFat100,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sMicrosJson => $composableBuilder(
    column: $table.sMicrosJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$EntryGroupsTableFilterComposer get groupId {
    final $$EntryGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.entryGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntryGroupsTableFilterComposer(
            $db: $db,
            $table: $db.entryGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FoodsTableFilterComposer get foodId {
    final $$FoodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableFilterComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mealType => $composableBuilder(
    column: $table.mealType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sName => $composableBuilder(
    column: $table.sName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sKcal100 => $composableBuilder(
    column: $table.sKcal100,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sProtein100 => $composableBuilder(
    column: $table.sProtein100,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sCarb100 => $composableBuilder(
    column: $table.sCarb100,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sFat100 => $composableBuilder(
    column: $table.sFat100,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sMicrosJson => $composableBuilder(
    column: $table.sMicrosJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$EntryGroupsTableOrderingComposer get groupId {
    final $$EntryGroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.entryGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntryGroupsTableOrderingComposer(
            $db: $db,
            $table: $db.entryGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FoodsTableOrderingComposer get foodId {
    final $$FoodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableOrderingComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MealType, int> get mealType =>
      $composableBuilder(column: $table.mealType, builder: (column) => column);

  GeneratedColumn<double> get grams =>
      $composableBuilder(column: $table.grams, builder: (column) => column);

  GeneratedColumn<String> get sName =>
      $composableBuilder(column: $table.sName, builder: (column) => column);

  GeneratedColumn<double> get sKcal100 =>
      $composableBuilder(column: $table.sKcal100, builder: (column) => column);

  GeneratedColumn<double> get sProtein100 => $composableBuilder(
    column: $table.sProtein100,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sCarb100 =>
      $composableBuilder(column: $table.sCarb100, builder: (column) => column);

  GeneratedColumn<double> get sFat100 =>
      $composableBuilder(column: $table.sFat100, builder: (column) => column);

  GeneratedColumn<String> get sMicrosJson => $composableBuilder(
    column: $table.sMicrosJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortIndex =>
      $composableBuilder(column: $table.sortIndex, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$EntryGroupsTableAnnotationComposer get groupId {
    final $$EntryGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.entryGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntryGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.entryGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FoodsTableAnnotationComposer get foodId {
    final $$FoodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableAnnotationComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntriesTable,
          Entry,
          $$EntriesTableFilterComposer,
          $$EntriesTableOrderingComposer,
          $$EntriesTableAnnotationComposer,
          $$EntriesTableCreateCompanionBuilder,
          $$EntriesTableUpdateCompanionBuilder,
          (Entry, $$EntriesTableReferences),
          Entry,
          PrefetchHooks Function({bool groupId, bool foodId})
        > {
  $$EntriesTableTableManager(_$AppDatabase db, $EntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<MealType> mealType = const Value.absent(),
                Value<int?> groupId = const Value.absent(),
                Value<int?> foodId = const Value.absent(),
                Value<double> grams = const Value.absent(),
                Value<String> sName = const Value.absent(),
                Value<double> sKcal100 = const Value.absent(),
                Value<double?> sProtein100 = const Value.absent(),
                Value<double?> sCarb100 = const Value.absent(),
                Value<double?> sFat100 = const Value.absent(),
                Value<String?> sMicrosJson = const Value.absent(),
                Value<int> sortIndex = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => EntriesCompanion(
                id: id,
                day: day,
                mealType: mealType,
                groupId: groupId,
                foodId: foodId,
                grams: grams,
                sName: sName,
                sKcal100: sKcal100,
                sProtein100: sProtein100,
                sCarb100: sCarb100,
                sFat100: sFat100,
                sMicrosJson: sMicrosJson,
                sortIndex: sortIndex,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String day,
                required MealType mealType,
                Value<int?> groupId = const Value.absent(),
                Value<int?> foodId = const Value.absent(),
                required double grams,
                required String sName,
                required double sKcal100,
                Value<double?> sProtein100 = const Value.absent(),
                Value<double?> sCarb100 = const Value.absent(),
                Value<double?> sFat100 = const Value.absent(),
                Value<String?> sMicrosJson = const Value.absent(),
                Value<int> sortIndex = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => EntriesCompanion.insert(
                id: id,
                day: day,
                mealType: mealType,
                groupId: groupId,
                foodId: foodId,
                grams: grams,
                sName: sName,
                sKcal100: sKcal100,
                sProtein100: sProtein100,
                sCarb100: sCarb100,
                sFat100: sFat100,
                sMicrosJson: sMicrosJson,
                sortIndex: sortIndex,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({groupId = false, foodId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (groupId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.groupId,
                                referencedTable: $$EntriesTableReferences
                                    ._groupIdTable(db),
                                referencedColumn: $$EntriesTableReferences
                                    ._groupIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (foodId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.foodId,
                                referencedTable: $$EntriesTableReferences
                                    ._foodIdTable(db),
                                referencedColumn: $$EntriesTableReferences
                                    ._foodIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntriesTable,
      Entry,
      $$EntriesTableFilterComposer,
      $$EntriesTableOrderingComposer,
      $$EntriesTableAnnotationComposer,
      $$EntriesTableCreateCompanionBuilder,
      $$EntriesTableUpdateCompanionBuilder,
      (Entry, $$EntriesTableReferences),
      Entry,
      PrefetchHooks Function({bool groupId, bool foodId})
    >;
typedef $$TargetsTableCreateCompanionBuilder =
    TargetsCompanion Function({
      Value<int> weekday,
      Value<double?> kcal,
      Value<double?> kcalMin,
      Value<double?> kcalMax,
      Value<double?> protein,
      Value<double?> carb,
      Value<double?> fat,
    });
typedef $$TargetsTableUpdateCompanionBuilder =
    TargetsCompanion Function({
      Value<int> weekday,
      Value<double?> kcal,
      Value<double?> kcalMin,
      Value<double?> kcalMax,
      Value<double?> protein,
      Value<double?> carb,
      Value<double?> fat,
    });

class $$TargetsTableFilterComposer
    extends Composer<_$AppDatabase, $TargetsTable> {
  $$TargetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kcalMin => $composableBuilder(
    column: $table.kcalMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kcalMax => $composableBuilder(
    column: $table.kcalMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carb => $composableBuilder(
    column: $table.carb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TargetsTableOrderingComposer
    extends Composer<_$AppDatabase, $TargetsTable> {
  $$TargetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kcalMin => $composableBuilder(
    column: $table.kcalMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kcalMax => $composableBuilder(
    column: $table.kcalMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carb => $composableBuilder(
    column: $table.carb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TargetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TargetsTable> {
  $$TargetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get weekday =>
      $composableBuilder(column: $table.weekday, builder: (column) => column);

  GeneratedColumn<double> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => column);

  GeneratedColumn<double> get kcalMin =>
      $composableBuilder(column: $table.kcalMin, builder: (column) => column);

  GeneratedColumn<double> get kcalMax =>
      $composableBuilder(column: $table.kcalMax, builder: (column) => column);

  GeneratedColumn<double> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<double> get carb =>
      $composableBuilder(column: $table.carb, builder: (column) => column);

  GeneratedColumn<double> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => column);
}

class $$TargetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TargetsTable,
          Target,
          $$TargetsTableFilterComposer,
          $$TargetsTableOrderingComposer,
          $$TargetsTableAnnotationComposer,
          $$TargetsTableCreateCompanionBuilder,
          $$TargetsTableUpdateCompanionBuilder,
          (Target, BaseReferences<_$AppDatabase, $TargetsTable, Target>),
          Target,
          PrefetchHooks Function()
        > {
  $$TargetsTableTableManager(_$AppDatabase db, $TargetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TargetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TargetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TargetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> weekday = const Value.absent(),
                Value<double?> kcal = const Value.absent(),
                Value<double?> kcalMin = const Value.absent(),
                Value<double?> kcalMax = const Value.absent(),
                Value<double?> protein = const Value.absent(),
                Value<double?> carb = const Value.absent(),
                Value<double?> fat = const Value.absent(),
              }) => TargetsCompanion(
                weekday: weekday,
                kcal: kcal,
                kcalMin: kcalMin,
                kcalMax: kcalMax,
                protein: protein,
                carb: carb,
                fat: fat,
              ),
          createCompanionCallback:
              ({
                Value<int> weekday = const Value.absent(),
                Value<double?> kcal = const Value.absent(),
                Value<double?> kcalMin = const Value.absent(),
                Value<double?> kcalMax = const Value.absent(),
                Value<double?> protein = const Value.absent(),
                Value<double?> carb = const Value.absent(),
                Value<double?> fat = const Value.absent(),
              }) => TargetsCompanion.insert(
                weekday: weekday,
                kcal: kcal,
                kcalMin: kcalMin,
                kcalMax: kcalMax,
                protein: protein,
                carb: carb,
                fat: fat,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TargetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TargetsTable,
      Target,
      $$TargetsTableFilterComposer,
      $$TargetsTableOrderingComposer,
      $$TargetsTableAnnotationComposer,
      $$TargetsTableCreateCompanionBuilder,
      $$TargetsTableUpdateCompanionBuilder,
      (Target, BaseReferences<_$AppDatabase, $TargetsTable, Target>),
      Target,
      PrefetchHooks Function()
    >;
typedef $$RecipesTableCreateCompanionBuilder =
    RecipesCompanion Function({
      Value<int> id,
      required String name,
      Value<double> servings,
      Value<String?> note,
      Value<DateTime> createdAt,
    });
typedef $$RecipesTableUpdateCompanionBuilder =
    RecipesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<double> servings,
      Value<String?> note,
      Value<DateTime> createdAt,
    });

final class $$RecipesTableReferences
    extends BaseReferences<_$AppDatabase, $RecipesTable, Recipe> {
  $$RecipesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RecipeItemsTable, List<RecipeItem>>
  _recipeItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.recipeItems,
    aliasName: 'recipes__id__recipe_items__recipe_id',
  );

  $$RecipeItemsTableProcessedTableManager get recipeItemsRefs {
    final manager = $$RecipeItemsTableTableManager(
      $_db,
      $_db.recipeItems,
    ).filter((f) => f.recipeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_recipeItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RecipesTableFilterComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get servings => $composableBuilder(
    column: $table.servings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> recipeItemsRefs(
    Expression<bool> Function($$RecipeItemsTableFilterComposer f) f,
  ) {
    final $$RecipeItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recipeItems,
      getReferencedColumn: (t) => t.recipeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeItemsTableFilterComposer(
            $db: $db,
            $table: $db.recipeItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecipesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get servings => $composableBuilder(
    column: $table.servings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecipesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get servings =>
      $composableBuilder(column: $table.servings, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> recipeItemsRefs<T extends Object>(
    Expression<T> Function($$RecipeItemsTableAnnotationComposer a) f,
  ) {
    final $$RecipeItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recipeItems,
      getReferencedColumn: (t) => t.recipeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.recipeItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecipesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipesTable,
          Recipe,
          $$RecipesTableFilterComposer,
          $$RecipesTableOrderingComposer,
          $$RecipesTableAnnotationComposer,
          $$RecipesTableCreateCompanionBuilder,
          $$RecipesTableUpdateCompanionBuilder,
          (Recipe, $$RecipesTableReferences),
          Recipe,
          PrefetchHooks Function({bool recipeItemsRefs})
        > {
  $$RecipesTableTableManager(_$AppDatabase db, $RecipesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> servings = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RecipesCompanion(
                id: id,
                name: name,
                servings: servings,
                note: note,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<double> servings = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RecipesCompanion.insert(
                id: id,
                name: name,
                servings: servings,
                note: note,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecipesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({recipeItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (recipeItemsRefs) db.recipeItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (recipeItemsRefs)
                    await $_getPrefetchedData<
                      Recipe,
                      $RecipesTable,
                      RecipeItem
                    >(
                      currentTable: table,
                      referencedTable: $$RecipesTableReferences
                          ._recipeItemsRefsTable(db),
                      managerFromTypedResult: (p0) => $$RecipesTableReferences(
                        db,
                        table,
                        p0,
                      ).recipeItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.recipeId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RecipesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipesTable,
      Recipe,
      $$RecipesTableFilterComposer,
      $$RecipesTableOrderingComposer,
      $$RecipesTableAnnotationComposer,
      $$RecipesTableCreateCompanionBuilder,
      $$RecipesTableUpdateCompanionBuilder,
      (Recipe, $$RecipesTableReferences),
      Recipe,
      PrefetchHooks Function({bool recipeItemsRefs})
    >;
typedef $$RecipeItemsTableCreateCompanionBuilder =
    RecipeItemsCompanion Function({
      Value<int> id,
      required int recipeId,
      required String sName,
      required double grams,
      required double sKcal100,
      Value<double?> sProtein100,
      Value<double?> sCarb100,
      Value<double?> sFat100,
      Value<String?> sMicrosJson,
      Value<int> sortIndex,
    });
typedef $$RecipeItemsTableUpdateCompanionBuilder =
    RecipeItemsCompanion Function({
      Value<int> id,
      Value<int> recipeId,
      Value<String> sName,
      Value<double> grams,
      Value<double> sKcal100,
      Value<double?> sProtein100,
      Value<double?> sCarb100,
      Value<double?> sFat100,
      Value<String?> sMicrosJson,
      Value<int> sortIndex,
    });

final class $$RecipeItemsTableReferences
    extends BaseReferences<_$AppDatabase, $RecipeItemsTable, RecipeItem> {
  $$RecipeItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RecipesTable _recipeIdTable(_$AppDatabase db) =>
      db.recipes.createAlias('recipe_items__recipe_id__recipes__id');

  $$RecipesTableProcessedTableManager get recipeId {
    final $_column = $_itemColumn<int>('recipe_id')!;

    final manager = $$RecipesTableTableManager(
      $_db,
      $_db.recipes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recipeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecipeItemsTableFilterComposer
    extends Composer<_$AppDatabase, $RecipeItemsTable> {
  $$RecipeItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sName => $composableBuilder(
    column: $table.sName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sKcal100 => $composableBuilder(
    column: $table.sKcal100,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sProtein100 => $composableBuilder(
    column: $table.sProtein100,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sCarb100 => $composableBuilder(
    column: $table.sCarb100,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sFat100 => $composableBuilder(
    column: $table.sFat100,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sMicrosJson => $composableBuilder(
    column: $table.sMicrosJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnFilters(column),
  );

  $$RecipesTableFilterComposer get recipeId {
    final $$RecipesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableFilterComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipeItemsTable> {
  $$RecipeItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sName => $composableBuilder(
    column: $table.sName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sKcal100 => $composableBuilder(
    column: $table.sKcal100,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sProtein100 => $composableBuilder(
    column: $table.sProtein100,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sCarb100 => $composableBuilder(
    column: $table.sCarb100,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sFat100 => $composableBuilder(
    column: $table.sFat100,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sMicrosJson => $composableBuilder(
    column: $table.sMicrosJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnOrderings(column),
  );

  $$RecipesTableOrderingComposer get recipeId {
    final $$RecipesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableOrderingComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipeItemsTable> {
  $$RecipeItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sName =>
      $composableBuilder(column: $table.sName, builder: (column) => column);

  GeneratedColumn<double> get grams =>
      $composableBuilder(column: $table.grams, builder: (column) => column);

  GeneratedColumn<double> get sKcal100 =>
      $composableBuilder(column: $table.sKcal100, builder: (column) => column);

  GeneratedColumn<double> get sProtein100 => $composableBuilder(
    column: $table.sProtein100,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sCarb100 =>
      $composableBuilder(column: $table.sCarb100, builder: (column) => column);

  GeneratedColumn<double> get sFat100 =>
      $composableBuilder(column: $table.sFat100, builder: (column) => column);

  GeneratedColumn<String> get sMicrosJson => $composableBuilder(
    column: $table.sMicrosJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortIndex =>
      $composableBuilder(column: $table.sortIndex, builder: (column) => column);

  $$RecipesTableAnnotationComposer get recipeId {
    final $$RecipesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableAnnotationComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipeItemsTable,
          RecipeItem,
          $$RecipeItemsTableFilterComposer,
          $$RecipeItemsTableOrderingComposer,
          $$RecipeItemsTableAnnotationComposer,
          $$RecipeItemsTableCreateCompanionBuilder,
          $$RecipeItemsTableUpdateCompanionBuilder,
          (RecipeItem, $$RecipeItemsTableReferences),
          RecipeItem,
          PrefetchHooks Function({bool recipeId})
        > {
  $$RecipeItemsTableTableManager(_$AppDatabase db, $RecipeItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipeItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipeItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipeItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> recipeId = const Value.absent(),
                Value<String> sName = const Value.absent(),
                Value<double> grams = const Value.absent(),
                Value<double> sKcal100 = const Value.absent(),
                Value<double?> sProtein100 = const Value.absent(),
                Value<double?> sCarb100 = const Value.absent(),
                Value<double?> sFat100 = const Value.absent(),
                Value<String?> sMicrosJson = const Value.absent(),
                Value<int> sortIndex = const Value.absent(),
              }) => RecipeItemsCompanion(
                id: id,
                recipeId: recipeId,
                sName: sName,
                grams: grams,
                sKcal100: sKcal100,
                sProtein100: sProtein100,
                sCarb100: sCarb100,
                sFat100: sFat100,
                sMicrosJson: sMicrosJson,
                sortIndex: sortIndex,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int recipeId,
                required String sName,
                required double grams,
                required double sKcal100,
                Value<double?> sProtein100 = const Value.absent(),
                Value<double?> sCarb100 = const Value.absent(),
                Value<double?> sFat100 = const Value.absent(),
                Value<String?> sMicrosJson = const Value.absent(),
                Value<int> sortIndex = const Value.absent(),
              }) => RecipeItemsCompanion.insert(
                id: id,
                recipeId: recipeId,
                sName: sName,
                grams: grams,
                sKcal100: sKcal100,
                sProtein100: sProtein100,
                sCarb100: sCarb100,
                sFat100: sFat100,
                sMicrosJson: sMicrosJson,
                sortIndex: sortIndex,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecipeItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({recipeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (recipeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.recipeId,
                                referencedTable: $$RecipeItemsTableReferences
                                    ._recipeIdTable(db),
                                referencedColumn: $$RecipeItemsTableReferences
                                    ._recipeIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RecipeItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipeItemsTable,
      RecipeItem,
      $$RecipeItemsTableFilterComposer,
      $$RecipeItemsTableOrderingComposer,
      $$RecipeItemsTableAnnotationComposer,
      $$RecipeItemsTableCreateCompanionBuilder,
      $$RecipeItemsTableUpdateCompanionBuilder,
      (RecipeItem, $$RecipeItemsTableReferences),
      RecipeItem,
      PrefetchHooks Function({bool recipeId})
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      required String key,
      Value<String?> value,
      Value<int> rowid,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> key,
      Value<String?> value,
      Value<int> rowid,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $$InstalledPacksTableCreateCompanionBuilder =
    InstalledPacksCompanion Function({
      required String code,
      required String name,
      required String version,
      required int products,
      required int sizeBytes,
      Value<DateTime> installedAt,
      Value<int> rowid,
    });
typedef $$InstalledPacksTableUpdateCompanionBuilder =
    InstalledPacksCompanion Function({
      Value<String> code,
      Value<String> name,
      Value<String> version,
      Value<int> products,
      Value<int> sizeBytes,
      Value<DateTime> installedAt,
      Value<int> rowid,
    });

class $$InstalledPacksTableFilterComposer
    extends Composer<_$AppDatabase, $InstalledPacksTable> {
  $$InstalledPacksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get products => $composableBuilder(
    column: $table.products,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InstalledPacksTableOrderingComposer
    extends Composer<_$AppDatabase, $InstalledPacksTable> {
  $$InstalledPacksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get products => $composableBuilder(
    column: $table.products,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InstalledPacksTableAnnotationComposer
    extends Composer<_$AppDatabase, $InstalledPacksTable> {
  $$InstalledPacksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get products =>
      $composableBuilder(column: $table.products, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => column,
  );
}

class $$InstalledPacksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InstalledPacksTable,
          InstalledPack,
          $$InstalledPacksTableFilterComposer,
          $$InstalledPacksTableOrderingComposer,
          $$InstalledPacksTableAnnotationComposer,
          $$InstalledPacksTableCreateCompanionBuilder,
          $$InstalledPacksTableUpdateCompanionBuilder,
          (
            InstalledPack,
            BaseReferences<_$AppDatabase, $InstalledPacksTable, InstalledPack>,
          ),
          InstalledPack,
          PrefetchHooks Function()
        > {
  $$InstalledPacksTableTableManager(
    _$AppDatabase db,
    $InstalledPacksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InstalledPacksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InstalledPacksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InstalledPacksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> version = const Value.absent(),
                Value<int> products = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<DateTime> installedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstalledPacksCompanion(
                code: code,
                name: name,
                version: version,
                products: products,
                sizeBytes: sizeBytes,
                installedAt: installedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String code,
                required String name,
                required String version,
                required int products,
                required int sizeBytes,
                Value<DateTime> installedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstalledPacksCompanion.insert(
                code: code,
                name: name,
                version: version,
                products: products,
                sizeBytes: sizeBytes,
                installedAt: installedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InstalledPacksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InstalledPacksTable,
      InstalledPack,
      $$InstalledPacksTableFilterComposer,
      $$InstalledPacksTableOrderingComposer,
      $$InstalledPacksTableAnnotationComposer,
      $$InstalledPacksTableCreateCompanionBuilder,
      $$InstalledPacksTableUpdateCompanionBuilder,
      (
        InstalledPack,
        BaseReferences<_$AppDatabase, $InstalledPacksTable, InstalledPack>,
      ),
      InstalledPack,
      PrefetchHooks Function()
    >;
typedef $$OcrMappingsTableCreateCompanionBuilder =
    OcrMappingsCompanion Function({
      required String normalizedName,
      required int foodId,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$OcrMappingsTableUpdateCompanionBuilder =
    OcrMappingsCompanion Function({
      Value<String> normalizedName,
      Value<int> foodId,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$OcrMappingsTableReferences
    extends BaseReferences<_$AppDatabase, $OcrMappingsTable, OcrMapping> {
  $$OcrMappingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FoodsTable _foodIdTable(_$AppDatabase db) =>
      db.foods.createAlias('ocr_mappings__food_id__foods__id');

  $$FoodsTableProcessedTableManager get foodId {
    final $_column = $_itemColumn<int>('food_id')!;

    final manager = $$FoodsTableTableManager(
      $_db,
      $_db.foods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_foodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$OcrMappingsTableFilterComposer
    extends Composer<_$AppDatabase, $OcrMappingsTable> {
  $$OcrMappingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FoodsTableFilterComposer get foodId {
    final $$FoodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableFilterComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OcrMappingsTableOrderingComposer
    extends Composer<_$AppDatabase, $OcrMappingsTable> {
  $$OcrMappingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FoodsTableOrderingComposer get foodId {
    final $$FoodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableOrderingComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OcrMappingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OcrMappingsTable> {
  $$OcrMappingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$FoodsTableAnnotationComposer get foodId {
    final $$FoodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableAnnotationComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OcrMappingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OcrMappingsTable,
          OcrMapping,
          $$OcrMappingsTableFilterComposer,
          $$OcrMappingsTableOrderingComposer,
          $$OcrMappingsTableAnnotationComposer,
          $$OcrMappingsTableCreateCompanionBuilder,
          $$OcrMappingsTableUpdateCompanionBuilder,
          (OcrMapping, $$OcrMappingsTableReferences),
          OcrMapping,
          PrefetchHooks Function({bool foodId})
        > {
  $$OcrMappingsTableTableManager(_$AppDatabase db, $OcrMappingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OcrMappingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OcrMappingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OcrMappingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> normalizedName = const Value.absent(),
                Value<int> foodId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OcrMappingsCompanion(
                normalizedName: normalizedName,
                foodId: foodId,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String normalizedName,
                required int foodId,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OcrMappingsCompanion.insert(
                normalizedName: normalizedName,
                foodId: foodId,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OcrMappingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({foodId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (foodId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.foodId,
                                referencedTable: $$OcrMappingsTableReferences
                                    ._foodIdTable(db),
                                referencedColumn: $$OcrMappingsTableReferences
                                    ._foodIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$OcrMappingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OcrMappingsTable,
      OcrMapping,
      $$OcrMappingsTableFilterComposer,
      $$OcrMappingsTableOrderingComposer,
      $$OcrMappingsTableAnnotationComposer,
      $$OcrMappingsTableCreateCompanionBuilder,
      $$OcrMappingsTableUpdateCompanionBuilder,
      (OcrMapping, $$OcrMappingsTableReferences),
      OcrMapping,
      PrefetchHooks Function({bool foodId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FoodsTableTableManager get foods =>
      $$FoodsTableTableManager(_db, _db.foods);
  $$EntryGroupsTableTableManager get entryGroups =>
      $$EntryGroupsTableTableManager(_db, _db.entryGroups);
  $$EntriesTableTableManager get entries =>
      $$EntriesTableTableManager(_db, _db.entries);
  $$TargetsTableTableManager get targets =>
      $$TargetsTableTableManager(_db, _db.targets);
  $$RecipesTableTableManager get recipes =>
      $$RecipesTableTableManager(_db, _db.recipes);
  $$RecipeItemsTableTableManager get recipeItems =>
      $$RecipeItemsTableTableManager(_db, _db.recipeItems);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$InstalledPacksTableTableManager get installedPacks =>
      $$InstalledPacksTableTableManager(_db, _db.installedPacks);
  $$OcrMappingsTableTableManager get ocrMappings =>
      $$OcrMappingsTableTableManager(_db, _db.ocrMappings);
}
