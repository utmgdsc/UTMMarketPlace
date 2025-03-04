class MenuModel {
  final List<MenuItem> menuItems;

  MenuModel({
    List<MenuItem>? menuItems,
  }) : menuItems = menuItems ?? [
    MenuItem(
      id: '1',
      title: 'Create Listing',
      icon: 'assets/icons/create_listing.png',
      route: '/create-listing',
      showDivider: true,
      
    ),
    MenuItem(
      id: '2',
      title: 'Settings',
      icon: 'assets/icons/settings.png',
      route: '/settings',
      showDivider: true,
    ),
    MenuItem(
      id: '3',
      title: 'Log Out',
      icon: 'assets/icons/logout.png',
      route: '/login',
      showDivider: true,
    ),
  ];
}

class MenuItem {
  final String id;
  final String title;
  final String icon;
  final String route;
  final bool showDivider;

  MenuItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.route,
    this.showDivider = false,
  });
}