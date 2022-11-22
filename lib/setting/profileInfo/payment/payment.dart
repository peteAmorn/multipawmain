import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:multipawmain/setting/profileInfo/payment/addBankAccount.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:sizer/sizer.dart';
import '../../../authCheck.dart';
import 'addCreditCard.dart';

class payment extends StatefulWidget {
  final userId,fromCheckOut;
  payment({required this.userId,this.fromCheckOut});

  @override
  _paymentState createState() => _paymentState();
}

class _paymentState extends State<payment> with SingleTickerProviderStateMixin{
  int _selectedIndex = 0;
  late TabController controller;
  bool isTablet = false;

  List<Widget> list = [
    Tab(text: 'ข้อมูลบัญชีธนาคารจะใช้สำหรับกรณีมีการคืนเงิน'),
    // Tab(text: 'บัตรเครดิต'),
  ];

  deleteBankAccount(String postId)async{
    await usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('bankAccount').doc(postId).delete().then((data){
      usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('bankAccount').where('refundAccount',isEqualTo: true).get().then((snapshot){
        if(snapshot.size == 0){
          usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('bankAccount').get().then((snap){
            usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('bankAccount').doc(snap.docs.first.id).update(
                {
                  'refundAccount': true
                });
          });
        }
      });
    });
  }

  // deleteCreditCard(String postId)async{
  //   await usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('creditCard').doc(postId).delete();
  // }

  setDefaultPayment(String postId, String type)async{
    await usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('bankAccount').where('default',isEqualTo: true).get().then((snapshot){
      if(snapshot.size>0){
        snapshot.docs.forEach((doc) {
          usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('bankAccount').doc(doc.id).update({
            'default': false,
          });
        });
      }
    });
    await usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('creditCard').where('default',isEqualTo: true).get().then((snapshot){
      if(snapshot.size>0){
        snapshot.docs.forEach((doc) {
          usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('creditCard').doc(doc.id).update({
            'default': false,
          });
        });
      }
    });
    await usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection(type).doc(postId).update({
      'default': true
    });
  }


