abstract class UseCase<TResult, TParam> {
  Future<TResult> call({required TParam params});
}
