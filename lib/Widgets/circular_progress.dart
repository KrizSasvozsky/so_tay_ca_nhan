import 'package:flutter/material.dart';

Container CircularProgress() {
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.only(top: 10),
    child: const CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.purple),
    ),
  );
}
