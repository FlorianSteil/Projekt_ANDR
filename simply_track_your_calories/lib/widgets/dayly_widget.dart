import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simply_track_your_calories/modal/meal.dart';
import 'package:intl/intl.dart';
import '../pages/root_page.dart';
import 'package:simply_track_your_calories/services/authentication.dart';
import 'package:flutter/services.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'dart:io';

class DaylyWidget extends StatefulWidget {
  DaylyWidget({Key key, this.auth, this.userId})
      : super(key: key);


  final BaseAuth auth;
  final String userId;
  @override
  State<DaylyWidget> createState() => _DaylyWidgetState();
}

class _DaylyWidgetState extends State<DaylyWidget > with SingleTickerProviderStateMixin{
  final Firestore _db = Firestore.instance;
  String id = AuthID.id;
  //var tmp = _db.collection('users').document('uid').collection('data').document(DateTime.now().toString()).snapshots();
  void initState() {
    super.initState();

  }

  TextStyle _style(){
    return TextStyle(
        fontWeight: FontWeight.bold
    );
  }
  //_db.collection('users').document(id).collection('data').where('date', isEqualTo: '2019-09-13').snapshots(),
  //
  // CustomAppBar(),

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          children:<Widget>[
          CustomAppBar(),
          new ListPage(),
    ])
 );
  }
}
   // _db.collection('users').document(id).collection('data').where('date', isEqualTo: _date).getDocuments();
class ListPage extends StatefulWidget{
 ListPage({Key key})
      : super(key: key);

  String id =  AuthID.id;
  String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  State<ListPage> createState() => _ListPageState();
}
class _ListPageState extends State<ListPage> {
  int titleCount;
  bool _isLoading;

  void initState() {
    super.initState();
    titleCount = 0;
    _isLoading = false;
  }
  String getBannerAdUnitId() {
    if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-7865620503229955/8376251106';
    }
    return null;
  }
  Widget _showCircularProgress(){
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.black),));
    } return Container(height: 0.0, width: 0.0,);

  }
  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
        stream: Firestore.instance.collection('users').document(widget.id).collection('data').where('date', isEqualTo: widget.date).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
          if(!snapshot.hasData) {_isLoading = true; return _showCircularProgress();}
          return Expanded( child: new ListView(
            children: snapshot.data.documents.map((document){
              titleCount++;
              if(titleCount%6 == 0 && titleCount !=0){
               return Column( children: <Widget>[
                 AdmobBanner(
                     adUnitId: getBannerAdUnitId(),
                     adSize: AdmobBannerSize.BANNER

                 ),
                 new ListTile(
                  leading: Container(
                    padding: EdgeInsets.only(right: 12.0, top: 10,bottom: 10),
                    decoration: new BoxDecoration(
                        border: new Border(
                            right: new BorderSide(width: 1.0, color: Colors.green[200]))),
                    child: new Text(document['time'].toString().substring(0,5)),),
                  title: Row(
                    children: <Widget>[
                      new Text(document['name'],style: TextStyle(
                        fontSize: 20,
                      )),
                    ],
                  ),
                  subtitle: Row(
                    children: <Widget>[

                      new Text(document['calories'].toString(),style: TextStyle(
                        fontSize: 15,
                      )),
                    ],
                  ),
                  trailing: new  IconButton(
                      icon: Icon(Icons.edit),
                      tooltip: 'Edit Meal',
                      onPressed: () {_showMealDialog(document);}),
                ),]);
              }
              else return new ListTile(
                  leading: Container(
                        padding: EdgeInsets.only(right: 12.0, top: 10,bottom: 10),
                        decoration: new BoxDecoration(
                        border: new Border(
                        right: new BorderSide(width: 1.0, color: Colors.green[200]))),
                        child: new Text(document['time'].toString().substring(0,5)),),
               title: Row(
                 children: <Widget>[
                   new Text(document['name'],style: TextStyle(
                  fontSize: 20,
                 )),
                 ],
               ),
               subtitle: Row(
                 children: <Widget>[

                   new Text(document['calories'].toString(),style: TextStyle(
                     fontSize: 15,
                   )),
                 ],
               ),
                trailing: new  IconButton(
                                    icon: Icon(Icons.edit),
                                    tooltip: 'Edit Meal',
                                    onPressed: () {_showMealDialog(document);}),
             );
            }).toList().reversed.toList(),
          ),);
        }
    )
      ;
  }
  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }
  void _validateAndSubmit(DocumentSnapshot doc, Meal editMeal) async {

    if (_validateAndSave()) {
      try {
        print("Save new Pos");
        _updateMealCurrentDay(doc, editMeal);
        Navigator.pop(context);
      } catch (e) {
        print('Error: $e');
      }
    }
  }
  _deleteMealCurrentDay(DocumentSnapshot doc) async{
    await Firestore.instance
        .collection('users')
        .document(widget.id)
        .collection('data')
        .document(doc.documentID)
        .delete();
    Navigator.pop(context);
  }
  _updateMealCurrentDay(DocumentSnapshot doc, Meal editMeal) async{
    String name;
    int calories;
    if(editMeal.title != null && editMeal.title.length >= 1){
      name = editMeal.title;
    }
    else {
      name = doc['name'];
    }
    if(editMeal.calries != null && editMeal.calries > 0){
      calories = editMeal.calries;
    }
    else {
      calories =  doc['calories'];
    }
    await Firestore.instance
        .collection('users')
        .document(widget.id)
        .collection('data')
        .document(doc.documentID)
        .updateData({'name': name, 'calories': calories});
  }
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Meal editmeal = new Meal();
  void _showMealDialog(DocumentSnapshot doc) {
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
                    keyboardType: TextInputType.text,
                    autofocus: false,
                    decoration: new InputDecoration(
                        hintText: doc['name'],
                        icon: new Icon(
                          Icons.label,
                          color: Colors.grey,
                        )),
                      onSaved: (value) => editmeal.title =  value.trim(),
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
                        hintText: doc['calories'].toString(),
                        icon: new Icon(
                          Icons.restaurant_menu,
                          color: Colors.grey,
                        )),
                    onSaved: (value) => editmeal.calries = (value.isEmpty ? 0 : int.parse(value.trim())),
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
                        child: Text("Delete",style: TextStyle(color: Colors.red),),
                        onPressed: () { _deleteMealCurrentDay(doc);},
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: FlatButton(
                        color: Colors.white,
                        child: Text("Save",style: TextStyle(color: Colors.green[800]),),
                        onPressed: () {_validateAndSubmit(doc, editmeal);},
                      ),),
                  ],),
              ],
            ),
          ),
        );
      },);
  }
}

