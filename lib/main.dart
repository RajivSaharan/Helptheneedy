import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/AppStateNotifier.dart';
import 'package:flutter_application_2/models/NgoAction.dart';
import 'package:flutter_application_2/ui/AboutUs.dart';
import 'package:flutter_application_2/ui/Associates.dart';
import 'package:flutter_application_2/ui/Disclaimer.dart';

import 'package:flutter_application_2/ui/Latest.dart';
import 'package:flutter_application_2/ui/LatestNGO.dart';
import 'package:flutter_application_2/ui/splash.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ui/Needy.dart';
import 'ui/PressRelease.dart';
import 'ui/camera.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ui/Emergency.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'ui/Feedback.dart';
import 'ui/loginscreen.dart';

//import './Recent.dart';
String _username;
String _useremail;
String _userphotourl;
String _usertype;
bool isSwitched;
var textValue = 'Switch is OFF';

void getParams() {
  var uri;
  Map<String, String> params = uri.queryParameters;
  var origin = params['origin'];
  var destiny = params['destiny'];
  print(origin);
  print(destiny);
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description: 'This channel is used for important notifications.',
  // description
  importance: Importance.max,
);

FirebaseMessaging messaging;
List<String> _value;
void main() async {
  //await init();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification notification = message.notification;
    AndroidNotification android = message.notification?.android;

    // If `onMessage` is triggered with a notification, construct our own
    // local notification to show to users using the created channel.
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id, channel.name,
              icon: android?.smallIcon,
              // other properties...
            ),
          ));
    }
  });
  runApp(
    ChangeNotifierProvider<AppStateNotifier>(
      child: MyHome(),
      create: (context) => AppStateNotifier(),
    ),
  );
}

