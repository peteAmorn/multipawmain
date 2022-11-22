import 'package:flutter/material.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:sizer/sizer.dart';

class conditionBuyer extends StatefulWidget {
  bool? toShowBackArrow = true;
  conditionBuyer({this.toShowBackArrow});

  @override
  _conditionBuyerState createState() => _conditionBuyerState();
}

class _conditionBuyerState extends State<conditionBuyer> {
  List<bool> toShowList = [false,false,false,false,false,false,false,false,false];
  bool isTablet = false;
   @override
  void initState() {
    // TODO: implement initState
    setState(() {
      SizerUtil.deviceType == DeviceType.tablet?isTablet = true:isTablet = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: widget.toShowBackArrow == false?appBarWithOutBackArrow('ข้อมูลสำหรับผู้ซื้อ',isTablet):appBarWithBackArrow('ข้อมูลสำหรับผู้ซื้อ',isTablet),
      body: ListView(
        children: [
          buildInkWell(
              'การันตีคุ้มครองกรณีไหนบ้าง ?',
              'หากลูกสุนัข หรือลูกแมวที่ซื้อมาเข้าเงื่อนไขดังต่อไปนี้ ผู้ซื้อสามารถแจ้งเคลมเพื่อขอคืนเงินเต็มจำนวนได้ภายในช่วงเวลาที่รับประกัน (การตัดสินใจของมัลติพอว์สถือเป็นที่สิ้นสุด)\n\n1) ลักษณะไม่ตรงกับที่โฆษณาไว้ \n2) เกิดอุบัติเหตุจากการขนส่งทำให้น้องพิการ หรือเสียชีวิต\n3) สามารถพิสูจน์ได้ว่ามีอาการป่วยเป็นโรคที่ถึงแก่ชีวิต อันมีต้นเหตุจากทางผู้ขายเช่น โรคพาโว ไข้หัด เป็นต้น',
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
              'การันตีครอบคลุมกี่วัน ?',
              'การันตีครอบคลุม 7 วันหลังจากผู้ซื้อได้รับน้อง',
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
              'ผู้ซื้อสามารถยกเลิกคำสั่งซื้อได้หรือไม่ ?',
              'สามารถทำได้ ทั้งนี้ ผู้ซื้อสามารถยกเลิกคำสั่งซื้อได้จนถึงวันพร้อมจัดส่งที่ผู้ขายได้ระบุไว้ โดยผู้ซื้อจะถูกหักค่ามัดจำ 30% ของราคาเต็ม และเงินส่วนที่เหลือจะถูกโอนคืนเข้าบัญชีที่ผู้ขายระบุไว้ในระบบในทุกวันพุธ ของเดือนโดยจะตัดรอบทุกเที่ยงคืนของวันอาทิตย์',
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
              'หากทำการจ่ายเงินนอกระบบของ มัลติพอว์ส จะได้รับความคุ้มครองหรือไม่ ?',
              'ไม่ได้รับ และเราไม่แนะนำให้ทำแบบนั้น เนื่องจากปัจจุบันมีการโกงเกิดขึ้นมากมาย สุนัขและแมวที่ซื้อมาจะต้องอยู่กับเราไปอีกมากกว่า 10 ปี ดังนั้นควรเลือกให้ดี',
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
              'ประเภทของใบเพ็ดดีกรี ?',
              'ใบเพ็ดดีกรีมีทั้งหมด 4 ประเภทดังนี้'
                  '\n\n1) UNCERTIFIED PEDIGREE : ใบเพ็ดดีกรีประเภทนี้เป็นเอกสารที่ผู้ผสมพันธุ์เป็นผู้ออกให้ผู้ซื้อเพื่อให้ทราบถึงสายบรรพบุรุษ ไม่สามารถนำมาใช้อ้างอิงเพื่อการรับรองโดยสมาคมได้'
                  '\n2) INCOMPLETE PEDIGREE : ใบเพ็ดดีกรีประเภทนี้เป็นที่รู้จักในชื่อของ "เพ็ดดีกรีครึ่งใบ" เนื่องจากมีข้อมูลบรรพบุรุษไม่ครบ 3 ช่วงอายุ โดยจะมีสีเขียวอ่อน'
                  '\n3) CERTIFIED EXPORT PEDIGREE : ใบเพ็ดดีกรีประเภทนี้เป็นใบเพ็ดดีกรีที่ออกให้สำหรับการส่งออก'
                  '\n4) COMPLETE PEDIGREE : เพ็ดดีกรีใบเต็ม โดยจะมีบันทึกที่มาของบรรพบุรุษครบ 3 ช่วงอายุ ใบเป็นสีม่วงอ่อนและมีตราสัญลักษณ์ของสมาคม A.K.U และ F.C.I'
                  '\n\nที่มา: https://www.dogilike.com/',

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
