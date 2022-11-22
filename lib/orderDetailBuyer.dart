import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multipawmain/authCheck.dart';
import 'package:multipawmain/chat/chatroom.dart';
import 'package:multipawmain/ratingAndReview.dart';
import 'package:multipawmain/setting/baseSetting.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:multipawmain/support/showNetworkImage.dart';
import 'dart:io';
import 'package:sizer/sizer.dart';
import 'guaranteeClaim.dart';

DateTime now = DateTime.now();
var cutoff = DateTime(now.year,now.month,now.day);
int? date,month,year;
var petDueToDelivery;

class orderDetailBuyer extends StatefulWidget {
  final String userId,userName,ticket_postId,status,deliMethod,imgUrl,storeName,topic,brand,weight,type,issueBank,accountName,accountNumber,sellerId,postId;
  final int price,promo,qty, deliFee,discount,total;
  final reason;
  final flightNo,airline,flightDepartureTime,flightArrivalTime;

  orderDetailBuyer({
    required this.userId,
    required this.userName,
    required this.ticket_postId,
    required this.status,
    required this.deliMethod,
    required this.imgUrl,
    required this.storeName,
    required this.topic,
    required this.brand,
    required this.weight,
    required this.type,
    required this.price,
    required this.promo,
    required this.qty,
    required this.deliFee,
    required this.discount,
    required this.total,
    required this.accountNumber,
    required this.issueBank,
    required this.accountName,
    required this.sellerId,
    required this.postId,

    this.airline,
    this.flightNo,
    this.reason,
    this.flightDepartureTime,
    this.flightArrivalTime
  });

  @override
  _orderDetailBuyerState createState() => _orderDetailBuyerState();
}

class _orderDetailBuyerState extends State<orderDetailBuyer> {

  String? name,houseNo,moo,road,subdistrict,district,city,postCode,phoneNumber,paymentType,airport,pet_postId;
  String? sellerName,sellerHouseNo,sellerMoo,sellerRoad,sellerSubdistrict,sellerDistrict,sellerCity,sellerPostCode,sellerPhoneNumber,symptom,vetCertificate,evident01,evident02,issueBank, accountName, accountNumber,buyer;
  String? sellerImageUrl;
  bool isLoading = false;
  bool isTablet = false;
  Timestamp? Timestamp_received_ticket_time,
      Timestamp_dispatched_time,
      Timestamp_delivered_time,
      Timestamp_guarantee_ticket_end_time,
      Timestamp_onComplete_time,
      Timestamp_onCancel_time,
      TimeStamp_expected_dispatched;
  String? seller,sellerId,postId,userImageUrl;
  int? Timestamp_received_added_two_Hour_ticket_time;

  getUserImageUrl()async{
    await usersRef.doc(widget.userId).get().then((snapshot){
      userImageUrl = snapshot.data()!['urlProfilePic'];
      buyer = snapshot.data()!['name'];
    });
    await usersRef.doc(widget.sellerId).get().then((snapshot){
      sellerImageUrl = snapshot.data()!['urlProfilePic'];
      seller = snapshot.data()!['name'];
    });
    await paymentIndexRef.doc(widget.ticket_postId).get().then((snapshot){
      pet_postId = snapshot.data()!['pet_postId'];
    });
  }

  getEvidence()async{
    await buyerOnGuaranteeRef.doc(widget.ticket_postId).get().then((snapshot) {
      symptom = snapshot.data()!['symptom'];
      vetCertificate = snapshot.data()!['vetCertificate'];
      evident01 = snapshot.data()!['evident01'];
      evident02 = snapshot.data()!['evident02'];
    });
  }

  getEvidenceOnRefund()async{
    await buyerOnRefundRef.doc(widget.ticket_postId).get().then((snapshot) {
      symptom = snapshot.data()!['symptom'];
      vetCertificate = snapshot.data()!['vetCertificate'];
      evident01 = snapshot.data()!['evident01'];
      evident02 = snapshot.data()!['evident02'];
    });
  }


  getDeliveryAddress()async{
    await paymentIndexRef.doc(widget.ticket_postId).get().then((snapshot){
      if(snapshot.exists){
        name = snapshot.data()!['toAddress_name'];
        houseNo = snapshot.data()!['toAddress_houseNo'];
        moo = snapshot.data()!['toAddress_moo'];
        road = snapshot.data()!['toAddress_road'];
        subdistrict = snapshot.data()!['toAddress_subdistrict'];
        district = snapshot.data()!['toAddress_district'];
        city = snapshot.data()!['toAddress_city'];
        postCode = snapshot.data()!['toAddress_postCode'];
        phoneNumber = snapshot.data()!['toAddress_phoneNo'];
        paymentType = snapshot.data()!['paymentType'];
        airport = snapshot.data()!['toAirport'];
      }
    });
  }

  getSellerAddress()async{
    await usersRef.doc(widget.sellerId).collection('storeLocationAndDeliveryOption').doc(widget.sellerId).get().then((snapshot){
      if(snapshot.exists){
        sellerName = snapshot.data()!['name'];
        sellerHouseNo = snapshot.data()!['houseNo'];
        sellerMoo = snapshot.data()!['moo'];
        sellerRoad = snapshot.data()!['road'];
        sellerSubdistrict = snapshot.data()!['subdistrict'];
        sellerDistrict = snapshot.data()!['district'];
        sellerCity = snapshot.data()!['city'];
        sellerPostCode = snapshot.data()!['postCode'];
        sellerPhoneNumber = snapshot.data()!['phoneNo'];
      }
    });
  }

