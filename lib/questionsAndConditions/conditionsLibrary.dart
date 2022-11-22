import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multipawmain/authCheck.dart';
import 'package:multipawmain/questionsAndConditions/conditionBuyer.dart';
import 'package:multipawmain/questionsAndConditions/questionAboutCat.dart';
import 'package:multipawmain/questionsAndConditions/questionsAboutCanine.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:sizer/sizer.dart';
import '../accountDelete.dart';
import 'condition.dart';
import 'dart:io';

class conditionLibrary extends StatefulWidget {

  final String userId;
  conditionLibrary({required this.userId});

  @override
  _conditionLibraryState createState() => _conditionLibraryState();
}

class _conditionLibraryState extends State<conditionLibrary> with SingleTickerProviderStateMixin{
  bool isTablet = false;
  String? userName;
  bool toShowDeleteButton = true;
  bool toShow01 = true;
  bool toShow02 = true;
  bool toShow03 = true;
  bool isLoading = false;

  petToDeliverPending()async{
    await buyerOnPrepareRef.where('sellerId',isEqualTo: widget.userId).get().then((snapshot){
      if(snapshot.size>0){
        setState(() {
          toShow01 = false;
        });
      }
    });
    await buyerOnDispatchRef.where('sellerId',isEqualTo: widget.userId).get().then((snapshot){
      if(snapshot.size>0){
        setState(() {
          toShow02 = false;
        });
      }
    });
    await buyerOnGuaranteeRef.where('sellerId',isEqualTo: widget.userId).get().then((snapshot){
      if(snapshot.size>0){
        setState(() {
          toShow03 = false;
        });
      }
    });
    if(toShow01 == false || toShow02 == false || toShow03 == false){
      setState(() {
        toShowDeleteButton = false;
      });
    }
  }

  getUserName()async{
    usersRef.doc(widget.userId).get().then((snapshot){
      userName = snapshot.data()!['name'];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      isLoading = true;
    });
    getUserName();
    petToDeliverPending();
    setState(() {
      SizerUtil.deviceType == DeviceType.tablet?isTablet = true:isTablet = false;
      isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithBackArrow('เงื่อนไขและคำถามที่พบบ่อย',isTablet),
      body: isLoading == true? loading():Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0,top: 25),
              child: Container(
                  child: Text('คำถามที่พบบ่อย',style: TextStyle(fontSize: isTablet?30:20,color: Colors.red.shade900,fontWeight: FontWeight.bold))),
            ),
          ),
          buildDivider(),
          Container(
            height: isTablet?330:230,
            child: GridView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 0,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.9
              ),
              children: [
                buildPadding('คำถามที่พบบ่อยเกี่ยวกับสุนัข','assets/questionIcon/dogIcon.jpg',()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>questionsAboutCanine(toShowBackButton: true)))),
                buildPadding('คำถามที่พบบ่อยเกี่ยวกับแมว','assets/questionIcon/catIcon.jpg',()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>questionsAboutCat(toShowBackButton: true)))),
              ],
            ),
          ),

          // #####################################
          // Uncomment this if want to show shop
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                buildListTile('ข้อมูลสำหรับผู้ซื้อ',FontAwesomeIcons.shoppingBag,()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>conditionBuyer()))),
              ],
            ),
          ),
          // #####################################
          Container(
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0,top: 30),
              child: Container(
                  child: Text('เงื่อนไขและข้อตกลง',style: TextStyle(fontSize: isTablet?30:20,color: Colors.red.shade900,fontWeight: FontWeight.bold))),
            ),
          ),
          buildDivider(),
          Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: [
                  buildListTile('ข้อกำหนดและเงื่อนไข',FontAwesomeIcons.fileContract,()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>policyAndCondition()))),
                  toShowDeleteButton == false?SizedBox():buildListTile('ลบบัญชี',FontAwesomeIcons.trash,()=>deleteAlertDialog(context, widget.userId, userName.toString())),
                ],
              )
          )
        ]));
  }

  Padding buildListTile(String topic,IconData icon,Function() ontap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: InkWell(
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300)
          ),
          child: ListTile(
            leading: Icon(icon,color: Colors.red.shade900),
            title: Text(topic,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: isTablet?20:16)),
          ),
        ),
        onTap: ontap,
      ),
    );
  }

  Padding buildPadding(String topic,String imgAddress, Function() ontap) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: InkWell(
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              color: Colors.white
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                  flex: 7,
                  child: Container(
                    width: screenWidth,
                    child: Image.asset(imgAddress,fit: BoxFit.fitHeight)
                  )
              ),

              Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                        child: Text(
                            topic,
                            style: TextStyle(
                                fontSize: isTablet?20:16,color: Colors.black,fontWeight: FontWeight.bold),
                            maxLines: 2)
                    ),
                  )
              ),
            ],
          ),
        ),
        onTap: ontap,
      ),
    );
  }
}


Future<dynamic> deleteAlertDialog(BuildContext context, String userId,String userName) {
  return showDialog(
      context: context,
      builder: (BuildContext context) =>
      Platform.isIOS ?
      CupertinoAlertDialog(
        title: Text('ต้องการลบบัญชี ใช่หรือไม่?',style: TextStyle(fontSize: 16)),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text('ยกเลิก',style: TextStyle(color: Colors.green.shade800,fontSize: 16)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            child: Text('ยืนยัน',style: TextStyle(color: Colors.red,fontSize: 16),),
            onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>accountDelete(userId: userId,name: userName))),
          )
        ],
      ) :
      AlertDialog(
        backgroundColor: Colors.grey.shade100,
        content: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.blue.shade50,
          ),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Text('คุณต้องการลบบัญชี\nใช่หรือไม่ ?',style: TextStyle(color: Colors.black,fontSize: 16)),
          ),
        ),
        actions: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: [
                SizedBox(width: 20),
                Expanded(
                  flex: 1,
                  child: InkWell(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.green,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Center(child: Text('ยืนยัน',style: TextStyle(color: Colors.white,fontSize: 16),)),
                      ),
                    ),
                    onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>accountDelete(userId: userId,name: userName))),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  flex: 1,
                  child: InkWell(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.red.shade900,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Center(child: Text('ยกเลิก',style: TextStyle(color: Colors.white,fontSize: 16))),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                SizedBox(width: 20),
              ],
            ),
          )

        ],
      )
  );
}