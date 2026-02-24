Map<String, int> countByFirstChar(List<String> values) {
  final result = <String, int>{};
  for (final v in values) {
    if (v.isEmpty) continue;
    final k = v[0];
    result[k] = (result[k] ?? 0) + 1;
  }
  return result;
}
