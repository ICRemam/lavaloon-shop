import 'package:lavaloon_assessment/business_layer/repositories/category_repository.dart';
import 'package:lavaloon_assessment/business_layer/useCases/params/no_params.dart';
import 'package:lavaloon_assessment/data/abstract/base_usecase.dart';
import 'package:lavaloon_assessment/data/abstract/integrator.dart';
import 'package:lavaloon_assessment/data/exceptions/request_exception.dart';
import 'package:lavaloon_assessment/data/models/categories_result.dart';

class GetCategoriesUseCase extends UseCase<CategoriesResult, NoParams> {
  final Integrator _integrator;
  final CategoryRepository _categoryRepository;

  GetCategoriesUseCase(this._integrator, this._categoryRepository);

  @override
  Future<CategoriesResult> call({required NoParams params}) async {
    try {
      final categories = await _integrator.getCategories();
      await _categoryRepository.replaceCategories(categories);

      return CategoriesResult(categories: categories);
    } on RequestException {
      final cached = await _categoryRepository.getCategories();
      if (cached.isEmpty) rethrow;

      return CategoriesResult(categories: cached, isFromCache: true);
    }
  }
}
