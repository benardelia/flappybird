import 'dart:async';
import 'dart:math';
import 'package:collector/barrier.dart';
import 'package:collector/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'ads_helper.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key, required this.highScore, required this.box});
  final int highScore;
  final Box box;
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String backgroundImage = 'lib/imgs/background.png';

  int i = 0;
  int topScore = 0;
  static double birdY = 0;
  double time = 0;
  double height = 0;
  double initialHeight = birdY;
  bool gameHasStarted = false;
  bool isGameOver = false;
  // score
  int score = 0;
  String gameStateText = 'T A P  T O   P L A Y';
  double birdWidth = 0.3;
  double barriersWidth = 0.4;

// Barriers heights
  List<List<double>> barriersHeight = [
    [0.9, 0.6],
    [0.8, 0.4]
  ];
  List<double> barriersX = [1, 2];

  double frontbarriersHeight = Random().nextDouble();
  double backbarriersHeight = Random().nextDouble();

  showGameDialog(BuildContext context) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: ((context) => AlertDialog(
              backgroundColor: Color.fromARGB(255, 54, 50, 49),
              title: const Text('G A M E  O V E R' ,style:TextStyle(color: Colors.white) ,),
              content: Center(
                heightFactor: 1,
                child: Text(
                  'Score : $score',
                  style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (score > topScore) {
                      widget.box.put('Top Score', score);
                      topScore = score;
                    }
                    setState(() {
                      if(_bannerAd != null){
                         _bannerAd!.dispose();
                      }
                      gameStateText = 'T A P  T O   P L A Y';
                      barriersX = [1, 2];
                      time = 0;
                      initialHeight = 0;
                      birdY = 0;
                      score = 0;
                      isGameOver = false;
                      gameHasStarted = false;
                      frontbarriersHeight = Random().nextDouble();
                      backbarriersHeight = Random().nextDouble();
                      loadAd();
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Restart'),
                ),
                TextButton(
                    onPressed: () {
                      SystemChannels.platform
                          .invokeMethod('SystemNavigator.pop');
                    },
                    child: const Text('Quit'))
              ],
            )));
  }

  bool gameOver() {
    // if bird exit the field
    if (birdY > 1.2 || birdY < -1.2) {
      return true;
    }

// collision detection
    for (int i = 0; i < barriersX.length; i++) {
      if ((barriersX[i] - barriersWidth + birdWidth <= -0.5 &&
          barriersX[i] < 0 &&
          barriersX[i] >= -0.5)) {
        if (birdY > 0) {
          if (birdY > 1 - (barriersHeight[i][0]) - 0.1) {
            return true;
          }
        } else {
          if (birdY < (barriersHeight[i][1] + 0.0) - 1) {
            return true;
          }
        }
      }
    }
    return false;
  }

  void jump() {
    setState(() {
      time = 0;
      initialHeight = birdY;
    });
  }

  void startGame() {
    gameHasStarted = true;

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isGameOver) {
        timer.cancel();
      } else {
        score += 1;
      }
    });
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      // deals with the height of character
      time += 0.05;
      height = -4.9 * time * time + 2 * time;
      setState(() {
        birdY = initialHeight - height;
        // Update barrier positions
        if (barriersX[0] < -1) {
          frontbarriersHeight = Random().nextDouble();
          barriersHeight[0][0] = frontbarriersHeight;
          barriersHeight[0][1] = (0.2 - frontbarriersHeight).abs();
          barriersX[0] = 1.5;
        } else {
          barriersX[0] -= 0.05;
        }
        if (barriersX[1] < -1) {
          backbarriersHeight = Random().nextDouble();
          barriersHeight[1][0] = backbarriersHeight;
          barriersHeight[1][1] = (0.25 - backbarriersHeight).abs();
          barriersX[1] = 2.5;
        } else {
          barriersX[1] -= 0.05;
        }
      });

      isGameOver = gameOver();
      if (isGameOver) {
        timer.cancel();
        gameHasStarted = false;
        showGameDialog(context);
      }
    });
  }

  void loadAd() async {
    await BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          print('fail to load');
        },
      ),
    ).load();
  }

  BannerAd? _bannerAd;
  @override
  void initState() {
    super.initState();
    topScore = widget.highScore;
    loadAd();
  }

  void dispose() {
    _bannerAd?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!isGameOver) {
          if (gameHasStarted) {
            jump();
          } else {
            startGame();
          }
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
                flex: 3,
                child: Stack(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 0),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      image: DecorationImage(
                          image: AssetImage(backgroundImage),
                          fit: BoxFit.cover),
                    ),
                    child: Player(
                      birdWidth: birdWidth,
                      birdHeight: 0.2,
                      birdY: birdY,
                    ),
                  ),
                  Container(
                    alignment: const Alignment(0, -0.2),
                    child: gameHasStarted
                        ? const Text('')
                        : Text(
                            gameStateText,
                            style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Calibri'),
                          ),
                  ),
                  Barrier(
                      barrierWidth: barriersWidth,
                      barrierHeight: barriersHeight[0][0],
                      barrierX: barriersX[0],
                      isBottomBarrier: true),
                  Barrier(
                      barrierWidth: barriersWidth,
                      barrierHeight: barriersHeight[0][1],
                      barrierX: barriersX[0],
                      isBottomBarrier: false),
                  Barrier(
                      barrierWidth: barriersWidth,
                      barrierHeight: barriersHeight[1][0],
                      barrierX: barriersX[1],
                      isBottomBarrier: true),
                  Barrier(
                      barrierWidth: barriersWidth,
                      barrierHeight: barriersHeight[1][1],
                      barrierX: barriersX[1],
                      isBottomBarrier: false)
                ])),
            Container(
              color: Colors.green,
              height: 15,
            ),
            Expanded(
                child: Container(
              color: Color.fromARGB(255, 227, 101, 51),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'SCORE',
                            style: TextStyle(fontSize: 15, color: Colors.white),
                          ),
                          Text(
                            '$score',
                            style: const TextStyle(
                                fontSize: 30, color: Colors.white),
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'TOP SCORE',
                            style: TextStyle(fontSize: 15, color: Colors.white),
                          ),
                          Text(
                            '$topScore',
                            style: const TextStyle(
                                fontSize: 30, color: Colors.white),
                          )
                        ],
                      )
                    ],
                  ),
                  // showing AdBanner here
                  _bannerAd != null
                      ? Container(
                          alignment: Alignment.center,
                          height: _bannerAd!.size.height.toDouble(),
                          width: _bannerAd!.size.width.toDouble(),
                          child: AdWidget(ad: _bannerAd!),
                        )
                      : SizedBox(),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
