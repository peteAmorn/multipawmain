import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multipawmain/authCheck.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:multipawmain/support/showNetworkImage.dart';
import 'dart:io';
import 'chat/chatroom.dart';
import 'myshop/flightDetail.dart';
import 'package:sizer/sizer.dart';

DateTime now = DateTime.now();
bool isTablet = false;

class orderDetailSeller extends StatefulWidget {
  final String sellerId,ticket_postId,status,deliMethod,imgUrl,storeName,topic,brand,weight,type,buyerId,buyerName;
  final int price,promo,qty, deliFee, total,discount;
  final reason;
  final flightNo,airline,flightDepartureTime,flightArrivalTime;

  orderDetailSeller({
    required this.sellerId,
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
    required this.buyerId,
    required this.buyerName,

    this.airline,
    this.flightNo,
    this.reason,
    this.flightDepartureTime,
    this.flightArrivalTime
  });

  @override
  _orderDetailSellerState createState() => _orderDetailSellerState();
}

class _orderDetailSellerState extends State<orderDetailSeller> {

  String? name,houseNo,moo,road,subdistrict,district,city,postCode,phoneNumber,paymentType,buyerId,airport,symptom,vetCertificate,evident01,evident02,issueBank, accountName, accountNumber,pet_postId;

  bool isLoading = false;
  Timestamp? Timestamp_received_ticket_time,
      Timestamp_dispatched_time,
      Timestamp_delivered_time,
      Timestamp_guarantee_ticket_end_time,
      Timestamp_onComplete_time,
      Timestamp_onCancel_time,
      TimeStamp_expected_dispatched;
  int? date,month,year;
  String? buyer,seller,sellerId,postId,sellerImageUrl,buyerImageUrl;

