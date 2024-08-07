import 'package:flutter/material.dart';
import 'package:hansol_high_school/Screens/SubScreens/setting_screen.dart';
import 'package:hansol_high_school/Widgets/SettingWidgets/setting_toggle_switch.dart';

void main() {
  runApp(HansolHighSchool());
}

class HansolHighSchool extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isSwitched = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              onPressed: () {
                Navigator.of(context).push(_createRoute());
              },
              icon: const Icon(Icons.settings),
            ),
          ),
          Center(
            child: SettingToggleSwitch(
              value: isSwitched,
              // trackActiveColor: PRIMARY_COLOR,
              // toggleActiveColor: Colors.green,
              // trackHeight: 25,
              toggleInActiveColor: Colors.white,
              onChanged: (value) {
                setState(() {
                  isSwitched = value;
                });
              },
            ),
          )
        ],
      ),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SettingScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}
