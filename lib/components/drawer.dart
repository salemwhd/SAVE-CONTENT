import 'package:flutter/material.dart';
import 'package:CONTGUARD/components/my_list_tile.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onProfileTap;
  final void Function()? onSignOut;
  final void Function()? onExploreTap;
  const MyDrawer({
    super.key,
    required this.onProfileTap,
    required this.onSignOut,
    required this.onExploreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color.fromARGB(255, 135, 1, 172),
      child: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //header
              const DrawerHeader(
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 64,
                ),
              ),

              //home list tile
              MyListTile(
                icon: Icons.home,
                text: 'H O M E',
                onTap: () => Navigator.pop(context),
              ),

              //profile list tile
              MyListTile(
                  icon: Icons.person,
                  text: 'P R O F I L E',
                  onTap: onProfileTap),
              MyListTile(
                icon: Icons.explore,
                text: 'E X P L O R E',
                onTap: onExploreTap, // Replace with your own function
              ),
            ],
          ),

          //logout list tile
          MyListTile(icon: Icons.logout, text: 'L O G O U T', onTap: onSignOut),
        ],
      ),
    );
  }
}
