import 'package:flutter/material.dart';
import 'package:so_tay_mon_an/Widgets/header.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Header(),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
