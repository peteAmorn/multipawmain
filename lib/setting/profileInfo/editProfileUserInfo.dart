import 'package:flutter/material.dart';
import 'package:multipawmain/authCheck.dart';
import 'package:multipawmain/database/breedDatabase.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:remove_emoji/remove_emoji.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:sizer/sizer.dart';

final DateTime timestamp = DateTime.now();
bool isTablet = false;

class editProfileUserInfo extends StatefulWidget {
  final userId;
  editProfileUserInfo({required this.userId});

  @override
  _editProfileUserInfoState createState() => _editProfileUserInfoState();
}

class _editProfileUserInfoState extends State<editProfileUserInfo> {
  String? gender;
  String? birthday,birthMonth,birthYear;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  DateTime? returnBirthDay;

  TextEditingController name  = TextEditingController();
  TextEditingController phoneNumber  = TextEditingController();
  var remove = RemoveEmoji();

  Container buildRowFieldDateTime(String topic, DateTime? name,Function() ontap) {
    final DateFormat formatter = DateFormat('dd MMM yyyy');
    return Container(
      color: Colors.white,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(topic,style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: InkWell(
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: name==null?
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('กรุณาเลือก ${topic}',style: TextStyle(color: Colors.grey.shade600,fontSize: isTablet?20:16),),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Divider(color: Colors.black,height:2),
                        )
                      ],
                    ):Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(formatter.format(name),style: TextStyle(color: Colors.black,fontSize: 17),),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Divider(color: Colors.black,height:2),
                        )
                      ],
                    )
                ),
                onTap: ontap,
              ),
            ),
          ],
        )
      ),
    );
  }

  handleSubmit()async{
    await usersRef.doc(widget.userId).collection('userInfo').doc(widget.userId).set(
        {
          'name': remove.removemoji(name.text),
          'gender': gender,
          'birthDay': returnBirthDay!.day.toString(),
          'birthMonth': returnBirthDay!.month.toString(),
          'birthYear': returnBirthDay!.year.toString(),
          'phoneNo': remove.removemoji(phoneNumber.text),
          'timestamp' : timestamp
        });
    Navigator.pop(context);
  }

  getData()async{
    setState(() {
      isLoading = true;
    });

    await usersRef.doc(widget.userId).collection('userInfo').doc(widget.userId).get().then((snapshot){
      if(snapshot.exists){
        name.text = snapshot.data()!['name'];
        gender = snapshot.data()!['gender'];
        birthday = snapshot.data()!['birthDay'];
        birthMonth = snapshot.data()!['birthMonth'];
        birthYear = snapshot.data()!['birthYear'];
        phoneNumber.text = snapshot.data()!['phoneNo'];
        setState(() {
          returnBirthDay = DateTime(int.parse(birthYear!),int.parse(birthMonth!),int.parse(birthday!));
        });
      }

      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          isLoading = false;
        });
      });
    });

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      SizerUtil.deviceType == DeviceType.tablet?isTablet = true:isTablet = false;
    });
    getData();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: themeColour,
        title: Text('โปรไฟล์',style: TextStyle(fontSize: isTablet?22:18)),
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: 15),
              child: InkWell(
                  child: Text('เสร็จสิ้น',style: TextStyle(fontWeight: FontWeight.bold,fontSize: isTablet?20:16)),
                  onTap: (){
                    if(_formKey.currentState!.validate()) {
                      handleSubmit();
                    }
                  }
              ),
            ),
          )
        ],
      ),
      body: isLoading == true? loading():Form(
        key: _formKey,
        child: InkWell(
          onTap: (){
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: ListView(
            children: [
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 8,horizontal: 20),
                  child: Text('ข้อมูลทั่วไป',style: TextStyle(fontWeight: FontWeight.bold,fontSize: isTablet?20:16))
              ),
              Container(
                color: Colors.white,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      buildTextFormField('ชื่อ-สกุล', 'ชื่อ-สกุล', name,0),
                      buildRowField(
                          'เพศ',
                          gender, () async{
                        final result = await Navigator.push(context, MaterialPageRoute(builder: (context)=>selectedPage(text: 'เพศ', list: userGendersList)));
                        setState(() {
                          gender = result.toString();
                        });
                      }),
                    ],
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 8,horizontal: 20),
                  child: Text('ข้อมูลวันเกิด',style: TextStyle(fontWeight: FontWeight.bold,fontSize: isTablet?20:16))
              ),
              buildRowFieldDateTime('วันเดือนปีเกิด', returnBirthDay, (){
                DatePicker.showDatePicker(context,
                    showTitleActions: true,
                    minTime: now.subtract(Duration(days: 29200)),
                    maxTime: now,
                    theme: const DatePickerTheme(
                        doneStyle: TextStyle(
                            color: themeColour
                        )
                    ),
                    onConfirm: (date) {
                      setState(() {
                        returnBirthDay = date;
                      });
                    },
                    currentTime: returnBirthDay == null? DateTime.now(): returnBirthDay,
                    locale: LocaleType.th
                );
              }),

              Padding(
                  padding: EdgeInsets.symmetric(vertical: 8,horizontal: 20),
                  child: Text('ข้อมูลติดต่อ',style: TextStyle(fontWeight: FontWeight.bold,fontSize: isTablet?20:16))
              ),
              Container(
                color: Colors.white,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          buildTextFormField('เบอร์มือถือ', '', phoneNumber,1),
                        ],
                      )
                  )
              ),

            ],
          ),
        ),
      ),
    );
  }

  Column buildTextFormField(String topic, String hintText ,TextEditingController controller,int no) {
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
            keyboardType: topic == 'เบอร์มือถือ'? TextInputType.number:TextInputType.name,
            decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(fontSize: isTablet?20:16),
                focusedBorder: const UnderlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFD35757),width: 3)
                ),
                labelStyle: TextStyle(color:themeColour)
            ),
            validator: no == 0
                ?(value){
              if(value!.isEmpty){
                return 'โปรดใส่ข้อมูล';
              }else if(value.length>40)
              {
                return 'โปรดใส่ข้อมูลไม่เกิน 40 ตัวอักษร';
              }else if(value.contains(RegExp(r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'))){
                return 'ไม่สามารถใช้ emoji ในช่องนี้ได้';
              }else if(value.contains( RegExp(r'[^a-zA-Zก-ํ ]')))
              {
                return 'โปรดใส่ข้อมูลให้ถูกต้อง';
              }
              return null;
            }
                :(value){
              if(value!.isEmpty){
                return 'โปรดใส่ข้อมูล';
              }else if(value.length!=10 || value.contains(RegExp(r'[^0-9]')))
              {
                return 'โปรดใส่ข้อมูลให้ถูกต้อง';
              }else if(value.contains(RegExp(r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])')))
              {
                return 'ไม่สามารถใช้ emoji ในช่องนี้ได้';
              }
              return null;
            },
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
                    Text('เลือก${topic}',style: TextStyle(color: Colors.grey.shade600,fontSize: isTablet?20:16),),
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
      appBar: appBarWithOutBackArrow(text,isTablet),
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

