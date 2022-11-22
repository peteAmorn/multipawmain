import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:multipawmain/support/constants.dart';

class resetPasswordPage extends StatefulWidget {
  @override
  _resetPasswordPageState createState() => _resetPasswordPageState();
}

class _resetPasswordPageState extends State<resetPasswordPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

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
              obscureText: hint == 'รหัสผ่าน'?true:false ,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: const UnderlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFD35757),width: 3)
                  ),
                  hintText: hint
              ),
              validator: (value)=>EmailValidator.validate(value!)?null:'กรุณาใส่อีเมลให้ถูกต้อง'
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

  resetPassword(String email){
    _auth.sendPasswordResetEmail(email: email);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ลิ้งรีเซ็ตรหัสผ่านได้ส่งไปที่อีเมลของคุณแล้ว โปรดตรวจสอบ Inbox และ Junk mail',style: TextStyle(color: Colors.white)),
          backgroundColor: themeColour,
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    TextEditingController emailController = new TextEditingController();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: themeColour,
        title: Text('ลืมรหัสผ่าน',style: TextStyle(color: Colors.white)),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                            SizedBox(height: height*0.005),
                            buildPadding(emailController, LineAwesomeIcons.envelope, 'อีเมล',0),
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
                                      child: Text('รีเซ็ตรหัสผ่าน',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ),
                                onTap: (){
                                  if(_formKey.currentState!.validate()){
                                    resetPassword(emailController.text.trim());
                                  }
                                },
                              )
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
}
