import 'package:chatnow/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});
  void logout() async {
    AuthService authService = AuthService();
    await authService.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey.shade300,
      child: Column(
        children: [
          DrawerHeader(
            child: Icon(
              Icons.message,
              size: 100,
              color: Colors.grey,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25),
            child: ListTile(
              onTap: () {
                Navigator.pop(context);
              },
              leading: Icon(Icons.home),
              title: Text('H O M E'),
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(left: 25, bottom: 25),
            child: ListTile(
              onTap: logout,
              leading: Icon(Icons.logout),
              title: Text('L O G O U T'),
            ),
          ),
        ],
      ),
    );
  }
}
