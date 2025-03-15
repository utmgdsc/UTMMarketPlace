import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:utm_marketplace/menu/model/menu.model.dart';
import 'package:utm_marketplace/shared/secure_storage/secure_storage.dart';

class MenuItemComponent extends StatelessWidget {
  final MenuItem item;

  const MenuItemComponent({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLogout = item.title == 'Log Out';
    final Color itemColor = isLogout ? Colors.red : Colors.black;

    return Column(
      children: [
        ListTile(
          leading: Image.asset(
            item.icon,
            width: 24,
            height: 24,
            color: itemColor,
          ),
          title: Text(
            item.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: itemColor,
            ),
          ),
          onTap: () {
            if (isLogout) {
              secureStorage.delete(key: 'jwt_token');
              context.go('/login');
            } else {
              context.push(item.route);
            }
          },
        ),
        if (item.showDivider)
          const Divider(
            height: 1,
            thickness: 0.5,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
}
