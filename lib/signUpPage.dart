import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:multipawmain/authScreenWithoutPet.dart';
import 'package:multipawmain/questionsAndConditions/condition.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/support/methods.dart';
import 'dart:io';

import 'package:sizer/sizer.dart';

import 'authCheck.dart';

class signUpPage extends StatefulWidget {
  @override
  _signUpPageState createState() => _signUpPageState();
}

class _signUpPageState extends State<signUpPage> {
  String? _getToken,os;
  double? lat,lng;
  Position? _currentPosition;
  String? locality,postCode,country,_location1,_location2,city,name,email,error;
  bool isLoading = false;
  bool _tick = false;
  bool toProceed = false;
  bool isTablet = false;

  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController usernameController = new TextEditingController();
  late double Containerheight;
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


  checkAuth() async{
    User user = await _auth.currentUser!;
    usersRef.doc(user.uid).set({
      'id': user.uid,
      'name': usernameController.text,
      'email': emailController.text,
      'location1': _location1,
      'location2': _location2,
      'city': city,
      'lat':lat,
      'lng':lng,
      'urlProfilePic' : '',
      'admin': 'No',
      'loyaltyPoints': 0,
      'appleSignIn': false,
      'firstLogin':true,
      'timestamp': DateTime.now()
    });
    usersRef.doc(user.uid).collection('token').doc(_getToken).set({
      'platform': os,
      'token':_getToken,
      'timeStamp':DateTime.now()
    });
    Navigator.push(context, MaterialPageRoute(builder: (context)=>authScreenWithoutPet(currentUserId:user.uid,pageIndex: 0)));
  }

  signUp()async{
    _auth.createUserWithEmailAndPassword(email: emailController.text.trim(), password: passwordController.text.trim()).then((value){
      _addEmailToStorage();
    }).then((value){
      Future.delayed(Duration(microseconds: 1000),(){
        checkAuth();
      });
    });
  }

  _getAddressFromLatLng() async{
    try{
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition!.latitude,
          _currentPosition!.longitude
      );

      Placemark place = placemarks[0];

      setState(() {
        _location1 = "${place.name}";
        _location2 = '${place.locality},${place.administrativeArea}, ${place.postalCode}';
        city = place.name!.isEmpty?'${place.locality}':'${place.name}';

      });

    } catch(e){
      print(e);
    }
  }

  _getCurrentPosition() async{
    await Geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.medium,
        forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        _getAddressFromLatLng();

        lat = _currentPosition?.latitude;
        lng = _currentPosition?.longitude;
      });
    }).catchError((e){print(e);});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    os = Platform.operatingSystem;
    SizerUtil.deviceType == DeviceType.tablet?isTablet = true:isTablet = false;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;


    return Scaffold(
      key: _scaffoldkey,
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: themeColour,
        title: Text(''),
      ),
      body: isLoading == true?loadingForLocation(context):InkWell(
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
                            SizedBox(height: 50),
                            Text('สมัครสมาชิก',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25)),
                            SizedBox(height: height*0.005),
                            buildPadding(emailController, LineAwesomeIcons.envelope, 'อีเมล',0),
                            buildPadding(passwordController, LineAwesomeIcons.key, 'รหัสผ่าน',1),
                            buildPadding(usernameController, LineAwesomeIcons.user, 'ชื่อบัญชี (แก้ไขไม่ได้)',3),
                            Padding(
                                padding: EdgeInsets.only(bottom: 10,left: 20,right: 20),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(20)),
                                            color: Colors.grey.shade200,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Icon(FontAwesomeIcons.mapMarkerAlt,color: themeColour),
                                                SizedBox(width: 10),
                                                Text('ค้นหาที่อยู่ปัจจุบัน',style: TextStyle(fontSize: isTablet?20:16))
                                              ],),
                                          ),
                                        ),
                                        onTap: ()async{
                                          setState(() {
                                            isLoading = true;
                                          });
                                          await _getCurrentPosition();

                                          setState(() {
                                            isLoading = false;
                                          });
                                        },
                                      ),
                                      Visibility(
                                          visible: _location1 !=null,
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 5.0),
                                            child: Text(
                                              '${_location1},${_location2}',
                                              style: TextStyle(fontSize: isTablet?16:12,color: Colors.grey.shade600),
                                              maxLines: 2,
                                            ),
                                          )
                                      )
                                    ],
                                  ),
                                )),
                            Padding(
                              padding: const EdgeInsets.only(top: 10,right: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Checkbox(
                                      activeColor: themeColour,
                                      value: _tick,
                                      onChanged: (val){
                                        setState(() {
                                          _tick == true?_tick = false: _tick = true;
                                        });
                                      }),
                                  SizedBox(width: 10),
                                  InkWell(
                                    child: Text('ยอมรับเงื่อนไขและข้อตกลง',style: TextStyle(color: themeColour,fontWeight: FontWeight.bold,decoration: TextDecoration.underline,)),
                                    onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>policyAndCondition())),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 10,left: width*0.08,right: width*0.08,bottom: 20),
                              child: isLoading == false && _tick == true && lat != null && lng != null
                                  ?InkWell(
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                      color: themeColour
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text('สมัครสมาชิก',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ),
                                onTap: (){
                                  if(_formKey.currentState!.validate()){
                                    setState(() {
                                      isLoading = true;
                                    });
                                    signUp();
                                  }
                                },
                              ):Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(20)),
                                    color: Colors.grey
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text('สมัครสมาชิก',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                            )
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
                child: Icon(icon,color: themeColour,size: hint == 'ยืนยันรหัสผ่าน'?20:null),
              )
          ),
          Expanded(
            flex: 8,
            child: TextFormField(
              controller: controller,
              obscureText: hint == 'อีเมล' || hint == 'ชื่อบัญชี (แก้ไขไม่ได้)'?false:true ,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: const UnderlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFD35757),width: 3)
                  ),
                  hintText: hint
              ),
              validator: no == 0
                  ?(value)=>EmailValidator.validate(value!)?null:'กรุณาใส่อีเมลให้ถูกต้อง'
                  :no==1?(value){
                if(value!.isEmpty){
                  return 'โปรดใส่ข้อมูล';
                }else if(value.length<6)
                {
                  return 'โปรดใส่รหัสผ่านมากกว่า 6 ตัวอักษร';
                }else if(value.contains(RegExp(r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'))){
                  return 'ไม่สามารถใช้ emoji ในช่องนี้ได้';
                }
                return null;
              }:no==3?(value){
                if(value == null||value.isEmpty||value.length<4){
                  return 'กรุณากรอกชื่อมากกว่า 3 ตัวอักษร';
                }else if(value.length>26){
                  return 'กรุณากรอกชื่อน้อยกว่า 25 ตัวอักษร';
                }
                return null;
              }:(value){
                if(value!.isEmpty){
                  return 'โปรดใส่ข้อมูล';
                }else if(value.length>40)
                {
                  return 'โปรดใส่ข้อมูลไม่เกิน 40 ตัวอักษร';
                }else if(value.contains(RegExp(r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'))){
                  return 'ไม่สามารถใช้ emoji ในช่องนี้ได้';
                }else if(value.contains( RegExp(r'[^a-zA-Zก-ํ ]')))
                {
                  return 'โปรดใส่ข้อมูลให้ถูกต้อง';
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
