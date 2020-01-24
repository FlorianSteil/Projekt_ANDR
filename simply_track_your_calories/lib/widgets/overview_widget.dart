import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simply_track_your_calories/modal/meal.dart';
import 'package:intl/intl.dart';
import 'package:simply_track_your_calories/pages/edit_page.dart';
import '../pages/root_page.dart';
import 'package:simply_track_your_calories/services/authentication.dart';
import 'package:flutter/services.dart';

class OverviewWidget extends StatefulWidget {
  @override
  _OverviewWidgetState createState() => _OverviewWidgetState();
}

class _OverviewWidgetState extends State<OverviewWidget> {

  final Firestore _db = Firestore.instance;
  String id = AuthID.id;

  //var tmp = _db.collection('users').document('uid').collection('data').document(DateTime.now().toString()).snapshots();
  void initState() {
    super.initState();
  }

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
class ListPage extends StatefulWidget{
  ListPage({Key key})
      : super(key: key);

  String id =  AuthID.id;
  String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  State<ListPage> createState() => _ListPageState();
}
class _ListPageState extends State<ListPage> {
   static DateTime dateToday = new DateTime.now();
   bool _isLoading;
  //var divDays = dateList.length;

   void initState() {
     super.initState();
     _isLoading = false;
   }
   void _addMealCurrentDay(Meal newMeal,String date) async {
     String id = AuthID.id;
     DocumentReference ref = Firestore.instance.collection('users').document(id).collection('data').document(date+DateFormat(' | HH:mm:ss').format(DateTime.now()));
     return await ref.setData(
         {
           'name': newMeal.title,
           'calories': newMeal.calries,
           'date': date,
           'time': DateFormat('HH:mm:ss').format(DateTime.now()),
         }, merge: true
     );

   }
   Meal newMeal = new Meal();
   bool _validateAndSave() {
     final form = _formKey.currentState;
     if (form.validate()) {
       form.save();
       return true;
     }
     return false;
   }

   void _validateAndSubmit(String date) async {

     if (_validateAndSave()) {
       try {
         print("Save new Pos");
         _addMealCurrentDay(newMeal,date);
         Navigator.pop(context);
       } catch (e) {
         print('Error: $e');
       }
     }
   }

   final _formKey = new GlobalKey<FormState>();
   void _showNewMealDialog(String date) {
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
                         onPressed: () {_validateAndSubmit(date);},
                       ),),
                   ],),
               ],
             ),
           ),
         );
       },);
   }
   Widget _showCircularProgress(){
     if (_isLoading) {
       return Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.black)));
     } return Container(height: 0.0, width: 0.0,);

   }
  @override
  Widget build(BuildContext context) {
    return new Expanded( child: ListView.builder(
       reverse: false,
        itemCount: 32,
      itemBuilder: (BuildContext ctxt, int Index) {
        return new StreamBuilder(
                stream: Firestore.instance.collection('users').document(widget.id).collection('data').where('date', isEqualTo: DateFormat('yyyy-MM-dd').format(dateToday.add(new Duration(days: -(Index))))).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                  if(!snapshot.hasData) {_isLoading = true; return _showCircularProgress() ;}
                  double tmpSUm =calcSum(snapshot);
                  return  new ListTile(
                    leading: Container(
                      padding: EdgeInsets.only(right: 12.0, top: 5),
                      decoration: new BoxDecoration(
                          border: new Border(
                              right: new BorderSide(width: 1.0, color: Colors.green[200]))),
                      child: new Column(
                        children: <Widget>[
                          new Text(weekday(dateToday.add(new Duration(days: -(Index))).weekday),style: TextStyle(
                            fontSize: 26,
                            color: Colors.green
                            ,)),
                          new Text(DateFormat('dd-MM-yyyy').format(dateToday.add(new Duration(days: -(Index)))))
                        ],
                      )
                     ,),
                    title: Text(tmpSUm.toString()+' Kcal',style: TextStyle(
                    fontSize: 26,
                    color: Colors.black
                    ,),
                    ),
                    trailing: (tmpSUm>0) ? new IconButton(
                      icon: Icon(Icons.edit),
                      tooltip: 'Edit Meal',
                      onPressed:  () {Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  new Edit_Page(snapshot: snapshot, sum: tmpSUm)),
                      );
                      }): new IconButton(
                        icon: Icon(Icons.add),
                        tooltip: 'Edit Meal',
                        onPressed:  () {_showNewMealDialog(DateFormat('yyyy-MM-dd').format(dateToday.add(new Duration(days: -(Index)))));}
                        )
                    );
                }

        );
      }
    ));
  }
}
String weekday (int numOFDay){
  switch(numOFDay){
    case 1:
      return "MO";
    case 2:
      return "TU";
    case 3:
      return "WE";
    case 4:
      return "TH";
    case 5:
      return "FR";
    case 6:
      return "SA";
    case 7:
      return "SU";
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
                    padding: EdgeInsets.only(top: 18,bottom: 25),
                    child:
                    Column(
                      children: <Widget>[
                        Text("Overview", style: TextStyle(
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
                  padding: EdgeInsets.only(top: 2,bottom: 0),
                  child:
                  Column(
                    children: <Widget>[
                      /*Text("This week", style: TextStyle(
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
                    ,),)*/*/
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

calcSum(AsyncSnapshot<QuerySnapshot> snapshot) {
  double tmpsum= 0;
  var docList = snapshot.data.documents.toList();
  int tmpL = docList.length;
  for(int a=0; a< tmpL;a++){
    tmpsum +=   docList[a].data['calories'];
  }
  return tmpsum;
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
