import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_signin_button/button_builder.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multipawmain/authScreenWithoutPet.dart';
import 'package:multipawmain/changeUserName.dart';
import 'package:multipawmain/pages/myPets/myPets.dart';
import 'package:multipawmain/pages/register/register.dart';
import 'package:multipawmain/questionsAndConditions/conditionsLibrary.dart';
import 'package:multipawmain/questionsAndConditions/questionsAboutCanine.dart';
import 'package:multipawmain/setting/contactUs.dart';
import 'package:multipawmain/setting/profileInfo/address/address.dart';
import 'package:multipawmain/setting/profileInfo/deliveryOptionAndStoreAddress.dart';
import 'package:multipawmain/setting/profileInfo/editProfileUserInfo.dart';
import 'package:multipawmain/setting/profileInfo/payment/payment.dart';
import 'dart:io';
import 'package:image/image.dart' as Im;
import 'package:multipawmain/signInWithEmailPage.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/support/handleGettingImage.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:uuid/uuid.dart';
import 'authCheck.dart';
import 'package:sizer/sizer.dart';
import 'database/users.dart';
import 'myshop/petShop/myPetShop.dart';
import 'myshop/storeManagement.dart';

final DateTime timestamp = DateTime.now();
Users? currentUser;
bool? isAuth;

class profileWithoutPet extends StatefulWidget {
  String? userId;
  profileWithoutPet({this.userId});

  @override
  _profileWithoutPetState createState() => _profileWithoutPetState();
}

class _profileWithoutPetState extends State<profileWithoutPet> {
  dynamic picker = ImagePicker();
  File? file;
  bool isLoading = false,toShow = true;
  String? userUrl,userName,_getToken,imageId,os,UserAccount;
  int? itemToPrepare,itemDispatched,itemGuarantee,totalCounter;
  bool isTablet = false;
  String a = '';
  bool? isAppleSignIn;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  retrieveToken()async{
    _getToken = await FirebaseMessaging.instance.getToken();
  }

