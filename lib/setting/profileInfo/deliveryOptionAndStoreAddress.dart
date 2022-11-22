import 'package:flutter/material.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:remove_emoji/remove_emoji.dart';
import 'package:sizer/sizer.dart';
import '../../authCheck.dart';

final DateTime timestamp = DateTime.now();
bool isTablet = false;

class deliveryOptionAndStoreAddress extends StatefulWidget {
  final userId,type;
  deliveryOptionAndStoreAddress({required this.userId,this.type});

  @override
  _deliveryOptionAndStoreAddressState createState() => _deliveryOptionAndStoreAddressState();
}

class _deliveryOptionAndStoreAddressState extends State<deliveryOptionAndStoreAddress> {
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  TextEditingController name = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();

  TextEditingController houseNumber = TextEditingController();
  TextEditingController moo = TextEditingController();
  TextEditingController subdistrict = TextEditingController();
  TextEditingController road = TextEditingController();
  TextEditingController district = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController postCode = TextEditingController();
  bool pickupAtStore = false;
  bool pickupAtAirport = false;
  var remove = RemoveEmoji();

  handleSubmit()async{
    await usersRef.doc(widget.userId).collection('storeLocationAndDeliveryOption').doc(widget.userId).set(
        {
          'name': remove.removemoji(name.text),
          'phoneNo': remove.removemoji(phoneNumber.text),

          'houseNo': remove.removemoji(houseNumber.text),
          'moo': remove.removemoji(moo.text),
          'road': remove.removemoji(road.text),
          'subdistrict': remove.removemoji(subdistrict.text),
          'district': remove.removemoji(district.text),
          'city': remove.removemoji(city.text),
          'postCode': remove.removemoji(postCode.text),

          'selfPickup': pickupAtStore,
          'airDelivery' : pickupAtAirport,

          'timestamp' : timestamp.millisecondsSinceEpoch
        });
    Navigator.pop(context);
  }

  handleUpdate()async{
    await usersRef.doc(widget.userId).collection('storeLocationAndDeliveryOption').doc(widget.userId).update(
        {
          'name': remove.removemoji(name.text),
          'phoneNo': remove.removemoji(phoneNumber.text),

          'houseNo': remove.removemoji(houseNumber.text),
          'moo': remove.removemoji(moo.text),
          'road': remove.removemoji(road.text),
          'subdistrict': remove.removemoji(subdistrict.text),
          'district': remove.removemoji(district.text),
          'city': remove.removemoji(city.text),
          'postCode': remove.removemoji(postCode.text),

          'selfPickup': pickupAtStore,
          'airDelivery' : pickupAtAirport,

          'timestamp' : timestamp.millisecondsSinceEpoch
        });
    Navigator.pop(context);
  }

  getData()async{
    usersRef.doc(widget.userId).collection('storeLocationAndDeliveryOption').doc(widget.userId).get().then((snapshot){
      if(snapshot.exists){
        name.text = snapshot.data()!['name'];
        phoneNumber.text = snapshot.data()!['phoneNo'];

        houseNumber.text = snapshot.data()!['houseNo'];
        snapshot.data()!['moo']!=null?moo.text = snapshot.data()!['moo']:null;
        snapshot.data()!['road']!=null?road.text = snapshot.data()!['road']:null;
        subdistrict.text = snapshot.data()!['subdistrict'];
        district.text = snapshot.data()!['district'];
        city.text = snapshot.data()!['city'];
        postCode.text = snapshot.data()!['postCode'];
        pickupAtStore = snapshot.data()!['selfPickup'];
        pickupAtAirport = snapshot.data()!['airDelivery'];
      }else{
        setState(() {
          pickupAtStore = true;
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      isLoading = true;
      SizerUtil.deviceType == DeviceType.tablet?isTablet = true:isTablet = false;
      getData();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        isLoading = false;
      });

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: themeColour,
        title: Text(widget.type,style: TextStyle(fontSize: isTablet?22:18)),
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: 15),
              child: InkWell(
                  child: Text('เสร็จสิ้น',style: TextStyle(fontWeight: FontWeight.bold,fontSize: isTablet?20:16)),
                  onTap: (){
                    if(_formKey.currentState!.validate()) {
                      widget.type == 'ที่ตั้งร้านค้าและการจัดส่ง'?handleSubmit():handleUpdate();
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
                padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 20),
                child: Text('ข้อมูลทั่วไป',style: TextStyle(fontWeight: FontWeight.bold,fontSize: isTablet?20:16)),
              ),
              Container(
                color: Colors.white,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      buildTextFormField('ชื่อ-สกุล **', '', name,0),
                      buildTextFormField('เบอร์มือถือ **', '', phoneNumber,1),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 20),
                child: Text('ที่อยู่',style: TextStyle(fontWeight: FontWeight.bold,fontSize: isTablet?20:16)),
              ),
              Container(
                color: Colors.white,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      buildTextFormField('บ้านเลขที่ **', '', houseNumber,4),
                      buildTextFormField('หมู่', '', moo,3),
                      buildTextFormField('ถนน', '', road,5),
                      buildTextFormField('แขวง/ตำบล **', '', subdistrict,0),
                      buildTextFormField('เขต/อำเภอ **', '', district,0),
                      buildTextFormField('จังหวัด **', '', city,0),
                      buildTextFormField('รหัสไปรษณีย์ **', '', postCode,2),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 20),
                child: Text('ตัวเลือกการจัดส่ง',style: TextStyle(fontWeight: FontWeight.bold,fontSize: isTablet?20:16)),
              ),
              Container(
                color: Colors.white,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Checkbox(
                              activeColor: themeColour,
                              value: pickupAtStore,
                              onChanged: (val){
                                setState(() {
                                  pickupAtStore = true;
                                });
                              }),
                          SizedBox(width: 10),
                          Text('ลูกค้ามารับเองที่ฟาร์ม',style: TextStyle(color: Colors.black,fontSize: isTablet?20:16))
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 55.0),
                        child: Text('(ไม่มีค่าส่ง)',style: TextStyle(color: Colors.red,fontSize: isTablet?20:16)),
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Checkbox(
                              activeColor: themeColour,
                              value: pickupAtAirport,
                              onChanged: (val){
                                setState(() {
                                  pickupAtAirport == false?pickupAtAirport = true:pickupAtAirport = false;
                                });
                              }),
                          SizedBox(width: 10),
                          Text('จัดส่งโดยเครื่องบิน',maxLines:2,style: TextStyle(color: Colors.black,fontSize: isTablet?20:16)),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 55.0),
                        child: Text('(คิดค่าส่งเป็น FIX ที่ 1,500 บาท)',style: TextStyle(color: Colors.red,fontSize: isTablet?20:16)),
                      ),

