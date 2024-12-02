// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'recipe.dart';

class CookStyleMapper extends EnumMapper<CookStyle> {
  CookStyleMapper._();

  static CookStyleMapper? _instance;
  static CookStyleMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CookStyleMapper._());
    }
    return _instance!;
  }

  static CookStyle fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  CookStyle decode(dynamic value) {
    switch (value) {
      case 'bake':
        return CookStyle.bake;
      case 'fry':
        return CookStyle.fry;
      case 'boil':
        return CookStyle.boil;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(CookStyle self) {
    switch (self) {
      case CookStyle.bake:
        return 'bake';
      case CookStyle.fry:
        return 'fry';
      case CookStyle.boil:
        return 'boil';
    }
  }
}

extension CookStyleMapperExtension on CookStyle {
  String toValue() {
    CookStyleMapper.ensureInitialized();
    return MapperContainer.globals.toValue<CookStyle>(this) as String;
  }
}

class RecipeMapper extends ClassMapperBase<Recipe> {
  RecipeMapper._();

  static RecipeMapper? _instance;
  static RecipeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = RecipeMapper._());
      IngredientsMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Recipe';

  static String _$id(Recipe v) => v.id;
  static const Field<Recipe, String> _f$id = Field('id', _$id);
  static String _$name(Recipe v) => v.name;
  static const Field<Recipe, String> _f$name = Field('name', _$name);
  static List<Ingredients>? _$ingredients(Recipe v) => v.ingredients;
  static const Field<Recipe, List<Ingredients>> _f$ingredients =
      Field('ingredients', _$ingredients, opt: true);

  @override
  final MappableFields<Recipe> fields = const {
    #id: _f$id,
    #name: _f$name,
    #ingredients: _f$ingredients,
  };

  static Recipe _instantiate(DecodingData data) {
    return Recipe(
        id: data.dec(_f$id),
        name: data.dec(_f$name),
        ingredients: data.dec(_f$ingredients));
  }

  @override
  final Function instantiate = _instantiate;

  static Recipe fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Recipe>(map);
  }

  static Recipe fromJson(String json) {
    return ensureInitialized().decodeJson<Recipe>(json);
  }
}

mixin RecipeMappable {
  String toJson() {
    return RecipeMapper.ensureInitialized().encodeJson<Recipe>(this as Recipe);
  }

  Map<String, dynamic> toMap() {
    return RecipeMapper.ensureInitialized().encodeMap<Recipe>(this as Recipe);
  }

  RecipeCopyWith<Recipe, Recipe, Recipe> get copyWith =>
      _RecipeCopyWithImpl(this as Recipe, $identity, $identity);
  @override
  String toString() {
    return RecipeMapper.ensureInitialized().stringifyValue(this as Recipe);
  }

  @override
  bool operator ==(Object other) {
    return RecipeMapper.ensureInitialized().equalsValue(this as Recipe, other);
  }

  @override
  int get hashCode {
    return RecipeMapper.ensureInitialized().hashValue(this as Recipe);
  }
}

extension RecipeValueCopy<$R, $Out> on ObjectCopyWith<$R, Recipe, $Out> {
  RecipeCopyWith<$R, Recipe, $Out> get $asRecipe =>
      $base.as((v, t, t2) => _RecipeCopyWithImpl(v, t, t2));
}

