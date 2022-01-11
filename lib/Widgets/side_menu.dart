import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:so_tay_mon_an/Models/user.dart';
import 'package:so_tay_mon_an/Views/admin/ingredient_management_page.dart';
import 'package:so_tay_mon_an/Views/admin/ingredient_type_management_page.dart';
import 'package:so_tay_mon_an/Views/admin/meal_type_management_page.dart';
import 'package:so_tay_mon_an/Views/admin/unit_management.page.dart';
import 'package:so_tay_mon_an/Views/admin/user_management_page.dart';

class SideMenu extends StatelessWidget {
  Users currentUser;
  SideMenu({Key? key, required this.currentUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.black.withOpacity(0.9),
        child: ListView(
          children: [
            DrawerHeader(
              child: Image.network(currentUser.hinhAnh!),
            ),
            DrawerListTile(
              title: "Quản lý loại nguyên liệu",
              svgSrc: "assets/icons/menu_dashbord.svg",
              press: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => IngredientTypeManagementPage())),
            ),
            DrawerListTile(
              title: "Quản lý nguyên liệu",
              svgSrc: "assets/icons/menu_tran.svg",
              press: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => IngredientManagementPage(
                            user: currentUser,
                          ))),
            ),
            DrawerListTile(
              title: "Quản lý người dùng",
              svgSrc: "assets/icons/menu_task.svg",
              press: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UserManagementPage(
                            user: currentUser,
                          ))),
            ),
            DrawerListTile(
              title: "Quản lý đơn vị",
              svgSrc: "assets/icons/menu_doc.svg",
              press: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UnitManagementPage())),
            ),
            DrawerListTile(
              title: "Quản lý loại món ăn",
              svgSrc: "assets/icons/menu_notification.svg",
              press: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MealTypeManagementPage())),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade600,
      child: ListTile(
        onTap: press,
        horizontalTitleGap: 0.0,
        leading: SvgPicture.asset(
          svgSrc,
          color: Colors.white54,
          height: 16,
        ),
        title: Text(
          title,
          style: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }
}
