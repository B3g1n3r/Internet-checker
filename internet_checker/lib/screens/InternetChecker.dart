import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class InternetChecker extends StatefulWidget {
  const InternetChecker({super.key});

  @override
  State<InternetChecker> createState() => _InternetCheckerState();
}

class _InternetCheckerState extends State<InternetChecker> {
  late ConfettiController confettiController;
  late StreamSubscription<InternetStatus> streamSubscription;
  late InternetStatus? internetStatus = InternetStatus.connected;

  final Connectivity connectivity = Connectivity();
  ConnectivityResult _connectionStatus = ConnectivityResult.none;

  String displayString = 'OFFLINE';
  Color statusTextColor = Colors.red;

  @override
  void initState() {
    streamSubscription = InternetConnection().onStatusChange.listen((status) {
      setState(() {
        internetStatus = status;
        updateDisplayString();
      });
    });
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _connectionStatus = result;
        updateDisplayString();
      });
    });
    confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    super.initState();
  }

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }

  void playConfetti() {
    confettiController.play();
  }

  void updateDisplayString() {
    if (internetStatus == InternetStatus.connected) {
      setState(() {
        displayString = 'ONLINE';
        statusTextColor = Colors.green;
        playConfetti();
      });
    } else {
      setState(() {
        displayString = 'OFFLINE';
        statusTextColor = Colors.red;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Internet Checker'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 230,
            ),
            ConfettiWidget(
              confettiController: confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              maxBlastForce: 10,
              minBlastForce: 2,
              emissionFrequency: 0.02,
              numberOfParticles: 20,
              gravity: 0.1,
            ),
            const SizedBox(height: 20),
            Hero(
              tag: 'statusText',
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                      width: 300,
                    ),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        displayString,
                        style: TextStyle(
                          fontSize: 48,
                          color: statusTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildConnectionStatusIcon(),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        updateDisplayString();
                      },
                      child: const Text('Check Again'),
                    ),
                    const SizedBox(
                      height: 30,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildConnectionStatusIcon() {
    IconData iconData;
    Color iconColor;
    String statusText;

    switch (_connectionStatus) {
      case ConnectivityResult.mobile:
        iconData = Icons.phone;
        iconColor = Colors.blue;
        statusText = 'Mobile data';
        break;
      case ConnectivityResult.wifi:
        iconData = Icons.wifi;
        iconColor = Colors.green;
        statusText = 'Wi-Fi';
        break;
      case ConnectivityResult.none:
      default:
        iconData = Icons.signal_wifi_off;
        iconColor = Colors.red;
        statusText = 'No connection';
        break;
    }

    return Column(
      children: [
        Icon(
          iconData,
          color: iconColor,
          size: 48.0,
        ),
        Text(statusText),
      ],
    );
  }
}