  getUserImageUrl()async{
    await usersRef.doc(widget.sellerId).get().then((snapshot){
      sellerImageUrl = snapshot.data()!['urlProfilePic'];
      seller = snapshot.data()!['name'];
    });

    await usersRef.doc(widget.buyerId).get().then((snapshot){
      buyerImageUrl = snapshot.data()!['urlProfilePic'];
      buyer = snapshot.data()!['name'];
    });

    await paymentIndexRef.doc(widget.ticket_postId).get().then((snapshot){
      pet_postId = snapshot.data()!['pet_postId'];
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
        buyerId = snapshot.data()!['userId'];
        airport = snapshot.data()!['toAirport'];
      }
    });
  }

  getBuyerOnPrep()async{
    await buyerOnPrepareRef.doc(widget.ticket_postId).get().then((snapshot){
      date = snapshot.data()!['dispatchDate'];
      month = snapshot.data()!['dispatchMonth'];
      year = snapshot.data()!['dispatchYear'];
      sellerId = snapshot.data()!['sellerId'];
      postId = snapshot.data()!['postId'];
    });
    setState(() {
      isLoading = false;
    });
  }

  getBuyerOnDispatch()async{
    await buyerOnDispatchRef.doc(widget.ticket_postId).get().then((snapshot){
      sellerId = snapshot.data()!['sellerId'];
      postId = snapshot.data()!['postId'];
      TimeStamp_expected_dispatched = snapshot.data()!['Timestamp_expected_dispatched_time'];
    });
    setState(() {
      isLoading = false;
    });
  }

  getBankInfo()async{
    await paymentIndexRef.doc(widget.ticket_postId).get().then((snapshot){
      issueBank = snapshot.data()!['toRefundIssueBank'];
      accountName = snapshot.data()!['toRefundAccountName'];
      accountNumber = snapshot.data()!['toRefundAccountNumber'];
    });
  }

  getTimeLine()async{
    if(widget.status == 'เตรียมจัดส่ง'){
      await buyerOnPrepareRef.doc(widget.ticket_postId).get().then((snapshot) {
        Timestamp_received_ticket_time = snapshot.data()!['Timestamp_received_ticket_time'];
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

  getEvidence()async{
    await buyerOnGuaranteeRef.doc(widget.ticket_postId).get().then((snapshot) {
      symptom = snapshot.data()!['symptom'];
      vetCertificate = snapshot.data()!['vetCertificate'];
      evident01 = snapshot.data()!['evident01'];
      evident02 = snapshot.data()!['evident02'];
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
    getTimeLine();
    widget.status == 'เกิดข้อพิพาท'
        ?getBankInfo():null;
    widget.status == 'เตรียมจัดส่ง'
        ?getBuyerOnPrep()
        :widget.status == 'กำลังขนส่ง'
        ?getBuyerOnDispatch()
        :widget.status == 'เกิดข้อพิพาท'
        ?getEvidence()
        :null;


    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final snackBar = SnackBar(content: Text('Copy to clipboard',style: TextStyle(fontSize: isTablet?20:16)),
        duration: Duration(seconds: 1),
        backgroundColor: themeColour,
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
          widget.status == 'เกิดข้อพิพาท'?SizedBox(height: 10):SizedBox(),
          widget.status == 'เกิดข้อพิพาท'?Container(
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
                      child: Text(symptom.toString(), maxLines: 10)
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(FontAwesomeIcons.mapMarkerAlt,color: themeColour),
                          SizedBox(width: 15),
                          widget.deliMethod == 'รับเองที่ฟาร์ม'
                              ?Text('ที่อยู่ของผู้ซื้อ',style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold))
                              :Text('ที่อยู่สำหรับจัดส่ง',style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 10),
                      moo == '' && widget.deliMethod != 'ส่งทางอากาศ (รับที่สนามบิน)'?
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
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
                      road == '' && widget.deliMethod != 'ส่งทางอากาศ (รับที่สนามบิน)'?
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
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
                      moo == '' && road == '' && widget.deliMethod != 'ส่งทางอากาศ (รับที่สนามบิน)'?
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
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
                      ): widget.deliMethod != 'ส่งทางอากาศ (รับที่สนามบิน)'?
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
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
                      ):Padding(
                        padding: const EdgeInsets.only(left: 20.0),
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
            padding: EdgeInsets.only(bottom: 10.0),
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
                          Text('หมายเลขคำสั่งซื้อ : ${widget.ticket_postId}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: isTablet?20:16)),
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
                          Text('สำเร็จ :',style: TextStyle(fontSize: isTablet?20:16),),
                          Text(DateFormat('dd-MM-yyyy').add_jm().format(Timestamp_onComplete_time!.toDate()),style: TextStyle(fontSize: isTablet?20:16))
                        ],
                      ),
                    ),

                    Timestamp_onCancel_time == null ? SizedBox():Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('ยกเลิกคำสั่งซื้อ :',style: TextStyle(fontSize: isTablet?20:16),),
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
                border: Border.all(color: themeColour),
                color: Colors.white,
              ),
              child: Text('ติดต่อผู้ซื้อ',style: TextStyle(color: Colors.black,fontSize: isTablet?20:16)),
            ),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>
                  chatroom(
                    userid: widget.sellerId,
                    peerid: buyerId.toString(),
                    peerImg: buyerImageUrl,
                    userImg: sellerImageUrl,
                    peerName: buyer,
                    userName: seller,
                    postid: pet_postId,
                    priceMin: widget.price,
                    priceMax:0,
                    pricePromoMin: 0,
                    pricePromoMax: 0,
                    dtype: 'productImage',
                    sold: true,
                  )
              ))

          ),
          SizedBox(height: 10),
          widget.status == 'เตรียมจัดส่ง'?InkWell(
            child: Container(
              height: 55,
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                border: Border.all(color: themeColour),
                color: Colors.black,
              ),
              child: Text('ยกเลิกคำสั่งซื้อ',style: TextStyle(color: Colors.white,fontSize: isTablet?20:16)),
            ),
            onTap: (){
              cancelAlertDialog(
                  context,
                  widget.buyerName,
                  widget.buyerId,
                  widget.ticket_postId,
                  widget.sellerId,
                  widget.type,
                  widget.deliMethod,
                  date!,
                  month!,
                  year!,
                  widget.topic,
                  widget.imgUrl,
                  widget.storeName,
                  widget.brand,
                  widget.price,
                  widget.promo,
                  widget.qty,
                  widget.deliFee,
                  widget.discount,
                  widget.total,
                  postId.toString(),
                  Timestamp_received_ticket_time!,
                  issueBank,
                  accountName,
                  accountNumber,
                  widget.weight
              );
            },
          ):SizedBox(),
          SizedBox(height: 10),
          // widget.status == 'เตรียมจัดส่ง'
          //     ?InkWell(
          //     child: Container(
          //       height: 55,
          //       alignment: Alignment.center,
          //       width: MediaQuery.of(context).size.width,
          //       color: themeColour,
          //       child: Text(widget.deliFee == 0?'มารับน้องได้เลย':'ส่งสินค้าแล้ว',style: TextStyle(color: Colors.white,fontSize: isTablet?20:16)),
          //     ), onTap: () async{
          //
          //   if(widget.deliMethod == 'ส่งทางอากาศ (รับที่สนามบิน)'){
          //     var result = await Navigator.push(context, MaterialPageRoute(builder: (context)=>flightDetail()));
          //     OrderPreparedToDispatch(
          //         widget.buyerName,
          //         widget.ticket_postId,
          //         buyerId.toString(),
          //         widget.type,
          //         widget.deliMethod,
          //         date!.toInt(),
          //         month!.toInt(),
          //         year!.toInt(),
          //         widget.topic,
          //         widget.imgUrl,
          //         widget.storeName,
          //         widget.brand,
          //         widget.weight,
          //         widget.price,
          //         widget.promo,
          //         widget.qty,
          //         widget.deliFee,
          //         widget.discount,
          //         widget.total,
          //         postId.toString(),
          //         result[0],
          //         result[1],
          //         result[2],
          //         result[3],
          //         Timestamp_received_ticket_time!
          //     );
          //   }else{
          //     OrderPreparedToDispatch(
          //         widget.buyerName,
          //         widget.ticket_postId,
          //         buyerId.toString(),
          //         widget.type,
          //         widget.deliMethod,
          //         date!.toInt(),
          //         month!.toInt(),
          //         year!.toInt(),
          //         widget.topic,
          //         widget.imgUrl,
          //         widget.storeName,
          //         widget.brand,
          //         widget.weight,
          //         widget.price,
          //         widget.promo,
          //         widget.qty,
          //         widget.deliFee,
          //         widget.discount,
          //         widget.total,
          //         postId.toString(),
          //         '0',
          //         '0',
          //         '0',
          //         '0',
          //         Timestamp_received_ticket_time!
          //     );
          //   }
          //   Navigator.pop(context);
          // }):
          widget.status == 'เกิดข้อพิพาท'
              ?InkWell(
              child: Container(
                height: 55,
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                color: themeColour,
                child: Text('ยอมรับการเคลมสินค้า',style: TextStyle(color: Colors.white,fontSize: isTablet?20:16)),
              ),
              onTap: (){
                acceptRefundAlertDialog(
                  context,
                  widget.buyerId,
                  widget.ticket_postId,
                  widget.total,
                  widget.brand,
                  issueBank.toString(),
                  accountName.toString(),
                  accountNumber.toString(),
                  widget.discount,
                );
                // Navigator.pop(context);
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

  TextStyle addressTextStyle() => TextStyle(fontSize: isTablet?17:13,color: Colors.black);

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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

  OrderPreparedToDispatch(
      String buyerName,
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
      'peerId': peerId,
      'peerImg': img,
      'peerName': topic,
      'timestamp': now,
      'type': 'noti',
      'userId': widget.sellerId,
      'userImg': img,
      'userName': "MULTIPAWS",
    }):null;

    await buyerOnPrepareRef.doc(ticket_postId).get().then((snapshot){
      buyerOnDispatchRef.doc(ticket_postId).set({
        'type': type,
        'seller': seller,
        'sellerId': widget.sellerId,
        'userId': peerId,
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

Future<dynamic> cancelAlertDialog(
    BuildContext context,
    String userName,
    String userId,
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
        content: Text('หากผู้ขายต้องการยกเลิกคำสั่งซื้อ ผู้ขายจะไม่ได้รับค่ามัดจำ ยืนยันเพื่อจะดำเนินการต่อ ใช่หรือไม่ ?',style: TextStyle(fontSize: isTablet?20:16)),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text('ยืนยัน',style: TextStyle(color: themeColour,fontSize: isTablet?20:16),),
            onPressed: () async {
              OrderPreparedToCancel(
                  userName,
                  userId,
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
                  weight
              );
              Navigator.pop(context,ticket_postId);
              Navigator.pop(context,ticket_postId);
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
              child: Text('หากผู้ขายต้องการยกเลิกคำสั่งซื้อ ผู้ขายจะไม่ได้รับค่ามัดจำ ยืนยันเพื่อจะดำเนินการต่อ ใช่หรือไม่ ?',style: TextStyle(color: Colors.black,fontSize: isTablet?20:16)),
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
                        child: Center(child: Text('ยืนยัน',style: TextStyle(color: Colors.white,fontSize: isTablet?20:16),)),
                      ),
                    ),
                    onTap: () {
                      OrderPreparedToCancel(
                          userName,
                          userId,
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
                          weight
                      );
                      Navigator.pop(context,ticket_postId);
                      Navigator.pop(context,ticket_postId);
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
                SizedBox(width: 20),
              ],
            ),
          ),
        ],
      )
  );
}

