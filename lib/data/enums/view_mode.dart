enum ViewMode {
  listItems('List'),
  gridItems('Grid')
  ;

  final String title;
  const ViewMode(this.title);

  bool get isGrid => this == ViewMode.gridItems;
  bool get isList => this == ViewMode.listItems;

  ViewMode get toggled => isGrid ? ViewMode.listItems : ViewMode.gridItems;

  static ViewMode fromName(String? name) {
    return ViewMode.values.firstWhere((mode) => mode.name == name, orElse: () => ViewMode.gridItems);
  }
}
