import 'dart:async';
import 'dart:async' as prefix0;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


abstract class BaseAuth {
  Future<String> signIn(String email, String password);

  Future<String> signUp(String email, String password);

  Future<FirebaseUser> getCurrentUser();

  Future<void> sendEmailVerification();

  Future<void> signOut();

  Future<bool> isEmailVerified();

  Future<FirebaseUser> getUser();

  Future<bool> checkUserState();

  Future<String> googleSignIn();

}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Firestore _db = Firestore.instance;

  Future<String> googleSignIn()async{
    GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
    AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken
    );
    var authresult = await _firebaseAuth.signInWithCredential(credential);
    updateUserData(authresult.user);
    return authresult.user.uid;
  }
  void updateUserData(FirebaseUser user)async{
    DocumentReference ref = _db.collection('users').document(user.uid);

    return ref.setData(
        {
          'uid': user.uid,
          'email': user.email,
          'photoURL': user.photoUrl,
          'displayName': user.displayName,
          'lastSeen': DateTime.now(),
        }, merge: true
    );

  }

  Future<String> signIn(String email, String password) async {
    var authResult = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    updateUserData(authResult.user);
    return  authResult.user.uid;
  }

  Future<String> signUp(String email, String password) async {
    var authResult = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    return authResult.user.uid;
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.isEmailVerified;
  }
  Future<FirebaseUser> getUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }
  Future<bool> checkUserState() async{
    FirebaseUser currentUser = await _firebaseAuth.currentUser();
    try{
      var oldID = await currentUser.getIdToken(refresh: false);
      var newID = await currentUser.getIdToken(refresh: true);
      return true;
    }
    catch(e){
      return false;
    }

  }
}
