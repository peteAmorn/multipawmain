import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:multipawmain/authScreenWithoutPet.dart';
import 'package:multipawmain/resetPassword.dart';
import 'package:multipawmain/signUpPage.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/authCheck.dart';
import 'package:multipawmain/support/methods.dart';
import 'dart:io';
import 'authCheck.dart';

class signInPage extends StatefulWidget {
  final email;
  signInPage({this.email});

  @override
  _signInPageState createState() => _signInPageState();
}

class _signInPageState extends State<signInPage> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  bool isLoading = false;
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  String? _getToken,os,name;
  bool toIntro = false;
  // Create storage
  final _storage = const FlutterSecureStorage();

  void _addEmailToStorage() async {
    final String key = 'emailAddress';
    final String value = emailController.text;

    await _storage.write(
        key: key,
        value: value
    );
  }

  _readEmailFromStorage()async{
    final name = await _storage.read(key: 'emailAddress')??'';
    setState(() {
      this.emailController.text = name;
    });
  }



  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    os = Platform.operatingSystem;
    widget.email == null?_readEmailFromStorage():emailController.text = widget.email;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final FirebaseAuth _auth = FirebaseAuth.instance;

    checkAuth() async{
      User user = await _auth.currentUser!;
      _getToken = await FirebaseMessaging.instance.getToken();
      _getToken == null?null:usersRef.doc(user.uid).collection('token').doc(_getToken).set({
        'platform': os,
        'token':_getToken,
        'timeStamp':timestamp
      });

      await usersRef.doc(user.uid).get().then((snapshot){
        snapshot.data()!['firstLogin'] == null || snapshot.data()!['firstLogin'] == true
            ? toIntro = true
            : toIntro = false;
      }).then((value){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>authScreenWithoutPet(currentUserId:user.uid,pageIndex: 0)));
      });

    }

    signInWithEmail(BuildContext context){
      _auth.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text
      ).then((user)async{
        _addEmailToStorage();
        checkAuth();
      }).catchError((error){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.message,style: TextStyle(color: Colors.white)),
              backgroundColor: themeColour,
            )
        );
      });
      setState(() {
        isLoading = false;
      });
    }

    AndroidOptions _getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );

    return Scaffold(
      key: _scaffoldkey,
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: themeColour,
        title: Text('เข้าสู่ระบบ',style: TextStyle(color: Colors.white)),
        leading: InkWell(
          child: Icon(Icons.arrow_back_ios,color: Colors.white,),
          onTap: (){
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading == true? loading():InkWell(
        onTap: (){
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20,bottom: 10,right: width*0.05,left: width*0.05),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      color: Colors.white
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: height*0.03,bottom: 10),
                            child: Container(
                                width: MediaQuery.of(context).size.width*0.2,
                                child: Image.asset('assets/authLogo.png',fit: BoxFit.cover)
                            ),
                          ),
                          SizedBox(height: height*0.005),
                          buildPadding(emailController, LineAwesomeIcons.envelope, 'อีเมล',0),
                          buildPadding(passwordController, LineAwesomeIcons.key, 'รหัสผ่าน',1),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:EdgeInsets.only(right: width*0.15),
                                  child: InkWell(
                                    child: Text('ลืมรหัสผ่าน',style: TextStyle(color: themeColour)),
                                    onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>resetPasswordPage())),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 20,left: width*0.08,right: width*0.08,bottom: 20),
                            child: InkWell(
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(20)),
                                    color: themeColour
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text('เข้าสู่ระบบ',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                              onTap: (){
                                setState(() {
                                  isLoading = true;
                                });
                                if(_formKey.currentState!.validate()){
                                  signInWithEmail(context);
                                }else{
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              },
                            )
                          ),
                          Row(
                              children: <Widget>[
                                Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 40.0,right: 10),
                                      child: Divider(color: themeColour),
                                    )
                                ),

                                Text("ไม่มีบัญชี ?",style: TextStyle(fontWeight: FontWeight.bold)),

                                Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10.0,right: 40),
                                      child: Divider(color: themeColour),
                                    )
                                ),
                              ]
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 20,left: width*0.08,right: width*0.08,bottom: 60),
                            child: InkWell(
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(20)),
                                    color: Colors.black
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text('สมัครสมาชิก',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                              onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>signUpPage()))
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding buildPadding(TextEditingController controller,IconData icon,String hint, int no) {
    return Padding(
      padding: const EdgeInsets.only(left: 35.0,right: 35,top: 20,bottom: 10),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Icon(icon,color: themeColour),
              )
          ),
          Expanded(
            flex: 8,
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              obscureText: hint == 'รหัสผ่าน'?true:false ,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: const UnderlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFD35757),width: 3)
                  ),
                  hintText: hint
              ),
              validator: no == 0
                  ?(value)=>EmailValidator.validate(value!)?null:'กรุณาใส่อีเมลให้ถูกต้อง':(value){
                if(value!.isEmpty){
                  return 'โปรดใส่ข้อมูล';
                }else if(value.length<6)
                {
                  return 'โปรดใส่รหัสผ่านมากกว่า 6 ตัวอักษร';
                }else if(value.contains(RegExp(r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'))){
                  return 'ไม่สามารถใช้ emoji ในช่องนี้ได้';
                }
                return null;
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: SizedBox(),
          )
        ],
      ),
    );
  }
}
