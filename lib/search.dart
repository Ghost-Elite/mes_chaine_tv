import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:mes_chaine_tv/tvPlayer.dart';

class SearchScreen extends StatefulWidget {
  var logoUrl;
  SearchScreen({Key? key,this.logoUrl}) : super(key: key);
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
//Step 3
  var logger =Logger();
  _SearchScreenState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
          filteredNames = names;
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
  }

//Step 1
  final TextEditingController _filter = TextEditingController();
  final dio =  Dio(); // for http requests
  String _searchText = "";
  List names = []; // names we get from API
  List filteredNames = []; // names filtered by search text
  Icon _searchIcon =  Icon(Icons.search);
  Widget _appBarTitle = Text('Search Channel');

  //step 2.1
  void _getNames() async {
    final response =
    await dio.get('https://iptv-org.github.io/iptv/channels.json');
    print(response.data);
    List tempList = [];
    for (int i = 0; i < response.data.length; i++) {
      tempList.add(response.data[i]);
    }
    setState(() {
      names = tempList;
      filteredNames = names;
    });
  }

//Step 2.2
  void _searchPressed() {
    setState(() {
      if (_searchIcon.icon == Icons.search) {
        _searchIcon = Icon(Icons.close);
        _appBarTitle = TextField(
          style: TextStyle(color: Colors.white),
          controller: _filter,
          decoration: InputDecoration(
              prefixIcon:  Icon(Icons.search), hintText: 'Search...',hoverColor: Colors.white),
        );
      } else {
        _searchIcon = Icon(Icons.search);
        _appBarTitle = Text('Search Example');
        filteredNames = names;
        _filter.clear();
      }
    });
  }

  //Step 4
  Widget _buildList() {
    if (!(_searchText.isEmpty)) {
      List tempList = [];
      for (int i = 0; i < filteredNames.length; i++) {
        if (filteredNames[i]['name']
            .toLowerCase()
            .contains(_searchText.toLowerCase())) {
          tempList.add(filteredNames[i]);
        }
      }
      filteredNames = tempList;
    }
    return ListView.builder(
      itemCount: names == null ? 0 : filteredNames.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(

          title: Text(filteredNames[index]['name'],style: GoogleFonts.roboto(color: Colors.white)),
          leading: SizedBox(
            height: 50,
            width: 50,
            child: ClipRRect(
              borderRadius:  BorderRadius.circular(10),
              child: Container(
                child: CachedNetworkImage(
                  imageUrl: filteredNames[index]['logo'].toString(),
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
                height: 50,
              ),
            ),
          ),

          onTap: () {
            logger.wtf('ghost',filteredNames[index]['url']);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TVPlayerPage(
                  dataUrl: filteredNames[index]['url'],

                ),
              ),
            );

          }

        );
      },
    );
  }

  //STep6
  Widget _buildBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: _appBarTitle,
      leading:  IconButton(
        icon: _searchIcon,
        onPressed: _searchPressed,
      ),
    );
  }

  @override
  void initState() {
    _getNames();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: _appBarTitle,
        actions: [
          IconButton(
            icon: _searchIcon,
            onPressed: _searchPressed,
          )
        ],
      ),
      body: Container(
        child: _buildList(),
      ),
      resizeToAvoidBottomInset: false,
//      floatingActionButton: FloatingActionButton(
//        onPressed: _postName,
//        child: Icon(Icons.add),
//      ),
    );
  }
}
