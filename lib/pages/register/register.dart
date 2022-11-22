import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multipawmain/authCheck.dart';
import 'package:multipawmain/questionsAndConditions/condition.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:multipawmain/support/constants.dart';

class register extends StatefulWidget {
  final bool isAppleSignin;
  register({required this.isAppleSignin});
  @override
  _registerState createState() => _registerState();
}

class _registerState extends State<register> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? locality,postCode,country,_location1,_location2,city,name,error;
  late double Containerheight;
  List<dynamic> data = [];
  double? lat,lng;
  Position? _currentPosition;
  bool _tick = false;
  bool isLoading = false;

  TextEditingController nameController = new TextEditingController();

  submit(){
    Navigator.pop(context,data);
    Navigator.push(context, MaterialPageRoute(builder: (context)=> home()));
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
        city = '${place.locality}';
      });

    } catch(e){
      print(e);
    }
  }

  _getCurrentPosition() async{
    await Geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best,
        forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        _getAddressFromLatLng();

        lat = _currentPosition?.latitude;
        lng = _currentPosition?.longitude;

      });
    }).catchError((e){});
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: appBarAuth(context,'ลงทะเบียน',(){
        try{
          FirebaseAuth.instance.signOut();
        }catch(e){}
        try{
          googleSignIn.signOut();
        }catch(e){}
        Navigator.push(context, MaterialPageRoute(builder: (context)=>home(isAuth: false)));
      }),
      body: isLoading == true ?loadingForLocation(context):Form(
        autovalidateMode: AutovalidateMode.always,
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(),
            Container(
              child: Column(
                children: [
                  widget.isAppleSignin == true?SizedBox():Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: TextFormField(
                      controller: nameController,
                      validator: (String? value){
                        if(value == null||value.isEmpty||value.length<4){
                          return 'กรุณากรอกชื่อมากกว่า 3 ตัวอักษร';
                        }else if(value.length>26){
                          return 'กรุณากรอกชื่อน้อยกว่า 25 ตัวอักษร';
                        }
                        return null;
                      },
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: themeColour,width: 3),
                              borderRadius: BorderRadius.circular(20)
                          ),
                          labelText: 'ชื่อผู้ใช้',
                          labelStyle: TextStyle(color:themeColour),
                          border: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(20),
                              borderSide: BorderSide(
                                  color: themeColour
                              )
                          )
                      ),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(bottom: 10,left: 40,right: 40),
                      child: Container(
                        width: MediaQuery.of(context).size.width-45,
                        height: _location1==''?Containerheight = 70:Containerheight = 120,
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      flex: 3,
                                      child: InkWell(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(20)),
                                            color: Colors.grey.shade300,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Icon(FontAwesomeIcons.mapMarkerAlt,color: themeColour),
                                                SizedBox(width: 10),
                                                Text('แตะเพื่อค้นหาที่อยู่ปัจจุบัน')
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
                                      )
                                  )],
                              ),
                              Visibility(
                                  visible: _location1 != null,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5.0),
                                    child: Text(
                                      '${_location1},${_location2}',
                                      style: TextStyle(fontSize: 12,color: Colors.grey.shade600),
                                      maxLines: 2,
                                    ),
                                  )
                              )
                            ],
                          ),
                        ),
                      )
                  ),

                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
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
            )
          ],
        ),
      ),
      bottomNavigationBar:_tick == false || lat == null || lng==null
          ?Padding(
            padding: const EdgeInsets.only(bottom: 30.0,left: 20,right: 20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Colors.grey,
              ),
        alignment: Alignment.center,
        height: 55,
        width: width,
        child: Text('เสร็จสิ้น',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15
            ),
        ),
      ),
          )
          :Padding(
            padding: const EdgeInsets.only(bottom: 30.0,left: 20,right: 20),
            child: GestureDetector(
        child: Container(
            alignment: Alignment.center,
            height: 55,
            width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: themeColour,
          ),
            child: Text('เสร็จสิ้น',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15
              ),
            ),
        ),
        onTap: (){
            if(_formKey.currentState!.validate()){
              name = nameController.text;

              data.add(name);
              data.add(lat);
              data.add(lng);
              data.add(_location1);
              data.add(_location2);
              data.add(city);
              submit();
            }
        },
      ),
          ),
    );
  }
}
