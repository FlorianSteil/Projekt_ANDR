import 'package:flutter/material.dart';
import 'package:simply_track_your_calories/services/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simply_track_your_calories/pages/settings_page.dart';
import 'package:simply_track_your_calories/widgets/dayly_widget.dart';
import 'package:simply_track_your_calories/widgets/overview_widget.dart';
import 'root_page.dart';
import 'package:simply_track_your_calories/modal/meal.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:admob_flutter/admob_flutter.dart';

@immutable
class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;


  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _Page {
  _Page({this.widget});
  final StatefulWidget widget;
}



class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin{
  final Firestore _db = Firestore.instance;
  final _formKey = new GlobalKey<FormState>();
  bool _isLoading;
  bool _secPage;
  Meal newMeal = new Meal();

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }
  void _validateAndSubmit() async {

    if (_validateAndSave()) {
      setState(() {
        _isLoading = true;
      });
      try {

          print("Save new Pos");
          _addMealCurrentDay(newMeal);
          Navigator.pop(context);
        setState(() {
          _isLoading = false;
        });

      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  @override
  void initState() {
    super.initState();
    _isLoading = false;
    _secPage = false;
    _checkEmailVerification();
    _controller = TabController(vsync: this, length: _allPages.length);

  }

  static String userID = AuthID.id;


  List<_Page> _allPages = <_Page>[ //fill it
    _Page(widget:  DaylyWidget(userId: userID )),
    _Page(widget: OverviewWidget())
  ];

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isEmailVerified = false;
  bool _isAccountaktive = false;
  TabController _controller;



  void _checkEmailVerification() async {
    _isEmailVerified = await widget.auth.isEmailVerified();
    _isAccountaktive = await widget.auth.checkUserState();
    if (!_isEmailVerified) {
      _showVerifyEmailDialog();
    }
    else{
      if(!_isAccountaktive){
        _signOut();
      }
    }

  }

  void _resentVerifyEmail(){
    widget.auth.sendEmailVerification();
    _showVerifyEmailSentDialog();
  }

  void _showVerifyEmailDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content: new Text("Please verify account in the link sent to email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Resent link"),
              onPressed: () {
                Navigator.of(context).pop();
                _resentVerifyEmail();
              },
            ),
          ],
        );
      },
    );
  }
 void _showMealDialog() {
       showDialog(
         context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child:
                        Padding(
                          padding: EdgeInsets.fromLTRB(8, 5, 5,0) ,
                            child: Text("Add a meal"),
                        ),
                  ),
              Padding(
              padding: const EdgeInsets.fromLTRB(5, 12, 5,30),
              child:
                  TextFormField(
                    maxLines: 1,
                    keyboardType: TextInputType.emailAddress,
                    autofocus: false,
                    decoration: new InputDecoration(
                        hintText: 'Title',
                        icon: new Icon(
                          Icons.label,
                          color: Colors.grey,
                        )),
                    validator: (value) => value.isEmpty ? 'Title can\'t be empty' : null,
                    onSaved: (value) => newMeal.title =  value.trim(),
                  ),),
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 0, 5,30),
                child:
                TextFormField(
                    maxLines: 1,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      WhitelistingTextInputFormatter(RegExp("[0-9]")),],
                    autofocus: false,
                    decoration: new InputDecoration(
                        hintText: 'Calories',
                        icon: new Icon(
                          Icons.restaurant_menu,
                          color: Colors.grey,
                        )),
                    validator: (value) => value.isEmpty ? 'Calories can\'t be empty' : null,
                    onSaved: (value) => newMeal.calries =  int.parse(value.trim(),),
                  ),),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                     Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: FlatButton(
                      color: Colors.white,
                      child: Text("Close",style: TextStyle(color: Colors.green[800]),),
                      onPressed: () {Navigator.pop(context);},
                    ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: FlatButton(
                        color: Colors.white,
                        child: Text("Add",style: TextStyle(color: Colors.green[800]),),
                        onPressed: () {_validateAndSubmit();},
                      ),),
                      ],),
                ],
              ),
            ),
          );
  },);
  }
  void _addMealCurrentDay(Meal newMeal) async {
    DocumentReference ref = _db.collection('users').document(widget.userId).collection('data').document(DateFormat('yyyy-MM-dd | HH:mm:ss').format(DateTime.now()));
    return await ref.setData(
        {
          'name': newMeal.title,
          'calories': newMeal.calries,
          'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'time': DateFormat('HH:mm:ss').format(DateTime.now()),
        }, merge: true
    );

  }
  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content: new Text("Link to verify account has been sent to your email"),
        );
      },
    );
  }
  _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[800],
        child: const Icon(Icons.add, color: Colors.white,), onPressed: () {
          if(_controller.index == 0)
                _showMealDialog();
          },),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 4.0,
        child: new Row( //
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(icon: Icon(Icons.menu), onPressed: (){_showModal();}),
            IconButton(icon: Icon(Icons.settings), onPressed: () {Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage(  userId: widget.userId, auth: widget.auth, onSignedOut: widget.onSignedOut)),
            );
            ;},),
          ],
        ),
      ),
      body: Stack(
          children: <Widget>[TabBarView(
          controller: _controller,
          children: _allPages.map<Widget>((_Page page) {
            return SafeArea(
              top: false,
              bottom: false,
              child: Container(
                  key: ObjectKey(page.widget),
                  padding: const EdgeInsets.all(0.0),
                  child: page.widget),
            );
          }).toList()),
            _showCircularProgress(),
          ],),
    );
  }
  Widget _showCircularProgress(){
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    } return Container(height: 0.0, width: 0.0,);

  }
  void _showModal() {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new ListTile(
                leading: new Icon(Icons.today),
                title: new Text('Current Day'),
                onTap: () {
                  _controller.animateTo(0);
                  Navigator.pop(context);
                },
              ),
              new ListTile(
                leading: new Icon(Icons.calendar_today),
                title: new Text('Overview'),
                onTap: () {
                  _controller.animateTo(1);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
}

