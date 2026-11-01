abstract class BaseMapper<TSource, TTarget> {
  TTarget convert(TSource obj);

  TSource convertBack(TTarget obj);

  List<TTarget> convertAll(List<TSource>? obj) {
    if (obj == null || obj.isEmpty) return [];

    return obj.map(convert).toList();
  }

  List<TSource> convertAllBack(List<TTarget>? obj) {
    if (obj == null || obj.isEmpty) return [];

    return obj.map(convertBack).toList();
  }
}
