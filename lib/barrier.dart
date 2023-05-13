import 'package:flutter/material.dart';

class Barrier extends StatelessWidget {
  final barrierWidth;
  final barrierHeight;
  final barrierX;
  final bool isBottomBarrier;

  const Barrier(
      {super.key,
      required this.barrierWidth,
      required this.barrierHeight,
      required this.barrierX,
      required this.isBottomBarrier});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment((2 * barrierX + barrierWidth) / (2 - barrierWidth),
          isBottomBarrier ? 1 : -1),
      child: Container(
          width: MediaQuery.of(context).size.width * barrierWidth / 2,
          height:
              (MediaQuery.of(context).size.height * 3 / 4) * barrierHeight / 2,
          decoration: const BoxDecoration(
            color: Colors.green,
            border: Border(
                left: BorderSide(
                    width: 3, color: Color.fromARGB(255, 245, 148, 45))),
          )),
    );
  }
}