  setDefaultReceive(String postId)async{
    await usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('bankAccount').where('refundAccount',isEqualTo: true).get().then((snapshot){
      if(snapshot.size>0){
        snapshot.docs.forEach((doc) {
          usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('bankAccount').doc(doc.id).update({
            'refundAccount': false,
          });
        });
      }
    });
    await usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('bankAccount').doc(postId).update({
      'refundAccount': true
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      SizerUtil.deviceType == DeviceType.tablet?isTablet = true:isTablet = false;
    });

    controller = TabController(length: list.length, vsync: this);
    controller.addListener(() {
      setState(() {
        _selectedIndex = controller.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColour,
        title: Text('ข้อมูลบัญชีธนาคาร',style: TextStyle(fontSize: isTablet?25:18)),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios,color: Colors.white),onPressed: (){
          if(widget.fromCheckOut == true){
            Navigator.pop(context);
            Navigator.pop(context);
          }else{
            Navigator.pop(context);
          }
        }),
      ),
      body: DefaultTabController(
        length: 1,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: TabBar(
              indicatorColor: themeColour,
              unselectedLabelColor: Colors.grey,
              labelColor: Colors.black,
              tabs: list
            ),
          ),
          body: TabBarView(
              children: <Widget>[
                Scaffold(
                  body: StreamBuilder<QuerySnapshot>(
                      stream: usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('bankAccount').orderBy('timestamp').snapshots(),
                      builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return Text('error');
                        }else if(snapshot.hasData){
                          return ListView(
                            children: snapshot.data!.docs.map((DocumentSnapshot document) {
                              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                              String sensor_account = data['accountNumber'];
                              sensor_account = sensor_account.substring(sensor_account.length - 4);
                              return InkWell(
                                child: Slidable(
                                    actionPane: SlidableDrawerActionPane(),
                                    actionExtentRatio: 0.15,
                                    child: Container(
                                      color: Colors.white,
                                      margin: EdgeInsets.only(top: 10),
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: ListTile(
                                            leading: Container(
                                              height: 30,
                                                width: 30,
                                                child: data['bankName'] == 'ทหารไทยธนชาต จำกัด (มหาชน)'?Image.asset('assets/bank_icons/${data['bankName']}.jpg')
                                                    :Image.asset('assets/bank_icons/${data['bankName']}.png')
                                            ),
                                            title: Text(data['bankName'],style: TextStyle(color: Colors.black,fontSize: isTablet?20:16)),
                                            subtitle: data['default'] == true || data['refundAccount']?Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(height: 5),
                                                // data['default'] == true?Row(
                                                //   children: [
                                                //     Icon(LineAwesomeIcons.coins,color: Colors.deepOrange.shade900,),
                                                //     SizedBox(width: 5),
                                                //     Text('ใช้เป็นบัญชีจ่ายเงินหลัก',style: TextStyle(color: Colors.deepOrange.shade900)),
                                                //   ],
                                                // ):SizedBox(),
                                                // SizedBox(height: 3),
                                                data['refundAccount'] == true
                                                    ?Row(
                                                  children: [
                                                    Icon(LineAwesomeIcons.hand_holding_us_dollar,color: Colors.blue.shade900,),
                                                    SizedBox(width: 5),
                                                    Text('ใช้เป็นบัญชีรับเงิน',style: TextStyle(color: Colors.blue.shade900,fontSize: isTablet?20:16)),
                                                  ],
                                                ):SizedBox(),
                                              ],
                                            ):SizedBox(),
                                            trailing: Text('*${sensor_account}',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: isTablet?20:16))
                                        ),
                                      ),
                                    ),
                                  secondaryActions: [
                                    IconSlideAction(
                                      caption: 'ใช้รับเงิน',
                                      color: Colors.blue.shade900,
                                      icon: LineAwesomeIcons.hand_holding_us_dollar,
                                      onTap: (){
                                        setDefaultReceive(data['postId']);
                                      },
                                    ),
                                    // IconSlideAction(
                                    //   caption: 'ใช้จ่ายเงิน',
                                    //   foregroundColor: Colors.white,
                                    //   color: Colors.deepOrange.shade700,
                                    //   icon: LineAwesomeIcons.coins,
                                    //   onTap: (){
                                    //     setDefaultPayment(data['postId'],'bankAccount');
                                    //   },
                                    // ),
                                    IconSlideAction(
                                      caption: 'ลบ',
                                      color: themeColour,
                                      icon: LineAwesomeIcons.trash,
                                      onTap: (){
                                        setState(() {
                                          deleteBankAccount(data['postId']);
                                        });
                                      },
                                    )
                                  ],
                                ),
                                onTap: (){
                                  List<String> info = [];
                                  widget.fromCheckOut != true?null:info.add('bankAccount');
                                  widget.fromCheckOut != true?null:info.add(data['title']+' '+data['accountFirstName']+' '+data['accountLastName']);
                                  widget.fromCheckOut != true?null:info.add(data['accountNumber']);
                                  widget.fromCheckOut != true?null:info.add(data['bankName']);
                                  widget.fromCheckOut != true?null:Navigator.pop(context,info);
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
                      onPressed:()async{
                        final result = Navigator.push(context,
                            MaterialPageRoute(builder: (context)=> bankAccount(userId: widget.userId,type: 'เพิ่มบัญชีธนาคาร',fromCheckOut: widget.fromCheckOut)));
                      },
                      child: Icon(
                          Icons.add,
                          color: Colors.white
                      ),
                    ),
                  ),
                ),

                // Scaffold(
                //   body: StreamBuilder<QuerySnapshot>(
                //       stream: usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('creditCard').orderBy('timestamp').snapshots(),
                //       builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot) {
                //         if (!snapshot.hasData) {
                //           return Text('error');
                //         }else if(snapshot.hasData){
                //           return ListView(
                //             children: snapshot.data!.docs.map((DocumentSnapshot document) {
                //               Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                //               String sensor_card = data['cardNumber'];
                //               sensor_card = sensor_card.substring(sensor_card.length - 4);
                //               return InkWell(
                //                 child: Slidable(
                //                   actionPane: SlidableDrawerActionPane(),
                //                   actionExtentRatio: 0.15,
                //                   child: Container(
                //                     color: Colors.white,
                //                     margin: EdgeInsets.only(top: 10),
                //                     child: Padding(
                //                       padding: EdgeInsets.all(8.0),
                //                       child: ListTile(
                //                         leading: data['cardType'] == 'visa'
                //                             ?Icon(FontAwesomeIcons.ccVisa,color: Colors.blue)
                //                             :data['cardType'] == 'MasterCard'?Icon(FontAwesomeIcons.ccMastercard,color: Colors.red)
                //                             :data['cardType'] == 'JCB'?Icon(FontAwesomeIcons.ccJcb,color: Colors.green):Text(''),
                //                         title: Text(data['issueBank'],style: TextStyle(color: Colors.black,fontSize: 15)),
                //                           subtitle: data['default'] == true
                //                               ?Row(
                //                             crossAxisAlignment: CrossAxisAlignment.start,
                //                             children: [
                //                               Icon(LineAwesomeIcons.coins,color: Colors.yellow.shade900),
                //                               SizedBox(width: 5),
                //                               Text('ใช้เป็นบัญชีจ่ายเงินหลัก',style: TextStyle(color: Colors.deepOrange.shade900)),
                //                             ],
                //                           ):SizedBox(),
                //                         trailing: Text('*${sensor_card}',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold))
                //                       ),
                //                     ),
                //                   ),
                //                   secondaryActions: [
                //                     IconSlideAction(
                //                       caption: 'ใช้จ่ายเงิน',
                //                       color: Colors.deepOrange.shade700,
                //                       foregroundColor: Colors.white,
                //                       icon: LineAwesomeIcons.coins,
                //                       onTap: (){
                //                         setDefaultPayment(data['postId'],'creditCard');
                //                       },
                //                     ),
                //                     IconSlideAction(
                //                       caption: 'ลบ',
                //                       color: themeColour,
                //                       icon: LineAwesomeIcons.trash,
                //                       onTap: (){
                //                         setState(() {
                //                           deleteCreditCard(data['postId']);
                //                         });
                //                       },
                //                     )
                //                   ],
                //                 ),
                //                 onTap: (){
                //                   List<String> info = [];
                //                   info.add('creditCard');
                //                   info.add(data['cardName']);
                //                   info.add(data['cardNumber']);
                //                   info.add(data['cardType']);
                //                   info.add(data['cvv']);
                //                   info.add(data['exDate']);
                //                   info.add(data['issueBank']);
                //                   Navigator.pop(context,info);
                //                 },
                //               );
                //             }).toList(),
                //           );
                //         }
                //         return Text('');
                //       }
                //   ),
                //   floatingActionButton: Padding(
                //     padding: EdgeInsets.only(left: 30,bottom: 20),
                //     child: FloatingActionButton(
                //       backgroundColor: themeColour,
                //       onPressed:(){
                //         Navigator.push(context,
                //             MaterialPageRoute(builder: (context)=> addCreditCard(userId: widget.userId,type: 'เพิ่มบัตรเครดิต',fromCheckOut: widget.fromCheckOut)));
                //       },
                //       child: Icon(
                //           Icons.add,
                //           color: Colors.white
                //       ),
                //     ),
                //   ),
                // ),
              ]),
        ),
      ),
    );
  }
}
