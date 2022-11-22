import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:multipawmain/chat/mychat.dart';
import 'package:multipawmain/database/breedDatabase.dart';
import 'package:multipawmain/database/posts.dart';
import 'package:multipawmain/guaranteeClaim.dart';
import 'package:multipawmain/orderDetailBuyer.dart';
import 'package:multipawmain/pages/timeline.dart';
import 'package:multipawmain/ratingAndReview.dart';
import 'package:multipawmain/shop/myCart.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:intl/intl.dart';
import 'package:multipawmain/support/methods.dart';
import 'dart:io';
import '../authCheck.dart';
import 'package:sizer/sizer.dart';

import '../authScreenWithoutPet.dart';

DateTime now = DateTime.now();
bool isTablet = false;

class notification extends StatefulWidget {
  final userId;
  late int itemToPrepare,itemDispatched,itemGuarantee,itemToReview;
  notification({ required this.userId, required this.itemToPrepare,required this.itemDispatched, required this.itemGuarantee, required this.itemToReview});

  @override
  _notificationState createState() => _notificationState();
}

class _notificationState extends State<notification> with SingleTickerProviderStateMixin{
  int _selectedIndex = 0;
  late TabController controller;
  bool isRead = true;
  int item_in_cart = 0;
  bool isLoading = false;
  bool confirm = false;
  String? monthAlpha,userName,userImageUrl;
  bool haveBankAccount = false;
  List<bankAccountPaymentMethod> refundList = [];
  bool checkrefund = false;
  String? issueBank,accountName,accountNumber;
  bool fromReview = false;
  bool fromDeliver = false;

  List<toPrepareList> orderToPrepareList = [];
  List<toDispatchedList> orderToDispatchedList = [];
  List<toNotiList> orderToGuaranteeList = [];
  List<toReviewList> orderToReviewList = [];
  List<toReviewList> orderToReviewCounterList = [];
  List<toCompletedList> orderToCompletedList = [];
  List<toRefundList> orderToRefundList = [];
  List<toCancelList> orderToCancelList = [];

