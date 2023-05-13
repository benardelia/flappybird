import 'package:flutter/material.dart';

class Player extends StatelessWidget {
  final birdY;
  final double birdWidth;
  final double birdHeight;
  const Player(
      {super.key,
      required this.birdY,
      required this.birdWidth,
      required this.birdHeight});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(-0.5, (2 * birdY + birdHeight) / (2 - birdHeight)),
      child: Image.asset(
        'lib/imgs/flappy.png',
        width: MediaQuery.of(context).size.width * birdWidth / 2,
        height: MediaQuery.of(context).size.height * 3 / 4 * birdHeight / 2,
        fit: BoxFit.fill,
      ),
    );
  }
}
