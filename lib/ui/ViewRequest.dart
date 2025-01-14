import 'package:chewie/chewie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/Apiservices.dart';
import 'package:flutter_application_2/models/NgoAction.dart';
import 'package:flutter_application_2/models/UsersReg.dart';
import 'package:flutter_application_2/ui/NGO.dart';
import 'package:flutter_application_2/ui/zoomimageview.dart';
import 'package:video_player/video_player.dart';

import 'ViewNgoAction.dart';
import '../main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'video_items.dart';

//import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
// ignore: unused_import
enum UrlType { IMAGE, VIDEO, UNKNOWN }

String _usermobile;
String usertype = "";
bool NGOapprove = false;
bool NGO = false;
String _ngoname;
int _id;
String _remarks;
String _imgurl;
String _category;
String _sex;
String _age;
String _lat, _long, _status, _dated, _mtype;
bool _vis;
bool stremarks;
bool stopen;
bool stshort;
bool stresolve;

class ViewRequest extends StatefulWidget {
  final String id;
  final String remarks;
  final String imgurl;
  final String category;
  final sex;
  final String age;
  final String requestMob;
  final String lat, long, status, dated, mtype;
  final bool vis;
  ViewRequest(
      this.id,
      this.remarks,
      this.age,
      this.category,
      this.dated,
      this.imgurl,
      this.lat,
      this.long,
      this.sex,
      this.status,
      this.mtype,
      this.vis,
      this.requestMob) {
    _id = int.parse(id);
    _remarks = remarks;
    _imgurl = imgurl;
    _category = category;
    _sex = sex;
    _age = age;
    _lat = lat;
    _long = long;
    _status = status;
    _mtype = mtype;
    _dated = dated;
    _vis = vis;
    _usermobile = requestMob;
  }

  @override
  _State createState() => _State();
}

class _State extends State<ViewRequest> {
  VideoPlayerController controller; // used to controller videos
  ChewieController _chewieController;
  TextEditingController mytextcommt = TextEditingController();
  @override
  Future<void> initState() {
    setuser();
    print(widget.status);
    super.initState();
  }

  Future<List<Users>> getdate(String mob) {
    var res = APIServices.fetchUsersbyMob(mob);
    return res;
  }

  Future<List<Ngo>> getngodate(String id) {
    var res = APIServices.fetchNGoData(id);
    return res;
  }

  @override
  void dispose() {
    //controller.dispose();
    //_chewieController.dispose();
    super.dispose();
  }

