import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  WebViewPlusController? _controller;
  double _height = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: 200,
        child: WebViewPlus(
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (controller) {
            controller.loadString(r"""
           <html lang="en">
<head>
    <meta charset="UTF-8">
    <title>CDNBye OpenPlayer Demo</title>
    <link rel="stylesheet" href="//cdn.jsdelivr.net/npm/openplayerjs@latest/dist/openplayer.css">
</head>
<body>

<!-- 1. Load DailyMotion API (Javascript) -->
<script src='https://api.dmcdn.net/all.js'> </script>

<!-- 2. Create container for DM Player instance  -->
<div id='player'></div>

<!-- 3. Javascript stuff goes here -->
<script>

    //Set VIDEO_ID (retrieve or update from your CMS)
    //**example** var VIDEO_ID = get_video_id.php **where PHP returns/echo the text of ID**

    var VIDEO_ID = "x7vidbb"; //update this via your CMS technique

    //Create DM Player instance//
    var player = DM.player(document.getElementById('player'), {
    video: VIDEO_ID,
    width: "100%", height: "100%",
    params: { autoplay: false, mute: true ,,}


    });

    //Handle video ending (seek back to zero time)//
    player.addEventListener('end', function (evt) { evt.target.currentTime = 0; evt.target.play() } );

    //Control functions for DM Player instance//
    function func_Play()
    { player.play(); }

    function func_Pause()
    { player.pause(); }

</script>



<p>

<!-- Buttons for play pause -->
<button onclick="func_Play()"> PLAY </button>

<button onclick="func_Pause()"> PAUSE </button>

</p>

</body>
</html>
      """);
          },
        ),
      ),
    );
  }
}
