import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:multipawmain/database/posts.dart';
import 'package:multipawmain/myshop/flightDetail.dart';
import 'package:multipawmain/orderDetailSeller.dart';
import 'package:multipawmain/pages/timeline.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:intl/intl.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:sizer/sizer.dart';
import '../authCheck.dart';
import 'dart:io';

final DateTime now = DateTime.now();
bool isTablet = false;

class storeManagement extends StatefulWidget {
  final userId;
  late int itemToPrepare,itemDispatched,itemGuarantee;
  storeManagement({required this.userId, required this.itemToPrepare,required this.itemDispatched, required this.itemGuarantee});

  @override
  _storeManagementState createState() => _storeManagementState();
}

class _storeManagementState extends State<storeManagement> with SingleTickerProviderStateMixin{
  int _selectedIndex = 0;
  late TabController controller;
  bool isLoading = false;
  String? monthAlpha,sellerName;
  String? issueBank,accountName,accountNumber;

  List<toPrepareList> orderToPrepareList = [];
  List<toDispatchedList> orderToDispatchedList = [];
  List<toNotiList> orderToGuaranteeList = [];
  List<toReviewList> orderToReviewList = [];
  List<toCompletedList> orderToCompletedList = [];
  List<toRefundList> orderToRefundList = [];
  List<toCancelList> orderToCancelList = [];

  getUserInfo()async{
    await usersRef.doc(widget.userId).get().then((snapshot){
      sellerName = snapshot.data()!['name'];
    });
  }

  getData()async{
    await buyerOnPrepareRef.where('sellerId',isEqualTo: widget.userId).get().then((snap){
      snap.docs.forEach((doc) {orderToPrepareList.add(toPrepareList.fromDocument(doc));});
    });
    orderToPrepareList.sort((b,a)=>a.Timestamp_received_ticket_time.compareTo(b.Timestamp_received_ticket_time));

    await buyerOnDispatchRef.where('sellerId',isEqualTo: widget.userId).get().then((snap){
      snap.docs.forEach((doc) {orderToDispatchedList.add(toDispatchedList.fromDocument(doc));});
    });
    orderToDispatchedList.sort((b,a)=>a.Timestamp_dispatched_time.compareTo(b.Timestamp_dispatched_time));

    await buyerOnGuaranteeRef.where('sellerId',isEqualTo: widget.userId).get().then((snap){
      snap.docs.forEach((doc) {orderToGuaranteeList.add(toNotiList.fromDocument(doc));});
    });
    orderToGuaranteeList.sort((b,a)=>a.Timestamp_guarantee_ticket_start_time.compareTo(b.Timestamp_guarantee_ticket_start_time));

    await buyerOnReviewRef.where('sellerId',isEqualTo: widget.userId).get().then((snap){
      snap.docs.forEach((doc) {orderToReviewList.add(toReviewList.fromDocument(doc));});
    });
    orderToReviewList.sort((b,a)=>a.Timestamp_guarantee_ticket_end_time.compareTo(b.Timestamp_guarantee_ticket_end_time));

    await buyerOnCompleteRef.where('sellerId',isEqualTo: widget.userId).get().then((snap){
      snap.docs.forEach((doc) {
        orderToCompletedList.add(toCompletedList.fromDocument(doc));
      });
    });
    orderToCompletedList.sort((b,a)=>a.Timestamp_completed.compareTo(b.Timestamp_completed));

    await buyerOnCancelRef.where('sellerId',isEqualTo: widget.userId).get().then((snap){
      snap.docs.forEach((doc) {
        orderToCancelList.add(toCancelList.fromDocument(doc));
      });
    });
    orderToCancelList.sort((b,a)=>a.cancelBySystem_time.compareTo(b.cancelBySystem_time));

    await buyerOnRefundRef.where('sellerId',isEqualTo: widget.userId).get().then((snap){
      snap.docs.forEach((doc) {orderToRefundList.add(toRefundList.fromDocument(doc));});
    });
    orderToRefundList.sort((b,a)=>a.Timestamp_product_claimed_approved_time.compareTo(b.Timestamp_product_claimed_approved_time));
  }

  getNotiCounter(){
    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() {
        isLoading = true;

        widget.itemToPrepare = orderToPrepareList.length;
        widget.itemDispatched = orderToDispatchedList.length;
        widget.itemGuarantee = orderToGuaranteeList.length;

        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      isLoading = true;
      SizerUtil.deviceType == DeviceType.tablet?isTablet = true:isTablet = false;
    });