  getBuyerOnPrep()async{
    await buyerOnPrepareRef.doc(widget.ticket_postId).get().then((snapshot){
      date = snapshot.data()!['dispatchDate'];
      month = snapshot.data()!['dispatchMonth'];
      year = snapshot.data()!['dispatchYear'];
      seller = snapshot.data()!['seller'];
      sellerId = snapshot.data()!['sellerId'];
      postId = snapshot.data()!['postId'];
    });
    setState(() {
      isLoading = false;
    });
  }

  getBuyerOnDispatch()async{
    await buyerOnDispatchRef.doc(widget.ticket_postId).get().then((snapshot){
      seller = snapshot.data()!['seller'];
      sellerId = snapshot.data()!['sellerId'];
      postId = snapshot.data()!['postId'];
      TimeStamp_expected_dispatched = snapshot.data()!['Timestamp_expected_dispatched_time'];
    });
    setState(() {
      isLoading = false;
    });
  }

  getTimeLine()async{
    if(widget.status == 'เตรียมจัดส่ง'){
      await buyerOnPrepareRef.doc(widget.ticket_postId).get().then((snapshot) {
        Timestamp_received_ticket_time = snapshot.data()!['Timestamp_received_ticket_time'];
        Timestamp_received_added_two_Hour_ticket_time = snapshot.data()!['Timestamp_received_ticket_time']!.toDate().add(Duration(hours: 2)).millisecondsSinceEpoch;
      });
    }else if(widget.status == 'กำลังขนส่ง'){
      await buyerOnDispatchRef.doc(widget.ticket_postId).get().then((snapshot) {
        Timestamp_received_ticket_time = snapshot.data()!['Timestamp_received_ticket_time'];
        Timestamp_dispatched_time = snapshot.data()!['Timestamp_dispatched_time'];
      });
    }else if(widget.status == 'การันตี' || widget.status == 'กำลังตรวจสอบ'){
      await buyerOnGuaranteeRef.doc(widget.ticket_postId).get().then((snapshot) {
        Timestamp_received_ticket_time = snapshot.data()!['Timestamp_received_ticket_time'];
        Timestamp_dispatched_time = snapshot.data()!['Timestamp_dispatched_time'];
        Timestamp_delivered_time = snapshot.data()!['Timestamp_guarantee_ticket_start_time'];
      });
    }else if(widget.status == 'รอการรีวิว' ){
      await buyerOnReviewRef.doc(widget.ticket_postId).get().then((snapshot) {
        Timestamp_received_ticket_time = snapshot.data()!['Timestamp_received_ticket_time'];
        Timestamp_dispatched_time = snapshot.data()!['Timestamp_dispatched_time'];
        Timestamp_delivered_time = snapshot.data()!['Timestamp_guarantee_ticket_start_time'];
        Timestamp_guarantee_ticket_end_time = widget.type == 'pet'?snapshot.data()!['Timestamp_received_ticket_time']: snapshot.data()!['Timestamp_guarantee_ticket_start_time'];
      });
    }else if(widget.status == 'ยกเลิก'){
      await buyerOnCancelRef.doc(widget.ticket_postId).get().then((snapshot) {
        Timestamp_received_ticket_time = snapshot.data()!['Timestamp_received_ticket_time'];
        Timestamp_onCancel_time = Timestamp.fromDate(DateTime.fromMillisecondsSinceEpoch(snapshot.data()!['cancelBySystem_time']));
      });
    }else if(widget.status == 'สำเร็จ'){
      await buyerOnCompleteRef.doc(widget.ticket_postId).get().then((snapshot) {
        Timestamp_onComplete_time = snapshot.data()!['Timestamp_completed'];
        Timestamp_received_ticket_time = snapshot.data()!['Timestamp_received_ticket_time'];
        Timestamp_dispatched_time = snapshot.data()!['Timestamp_dispatched_time'];
        Timestamp_delivered_time = snapshot.data()!['Timestamp_guarantee_ticket_start_time'];
      });
    }
  }

