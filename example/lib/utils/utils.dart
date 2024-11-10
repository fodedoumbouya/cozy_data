class AutoIncrementer {
  int _currentId = 0;
  AutoIncrementer init(int? initialId) {
    _currentId = initialId ?? 0;
    return this;
  }

  int getNextId() {
    _currentId++;
    return _currentId;
  }
}