                      SizedBox(height: 20),
                    ],
                  ),
                ),
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
        Text(topic,style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold)),
        Container(
          color: Colors.transparent,
          height: 60,
          child: TextFormField(
            controller: controller,
            keyboardType: topic == 'เบอร์มือถือ **' || topic == 'หมู่' || topic == 'รหัสไปรษณีย์ **'? TextInputType.number:TextInputType.text,
            decoration: InputDecoration(
                hintText: hintText,
                focusedBorder: const UnderlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFD35757),width: 3)
                ),
                labelStyle: TextStyle(color:themeColour,fontSize: isTablet?20:16)
            ),
            validator: no == 0
                ?(value){
              if(value!.isEmpty){
                return 'โปรดใส่ข้อมูล';
              }else if(value.length>40)
              {
                return 'โปรดใส่ข้อมูลไม่เกิน 40 ตัวอักษร';
              }else if(value.contains(RegExp(r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])')))
              {
                return 'ไม่สามารถใช้ emoji ในช่องนี้ได้';
              }else if(value.contains( RegExp(r'[^a-zA-Zก-ํ ]')))
              {
                return 'โปรดใส่ข้อมูลให้ถูกต้อง';
              }
              return null;
            }
            // Phone Number Validation
                :no == 1?(value){
              if(value!.isEmpty){
                return 'โปรดใส่ข้อมูล';
              }else if(value.length!=10 || value.contains(RegExp(r'[^0-9]')))
              {
                return 'โปรดใส่ข้อมูลให้ถูกต้อง';
              }else if(value.contains(RegExp(r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'))){
                return 'ไม่สามารถใช้ emoji ในช่องนี้ได้';
              }
              return null;
            }// Post Code Validation
                :no == 2? (value){
              if(value!.isEmpty){
                return 'โปรดใส่ข้อมูล';
              }else if(value.length!=5 || value.contains(RegExp(r'[^0-9]')))
              {
                return 'โปรดใส่ข้อมูลให้ถูกต้อง';
              }else if(value.contains(RegExp(r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'))){
                return 'ไม่สามารถใช้ emoji ในช่องนี้ได้';
              }
            }
            // Moo validation
                : no == 3? (value){
              if(value!.length>=3 || value.contains(RegExp(r'[^0-9]')))
              {
                return 'โปรดใส่ข้อมูลให้ถูกต้อง';
              }else if(value.contains(RegExp(r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'))){
                return 'ไม่สามารถใช้ emoji ในช่องนี้ได้';
              }
            }// House number
                : no == 4
                ?(value){
              if(value!.isEmpty){
                return 'โปรดใส่ข้อมูล';
              }else if(value.length>10)
              {
                return 'โปรดใส่ข้อมูลไม่เกิน 10 ตัวอักษร';
              }else if(value.contains(RegExp(r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'))){
                return 'ไม่สามารถใช้ emoji ในช่องนี้ได้';
              }else if(value.contains( RegExp(r'[^0-9/]')))
              {
                return 'โปรดใส่ข้อมูลให้ถูกต้อง';
              }
              return null;
            }: null,
          ),
        ),
      ],
    );
  }
}