OrderPreparedToCancel(
    String userName,
    String buyerId,
    String ticket_postId,
    String sellerId,
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
    weight,
    )async{

  String date_format = date<10?'0'+date.toString(): date.toString();
  String month_format = month<10?'0'+month.toString(): month.toString();
  DateTime cancelTime = DateTime.now();

  total == 0? null:await usersRef.doc(buyerId).collection('payment').doc(buyerId).collection('bankAccount').where('refundAccount',isEqualTo: true).get().then((snapshot){
    snapshot.docs.forEach((doc) {
      usersRef.doc(buyerId).collection('payment').doc(buyerId).collection('bankAccount').doc(doc.id).get().then((snaps){
        transactionRef.doc(ticket_postId).set({
          'issueBank': snaps.data()!['bankName'],
          'accountName': snaps.data()!['title']+' '+snaps.data()!['accountFirstName']+' '+snaps.data()!['accountLastName'],
          'accountNumber': snaps.data()!['accountNumber'],
          'amount': total,
          'timestamp': now.millisecondsSinceEpoch,
          'type' : type,
          'brand': breed,
          'weight': '0',
          'postId': ticket_postId,
          'status': false,
          'transactionId': ticket_postId,
        });
      });
    });
  });

  await buyerOnPrepareRef.doc(ticket_postId).get().then((snapshot){
    buyerOnCancelRef.doc(ticket_postId).set({
      'type': type,
      'seller': seller,
      'sellerId': sellerId,
      'userId': buyerId,
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

      'Timestamp_expected_dispatched_time':type == 'pet'?DateTime.parse('${year}-${month_format}-${date_format}'):now,
      'Timestamp_received_ticket_time':Timestamp_received_ticket_time,
      'cancelBySystem_time' : cancelTime.millisecondsSinceEpoch,
      'reason': 'ผู้ขายต้องการยกเลิก',
    });

     loseRef.doc(ticket_postId).set({
      'loss': total * 0.0277,
      'postId': ticket_postId,
      'sellerId': sellerId,
      'timestamp': now.millisecondsSinceEpoch,
    });

    discount == 0? null:promotionIndexRef.doc(snapshot.data()!['promotionCode']+buyerId).delete();
    discount == 0? null:promotionRef.doc('123456789').collection('PetPromotion').doc(snapshot.data()!['promotionCode']).get().then((snapshot){
      promotionRef.doc('123456789').collection('PetPromotion').doc(snapshot.data()!['promotionCode']).update(
          {
            'remain': snapshot.data()!['remain']+1
          });
    });

    buyerOnPrepareRef.doc(ticket_postId).delete();
    discount == 0? null:updateCouponId(snapshot.data()!['promotionCode']);
  });

  paymentIndexRef.doc(ticket_postId).update({
    'status': 'cxlByUser',
  });
}


