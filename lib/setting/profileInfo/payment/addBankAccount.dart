import 'package:flutter/material.dart';
import 'package:multipawmain/database/breedDatabase.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:remove_emoji/remove_emoji.dart';
import 'package:uuid/uuid.dart';
import '../../../authCheck.dart';
import 'package:sizer/sizer.dart';

final DateTime timestamp = DateTime.now();
bool isTablet = false;

class bankAccount extends StatefulWidget {
  final userId,postId,type,pop,fromCheckOut;
  bankAccount({required this.userId,this.postId,this.type,this.pop,this.fromCheckOut
  });

  @override
  _bankAccountState createState() => _bankAccountState();
}

class _bankAccountState extends State<bankAccount> {
  final _formKey = GlobalKey<FormState>();
  String new_postId = Uuid().v4();
  bool isLoading = false;
  bool default_setting = false;
  bool default_Refund = false;
  List<String> info= [];

  TextEditingController accountFirstName = TextEditingController();
  TextEditingController accountLastName = TextEditingController();
  TextEditingController accountNumber = TextEditingController();
  String? bankName,title;
  var remove = RemoveEmoji();

  checkDeafult()async{
    await usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('bankAccount').where('default',isEqualTo:true).get().then((snapshot){
      if(snapshot.size == 0){
        usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('creditCard').where('default',isEqualTo:true).get().then((snap){
          if(snap.size == 0){
            default_setting = true;
          }else{
            default_setting = false;
          }
        });
      }else{
        default_setting = false;
      }
    });
  }

  checkDefaultOTrefund()async{
    await usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('bankAccount').where('refundAccount',isEqualTo: true).get().then((snapshot){
      snapshot.size == 0? default_Refund = true: default_Refund = false;
    });
  }

  handleSubmit()async{
    info.add('bankAccount');
    info.add(title.toString()+' '+ accountFirstName.toString().trim() +' '+ accountLastName.toString().trim());
    info.add(accountNumber.text);
    info.add(bankName.toString());

    await checkDeafult();
    await usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('bankAccount').doc(new_postId).set(
        {
          'bankName': bankName,
          'title': title,
          'accountFirstName': remove.removemoji(accountFirstName.text).trim(),
          'accountLastName': remove.removemoji(accountLastName.text).trim(),
          'accountNumber': remove.removemoji(accountNumber.text).trim(),
          'postId': new_postId,
          'timestamp' : timestamp,
          'default': default_setting,
          'refundAccount': default_Refund
        });
    if(widget.fromCheckOut == true){
      Navigator.pop(context,info);
      Navigator.pop(context,info);
    }else{
      Navigator.pop(context,info);
    }
  }

  handleUpdate()async{
    await usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('bankAccount').doc(widget.postId).update(
        {
          'bankName': bankName,
          'title': title,
          'accountFirstName': remove.removemoji(accountFirstName.text),
          'accountLastName': remove.removemoji(accountLastName.text),
          'accountNumber': remove.removemoji(accountNumber.text),
          'timestamp' : timestamp
        });
    Navigator.pop(context);
  }


  getData()async{
    await usersRef.doc(widget.userId).collection('userInfo').doc(widget.userId).get().then((snapshot){
      if(snapshot.exists){
        bankName = snapshot.data()!['bankName'];
        title = snapshot.data()!['title'];
        accountFirstName.text = snapshot.data()!['accountFirstName'];
        accountLastName.text = snapshot.data()!['accountLastName'];
        accountNumber.text = snapshot.data()!['accountNumber'];
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      isLoading = false;
      SizerUtil.deviceType == DeviceType.tablet?isTablet = true:isTablet = false;
    });

    widget.postId != null?getData():null;
    checkDefaultOTrefund();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColour,
        leading: IconButton(onPressed: (){
          widget.pop == 1?Navigator.pop(context):null;
          Navigator.pop(context);
        },
            icon: Icon(Icons.arrow_back_ios_new ,color: Colors.white,)),
        title: Text(widget.type,style: TextStyle(fontSize: isTablet?20:16)),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: bankName == null ? SizedBox():Center(
              child: InkWell(
                  child: Text('เสร็จสิ้น',style: TextStyle(fontWeight: FontWeight.bold,fontSize: isTablet?20:16)),
                  onTap: (){
                    if(_formKey.currentState!.validate()) {
                      widget.type == 'เพิ่มบัญชีธนาคาร'?handleSubmit():handleUpdate();
                    }
                  }
              ),
            ),
          )
        ],
      ),
      body:  isLoading == true? loading():Form(
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
                buildRowField('คำนำหน้าชื่อ',title,() async{
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (context)=>selectedPage(text: 'คำนำหน้าชื่อ', list: titleList)));
                  setState(() {
                    title = result.toString();
                  });
                }),
                buildTextFormField('ชื่อ','** กรุณากรอกข้อมูลให้ตรงกับในสมุดบัญชี',accountFirstName,0),
                buildTextFormField('นามสกุล','** กรุณากรอกข้อมูลให้ตรงกับในสมุดบัญชี',accountLastName,0),
                buildRowField('ธนาคาร',bankName,() async{
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (context)=>selectedPage(text: 'รายชื่อธนาคาร', list: bankList)));
                  setState(() {
                    bankName = result.toString();
                  });
                }),
                buildTextFormField('หมายเลขบัญชี','',accountNumber,1),
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
        Text(topic,style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold),),
        Container(
          color: Colors.transparent,
          height: 60,
          child: TextFormField(
            controller: controller,
            keyboardType: topic == 'หมายเลขบัญชี'? TextInputType.number:TextInputType.name,
            decoration: InputDecoration(
                hintText: hintText,
                focusedBorder: const UnderlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFD35757),width: 3)
                ),
                labelStyle: TextStyle(color:themeColour,fontSize: isTablet?20:16)
            ),
            // Account Name
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
                :(value){
              if(value!.isEmpty){
                return 'โปรดใส่ข้อมูล';
              }else if(value.length!=10 || value.contains(RegExp(r'[^0-9]')))
              {
                return 'โปรดใส่ข้อมูลให้ถูกต้อง';
              }else if(value.contains(RegExp(r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'))){
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
    return SafeArea(
      child: Scaffold(
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
      ),
    );
  }
}