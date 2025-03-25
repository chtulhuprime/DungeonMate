import 'package:flutter/material.dart';

import '../home_screen.dart';

class MasterHomeScreen extends StatefulWidget {
  final bool isMaster;

  const MasterHomeScreen({
    super.key,
    required this.isMaster,
  });

  @override
  State<MasterHomeScreen> createState() => _MasterHomeScreenState();
}

class _MasterHomeScreenState extends State<MasterHomeScreen> {

  void _navigateToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isMaster ? 'Режим Мастера' : 'Мои Сценарии'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.ad_units),
              onPressed: () => _navigateToHome(context),
            )
          ]
      ),
      body: Column(

      ),
    );
  }
}