  exitLoading(){
    setState(() {
      isLoading = false;
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

    getUserImageUrl();
    getDeliveryAddress();
    widget.deliMethod == 'รับเองที่ฟาร์ม'?getSellerAddress():null;
    getTimeLine();
    widget.status == 'เตรียมจัดส่ง'
        ?getBuyerOnPrep()
        :widget.status == 'กำลังขนส่ง'
        ?getBuyerOnDispatch()
        :widget.status == 'เกิดข้อพิพาท'
        ?getEvidence()
        :widget.status == 'เคลมสินค้า'
        ?getEvidenceOnRefund()
        :null;

    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        if(widget.type == 'pet' && widget.status == 'เตรียมจัดส่ง'){
          String day_string = date!<10?'0${date.toString()}':date.toString();
          String month_string = month!<10?'0${month.toString()}':month.toString();
          petDueToDelivery = DateTime.parse('${year.toString()}-${month_string}-${day_string}');
        }

        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final snackBar = SnackBar(content: Text('Copy to clipboard',style: TextStyle(fontSize: isTablet?20:16)),
        backgroundColor: themeColour,
        duration: Duration(seconds: 1),
        action: SnackBarAction(
          label: '',
          onPressed: (){
            Navigator.pop(context);
          },
        ));
    var f = new NumberFormat("#,###", "en_US");
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: appBarWithBackArrow('ข้อมูลคำสั่งซื้อ',isTablet),
      body: isLoading == true?loading():ListView(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.only(bottom: 30,top: 10,left: 20,right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.status,style: TextStyle(fontSize: isTablet?22:18,fontWeight: FontWeight.bold,color: themeColour)),
                  Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: paymentType == 'creditCard'
                        ?Row(
                          children: [
                            Text('ชำระเงินโดย บัตรเครดิต/เดบิต',style: TextStyle(color: Colors.grey.shade800,fontSize: isTablet?20:16)),
                          ],
                        )
                        :Text('ชำระเงินโดย การโอนเงิน',style: TextStyle(color: Colors.grey.shade800,fontSize: isTablet?20:16))
                  )
                ],
              ),
            ),
          ),
          widget.status == 'เกิดข้อพิพาท' || widget.status == 'เคลมสินค้า'?SizedBox(height: 10):SizedBox(),
          widget.status == 'เกิดข้อพิพาท' || widget.status == 'เคลมสินค้า'?Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.only(bottom: 30,top: 10,left: 20,right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(FontAwesomeIcons.balanceScale,color: themeColour),
                      SizedBox(width: 15),
                      Text('เหตุผลการเคลม',style: TextStyle(fontSize: isTablet?22:18,fontWeight: FontWeight.bold)),
                    ],
                  ),
                  symptom == ''? SizedBox():Padding(padding: EdgeInsets.symmetric(vertical: 10),child: Divider(color: themeColour),),
                  symptom == ''? SizedBox(): Text('เหตุผล/อาการ',style: TextStyle(fontWeight: FontWeight.bold,fontSize: isTablet?20:16)),
                  symptom == ''? SizedBox():Padding(
                      padding: EdgeInsets.only(top: 5,left: 20),
                      child: Text(symptom.toString(),style: TextStyle(fontSize: isTablet?20:16), maxLines: 10)
                  ),
                  SizedBox(height: 10),
                  symptom == ''? SizedBox(): Text('หลักฐาน',style: TextStyle(fontWeight: FontWeight.bold,fontSize: isTablet?20:16)),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildEvidence(context,vetCertificate.toString()),
                        evident01 == 'guaranteeClaimed01'? SizedBox()
                            : buildEvidence(context,evident01.toString()),
                        evident02 == 'guaranteeClaimed02'? SizedBox()
                            : buildEvidence(context,evident02.toString()),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ):SizedBox(),
          SizedBox(height: 10),
          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.only(bottom: 20,top: 10,left: 20,right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Container(
                          child: Row(
                            children: [
                              Icon(FontAwesomeIcons.truck,color: themeColour),
                              SizedBox(width: 15),
                              Text('ข้อมูลการจัดส่ง',style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(widget.deliMethod,style: TextStyle(fontWeight: FontWeight.bold,fontSize: isTablet?20:16,color: themeColour),maxLines: 3),
                      ),
                      widget.deliMethod == 'ส่งทางอากาศ (รับที่สนามบิน)' && widget.status != 'เตรียมจัดส่ง' && widget.status != 'ยกเลิก'
                          ? Padding(
                        padding: const EdgeInsets.only(left: 20.0,top: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('สายการบิน : ${widget.airline}',style: addressTextStyle(),maxLines: 3),
                            SizedBox(height: 3),
                            Text('เที่ยวบิน : ${widget.flightNo}',style: addressTextStyle(),maxLines: 3),
                            SizedBox(height: 3),
                            Text('เวลาเครื่องออก : ${widget.flightDepartureTime}',style: addressTextStyle(),maxLines: 3),
                            SizedBox(height: 3),
                            Text('เวลาเครื่องถึง : ${widget.flightArrivalTime}',style: addressTextStyle(),maxLines: 3)
                          ],
                        ),
                      ):SizedBox()
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Divider(color: themeColour),
                  ),
                  InkWell(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child: Row(
                                  children: [
                                    Icon(FontAwesomeIcons.mapMarkerAlt,color: themeColour),
                                    SizedBox(width: 15),
                                    widget.deliMethod == 'รับเองที่ฟาร์ม'
                                        ?Text('ที่อยู่ของผู้ขาย',style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold))
                                        :Text('ที่อยู่สำหรับจัดส่ง',style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        moo == '' && widget.deliMethod == 'Standard Delivery'?
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0,top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(name.toString(),style: addressTextStyle(),maxLines: 3),
                                  SizedBox(width: 10),
                                  Text(phoneNumber.toString(),style: addressTextStyle(),maxLines: 3),
                                ],
                              ),
                              SizedBox(height: 10),
                              Text('${houseNo} ถ.${road} ต.${subdistrict} อ.${district} จ.${city} ${postCode}',style: addressTextStyle(),maxLines: 3),
                            ],
                          ),
                        ) :
                        road == '' && widget.deliMethod == 'Standard Delivery'?
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0,top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(name.toString(),style: addressTextStyle(),maxLines: 3),
                                  SizedBox(width: 10),
                                  Text(phoneNumber.toString(),style: addressTextStyle(),maxLines: 3),
                                ],
                              ),
                              SizedBox(height: 10),
                              Text('${houseNo} ม.${moo} ต.${subdistrict} อ.${district} จ.${city} ${postCode}',style: addressTextStyle(),maxLines: 3),
                            ],
                          ),
                        ):
                        moo == '' && road == '' && widget.deliMethod == 'Standard Delivery'?
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0,top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(name.toString(),style: addressTextStyle(),maxLines: 3),
                                  SizedBox(width: 10),
                                  Text(phoneNumber.toString(),style: addressTextStyle(),maxLines: 3),
                                ],
                              ),
                              SizedBox(height: 10),
                              Text('${houseNo} ต.${subdistrict} อ.${district} จ.${city} ${postCode}',style: addressTextStyle(),maxLines: 3),
                            ],
                          ),
                        ): widget.deliMethod == 'Standard Delivery'?
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0,top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(name.toString(),style: addressTextStyle(),maxLines: 3),
                                  SizedBox(width: 10),
                                  Text(phoneNumber.toString(),style: addressTextStyle(),maxLines: 3),
                                ],
                              ),
                              SizedBox(height: 10),
                              Text('${houseNo} ม.${moo} ถ.${road} ต.${subdistrict} อ.${district} จ.${city} ${postCode}',style: addressTextStyle(),maxLines: 3),
                            ],
                          ),
                        ):

                        sellerRoad == '' && widget.deliMethod == 'รับเองที่ฟาร์ม'?
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0,top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(sellerName.toString(),style: addressTextStyle(),maxLines: 3),
                                  SizedBox(width: 10),
                                  Text(sellerPhoneNumber.toString(),style: addressTextStyle(),maxLines: 3),
                                ],
                              ),
                              SizedBox(height: 10),
                              Text('${sellerHouseNo} ม.${sellerMoo} ต.${sellerSubdistrict} อ.${sellerDistrict} จ.${sellerCity} ${sellerPostCode}',style: addressTextStyle(),maxLines: 3),
                            ],
                          ),
                        ):
                        sellerMoo == '' && sellerRoad == '' && widget.deliMethod == 'รับเองที่ฟาร์ม'?
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0,top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(sellerName.toString(),style: addressTextStyle(),maxLines: 3),
                                  SizedBox(width: 10),
                                  Text(sellerPhoneNumber.toString(),style: addressTextStyle(),maxLines: 3),
                                ],
                              ),
                              SizedBox(height: 10),
                              Text('${sellerHouseNo} ต.${sellerSubdistrict} อ.${sellerDistrict} จ.${sellerCity} ${sellerPostCode}',style: addressTextStyle(),maxLines: 3),
                            ],
                          ),
                        ): widget.deliMethod == 'รับเองที่ฟาร์ม'?
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0,top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(sellerName.toString(),style: addressTextStyle(),maxLines: 3),
                                  SizedBox(width: 10),
                                  Text(sellerPhoneNumber.toString(),style: addressTextStyle(),maxLines: 3),
                                ],
                              ),
                              SizedBox(height: 10),
                              Text('${sellerHouseNo} ม.${sellerMoo} ถ.${sellerRoad} ต.${sellerSubdistrict} อ.${sellerDistrict} จ.${sellerCity} ${sellerPostCode}',style: addressTextStyle(),maxLines: 3),
                            ],
                          ),
                        )
                            :Padding(
                          padding: const EdgeInsets.only(left: 20.0,top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(name.toString(),style: addressTextStyle(),maxLines: 3),
                                  SizedBox(width: 10),
                                  Text(phoneNumber.toString(),style: addressTextStyle(),maxLines: 3),
                                ],
                              ),
                              SizedBox(height: 10),
                              Text(airport.toString(),style: addressTextStyle(),maxLines: 3),
                            ],
                          ),
                        ),
                      ],
                    ),
                    onTap: (){

                    },
                  ),
                ],
              ),
            ),
          ),


          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: buildTicketUpperPart(
                context,
                widget.ticket_postId,
                widget.storeName,
                widget.imgUrl,
                widget.topic,
                widget.brand,
                widget.weight,
                widget.type,
                widget.price,
                widget.promo,
                widget.qty,
                widget.deliMethod
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Row(
                        children: [
                          Text('หมายเลขคำสั่งซื้อ : ${widget.ticket_postId}',style: TextStyle(fontWeight: FontWeight.bold,fontSize:isTablet?20:16)),
                          SizedBox(width: 10),
                          InkWell(
                            child: Icon(FontAwesomeIcons.copy,size: 15,color: Colors.grey),
                            onTap: (){
                              Clipboard.setData(ClipboardData(text: widget.ticket_postId));
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            },
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    Timestamp_onComplete_time == null ? SizedBox():Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('สำเร็จ :',style: TextStyle(fontSize: isTablet?20:16)),
                          Text(DateFormat('dd-MM-yyyy').add_jm().format(Timestamp_onComplete_time!.toDate()),style: TextStyle(fontSize: isTablet?20:16))
                        ],
                      ),
                    ),

                    Timestamp_onCancel_time == null ? SizedBox():Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('ยกเลิกคำสั่งซื้อ :',style: TextStyle(fontSize: isTablet?20:16)),
                          Text(DateFormat('dd-MM-yyyy').add_jm().format(Timestamp_onCancel_time!.toDate()),style: TextStyle(fontSize: isTablet?20:16))
                        ],
                      ),
                    ),

                    Timestamp_guarantee_ticket_end_time == null || widget.type != 'pet'? SizedBox():Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('การันตีสิ้นสุด :',style: TextStyle(fontSize: isTablet?20:16)),
                          Text(DateFormat('dd-MM-yyyy').add_jm().format(Timestamp_guarantee_ticket_end_time!.toDate()),style: TextStyle(fontSize: isTablet?20:16))
                        ],
                      ),
                    ),

                    Timestamp_delivered_time == null? SizedBox():Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('ได้รับสินค้า :',style: TextStyle(fontSize: isTablet?20:16)),
                          Text(DateFormat('dd-MM-yyyy').add_jm().format(Timestamp_delivered_time!.toDate()),style: TextStyle(fontSize: isTablet?20:16))
                        ],
                      ),
                    ),

                    Timestamp_dispatched_time == null? SizedBox():Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('จัดส่ง :',style: TextStyle(fontSize: isTablet?20:16)),
                          Text(DateFormat('dd-MM-yyyy').add_jm().format(Timestamp_dispatched_time!.toDate()),style: TextStyle(fontSize: isTablet?20:16))
                        ],
                      ),
                    ),

                    Timestamp_received_ticket_time == null? SizedBox():Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('ชำระเงิน :',style: TextStyle(fontSize: isTablet?20:16)),
                          Text(DateFormat('dd-MM-yyyy').add_jm().format(Timestamp_received_ticket_time!.toDate()),style: TextStyle(fontSize: isTablet?20:16))
                        ],
                      ),
                    ),


                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Divider(color: themeColour),
                    ),
                    dataRow(
                        Text('ราคา (${widget.qty} ตัว) :',style: TextStyle(fontSize: isTablet?20:16)),
                        widget.promo == 0
                            ? Text('฿ ${f.format(widget.price *widget.qty)}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: isTablet?20:16))
                            : Text('฿ ${f.format(widget.promo *widget.qty)}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: isTablet?20:16))
                    ),
                    dataRow(
                        Text('ค่าจัดส่ง :',style: TextStyle(fontSize: isTablet?20:16)),
                        Text('฿ ${f.format(widget.deliFee)}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: isTablet?20:16))
                    ),
                    widget.discount == 0?SizedBox():dataRow(
                        Text('ส่วนลด :',style: TextStyle(fontSize: isTablet?20:16)),
                        Text('฿ - ${f.format(widget.discount)}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: isTablet?20:16))
                    ),
                    dataRow(
                        Text('ยอดรวม :',style: TextStyle(color: themeColour,fontSize: isTablet?20:16)),
                        Text('฿ ${f.format(widget.total)}',style: TextStyle(color: themeColour,fontWeight: FontWeight.bold,fontSize: isTablet?20:16))
                    ),
                    SizedBox(height: 10)
                  ],
                ),
              ),
            ),
          ),

          InkWell(
              child: Container(
                height: 55,
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red.shade900),
                  color: Colors.white,
                ),
                child: Text('ติดต่อผู้ขาย',style: TextStyle(color: Colors.red.shade900,fontSize: isTablet?20:16)),
              ),

              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>
                  chatroom(
                    userid: widget.userId,
                    peerid: widget.sellerId,
                    peerImg: sellerImageUrl,
                    userImg: userImageUrl,
                    peerName: widget.type == 'food'?'MULTIPAWS':sellerName,
                    userName: widget.userName,
                    postid: pet_postId,
                    priceMin: widget.price,
                    priceMax:0,
                    pricePromoMin: 0,
                    pricePromoMax: 0,
                    sold: true,
                  )
              ))
          ),
          SizedBox(height: 10),

          widget.status == 'เตรียมจัดส่ง'
              ?InkWell(
              child: Container(
                height: 55,
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                color: themeColour,
                child: Text('ยกเลิกคำสั่งซื้อ',style: TextStyle(color: Colors.white,fontSize: isTablet?20:16)),
              ), onTap: () {
                if(widget.type != 'pet' && Timestamp_received_ticket_time!.millisecondsSinceEpoch < cutoff.millisecondsSinceEpoch && now.millisecondsSinceEpoch >= Timestamp_received_added_two_Hour_ticket_time!){
                  notiAlertDialog(context, widget.type);
                }else if(widget.type == 'pet' && DateTime.now().millisecondsSinceEpoch > petDueToDelivery.millisecondsSinceEpoch && now.millisecondsSinceEpoch >= Timestamp_received_added_two_Hour_ticket_time!){
                  notiAlertDialog(context, widget.type);
                }else{
                  cancelAlertDialog(
                      context,
                      widget.userName,
                      widget.ticket_postId,
                      sellerId.toString(),
                      widget.type,
                      widget.deliMethod,
                      date!,
                      month!,
                      year!,
                      widget.topic,
                      widget.imgUrl,
                      seller.toString(),
                      widget.brand,
                      widget.price,
                      widget.promo,
                      widget.qty,
                      widget.deliFee,
                      widget.discount,
                      widget.total,
                      postId.toString(),
                      Timestamp_received_ticket_time!,
                      widget.issueBank,
                      widget.accountName,
                      widget.accountNumber,
                      widget.weight);
                }
          })
              :widget.status == 'กำลังขนส่ง'?
          InkWell(
              child: Container(
                height: 55,
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                color: themeColour,
                child: Text('ได้รับแล้ว',style: TextStyle(color: Colors.white,fontSize: isTablet?20:16)),
              ), onTap: () async{

            await receviedConfirmationAlertDialog(
                context,
                widget.userName,
                widget.ticket_postId,
                sellerId.toString(),
                widget.type,
                widget.deliMethod,
                widget.topic,
                widget.imgUrl,
                seller.toString(),
                widget.brand,
                widget.weight,
                widget.price,
                widget.promo,
                widget.qty,
                widget.deliFee,
                widget.discount,
                widget.total,
                postId.toString(),
                widget.airline,
                widget.flightNo,
                widget.flightDepartureTime,
                widget.flightArrivalTime,
                Timestamp_received_ticket_time!,
                Timestamp_dispatched_time!,
                TimeStamp_expected_dispatched!
            );
          }):
          widget.status == 'การันตี'
              ?InkWell(
              child: Container(
                height: 55,
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                color: themeColour,
                child: Text('สิ้นค้ามีปัญหา',style: TextStyle(color: Colors.white,fontSize: isTablet?20:16)),
              ), onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=>guaranteeClaim(
                userId: widget.userId,
                ticket_postId: widget.ticket_postId,
                storeName: widget.storeName,
                imgurl: widget.imgUrl,
                brand: widget.brand,
                topic: widget.topic,
                price: widget.price,
                total: widget.total)));
          })
              :widget.status == 'รอการรีวิว'
              ?InkWell(
              child: Container(
                height: 55,
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                color: themeColour,
                child: Text('รีวิวสินค้า',style: TextStyle(color: Colors.white,fontSize: isTablet?20:16)),
              ), onTap: ()async{
            var result = await Navigator.push(context, MaterialPageRoute(builder: (context)=>
                rateAndReview(
                    imgUrl: widget.imgUrl,
                    topic:widget.topic,
                    breed: widget.brand,
                    sellerId: widget.sellerId,
                    userId: widget.userId,
                    userName: widget.userName,
                    buyerImageUrl: userImageUrl,
                    ticket_postId: widget.ticket_postId,
                    type: widget.type,
                    weight: widget.weight
                )));
            result == true ? Navigator.pop(context): null;
          })
              :Container(
            height: 0.0001,
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
          )
        ],
      ),
    );
  }

  Padding dataRow(Text text1, text2) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          text1,
          text2
        ],
      ),
    );
  }

  TextStyle addressTextStyle() => TextStyle(fontSize: isTablet?16:13,color: Colors.black);
  TextStyle addressBoldTextStyle() => TextStyle(fontSize: isTablet?16:13,color: Colors.black,fontWeight: FontWeight.bold);

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

  Future<dynamic> receviedConfirmationAlertDialog(
      BuildContext context,
      String userName,
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
                if(type == 'pet'){
                  price > 0 ?await OrderDispatchedToGuarantee(
                  userName,
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
                    OrderDispatchedToAwaitReviewFood(
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
                Navigator.pop(context,true);
                Navigator.pop(context,true);
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
                    :type == 'pet' && price == 0? Text('ได้รับน้องแล้วใช่หรือไม่ ?')
                    :Text('หากกดยืนยันรับสินค้าแล้ว จะไม่สามารถคืนหรือเปลี่ยนสินค้าได้หากเจอปัญหาภายหลัง',style: TextStyle(color: Colors.black,fontSize: isTablet?20:16)),
              )),
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
                          child: Center(child: Text('ยืนยัน',style: TextStyle(color: Colors.white,fontSize: isTablet?20:16),)),
                        ),
                      ),
                      onTap: () async {
                        if(type == 'pet'){
                          price > 0 ?await OrderDispatchedToGuarantee(
                              userName,
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
                          OrderDispatchedToAwaitReviewFood(
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
                        Navigator.pop(context,true);
                        Navigator.pop(context,true);
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
                          child: Center(child: Text('ยกเลิก',style: TextStyle(color: Colors.white,fontSize: isTablet?20:16))),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(width: 20)
                ],
              ),
            ),
          ],
        )
    );
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
        'userName': userName.toString(),
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
        'flightDepartureTime':'0',
        'flightArrivalTime': '0',

        'Timestamp_received_ticket_time':Timestamp_received_ticket_time,
        'Timestamp_dispatched_time':Timestamp_dispatched_time,
        'Timestamp_guarantee_ticket_start_time': now,
        'Timestamp_guarantee_ticket_end_time': now.millisecondsSinceEpoch
      });
      buyerOnDispatchRef.doc(ticket_postId).delete();
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
        'airline': airline == 0? '0': airline,
        'flightNumber': flightNumber == 0? '0': flightNumber,
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
    });
  }

  Padding buildTicketUpperPart(BuildContext context,
      String ticket_postId,
      String storeName,
      String imgurl,
      String topic,
      String brand,
      String weight,
      String type,
      int price,
      int promo,
      int qty,
      String deliMethod,
      ) {

    var f = new NumberFormat("#,###", "en_US");

    return Padding(
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(FontAwesomeIcons.store,size: 20,color: Colors.black),
                      SizedBox(width: 15),
                      Text(storeName,style: TextStyle(fontSize: isTablet?20:16))
                    ],
                  ),
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
                            crossAxisAlignment: CrossAxisAlignment.end,
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
                                padding: const EdgeInsets.only(right: 10.0),
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
            ],
          )
      ),
    );
  }

  updateCouponId(String couponId)async{
    await promotionRef.doc('123456789').collection('FoodPromotion').doc(couponId).get().then((snapshot){
      if(snapshot.exists){
        int remained = snapshot.data()!['remain'];
        promotionRef.doc('123456789').collection('FoodPromotion').doc(couponId).update(
            {
              'remain' : remained + 1
            });
      }else{
        promotionRef.doc('123456789').collection('PetPromotion').doc(couponId).get().then((snapshot){
          int remained = snapshot.data()!['remain'];
          promotionRef.doc('123456789').collection('PetPromotion').doc(couponId).update(
              {
                'remain' : remained + 1
              });
        });
      }
    });
  }

  OrderPreparedToCancel(
      String userName,
      String ticket_postId,
      String peerId,
      String type,
      String deliMethod,
      int date,
      int month,
      int year,
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
      Timestamp Timestamp_received_ticket_time,
      issueBank,
      accountName,
      accountNumber,
      amount,
      amount_deposit,
      amount_multipaws,
      weight,
      )async{

    String date_format = date<10?'0'+date.toString(): date.toString();
    String month_format = month<10?'0'+month.toString(): month.toString();
    DateTime cancelTime = DateTime.now();

    setState(() {
      isLoading = true;
    });

    total == 0? null:await usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('bankAccount').where('refundAccount',isEqualTo: true).get().then((snapshot){
      snapshot.docs.forEach((doc) {
        usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('bankAccount').doc(doc.id).get().then((snaps){
          transactionRef.doc(ticket_postId).set({
            'issueBank': snaps.data()!['bankName'],
            'accountName': snaps.data()!['title']+' '+snaps.data()!['accountFirstName']+' '+snaps.data()!['accountLastName'],
            'accountNumber': snaps.data()!['accountNumber'],
            'amount': amount.round(),
            'timestamp': now.millisecondsSinceEpoch,
            'postId': ticket_postId,
            'transactionId': ticket_postId,
            'type' : type,
            'brand': breed,
            'weight': type == 'pet'? '0': weight,
            'status': false,
          });
        });
      });
    });

    type == 'pet' && total != 0?await paymentIndexRef.doc(ticket_postId).get().then((snapshot){
      transactionRef.doc('DEPOSIT'+ticket_postId).set({
        'issueBank': snapshot.data()!['toIssueBank'],
        'accountName': snapshot.data()!['toAccountName'],
        'accountNumber': snapshot.data()!['toAccountNumber'],
        'amount': amount_deposit.round(),
        'timestamp': now.millisecondsSinceEpoch,
        'postId': ticket_postId,
        'transactionId': 'DEPOSIT'+ ticket_postId,
        'type' : type,
        'brand': breed,
        'weight': '0',
        'status': false,
      });
    }):null;

    type == 'pet' && total != 0?await transactionRef.doc('mulipaws'+ticket_postId).set({
      'issueBank': 'ไทยพาณิชย์',
      'accountName': 'บริษัท มัลติพอว์ส จำกัด',
      'accountNumber': '3574185835',
      'amount': amount_multipaws.round(),
      'timestamp': now.millisecondsSinceEpoch,
      'postId': ticket_postId,
      'transactionId': 'mulipaws'+ ticket_postId,
      'type' : type,
      'brand': breed,
      'weight': '0',
      'status': false,
    }):null;

    await buyerOnPrepareRef.doc(ticket_postId).get().then((snapshot){
      buyerOnCancelRef.doc(ticket_postId).set({
        'type': type,
        'seller': seller,
        'sellerId': peerId,
        'userId': widget.userId,
        'userName': userName,
        'topic': topic,
        'breed': breed,
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
        'status': 'ยกเลิก',
        'weight': type == 'pet'? '0': weight,

        'Timestamp_expected_dispatched_time':type == 'pet'?DateTime.parse('${year}-${month_format}-${date_format}').millisecondsSinceEpoch:now.millisecondsSinceEpoch,
        'Timestamp_received_ticket_time':Timestamp_received_ticket_time,
        'cancelBySystem_time' : cancelTime.millisecondsSinceEpoch,
        'reason': 'ผู้ซื้อต้องการยกเลิก',
      });
      buyerOnPrepareRef.doc(ticket_postId).delete();
      snapshot.data()!['promotionCode'] != ''?updateCouponId(snapshot.data()!['promotionCode']):null;
    });
    paymentIndexRef.doc(ticket_postId).update({
      'status': 'cxlByUser',
    });
    postsPuppyKittenRef.doc(postId).update({
      'active': true
    });
    widget.type != 'pet'?loseRef.doc(ticket_postId).set({
      'loss': total * 0.0277,
      'postId': ticket_postId,
      'sellerId': peerId,
      'timestamp': now.millisecondsSinceEpoch,
    }):null;
    widget.type != 'pet'?await postsFoodRef.doc(postId).get().then((snapshot){



      if(double.parse(weight) == snapshot['weight1']){
        int remaining = snapshot['stock1'];
        postsFoodRef.doc(postId).update({
          'stock1':remaining+qty
        });
      }else if(double.parse(weight) == snapshot['weight2']){
        int remaining = snapshot['stock2'];
        postsFoodRef.doc(postId).update({
          'stock2':remaining+qty
        });
      }else if(double.parse(weight) == snapshot['weight3']){
        int remaining = snapshot['stock3'];
        postsFoodRef.doc(postId).update({
          'stock3':remaining+qty
        });
      }else if(double.parse(weight) == snapshot['weight4']){
        int remaining = snapshot['stock4'];
        postsFoodRef.doc(postId).update({
          'stock4':remaining+qty
        });
      }else if(double.parse(weight) == snapshot['weight5']){
        int remaining = snapshot['stock5'];
        postsFoodRef.doc(postId).update({
          'stock5':remaining+qty
        });
      }else if(double.parse(weight) == snapshot['weight6']){
        int remaining = snapshot['stock6'];
        postsFoodRef.doc(postId).update({
          'stock6':remaining+qty
        });
      }
    }):null;
  }

  Future<dynamic> notiAlertDialog(BuildContext context,String type) {
    return showDialog(
        context: context,
        builder: (BuildContext context) =>
        Platform.isIOS ?
        CupertinoAlertDialog(
          content: type == 'pet'
              ?Text('ไม่สามารถยกเลิกได้เนื่องจากเกินเวลากำหนดส่งแล้ว',style: TextStyle(fontSize: isTablet?20:16))
              :Text('กรุณาติดต่อ MULTIPAWS ทาง LIVE HELP เพื่อยกเลิกคำสั่งซื้อ',style: TextStyle(fontSize: isTablet?20:16),),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('รับทราบ',style: TextStyle(color: themeColour,fontSize: isTablet?20:16)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ) :
        AlertDialog(
          backgroundColor: Colors.grey.shade100,
          content: type == 'pet'
              ?Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.blue.shade50,
              ),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: type == 'pet'
                    ?Text('ไม่สามารถยกเลิกได้เนื่องจากเกินเวลากำหนดส่งแล้ว',style: TextStyle(color: Colors.black,fontSize: isTablet?20:16))
                    :Text('กรุณาติดต่อ MULTIPAWS ทาง LIVE HELP เพื่อยกเลิกคำสั่งซื้อ ?',style: TextStyle(color: Colors.black,fontSize: isTablet?20:16)),)
          )
              :Text(''),
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
                          child: Center(child: Text('รับทราบ',style: TextStyle(color: Colors.white,fontSize: isTablet?20:16),)),
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
            ),
          ],
        )
    );
  }

  Future<dynamic> cancelAlertDialog(
      BuildContext context,
      String userName,
      String ticket_postId,
      String sellerId,
      String type,
      deliMethod,
      int date,
      int month,
      int year,
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
      Timestamp Timestamp_received_ticket_time,
      issueBank,
      accountName,
      accountNumber,
      weight,
      ) {
    return showDialog(
        context: context,
        builder: (BuildContext context) =>
        Platform.isIOS ?
        CupertinoAlertDialog(
          content: type == 'pet'
              ?Text('หากต้อกการยกเลิกคำสั่งซื้อ คุณจะถูกยึดมัดจำ 30% ของราคาเต็มและเงินส่วนที่เหลือจะถูกโอนเข้าบัญชีที่ให้ไว้ในระบบในวันที่ 15 หรือ 25 ของเดือน',style: TextStyle(fontSize: isTablet?20:16),)
              :Text('ต้องการยกเลิกคำสั่งซื้อ ใช่หรือไม่ ?',style: TextStyle(fontSize: isTablet?20:16)),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('ยืนยัน',style: TextStyle(color: themeColour,fontSize: isTablet?20:16),),
              onPressed: () async {
                OrderPreparedToCancel(
                    userName,
                    ticket_postId,
                    sellerId,
                    type,
                    deliMethod,
                    date,
                    month,
                    year,
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
                    Timestamp_received_ticket_time,
                    issueBank,
                    accountName,
                    accountNumber,
                    type == 'pet'? total-(price*0.3):total,
                    type == 'pet'? (price)*0.3*2/3:0,
                    type == 'pet'? (price)*0.3 - (price)*0.3*2/3 - ((price-discount+deliprice) * 0.0277):0,
                    weight
                );

                Future.delayed(const Duration(milliseconds: 1000), () {
                  setState(() {
                    isLoading = false;
                  });
                  Navigator.pop(context,true);
                  Navigator.pop(context,true);
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
          content: type == 'pet'
              ?Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.blue.shade50,
              ),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text('หากต้อกการยกเลิกคำสั่งซื้อ คุณจะถูกยึดมัดจำ 30% ของราคาเต็มและเงินส่วนที่เหลือจะถูกโอนเข้าบัญชีที่ให้ไว้ในระบบในวันที่ 15 หรือ 25 ของเดือน',style: TextStyle(color: Colors.black,fontSize: isTablet?20:16)),
              )
          )
              :Text('ต้องการยกเลิกคำสั่งซื้อ ใช่หรือไม่ ?',style: TextStyle(fontSize: isTablet?20:16)),
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
                          child: Center(child: Text('ยืนยัน',style: TextStyle(color: Colors.white,fontSize: isTablet?20:16),)),
                        ),
                      ),
                      onTap: () {
                        OrderPreparedToCancel(
                            userName,
                            ticket_postId,
                            sellerId,
                            type,
                            deliMethod,
                            date,
                            month,
                            year,
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
                            Timestamp_received_ticket_time,
                            issueBank,
                            accountName,
                            accountNumber,
                            type == 'pet'? total-(price*0.3):total,
                            type == 'pet'? (price)*0.3*2/3:0,
                            type == 'pet'? (price)*0.3 - (price)*0.3*2/3 - ((price-discount+deliprice) * 0.0277):0,
                            weight
                        );
                        Future.delayed(const Duration(milliseconds: 1000), () {
                          setState(() {
                            isLoading = false;
                          });
                          Navigator.pop(context,true);
                          Navigator.pop(context,true);
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
                          child: Center(child: Text('ยกเลิก',style: TextStyle(color: Colors.white,fontSize: isTablet?20:16))),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context,false);
                      },
                    ),
                  ),
                  SizedBox(width: 20),
                ],
              ),
            ),
          ],
        )
    );
  }
}

InkWell buildEvidence(BuildContext context,String image) {
  return InkWell(
    child: Container(
      width: 80,
      height: 80,
      child: Image.network(image,fit: BoxFit.fitHeight),
    ),
    onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>showNetworkImage(image: image))),
  );
}