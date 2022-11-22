import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:multipawmain/authCheck.dart';
import 'package:multipawmain/setting/profileInfo/address/editAddress.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:sizer/sizer.dart';

class address extends StatefulWidget {
  final userId;
  address({required this.userId});

  @override
  _addressState createState() => _addressState();
}

class _addressState extends State<address> {
  bool isTablet = false;

  deleteAddress(String postId)async{
    await usersRef.doc(widget.userId).collection('deliveryAddress').doc(postId).delete();
  }

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
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: themeColour,
        title: Text('ที่อยู่เพื่อจัดส่ง',style: TextStyle(fontSize: isTablet?25:18)),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: usersRef.doc(widget.userId).collection('deliveryAddress').orderBy('timestamp').snapshots(),
        builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Text('error');
          }else if(snapshot.hasData){
            return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              return InkWell(
                child: Slidable(
                  actionPane: SlidableDrawerActionPane(),
                  actionExtentRatio: 0.15,
                  child: Container(
                    color: Colors.white,
                    margin: EdgeInsets.only(top: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: Icon(FontAwesomeIcons.houseUser,color: themeColour,size: 30),
                        title: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['name'],style: TextStyle(color: Colors.black,fontSize: isTablet?20:16)),
                            Text(data['phoneNo'],style: TextStyle(color: Colors.grey.shade800,fontSize: isTablet?20:16)),
                            SizedBox(height: 10)
                          ],
                        ),
                        subtitle: Text(
                            data['moo'] == ''
                            ? '${data['houseNo']} ${data['road']} ${data['subdistrict']} ${data['district']} ${data['city']} ${data['postCode']}'
                            : data['road'] == ''
                                ?'${data['houseNo']} ม.${data['moo']} ${data['subdistrict']} ${data['district']} ${data['city']} ${data['postCode']}'
                                :'${data['houseNo']} ม.${data['moo']} ${data['road']} ${data['subdistrict']} ${data['district']} ${data['city']} ${data['postCode']}'

                            ,maxLines: 3,style: TextStyle(color: Colors.black,fontSize: isTablet?20:16)),
                        trailing: InkWell(
                          child: Text('แก้ไข',style: TextStyle(color: themeColour,fontSize: isTablet?20:16)),
                          onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>editAddress(userId: widget.userId,postId: data['postId'],type: 'แก้ไขสถานที่จัดส่ง'))),
                        ),
                      ),
                    ),
                  ),
                  secondaryActions: [
                    IconSlideAction(
                      caption: 'ลบ',
                      color: themeColour,
                      icon: LineAwesomeIcons.trash,
                      onTap: (){
                        setState(() {
                          deleteAddress(data['postId']);
                        });
                      },
                    )
                  ],
                ),
                onTap: (){
                  List<dynamic> dataList = [];

                  dataList.add(data['name']);
                  dataList.add(data['houseNo']);
                  dataList.add(data['moo']);
                  dataList.add(data['road']);
                  dataList.add(data['subdistrict']);
                  dataList.add(data['district']);
                  dataList.add(data['city']);
                  dataList.add(data['postCode']);
                  dataList.add(data['phoneNo']);

                  Navigator.pop(context,dataList);
                },
              );
            }).toList(),
            );
          }
          return Text('');
        }
      ),

      floatingActionButton: Padding(
        padding: EdgeInsets.only(left: 30,bottom: 20),
        child: FloatingActionButton(
          backgroundColor: themeColour,
          onPressed:(){
            Navigator.push(context,
                MaterialPageRoute(builder: (context)=> editAddress(userId: widget.userId,type: 'เพิ่มสถานที่จัดส่ง')));
          },
          child: Icon(
              Icons.add,
              color: Colors.white
          ),
        ),
      ),
    );
  }
}

