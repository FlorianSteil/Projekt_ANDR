import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simply_track_your_calories/modal/meal.dart';
import 'package:intl/intl.dart';
import '../pages/root_page.dart';
import 'package:simply_track_your_calories/services/authentication.dart';

import 'package:flutter/services.dart';


class Edit_Page extends StatefulWidget {
  Edit_Page({Key key, this.snapshot, this.sum})
      : super(key: key);

  AsyncSnapshot<QuerySnapshot>  snapshot;
  double sum;

  @override
  State<StatefulWidget> createState() => new _Edit_PageState();
}

class _Edit_PageState extends State<Edit_Page> with SingleTickerProviderStateMixin {

  static AsyncSnapshot<QuerySnapshot>  snapshot;
  static double sum;

  void initState() {
    snapshot = widget.snapshot;
    sum = widget.sum;
    super.initState();

  }
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation:
        FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green[800],
          child: const Icon(Icons.add, color: Colors.white,), onPressed: () {
          _showNewMealDialog(snapshot);
        },),
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: 4.0,
          child: new Row( //
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(icon: Icon(Icons.menu),color: Colors.white , onPressed: (){}),
              IconButton(icon: Icon(Icons.settings), color: Colors.white, onPressed: () {},),
            ],
          ),
        ),
      body:Column(
          children:<Widget>[
            CustomAppBar(date: snapshot.data.documents[0].documentID.substring(0,10),),
            new ListPage(snapshot: snapshot, sum: sum,),
          ])
    );

  }
  Meal newMeal = new Meal();
  AsyncSnapshot<QuerySnapshot>  globalSnapshot;
  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }
  void _addMealCurrentDay(Meal newMeal,AsyncSnapshot<QuerySnapshot>  snapshot) async {
    String id = AuthID.id;
    DocumentReference ref = Firestore.instance.collection('users').document(id).collection('data').document((snapshot.data.documents[0].documentID.substring(0,13)+DateFormat('HH:mm:ss').format(DateTime.now())));
    return await ref.setData(
        {
          'name': newMeal.title,
          'calories': newMeal.calries,
          'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'time': DateFormat('HH:mm:ss').format(DateTime.now()),
        }, merge: true
    );

  }

  void _validateAndSubmit() async {

    if (_validateAndSave()) {
      try {
        print("Save new Pos");
        _addMealCurrentDay(newMeal,globalSnapshot);
        Navigator.pop(context);
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  final _formKey = new GlobalKey<FormState>();
  void _showNewMealDialog(AsyncSnapshot<QuerySnapshot>  snapshot) {
    globalSnapshot = snapshot;
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
                        color: Colors.green[800],
                        child: Text("Close",style: TextStyle(color: Colors.green),),
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
}
class ListPage extends StatefulWidget{
  ListPage({Key key, this.snapshot, this.sum})
      : super(key: key);

  final AsyncSnapshot<QuerySnapshot>  snapshot;
  final double sum;
  String id =  AuthID.id;


  State<StatefulWidget> createState() => new _ListPageState();
}

class _ListPageState extends State<ListPage> {
  static AsyncSnapshot<QuerySnapshot>  snapshot;
  static double sum;
  void initState() {
    snapshot = widget.snapshot;
    sum = widget.sum;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
        stream: Firestore.instance.collection('users').document(widget.id).collection('data').where('date', isEqualTo: snapshot.data.documents[0].documentID.substring(0,10)).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
          if(!snapshot.hasData) return new Text('Is loading');
          return Expanded( child: new ListView(
            children: snapshot.data.documents.map((document){
              return new ListTile(
                leading: Container(
                  padding: EdgeInsets.only(right: 12.0, top: 28),
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
            }).toList(),
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
class CustomAppBar extends StatelessWidget with PreferredSizeWidget{
  CustomAppBar({Key key, this.date})
      : super(key: key);
  final String date;
  String id =  AuthID.id;
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:<Widget>[
                  IconButton(icon: new Icon(Icons.arrow_back, color: Colors.white,), onPressed: (){Navigator.pop(context);}),
                ]
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 2,bottom: 30),
                  child:
                  Column(
                    children: <Widget>[
                      Text(date, style: TextStyle(
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