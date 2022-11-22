import 'package:flutter/material.dart';
import 'package:multipawmain/database/breedDatabase.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:sizer/sizer.dart';

bool isTablet = false;

class flightDetail extends StatefulWidget {
  @override
  _flightDetailState createState() => _flightDetailState();
}

class _flightDetailState extends State<flightDetail> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController flightNumber = TextEditingController();
  TextEditingController departureTime = TextEditingController();
  TextEditingController arrivalTime = TextEditingController();
  var airline;
  List<String> info = [];

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
      appBar: AppBar(
        backgroundColor: themeColour,
        title: Text('ข้อมูลเที่ยวบิน',style: TextStyle(color: Colors.white,fontSize: isTablet?20:16)),
        actions: [
          airline == null? SizedBox():Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: InkWell(
                child: Text('เสร็จสิ้น',style: TextStyle(color: Colors.white,fontSize: isTablet?20:16)),
                onTap: ()async{
                  if(_formKey.currentState!.validate()){
                    info.add(airline);
                    info.add(flightNumber.text);
                    info.add(departureTime.text);
                    info.add(arrivalTime.text);

                    Navigator.pop(context,info);
                  }
                },
              ),
            ),
          )
        ],
      ),
      body: Form(
        key: _formKey,
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
              child: ListView(
                children: [
                  buildRowField('เลือกสายการบิน',airline,()async{
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (context)=>selectedPage(text: 'สายการบิน', list: flightList)));
                    setState(() {
                      airline = result.toString();
                    });
                  }),
                  buildTextFormField('หมายเลขไฟล์บิน','',flightNumber),
                  buildTextFormField('เวลาออก (Departure Time)','',departureTime),
                  buildTextFormField('เวลาถึง (Arrival Time)','',arrivalTime),
                  SizedBox(height: 10),
                  Text('*** กรุณาถ่ายรูปน้องหมา/แมว พร้อมใบเสร็จการจัดส่งคู่กัน แล้วเก็บไว้เป็นหลักฐานจนกว่าจะสิ้นสุดการันตี',style: TextStyle(color: themeColour,fontWeight: FontWeight.bold))
                ],
              ),
          )
      ),
    );
  }

  Column buildTextFormField(String topic, String hintText ,TextEditingController controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(topic,style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold),),
        Container(
          color: Colors.transparent,
          height: 60,
          child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                  hintText: hintText,
                  focusedBorder: const UnderlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFD35757),width: 3)
                  ),
                  labelStyle: TextStyle(color:themeColour)
              ),
              validator: (value){
                if(value!.isEmpty){
                  return 'โปรดใส่ข้อมูล';
                }
                return null;
              }
          ),
        ),
      ],
    );
  }

  Column buildRowField(String topic, String? name,Function() ontap) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(topic,style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold)),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: InkWell(
            child: Container(
                width: MediaQuery.of(context).size.width,
                child: name==null?
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('',style: TextStyle(color: Colors.grey.shade600,fontSize: isTablet?20:16),),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Divider(color: Colors.black,height:2),
                    )
                  ],
                ):Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,style: TextStyle(color: Colors.black,fontSize: isTablet?20:16),),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Divider(color: Colors.black,height:2),
                    )
                  ],
                )
            ),
            onTap: ontap,
          ),
        ),
      ],
    );
  }
}

class selectedPage extends StatelessWidget {
  String text;
  List list;
  selectedPage({required this.text,required this.list});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithBackArrow(text,isTablet),
      body: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context,i){
          return InkWell(
            child: Card(
              child: ListTile(
                title: Text(list[i].toString(),style: TextStyle(fontSize: isTablet?20:16)),
              ),
            ),
            onTap: (){
              Navigator.pop(context,list[i]);
            },
          );
        },
      ),
    );
  }
}