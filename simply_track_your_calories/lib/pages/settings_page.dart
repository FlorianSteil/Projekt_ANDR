import 'package:flutter/material.dart';
import 'package:simply_track_your_calories/pages/root_page.dart';
import 'package:simply_track_your_calories/services/authentication.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'dart:io';

import 'dart:math' as math;

class SettingsPage extends StatefulWidget {
SettingsPage({Key key, this.auth, this.userId, this.onSignedOut})
    : super(key: key);

final BaseAuth auth;
final VoidCallback onSignedOut;
final String userId;

@override
State<StatefulWidget> createState() => new _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with SingleTickerProviderStateMixin {

  void initState() {
    super.initState();
  }
 _deletUser()async{
    try{

    }
    catch(e){
      print(e);
    }
 }
  _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
      Navigator.pop(context);
    } catch (e) {
      print(e);
    }
  }

  TextStyle _style(){
    return TextStyle(
        fontWeight: FontWeight.bold
    );
  }

  String getBannerAdUnitId() {
    if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-7865620503229955/8376251106';
    }
    return null;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Settings'),
      actions: <Widget>[
      new FlatButton(
      child: new Text('Logout',
      style: new TextStyle(fontSize: 17.0, color: Colors.black)),
      onPressed: _signOut)
      ],
      ),
      body:
      Container(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 20,),


                  SizedBox(height: 20,),
                  Text("General informations"),
                  SizedBox(height: 4,),
                  Text("Hey, i´m Florian...", style: _style(),),//Thanks for using my app. If you like the app please let me know.

                  Divider(color: Colors.grey,),
                  buttonSection(),
                  Divider(color: Colors.grey,),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget> [
                  RaisedButton(onPressed: _showDeletDialog, color: Colors.white, child:
                   Container(
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.restore_from_trash,color: Colors.red,),
                        Text("Deactivate Account", style: TextStyle(
                           color: Colors.black,
                        ) ,)
                      ],
                    ),
                  )
                  ),]),
                  Divider(color: Colors.grey,),
                  Center( child: InkWell(
                    child: Text("Privacy policy", style: TextStyle(
                      fontSize: 20,
                        color: Colors.black
                    ),),
                    onTap: () { _launchURLinside("https://florian-steil.com/datenschutz.html");},
                  ),),
                  Divider(color: Colors.grey,),
                  Center(
                    child: AdmobBanner(
                        adUnitId: getBannerAdUnitId(),
                        adSize: AdmobBannerSize.LARGE_BANNER

                    ),
                  )
          ],
        ),),]),
      ),
    );
  }
  Column _buildButtonColumn(Color color, IconData icon, String label, String url) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget> [
        IconButton(
          icon:Icon(icon),
          color: color,
          onPressed: () {
            (label == "Form")?
                _launchURLinside(url):
            _launchURL(url);
          },
        ),
        Text(label)
      ],
    );
  }
  Container buttonSection() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildButtonColumn(Colors.grey, FontAwesomeIcons.wpforms, 'Form', 'https://docs.google.com/forms/d/e/1FAIpQLSfB4LYh_0C7NO2a5Uxodx0WPB7CkoaFilCsox_ung67X2YQjg/viewform?usp=sf_link'),
          _buildButtonColumn(Colors.grey, FontAwesomeIcons.googlePlay, 'Google Play', 'https://florian-steil.com/forwarding/trackyourcalories.php'),
          _buildButtonColumn(Colors.grey, FontAwesomeIcons.github, "Github", 'https://github.com/FlorianSteil'),
          _buildButtonColumn(Colors.grey, FontAwesomeIcons.patreon, "Patron", 'https://www.patreon.com/floriansteil'),
          _buildButtonColumn(Colors.grey, FontAwesomeIcons.paypal, "Paypal", 'https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=6BVR67UPNAWUY&source=url'),
        ],
      ),
  );}
  void _showDeletDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Deactivate account"),
            content: new Text("Are you sure? You want to deactivate the account?"),
            actions: <Widget>[
              new FlatButton(
                child: new Text("Cancel"),
                color: Colors.black,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text("Deactivate"),
                color: Colors.red,
                onPressed: () {
                  _signOut();
                  Navigator.of(context).pop();
                  _deletUser();
                },
              ),
            ],
          );
        });
  }
}

_launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
_launchURLinside(String url) async {
  if (await canLaunch(url)) {
    await launch(url, forceWebView: true, forceSafariVC: true, enableJavaScript: true);
  } else {
    throw 'Could not launch $url';
  }
}