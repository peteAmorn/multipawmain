import 'package:flutter/material.dart';
import 'package:multipawmain/database/breedDatabase.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:uuid/uuid.dart';
import 'package:sizer/sizer.dart';
import '../../../authCheck.dart';

final DateTime timestamp = DateTime.now();
bool isTablet = false;

class addCreditCard extends StatefulWidget {
  final userId,postId,type,fromCheckOut;
  addCreditCard({required this.userId,this.postId,this.type,this.fromCheckOut});

  @override
  _addCreditCardState createState() => _addCreditCardState();
}

class _addCreditCardState extends State<addCreditCard> {
  final _formKey = GlobalKey<FormState>();
  String new_postId = Uuid().v4();
  String? issueBank;
  bool autoSlash = true;
  bool default_setting = false;
  List<String> info= [];

  TextEditingController cardName = TextEditingController();
  TextEditingController cardNumber = TextEditingController();
  TextEditingController exDate = TextEditingController();
  TextEditingController cvv = TextEditingController();

  String? cardType;


  handleSubmit()async{
    info.add('creditCard');
    info.add(cardName.text);
    info.add(cardNumber.text);
    info.add(cardType.toString());
    info.add(issueBank.toString());
    info.add(exDate.text);

    await usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('bankAccount').where('default',isEqualTo:true).get().then((snapshot){
      if(snapshot.size == 0){
        usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('creditCard').where('default',isEqualTo:true).get().then((snap){
          if(snap.size == 0){
            usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('creditCard').doc(new_postId).set(
                {
                  'cardName': cardName.text,
                  'cardNumber': cardNumber.text,
                  'cardType': cardType,
                  'issueBank': issueBank,
                  'exDate': exDate.text,
                  'cvv': cvv.text,
                  'postId': new_postId,
                  'default' : true,
                  'timestamp' : timestamp
                });
          }
        });
      }else{
        usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('creditCard').doc(new_postId).set(
            {
              'cardName': cardName.text,
              'cardNumber': cardNumber.text,
              'cardType': cardType,
              'issueBank': issueBank,
              'exDate': exDate.text,
              'cvv': cvv.text,
              'postId': new_postId,
              'default' : false,
              'timestamp' : timestamp
            });
      }
    });
    Navigator.pop(context,info);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      autoSlash = true;
      SizerUtil.deviceType == DeviceType.tablet?isTablet = true:isTablet = false;
    });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColour,
        title: InkWell(
            child: Text(widget.type,style: TextStyle(fontSize: 18)),
          onTap: (){
              FocusScope.of(context).requestFocus(new FocusNode());
          },
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(top: 20,right: 15),
            child: cardType == null?Text(''):InkWell(
                child: Text('เสร็จสิ้น',style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: (){
                  if(_formKey.currentState!.validate()) {
                    handleSubmit();
                  }
                }
            ),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: InkWell(
          onTap: (){
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: ListView(
              children: [
                SizedBox(height: 30),
                buildTextFormField('Name on card','',cardName,0),
                buildTextFormField('Card Number','',cardNumber,3),
                buildRowField('Card Type',cardType,() async{
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (context)=>selectedPage(text: 'ประเภทบัตร', list: cardTypeList)));
                  setState(() {
                    cardType = result.toString();
                  });
                }),
                buildRowField('Issue Bank',issueBank,() async{
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (context)=>selectedPage(text: 'ธนาคารที่ออกบัตร', list: bankList)));
                  setState(() {
                    issueBank = result.toString();
                  });
                }),
                buildTextFormFieldDate('Expiry Date','MM/YY',exDate,0),
                buildTextFormFieldDate('cvv','',cvv,2),
              ],
            ),
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
        Text(topic,style: topicStyle,),
        Container(
          color: Colors.transparent,
          height: 60,
          child: TextFormField(
            controller: controller,
            maxLength: topic == 'cvv'?3: topic == 'Expiry Date'?5:topic == 'Card Number'?16:40,
            keyboardType: topic == 'Card Number' || topic == 'Expiry Date' || topic == 'ccv'? TextInputType.number:TextInputType.name,
            decoration: InputDecoration(
                hintText: hintText,
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
              }
              return null;
            }
                :no == 1
                ?(value){
              if(value!.isEmpty){
                return 'โปรดใส่ข้อมูล';
              }else if(value.length!=10)
              {
                return 'โปรดใส่ข้อมูลให้ถูกต้อง';
              }
              return null;
            }:no == 2
                ?(value){
              if(value!.isEmpty){
                return 'โปรดใส่ข้อมูล';
              }else if(value.length!=3)
              {
                return 'โปรดใส่ข้อมูลให้ถูกต้อง';
              }
              return null;
            }:no == 3
                ?(value){
              if(value!.isEmpty){
                return 'โปรดใส่ข้อมูล';
              }else if(value.length!=16)
              {
                return 'โปรดใส่ข้อมูลให้ถูกต้อง';
              }
              return null;
            }:null
          ),
        ),
      ],
    );
  }

  Column buildTextFormFieldDate(String topic, String hintText ,TextEditingController controller,int no) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(topic,style: topicStyle,),
        Container(
          color: Colors.transparent,
          height: 60,
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                hintText: hintText,
                focusedBorder: const UnderlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFD35757),width: 3)
                ),
                labelStyle: TextStyle(color:themeColour)
            ),
            onChanged: (value){
              if(value.length == 2 && autoSlash == true){
                try{
                  exDate.text = value + '/';
                  setState(() {
                    autoSlash = false;
                  });
                }catch(e){
                  print(e);
                }
              }
            },
            validator:(value){
              if(value!.isEmpty){
                return 'โปรดใส่ข้อมูล';
              }else if(value.length>5)
              {
                return 'โปรดใส่ / ระหว่างเดือนและปี';
              }else if(value.length<5)
              {
                return 'โปรดใส่ / ระหว่างเดือนและปี';
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
        Text(topic,style: topicStyle),
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
                    Text('',style: TextStyle(color: Colors.grey.shade600,fontSize: 15),),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Divider(color: Colors.black,height:2),
                    )
                  ],
                ):Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,style: TextStyle(color: Colors.black,fontSize: 17),),
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
    return SafeArea(
      child: Scaffold(
        appBar: appBarWithBackArrow(text,isTablet),
        body: ListView.builder(
          itemCount: list.length,
          itemBuilder: (context,i){
            return InkWell(
              child: Card(
                child: ListTile(
                  title: Text(list[i].toString()),
                ),
              ),
              onTap: (){
                Navigator.pop(context,list[i]);
              },
            );
          },
        ),
      ),
    );
  }
}
