class MenuModel {
  final List<MenuItem> menuItems;

  MenuModel({this.menuItems = const []});
}

class MenuItem {
  final String id;
  final String title;
  final String icon;
  final String route;

  MenuItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.route,
  });
}