  refreshGuarantee()async{
    orderToGuaranteeList.clear();

    await buyerOnGuaranteeRef.where('userId',isEqualTo: widget.userId).get().then((snap){
      snap.docs.forEach((doc) {orderToGuaranteeList.add(toNotiList.fromDocument(doc));});
    });
    orderToGuaranteeList.sort((b,a)=>a.Timestamp_guarantee_ticket_start_time.compareTo(b.Timestamp_guarantee_ticket_start_time));
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

  getData()async{
    await buyerOnPrepareRef.where('userId',isEqualTo: widget.userId).get().then((snap){
      snap.docs.forEach((doc) {orderToPrepareList.add(toPrepareList.fromDocument(doc));});
    });
    orderToPrepareList.sort((b,a)=>a.Timestamp_received_ticket_time.compareTo(b.Timestamp_received_ticket_time));

    await buyerOnDispatchRef.where('userId',isEqualTo: widget.userId).get().then((snap){
      snap.docs.forEach((doc) {
        orderToDispatchedList.add(toDispatchedList.fromDocument(doc));
      });
    });
    orderToDispatchedList.sort((b,a)=>a.Timestamp_dispatched_time.compareTo(b.Timestamp_dispatched_time));

    await buyerOnGuaranteeRef.where('userId',isEqualTo: widget.userId).get().then((snap){
      snap.docs.forEach((doc) {orderToGuaranteeList.add(toNotiList.fromDocument(doc));});
    });
    orderToGuaranteeList.sort((b,a)=>a.Timestamp_guarantee_ticket_start_time.compareTo(b.Timestamp_guarantee_ticket_start_time));

    await buyerOnReviewRef.where('userId',isEqualTo: widget.userId).get().then((snap){
      snap.docs.forEach((doc) {
        orderToReviewList.add(toReviewList.fromDocument(doc));
      });

      });
    orderToReviewList.sort((b,a)=>a.Timestamp_guarantee_ticket_end_time.compareTo(b.Timestamp_guarantee_ticket_end_time));

    await buyerOnCompleteRef.where('userId',isEqualTo: widget.userId).get().then((snap){
      snap.docs.forEach((doc) {
        orderToCompletedList.add(toCompletedList.fromDocument(doc));
      });
    });
    orderToCompletedList.sort((b,a)=>a.Timestamp_completed.compareTo(b.Timestamp_completed));

    await buyerOnCancelRef.where('userId',isEqualTo: widget.userId).get().then((snap){
      snap.docs.forEach((doc) {
        orderToCancelList.add(toCancelList.fromDocument(doc));
      });
    });
    orderToCancelList.sort((b,a)=>a.cancelBySystem_time.compareTo(b.cancelBySystem_time));

    await buyerOnRefundRef.where('userId',isEqualTo: widget.userId).get().then((snap){
      snap.docs.forEach((doc) {
        orderToRefundList.add(toRefundList.fromDocument(doc));
      });
    });
    orderToRefundList.sort((b,a)=>a.Timestamp_product_claimed_approved_time.compareTo(b.Timestamp_product_claimed_approved_time));
  }

  updateGuaranteeRequest()async{
    orderToGuaranteeList.clear();

    await buyerOnGuaranteeRef.where('userId',isEqualTo: widget.userId).get().then((snap){
      snap.docs.forEach((doc) {

        orderToGuaranteeList.add(toNotiList.fromDocument(doc));
      });
    });
    orderToGuaranteeList.sort((b,a)=>a.Timestamp_guarantee_ticket_start_time.compareTo(b.Timestamp_guarantee_ticket_start_time));
  }


  getNotiCounter(){
    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() {
        isLoading = true;

        widget.itemToPrepare = orderToPrepareList.length;
        widget.itemDispatched = orderToDispatchedList.length;
        widget.itemGuarantee = orderToGuaranteeList.length;
        int toReviewCounter = orderToReviewList.length - orderToGuaranteeList.length;
        toReviewCounter>0? widget.itemToReview = toReviewCounter: widget.itemToReview = 0;

        isLoading = false;
        fromReview = false;
        fromDeliver = false;
      });
    });
  }

  checkRefundAccount()async{
    await usersRef.doc(widget.userId).collection('payment').doc(widget.userId)
        .collection('bankAccount')
        .where('refundAccount',isEqualTo: true)
        .get().then((snapshot){
      if(snapshot.size == 0){
        checkrefund = false;
      }else{
        checkrefund = true;
        snapshot.docs.forEach((doc) {
          usersRef.doc(widget.userId).collection('payment').doc(widget.userId)
              .collection('bankAccount').doc(doc.id).get().then((snaps){
                issueBank = snaps.data()!['bankName'];
                accountName = snaps.data()!['title']+' '+snaps.data()!['accountFirstName']+' '+snaps.data()!['accountLastName'];
                accountNumber = snaps.data()!['accountNumber'];
          });
        });
      }
    });
  }

  getCart()async{
    await usersRef.doc(widget.userId).collection('myCart').get().then((snap){
      item_in_cart = snap.size;
    });
  }

  getChattingNoti()async{
    await usersRef.doc(widget.userId).collection('chattingWith').where('isRead',isEqualTo: true).get().then((snapshot) => {
      if(snapshot.size>0){
        isRead = false
      }else{
        isRead = true
      }
    });
  }

  getUserName()async{
    await usersRef.doc(widget.userId).get().then((snapshot){
      userName = snapshot.data()!['name'];
      userImageUrl = snapshot.data()!['urlProfilePic'];
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
    getCart();
    getChattingNoti();
    getUserName();
    getNotiCounter();
    checkRefundAccount();


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

  OrderDispatchedToAwaitReviewFood(
      String ticket_postId,
      String peerId,
      String type,
      String deliMethod,
      String topic,
      String img,
      String seller,
      String breed,
      int price,
      int promo,
      int qty,
      int deliprice,
      int discount,
      int total,
      String postId,
      String weight,
      Timestamp Timestamp_received_ticket_time,
      Timestamp Timestamp_dispatched_time,
      )async{
    await buyerOnDispatchRef.doc(ticket_postId).get().then((snapshot){
      buyerOnReviewRef.doc(ticket_postId).set({
        'type': type,
        'seller': seller,
        'sellerId': peerId,
        'userId': widget.userId,
        'userName': snapshot.data()!['userName'],
        'topic': topic,
        'breed': breed,
        'image': img,
        'price': price,
        'weight': weight,
        'promo': promo,
        'quantity':qty,
        'deliPrice': deliprice,
        'discount': discount,
        'total': total,
        'postId': postId,
        'ticket_postId': ticket_postId,
        'delivery_method': deliMethod,
        'status': 'รอการรีวิว',
        'flightNumber': '0',
        'airline' : '0',
        'flightDepartureTime': '0',
        'flightArrivalTime': '0',
        'rp_AccountName': snapshot.data()!['rp_AccountName'],
        'rp_AccountNumber': snapshot.data()!['rp_AccountNumber'],
        'rp_BankName': snapshot.data()!['rp_BankName'],

        'Timestamp_received_ticket_time':Timestamp_received_ticket_time,
        'Timestamp_dispatched_time':Timestamp_dispatched_time,
        'Timestamp_guarantee_ticket_start_time': now,
        'Timestamp_guarantee_ticket_end_time' : now.millisecondsSinceEpoch,
      });
      buyerOnDispatchRef.doc(ticket_postId).delete();
    });
    paymentIndexRef.doc(ticket_postId).update({
      'status': 'completed'
    });
    transactionRef.doc("mulipaws" + ticket_postId).set({
      'accountName': 'บริษัท มัลติพอว์ส จำกัด',
      'accountNumber': "3573006193",
      'amount': (total*(1-0.0277)).floor(),
      'issueBank': "ไทยพาณิชย์",
      'postId': ticket_postId,
      'transactionId': "mulipaws" + ticket_postId,
      'brand': breed,
      'weight': weight,
      'type': type,
      'timestamp': now.millisecondsSinceEpoch,
      'status': false,
    });
  }

  OrderDispatchedToGuarantee(
      String userName,
      String ticket_postId,
      String peerId,
      String type,
      String deliMethod,
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
      Timestamp Timestamp_dispatched_time,
      Timestamp Timestamp_expected_dispatched_time
      )async{
    await buyerOnDispatchRef.doc(ticket_postId).get().then((snapshot){
      buyerOnGuaranteeRef.doc(ticket_postId).set({
        'type': type,
        'seller': seller,
        'sellerId': peerId,
        'userId': widget.userId,
        'userName': userName,
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
        'status': 'การันตี',
        'airline': airline,
        'flightNumber': flightNumber,
        'flightDepartureTime': departureTime,
        'flightArrivalTime': arraivalTime,
        'Timestamp_guarantee_ticket_start_time' : now,
        'Timestamp_guarantee_ticket_end_time' : now.add(Duration(days: 7)).millisecondsSinceEpoch,

        'Timestamp_received_ticket_time':Timestamp_received_ticket_time,
        'Timestamp_dispatched_time':Timestamp_dispatched_time,
        'Timestamp_expected_dispatched_time':Timestamp_expected_dispatched_time,
        'rp_BankName': snapshot.data()!['rp_BankName'],
        'rp_AccountName': snapshot.data()!['rp_AccountName'],
        'rp_AccountNumber': snapshot.data()!['rp_AccountNumber'],
        'flightDepartureTime': snapshot.data()!['flightDepartureTime'] == null?'':snapshot.data()!['flightDepartureTime'],
        'flightArrivalTime': snapshot.data()!['flightArrivalTime'] == null?'':snapshot.data()!['flightArrivalTime'],
      });
      buyerOnReviewRef.doc(ticket_postId).set({
        'type': type,
        'seller': seller,
        'sellerId': peerId,
        'userId': widget.userId,
        'userName': userName,
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
        'status': 'การันตี',
        'airline': airline,
        'flightNumber': flightNumber,
        'flightDepartureTime': departureTime,
        'flightArrivalTime': arraivalTime,
        'Timestamp_guarantee_ticket_start_time' : now,
        'Timestamp_guarantee_ticket_end_time' : now.add(Duration(days: 7)).millisecondsSinceEpoch,

        'Timestamp_received_ticket_time':Timestamp_received_ticket_time,
        'Timestamp_dispatched_time':Timestamp_dispatched_time,
        'Timestamp_expected_dispatched_time':Timestamp_expected_dispatched_time,
        'rp_BankName': snapshot.data()!['rp_BankName'],
        'rp_AccountName': snapshot.data()!['rp_AccountName'],
        'rp_AccountNumber': snapshot.data()!['rp_AccountNumber'],
        'flightDepartureTime': snapshot.data()!['flightDepartureTime'] == null?'':snapshot.data()!['flightDepartureTime'],
        'flightArrivalTime': snapshot.data()!['flightArrivalTime'] == null?'':snapshot.data()!['flightArrivalTime'],
      });
      buyerOnDispatchRef.doc(ticket_postId).delete();
    });
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

  @override
  Widget build(BuildContext context) {

    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Text('รายการสั่งซื้อ',style: TextStyle(color: Colors.black,fontSize: isTablet?22:18)),
        bottom: TabBar(
          indicatorColor: themeColour,
          labelColor: themeColour,
          unselectedLabelColor: Colors.black,
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
            Tab(
                child: Row(
                  children: [
                    Text('รอการรีวิว',style: TextStyle(fontSize: isTablet?20:15)),
                    SizedBox(width: 10),
                    widget.itemToReview == 0?SizedBox():buildContainerNotification(widget.itemToReview)
                  ],
                ),icon:Icon(FontAwesomeIcons.pencilRuler)),
            Tab(child: Text('สำเร็จ',style: TextStyle(fontSize: isTablet?20:15)),icon:Icon(FontAwesomeIcons.check)),
            Tab(child: Text('เคลมสินค้า',style: TextStyle(fontSize: isTablet?20:15)),icon:Icon(FontAwesomeIcons.undoAlt)),
            Tab(child: Text('ยกเลิกสินค้า',style: TextStyle(fontSize: isTablet?20:15)),icon:Icon(FontAwesomeIcons.ban)),
          ],
        ),
        actions: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 5.0),
                child: InkWell(
                  child: item_in_cart == 0?
                  Container(
                    height: screenHeight,
                    width: 40,
                    child: Center(
                      child: Icon(
                        LineAwesomeIcons.shopping_cart,
                        color: Colors.red.shade900,
                        size: 32,
                      ),
                    ),
                  ):Container(
                    height: screenHeight,
                    width: 40,
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            LineAwesomeIcons.shopping_cart,
                            color: Colors.red.shade900,
                            size: 32,
                          ),
                        ),
                        Positioned(
                            top: 3,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red.shade900
                              ),
                              child: Center(child: Padding(
                                padding: const EdgeInsets.only(bottom: 5.0,left: 5.0,right: 5.0,top: 8),
                                child: Text(item_in_cart.toString(),style: TextStyle(color: Colors.white,fontSize: 12,fontWeight: FontWeight.bold)),
                              )),
                            )
                        )
                      ]
                    ),
                  ),
                  onTap: ()=>
                  widget.userId == null?
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>authScreenWithoutPet(pageIndex: 3))):
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>myCart(userId: widget.userId))).then((value){
                    setState(() {
                      getNotiCounter();
                      getCart();
                    });
                  }),
                ),
              ),
              isRead == true?
              localIconbutton(LineAwesomeIcons.rocket_chat, ()=>
              widget.userId == null?
              Navigator.push(context, MaterialPageRoute(builder: (context)=>authScreenWithoutPet(pageIndex: 3))):
              Navigator.push(context, MaterialPageRoute(builder: (context)=> mychat(userId: widget.userId)))):
              Container(
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  children: [
                    Center(child: localIconbutton(LineAwesomeIcons.rocket_chat,()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> mychat(userId: widget.userId))))),
                    Positioned(
                        top: 3,right: 10,
                        child: isRead == false?
                        Container(decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: themeColour),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 6.0,left: 6.0,right: 6.0,top: 9.0),
                              child: Text('1',style: TextStyle(fontSize: 12,color: Colors.transparent,fontWeight: FontWeight.bold)),
                            )): Text(''))
                  ],
                ),
              ),
            ],
          )
        ],
      ),
      body: isLoading == true && item_in_cart != null? loading():TabBarView(
        controller: controller,
          children: <Widget>[
            //######  เตรียมจัดส่ง
            ListView.builder(
                itemCount: orderToPrepareList.length,
                itemBuilder: (context,i){
                  int index = orderToPrepareList[i].dispatchMonth>0 ? orderToPrepareList[i].dispatchMonth - 1: 0;
                  monthAlpha = monthList.elementAt(index);
                  return buildOrderPrepare(
                      context,
                      widget.userId,
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
                      orderToPrepareList[i].seller,
                      orderToPrepareList[i].delivery_method,
                      orderToPrepareList[i].Timestamp_received_ticket_time,
                      orderToPrepareList[i].weight,
                      orderToPrepareList[i].deliPrice
                  );
                }),

            //######  กำลังขนส่ง
            ListView.builder(
                itemCount: orderToDispatchedList.length,
                itemBuilder: (context,i){
                  return Column(
                    children: [
                      buildTicketUpperPart(context,orderToDispatchedList[i].sellerId,orderToDispatchedList[i].ticket_postId,orderToDispatchedList[i].postId,orderToDispatchedList[i].seller, 'กำลังขนส่ง', orderToDispatchedList[i].image, orderToDispatchedList[i].topic, orderToDispatchedList[i].breed, orderToDispatchedList[i].weight, orderToDispatchedList[i].type ,orderToDispatchedList[i].price, orderToDispatchedList[i].promo, orderToDispatchedList[i].quantity, orderToDispatchedList[i].deliPrice ,orderToDispatchedList[i].discount,orderToDispatchedList[i].total,orderToDispatchedList[i].delivery_method,orderToDispatchedList[i].flightNumber,orderToDispatchedList[i].airline,orderToDispatchedList[i].flightDepartureTime,orderToDispatchedList[i].flightArrivalTime),
                      buildTicketDispatched(context, orderToDispatchedList[i].ticket_postId, orderToDispatchedList[i].delivery_method, orderToDispatchedList[i].image, 'กำลังขนส่ง', orderToDispatchedList[i].airline, orderToDispatchedList[i].flightNumber, orderToDispatchedList[i].flightDepartureTime, orderToDispatchedList[i].flightArrivalTime,orderToDispatchedList[i].Timestamp_received_ticket_time, orderToDispatchedList[i].Timestamp_dispatched_time, '  ได้รับแล้ว  ',
                              ()async{
                                await receviedConfirmationAlertDialog(
                                    context,
                                    orderToDispatchedList[i].ticket_postId,
                                    orderToDispatchedList[i].sellerId,
                                    orderToDispatchedList[i].type,
                                    orderToDispatchedList[i].delivery_method,
                                    orderToDispatchedList[i].topic,
                                    orderToDispatchedList[i].image,
                                    orderToDispatchedList[i].seller,
                                    orderToDispatchedList[i].breed,
                                    orderToDispatchedList[i].weight,
                                    orderToDispatchedList[i].price,
                                    orderToDispatchedList[i].promo,
                                    orderToDispatchedList[i].quantity,
                                    orderToDispatchedList[i].deliPrice,
                                    orderToDispatchedList[i].discount,
                                    orderToDispatchedList[i].total,
                                    orderToDispatchedList[i].postId,
                                    orderToDispatchedList[i].airline,
                                    orderToDispatchedList[i].flightNumber,
                                    orderToDispatchedList[i].flightDepartureTime,
                                    orderToDispatchedList[i].flightArrivalTime,
                                    orderToDispatchedList[i].Timestamp_received_ticket_time,
                                    orderToDispatchedList[i].Timestamp_dispatched_time,
                                    orderToDispatchedList[i].Timestamp_expected_dispatched_time
                                );
                              }
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
                          orderToGuaranteeList[i].sellerId,
                          orderToGuaranteeList[i].ticket_postId,
                          orderToGuaranteeList[i].postId,
                          orderToGuaranteeList[i].seller,
                          orderToGuaranteeList[i].status == 'กำลังตรวจสอบ'?'เกิดข้อพิพาท': orderToGuaranteeList[i].status,
                          orderToGuaranteeList[i].image,
                          orderToGuaranteeList[i].topic,
                          orderToGuaranteeList[i].breed,
                          orderToGuaranteeList[i].weight,
                          orderToGuaranteeList[i].type ,
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
                      buildTicketGuarantee(
                          context,
                          orderToGuaranteeList[i].ticket_postId,
                          orderToGuaranteeList[i].delivery_method,
                          orderToGuaranteeList[i].image,
                          orderToGuaranteeList[i].status,
                          orderToGuaranteeList[i].airline,
                          orderToGuaranteeList[i].flightNumber,
                          orderToGuaranteeList[i].Timestamp_received_ticket_time,
                          orderToGuaranteeList[i].Timestamp_dispatched_time,
                          orderToGuaranteeList[i].Timestamp_guarantee_ticket_start_time,
                          orderToGuaranteeList[i].Timestamp_guarantee_ticket_end_time,
                          'เคลมสัตว์เลี้ยง',
                              (){
                            setState(() {
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>guaranteeClaim(
                                  userId: widget.userId,
                                  ticket_postId: orderToGuaranteeList[i].ticket_postId,
                                  storeName: orderToGuaranteeList[i].seller,
                                  imgurl: orderToGuaranteeList[i].image,
                                  brand: orderToGuaranteeList[i].breed,
                                  topic: orderToGuaranteeList[i].topic,
                                  price: orderToGuaranteeList[i].price,
                                  total: orderToGuaranteeList[i].total))).then((value){
                                Future.delayed(const Duration(milliseconds: 500), () {
                                  setState(() {
                                    updateGuaranteeRequest();
                                    getCart();
                                    getNotiCounter();
                                  });
                                });
                              });
                            });
                          }
                      )
                    ],
                  );
                }),

            //######  รอการรีวิว
            ListView.builder(
                itemCount: orderToReviewList.length,
                itemBuilder: (context,i){
                  return orderToReviewList[i].status != 'รอการรีวิว'?SizedBox():Column(
                    children: [
                      buildTicketUpperPart(
                          context,
                          orderToReviewList[i].sellerId,
                          orderToReviewList[i].ticket_postId,
                          orderToReviewList[i].postId,
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
                      buildTicketGuarantee(context,
                          orderToReviewList[i].ticket_postId,
                          orderToReviewList[i].delivery_method,
                          orderToReviewList[i].image,
                          'รอการรีวิว',
                          orderToReviewList[i].airline,
                          orderToReviewList[i].flightNumber,
                          orderToReviewList[i].Timestamp_received_ticket_time,
                          orderToReviewList[i].Timestamp_dispatched_time,
                          orderToReviewList[i].Timestamp_guarantee_ticket_start_time,
                          orderToReviewList[i].Timestamp_guarantee_ticket_end_time,
                          '  รีวิวสินค้า  '
                          ,()async{
                            final result  = await Navigator.push(context,
                                MaterialPageRoute(builder: (context)=>
                                    rateAndReview(
                                        imgUrl: orderToReviewList[i].image,
                                        topic: orderToReviewList[i].topic,
                                        breed: orderToReviewList[i].breed,
                                        sellerId: orderToReviewList[i].sellerId,
                                        userId: widget.userId,
                                        userName: userName,
                                        buyerImageUrl: userImageUrl,
                                        ticket_postId: orderToReviewList[i].ticket_postId,
                                        type: orderToReviewList[i].type,
                                        weight: orderToReviewList[i].weight
                                    ))).then((value)async{

                              await buyerOnReviewRef.doc(orderToReviewList[i].ticket_postId).get().then((snap)async{
                                if(!snap.exists){
                                  orderToReviewList.clear();
                                  orderToCompletedList.clear();
                                  fromReview = true;

                                  await buyerOnReviewRef.where('userId',isEqualTo: widget.userId).get().then((snap){
                                    snap.docs.forEach((doc) {orderToReviewList.add(toReviewList.fromDocument(doc));});
                                  });
                                  orderToReviewList.sort((b,a)=>a.Timestamp_guarantee_ticket_end_time.compareTo(b.Timestamp_guarantee_ticket_end_time));

                                  await buyerOnCompleteRef.where('userId',isEqualTo: widget.userId).get().then((snap){
                                    snap.docs.forEach((doc) {
                                      orderToCompletedList.add(toCompletedList.fromDocument(doc));
                                    });
                                  });
                                  orderToCompletedList.sort((b,a)=>a.Timestamp_completed.compareTo(b.Timestamp_completed));
                                  getNotiCounter();
                                }
                              });
                            });
                            if(result == true){
                              controller.index = 4;
                            }
                          })
                    ],
                  );
                }
            ),

            //######  สำเร็จ
            ListView.builder(
                itemCount: orderToCompletedList.length,
                itemBuilder: (context,i){
                  return  buildTicketUpperPart(
                      context,
                      orderToCompletedList[i].sellerId,
                      orderToCompletedList[i].ticket_postId,
                      orderToCompletedList[i].postId,
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
                      orderToRefundList[i].sellerId,
                      orderToRefundList[i].ticket_postId,
                      orderToRefundList[i].postId,
                      orderToRefundList[i].seller,
                      'เคลมสินค้า',
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
                  return Column(
                    children: [
                      buildTicketUpperPart(
                          context,
                          orderToCancelList[i].sellerId,
                          orderToCancelList[i].ticket_postId,
                          orderToCancelList[i].postId,
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
                      buildTicketOnCancel(
                          context,
                          orderToCancelList[i].ticket_postId,
                          orderToCancelList[i].delivery_method,
                          orderToCancelList[i].image,
                          orderToCancelList[i].status,
                          orderToCancelList[i].Timestamp_received_ticket_time,
                          DateTime.fromMillisecondsSinceEpoch(orderToCancelList[i].cancelBySystem_time),
                          orderToCancelList[i].reason
                      )
                    ],
                  );
                }
                )
          ]),
    );
  }

  Container buildContainerNotification(int num) {
    return Container(
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: themeColour
      ),
      child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(num >99?'99+':num.toString(),
              style: TextStyle(color: Colors.white)
          )
      ),
    );
  }

  Padding buildOrderPrepare(BuildContext context,
      String userId,
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
      String seller,
      String deliMethod,
      Timestamp Timestamp_received_ticket_time,
      String weight,
      int deliFee,
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
                            child: Image.network(imgurl,height: isTablet?200:100)
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
                                    Text(breed,style: TextStyle(color: Colors.grey.shade800,fontSize: isTablet?20:16)),
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
                                    Padding(
                                      padding: EdgeInsets.only(right: isTablet?10:0),
                                      child: Text('จำนวน ${qty}',style: TextStyle(fontSize: isTablet?20:16)),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 15),
                    Padding(
                      padding: EdgeInsets.only(left: isTablet?10:0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('ยอดรวมสินค้า :',style: TextStyle(fontSize: isTablet?20:16)),
                          Text('฿ ${f.format(total)}',style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold,color: themeColour))
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    type != 'pet' ?SizedBox():Container(
                      margin: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: themeColour
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: isTablet?10:2),
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
                  final result = await Navigator.push(
                  context, MaterialPageRoute(
                  builder: (context)=>
                       orderDetailBuyer(
                        sellerId: sellerId,
                        accountNumber: accountNumber!,
                        accountName: accountName!,
                        issueBank: issueBank!,
                        userName: userName.toString(),
                        userId: userId,
                        ticket_postId: ticket_postId,
                        postId: postId,
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
                      )));
                  if(result == true){
                    Future.delayed(const Duration(milliseconds: 500), () {
                      buyerOnPrepareRef.doc(ticket_postId).get().then((snapshot){
                        if(!snapshot.exists){
                          if(orderToPrepareList.length == 0){
                            orderToDispatchedList.clear();
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
                  }
                }),
            ],
          )
      ),
    );
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
                          deliMethod == 'ส่งทางอากาศ (รับที่สนามบิน)'
                              ?Text('ผู้ขายจัดส่งข้อมูลเที่ยวบินมาแล้ว',style: TextStyle(color: themeColour,fontSize: isTablet?20:16))
                              :deliMethod == 'รับเองที่ฟาร์ม'
                              ? Text('กรุณากดยอมรับเมื่อได้รับน้องจากฟาร์ม',style: TextStyle(color: themeColour,fontSize: isTablet?20:16))
                              :Text('สินค้ากำลังถูกจัดส่ง',style: TextStyle(color: themeColour,fontSize: isTablet?20:16))
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
                    child: Text(button,style: TextStyle(color: Colors.white,fontSize: isTablet?20:16)),
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

  OrderDispatchedToReviewFreePet(
      String userName,
      String ticket_postId,
      String peerId,
      String type,
      String deliMethod,
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
      Timestamp Timestamp_dispatched_time,
      Timestamp Timestamp_expected_dispatched_time
      )async{
    await buyerOnDispatchRef.doc(ticket_postId).get().then((snapshot){
      buyerOnReviewRef.doc(ticket_postId).set({
        'type': type,
        'seller': seller,
        'sellerId': peerId,
        'userId': widget.userId,
        'userName': userName,
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
        'status': 'รอการรีวิว',
        'airline': airline,
        'flightNumber': flightNumber,
        'flightDepartureTime': departureTime,
        'flightArrivalTime': arraivalTime,
        'Timestamp_guarantee_ticket_start_time' : now,
        'Timestamp_guarantee_ticket_end_time' : now.add(Duration(days: 7)).millisecondsSinceEpoch,

        'Timestamp_received_ticket_time':Timestamp_received_ticket_time,
        'Timestamp_dispatched_time':Timestamp_dispatched_time,
        'Timestamp_expected_dispatched_time':Timestamp_expected_dispatched_time,
        'rp_BankName': snapshot.data()!['rp_BankName'],
        'rp_AccountName': snapshot.data()!['rp_AccountName'],
        'rp_AccountNumber': snapshot.data()!['rp_AccountNumber'],
      });
      buyerOnDispatchRef.doc(ticket_postId).delete();
      paymentIndexRef.doc(ticket_postId).update({
        'status': 'completed'
      });
    });
  }

  Padding buildTicketGuarantee(
      BuildContext context,
      String ticket_postId,
      String deliMethod,
      String imgurl,
      String status,
      String airline,
      String flightNumber,
      Timestamp_received_ticket_time,
      Timestamp_dispatched_time,
      Timestamp_delivered_time,
      Timestamp_guarantee_ticket_end_time,
      String button,
      Function() ontap
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
                              ?Text('การันตีจะสิ้นสุดวันที่ ${formatter.format(DateTime.fromMillisecondsSinceEpoch(Timestamp_guarantee_ticket_end_time))}',style: TextStyle(color: themeColour,fontSize: isTablet?20:14)):
                          status == 'กำลังตรวจสอบ'
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
                    status: status,
                    deliMethod: deliMethod,
                    flightNo: flightNumber,
                    airline: airline,
                    Timestamp_received_ticket_time: Timestamp_received_ticket_time,
                    Timestamp_dispatched_time: Timestamp_dispatched_time,
                    Timestamp_delivered_time: Timestamp_delivered_time,
                  ))),
            ),
            Padding(padding: EdgeInsets.all(5),child: Divider(color: Colors.grey.shade500)),
            status == 'กำลังตรวจสอบ'?SizedBox():Align(
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
        ),
      ),
    );
  }

  Padding buildTicketOnCancel(
      BuildContext context,
      String ticket_postId,
      String deliMethod,
      String imgurl,
      String status,
      Timestamp_received_ticket_time,
      cancelBySystem_time,
      String reason
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
                          Text(reason,style: TextStyle(color: themeColour,fontSize: isTablet?20:16),maxLines: 3)
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
                    status: 'ยกเลิก',
                    deliMethod: deliMethod,
                    Timestamp_received_ticket_time: Timestamp_received_ticket_time,
                    Timestamp_onCancel_time: cancelBySystem_time,
                    reason: reason,
                  ))),
            ),
            Padding(padding: EdgeInsets.all(5),child: Divider(color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  InkWell buildTicketUpperPart(BuildContext context,
      String sellerId,
      String ticket_postId,
      String postId,
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
                        child: Image.network(imgurl,height: isTablet?200:100)
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
                                Text(brand,style: TextStyle(color: Colors.grey.shade800,fontSize: isTablet?20:16)),
                                SizedBox(width: 5),
                                type == 'pet'?SizedBox():Text('${weight} kg', style:TextStyle(color: Colors.grey.shade800,fontSize: isTablet?20:16)),
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
                                Padding(
                                  padding: EdgeInsets.only(right: isTablet?10:0),
                                  child: Text('จำนวน ${qty}',style: TextStyle(fontSize: isTablet?20:16)),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 15),
                Padding(
                  padding: EdgeInsets.only(right: isTablet?10:0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('ยอดรวมสินค้า :',style: TextStyle(fontSize: isTablet?20:16)),
                      Text('฿ ${f.format(total)}',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: themeColour))
                    ],
                  ),
                ),
              ],
            )
        ),
      ),
      onTap: ()=> Navigator.push(
          context, MaterialPageRoute(
          builder: (context)=>
              orderDetailBuyer(
                sellerId: sellerId,
                accountNumber: accountNumber.toString(),
                accountName: accountName.toString(),
                issueBank: issueBank.toString(),
                userName: userName.toString(),
                userId: widget.userId,
                ticket_postId: ticket_postId,
                postId: postId,
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

  Future<dynamic> receviedConfirmationAlertDialog(
      BuildContext context,
      String ticket_postId,
      String sellerId,
      String type,
      String deliMethod,
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
      Timestamp Timestamp_dispatched_time,
      Timestamp Timestamp_expected_dispatched_time
      ) {
    return showDialog(
        context: context,
        builder: (BuildContext context) =>
        Platform.isIOS ?
        CupertinoAlertDialog(
          content: type == 'pet' && price>0
              ?Text('หากกดยืนยันรับสินค้าแล้ว การรับประกันจะเริ่มต้นขึ้นและสิ้นสุดใน 7 วันให้หลัง',style: TextStyle(fontSize: isTablet?20:16))
              :type == 'pet' && price == 0? Text('ได้รับน้องแล้วใช่หรือไม่ ?',style: TextStyle(fontSize: isTablet?20:16))
              :Text('หากกดยืนยันรับสินค้าแล้ว จะไม่สามารถคืนหรือเปลี่ยนสินค้าได้หากเจอปัญหาภายหลัง',style: TextStyle(fontSize: isTablet?20:16)),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('ยืนยัน',style: TextStyle(color: themeColour,fontSize: isTablet?20:16),),
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });
                if(type == 'pet'){
                    price > 0 ?await OrderDispatchedToGuarantee(
                    userName.toString(),
                    ticket_postId,
                    sellerId,
                    type,
                    deliMethod,
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
                    Timestamp_dispatched_time,
                    Timestamp_expected_dispatched_time
                    ):await OrderDispatchedToReviewFreePet(
                        userName.toString(),
                        ticket_postId,
                        sellerId,
                        type,
                        deliMethod,
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
                        Timestamp_dispatched_time,
                        Timestamp_expected_dispatched_time
                    );
                }else{
                  await OrderDispatchedToAwaitReviewFood(
                      ticket_postId,
                      sellerId,
                      type,
                      deliMethod,
                      topic,
                      img,
                      seller,
                      breed,
                      price,
                      promo,
                      qty,
                      deliprice,
                      discount,
                      total,
                      postId,
                      weight,
                      Timestamp_received_ticket_time,
                      Timestamp_dispatched_time);
                }
                setState(() {
                  fromDeliver = true;
                  type == 'pet'
                      ?_selectedIndex = 2:_selectedIndex = 3;
                });


                orderToDispatchedList.clear();
                orderToGuaranteeList.clear();
                orderToReviewList.clear();

                await buyerOnDispatchRef.where('userId',isEqualTo: widget.userId).get().then((snap){
                  snap.docs.forEach((doc) {orderToDispatchedList.add(toDispatchedList.fromDocument(doc));});
                });
                orderToDispatchedList.sort((b,a)=>a.Timestamp_dispatched_time.compareTo(b.Timestamp_dispatched_time));

                await buyerOnGuaranteeRef.where('userId',isEqualTo: widget.userId).get().then((snap){
                  snap.docs.forEach((doc) {orderToGuaranteeList.add(toNotiList.fromDocument(doc));});
                });
                orderToGuaranteeList.sort((b,a)=>a.Timestamp_guarantee_ticket_start_time.compareTo(b.Timestamp_guarantee_ticket_start_time));

                await buyerOnReviewRef.where('userId',isEqualTo: widget.userId).get().then((snap){
                  snap.docs.forEach((doc) {orderToReviewList.add(toReviewList.fromDocument(doc));});
                });
                orderToReviewList.sort((b,a)=>a.Timestamp_guarantee_ticket_end_time.compareTo(b.Timestamp_guarantee_ticket_end_time));

                Future.delayed(const Duration(milliseconds: 1000), () {
                  setState(() {
                    getNotiCounter();
                    isLoading = false;
                  });
                });
                Navigator.pop(context);
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
                child: type == 'pet' && price>0
                    ?Text('หากกดยืนยันรับสินค้าแล้ว การรับประกันจะเริ่มต้นขึ้นและสิ้นสุดใน 7 วันให้หลัง',style: TextStyle(color: Colors.black,fontSize: isTablet?20:16))
                    :type == 'pet' && price == 0? Text('ได้รับน้องแล้วใช่หรือไม่ ?',style: TextStyle(color: Colors.black,fontSize: isTablet?20:16))
                    :Text('หากกดยืนยันรับสินค้าแล้ว จะไม่สามารถคืนหรือเปลี่ยนสินค้าได้หากเจอปัญหาภายหลัง',style: TextStyle(color: Colors.black,fontSize: isTablet?20:16)),
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
                        type == 'pet'
                            ?await OrderDispatchedToGuarantee(
                            userName.toString(),
                            ticket_postId,
                            sellerId,
                            type,
                            deliMethod,
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
                            Timestamp_dispatched_time,
                            Timestamp_expected_dispatched_time
                        ) :OrderDispatchedToAwaitReviewFood(
                            ticket_postId,
                            sellerId,
                            type,
                            deliMethod,
                            topic,
                            img,
                            seller,
                            breed,
                            price,
                            promo,
                            qty,
                            deliprice,
                            discount,
                            total,
                            postId,
                            weight,
                            Timestamp_received_ticket_time,
                            Timestamp_dispatched_time
                        );
                        setState(() {
                          fromDeliver = true;
                          type == 'pet'
                              ?_selectedIndex = 2:_selectedIndex = 3;
                        });


                        orderToDispatchedList.clear();
                        orderToGuaranteeList.clear();
                        orderToReviewList.clear();

                        await buyerOnDispatchRef.where('userId',isEqualTo: widget.userId).get().then((snap){
                          snap.docs.forEach((doc) {orderToDispatchedList.add(toDispatchedList.fromDocument(doc));});
                        });
                        orderToDispatchedList.sort((b,a)=>a.Timestamp_dispatched_time.compareTo(b.Timestamp_dispatched_time));

                        await buyerOnGuaranteeRef.where('userId',isEqualTo: widget.userId).get().then((snap){
                          snap.docs.forEach((doc) {orderToGuaranteeList.add(toNotiList.fromDocument(doc));});
                        });
                        orderToGuaranteeList.sort((b,a)=>a.Timestamp_guarantee_ticket_start_time.compareTo(b.Timestamp_guarantee_ticket_start_time));

                        await buyerOnReviewRef.where('userId',isEqualTo: widget.userId).get().then((snap){
                          snap.docs.forEach((doc) {orderToReviewList.add(toReviewList.fromDocument(doc));});
                        });
                        orderToReviewList.sort((b,a)=>a.Timestamp_guarantee_ticket_end_time.compareTo(b.Timestamp_guarantee_ticket_end_time));

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



  TextStyle buildBoldText() => TextStyle(fontWeight: FontWeight.bold,color: Colors.grey,fontSize: isTablet?20:16);
  TextStyle buildBoldWithThemeColourText() => TextStyle(fontWeight: FontWeight.bold,color: themeColour,fontSize: isTablet?20:16);
}

