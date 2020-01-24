import 'package:flutter/material.dart';
import 'package:simply_track_your_calories/services/authentication.dart';
import 'package:url_launcher/url_launcher.dart';


class LoginSignUpPage extends StatefulWidget {
  LoginSignUpPage({this.auth, this.onSignedIn});

  final BaseAuth auth;
  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() => new _LoginSignUpPageState();
}

enum FormMode { LOGIN, SIGNUP }

class _LoginSignUpPageState extends State<LoginSignUpPage> {
  final _formKey = new GlobalKey<FormState>();

  String _email;
  String _password;
  String _errorMessage;

  // Initial form is login form
  FormMode _formMode = FormMode.LOGIN;
  bool _isIos;
  bool _isLoading;
  bool datenschutz;

  // Check if form is valid before perform login or signup
  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // Perform login or signup
  void _validateAndSubmit() async {

    if (_validateAndSave()) {
      setState(() {
        _errorMessage = "";
        _isLoading = true;
      });
      String userId = "";
      try {
        if(datenschutz) {
          if (_formMode == FormMode.LOGIN) {
            userId = await widget.auth.signIn(_email, _password);
            print('Signed in: $userId');
          } else {
            userId = await widget.auth.signUp(_email, _password);
            widget.auth.sendEmailVerification();
            _showVerifyEmailSentDialog();
            print('Signed up user: $userId');
          }
          setState(() {
            _isLoading = false;
          });

          if (userId.length > 0 && userId != null &&
              _formMode == FormMode.LOGIN) {
            widget.onSignedIn();
          }
        }
        else{
          _errorMessage = "Please accept the privacy policy!";
          _isLoading = false;
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          if (_isIos) {
            _errorMessage = e.details;
          } else
            _errorMessage = e.message;
        });
      }
    }
  }

  // Perform login or signup with Google
  void _validateAndSubmitwithGoogle() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    String userId = "";
    try {
      if(datenschutz){
        userId = await widget.auth.googleSignIn();
        print('Signed in: $userId');
        setState(() {
          _isLoading = false;
        });

        if (userId.length > 0 && userId != null && _formMode == FormMode.LOGIN) {
          widget.onSignedIn();
        }
      }
      else{
        _errorMessage = "Please accept the privacy policy!";
        _isLoading = false;
      }

    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
        if (_isIos) {
          _errorMessage = e.details;
        } else
          _errorMessage = e.message;
      });
    }

  }

  @override
  void initState() {
    _errorMessage = "";
    datenschutz = false;
    _isLoading = false;
    super.initState();
  }

  void _changeFormToSignUp() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.SIGNUP;
    });
  }

  void _changeFormToLogin() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.LOGIN;
    });
  }

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return new Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.green[800],
        ),
        body: Stack(
          children: <Widget>[
            _showBody(),
            _showCircularProgress(),
          ],
        ));
  }

  Widget _showCircularProgress(){
    if (_isLoading) {
      return Center(child: CircularProgressIndicator( valueColor: new AlwaysStoppedAnimation<Color>(Colors.green[800]),));
    } return Container(height: 0.0, width: 0.0,);

  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content: new Text("Link to verify account has been sent to your email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                _changeFormToLogin();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _showBody(){
    return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          key: _formKey,
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              _showLogo(),
              _showWelcome(),
              _showEmailInput(),
              _showPasswordInput(),
              _showErrorMessage(),
              _showDatenschutz(),
              _showPrimaryButton(),
              _showGoogleButton(),
              _showSecondaryButton(),
            ],
          ),
        ));
  }

  Widget _showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Padding(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
        child:
        Text(
          _errorMessage,
          style: TextStyle(
              fontSize: 13.0,
              color: Colors.red,
              height: 1.0,
              fontWeight: FontWeight.w300),
        ),);
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget _showLogo() {
    return new Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 60.0,
          child: Image.asset('assets/flutter-icon.png'),
        ),
      ),
    );
  }
  Widget _showWelcome() {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
    Container(
    padding: EdgeInsets.fromLTRB(0,70,0,5),
        child:
        Text('Welcome to Simply track your calories!',style: new TextStyle(fontSize: 25),)
    ),
    Text('Create an account to synchronize your calories between all devices.',style: new TextStyle(fontSize: 12),)
      ],
    );
  }

  Widget _showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Email',
            icon: new Icon(
              Icons.mail,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: (value) => _email =  value.trim(),
      ),
    );
  }

  Widget _showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Password',
            icon: new Icon(
              Icons.lock,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
        onSaved: (value) => _password = value.trim(),
      ),
    );
  }

  Widget _showSecondaryButton() {
    return new FlatButton(
      child: _formMode == FormMode.LOGIN
          ? new Text('Create an account',
          style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300))
          : new Text('Have an account? Sign in',
          style:
          new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)),
      onPressed: _formMode == FormMode.LOGIN
          ? _changeFormToSignUp
          : _changeFormToLogin,
    );
  }

  Widget _showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.green,
            child: _formMode == FormMode.LOGIN
                ? new Text('Login',
                style: new TextStyle(fontSize: 20.0, color: Colors.white))
                : new Text('Create account',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: _validateAndSubmit,
          ),
        ));
  }
  Widget _showGoogleButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.white,
            child: _formMode == FormMode.LOGIN
                ? new Text('Login with Google',
                style: new TextStyle(fontSize: 20.0, color: Colors.black))
                : new Text('Login with Google',
                style: new TextStyle(fontSize: 20.0, color: Colors.black)),
            onPressed: _validateAndSubmitwithGoogle,
          ),
        ));
  }
  Widget _showDatenschutz() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
        child: _formMode == FormMode.SIGNUP
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Checkbox(
                          checkColor: Colors.green,
                          value: datenschutz,
                          onChanged: (bool value) {
                            setState(() {
                              datenschutz = value;
                            });
                          },
                        ),
                        Text("Accept the "),
                        InkWell(
                          child: Text("privacy policy", style: TextStyle(
                              color: Colors.blue
                          ),),
                          onTap: () { _launchURL("https://florian-steil.com/datenschutz.html");},
                        ),
                      ],
                    )
                    ],
                  )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Checkbox(
                  checkColor: Colors.green,
                  value: datenschutz,
                  onChanged: (bool value) {
                    setState(() {
                      datenschutz = value;
                    });
                  },
                ),
                Text("Accept the "),
                InkWell(
                  child: Text("privacy policy", style: TextStyle(
                      color: Colors.blue
                  ),),
                  onTap: () { _launchURL("https://florian-steil.com/datenschutz.html");},
                ),
              ],
            )
          ],
        ),
    );
  }

}

_launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url, forceWebView: true, forceSafariVC: true, enableJavaScript: true);
  } else {
    throw 'Could not launch $url';
  }
}