Future<dynamic> acceptRefundAlertDialog(BuildContext context,
    String buyerId,
    String ticket_postId,
    int amount,
    String breed,
    String issueBank,
    String accountName,
    String accountNumber,
    int discount,
    ) {
  return showDialog(
      context: context,
      builder: (BuildContext context) =>
      Platform.isIOS ?
      CupertinoAlertDialog(
        content: Text('หากยอมรับการเคลมสินค้า เงินจะถูกโอนคืนให้ลูกค้า',style: TextStyle(fontSize: isTablet?20:16)),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text('ยืนยัน',style: TextStyle(color: Colors.red,fontSize: isTablet?20:16),),
            onPressed: () async {

              amount == 0?null:await transactionRef.doc(ticket_postId).set({
                'issueBank': issueBank,
                'accountName': accountName,
                'accountNumber': accountNumber,
                'amount': amount,
                'timestamp': now.millisecondsSinceEpoch,
                'type' : 'pet',
                'brand': breed,
                'weight': '0',
                'postId': ticket_postId,
                'status': false,
                'transactionId': ticket_postId,
              });

              await buyerOnGuaranteeRef.doc(ticket_postId).get().then((snapshot){
                buyerOnRefundRef.doc(ticket_postId).set({
                  'type': 'pet',
                  'sellerId': snapshot.data()!['sellerId'],
                  'seller': snapshot.data()!['seller'],
                  'userId':snapshot.data()!['userId'],
                  'userName': snapshot.data()!['userName'],
                  'topic': snapshot.data()!['topic'],
                  'breed': breed,
                  'image': snapshot.data()!['image'],
                  'price': snapshot.data()!['price'],
                  'promo': 0,
                  'quantity': snapshot.data()!['quantity'],
                  'deliPrice': snapshot.data()!['deliPrice'],
                  'discount': discount,
                  'total': snapshot.data()!['total'],
                  'postId': snapshot.data()!['postId'],
                  'ticket_postId': ticket_postId,
                  'delivery_method': snapshot.data()!['delivery_method'],
                  'status': 'เคลมสินค้าสำเร็จ',
                  'weight': '0',
                  'airline': snapshot.data()!['airline'],
                  'flightNumber' : snapshot.data()!['flightNumber'],
                  'flightArrivalTime': snapshot.data()!['flightArrivalTime'],
                  'flightDepartureTime': snapshot.data()!['flightDepartureTime'],
                  'vetCertificate': snapshot.data()!['vetCertificate'],
                  'evident01': snapshot.data()!['evident01'],
                  'evident02': snapshot.data()!['evident02'],
                  'symptom': snapshot.data()!['symptom'],

                  'Timestamp_product_claimed_approved_time': now,
                  'Timestamp_guarantee_ticket_start_time':snapshot.data()!['Timestamp_guarantee_ticket_start_time'],
                  'Timestamp_dispatched_time':snapshot.data()!['Timestamp_dispatched_time'],
                  'Timestamp_received_ticket_time':snapshot.data()!['Timestamp_received_ticket_time'],
                  'rp_BankName': snapshot.data()!['rp_BankName'],
                  'rp_AccountName': snapshot.data()!['rp_AccountName'],
                  'rp_AccountNumber': snapshot.data()!['rp_AccountNumber']
                });
                loseRef.doc(ticket_postId).set({
                  'loss': snapshot.data()!['total'] * 0.0277,
                  'postId': ticket_postId,
                  'sellerId': snapshot.data()!['sellerId'],
                  'timestamp': now.millisecondsSinceEpoch,
                });


                buyerOnGuaranteeRef.doc(ticket_postId).delete();
                buyerOnReviewRef.doc(ticket_postId).delete();
              });

              paymentIndexRef.doc(ticket_postId).update({
                'status': 'refunded',
              });

              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            child: Text('ยกเลิก',style: TextStyle(color: Colors.green.shade800,fontSize: isTablet?20:16)),
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
              child: Text('หากยอมรับการเคลมสินค้า เงินจะถูกโอนคืนให้ลูกค้า',style: TextStyle(color: Colors.black,fontSize: isTablet?20:16)),
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
                          child: Center(child: Text('ยืนยัน',style: TextStyle(color: Colors.white,fontSize: isTablet?20:16),)),
                        )),
                    onTap: () async {
                      amount == 0?null:await transactionRef.doc(ticket_postId).set({
                        'issueBank': issueBank,
                        'accountName': accountName,
                        'accountNumber': accountNumber,
                        'amount': amount,
                        'timestamp': now.millisecondsSinceEpoch,
                        'type' : 'pet',
                        'brand': breed,
                        'weight': '0',
                        'postId': ticket_postId,
                        'status': false,
                        'transactionId': ticket_postId,
                      });

                      await buyerOnGuaranteeRef.doc(ticket_postId).get().then((snapshot){
                        buyerOnRefundRef.doc(ticket_postId).set({
                          'type': 'pet',
                          'sellerId': snapshot.data()!['sellerId'],
                          'seller': snapshot.data()!['seller'],
                          'userId':snapshot.data()!['userId'],
                          'userName': snapshot.data()!['userName'],
                          'topic': snapshot.data()!['topic'],
                          'breed': breed,
                          'image': snapshot.data()!['image'],
                          'price': snapshot.data()!['price'],
                          'promo': 0,
                          'quantity': snapshot.data()!['quantity'],
                          'deliPrice': snapshot.data()!['deliPrice'],
                          'discount': discount,
                          'total': snapshot.data()!['total'],
                          'postId': snapshot.data()!['postId'],
                          'ticket_postId': ticket_postId,
                          'delivery_method': snapshot.data()!['delivery_method'],
                          'status': 'เคลมสินค้าสำเร็จ',
                          'weight': '0',
                          'airline': snapshot.data()!['airline'],
                          'flightNumber' : snapshot.data()!['flightNumber'],
                          'flightArrivalTime': snapshot.data()!['flightArrivalTime'],
                          'flightDepartureTime': snapshot.data()!['flightDepartureTime'],
                          'vetCertificate': snapshot.data()!['vetCertificate'],
                          'evident01': snapshot.data()!['evident01'],
                          'evident02': snapshot.data()!['evident02'],
                          'symptom': snapshot.data()!['symptom'],

                          'Timestamp_product_claimed_approved_time': now,
                          'Timestamp_guarantee_ticket_start_time':snapshot.data()!['Timestamp_guarantee_ticket_start_time'],
                          'Timestamp_dispatched_time':snapshot.data()!['Timestamp_dispatched_time'],
                          'Timestamp_received_ticket_time':snapshot.data()!['Timestamp_received_ticket_time'],
                          'rp_BankName': snapshot.data()!['rp_BankName'],
                          'rp_AccountName': snapshot.data()!['rp_AccountName'],
                          'rp_AccountNumber': snapshot.data()!['rp_AccountNumber']
                        });
                        loseRef.doc(ticket_postId).set({
                          'loss': snapshot.data()!['total'] * 0.0277,
                          'postId': ticket_postId,
                          'sellerId': snapshot.data()!['sellerId'],
                          'timestamp': now.millisecondsSinceEpoch,
                        });
                        buyerOnGuaranteeRef.doc(ticket_postId).delete();
                        buyerOnReviewRef.doc(ticket_postId).delete();
                      });

                      paymentIndexRef.doc(ticket_postId).update({
                        'status': 'refunded',
                      });

                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.pop(context);
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
                SizedBox(width: 20),
              ],
            ),
          )
        ],
      )
  );
}