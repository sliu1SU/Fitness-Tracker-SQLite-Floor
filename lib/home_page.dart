import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'display_point_info.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'main.dart';

class Home extends StatefulWidget {
  final Widget child;
  // constructor
  const Home({super.key, required this.child});

  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> {
  int currentIndex = 0; // Set the initial tab index

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appBarTitle),
        backgroundColor: Colors.lightBlueAccent,
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       showModalBottomSheet(
        //         context: context,
        //         builder: (context) {
        //           return const SettingPage();
        //         },
        //       );
        //     },
        //     icon: const Icon(Icons.settings),
        //   )
        // ],
      ),
      body: Column(
        children: [
          const DisplayPointInfo(),
          Expanded(
            child: widget.child,
          ),
          //widget.child, // is it because the child is scaffold?
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.green,
        currentIndex: currentIndex,
        onTap: (int index) {
          setState(() {
            currentIndex = index;
          });
          if (index == 0) {
            GoRouter.of(context).go('/');
          } else if (index == 1) {
            GoRouter.of(context).go('/diet');
          } else {
            GoRouter.of(context).go('/workout');
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.emoji_emotions_sharp),
            label: AppLocalizations.of(context)!.emotion,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.food_bank_sharp),
            label: AppLocalizations.of(context)!.diet,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.fitness_center_sharp),
            label: AppLocalizations.of(context)!.workout,
          ),
        ],
      ),
    );
  }
}