Future init() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  TabController _tabController;
  String notificationTitle = 'No Title';
  String notificationBody = 'No Body';
  String notificationData = 'No Data';

  // ignore: non_constant_identifier_names
  String ShareText =
      "Welcome to Help the Needy App, Install the app for helping the needy from : https://play.google.com/store/apps/details?id=com.help.theneedy";
  @override
  void initState() {
    setuser();

    super.initState();
  }

  @override
  void dispose() {
    // _tabController.dispose();

    super.dispose();
  }

  void launchWhatsApp({
    @required int phone,
    @required String message,
  }) async {
    String url() {
      return "https://wa.me/$phone::/?text=${Uri.parse(message)}";
    }

    if (await canLaunch(url())) {
      await launch(url());
    } else {
      throw 'Could not launch ${url()}';
    }
  }

  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 4,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80.0),
          child: AppBar(
            title: Text('HelpTheNeedy'),
            actions: [
              // action button
              IconButton(
                icon: Icon(MdiIcons.alarmLight),
                tooltip: 'Press in Emergency',
                iconSize: 35.0,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Emergency()),
                  );
                },
              ),
            ],
            centerTitle: true,
            bottom: TabBar(
              isScrollable: true,
              tabs: <Widget>[
                Container(
                  width: 20,
                  child: Icon(
                    Icons.camera_alt,
                    size: 25.0,
                  ),
                ),
                Container(
                    width: 65,
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Needy",
                      style: TextStyle(fontSize: 15.0),
                    )),
                Container(
                    width: 65,
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Latest",
                      style: TextStyle(fontSize: 15.0),
                    )),
                Container(
                    width: 100,
                    alignment: Alignment.topLeft,
                    child: Text(
                      "NGO's",
                      style: TextStyle(fontSize: 15.0),
                    )),
              ],
            ),
          ),
        ),
        drawer: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(_username != null ? _username : "NO User"),
                accountEmail: Text(_useremail != null
                    ? _useremail
                    : "codeplayonapp@gmail.com"),
                currentAccountPicture: CircleAvatar(
                  backgroundImage:
                      NetworkImage(_userphotourl != null ? _userphotourl : ""),
                  backgroundColor:
                      Theme.of(context).platform == TargetPlatform.iOS
                          ? Colors.blue
                          : Colors.white,
                ),
              ),
              ListTile(
                title: Text('About Us'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutUs()),
                  );
                },
              ),
              ListTile(
                title: Text('Disclaimer'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Disclaimer()),
                  );
                },
              ),
              // ListTile(
              //   title: Text('Press Release'),
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => PressRelease()),
              //     );

              //     // Update the state of the app
              //     // ...
              //     // Then close the drawer
              //     // Navigator.pop(context);
              //   },
              // ),
              ListTile(
                title: Text('NGO Contact'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Associates(true)),
                  );
                },
              ),
              ListTile(
                title: Text('Contact Us'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Arun()),
                  );
                },
              ),
              ListTile(
                title: Text('Share'),
                onTap: () {
                  Share.share(ShareText);
                },
                trailing: IconButton(
                  icon: Icon(Icons.share_rounded),
                  onPressed: () {
                    Share.share(ShareText);
                  },
                ),
              ),
              ListTile(
                title: Text('Dark Mode'),
                onTap: () async {
                  SharedPreferences preferences =
                      await SharedPreferences.getInstance();
                  await preferences.clear();

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Loginpage()),
                  );
                },
                trailing: Switch(
                  value: Provider.of<AppStateNotifier>(context).isDarkMode,
                  onChanged: (boolVal) {
                    try {
                      Provider.of<AppStateNotifier>(context, listen: false)
                          .updateTheme(boolVal);
                    } catch (ex) {
                      print(ex);
                    }
                  },
                ),
              ),
              ListTile(
                title: Text('LogOut'),
                onTap: () async {
                  SharedPreferences preferences =
                      await SharedPreferences.getInstance();
                  _value = preferences.getStringList("topic");
                  if (_value != null) {
                    unsubscribeToTopic();
                  }

                  await preferences.clear();

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Loginpage()),
                  );
                },
                trailing: IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () {},
                ),
              ),
              ListTile(
                title: Text('How  Its Work'),
                onTap: () async {
                  await launch("https://youtu.be/Xr80Iqkruek");
                },
                trailing: IconButton(
                  icon: Icon(Icons.video_collection_outlined),
                  onPressed: () {},
                ),
              )
            ],
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) => FabCircularMenu(
            alignment: Alignment.bottomRight,
            ringColor: Colors.teal,
            ringDiameter: 200.0,
            ringWidth: 50.0,
            fabSize: 50.0,
            fabElevation: 8.0,
            fabOpenIcon: Icon(Icons.menu, color: Colors.white),
            fabCloseIcon: Icon(Icons.close, color: Colors.white),
            fabMargin: const EdgeInsets.all(20.0),
            animationDuration: const Duration(milliseconds: 800),
            animationCurve: Curves.easeInOutCirc,
            children: <Widget>[
              SizedBox(),
              FloatingActionButton(
                // backgroundColor: Colors.white,
                child: Icon(Icons.home),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Disclaimer()),
                  );
                },
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: _usertype == "NGO"
              ? [Camera(), Needy(), Latest(), LatestNGO()]
              : [Camera(), Needy(), Latest(), Associates(false)],
          controller: _tabController,
        ),
      ),
    );
  }

  void setuser() async {
    final prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString("username");
    if (uid != null && uid.isNotEmpty) {
      setState(() {
        _username = prefs.getString("username");
        _useremail = prefs.getString("useremail");
        _userphotourl = prefs.getString("userphotourl");
        _usertype = prefs.getString("usertype");
      });
    }
  }
}

void showSnack(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      /* action: SnackBarAction(
        label: 'Action',
        onPressed: () {
          // Code to execute.
        },
      ), */
      content: Text(
        content,
        //textAlign: TextAlign.center,
      ),
      duration: const Duration(milliseconds: 1500),
      width: MediaQuery.of(context).size.width - 20, // Width of the SnackBar.
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0, // Inner padding for SnackBar content.
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    ),
  );
}

void showdg(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (context) => new AlertDialog(
      title: new Text(title),
      content: Text(message),
      actions: <Widget>[
        new ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            // dismisses only the dialog and returns nothing
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
          child: new Text('OK'),
        ),
      ],
    ),
  );
}

Future<void> unsubscribeToTopic() async {
  for (var element in _value) {
    var res = await FirebaseMessaging.instance.unsubscribeFromTopic(element);
  }
}
