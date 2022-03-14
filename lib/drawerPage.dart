import 'dart:async';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({Key? key}) : super(key: key);

  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  var logger =Logger();
  var dataUrl;
  Future<void> getall() async {
    bool loadRemoteDatatSucceed = false;
    try {
      var response = await http
          .get(Uri.parse("https://iptv-org.github.io/api/categories.json"))
          .timeout(const Duration(seconds: 10), onTimeout: () {

        throw TimeoutException("connection time out try agian");
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        //logger.w(listChannelsbygroup);

        setState(() {
          dataUrl = jsonDecode(response.body);
        });

        logger.i("guide url",dataUrl);
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
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      backgroundColor: Colors.white,

      child: ListCategories()
    );
  }
  Widget ListCategories(){
    return ListView.builder(
      padding: EdgeInsets.only(top: 50),
      itemCount: dataUrl == null ? 0 : dataUrl.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(

          title: Text(dataUrl[index]['name'],style: GoogleFonts.roboto(color: Colors.black)),

          /*onTap: () {
                logger.wtf('ghost',filteredNames[index]['url']);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TVPlayerPage(
                      dataUrl: filteredNames[index]['url'],

                    ),
                  ),
                );

              }*/

        );
      },
    );
  }
}
