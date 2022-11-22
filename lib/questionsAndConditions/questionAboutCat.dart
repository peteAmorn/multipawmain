import 'package:flutter/material.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:sizer/sizer.dart';

class questionsAboutCat extends StatefulWidget {
  bool toShowBackButton;
  questionsAboutCat({required this.toShowBackButton});

  @override
  _questionsAboutCatState createState() => _questionsAboutCatState();
}


class _questionsAboutCatState extends State<questionsAboutCat> {
  bool isTablet = false;
  List<bool> toShowList = [false,false,false,false,false,false,false,false];

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
      appBar: widget.toShowBackButton == true
          ?appBarWithBackArrow('คำถามที่พบบ่อยเกี่ยวกับแมว',isTablet)
          :appBarWithOutBackArrow('คำถามที่พบบ่อยเกี่ยวกับแมว',isTablet),
      body: ListView(
        children: [
          buildInkWell(
              'น้องแมวพร้อมผสมพันธุ์ตอนอายุเท่าไหร่ ?',
              'แมวตัวผู้พร้อมผสมพันธุ์เมื่ออายุครบ 8-10 เดือนในขณะที่ตัวเมียควรรอจนน้องอายุครบ 12 เดือนเพื่อการเติบโตที่สมบูรณ์ทั้งแม่และลูก',
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
              'จะรู้ได้อย่างไรว่าน้องแมวตัวเมียพร้อมผสมพันธุ์ ?',
              'ในการสังเกตน้องแมว ในระยะก่อนที่น้องจะพร้อมผสมพันธุ์ (Proestrus) น้องจะร้องเสียงดังและต่ำกว่าปกติ ชอบเอาตัวไปถูวัตถุเพื่อปล่อยกลิ่น หลังจากนั้น 1-2 วันน้องจะเข้าสู่ระยะตกไข่ (Estrus) ซึ่งเป็นระยะพร้อมผสมพันธุ์ ระยะนี้กินเวลาประมาณ 3-20 วัน (เฉลี่ย 7 วัน) โดยในระยะนี้หากเอามือลูบหลังน้อง น้องจะโก่งหลังรับ อวัยวะเพศจะบวมเล็กน้อย น้องจะเลียอวัยวะเพศ และปัสสาวะบ่อย',
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
              'การผสมพันธุ์มีกี่แบบ ?',
              'การผสมพันธุ์มีทั้งหมด 2 แบบคือ แบบธรรมชาติ และผสมเทียม',
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
              'การผสมแบบธรรมชาติควรทำอย่างไร ?',
              'ในการผสมแบบธรรมชาติควรจะผสมเมื่อน้องตัวเมียอยู่ในระยะ Estrus โดยควรเลือกสถานที่ที่น้องตัวผู้คุ้นเคย (แมวตัวผู้ส่วนมากจะไม่สามารถหลั่งน้ำเชื้อได้เมื่ออยู่แปลกถิ่น) และควรทำการผสมทั้งหมด 3 ครั้ง วันเว้นวันเพื่อโอกาสสำเร็จสูงสุด',
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
              'แมวตั้งท้องกี่วัน ?',
              'แมวตั้งท้อง 58-68 วัน (ประมาณ 2 เดือน)',
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
              'แมวตั้งท้องดูแลอย่างไร ?',
              'ในช่วงที่แม่แมวตั้งท้อง ควรให้ปริมาณอาหารเพิ่มขึ้นประมาณ 20-40% เน้นอาหารที่มีโปรตีนสูง และหลีกเลี่ยงการทำให้น้องเครียด ในช่วงท้ายของการตั้งครรภ์ควรให้อาหารทีละน้อยๆ แต่ถี่กว่าปกติ เนื่องจากกระเพาะของแม่แมวจะมีขนาดเล็กลง ก่อนน้องคลอดประมาณ 2 สัปดาห์ควรจัดสถานที่คลอดที่อบอุ่นและปลอดภัยให้กับแม่และลูกแมวด้วย',
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
          buildInkWell(
              'แมวคลอดลูกกี่ตัว ?',
              'โดยเฉลี่ยแมวจะคลอดลูกอยู่ที่ 4-6 ตัวต่อครั้ง เว้นแต่แม่แมวที่ยังไม่โตเต็มที่ แม่แมวที่อายุมาก หรือแม่แมวที่ตั้งครรภ์ครั้งแรกอาจจะคลอดลูกแมวออกมาน้อยกว่าค่าเฉลี่ย โดยอาจจะอยู่ที่ประมาณ 2-3 ตัว',
              toShowList[6],()
          {
            setState(() {
              for(var i = 0;i<toShowList.length;i++){
                if(i != 6){
                  toShowList[i] = false;
                }else{
                  toShowList[i] == true? toShowList[i] = false: toShowList[i] = true;
                }
              }
            });
          }),
          buildInkWell(
              'ลูกแมวต้องฉีดวัคซีนอะไรบ้าง ?',
              '1)อายุครบ 2 เดือน: วัคซีนรวมเข็มแรก\n2) อายุครบ 3 เดือน: กระตุ้นวัคซีนรวมเข็มสอง และวัคซีนป้องกันโรคพิษสุนัขบ้าเข็มแรก\n3) อายุครบ 4 เดือน: กระตุ้นวัคซีนรวมเข็มสาม และวัคซีนป้องกันโรคพิษสุนัขบ้าเข็มสอง\n4) อายุครบ 12 เดือน: กระตุ้นภูมิป้องกันโรคข้างต้นทั้งหมด\n\n** แนะนำให้น้องทานยาถ่ายพยาธิทุก 3 เดือน โดยทานครั้งแรกตอนอายุ 6 สัปดาห์',
    toShowList[7],()
          {
            setState(() {
              for(var i = 0;i<toShowList.length;i++){
                if(i != 7){
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
