import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:mes_chaine_tv/drawerPage.dart';
import 'package:mes_chaine_tv/search.dart';
import 'package:mes_chaine_tv/tvPlayer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List apijson = [];
  List names = []; // names we get from API
  List filteredNames = [];
  var logger =Logger();
  var dataUrl;final dio =  Dio();
  void _getNames() async {
    final response =
    await dio.get('https://iptv-org.github.io/iptv/channels.json');
    //print(response.data);
    List tempList = [];
    List cat = [];
    for (int i = 0; i < response.data.length; i++) {
      tempList.add(response.data[i]);
    }
    setState(() {
      names = tempList;
      filteredNames = names;
    });

    for (int i = 0; i < filteredNames.length; i++) {
      for(int j = 0; j < filteredNames.length; j++){

        /*cat.add(names[j]);
        logger.wtf('message ',names[j]);*/
      }


    }

  }
  Future<void> getall() async {
    bool loadRemoteDatatSucceed = false;
    try {
      var response = await http
          .get(Uri.parse("https://iptv-org.github.io/iptv/channels.json"))
          .timeout(const Duration(seconds: 10), onTimeout: () {

        throw TimeoutException("connection time out try agian");
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        //logger.w(listChannelsbygroup);

        setState(() {
          dataUrl = jsonDecode(response.body);
        });
        var rest = dataUrl as List;


        logger.i("guide url",);
        // model= AlauneModel.fromJson(jsonDecode(response.body));
      } else {

        return null;
      }

    } on TimeoutException catch (_) {
    }

  }
    @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getall();
    _getNames();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown]);
  }
  @override
  Widget build(BuildContext context) {
   // logger.i('message',apijson[0]);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('World TV',style: GoogleFonts.roboto(fontWeight: FontWeight.bold),),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,color: Colors.white,size: 24,
            ), onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SearchScreen(

                  logoUrl: dataUrl,
                ),
              ),
            );
          },
          )
        ],
      ),
      body: gridviewItem(),
      drawer: DrawerPage(),
    );
  }

  Widget gridviewItem(){
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      //padding: const EdgeInsets.only(bottom:15,top: 10,left: 10,right: 10),
      crossAxisSpacing: 8,
      mainAxisSpacing: 4,
      children: List.generate(dataUrl==null?0: dataUrl.length, (index) {
        return GestureDetector(
          onTap: (){
            logger.wtf('message',dataUrl[index]['url']);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TVPlayerPage(
                  dataUrl: dataUrl[index]['url'],
                  title: dataUrl[index]['name'],

                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(9.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width/4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [

                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width/4,
                        decoration:  BoxDecoration(
                            image: const DecorationImage(
                              image: AssetImage('assets/images/carreImage.png'),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(10)
                        ),
                      ),
                      ClipRRect(
                        borderRadius:  BorderRadius.circular(10),
                        child: Container(
                          child: CachedNetworkImage(
                            imageUrl: dataUrl[index]['logo'].toString(),
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Image.asset(
                              "assets/images/vignete.jpg",
                              fit: BoxFit.cover,
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                              "assets/images/vignete.jpg",
                              fit: BoxFit.cover,
                            ),
                          ),
                          width: MediaQuery.of(context).size.width,
                          height: 90,
                        ),
                      ),
                      /*Text(
                        dataUrl[position]['name'],
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      )*/
                    ],
                  )

                ],
              ),
            ),
          ),
        );
      }),
    );
  }
  Widget gridTV(){
    final orientation = MediaQuery.of(context).orientation;
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3),

      physics: ClampingScrollPhysics(),
      itemBuilder: (context, position) {
        //logger.i('ghost',widget.ytResultPlaylist[position].thumbnail['high']['url']);
        return GestureDetector(
          onTap: (){
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => HomePage(
                 /* dataUrl: dataUrl[position]['url'],
                  title: dataUrl[position]['name'],*/

                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(9.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 145,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      ClipRRect(
                        borderRadius:  BorderRadius.circular(10),
                        child: Container(
                          child: CachedNetworkImage(
                            imageUrl: dataUrl[position]['logo'].toString(),
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Image.asset(
                              "assets/images/vignete.jpg",
                              fit: BoxFit.cover,
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                              "assets/images/vignete.jpg",
                              fit: BoxFit.cover,
                            ),
                          ),
                          width: MediaQuery.of(context).size.width,
                          height:145,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 145,
                        decoration:  BoxDecoration(
                            image: const DecorationImage(
                              image: AssetImage('assets/images/carreImage.png'),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(10)
                        ),
                      ),
                      /*Text(
                        dataUrl[position]['name'],
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      )*/
                    ],
                  )

                ],
              ),
            ),
          ),
        );
      },
      itemCount:dataUrl==null?0: dataUrl.length,
    );
  }
}
