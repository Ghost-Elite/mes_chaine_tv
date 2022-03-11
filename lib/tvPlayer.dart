import 'dart:async';
import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:retry/retry.dart';

class TVPlayerPage extends StatefulWidget {
  var dataUrl,title;
  TVPlayerPage({Key? key,this.dataUrl,this.title}) : super(key: key);

  @override
  _TVPlayerPageState createState() => _TVPlayerPageState();
}

class _TVPlayerPageState extends State<TVPlayerPage> {
  var logger =Logger();
  GlobalKey _betterPlayerKey = GlobalKey();
  BetterPlayerController? betterPlayerController;
  late var betterPlayerConfiguration = BetterPlayerConfiguration(
    autoPlay: true,
    looping: false,
    fullScreenByDefault: false,
    allowedScreenSleep: false,
    translations: [
      BetterPlayerTranslations(
        languageCode: "fr",
        generalDefaultError: "Impossible de lire la vidéo",
        generalNone: "Rien",
        generalDefault: "Défaut",
        generalRetry: "Réessayez",
        playlistLoadingNextVideo: "Chargement de la vidéo suivante",
        controlsNextVideoIn: "Vidéo suivante dans",
        overflowMenuPlaybackSpeed: "Vitesse de lecture",
        overflowMenuSubtitles: "Sous-titres",
        overflowMenuQuality: "Qualité",
        overflowMenuAudioTracks: "Audio",
        qualityAuto: "Auto",
      ),
    ],
    deviceOrientationsAfterFullScreen: [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
    //autoDispose: true,
    controlsConfiguration: const BetterPlayerControlsConfiguration(
      iconsColor: Colors.white,
      //controlBarColor: colorPrimary,
      controlBarColor: Colors.transparent,
      liveTextColor: Colors.red,
      playIcon: Icons.play_arrow,
      enablePip: true,
      enableFullscreen: true,
      enableSubtitles: false,
      enablePlaybackSpeed: false,
      loadingColor: Colors.white,
      enableSkips: false,
      overflowMenuIconsColor:  Colors.white,
      //overflowModalColor: Colors.amberAccent
    ),
  );
  initPlayer(){
    BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.dataUrl.toString(),
      liveStream: true,
      asmsTrackNames: ["3G 360p", "SD 480p", "HD 1080p"],
      /*notificationConfiguration: BetterPlayerNotificationConfiguration(
            showNotification: true,
            title: tvTitle,
            author: "DMedia",
            imageUrl:tvIcon,
          ),*/
    );
    if (betterPlayerController != null) {
      betterPlayerController!.pause();
      betterPlayerController!.setupDataSource(betterPlayerDataSource);
    } else {
      betterPlayerController = BetterPlayerController(betterPlayerConfiguration,
          betterPlayerDataSource: betterPlayerDataSource);
    }
    betterPlayerController!.setBetterPlayerGlobalKey(_betterPlayerKey);

  }
  Future<void> retryMethode() async {
    // Create an HttpClient.
    final client = HttpClient();

    try {
      // Get statusCode by retrying a function
      final statusCode = await retry(
            () async {
          // Make a HTTP request and return the status code.
          final request = await client
              .getUrl(Uri.parse('https://www.google.com'))
              .timeout(Duration(seconds: 5));
          final response = await request.close().timeout(Duration(seconds: 5));
          await response.drain();
          return response.statusCode;
        },
        // Retry on SocketException or TimeoutException
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );

      // Print result from status code
      if (statusCode == 200) {
        logger.i('google.com is running');

      } else {
        logger.i('google.com is not availble...');
      }
    } finally {
      // Always close an HttpClient from dart:io, to close TCP connections in the
      // connection pool. Many servers has keep-alive to reduce round-trip time
      // for additional requests and avoid that clients run out of port and
      // end up in WAIT_TIME unpleasantries...
      client.close();
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    betterPlayerController = BetterPlayerController(betterPlayerConfiguration)..addEventsListener((error) => {
      if(error.betterPlayerEventType.index==9){
        logger.i(error.betterPlayerEventType.index,"index event"),
        retryMethode(),

        betterPlayerController!.retryDataSource()
      }
    });
    initPlayer();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft
    ]);
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    betterPlayerController!.dispose();
    betterPlayerController ==null;
  }
  @override
  Widget build(BuildContext context) {

    logger.i('ghost tv',widget.dataUrl);
    return Scaffold(
      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: betterPlayerController !=null?
          AspectRatio(
            aspectRatio: 16 / 9,
            key: _betterPlayerKey,
            child: BetterPlayer(controller: betterPlayerController!),
          ):Container(),
        ),
      ),
    );
  }
}