class CustomAppBar extends StatelessWidget
    with PreferredSizeWidget{
  String id =  AuthID.id;
  String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  @override
  Size get preferredSize => Size(double.infinity, 320);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: MyClipper(),
      child: Container(
        padding: EdgeInsets.only(top: 18,bottom: 10),
        decoration: BoxDecoration(
            color: Colors.green[800],
            boxShadow: [
              BoxShadow(
                  color: Colors.blue,
                  blurRadius: 20,
                  offset: Offset(0, 0)
              )
            ]
        ),
        child: Column(
          children: <Widget>[
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:<Widget>[
              Padding(
            padding: EdgeInsets.only(top: 18,bottom: 15),
                child:
                  Column(
                    children: <Widget>[
                    Text("Simply track your calories", style: TextStyle(
                          fontSize: 25,
                          color: Colors.white
                      ),),
                    ],
                  ),
              ),  ]
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 2,bottom: 20),
                  child:
                Column(
                  children: <Widget>[
                    Text("Today", style: TextStyle(
                        color: Colors.white
                    ),),
                    new StreamBuilder(
                        stream: Firestore.instance.collection('users').document(id).collection('data').where('date', isEqualTo: date).snapshots(),
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                          if(!snapshot.hasData) return new Text('Is loading');
                          double tmpSUm =calcSum(snapshot);
                          return  new Text(tmpSUm.toString()+' Kcal',style: TextStyle(
                            fontSize: 26,
                            color: Colors.white
                            ,),);
                        }
                    )
                   /* Text(SumCal.sumCal.toString(), style: TextStyle(
                        fontSize: 26,
                        color: Colors.white
                    ,),)*/
                  ],
                ),),

              ],
            ),
          ],
        ),
      ),
    );
  }
}



class MyClipper extends CustomClipper<Path>{

  @override
  Path getClip(Size size) {
    Path p = Path();
    p.lineTo(0.0, size.height );
    p.lineTo(size.width, size.height );
    p.lineTo(size.width, 0.0);

    p.close();

    return p;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
calcSum(AsyncSnapshot<QuerySnapshot> snapshot) {
  double tmpsum= 0;
  var docList = snapshot.data.documents.toList();
  int tmpL = docList.length;
  for(int a=0; a< tmpL;a++){
    tmpsum +=   docList[a].data['calories'];
  }
  return tmpsum;
}