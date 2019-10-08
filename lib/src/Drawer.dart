import 'package:flutter/material.dart';

class DrawerUI extends StatefulWidget {
  @override
  _DrawerUIState createState() => _DrawerUIState();
}

class _DrawerUIState extends State<DrawerUI> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: ListView(
          children: <Widget>[
            Container(
              alignment: Alignment.topCenter,
              color: Colors.redAccent,
              height: 200,
            ),
            Container(
              alignment: Alignment.topCenter,
              color: Colors.white,
              height: 200,
            ),
            
          ],
      ),
    );
  }
}
