import 'package:flutter/material.dart';
import 'package:multipawmain/authCheck.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/support/methods.dart';

class changeUserName extends StatefulWidget {
  final String userId,name;
  changeUserName({required this.userId,required this.name});

  @override
  _changeUserNameState createState() => _changeUserNameState();
}

class _changeUserNameState extends State<changeUserName> {
  TextEditingController userNameController = new TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isShow = true;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userNameController.text = widget.name;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: themeColour,
        title: Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text('เปลี่ยนชื่อผู้ใช้',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20)
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Center(
              child: InkWell(
                child: Text('เสร็จสิ้น',style: TextStyle(color: Colors.white)),
                onTap: (){
                  if(_formKey.currentState!.validate()){
                    usersRef.doc(widget.userId).update({
                      'name': userNameController.text,
                      'appleSignIn': false,
                    });
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          )
        ],),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: TextFormField(
                      controller: userNameController,
                      validator: (String? value){
                        if(value == null||value.isEmpty||value.length<4){
                          return 'กรุณากรอกชื่อมากกว่า 3 ตัวอักษร';
                        }else if(value.length>26){
                          return 'กรุณากรอกชื่อน้อยกว่า 25 ตัวอักษร';
                        }else if(userNameController.text == widget.name){
                          return 'กรุณาเปลี่ยนชื่อ';
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
                          ),
                        suffixIcon: isShow == true?IconButton(
                          onPressed: userNameController.clear,
                          icon: Icon(Icons.clear,color: themeColour),
                        ):SizedBox(),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('** สามารถเปลี่ยนชื่อผู้ใช้ได้ครั้งเดียวเท่านั้น',style: TextStyle(color: themeColour,fontWeight: FontWeight.bold,fontSize: 16))

                ],
              ),
            ),
          ],
        ),
      )
      );
  }
}
