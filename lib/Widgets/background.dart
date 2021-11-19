import 'package:flutter/material.dart';

class BackGround extends StatelessWidget {
  const BackGround({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 75, 0, 40),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(25))),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
      ),
    );
  }
}