abstract class RecipeCopyWith<$R, $In extends Recipe, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, Ingredients,
      IngredientsCopyWith<$R, Ingredients, Ingredients>>? get ingredients;
  $R call({String? id, String? name, List<Ingredients>? ingredients});
  RecipeCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _RecipeCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Recipe, $Out>
    implements RecipeCopyWith<$R, Recipe, $Out> {
  _RecipeCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Recipe> $mapper = RecipeMapper.ensureInitialized();
  @override
  ListCopyWith<$R, Ingredients,
          IngredientsCopyWith<$R, Ingredients, Ingredients>>?
      get ingredients => $value.ingredients != null
          ? ListCopyWith($value.ingredients!, (v, t) => v.copyWith.$chain(t),
              (v) => call(ingredients: v))
          : null;
  @override
  $R call({String? id, String? name, Object? ingredients = $none}) =>
      $apply(FieldCopyWithData({
        if (id != null) #id: id,
        if (name != null) #name: name,
        if (ingredients != $none) #ingredients: ingredients
      }));
  @override
  Recipe $make(CopyWithData data) => Recipe(
      id: data.get(#id, or: $value.id),
      name: data.get(#name, or: $value.name),
      ingredients: data.get(#ingredients, or: $value.ingredients));

  @override
  RecipeCopyWith<$R2, Recipe, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _RecipeCopyWithImpl($value, $cast, t);
}

class IngredientsMapper extends ClassMapperBase<Ingredients> {
  IngredientsMapper._();

  static IngredientsMapper? _instance;
  static IngredientsMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = IngredientsMapper._());
      CookStyleMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Ingredients';

  static String _$name(Ingredients v) => v.name;
  static const Field<Ingredients, String> _f$name = Field('name', _$name);
  static int? _$quantity(Ingredients v) => v.quantity;
  static const Field<Ingredients, int> _f$quantity =
      Field('quantity', _$quantity, opt: true);
  static CookStyle _$cookStyle(Ingredients v) => v.cookStyle;
  static const Field<Ingredients, CookStyle> _f$cookStyle =
      Field('cookStyle', _$cookStyle);

  @override
  final MappableFields<Ingredients> fields = const {
    #name: _f$name,
    #quantity: _f$quantity,
    #cookStyle: _f$cookStyle,
  };

  static Ingredients _instantiate(DecodingData data) {
    return Ingredients(
        name: data.dec(_f$name),
        quantity: data.dec(_f$quantity),
        cookStyle: data.dec(_f$cookStyle));
  }

  @override
  final Function instantiate = _instantiate;

  static Ingredients fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Ingredients>(map);
  }

  static Ingredients fromJson(String json) {
    return ensureInitialized().decodeJson<Ingredients>(json);
  }
}

mixin IngredientsMappable {
  String toJson() {
    return IngredientsMapper.ensureInitialized()
        .encodeJson<Ingredients>(this as Ingredients);
  }

  Map<String, dynamic> toMap() {
    return IngredientsMapper.ensureInitialized()
        .encodeMap<Ingredients>(this as Ingredients);
  }

  IngredientsCopyWith<Ingredients, Ingredients, Ingredients> get copyWith =>
      _IngredientsCopyWithImpl(this as Ingredients, $identity, $identity);
  @override
  String toString() {
    return IngredientsMapper.ensureInitialized()
        .stringifyValue(this as Ingredients);
  }

  @override
  bool operator ==(Object other) {
    return IngredientsMapper.ensureInitialized()
        .equalsValue(this as Ingredients, other);
  }

  @override
  int get hashCode {
    return IngredientsMapper.ensureInitialized().hashValue(this as Ingredients);
  }
}

extension IngredientsValueCopy<$R, $Out>
    on ObjectCopyWith<$R, Ingredients, $Out> {
  IngredientsCopyWith<$R, Ingredients, $Out> get $asIngredients =>
      $base.as((v, t, t2) => _IngredientsCopyWithImpl(v, t, t2));
}

abstract class IngredientsCopyWith<$R, $In extends Ingredients, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? name, int? quantity, CookStyle? cookStyle});
  IngredientsCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _IngredientsCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Ingredients, $Out>
    implements IngredientsCopyWith<$R, Ingredients, $Out> {
  _IngredientsCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Ingredients> $mapper =
      IngredientsMapper.ensureInitialized();
  @override
  $R call({String? name, Object? quantity = $none, CookStyle? cookStyle}) =>
      $apply(FieldCopyWithData({
        if (name != null) #name: name,
        if (quantity != $none) #quantity: quantity,
        if (cookStyle != null) #cookStyle: cookStyle
      }));
  @override
  Ingredients $make(CopyWithData data) => Ingredients(
      name: data.get(#name, or: $value.name),
      quantity: data.get(#quantity, or: $value.quantity),
      cookStyle: data.get(#cookStyle, or: $value.cookStyle));

  @override
  IngredientsCopyWith<$R2, Ingredients, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _IngredientsCopyWithImpl($value, $cast, t);
}
