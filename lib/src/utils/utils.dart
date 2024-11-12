import 'package:cozy_data/cozy_data.dart';

class Utils {
  static final Map<String, bool> _idsTypeInt = {};
  //make it singleton
  Utils._();
  static final Utils instance = Utils._();

  factory Utils() => instance;

  static Future<void> idsTypeIsInt({required Isar isar}) async {
    for (var i = 0; i < isar.schemas.length; i++) {}
    for (var schema in isar.schemas) {
      if (schema.embedded) {
        continue;
      }
      final idType = schema.properties
          .firstWhere((element) => element.name == 'id',
              orElse: () => schema.getPropertyByIndex(0))
          .type;
      if (idType.isInt) {
        _idsTypeInt[schema.name] = true;
      } else if (idType.isString) {
        _idsTypeInt[schema.name] = false;
      }
    }
    return;
  }

  static Future<bool> getIdIsInit<T>() async {
    final resp = _idsTypeInt[T.toString()];
    if (resp == null) {
      throw Exception(
          "Id type of ${T.toString()} not found. Please make sure the schema is registered in the Isar instance. And the id property is int or string");
    } else {
      return resp;
    }
  }
}
