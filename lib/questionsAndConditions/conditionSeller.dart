import 'package:flutter/material.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:sizer/sizer.dart';

class conditionSeller extends StatefulWidget {
  const conditionSeller({Key? key}) : super(key: key);

  @override
  _conditionSellerState createState() => _conditionSellerState();
}

class _conditionSellerState extends State<conditionSeller> {
  List<bool> toShowList = [false,false,false,false,false,false,false,false,false];
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
      backgroundColor: Colors.grey.shade300,
      appBar: appBarWithBackArrow('ข้อมูลสำหรับผู้ขาย',isTablet),
      body: ListView(
        children: [
          buildInkWell(
              'มัลติพอว์ส คิดค่าบริการอย่างไร ?',
              'เราคิดค่าบริการอยู่ที่ 20% ของราคาขาย โดยเงินจะถูกโอนเข้าบัญชีที่ผู้ขายระบุไว้ในระบบในทุกวันพุธ โดยจะตัดรอบทุกเที่ยงคืนของวันอาทิตย์',
              toShowList[0],()
          {
            setState(() {
              for(var i = 0;i<toShowList.length;i++){
                if(i != 0){
                  toShowList[i] = false;
                }else{
                  toShowList[i] == true? toShowList[i] = false: toShowList[i] = true;
                }
              }
            });
          }),
          buildInkWell(
              'ค่าจัดส่งคำนวนอย่างไร ?',
              'หากผู้ซื้อเลือกรับเองที่ฟาร์มเราจะไม่คิดค่าจัดส่ง หากผู้ซื้อเลือกการจัดส่งทางเครื่องบิน เราจะเก็บค่าส่งแบบคงที่ในราคา 1,500 บาท โดยผู้ขายจะต้องดำเนินการออกค่าส่งไปก่อน หากคำสั่งซื้อสำเร็จเราจะโอนค่าจัดส่งและค่าลูกสุนัข/แมวไปให้ ทั้งนี้ หากผู้ขายไม่ต้องการจัดส่งทางเครื่องบินสามารถเข้าไปที่หน้าโปรไฟล์ -> ไอคอนเมนูสามขีด -> ตั้งค่า -> โปรไฟล์ -> ที่ตั้งร้านค้าและการจัดส่ง แล้วแตะเพื่อเอาเครื่องหมายขีดถูกของจัดส่งโดยเครื่องบินออก',
              toShowList[1],()
          {
            setState(() {
              for(var i = 0;i<toShowList.length;i++){
                if(i != 1){
                  toShowList[i] = false;
                }else{
                  toShowList[i] == true? toShowList[i] = false: toShowList[i] = true;
                }
              }
            });
          }),
          buildInkWell(
              'ระยะเวลาการจัดส่ง ?',
              'เมื่อถึงกำหนดจัดส่ง ขอให้ผู้ขายติดต่อผู้ซื้อเพื่อกำหนดวันจัดส่ง โดยทางมัลติพอว์สขอให้ผู้ขายจัดส่งลูกสุนัข/แมวภายใน 7 วันหลังถึงกำหนดวันพร้อมจัดส่ง หรือหากได้รับคำสั่งซื้อภายหลัง ให้จัดส่งภายใน 7 วัน',
              toShowList[2],()
          {
            setState(() {
              for(var i = 0;i<toShowList.length;i++){
                if(i != 2){
                  toShowList[i] = false;
                }else{
                  toShowList[i] == true? toShowList[i] = false: toShowList[i] = true;
                }
              }
            });
          }),
          buildInkWell(
              'หากผู้ซื้อยกเลิกคำสั่งซื้อ ผู้ขายจะได้รับค่ามัดจำหรือไม่ ?',
              'ได้รับ โดยผู้ขายจะได้รับค่ามัดจำ 20% ของราคาเต็มในกรณีที่ผู้ซื้อยกเลิกคำสั่งซื้อ โดยเงินจะถูกโอนคืนเข้าบัญชีที่ผู้ขายระบุไว้ในระบบในทุกวันพุธ ของเดือนโดยจะตัดรอบทุกเที่ยงคืนของวันอาทิตย์',
              toShowList[3],()
          {
            setState(() {
              for(var i = 0;i<toShowList.length;i++){
                if(i != 3){
                  toShowList[i] = false;
                }else{
                  toShowList[i] == true? toShowList[i] = false: toShowList[i] = true;
                }
              }
            });
          }),
          buildInkWell(
              'เงื่อนไขการคุ้มครองการันตี ?',
              'หากลูกสุนัขหรือลูกแมวที่ถูกจัดส่งโดยผู้ขายเข้าเงื่อนไขดังต่อไปนี้ ผู้ซื้อสามารถยื่นเรื่องขอเคลมเพื่อขอคืนเงินเต็มจำนวนได้ (การตัดสินใจของมัลติพอว์สถือเป็นที่สิ้นสุด)\n\n1) ลักษณะไม่ตรงกับที่โฆษณาไว้\n2) เกิดอุบัติเหตุจากการขนส่งทำให้น้องพิการ/เสียชีวิต\n3) สามารถพิสูจน์ได้ว่ามีอาการป่วยเป็นโรคที่ถึงแก่ชีวิต อันมีต้นเหตุจากทางผู้ขาย เช่น โรคพาโว ไข้หัด เป็นต้น',

    toShowList[4],()
          {
            setState(() {
              for(var i = 0;i<toShowList.length;i++){
                if(i != 4){
                  toShowList[i] = false;
                }else{
                  toShowList[i] == true? toShowList[i] = false: toShowList[i] = true;
                }
              }
            });
          }),
          buildInkWell(
              'การันตีครอบคลุมกี่วัน ?',
              'การันตีครอบคลุม 7 วันหลังจากผู้ซื้อได้รับน้อง',
              toShowList[5],()
          {
            setState(() {
              for(var i = 0;i<toShowList.length;i++){
                if(i != 5){
                  toShowList[i] = false;
                }else{
                  toShowList[i] == true? toShowList[i] = false: toShowList[i] = true;
                }
              }
            });
          }),
        ],
      ),
    );
  }
  InkWell buildInkWell(String question,String answer,bool toShow, Function() ontap) {
    return InkWell(
        child: Container(
          margin: EdgeInsets.only(top: 10),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(question,style: TextStyle(
                    color: toShow == true? Colors.red.shade900:Colors.black,
                    fontWeight: toShow == true? FontWeight.bold: FontWeight.normal,
                    fontSize: isTablet?20:16
                )),
                trailing: Icon(toShow == false?Icons.arrow_drop_down:Icons.arrow_drop_up,color: Colors.red.shade900),
              ),
              toShow == true? buildDividerNoPaddingVertical():SizedBox(),
              toShow == true ?SizedBox(height: 10):SizedBox(),
              toShow == true ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 35),
                child: Text(answer,style: TextStyle(fontSize: isTablet?20:16)),
              ):SizedBox(),
              toShow == true ?SizedBox(height: 15):SizedBox()
            ],
          ),
        ),
        onTap: ontap
    );
  }
}
