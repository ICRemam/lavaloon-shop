import 'package:lavaloon_assessment/data/constants/app_constants.dart';

class GetProductsParams {
  final int skip;
  final int limit;
  final String? query;
  final String? categorySlug;

  const GetProductsParams({this.skip = 0, this.limit = AppConstants.pageSize, this.query, this.categorySlug});

  String? get trimmedQuery {
    final trimmed = query?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  bool get isPlainListing => trimmedQuery == null && (categorySlug == null || categorySlug!.isEmpty);
}