    getData();
    getNotiCounter();
    getUserInfo();
    controller = TabController(
        initialIndex: _selectedIndex,
        length: 7,
        vsync: this
    );
    controller.addListener(() {
      setState(() {
        _selectedIndex = controller.index;
      });
    });
    Future.delayed(const Duration(milliseconds: 120), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  OrderPreparedToDispatch(
      String buyerName,
      String ticket_postId,
      String buyerId,
      String type,
      String deliMethod,
      int date,
      int month,
      int year,
      String topic,
      String img,
      String seller,
      String breed,
      String weight,
      int price,
      int promo,
      int qty,
      int deliprice,
      int discount,
      int total,
      String postId,
      String airline,
      String flightNumber,
      String departureTime,
      String arraivalTime,
      Timestamp Timestamp_received_ticket_time,
      )async{

    String day_string = date<10?'0${date.toString()}':date.toString();
    String month_string = month<10?'0${month.toString()}':month.toString();

    deliMethod != 'รับเองที่ฟาร์ม'?await notiRef.doc().set({
      'message': airline != '0'?"ลูกสุนัข/แมวกำลังถูกจัดส่ง โปรดตรวจสอบเที่ยวบิน": "สินค้ากำลังถูกจัดส่ง",
      'peerId': buyerId,
      'peerImg': img,
      'peerName': topic,
      'timestamp': now,
      'type': 'noti',
      'userId': widget.userId,
      'userImg': img,
      'userName': "MULTIPAWS",
    }):null;

    await buyerOnPrepareRef.doc(ticket_postId).get().then((snapshot){
      buyerOnDispatchRef.doc(ticket_postId).set({
        'type': type,
        'seller': seller,
        'sellerId': widget.userId,
        'userId': buyerId,
        'userName': buyerName,
        'topic': topic,
        'breed': breed,
        'weight': weight,
        'image': img,
        'price': price,
        'promo': promo,
        'quantity':qty,
        'deliPrice': deliprice,
        'discount': discount,
        'total': total,
        'postId': postId,
        'ticket_postId': ticket_postId,
        'delivery_method': deliMethod,
        'status': 'กำลังขนส่ง',
        'airline': airline,
        'flightNumber': flightNumber,
        'flightDepartureTime': departureTime,
        'flightArrivalTime': arraivalTime,

        'Timestamp_due_to_received': DateTime.now().add(Duration(days: 14)).millisecondsSinceEpoch,
        'Timestamp_expected_dispatched_time':type == 'pet'?DateTime.parse('${year}-${month_string}-${day_string}'):now,
        'Timestamp_received_ticket_time':Timestamp_received_ticket_time,
        'Timestamp_dispatched_time':now,
        'rp_BankName': snapshot.data()!['rp_BankName'],
        'rp_AccountName': snapshot.data()!['rp_AccountName'],
        'rp_AccountNumber': snapshot.data()!['rp_AccountNumber'],

      });
      buyerOnPrepareRef.doc(ticket_postId).delete();
    });
  }

  Future<dynamic> toDeliverAlertDialog(
      BuildContext context,
      String buyerName,
      String ticket_postId,
      String buyerId,
      String type,
      String deliMethod,
      int date,
      int month,
      int year,
      String topic,
      String img,
      String seller,
      String breed,
      String weight,
      int price,
      int promo,
      int qty,
      int deliprice,
      int discount,
      int total,
      String postId,
      String airline,
      String flightNumber,
      String departureTime,
      String arraivalTime,
      Timestamp Timestamp_received_ticket_time,
      ) {
    return showDialog(
        context: context,
        builder: (BuildContext context) =>
        Platform.isIOS ?
        CupertinoAlertDialog(
          content: Text('กรุณาให้ผู้ซื้อกดรับสินค้าในระบบต่อหน้า พร้อมถ่ายรูปขณะส่งมอบเก็บไว้เป็นหลักฐาน',style: TextStyle(fontSize: isTablet?20:16)),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('ยืนยัน',style: TextStyle(color: themeColour,fontSize: isTablet?20:16),),
              onPressed: () async {
                if(type == 'pet'){
                  await OrderPreparedToDispatch(
                      buyerName,
                      ticket_postId,
                      buyerId,
                      type,
                      deliMethod,
                      date,
                      month,
                      year,
                      topic,
                      img,
                      seller,
                      breed,
                      weight,
                      price,
                      promo,
                      qty,
                      deliprice,
                      discount,
                      total,
                      postId,
                      airline,
                      flightNumber,
                      departureTime,
                      arraivalTime,
                      Timestamp_received_ticket_time,
                  );
                }
                setState(() {
                  type == 'pet'
                      ?_selectedIndex = 1:_selectedIndex = 2;
                });

                orderToPrepareList.clear();
                orderToDispatchedList.clear();

                await buyerOnDispatchRef.where('sellerId',isEqualTo: widget.userId).get().then((snap){
                  snap.docs.forEach((doc) {orderToDispatchedList.add(toDispatchedList.fromDocument(doc));});
                });
                orderToDispatchedList.sort((b,a)=>a.Timestamp_dispatched_time.compareTo(b.Timestamp_dispatched_time));

                await buyerOnPrepareRef.where('sellerId',isEqualTo: widget.userId).get().then((snap){
                  snap.docs.forEach((doc) {orderToPrepareList.add(toPrepareList.fromDocument(doc));});
                });
                orderToPrepareList.sort((b,a)=>a.Timestamp_received_ticket_time.compareTo(b.Timestamp_received_ticket_time));

                setState(() {
                  getNotiCounter();
                  Navigator.pop(context);
                });
              },
            ),
            CupertinoDialogAction(
              child: Text('ยกเลิก',style: TextStyle(color: Colors.black,fontSize: isTablet?20:16)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ) :
        AlertDialog(
          backgroundColor: Colors.grey.shade100,
          content: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.blue.shade50,
              ),
              child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Text('กรุณาให้ผู้ซื้อกดรับสินค้าในระบบต่อหน้า พร้อมถ่ายรูปขณะส่งมอบเก็บไว้เป็นหลักฐาน',style: TextStyle(color: Colors.black,fontSize: isTablet?20:16)),
              )
          ),
          actions: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  SizedBox(width: 20),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Colors.green,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Center(
                              child: Text('ยืนยัน',style: TextStyle(color: Colors.white,fontSize: isTablet?20:16),)),
                        ),
                      ),
                      onTap: () async {
                        await OrderPreparedToDispatch(
                          buyerName,
                          ticket_postId,
                          buyerId,
                          type,
                          deliMethod,
                          date,
                          month,
                          year,
                          topic,
                          img,
                          seller,
                          breed,
                          weight,
                          price,
                          promo,
                          qty,
                          deliprice,
                          discount,
                          total,
                          postId,
                          airline,
                          flightNumber,
                          departureTime,
                          arraivalTime,
                          Timestamp_received_ticket_time,
                        );
                        setState(() {
                          type == 'pet'
                              ?_selectedIndex = 1:_selectedIndex = 2;
                        });

                        orderToPrepareList.clear();
                        orderToDispatchedList.clear();

                        await buyerOnDispatchRef.where('sellerId',isEqualTo: widget.userId).get().then((snap){
                          snap.docs.forEach((doc) {orderToDispatchedList.add(toDispatchedList.fromDocument(doc));});
                        });
                        orderToDispatchedList.sort((b,a)=>a.Timestamp_dispatched_time.compareTo(b.Timestamp_dispatched_time));

                        await buyerOnPrepareRef.where('sellerId',isEqualTo: widget.userId).get().then((snap){
                          snap.docs.forEach((doc) {orderToPrepareList.add(toPrepareList.fromDocument(doc));});
                        });
                        orderToPrepareList.sort((b,a)=>a.Timestamp_received_ticket_time.compareTo(b.Timestamp_received_ticket_time));

                        setState(() {
                          getNotiCounter();
                          Navigator.pop(context);
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Colors.red.shade900,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Center(
                              child: Text('ยกเลิก',style: TextStyle(color: Colors.white,fontSize: isTablet?20:16))),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(width: 20),
                ],
              ),
            )
          ],
        )
    );
  }

  refreshCancel()async{
    orderToCancelList.clear();
    await buyerOnCancelRef.where('userId',isEqualTo: widget.userId).get().then((snap){
      snap.docs.forEach((doc) {
        orderToCancelList.add(toCancelList.fromDocument(doc));
      });
    });
    orderToCancelList.sort((b,a)=>a.cancelBySystem_time.compareTo(b.cancelBySystem_time));
  }

  Padding buildTicketDispatched(
      BuildContext context,
      String ticket_postId,
      String deliMethod,
      String imgurl,
      String status,
      String airline,
      String flightNumber,
      String departureTime,
      String arraivalTime,
      Timestamp_received_ticket_time,
      Timestamp_dispatched_time,
      String button,
      Function() ontap){

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(height: 10),
            InkWell(
              child: Container(
                height: 25,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Icon(LineAwesomeIcons.box,color: themeColour)
                          ),
                          Text('รอผู้ซื้อกดรับสินค้า',style: TextStyle(color: themeColour,fontSize: isTablet?20:16))
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(Icons.arrow_forward_ios),
                    )
                  ],
                ),
              ),
              onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>
                  timeline(
                    ticket_postId: ticket_postId,
                    imgUrl: imgurl,
                    status: 'กำลังขนส่ง',
                    deliMethod: deliMethod,
                    flightNo: flightNumber,
                    airline: airline,
                    Timestamp_received_ticket_time: Timestamp_received_ticket_time,
                    Timestamp_dispatched_time: Timestamp_dispatched_time,
                  ))),
            ),
            Padding(padding: EdgeInsets.all(5),child: Divider(color: Colors.grey.shade500)),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                  color: themeColour,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(button,style: TextStyle(color: Colors.white,fontSize: 15)),
                  ),
                ),
                onTap: ontap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding localIconbutton(IconData icon,Function() ontap) {
    return Padding(
      padding: const EdgeInsets.only(right: 15.0),
      child: InkWell(
        child: Icon(
          icon,
          color: themeColour,
          size: 28,
        ),
        onTap: ontap,
      ),
    );
  }

  Container buildContainerNotification(int num) {
    return Container(
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white
      ),
      child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(num >99?'99+':num.toString(),
              style: TextStyle(color: themeColour)
          )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: themeColour,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios,color: Colors.white),onPressed: ()=> Navigator.pop(context)),
        title: Text('รายการขาย',style: TextStyle(color: Colors.white,fontSize: isTablet?22:18)),
        bottom: TabBar(
          indicatorColor: Colors.blue.shade200,
          labelColor: Colors.blue.shade200,
          unselectedLabelColor: Colors.white,
          controller: controller,
          isScrollable: true,
          tabs: [
            Tab(
                child: Row(
                  children: [
                    Text('เตรียมจัดส่ง',style: TextStyle(fontSize: isTablet?20:15)),
                    SizedBox(width: 10),
                    widget.itemToPrepare == 0?SizedBox():buildContainerNotification(widget.itemToPrepare)
                  ],
                ),icon:Icon(FontAwesomeIcons.boxOpen)),
            Tab(
                child: Row(
                  children: [
                    Text('กำลังขนส่ง',style: TextStyle(fontSize: isTablet?20:15)),
                    SizedBox(width: 10),
                    widget.itemDispatched == 0?SizedBox():buildContainerNotification(widget.itemDispatched)
                  ],
                ),icon:Icon(FontAwesomeIcons.shippingFast)),
            Tab(
                child: Row(
                  children: [
                    Text('การันตี',style: TextStyle(fontSize: isTablet?20:15)),
                    SizedBox(width: 10),
                    widget.itemGuarantee == 0?SizedBox():buildContainerNotification(widget.itemGuarantee)
                  ],
                ),icon:Icon(FontAwesomeIcons.shieldAlt)),

            Tab(child: Text('รอการรีวิว',style: TextStyle(fontSize: isTablet?20:15)),icon:Icon(FontAwesomeIcons.pencilRuler)),
            Tab(child: Text('สำเร็จ',style: TextStyle(fontSize: isTablet?20:15)),icon:Icon(FontAwesomeIcons.check)),
            Tab(child: Text('เคลมสินค้า',style: TextStyle(fontSize: isTablet?20:15)),icon:Icon(FontAwesomeIcons.undoAlt)),
            Tab(child: Text('ยกเลิกสินค้า',style: TextStyle(fontSize: isTablet?20:15)),icon:Icon(FontAwesomeIcons.ban)),
          ],
        ),
      ),
      body: isLoading == true? loading():TabBarView(
          controller: controller,
          children: <Widget>[

            //######  เตรียมจัดส่ง
            ListView.builder(
                itemCount: orderToPrepareList.length,
                itemBuilder: (context,i) {
                  return buildOrderPrepare(
                      context,
                      orderToPrepareList[i].userId,
                      orderToPrepareList[i].userName,
                      orderToPrepareList[i].seller,
                      orderToPrepareList[i].delivery_method,
                      orderToPrepareList[i].image,
                      orderToPrepareList[i].topic,
                      orderToPrepareList[i].breed,
                      orderToPrepareList[i].price,
                      orderToPrepareList[i].promo,
                      orderToPrepareList[i].quantity,
                      orderToPrepareList[i].discount,
                      orderToPrepareList[i].total,
                      orderToPrepareList[i].dispatchDate,
                      orderToPrepareList[i].dispatchMonth,
                      orderToPrepareList[i].dispatchYear,
                      orderToPrepareList[i].Timestamp_dueToDeliveryAlert,
                      orderToPrepareList[i].ticket_postId,
                      orderToPrepareList[i].postId,
                      orderToPrepareList[i].sellerId,
                      orderToPrepareList[i].type,
                      orderToPrepareList[i].deliPrice,
                      orderToPrepareList[i].delivery_method,
                      orderToPrepareList[i].Timestamp_received_ticket_time,
                      orderToPrepareList[i].weight,
                      orderToPrepareList[i].deliPrice,
                      orderToPrepareList[i].delivery_method == 'รับเองที่ฟาร์ม'
                          ? 'มารับน้องได้เลย'
                          : 'ส่งสินค้าแล้ว',
                          () async {
                            if (orderToPrepareList[i].delivery_method ==
                                'ส่งทางอากาศ (รับที่สนามบิน)') {
                              var result = await Navigator.push(
                                  context, MaterialPageRoute(builder: (context) =>
                                  flightDetail()));
                              OrderPreparedToDispatch(
                                  orderToPrepareList[i].userName,
                                  orderToPrepareList[i].ticket_postId,
                                  orderToPrepareList[i].userId,
                                  orderToPrepareList[i].type,
                                  orderToPrepareList[i].delivery_method,
                                  orderToPrepareList[i].dispatchDate,
                                  orderToPrepareList[i].dispatchMonth,
                                  orderToPrepareList[i].dispatchYear,
                                  orderToPrepareList[i].topic,
                                  orderToPrepareList[i].image,
                                  orderToPrepareList[i].seller,
                                  orderToPrepareList[i].breed,
                                  orderToPrepareList[i].weight,
                                  orderToPrepareList[i].price,
                                  orderToPrepareList[i].promo,
                                  orderToPrepareList[i].quantity,
                                  orderToPrepareList[i].deliPrice,
                                  orderToPrepareList[i].discount,
                                  orderToPrepareList[i].total,
                                  orderToPrepareList[i].postId,
                                  result[0],
                                  result[1],
                                  result[2],
                                  result[3],
                                  orderToPrepareList[i].Timestamp_received_ticket_time
                              ).then((value)async{
                                await buyerOnPrepareRef.doc(orderToPrepareList[i].ticket_postId).get().then((snapshot)async{
                                  if(!snapshot.exists){
                                    setState(() {
                                      isLoading = true;
                                    });
                                    orderToPrepareList.clear();
                                    orderToDispatchedList.clear();

                                    await buyerOnPrepareRef.where('sellerId',isEqualTo: widget.userId).get().then((snap){
                                      snap.docs.forEach((doc) {orderToPrepareList.add(toPrepareList.fromDocument(doc));});
                                    });
                                    orderToPrepareList.sort((b,a)=>a.Timestamp_received_ticket_time.compareTo(b.Timestamp_received_ticket_time));

                                    await buyerOnDispatchRef.where('sellerId',isEqualTo: widget.userId).get().then((snap){
                                      snap.docs.forEach((doc) {orderToDispatchedList.add(toDispatchedList.fromDocument(doc));});
                                    });
                                    orderToDispatchedList.sort((b,a)=>a.Timestamp_dispatched_time.compareTo(b.Timestamp_dispatched_time));

                                    setState(() {
                                      controller.index = 1;
                                      getNotiCounter();
                                      isLoading = false;
                                    });
                                  }
                                });
                              });
                            }else{
                              toDeliverAlertDialog(
                                context,
                                  orderToPrepareList[i].userName,
                                  orderToPrepareList[i].ticket_postId,
                                  orderToPrepareList[i].userId,
                                  orderToPrepareList[i].type,
                                  orderToPrepareList[i].delivery_method,
                                  orderToPrepareList[i].dispatchDate,
                                  orderToPrepareList[i].dispatchMonth,
                                  orderToPrepareList[i].dispatchYear,
                                  orderToPrepareList[i].topic,
                                  orderToPrepareList[i].image,
                                  orderToPrepareList[i].seller,
                                  orderToPrepareList[i].breed,
                                  orderToPrepareList[i].weight,
                                  orderToPrepareList[i].price,
                                  orderToPrepareList[i].promo,
                                  orderToPrepareList[i].quantity,
                                  orderToPrepareList[i].deliPrice,
                                  orderToPrepareList[i].discount,
                                  orderToPrepareList[i].total,
                                  orderToPrepareList[i].postId,
                                  '0',
                                  '0',
                                  '0',
                                  '0',
                                  orderToPrepareList[i].Timestamp_received_ticket_time
                              );

                            }
                          });
                }),

            //######  กำลังขนส่ง
            ListView.builder(
                itemCount: orderToDispatchedList.length,
                itemBuilder: (context,i){
                  return Column(
                    children: [
                      buildTicketUpperPart(context,orderToDispatchedList[i].userId,orderToDispatchedList[i].userName,orderToDispatchedList[i].sellerId,orderToDispatchedList[i].ticket_postId,orderToDispatchedList[i].seller, 'กำลังขนส่ง', orderToDispatchedList[i].image, orderToDispatchedList[i].topic, orderToDispatchedList[i].breed, orderToDispatchedList[i].weight, orderToDispatchedList[i].type ,orderToDispatchedList[i].price, orderToDispatchedList[i].promo, orderToDispatchedList[i].quantity, orderToDispatchedList[i].deliPrice ,orderToDispatchedList[i].discount,orderToDispatchedList[i].total,orderToDispatchedList[i].delivery_method,orderToDispatchedList[i].flightNumber,orderToDispatchedList[i].airline,orderToDispatchedList[i].flightDepartureTime,orderToDispatchedList[i].flightArrivalTime),
                      buildLowerSectionOnDispatched(
                        context,
                        orderToDispatchedList[i].ticket_postId,
                        orderToDispatchedList[i].delivery_method,
                        orderToDispatchedList[i].image,
                        'กำลังขนส่ง',
                        orderToDispatchedList[i].airline,
                        orderToDispatchedList[i].flightNumber,
                        orderToDispatchedList[i].flightDepartureTime,
                        orderToDispatchedList[i].flightArrivalTime,
                        orderToDispatchedList[i].Timestamp_received_ticket_time,
                        orderToDispatchedList[i].Timestamp_dispatched_time,
                      )
                    ],
                  );
                }),

            //######  7วันการันตี
            ListView.builder(
                itemCount: orderToGuaranteeList.length,
                itemBuilder: (context,i){
                  return Column(
                    children: [
                      buildTicketUpperPart(
                          context,
                          orderToGuaranteeList[i].userId,
                          orderToGuaranteeList[i].userName,
                          orderToGuaranteeList[i].sellerId,
                          orderToGuaranteeList[i].ticket_postId,
                          orderToGuaranteeList[i].seller,
                          orderToGuaranteeList[i].status == 'กำลังตรวจสอบ'?'เกิดข้อพิพาท': orderToGuaranteeList[i].status,
                          orderToGuaranteeList[i].image,
                          orderToGuaranteeList[i].topic,
                          orderToGuaranteeList[i].breed,
                          orderToGuaranteeList[i].weight,
                          orderToGuaranteeList[i].type,
                          orderToGuaranteeList[i].price,
                          orderToGuaranteeList[i].promo,
                          orderToGuaranteeList[i].quantity,
                          orderToGuaranteeList[i].deliPrice,
                          orderToGuaranteeList[i].discount,
                          orderToGuaranteeList[i].total,
                          orderToGuaranteeList[i].delivery_method,
                          orderToGuaranteeList[i].flightNumber,
                          orderToGuaranteeList[i].airline,
                          orderToGuaranteeList[i].flightDepartureTime,
                          orderToGuaranteeList[i].flightArrivalTime
                      ),
                  buildLowerSectionOnGuarantee(
                          context,
                          orderToGuaranteeList[i].ticket_postId,
                          orderToGuaranteeList[i].delivery_method,
                          orderToGuaranteeList[i].image,
                          orderToGuaranteeList[i].status,
                          orderToGuaranteeList[i].airline,
                          orderToGuaranteeList[i].flightNumber,
                          orderToGuaranteeList[i].flightDepartureTime,
                          orderToGuaranteeList[i].flightArrivalTime,
                          orderToGuaranteeList[i].Timestamp_received_ticket_time,
                          orderToGuaranteeList[i].Timestamp_dispatched_time,
                          orderToGuaranteeList[i].Timestamp_guarantee_ticket_start_time,
                          orderToGuaranteeList[i].Timestamp_guarantee_ticket_end_time,
                      )
                    ],
                  );
                }),


            //######  รอการรีวิว
            ListView.builder(
                itemCount: orderToReviewList.length,
                itemBuilder: (context,i){
                  return orderToReviewList[i].status != 'รอการรีวิว'?SizedBox():
                  Column(
                    children: [
                      buildTicketUpperPart(
                          context,
                          orderToReviewList[i].userId,
                          orderToReviewList[i].userName,
                          orderToReviewList[i].sellerId,
                          orderToReviewList[i].ticket_postId,
                          orderToReviewList[i].seller,
                          orderToReviewList[i].status,
                          orderToReviewList[i].image,
                          orderToReviewList[i].topic,
                          orderToReviewList[i].breed,
                          orderToReviewList[i].weight,
                          orderToReviewList[i].type,
                          orderToReviewList[i].price,
                          orderToReviewList[i].promo,
                          orderToReviewList[i].quantity,
                          orderToReviewList[i].deliPrice,
                          orderToReviewList[i].discount,
                          orderToReviewList[i].total,
                          orderToReviewList[i].delivery_method,
                          orderToReviewList[i].flightNumber,
                          orderToReviewList[i].airline,
                          orderToReviewList[i].flightDepartureTime,
                          orderToReviewList[i].flightArrivalTime
                      ),
                    ],
                  );
                }
            ),


            //######  สำเร็จ
            ListView.builder(
                itemCount: orderToCompletedList.length,
                itemBuilder: (context,i){
                  return buildTicketUpperPart(
                    context,
                    orderToCompletedList[i].userId,
                    orderToCompletedList[i].userName,
                    orderToCompletedList[i].sellerId,
                    orderToCompletedList[i].ticket_postId,
                    orderToCompletedList[i].seller,
                    'สำเร็จ',
                    orderToCompletedList[i].image,
                    orderToCompletedList[i].topic,
                    orderToCompletedList[i].breed,
                    orderToCompletedList[i].weight,
                    orderToCompletedList[i].type,
                    orderToCompletedList[i].price,
                    orderToCompletedList[i].promo,
                    orderToCompletedList[i].quantity,
                    orderToCompletedList[i].deliPrice,
                    orderToCompletedList[i].discount,
                    orderToCompletedList[i].total,
                    orderToCompletedList[i].delivery_method,
                    orderToCompletedList[i].delivery_method != 'ส่งทางอากาศ (รับที่สนามบิน)'?'0':orderToCompletedList[i].flightNumber,
                    orderToCompletedList[i].delivery_method != 'ส่งทางอากาศ (รับที่สนามบิน)'?'0':orderToCompletedList[i].airline,
                    '0',
                    '0',
                  );

                }),



            //######  เคลมสินค้า
            ListView.builder(
                itemCount: orderToRefundList.length,
                itemBuilder: (context,i){
                  return buildTicketUpperPart(
                      context,
                      orderToRefundList[i].userId,
                      orderToRefundList[i].userName,
                      orderToRefundList[i].sellerId,
                      orderToRefundList[i].ticket_postId,
                      orderToRefundList[i].seller,
                      orderToRefundList[i].status,
                      orderToRefundList[i].image,
                      orderToRefundList[i].topic,
                      orderToRefundList[i].breed,
                      orderToRefundList[i].weight,
                      orderToRefundList[i].type,
                      orderToRefundList[i].price,
                      orderToRefundList[i].promo,
                      orderToRefundList[i].quantity,
                      orderToRefundList[i].deliPrice,
                      orderToRefundList[i].discount,
                      orderToRefundList[i].total,
                      orderToRefundList[i].delivery_method,
                      orderToRefundList[i].flightNumber,
                      orderToRefundList[i].airline,
                      orderToRefundList[i].delivery_method != 'ส่งทางอากาศ (รับที่สนามบิน)'?'0':orderToRefundList[i].flightDepartureTime,
                      orderToRefundList[i].delivery_method != 'ส่งทางอากาศ (รับที่สนามบิน)'?'0':orderToRefundList[i].flightArrivalTime
                  );
                }),

            //######  ยกเลิก
            ListView.builder(
                itemCount: orderToCancelList.length,
                itemBuilder: (context,i){
                  return  Column(
                    children: [
                      buildTicketUpperPart(
                          context,
                          orderToCancelList[i].userId,
                          orderToCancelList[i].userName,
                          orderToCancelList[i].sellerId,
                          orderToCancelList[i].ticket_postId,
                          orderToCancelList[i].seller,
                          orderToCancelList[i].status,
                          orderToCancelList[i].image,
                          orderToCancelList[i].topic,
                          orderToCancelList[i].breed,
                          orderToCancelList[i].weight,
                          orderToCancelList[i].type,
                          orderToCancelList[i].price,
                          orderToCancelList[i].promo,
                          orderToCancelList[i].quantity,
                          orderToCancelList[i].deliPrice,
                          orderToCancelList[i].discount,
                          orderToCancelList[i].total,
                          orderToCancelList[i].delivery_method,
                          "0",
                          "0",
                          "0",
                          "0"),
                    ],
                  );
                }
            )
          ]),
    );
  }

  refreshGuarantee()async{
    orderToGuaranteeList.clear();

    await buyerOnGuaranteeRef.where('userId',isEqualTo: widget.userId).get().then((snap){
      snap.docs.forEach((doc) {orderToGuaranteeList.add(toNotiList.fromDocument(doc));});
    });
    orderToGuaranteeList.sort((b,a)=>a.Timestamp_guarantee_ticket_start_time.compareTo(b.Timestamp_guarantee_ticket_start_time));
  }

  Padding buildLowerSectionOnDispatched(
      BuildContext context,
      String ticket_postId,
      String deliMethod,
      String imgurl,
      String status,
      String airline,
      String flightNumber,
      String departureTime,
      String arraivalTime,
      Timestamp_received_ticket_time,
      Timestamp_dispatched_time,
      ){

    final DateFormat formatter = DateFormat('dd-MMM-yyyy');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(height: 10),
            InkWell(
              child: Container(
                height: 25,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Icon(LineAwesomeIcons.box,color: themeColour)
                          ),
                          Text('รอผู้ซื้อกดรับสินค้า',style: TextStyle(color: themeColour,fontSize: isTablet?20:16))
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(Icons.arrow_forward_ios),
                    )
                  ],
                ),
              ),
              onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>
                  timeline(
                    ticket_postId: ticket_postId,
                    imgUrl: imgurl,
                    status: 'กำลังขนส่ง',
                    deliMethod: deliMethod,
                    flightNo: flightNumber,
                    airline: airline,
                    Timestamp_received_ticket_time: Timestamp_received_ticket_time,
                    Timestamp_dispatched_time: Timestamp_dispatched_time,
                  ))),
            ),
            Padding(padding: EdgeInsets.all(5),child: Divider(color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Padding buildLowerSectionOnGuarantee(
      BuildContext context,
      String ticket_postId,
      String deliMethod,
      String imgurl,
      String status,
      String airline,
      String flightNumber,
      String departureTime,
      String arraivalTime,
      Timestamp_received_ticket_time,
      Timestamp_dispatched_time,
      Timestamp_delivered_time,
      Timestamp_guarantee_ticket_end_time
      ){

    final DateFormat formatter = DateFormat('dd-MMM-yyyy');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(height: 10),
            InkWell(
              child: Container(
                height: 25,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Icon(LineAwesomeIcons.box,color: themeColour)
                          ),
                          status == 'การันตี'
                              ?Text('การันตีจะสิ้นสุดวันที่ ${formatter.format(DateTime.fromMillisecondsSinceEpoch(Timestamp_guarantee_ticket_end_time))}',style: TextStyle(color: themeColour,fontSize: isTablet?20:14))
                              :status == 'กำลังตรวจสอบ'
                              ?Text('กำลังตรวจสอบ',style: TextStyle(color: themeColour,fontSize: isTablet?20:14))
                              :Text('รอการรีวิว',style: TextStyle(color: themeColour,fontSize: isTablet?20:14))
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(Icons.arrow_forward_ios),
                    )
                  ],
                ),
              ),
              onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>
                  timeline(
                    ticket_postId: ticket_postId,
                    imgUrl: imgurl,
                    status: 'กำลังขนส่ง',
                    deliMethod: deliMethod,
                    flightNo: flightNumber,
                    airline: airline,
                    Timestamp_received_ticket_time: Timestamp_received_ticket_time,
                    Timestamp_dispatched_time: Timestamp_dispatched_time,
                    Timestamp_delivered_time: Timestamp_delivered_time,
                  ))),
            ),
            Padding(padding: EdgeInsets.all(5),child: Divider(color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Padding buildOrderPrepare(BuildContext context,
      String userId,
      String userName,
      String storeName,
      String prepareStatus,
      String imgurl,
      String topic,
      String breed,
      int price,
      int promo,
      int qty,
      int discount,
      int total,
      int date,
      int month,
      int year,
      int dueToDelivery,
      String ticket_postId,
      String postId,
      String sellerId,
      String type,
      int deliprice,
      String deliMethod,
      Timestamp Timestamp_received_ticket_time,
      String weight,
      int deliFee,
      String button,
      Function() ontap
      ) {

    var f = new NumberFormat("#,###", "en_US");
    final DateFormat formatter = DateFormat('dd-MMM-yyyy');

    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color:Colors.grey.shade300)
              ),
              color: Colors.white
          ),
          child: Column(
            children: [
              InkWell(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(FontAwesomeIcons.store,size: 20,color: Colors.black),
                                  SizedBox(width: 10),
                                  Text(storeName,style: TextStyle(fontSize: isTablet?30:20))
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                prepareStatus == 'ส่งทางอากาศ (รับที่สนามบิน)'? Padding(
                                  padding: const EdgeInsets.only(right: 10.0),
                                  child: Icon(LineAwesomeIcons.plane,color: Colors.blueAccent),
                                ):SizedBox(),
                                Text('กำลังเตรียมจัดส่ง',style: TextStyle(color: themeColour,fontSize: isTablet?20:16)),
                              ],
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              flex: isTablet?2:3,
                              child: Image.network(imgurl,height: 100)
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            flex: 8,
                            child: Container(
                              height: 100,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(topic,style: topicStyle,maxLines: 2),
                                  Row(
                                    children: [
                                      Text(breed,style: TextStyle(color: Colors.grey.shade800)),
                                      SizedBox(width: 5),
                                      type == 'pet'? SizedBox(): Text('${weight} kg',style: TextStyle(color: Colors.grey.shade800,fontSize: isTablet?20:16)),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text('฿ ${f.format(price)}',style: promo != 0
                                              ?TextStyle(decoration:TextDecoration.lineThrough,fontSize: isTablet?20:16):TextStyle(fontSize: isTablet?20:16)),
                                          Visibility(
                                            visible: promo!=0,
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 5.0),
                                              child: Text('฿ ${f.format(promo)}',style: TextStyle(color: themeColour,fontSize: isTablet?20:16)),
                                            ),
                                          )
                                        ],
                                      ),
                                      Text('จำนวน ${qty}',style: TextStyle(fontSize: isTablet?20:16))
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('ยอดรวมสินค้า :',style: TextStyle(fontSize: isTablet?20:16)),
                          Text('฿ ${f.format(total)}',style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold,color: themeColour))
                        ],
                      ),
                      SizedBox(height: 5),
                      type != 'pet' ?SizedBox():Container(
                        margin: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: themeColour
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 2),
                          child: Row(
                            children: [
                              Icon(LineAwesomeIcons.exclamation_circle,color: Colors.white),
                              SizedBox(width: 10),
                              Text('สินค้าจะพร้อมส่งภายในวันที่ ${formatter.format(DateTime.fromMillisecondsSinceEpoch(dueToDelivery))}',style: TextStyle(color: Colors.white,fontSize: isTablet?20:13))
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () async{
                    String post_ticketId;
                    final result = await Navigator.push(
                        context, MaterialPageRoute(
                        builder: (context)=>
                            orderDetailSeller(
                              sellerId: widget.userId,
                              ticket_postId: ticket_postId,
                              status: 'เตรียมจัดส่ง',
                              deliMethod: deliMethod,
                              imgUrl: imgurl,
                              storeName: storeName,
                              topic: topic,
                              brand: breed,
                              weight: weight,
                              type: type,
                              price: price,
                              promo: promo,
                              qty: qty,
                              deliFee: deliFee,
                              discount: discount,
                              total: total,
                              buyerName: userName,
                              buyerId: userId,
                            ))).then((value){
                      Future.delayed(const Duration(milliseconds: 500), () {
                        buyerOnPrepareRef.doc(ticket_postId).get().then((snapshot){
                          if(!snapshot.exists){
                            if(orderToPrepareList.length == 0){
                              orderToPrepareList.clear();
                              setState(() {
                                refreshCancel();
                              });
                            }else{
                              for(var i =0; i<orderToPrepareList.length;i++){
                                if(orderToPrepareList[i].ticket_postId == ticket_postId){
                                  setState(() {
                                    orderToPrepareList.removeAt(i);
                                    widget.itemToPrepare<=0?null:widget.itemToPrepare-=1;
                                    refreshCancel();
                                  });
                                }
                              }
                            }
                          }});
                      });
                    });

                    post_ticketId = result.toString();
                    if(result != ''){
                      for(var i = 0;i<orderToPrepareList.length;i++){
                        if(result == orderToPrepareList[i].ticket_postId){
                          orderToPrepareList.removeAt(i);
                        }
                      }
                    }
                  }),
              SizedBox(height: 5),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                    color: themeColour,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(button,style: TextStyle(color: Colors.white,fontSize: isTablet?20:16)),
                    ),
                  ),
                  onTap: ontap,
                ),
              ),

            ],
          )
      ),
    );
  }

  InkWell buildTicketUpperPart(BuildContext context,
      String buyerId,
      String buyerName,
      String sellerId,
      String ticket_postId,
      String storeName,
      String status,
      String imgurl,
      String topic,
      String brand,
      String weight,
      String type,
      int price,
      int promo,
      int qty,
      int deliFee,
      int discount,
      int total,
      String deliMethod,
      String flightNo,
      String airline,
      String departureTime,
      String arraivalTime,
      ) {

    var f = new NumberFormat("#,###", "en_US");
    return InkWell(
        child: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color:Colors.grey.shade300),
                  ),
                  color: Colors.white
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(FontAwesomeIcons.store,size: 20,color: Colors.black),
                              SizedBox(width: 15),
                              Text(storeName,style: TextStyle(fontSize: isTablet?20:16))
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            deliMethod == 'ส่งทางอากาศ (รับที่สนามบิน)' && status != 'เกิดข้อพิพาท'? Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Icon(LineAwesomeIcons.plane,color: Colors.blueAccent),
                            ):status == 'การันตี'?Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Icon(FontAwesomeIcons.shieldAlt,color: Colors.green),
                            ):status == 'เกิดข้อพิพาท'?Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Icon(FontAwesomeIcons.times,color: Colors.red.shade900),
                            )
                                :SizedBox(),
                            Text(status,style: TextStyle(color: themeColour,fontSize: isTablet?20:16)),
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: isTablet?2:3,
                          child: Image.network(imgurl,height: 100)
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        flex: 8,
                        child: Container(
                          height: 100,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(topic,style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold),maxLines: 2),
                              Row(
                                children: [
                                  Text(brand,style: TextStyle(color: Colors.grey.shade800,fontSize: isTablet?18:14)),
                                  SizedBox(width: 5),
                                  type == 'pet'?SizedBox():Text('${weight} kg', style:TextStyle(color: Colors.grey.shade800,fontSize: isTablet?18:14)),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text('฿ ${f.format(price)}',style: promo != 0
                                          ?TextStyle(decoration:TextDecoration.lineThrough,fontSize: isTablet?20:16):TextStyle(fontSize: isTablet?20:16)),
                                      Visibility(
                                        visible: promo!=0,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 5.0),
                                          child: Text('฿ ${f.format(promo)}',style: TextStyle(color: themeColour,fontSize: isTablet?20:16)),
                                        ),
                                      )
                                    ],
                                  ),
                                  Text('จำนวน ${qty}',style: TextStyle(fontSize: isTablet?20:16))
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('ยอดรวมสินค้า :',style: TextStyle(fontSize: isTablet?20:16)),
                      Text('฿ ${f.format(total)}',style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold,color: themeColour))
                    ],
                  ),
                ],
              )
          ),
        ),
        onTap: ()=>Navigator.push(
            context, MaterialPageRoute(
            builder: (context)=>
                orderDetailSeller(
                  sellerId: sellerId,
                  buyerId: buyerId,
                  buyerName: buyerName,
                  ticket_postId: ticket_postId,
                  status: status,
                  deliMethod: deliMethod,
                  imgUrl: imgurl,
                  storeName: storeName,
                  topic: topic,
                  brand: brand,
                  weight: weight,
                  type: type,
                  price: price,
                  promo: promo,
                  qty: qty,
                  deliFee: deliFee,
                  discount: discount,
                  total: total,
                  flightNo: flightNo,
                  airline: airline,
                  flightDepartureTime: departureTime,
                  flightArrivalTime: arraivalTime,
                ))).then((value)async{
          setState(() {
            isLoading = true;
          });
          if(_selectedIndex != 2){
            await buyerOnDispatchRef.doc(ticket_postId).get().then((snapshot){
              if(!snapshot.exists){
                if(orderToDispatchedList.length == 0){
                  orderToDispatchedList.clear();
                  setState(() {
                    refreshGuarantee();
                  });
                }else{
                  for(var i =0; i<orderToDispatchedList.length;i++){
                    if(orderToDispatchedList[i].ticket_postId == ticket_postId){
                      setState(() {
                        orderToDispatchedList.removeAt(i);
                        widget.itemDispatched<=0?null:widget.itemDispatched-=1;
                        refreshGuarantee();
                      });
                    }
                  }
                }
              }
            });
          }
          setState(() {
            isLoading = false;
          });
        })
    );
  }

  Padding buildUpperSection(BuildContext context,
      String storeName,
      String status,
      String imgurl,
      String topic,
      String brand,
      int price,
      int promo,
      int qty,
      int total) {

    var f = new NumberFormat("#,###", "en_US");

    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color:Colors.grey.shade300),
              ),
              color: Colors.white
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(FontAwesomeIcons.store,size: 20,color: Colors.black),
                          SizedBox(width: 10),
                          Text(storeName,style: TextStyle(fontSize: isTablet?30:20))
                        ],
                      ),
                    ),
                    Text(status,style: TextStyle(color: themeColour,fontSize: isTablet?20:16))
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      flex: isTablet?2:3,
                      child: Image.network(imgurl,height: 100)
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 8,
                    child: Container(
                      height: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(topic,style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold),maxLines: 2),
                          Text(brand,style: TextStyle(color: Colors.grey.shade800,fontSize: isTablet?18:14)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text('฿ ${f.format(price)}',style: promo != 0
                                      ?TextStyle(decoration:TextDecoration.lineThrough,fontSize: isTablet?20:16):TextStyle(fontSize: isTablet?20:16)),
                                  Visibility(
                                    visible: promo!=0,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      child: Text('฿ ${f.format(promo)}',style: TextStyle(color: themeColour,fontSize: isTablet?20:16)),
                                    ),
                                  )
                                ],
                              ),
                              Text('จำนวน ${qty}',style: TextStyle(fontSize: isTablet?20:16),)
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('ยอดรวมสินค้า :',style: TextStyle(fontSize: isTablet?20:16)),
                  Text('฿ ${f.format(total)}',style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold,color: themeColour))
                ],
              ),
            ],
          )
      ),
    );
  }
}
