import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multipawmain/authScreenWithoutPet.dart';
import 'package:multipawmain/pages/myPets/myPets.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class thankyou extends StatefulWidget {
  late String userId,amount;
  thankyou({required this.userId,required this.amount});

  @override
  _thankyouState createState() => _thankyouState();
}

class _thankyouState extends State<thankyou> {
  var f = new NumberFormat("#,##0.00", "en_US");
  bool isTablet = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      SizerUtil.deviceType == DeviceType.tablet?isTablet = true:isTablet = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.red.shade900,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40)
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.shade900.withOpacity(0.1),
                      spreadRadius: 3,
                      blurRadius: 3,
                      offset: Offset(2, 2), // changes position of shadow
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(FontAwesomeIcons.paw,color: Colors.white,size: 80),
                      Container(
                        margin: EdgeInsets.only(top: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(1)),
                          color: Colors.white
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 3),
                          child: Text('ขอบคุณที่ใช้บริการ',
                              style: TextStyle(
                                  color: themeColour,
                                fontWeight: FontWeight.bold,
                                fontSize: isTablet?20:16
                              )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top:20.0,bottom: 10),
                        child: Text('คุณได้ชำระเงินจำนวน ${f.format(double.parse(widget.amount))} บาท',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: isTablet?30:20
                            )),
                      ),
                      Text('เราได้แจ้งคำสั่งซื้อให้ผู้ขายทราบแล้ว',style: TextStyle(color: Colors.white,fontSize: isTablet?20:16))
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.grey.shade100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 25),
                    buildInkWell('กลับไปหน้าแรก',()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>authScreenWithoutPet(currentUserId: widget.userId, pageIndex: 0)))),
                  ],
                ),
              ),
            )
          ],
        )
    );
  }

  InkWell buildInkWell(String text,Function() ontap) {
    return InkWell(
      child: Container(
        width: 200,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
            border: Border.all(color: Colors.red.shade900)
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(text,
                style: TextStyle(
                    color: Colors.red.shade900,
                    fontWeight: FontWeight.bold
                )),
          ),
        ),
      ),
      onTap: ontap,
    );
  }
}

