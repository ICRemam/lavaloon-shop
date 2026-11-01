enum EndpointsRoutes {
  loginEndpoint('auth/login'),
  currentUserEndpoint('auth/me'),
  productsEndpoint('products'),
  searchProductsEndpoint('products/search'),
  categoriesEndpoint('products/categories'),
  productsByCategoryEndpoint('products/category'),
  submitCartEndpoint('carts/add')
  ;

  final String path;
  const EndpointsRoutes(this.path);

  String withSegment(Object segment) => '$path/$segment';
}
