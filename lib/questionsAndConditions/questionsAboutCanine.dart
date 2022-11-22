import 'package:flutter/material.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:sizer/sizer.dart';

class questionsAboutCanine extends StatefulWidget {
  bool toShowBackButton;
  questionsAboutCanine({required this.toShowBackButton});

  @override
  _questionsAboutCanineState createState() => _questionsAboutCanineState();
}

class _questionsAboutCanineState extends State<questionsAboutCanine> {

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
      appBar: widget.toShowBackButton == true
          ?appBarWithBackArrow('คำถามที่พบบ่อยเกี่ยวกับสุนัข',isTablet)
          :appBarWithOutBackArrow('คำถามที่พบบ่อยเกี่ยวกับสุนัข', isTablet),
      body: ListView(
        children: [
          buildInkWell(
              'น้องสุนัขพร้อมผสมพันธุ์ตอนอายุเท่าไหร่ ?',
              'สุนัขตัวผู้พร้อมผสมพันธุ์เมื่ออายุครบ 6-12 เดือนในขณะที่ตัวเมียควรรอจนอายุครบ 18 เดือน เพื่อการเติบโตที่สมบูรณ์ทั้งแม่และลูก',
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
              'จะรู้ได้อย่างไรว่าน้องสุนัขตัวเมียพร้อมผสมพันธุ์ ?',
              'เมื่อน้องเริ่มเป็นฮีท นับได้ว่าน้องอาจเข้าสู่ระยะ Proestrus โดยระยะนี้มีช่วงระยะเวลาที่ไม่แน่นอน โดยอาจจะมีระยะเวลาตั้งแต่ 3-21 วัน ทั้งนี้ โดยเฉลี่ยจะอยู่ประมาณ 9 วัน หลังจากนั้นน้องจะพร้อมผสมพันธุ์ โดยสังเกตความพร้อมได้จากปากช่องคลอด ที่จะมีน้ำใสๆปนเลือดปริมาณเล็กน้อยไหลออกมาจากปากช่องคลอด และสามารถเอามือไปแตะบริเวณปากช่องคลอด ถ้าน้องยอมให้แตะโดยเอาหางเฉียงไปด้านข้างแทนที่จะเอามาปิด อาจหมายถึงน้องพร้อมผสมพันธุ์แล้ว ทั้งนี้ เพื่อความแน่ใจอาจพาน้องไปตรวจเนื้อเยื่อมดลูกและตรวจสอบระดับฮอร์โมนโปรเจสเตอโรน ซึ่งจะสามารถให้ค่าที่แม่นยำกว่า (ค่าใช้จ่ายรวมประมาณ 1,000 บาท)',
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
              'ในการผสมแบบธรรมชาติควรจะผสมเมื่อน้องตัวเมียอยู่ในระยะ Estrus โดยควรเลือกสถานที่ที่น้องตัวผู้คุ้นเคย และควรทำการผสมทั้งหมด 3 ครั้ง วันเว้นวันเพื่อโอกาสสำเร็จสูงสุด',
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
              'สุนัขตั้งท้องกี่วัน ?',
              'สุนัขตั้งท้อง 58-68 วัน (ประมาณ 2 เดือน)',
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
              'สุนัขตั้งท้องดูแลอย่างไร ?',
              'ช่วงสุนัขตั้งท้อง 6 สัปดาห์แรกควรให้ปริมาณอาหารเพิ่มขึ้นกว่าปกติเล็กน้อย หลังจากนั้นให้เพิ่มปริมาณอาหารขึ้นประมาณ 20% เน้นอาหารที่อุดมไปด้วยโปรตีนที่มีคุณภาพ โดยในระยะนี้สุนัขจะปลีกตัวออกมา จึงควรจัดที่นอนให้อบอุ่นและไม่อับชื้นสำหรับแม่และลูกสุนัข',
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
              'สุนัขคลอดลูกกี่ตัว ?',
              'สุนัขพันธุ์เล็กจะคลอดลูกเฉลี่ยอยุ่ที่ 3-4 ตัวในขณะที่สุนัขพันธุ์ใหญ่เฉลี่ยประมาณ 8-12 ตัว',
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
              'ลูกสุนัขต้องฉีดวัคซีนอะไรบ้าง ?',
              '1) อายุครบ 2 เดือน: วัคซีนรวม 5 โรคเข็มแรก\n2) อายุครบ 3 เดือน: กระตุ้นวัคซีนรวม 5 โรคเข็มสอง และพิษสุนัขบ้าเข็มแรก\n3) อายุครบ 4 เดือน: กระตุ้นวัคซีนรวม 5 โรคเข็มสาม และพิษสุนัขบ้าเข็มสอง\n4) อายุครบ 12 เดือน: กระตุ้นภูมิป้องกันโรคข้างต้นทั้งหมด\n\n** ในช่วงนี้แนะนำให้น้องทานยาถ่ายพยาธิประกอบกับการฉีดวัคซีน',
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
          buildInkWell(
              'โรคอันตรายสำหรับลูกสุนัขที่ควรระวัง ?',
              'หากตรวจพบโรคดังต่อไปนี้ในสุนัขอายุต่ำกว่า 6 เดือน มีโอกาสมากกว่า 90% ที่จะเสียชีวิต\n\n1) ลำไส้อักเสบจากเชื้อพาร์โวไวรัส\n2) โรคไข้หัดสุนัข',
    toShowList[8],()
          {
            setState(() {
              for(var i = 0;i<toShowList.length;i++){
                if(i != 8){
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
