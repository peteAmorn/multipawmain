import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:multipawmain/authScreenWithoutPet.dart';
import 'package:multipawmain/tutorial/introScreen.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multipawmain/pages/register/register.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'chat/chatroom.dart';
import 'database/users.dart';
import 'package:sizer/sizer.dart';

final GoogleSignIn googleSignIn = new GoogleSignIn();
final firebase_storage.Reference storageRef = firebase_storage.FirebaseStorage.instance.ref();

final usersRef = FirebaseFirestore.instance.collection('users');
final petsRef = FirebaseFirestore.instance.collection('pets');
final petsIndexRef = FirebaseFirestore.instance.collection('petsIndex');
final myPetsIndex = FirebaseFirestore.instance.collection('myPetsIndex');
final postsPuppyKittenRef = FirebaseFirestore.instance.collection('postsPuppyKitten');
final postsPuppyKittenIndexRef = FirebaseFirestore.instance.collection('postsPuppyKittenIndexRef');
final postsFoodRef = FirebaseFirestore.instance.collection('postsFood');
final chatsRef = FirebaseFirestore.instance.collection('chats');
final commentsRef = FirebaseFirestore.instance.collection('comments');
final activitiesRef = FirebaseFirestore.instance.collection('feeds');
final marketingRef = FirebaseFirestore.instance.collection('marketing');
final notiRef = FirebaseFirestore.instance.collection('notification');

final paymentIndexRef = FirebaseFirestore.instance.collection('paymentIndex');

final buyerOnPrepareRef = FirebaseFirestore.instance.collection('buyerOnPrepareRef');
final buyerOnDispatchRef = FirebaseFirestore.instance.collection('buyerOnDispatchRef');
final buyerOnGuaranteeRef = FirebaseFirestore.instance.collection('buyerOnGuaranteeRef');
final buyerOnReviewRef = FirebaseFirestore.instance.collection('buyerOnReviewRef');
final buyerOnCompleteRef = FirebaseFirestore.instance.collection('buyerOnCompleteRef');
final buyerOnCancelRef = FirebaseFirestore.instance.collection('buyerOnCancelRef');
final buyerOnRefundRef = FirebaseFirestore.instance.collection('buyerOnRefundRef');

final transactionRef = FirebaseFirestore.instance.collection('transaction');

final bannersRef = FirebaseFirestore.instance.collection('banners');
final helpChatRef = FirebaseFirestore.instance.collection('helpChat');
final allHelpChatRef = FirebaseFirestore.instance.collection('helpChatIndex');

final promotionRef = FirebaseFirestore.instance.collection('promotion');
final promotionIndexRef = FirebaseFirestore.instance.collection('promotionIndex');
final loseRef = FirebaseFirestore.instance.collection('moneyLosingRef');

final accountDeleteRef = FirebaseFirestore.instance.collection('reasonToDeleteAccount');
final promoActRef= FirebaseFirestore.instance.collection('promotionAccounts');

final DateTime timestamp = DateTime.now();
Users? currentUser;

class home extends StatefulWidget {
  final currentUserId,isAuth;
  home({this.currentUserId,this.isAuth});
  @override
  _HomeState createState()=> _HomeState();
}

class _HomeState extends State<home> with TickerProviderStateMixin{
  bool isAuth = false;
  String? _getToken,os;
  List<String> dataList =[];
  int? number_of_pet;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;
  bool isLoggingIn = false;
  bool isTablet = false;
  String? UserAccount;
  String? name;
  bool toIntro = false;

  retrieveToken()async{
    _getToken = await FirebaseMessaging.instance.getToken();
  }

  logOut()async{
    try{
      await usersRef.doc(widget.currentUserId).collection('token').doc(_getToken).delete();
      googleSignIn.signOut();
      _auth.signOut();
    }catch(e){}
  }

  void notificationSection() async{
    ///gives you the message on which user taps and it opened the app from terminated state
    var _messaging = FirebaseMessaging.instance;

    // On iOS, this helps to take the user permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      _messaging.getInitialMessage().then((message) {

        //Notification on background work
        FirebaseMessaging.onMessageOpenedApp.listen((message) {

          message.data['type'] == 'chat'
              ?Navigator.push(context, MaterialPageRoute(builder: (context)=>chatroom(
              peerid: message.data['userId'],
              userid: message.data['peerId'],
              userImg: message.data['peerImg'],
              peerImg: message.data['userImg'],
              userName: message.data['peerName'],
              peerName: message.data['userName']
          )))
              :null;
        });

        //Notification on app terminated work
        if (message != null) {
          message.data['type'] == 'chat'
              ?Navigator.push(context, MaterialPageRoute(builder: (context)=>chatroom(
              peerid: message.data['userId'],
              userid: message.data['peerId'],
              userImg: message.data['peerImg'],
              peerImg: message.data['userImg'],
              userName: message.data['peerName'],
              peerName: message.data['userName']
          )))
              :null;
        }
      });
    } else {
      logOut();
    }
  }

  checkAuth() async{
    User user = await _auth.currentUser!;
    final doc = await usersRef.doc(user.uid).get();
    if(doc.exists){
      Future.delayed(const Duration(milliseconds: 500), () {
        if(user!=null){
          usersRef.doc(user.uid).collection('token').where('token',isEqualTo: _getToken).get().then((snapshot){
            if(snapshot.size == 0){
              _getToken == null?null:usersRef.doc(user.uid).collection('token').doc(_getToken).set({
                'platform': os,
                'token':_getToken,
                'timeStamp':timestamp
              });
            }
          });
        }
      });
    }else{
      setState(() {
        isAuth = false;
      });
      try{
        googleSignIn.signOut();
        _auth.signOut();
      }catch(e){}
    }
  }

  checkConnection()async{
    var connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi){
      try{
        checkAuth();
      }catch(e){
        logOut();
      };
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
      SizerUtil.deviceType == DeviceType.tablet?isTablet = true:isTablet = false;
    });
    widget.isAuth == null?null:isAuth = widget.isAuth;

    UserAccount = widget.currentUserId;
    os = Platform.operatingSystem;
    retrieveToken();
    checkConnection();

    widget.currentUserId == null? isAuth = false: isAuth = true;
    notificationSection();

    setState(() {
      isLoading = false;
    });
  }
