import 'dart:math';

import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:so_tay_mon_an/Widgets/animated_wave.dart';
import 'package:supercharged/supercharged.dart';

enum _ColorTween { color1, color2 }

class AnimatedBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(child: AnimatedBackgroundThing()),
          onBottom(AnimatedWave(
            height: 180,
            speed: 1.0,
          )),
          onBottom(AnimatedWave(
            height: 120,
            speed: 0.9,
            offset: pi,
          )),
          onBottom(AnimatedWave(
            height: 220,
            speed: 1.2,
            offset: pi / 2,
          )),
          Positioned.fill(
              child: new Center(
                  child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 10.0,
              ),
            ],
          ))),
        ],
      ),
    );
  }

  onBottom(Widget child) => Positioned.fill(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: child,
        ),
      );
}

class AnimatedBackgroundThing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tween = MultiTween<_ColorTween>()
      ..add(
        _ColorTween.color1,
        Color(0xffD38312).tweenTo(Colors.lightBlue.shade900),
        3.seconds,
      )
      ..add(
        _ColorTween.color2,
        Color(0xffA83279).tweenTo(Colors.blue.shade600),
        3.seconds,
      );

    return MirrorAnimation<MultiTweenValues<_ColorTween>>(
      tween: tween,
      duration: tween.duration,
      builder: (context, child, value) {
        return Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                value.get<Color>(_ColorTween.color1),
                value.get<Color>(_ColorTween.color2)
              ])),
        );
      },
    );
  }
}