  getNotiCounter(String userId)async{
    await buyerOnPrepareRef.where('sellerId',isEqualTo: userId).get().then((snap){
      snap.size > 0? itemToPrepare = snap.size:itemToPrepare = 0;
    });
    await buyerOnDispatchRef.where('sellerId',isEqualTo: userId).get().then((snap){
      snap.size > 0? itemDispatched = snap.size:itemDispatched = 0;
    });
    await buyerOnGuaranteeRef.where('sellerId',isEqualTo: userId).get().then((snap){
      snap.size > 0? itemGuarantee = snap.size:itemGuarantee = 0;
    });

    totalCounter = itemToPrepare! + itemDispatched! + itemGuarantee!;

    Future.delayed(const Duration(milliseconds: 150), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  compressImage(File? file) async{
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image? imageFile = Im.decodeImage(file!.readAsBytesSync());
    final compressedImageFile = File('$path/userProfile_$imageId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile!,quality:15));
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImage(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('userProfile_$imageId.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }
    return a;
  }

  clearImage(File? file) {
    if (file == null) return;
    File? tmp_file = File(file.path);
    tmp_file = null;

    setState(() {
      file = tmp_file;
    });
    return tmp_file;
  }

  Container notiAlert(int notiCount) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red.shade900,
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet?10.0:8.0),
        child: Text(notiCount >99?'99+':notiCount.toString(),style: TextStyle(fontSize: isTablet?20.0:16.0,color: Colors.white),),
      ),
    );
  }

  handleSubmitUserImg() async{
    String? imgUrl;

    setState(() {
      isLoading = true;
    });

    // Remove old profile picture
    await usersRef.doc(widget.userId).get().then((snapshot){
      final oldImg = snapshot.data()!['urlProfilePic'];
      if(oldImg == null || oldImg == ''){

      }else{
      try{
        FirebaseStorage.instance.refFromURL(oldImg.toString()).delete();
      }catch(e){

      };}
    });
// Compress and upload new profile picture
    file == null? null: await compressImage(file);
    file == null? null: imgUrl = await uploadImage(file);

    if(file != null){

      // Update a new profile picture
      await usersRef.doc(widget.userId).update({
        'urlProfilePic': imgUrl
      });

      // Update a new profile picture in pets profile
      await petsRef.where('id',isEqualTo: widget.userId).get().then((snapshot){
        snapshot.docs.forEach((data) {
          petsRef.doc(data.id).update({
            'ownerProfile': imgUrl
          });
        });
      });

      // Update a new profile picture in sell post
      await postsPuppyKittenRef.where('id',isEqualTo: widget.userId).get().then((snapshot){
        if(snapshot.size >0){
          snapshot.docs.forEach((data) {
            postsPuppyKittenRef.doc(data.id).update({
              'postOwnerprofileUrl': imgUrl
            });
          });
        }
      });

      // Update a new profile picture in chat
      await usersRef.where('id',isNotEqualTo: widget.userId).get()
          .then((snap) => {
        snap.docs.forEach((docId) {
          usersRef.doc(docId.id).collection('chattingWith').doc(widget.userId).update(
              {
                'profile': imgUrl
              });
        })
      });

      // Update a new profile picture in reviews (comments)
      await commentsRef.where('buyerId',isEqualTo: widget.userId).get()
          .then((snap) => {
        snap.docs.forEach((docId) {
          commentsRef.doc(docId.id).update(
              {
                'buyerProfile': imgUrl
              });
        })
      });
    }
    setState(() {
      isLoading = false;
    });
  }

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
    file = null;

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
    }
    Navigator.push(context, MaterialPageRoute(builder: (context)=>authScreenWithoutPet(pageIndex: 0,currentUserId: user.uid)));
  }

  createUserInFirestoreAppleAuth() async{
    // 1. check if user exists in database based on their id
    final User? user = FirebaseAuth.instance.currentUser;
    final doc = await usersRef.doc(user!.uid).get();
    file = null;

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
    }
    Navigator.push(context, MaterialPageRoute(builder: (context)=>authScreenWithoutPet(pageIndex: 0,currentUserId: user.uid)));
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
          UserAccount = user.uid;
          isAuth = true;
          Navigator.push(context, MaterialPageRoute(builder: (context)=>authScreenWithoutPet(pageIndex: 0,currentUserId: UserAccount)));
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
          UserAccount = user.uid;
          isAuth = true;
        });
      }else{
        createUserInFirestoreGoogleAuth();
      }
      Navigator.push(context, MaterialPageRoute(builder: (context)=>authScreenWithoutPet(pageIndex: 0,currentUserId: user.uid)));
    }
  }


  getUser(String userId)async{
    return await usersRef.doc(userId).get().then((snapshot){
      userUrl = snapshot.data()!['urlProfilePic'];
      userName = snapshot.data()!['name'];
      isAppleSignIn = snapshot.data()!['appleSignIn'];
    });

  }

  SafeArea buildUnAuthScreen() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
          backgroundColor: themeColour,
          body: Column(
            children: [
              Padding(
                  padding: EdgeInsets.only(top: height*0.13,bottom: isTablet?height*0.20 :height*0.09),
                  child: Column(
                    children: [
                      Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 30.0,right: 25,bottom: 25,top: 10),
                            child: Center(
                              child: Container(
                                  width: isTablet?width-width*3/4:width-width*1.9/3,
                                  child: Image.asset('assets/authLogo.png',width: width*0.7,fit: BoxFit.cover)
                              ),
                            ),
                          )
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(height: 50),
                          Text('MULTI',style: TextStyle(color: Colors.white,fontSize: isTablet?63:33,fontWeight: FontWeight.bold,fontFamily: 'Chalkboard SE')),
                          Text('PAWS',style: TextStyle(color: Colors.yellowAccent,fontSize: isTablet?63:33,fontWeight: FontWeight.bold,fontFamily: 'Chalkboard SE'))
                        ],
                      ),
                    ],
                  )
              ),
              SizedBox(height: 40),
              Center(
                  child: SignInButtonBuilder(
                      icon: FontAwesomeIcons.paw,
                      backgroundColor: Colors.black,
                      text: 'Sign in with MultiPaws',
                      onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>signInPage()))
                  )),
              SizedBox(height: 5),
              Platform.isIOS
                  ?Center(
                  child: SignInButton(
                      Buttons.Apple,
                      onPressed: ()async{
                        var connectivityResult = await (Connectivity().checkConnectivity());
                        if(connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi){
                          login_with_Apple();
                        }
                      }
                  )):SizedBox(),
              SizedBox(height: Platform.isIOS?8:5),
              Center(
                  child: SignInButton(
                    Buttons.GoogleDark,
                    onPressed: ()async{
                      login_with_Gmail();
                      var connectivityResult = await (Connectivity().checkConnectivity());
                      if(connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi){
                        if(googleSignIn.currentUser != null){
                          createUserInFirestoreGoogleAuth();
                        }
                      }
                    },
                  )
              ),
            ],
          ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      isLoading = true;
      SizerUtil.deviceType == DeviceType.tablet?isTablet = true:isTablet = false;
    });

    os = Platform.operatingSystem;
    widget.userId != null ? isAuth = true: isAuth = false;
    widget.userId == null?null:getUser(widget.userId.toString());
    retrieveToken();
    file = null;
    widget.userId == null?null:getNotiCounter(widget.userId.toString());
    if(widget.userId == null){
      setState(() {
        isLoading = false;
      });
    }
  }

  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    imageId = Uuid().v4();

    updateLiveChatStatus()async{
      await allHelpChatRef.doc(widget.userId).get().then((snapshot){
        if(!snapshot.exists){}else{
          if(snapshot.data()!['isDone'] == true){
            allHelpChatRef.doc(widget.userId).update({
              'isShow': false
            });

            helpChatRef.doc(widget.userId).collection(widget.userId.toString()).where('toShow',isEqualTo: true).get().then((snapshot){
              snapshot.docs.forEach((doc){
                helpChatRef.doc(widget.userId).collection(widget.userId.toString()).doc(doc.id).update(
                    {
                      'toShow': false
                    });
              });
            });
          }
        }
      });
    }
    return isAuth == false? buildUnAuthScreen():isLoading == true ?loading():Scaffold(
      backgroundColor: Colors.grey.shade300,
      key: _scaffoldState,
      drawer: buildDrawer(),
      appBar: AppBar(
        backgroundColor: themeColour,
        leading: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: InkWell(
              child: totalCounter == 0 ? Icon(Icons.menu):Row(
                children: [
                  Icon(Icons.menu),
                  Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(totalCounter.toString(),style: TextStyle(color: themeColour)),
                    ),
                  ),
                ],
              ),
              onTap: (){
                _scaffoldState.currentState!.openDrawer();
              },
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(top: 20,right: 15),
            child: InkWell(
                child: toShow == false || file == null?SizedBox():Text('เสร็จสิ้น',style: TextStyle(fontWeight: FontWeight.bold,fontSize: isTablet?20:16)),
                onTap: (){
                  setState(() {
                    toShow = false;
                  });
                  handleSubmitUserImg();
                }
            ),
          )
        ],
      ),
      body: isLoading == true? loading():ListView(
        children: [
          Container(
            color: Colors.white,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height*4/15,
            child: Stack(
              children: [
                Positioned.fill(
                  top: MediaQuery.of(context).size.height*1/14,
                  child: Align(
                    alignment: Alignment.center,
                    child: file == null && userUrl != ""
                        ?CircleAvatar(
                      radius: 90.0,
                      backgroundImage: NetworkImage(userUrl.toString()),
                      backgroundColor: Colors.transparent,
                    )
                        :file == null && userUrl == "" || file == null && userUrl == null
                        ?Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black)
                      ),
                      child: CircleAvatar(
                        radius: 90.0,
                        child: Center(child: Icon(FontAwesomeIcons.userAlt,color: Colors.black,size: 80)),
                        backgroundColor: Colors.transparent,
                      ),
                    )

                        :CircleAvatar(
                      radius: 90.0,
                      backgroundImage: FileImage(file!),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),

                Positioned(
                    bottom: isTablet?35:1,
                    right: isTablet?MediaQuery.of(context).size.width*2/5:MediaQuery.of(context).size.width*3/11,
                    child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              color: Colors.grey.shade300
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              children: [
                                Icon(Icons.edit,color: Colors.black),
                                SizedBox(width: 5),
                                Text('แก้ไข',style: TextStyle(color: Colors.black,fontSize: isTablet?20:16))
                              ],
                            ),
                          ),
                        ),
                        onTap: ()async{
                          setState(() {
                            isLoading = true;
                          });
                          file = await Navigator.push(context, MaterialPageRoute(builder: (context)=>handleGettingImage(file: file)));
                          setState(() {
                            isLoading = false;
                          });
                        }
                    )
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child:


            isAppleSignIn == true?InkWell(
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 10),
                      Text(userName.toString(),style: TextStyle(fontSize: isTablet?25:15,fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Text('(เปลี่ยนชื่อ)',style: TextStyle(color: Colors.grey))
                    ],
                  )
              ),
              onTap: ()=>Navigator.push(context, MaterialPageRoute(
                  builder: (context)=>
                      changeUserName(
                          userId: widget.userId.toString(),
                          name: userName.toString()
                      )
              )).then((snapshot)async{
                await usersRef.doc(widget.userId).get().then((snap){
                  setState(() {
                    userName = snap.data()!['name'];
                    isAppleSignIn = snap.data()!['appleSignIn'];
                  });
                });
              }),
            ):Container(
                width: MediaQuery.of(context).size.width,
                height: 60,
                color: Colors.white,
                child: Center(
                  child: Text(userName.toString(),style: TextStyle(fontSize: isTablet?30:25,fontWeight: FontWeight.bold)
                  ),
                )
            ),
          ),
          buildPaymentAddressButton(context,'โปรไฟล์',isTablet,()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>editProfileUserInfo(userId: widget.userId)))),
          buildPaymentAddressButton(context,'ที่อยู่เพื่อจัดส่ง',isTablet,()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>address(userId: widget.userId)))),
          buildPaymentAddressButton(context,'บัญชีธนาคาร',isTablet,()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>payment(userId: widget.userId)))),
          buildPaymentAddressButton(context,'ที่ตั้งร้านค้าและการจัดส่ง',isTablet,()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>deliveryOptionAndStoreAddress(userId: widget.userId,type: 'ที่ตั้งร้านค้าและการจัดส่ง')))),
          buildPaymentAddressButton(context,'ติดต่อเรา',isTablet,()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>contactUs(userId: widget.userId, userImage: userUrl, userName: userName))).then((value){
            updateLiveChatStatus();
          })),
        ],
      ),
    );
  }

  Drawer buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/drawerProfile.jpg'),
                    fit: BoxFit.cover)
            ),
            child: null,
          ),
          Expanded(
            child: Column(
              children: [

                buildListTile('ขายสัตว์เลี้ยง',Icon(FontAwesomeIcons.briefcase,size: 20,color: Colors.black),0,(){
                  Navigator.push(context, MaterialPageRoute(builder: (contetxt)=> myShop(userId: widget.userId.toString())));
                }),
                buildListTile('จัดการออเดอร์',Icon(FontAwesomeIcons.store,size: 20,color: Colors.black),5,(){
                  Navigator.push(context, MaterialPageRoute(builder: (contetxt)=>
                      storeManagement(
                        userId: widget.userId,
                        itemToPrepare: itemToPrepare!.toInt(),
                        itemDispatched: itemDispatched!.toInt(),
                        itemGuarantee: itemGuarantee!.toInt(),
                      )
                  ));
                }),
                buildListTile('หาคู่ให้สัตว์เลี้ยง',Icon(FontAwesomeIcons.dog,color: Colors.black,),0,(){
                  Navigator.push(context, MaterialPageRoute(builder: (contetxt)=>myPets(currentUserId: widget.userId)));
                }),
                buildListTile('คำถามที่พบบ่อย',Icon(FontAwesomeIcons.solidQuestionCircle,size: 20,color: Colors.black),0,(){
                  Navigator.push(context, MaterialPageRoute(builder: (contetxt)=> questionsAboutCanine(toShowBackButton: true)));
                }),
              ],
            ),
          ),
          Container(
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: Column(
                children: [
                  buildDivider(),
                  buildListTile('เงือนไขและคำถามที่พบบ่อย', Icon(FontAwesomeIcons.book,color: Colors.black),0,()=> Navigator.push(context, MaterialPageRoute(
                      builder: (context)=> conditionLibrary(userId: widget.userId.toString())))),
                  SizedBox(height: 10),
                  InkWell(
                      child: buildListTileSignOut(),
                      onTap: ()
                      {
                        logOut();
                      }),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  logOut()async{
    await usersRef.doc(widget.userId).collection('token').doc(_getToken.toString()).delete();
    try{
      FirebaseAuth.instance.signOut();
      googleSignIn.signOut();
    }catch(e){
      print(e);
    }
    setState(() {
      isAuth = false;
    });
    Navigator.push(context, MaterialPageRoute(builder: (context)=> authScreenWithoutPet(pageIndex: 3,currentUserId: null)));
  }

  InkWell buildListTile(String topic, Icon icon,int notiCount, Function() onTap) {
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color:Colors.grey.shade200)
            )
        ),
        child: ListTile(
          title: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10,right: 30),
                child: icon,
              ),
              topic != 'จัดการออเดอร์'?
              Text(topic,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)):
              totalCounter == 0
                  ? Text(topic,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold))
                  :Row(
                mainAxisAlignment:MainAxisAlignment.start ,
                children: [
                  Text(topic,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                  SizedBox(width: 5),
                  notiAlert(totalCounter!)
                ],
              ),
            ],
          ),
        ),
      ),
      onTap: onTap,
    );
  }

  ListTile buildListTileSignOut() {
    return ListTile(
      title: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10,right: 30),
            child: Icon(FontAwesomeIcons.powerOff,color: themeColour),
          ),
          Text('ล็อคเอ้า',style: topicStyle.apply(color: themeColour)),
        ],
      ),
    );
  }

  InkWell buildPaymentAddressButton(BuildContext context,String topic,bool isTablet,Function() ontap) {
    return InkWell(
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(bottom: 3),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200)
        ),
        child: ListTile(
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0,vertical: 15),
            child: Text(topic,style: TextStyle(fontSize: isTablet == true?20:16,fontWeight: FontWeight.bold)),
          ),
          trailing: Icon(Icons.arrow_forward_ios_outlined),
        ),
      ),
      onTap: ontap,
    );
  }
}