// <-------------- End of InitState --------------------->

  handleGoogleSignIn(GoogleSignInAccount? account) async{
    if (account !=null) {
      await createUserInFirestoreGoogleAuth();
      setState(() {
        isAuth=true;
      });
    } else {
      setState(() {
        isAuth=false;
      });
    }
  }

  createUserInFirestoreGoogleAuth() async{
    // 1. check if user exists in database based on their id
    final User? user = FirebaseAuth.instance.currentUser;
    final google_user = await googleSignIn.currentUser;


    final doc = await usersRef.doc(user!.uid).get();
    retrieveToken();

    if(!doc.exists){
      // 2. if user doesn't exist, push the user to create account page
      final data = await Navigator.push(context, MaterialPageRoute(builder: (context) => register(isAppleSignin: false)));

      //3. get info from create account page to create new account in user collection
      usersRef.doc(user.uid).set(
          {
            'id': user.uid,
            'name': data[0],
            'email': user.email,
            'location1': data[3],
            'location2': data[4],
            'city': data[5],
            'lat':data[1],
            'lng':data[2],
            'urlProfilePic' : google_user?.photoUrl,
            'admin': 'No',
            'loyaltyPoints': 0,
            'timestamp': timestamp,
            'appleSignIn': false,
          }
      );
      _getToken == null?null:usersRef.doc(user.uid).collection('token').doc(_getToken).set({
        'platform': os,
        'token':_getToken,
        'timeStamp':timestamp
      });
      Navigator.push(context, MaterialPageRoute(builder: (context)=>introScreen(currentUserId:user.uid)));
    }
  }

  createUserInFirestoreAppleAuth() async{
    // 1. check if user exists in database based on their id
    final User? user = FirebaseAuth.instance.currentUser;

    final doc = await usersRef.doc(user!.uid).get();
    if(!doc.exists){
      // 2. if user doesn't exist, push the user to create account page
      final data = await Navigator.push(context, MaterialPageRoute(builder: (context) => register(isAppleSignin: true)));
      //3. get info from create account page to create new account in user collection
      usersRef.doc(user.uid).set(
          {
            'id': user.uid,
            'name': user.email,
            'email': user.email,
            'location1': data[3],
            'location2': data[4],
            'city': data[5],
            'lat':data[1],
            'lng':data[2],
            'urlProfilePic' : '',
            'admin': 'No',
            'loyaltyPoints': 0,
            'timestamp': timestamp,
            'appleSignIn': true,
            'firstLogin':true,
          }
      );
      _getToken == null?null:usersRef.doc(user.uid).collection('token').doc(_getToken).set({
        'platform': os,
        'token':_getToken,
        'timeStamp':timestamp
      });
      Navigator.push(context, MaterialPageRoute(builder: (context)=>introScreen(currentUserId:user.uid)));
    }
  }

  login_with_Apple() async{
    final appleIdCredential =  await SignInWithApple.getAppleIDCredential(scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ]);

    final OAuthProvider oAuthProvider = OAuthProvider('apple.com');
    final credential = oAuthProvider.credential(
        idToken:  appleIdCredential.identityToken,
        accessToken: appleIdCredential.authorizationCode
    );

    await _auth.signInWithCredential(credential);
    retrieveToken();

    if(credential.accessToken!=null){
      final User? user = FirebaseAuth.instance.currentUser;
      final doc = await usersRef.doc(user!.uid).get();
      if(doc.exists){
        setState((){
          doc.data()!['firstLogin'] == null || doc.data()!['firstLogin'] == true
              ? toIntro = true
              : toIntro = false;
          UserAccount = user.uid;
          isAuth = true;
        });
      }else{
        createUserInFirestoreAppleAuth();
      }
    }else{
      setState(() {
        isAuth = false;
      });
    }
  }
  login_with_Gmail() async{
    GoogleSignInAccount? _user;
    final googleUser = await googleSignIn.signIn();
    if(googleUser == null) return;
    _user = googleUser;

    final googleAuth = await _user.authentication;
    final credentail = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await FirebaseAuth.instance.signInWithCredential(credentail);

    if(credentail.accessToken!=null){
      final User? user = FirebaseAuth.instance.currentUser;
      final doc = await usersRef.doc(user!.uid).get();
      if(doc.exists){
        setState((){
          doc.data()!['firstLogin'] == null || doc.data()!['firstLogin'] == true
              ? toIntro = true
              : toIntro = false;
          UserAccount = user.uid;
          isAuth = true;
        });
      }else{
        createUserInFirestoreGoogleAuth();
      }
    }
  }

  Widget build(BuildContext context) {
    return !isAuth
        ? authScreenWithoutPet(pageIndex: 0)
        :toIntro == true
        ? introScreen(currentUserId: UserAccount == null?currentUser?.id:UserAccount)
        :authScreenWithoutPet(currentUserId: widget.currentUserId,pageIndex: 0);
  }
}