  Future<void> futureController() async {
    controller = VideoPlayerController.network(_imgurl);
    await controller.initialize();
    _chewieController = ChewieController(
      videoPlayerController: controller,
      autoPlay: true,
      looping: true,
      // Try playing around with some of these other options:

      // showControls: false,
      // materialProgressColors: ChewieProgressColors(
      //   playedColor: Colors.red,
      //   handleColor: Colors.blue,
      //   backgroundColor: Colors.grey,
      //   bufferedColor: Colors.lightGreen,
      // ),
      // placeholder: Container(
      //   color: Colors.grey,
      // ),
      // autoInitialize: true,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('View Request'),
        ),
        body: ListView(children: [
          Card(
            color: setCol(widget.status),
            margin: EdgeInsets.all(20),
            elevation: 10,
            child: NGOWidget(context),
          ),
          Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: ElevatedButton.icon(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NgoAction(widget.id)),
                    );
                  },
                  icon: Icon(Icons.list_alt_rounded),
                  label: Text("View NGO Action")))
        ]));
  }

  void setuser() async {
    final prefs = await SharedPreferences.getInstance();
    usertype = prefs.getString("usertype");
    _usermobile = prefs.getString("usermobile");
    _ngoname = prefs.getString("ngoname");

    setState(() {});
  }

  Color setCol(String s) {
    if (s == 'Short List') {
      return Colors.yellow[100];
    } else if (s == 'Resolved') {
      return Colors.greenAccent[100];
    } else if (s == 'Open') {
      return Colors.red[100];
    }
  }

  void navigateTo(String lat, String lng) async {
    var uri = Uri.parse("google.navigation:q=$lat,$lng&mode=d");
    if (await canLaunch(uri.toString())) {
      await launch(uri.toString());
    } else {
      throw 'Could not launch ${uri.toString()}';
    }
  }

  Widget NGOWidget(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([getdate(_usermobile), getngodate(widget.id)]),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child:
                  CircularProgressIndicator()); // While data is being fetched
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final List<Users> apiuser = snapshot.data[0];
          final List<Ngo> apingoaction = snapshot.data[1];
          print(apingoaction.last.ngomobile);
          if (usertype.isNotEmpty &&
              usertype.contains("NGO") &&
              apiuser.first.approve != null &&
              apiuser.first.approve.toString().isNotEmpty) {
            NGO = true;
            print(NGO);

            if (!_status.contains("Open") &&
                _usermobile != apingoaction.last.ngomobile) {
              NGO = false;
              print(NGO);
            }
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                color: setCol(widget.status),
                margin: EdgeInsets.all(20),
                child: _mtype == 'V'
                    ? Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.teal)),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 100,
                          height: MediaQuery.of(context).size.width - 200,
                          child: VideoItems(
                            videoPlayerController:
                                VideoPlayerController.network(_imgurl),
                            looping: false,
                            autoplay: false,
                          ),
                        ),
                      )
                    : InkWell(
                        child: CircleAvatar(
                          backgroundColor: Colors.teal,
                          maxRadius: 90.0,
                          backgroundImage: NetworkImage(_imgurl),
                        ),
                        onTap: () {
                          _showZoomableImage(context, _imgurl);
                        },
                      ),
                elevation: 0.0,
                // shape: CircleBorder(),
              ),
              Text(
                _category,
                style: TextStyle(fontSize: 20, color: Colors.deepOrange[700]),
              ),
              Visibility(
                  visible: NGO,
                  child: Text("Posted by : " + widget.requestMob)),
              Visibility(
                  visible: _status != null ? true : false,
                  child: Text("  Status : " + _status)),
              Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Center(
                    child: Visibility(
                      child: Text(
                        _remarks,
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                  )),
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(padding: EdgeInsets.only(left: 5.0)),
                    ElevatedButton.icon(
                        onPressed: () {
                          navigateTo(_lat, _long);
                        },
                        icon: Icon(Icons.my_location_rounded),
                        label: const Text('Track Geo Location',
                            style: TextStyle(fontSize: 12)))
                  ],
                ),
              ),
              Visibility(
                visible: NGO,
                child: Container(
                  padding: EdgeInsets.only(bottom: 10),
                  width: MediaQuery.of(context).size.width - 100,
                  child: TextFormField(
                    controller: mytextcommt,
                    decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        labelText: "Remarks...",
                        errorStyle:
                            TextStyle(color: Colors.redAccent, fontSize: 12.0),
                        hintText: 'Enter Your comments',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Visibility(
                  visible: NGO && widget.status.contains("Open") ? true : false,
                  child: ElevatedButton(
                    onPressed: () async {
                      Ngo users = new Ngo(
                          dataid: _id,
                          ngo: _ngoname,
                          ngomobile: _usermobile,
                          ngoaction1: 'Short List',
                          remarks: mytextcommt.text);

                      var res = await APIServices.postNGoData(users)
                          .whenComplete(() => null);

                      if (res != 200) {
                        showdg(context, "Error", "Error saving data");
                        return;
                      }
                      if (res == 200) {
                        showdg(context, "Success", "Needy Short Listed");
                      }
                    },
                    child: const Text('Short List',
                        style: TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                ),
                Padding(padding: EdgeInsets.only(left: 5.0)),
                Visibility(
                  visible:
                      NGO && !widget.status.contains("Open") ? true : false,
                  child: ElevatedButton(
                    onPressed: () async {
                      Ngo users = new Ngo(
                          dataid: _id,
                          ngo: _ngoname,
                          ngomobile: _usermobile,
                          ngoaction1: 'Open',
                          remarks: mytextcommt.text);

                      var res = await APIServices.postNGoData(users);
                      if (res != 200) {
                        showdg(context, "Error", "Error saving data");
                        return;
                      }
                      if (res == 200) {
                        showdg(context, "Success", "Needy Re-Open");
                      }
                    },
                    child: const Text('Re-Open',
                        style: TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                ),
                Padding(padding: EdgeInsets.only(left: 5.0)),
                Visibility(
                  visible:
                      NGO && !widget.status.contains("Open") ? true : false,
                  child: ElevatedButton(
                    onPressed: () async {
                      Ngo users = new Ngo(
                          dataid: _id,
                          ngo: _ngoname,
                          ngomobile: _usermobile,
                          ngoaction1: 'Resolved',
                          remarks: mytextcommt.text);

                      var res = await APIServices.postNGoData(users);
                      if (res != 200) {
                        showdg(context, "Error", "Error saving data");
                        return;
                      }
                      if (res == 200) {
                        showdg(context, "Success", "Needy Resolved");
                      }
                    },
                    child: const Text('Resolved',
                        style: TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                ),
              ])
            ],
          );
        }
      },
    );
  }
}

void _showZoomableImage(BuildContext context, String imageUrl) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ZoomableImage(imageUrl: imageUrl),
    ),
  );
}
