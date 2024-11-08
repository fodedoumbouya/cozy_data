import 'package:cozy_data/cozy_data.dart';

part 'programmer.g.dart';

@collection
class Programmer {
  final int id;

  String name;
  String? language;
  List<FavoriteLanguage>? favoriteLanguages;

  Programmer(
      {required this.id,
      required this.name,
      this.language,
      this.favoriteLanguages});
}

@embedded
class FavoriteLanguage {
  String? language;
  String? framework;
}
