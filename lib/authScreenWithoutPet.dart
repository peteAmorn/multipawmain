import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multipawmain/myshop/petShop/addSellPostPet.dart';
import 'package:multipawmain/pages/notification.dart';
import 'package:multipawmain/profileWIthoutPet.dart';
import 'package:multipawmain/questionsAndConditions/conditionBuyer.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/shop/shop.dart';
import 'package:multipawmain/authCheck.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:multipawmain/support/payment/api_request.dart';
import 'package:multipawmain/support/payment/moneyspace_model.dart';
import 'package:multipawmain/support/payment/service.dart';
import 'package:nanoid/nanoid.dart';
import 'database/breedDatabase.dart';
import 'database/posts.dart';
import 'dart:io';

DateTime now = DateTime.now();
class authScreenWithoutPet extends StatefulWidget {
  final String? currentUserId;
  final int pageIndex;
  authScreenWithoutPet(
      {
        this.currentUserId,
        required this.pageIndex,
      });

  @override
  _authScreenWithoutPetState createState() => _authScreenWithoutPetState();
}

class _authScreenWithoutPetState extends State<authScreenWithoutPet> {
  late PageController pageController;
  late int _pageIndex;
  bool isLoading = false;
  String? _getToken;
  int total_Noti = 0;
  int itemToPrepare = 0;
  int itemDispatched = 0;
  int itemGuarantee =0;
  int itemToReview = 0;
  bool iLoading = false;
  List<String> postIdList = [];
  List<itemInCart> itemCart = [];
  bool destinationCheck = true;
  int comm = 20;

  late APIRequest<List<TransStatChck_MoneySpace_Response>> _responseFromPaymentCheckingTransactionID;

  // #########################################################
  // Uncomment this section when want to show shop
  updateActive(String postId, String type)async{
    if(type == 'pet'){
      await postsPuppyKittenRef.doc(postId).update({
        'active':false,
      });
    }
  }

  pushToPurchase(
      String userId,
      String seller,
      String sellerId,
      String postId ,
      String topic,
      String breed,
      String img ,
      int? price,
      int? promo,
      int? quantity,
      int? deliPrice,
      int discount,
      int? total,
      int? date,
      int? month,
      int? year,
      String deliMethod,
      String type,
      String subType,
      String brand,
      String weight,
      String destination,
      String transactionId,
      String MoneySpaceTransactionID,
      String paymentName,
      String issueBank,
      String paymentNumber,
      String paymentType,
      String userName,
      String promoCode,
      String rp_BankName,
      String rp_AccountName,
      String rp_AccountNumber,
      String toAddress_name,
      String toAddress_houseNo,
      String toAddress_moo,
      String toAddress_road,
      String toAddress_subdistrict,
      String toAddress_district,
      String toAddress_city,
      String toAddress_postCode,
      String toAddress_phoneNo,
      )async{
    final DateTime timestamp = DateTime.now();
    var getId = customAlphabet('ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789', 10);
    final today = formatDate(now,[dd,mm,yyyy]);
    final new_postId = getId + today;

    String concatDate = date!<10?'0'+date.toString(): date.toString();
    String concatMonth = month!<10?'0'+ month.toString(): month.toString();
    DateTime petDeliDate = type == 'pet'?DateTime.parse('${year.toString()}-${concatMonth}-${concatDate} 10:00:00'):timestamp;

    bool isAfterdeliDate = timestamp.isAfter(petDeliDate);

    DateTime deliDate = type == 'pet' && isAfterdeliDate == false? petDeliDate:now;

    // promo Account
    await promoActRef.where('id',isEqualTo: sellerId).get().then((snapshot){
      if(snapshot.size>0){
        comm = 3;
      }
    });

    await usersRef.doc(sellerId).collection('payment').doc(sellerId).collection('bankAccount').where('refundAccount',isEqualTo: true).get().then((snapshot){
      if(snapshot.size>0){
        snapshot.docs.forEach((doc) {
          usersRef.doc(sellerId).collection('payment').doc(sellerId).collection('bankAccount').doc(doc.id).get().then((snap){
            usersRef.doc(userId).collection('payment').doc(userId).collection('bankAccount').where('refundAccount',isEqualTo: true).get().then((sh){
              sh.docs.forEach((doc1) {
                usersRef.doc(userId).collection('payment').doc(userId).collection('bankAccount').doc(doc1.id).get().then((snap1){
                  paymentIndexRef.doc(new_postId).set({
                    'sellerId': sellerId,
                    'userId': widget.currentUserId,
                    'comm': comm,
                    'paymentName': paymentName,
                    'issueBank': issueBank,
                    'paymentNumber' : paymentNumber,
                    'paymentType': paymentType,
                    'total': total,
                    'price': price,
                    'quantity': quantity,
                    'promo': promo,
                    'discount': discount,
                    'deliPrice': deliPrice,
                    'toIssueBank' : snap.data()!['bankName'],
                    'toAccountName' : snap.data()!['title']+' '+snap.data()!['accountFirstName']+' '+snap.data()!['accountLastName'],
                    'toAccountNumber' : snap.data()!['accountNumber'],
                    'toAddress_name':toAddress_name,
                    'toAddress_houseNo':toAddress_houseNo,
                    'toAddress_moo':toAddress_moo,
                    'toAddress_road':toAddress_road,
                    'toAddress_subdistrict':toAddress_subdistrict,
                    'toAddress_district':toAddress_district,
                    'toAddress_city':toAddress_city,
                    'toAddress_postCode':toAddress_postCode,
                    'toAddress_phoneNo':toAddress_phoneNo,
                    'toAirport': destination,
                    'timestamp': now.millisecondsSinceEpoch,
                    'type': type,
                    'subType': subType,
                    'brand': type == 'pet'? breed:brand,
                    'topic': topic,
                    'pet_postId': postId,
                    'weight': weight,
                    'status': 'progress',
                    'toRefundAccountName' : snap1.data()!['title']+' '+snap1.data()!['accountFirstName']+' '+snap1.data()!['accountLastName'],
                    'toRefundAccountNumber' : snap1.data()!['accountNumber'],
                    'toRefundIssueBank' : snap1.data()!['bankName'],
                    'ticket_postId': new_postId,
                    'transactionId': transactionId,
                    'MoneySpaceTransactionID': MoneySpaceTransactionID
                  });
                });});});
          });});
      }
    });

    await usersRef.doc(widget.currentUserId).collection('payment').doc(widget.currentUserId).collection('bankAccount').where('refundAccount',isEqualTo: true).get().then((snapshot){
      snapshot.docs.forEach((doc) {
        usersRef.doc(widget.currentUserId).collection('payment').doc(widget.currentUserId).collection('bankAccount').doc(doc.id).get().then((snap){
          buyerOnPrepareRef.doc(new_postId).set(
              {
                'type': type,
                'seller': seller,
                'sellerId': sellerId,
                'userId': widget.currentUserId,
                //username == BuyerName
                'userName': userName,
                'topic': topic,
                'breed': type == 'pet'? breed:brand,
                'image': img,
                'price': price,
                'promo': promo,
                'weight': weight,
                'quantity':quantity,
                'deliPrice': deliPrice,
                'discount': discount,
                'promotionCode': promoCode,
                'total': total,
                'dispatchDate': date,
                'dispatchMonth': month,
                'dispatchYear': year,
                'postId': postId,
                'status': 'เตรียมจัดส่ง',
                'ticket_postId': new_postId,
                'delivery_method': deliMethod,
                'Timestamp_received_ticket_time':timestamp,
                'Timestamp_dueToDeliveryAlert': deliDate.millisecondsSinceEpoch,
                'Timestamp_autoCancel': deliDate.add(Duration(days: 7)).millisecondsSinceEpoch,
                'notiSend' : false,
                'rp_BankName': rp_BankName,
                'rp_AccountName':rp_AccountName,
                'rp_AccountNumber': rp_AccountNumber,

                'toAddress_name':toAddress_name,
                'toAddress_houseNo':toAddress_houseNo,
                'toAddress_moo':toAddress_moo,
                'toAddress_road':toAddress_road,
                'toAddress_subdistrict':toAddress_subdistrict,
                'toAddress_district':toAddress_district,
                'toAddress_city':toAddress_city,
                'toAddress_postCode':toAddress_postCode,
                'toAddress_phoneNo':toAddress_phoneNo,
              });
        });
      });
    });

    if(type == 'pet'){
      await usersRef.doc(userId).get().then((snapshot){
        usersRef.doc(sellerId).get().then((snap){
          notiRef.doc().set({
            'userName': 'MULTIPAWS',
            'peerName': seller,
            'userId': userId,
            'peerId': sellerId,
            'userImg': snapshot.data()!['urlProfilePic'] == null?null:snapshot.data()!['urlProfilePic'],
            'peerImg': snap.data()!['urlProfilePic'] == null?null:snap.data()!['urlProfilePic'],
            'message': '${userName} ได้ซื้อสัตว์เลี้ยงพันธุ์${breed}ของคุณแล้ว กรุณาเตรียมจัดส่งน้องในวันที่ ${date} ${monthList[month]} ${year}-${topic}',
            'type': 'alert',
            'timestamp': DateTime.now()
          });
        });
      });
    }
  }

  getInfoFromCart()async{
    String allPostId = '';
    await usersRef.doc(widget.currentUserId).collection('cart').doc(widget.currentUserId).get().then((snapshot){
      if(snapshot.exists){
        allPostId = snapshot.data()!['itemCart'];
      }
    });
    if(allPostId != null){
      postIdList = allPostId.trim().split(',');

      for(var i = 0;i<postIdList.length;i++){
        await usersRef.doc(widget.currentUserId).collection('myCart').where('postid',isEqualTo:postIdList[i]).get().then((snapshot){
          snapshot.docs.forEach((doc) {
            itemCart.add(
                itemInCart(
                  sellerName: doc.data()['sellerName'],
                  sellerId: doc.data()['id'],
                  postId: doc.data()['postid'],
                  topicName: doc.data()['topicName'],
                  breed: doc.data()['type'] == 'pet'? doc.data()['breed']:doc.data()['weight'].toString(),
                  imageUrl: doc.data()['imageUrl'],
                  price: doc.data()['price'],
                  promo: doc.data()['promo'] == null? 0:doc.data()['promo'],
                  quantity: doc.data()['quantity'],
                  deliFee: doc.data()['deliPrice'],
                  discount: 0,
                  dispatchDate: doc.data()['dispatchDate'],
                  dispatchMonth: doc.data()['dispatchMonth'],
                  dispatchYear: doc.data()['dispatchYear'],
                  type: doc.data()['type'],
                  subType: doc.data()['subType'],
                  deliMethod: doc.data()['type'] == 'pet'? doc.data()['deliMethod']: 'Standard Delivery',
                  brand: doc.data()['type'] == 'pet'? '0': doc.data()['brand'],
                  airPickUpShow: doc.data()['airPickUpShow'],
                  destination: '0',
                  forbidAirTransport: false,
                ));
          });
        });
      }

      setState(() {
        List<bool> checker = [];
        for(var i = 0; i<itemCart.length; i++){
          if(itemCart[i].destination == '0'  && itemCart[i].deliMethod == 'ส่งทางอากาศ (รับที่สนามบิน)'
              || itemCart[i].destination == null  && itemCart[i].deliMethod == 'ส่งทางอากาศ (รับที่สนามบิน)'){
            checker.add(false);
          }
        }
        checker.length > 0 ? destinationCheck = false: destinationCheck = true;
        checker.clear();
      });
    }
  }

  Future<dynamic> showAlertDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) =>
        Platform.isIOS ?
        CupertinoAlertDialog(
          title: Text('แจ้งเตือน'),
          content: Text('ขออภัย สิ้นค้าบางรายการในตระกร้ามีจำนวนไม่พอ'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('รับทราบ',style: TextStyle(color: Colors.blueAccent)),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
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
              child: Text('ขออภัย สิ้นค้าบางรายการในตระกร้ามีจำนวนไม่พอ',style: TextStyle(color: Colors.black,fontSize: 15))
          ),
          actions: <Widget>[
            Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                child: InkWell(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.green,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Center(
                          child: Text('ยืนยัน',style: TextStyle(color: Colors.white),)),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                )
            )
          ],
        )
    );
  }

  updateStock(String type,String postId, double weight, int qty)async{
    int residual;
    if(type == 'foods'){
      await postsFoodRef.doc(postId).get().then((snapshot){
        if(weight == snapshot.data()!['weight1']){
          residual = snapshot.data()!['stock1'] - qty;
          if(residual>=0){
            postsFoodRef.doc(postId).update({
              'stock1': residual
            });
          }else{
            setState(() {
              showAlertDialog(context);
            });
          }
        }else if(weight == snapshot.data()!['weight2']){
          residual = snapshot.data()!['stock2'] - qty;
          if(residual>=0){
            postsFoodRef.doc(postId).update({
              'stock2': residual
            });
          }else{
            setState(() {
              showAlertDialog(context);
            });
          }
        }else if(weight == snapshot.data()!['weight3']){
          residual = snapshot.data()!['stock3'] - qty;
          if(residual>=0){
            postsFoodRef.doc(postId).update({
              'stock3': residual
            });
          }else{
            setState(() {
              showAlertDialog(context);
            });
          }
        }else if(weight == snapshot.data()!['weight4']){
          residual = snapshot.data()!['stock4'] - qty;
          if(residual>=0){
            postsFoodRef.doc(postId).update({
              'stock4': residual
            });
          }else{
            setState(() {
              showAlertDialog(context);
            });
          }
        }else if(weight == snapshot.data()!['weight5']){
          residual = snapshot.data()!['stock5'] - qty;
          if(residual>=0){
            postsFoodRef.doc(postId).update({
              'stock5': residual
            });
          }else{
            setState(() {
              showAlertDialog(context);
            });
          }
        }else if(weight == snapshot.data()!['weight6']){
          residual = snapshot.data()!['stock6'] - qty;
          if(residual>=0){
            postsFoodRef.doc(postId).update({
              'stock6': residual
            });
          }else{
            setState(() {
              showAlertDialog(context);
            });
          }
        }
      });
    }
  }

  deleteItemInCart()async{
    await usersRef.doc(widget.currentUserId).collection('myCart').where('check',isEqualTo: true).get().then((snapshot){
      snapshot.docs.forEach((doc) {
        usersRef.doc(widget.currentUserId).collection('myCart').doc(doc.id).delete();
      });
    });
  }

  _checkTransaction()async{
    usersRef.doc(widget.currentUserId).collection('cart').doc(widget.currentUserId).get().then((snapshot) async {
      if(snapshot.exists){
        var MoneySpaceTransactionId = snapshot.data()!['MoneySpaceTransactionId'];
        String fromPage = snapshot.data()!['fromPage'];
        // Check transaction status
        _responseFromPaymentCheckingTransactionID = await Service().paymentCheckingMoneySpaceClass(MoneySpaceTransactionId).then((data) async {
          if(data.body![0].transactionId.status == 'Pay Success' && fromPage == 'fromCart'){
            for(var i = 0; i<itemCart.length; i++){
              if(itemCart[i].type == 'pet'){
                updateActive(itemCart[i].postId, itemCart[i].type);
                pushToPurchase(
                  widget.currentUserId.toString(),
                  itemCart[i].sellerName,
                  itemCart[i].sellerId,
                  itemCart[i].postId ,
                  itemCart[i].topicName,
                  itemCart[i].breed,
                  itemCart[i].imageUrl,
                  itemCart[i].price,
                  itemCart[i].promo,
                  itemCart[i].quantity,
                  itemCart[i].deliMethod == 'ส่งทางอากาศ (รับที่สนามบิน)'? 1500 : 0,
                  itemCart[i].discount,
                  itemCart[i].deliMethod == 'ส่งทางอากาศ (รับที่สนามบิน)'? itemCart[i].price + 1500 -itemCart[i].discount: itemCart[i].price -itemCart[i].discount,
                  itemCart[i].dispatchDate,
                  itemCart[i].dispatchMonth,
                  itemCart[i].dispatchYear,
                  itemCart[i].deliMethod,
                  itemCart[i].type,
                  itemCart[i].subType,
                  itemCart[i].breed,
                  '0',
                  itemCart[i].destination,
                  snapshot.data()!['transactionId'],
                  MoneySpaceTransactionId,
                  snapshot.data()!['paymentName'],
                  snapshot.data()!['issueBank'],
                  snapshot.data()!['paymentNumber'],
                  snapshot.data()!['paymentType'],
                  snapshot.data()!['userName'],
                  snapshot.data()!['promoCode'],
                  snapshot.data()!['rp_BankName'],
                  snapshot.data()!['rp_AccountName'],
                  snapshot.data()!['rp_AccountNumber'],
                  snapshot.data()!['toAddress_name'],
                  snapshot.data()!['toAddress_houseNo'],
                  snapshot.data()!['toAddress_moo'],
                  snapshot.data()!['toAddress_road'],
                  snapshot.data()!['toAddress_subdistrict'],
                  snapshot.data()!['toAddress_district'],
                  snapshot.data()!['toAddress_city'],
                  snapshot.data()!['toAddress_postCode'],
                  snapshot.data()!['toAddress_phoneNo'],
                );
              }else{
                updateStock(itemCart[i].type,itemCart[i].postId,double.parse(itemCart[i].breed),itemCart[i].quantity);

                pushToPurchase(
                  widget.currentUserId.toString(),
                  itemCart[i].sellerName,
                  itemCart[i].sellerId,
                  itemCart[i].postId ,
                  itemCart[i].topicName,
                  '${itemCart[i].breed}kg',
                  itemCart[i].imageUrl,
                  itemCart[i].price,
                  itemCart[i].promo,
                  itemCart[i].quantity,
                  itemCart[i].deliFee,
                  itemCart[i].discount,
                  itemCart[i].promo != 0
                      ? (itemCart[i].promo * itemCart[i].quantity) + itemCart[i].deliFee - itemCart[i].discount
                      : (itemCart[i].price * itemCart[i].quantity) + itemCart[i].deliFee - itemCart[i].discount,
                  itemCart[i].dispatchDate,
                  itemCart[i].dispatchMonth,
                  itemCart[i].dispatchYear,
                  itemCart[i].deliMethod,
                  itemCart[i].type,
                  itemCart[i].subType,
                  // breed provides pet breed and food weight
                  itemCart[i].brand,
                  // brand provides food brand
                  itemCart[i].breed,
                  '0',
                  snapshot.data()!['transactionId'],
                  MoneySpaceTransactionId,
                  snapshot.data()!['paymentName'],
                  snapshot.data()!['issueBank'],
                  snapshot.data()!['paymentNumber'],
                  snapshot.data()!['paymentType'],
                  snapshot.data()!['userName'],
                  snapshot.data()!['promoCode'],
                  snapshot.data()!['rp_BankName'],
                  snapshot.data()!['rp_AccountName'],
                  snapshot.data()!['rp_AccountNumber'],
                  snapshot.data()!['toAddress_name'],
                  snapshot.data()!['toAddress_houseNo'],
                  snapshot.data()!['toAddress_moo'],
                  snapshot.data()!['toAddress_road'],
                  snapshot.data()!['toAddress_subdistrict'],
                  snapshot.data()!['toAddress_district'],
                  snapshot.data()!['toAddress_city'],
                  snapshot.data()!['toAddress_postCode'],
                  snapshot.data()!['toAddress_phoneNo'],
                );
              }
            }
            usersRef.doc(widget.currentUserId).collection('cart').doc(widget.currentUserId).delete();
            deleteItemInCart();
          }else if(data.body![0].transactionId.status == 'Pay Success' && fromPage == 'buyNow'){
            // TransactionFromBuyNow

            String postId =  snapshot.data()!['postId'];
            String type = snapshot.data()!['type'];
            String weight = snapshot.data()!['weight'];
            var quantity = snapshot.data()!['quantity'];

            if(type == 'pet'){
              updateActive(postId,type);
              pushToPurchase(
                widget.currentUserId.toString(),
                snapshot.data()!['sellerName'],
                snapshot.data()!['sellerId'],
                postId,
                snapshot.data()!['topicName'],
                snapshot.data()!['breed'],
                snapshot.data()!['imageUrl'],
                snapshot.data()!['price'],
                snapshot.data()!['promo'],
                quantity,
                snapshot.data()!['deliPrice_BuyNow'],
                snapshot.data()!['discount'],
                snapshot.data()!['total'],
                snapshot.data()!['dispatchDate'],
                snapshot.data()!['dispatchMonth'],
                snapshot.data()!['dispatchYear'],
                snapshot.data()!['deliMethod_BuyNow'],
                type,
                snapshot.data()!['subType'],
                snapshot.data()!['breed'],
                '0',
                snapshot.data()!['destination'],
                snapshot.data()!['transactionId'],
                MoneySpaceTransactionId,
                snapshot.data()!['paymentName'],
                snapshot.data()!['issueBank'],
                snapshot.data()!['paymentNumber'],
                snapshot.data()!['paymentType'],
                snapshot.data()!['userName'],
                snapshot.data()!['promoCode'],
                snapshot.data()!['rp_BankName'],
                snapshot.data()!['rp_AccountName'],
                snapshot.data()!['rp_AccountNumber'],
                snapshot.data()!['toAddress_name'],
                snapshot.data()!['toAddress_houseNo'],
                snapshot.data()!['toAddress_moo'],
                snapshot.data()!['toAddress_road'],
                snapshot.data()!['toAddress_subdistrict'],
                snapshot.data()!['toAddress_district'],
                snapshot.data()!['toAddress_city'],
                snapshot.data()!['toAddress_postCode'],
                snapshot.data()!['toAddress_phoneNo'],
              );
              usersRef.doc(widget.currentUserId).collection('cart').doc(widget.currentUserId).delete();
            }else{
              updateStock(type,postId, double.parse(weight), quantity);
              pushToPurchase(
                widget.currentUserId.toString(),
                snapshot.data()!['sellerName'],
                snapshot.data()!['sellerId'],
                postId,
                snapshot.data()!['topicName'],
                snapshot.data()!['breed'],
                snapshot.data()!['imageUrl'],
                snapshot.data()!['price'],
                snapshot.data()!['promo'],
                quantity,
                snapshot.data()!['deliPrice_BuyNow'],
                snapshot.data()!['discount'],
                snapshot.data()!['total'],
                snapshot.data()!['dispatchDate'],
                snapshot.data()!['dispatchMonth'],
                snapshot.data()!['dispatchYear'],
                snapshot.data()!['deliMethod_BuyNow'],
                type,
                snapshot.data()!['subType'],
                snapshot.data()!['breed'],
                '0',
                snapshot.data()!['destination'],
                snapshot.data()!['transactionId'],
                MoneySpaceTransactionId,
                snapshot.data()!['paymentName'],
                snapshot.data()!['issueBank'],
                snapshot.data()!['paymentNumber'],
                snapshot.data()!['paymentType'],
                snapshot.data()!['userName'],
                snapshot.data()!['promoCode'],
                snapshot.data()!['rp_BankName'],
                snapshot.data()!['rp_AccountName'],
                snapshot.data()!['rp_AccountNumber'],
                snapshot.data()!['toAddress_name'],
                snapshot.data()!['toAddress_houseNo'],
                snapshot.data()!['toAddress_moo'],
                snapshot.data()!['toAddress_road'],
                snapshot.data()!['toAddress_subdistrict'],
                snapshot.data()!['toAddress_district'],
                snapshot.data()!['toAddress_city'],
                snapshot.data()!['toAddress_postCode'],
                snapshot.data()!['toAddress_phoneNo'],
              );
              usersRef.doc(widget.currentUserId).collection('cart').doc(widget.currentUserId).delete();
            }
          }else{
            usersRef.doc(widget.currentUserId).collection('cart').doc(widget.currentUserId).delete();
          }
          return APIRequest<List<TransStatChck_MoneySpace_Response>>(
              error: true,
              errorMessage: 'Create Payment fail'
          );
        }
        );
      }
    });
  }

  retrieveToken()async{
    _getToken = await FirebaseMessaging.instance.getToken();
  }

  getNotiCounter()async{
    await usersRef.doc(widget.currentUserId).collection('deliveryStatusForBuyer').where('status',isEqualTo: 'เตรียมจัดส่ง').get().then((snap){
      snap.size > 0? itemToPrepare = snap.size:itemToPrepare = 0;
    });
    await usersRef.doc(widget.currentUserId).collection('deliveryStatusForBuyer').where('status',isEqualTo: 'กำลังขนส่ง').get().then((snap){
      snap.size > 0? itemDispatched = snap.size:itemDispatched = 0;
    });
    await usersRef.doc(widget.currentUserId).collection('deliveryStatusForBuyer').where('status',isEqualTo: 'การันตี').get().then((snap){
      snap.size > 0? itemGuarantee = snap.size:itemGuarantee = 0;
    });
    await usersRef.doc(widget.currentUserId).collection('deliveryStatusForBuyer').where('status',isEqualTo: 'รอการรีวิว').get().then((snap){
      snap.size > 0? itemToReview = snap.size:itemToReview = 0;
    });
  }

  checkAdmin()async{
    setState(() {
      isLoading = true;
    });

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });

    _pageIndex = widget.pageIndex;
    checkAdmin();
    getNotiCounter();
    retrieveToken();
    //###############################################
    // Uncomment this section when want to show shop
    getInfoFromCart();
    _checkTransaction();
    // ###############################################
    pageController = PageController(initialPage: _pageIndex, keepPage: true);

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        total_Noti = itemToPrepare + itemDispatched + itemGuarantee + itemToReview;
        isLoading = false;
      });
    });
  }

  onPageChange(int pageIndex){
    setState(() {
      this._pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex){
    pageController.animateToPage(
        pageIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut);
  }

  SafeArea buildAuthScreen() {
    getNotiCounter();
    return SafeArea(
      child: Scaffold(
          body: PageView(
            children: <Widget>[
              shop(userid: widget.currentUserId.toString()),
              conditionBuyer(toShowBackArrow: false),
              notification(
                userId: widget.currentUserId,
                itemToPrepare: itemToPrepare,
                itemDispatched: itemDispatched,
                itemGuarantee: itemGuarantee,
                itemToReview: itemToReview,
              ),
              profileWithoutPet(userId: widget.currentUserId)
            ],
            controller: pageController,
            onPageChanged: onPageChange,
            physics: NeverScrollableScrollPhysics(),
          ),
          floatingActionButton: _pageIndex == 3 && widget.currentUserId == null?SizedBox():Padding(
            padding: const EdgeInsets.all(1.0),
            child: FloatingActionButton(
              onPressed: ()=> widget.currentUserId == null?
              Navigator.push(context, MaterialPageRoute(builder: (contetxt)=> authScreenWithoutPet(pageIndex: 3))):
              Navigator.push(context, MaterialPageRoute(builder: (contetxt)=> addSellPost(userId: widget.currentUserId.toString()))),
              child: Icon(Icons.add,color: Colors.white),
              backgroundColor: themeColour,
              tooltip: 'Increment',
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
          bottomNavigationBar: BottomAppBar(
            shape: CircularNotchedRectangle(),
            notchMargin: _pageIndex == 3 && widget.currentUserId == null?0:8.0,
            clipBehavior: Clip.antiAlias,
            child: Container(
              decoration: BoxDecoration(
                color: themeColour,
                border: Border(top: BorderSide(width: 0.4,color: Colors.black)
                ),
              ),
              child: _pageIndex == 3 && widget.currentUserId == null?Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(width: 0.001),
                  // Shopping Page
                  IconButton(
                      onPressed: ()=> pageController.jumpToPage(0),
                      icon: _pageIndex ==0?
                      Icon(Icons.shopping_cart, color: Colors.white, size: 32):
                      Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 25)
                  ),

                  IconButton(
                      onPressed: ()=> pageController.jumpToPage(1),
                      icon: _pageIndex ==1?
                      Icon(FontAwesomeIcons.solidQuestionCircle, color: Colors.white, size: 32):
                      Icon(FontAwesomeIcons.questionCircle, color: Colors.white, size: 25)
                  ),

                  // Notification Page
                  Container(
                    width: 58,
                    child: IconButton(
                        onPressed: ()=> pageController.jumpToPage(2),
                        icon: _pageIndex ==2?
                        Stack(
                          children: [
                            Center(
                                child: Icon(FontAwesomeIcons.solidBell, color: Colors.white, size: 28)),
                            Positioned(
                                top: 0,right: 0,
                                child: total_Noti == 0? SizedBox():Container(
                                    width: 18,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.transparent),
                                        color: Colors.yellow
                                    ),
                                    child: Center(
                                        child: Text(total_Noti.toString(),
                                            style: TextStyle(color: Colors.black,fontSize: 15))
                                    )
                                )
                            )
                          ],):
                        Stack(children: [
                          Positioned(
                              top: 0,right: 0,
                              child: total_Noti == 0? SizedBox():Container(
                                  width: 16,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.transparent),
                                      shape: BoxShape.circle,
                                      color: Colors.yellow
                                  ),
                                  child: Center(
                                      child: Text(total_Noti.toString(),
                                          style: TextStyle(color: Colors.black,fontSize: 13)))
                              )
                          ),
                          Center(
                              child: Icon(FontAwesomeIcons.bell, color: Colors.white, size: 25))
                        ],)
                    ),
                  ),

                  // chats Page
                  IconButton(
                      onPressed: ()=> pageController.jumpToPage(3),
                      icon: _pageIndex ==3?
                      Icon(FontAwesomeIcons.userAlt, color: Colors.white, size: 28):
                      Icon(FontAwesomeIcons.user, color: Colors.white, size: 25)
                  ),
                  SizedBox(width: 0.001),
                ],
              ):Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(width: 0.001),
                  // Shopping Page
                  IconButton(
                      onPressed: ()=> pageController.jumpToPage(0),
                      icon: _pageIndex ==0?
                      Icon(Icons.shopping_cart, color: Colors.white, size: 32):
                      Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 25)
                  ),

                  IconButton(
                      onPressed: ()=> pageController.jumpToPage(1),
                      icon: _pageIndex ==1?
                      Icon(FontAwesomeIcons.solidQuestionCircle, color: Colors.white, size: 32):
                      Icon(FontAwesomeIcons.questionCircle, color: Colors.white, size: 25)
                  ),

                  SizedBox(),
                  SizedBox(),
                  SizedBox(),

                  // Notification Page
                  Container(
                    width: 58,
                    child: IconButton(
                        onPressed: ()=> pageController.jumpToPage(2),
                        icon: _pageIndex ==2?
                        Stack(
                          children: [
                            Center(
                                child: Icon(FontAwesomeIcons.solidBell, color: Colors.white, size: 28)),
                            Positioned(
                                top: 0,right: 0,
                                child: total_Noti == 0? SizedBox():Container(
                                    width: 18,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.transparent),
                                        color: Colors.yellow
                                    ),
                                    child: Center(
                                        child: Text(total_Noti.toString(),
                                            style: TextStyle(color: Colors.black,fontSize: 15))
                                    )
                                )
                            )
                          ],):
                        Stack(children: [
                          Positioned(
                              top: 0,right: 0,
                              child: total_Noti == 0? SizedBox():Container(
                                  width: 16,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.transparent),
                                      shape: BoxShape.circle,
                                      color: Colors.yellow
                                  ),
                                  child: Center(
                                      child: Text(total_Noti.toString(),
                                          style: TextStyle(color: Colors.black,fontSize: 13)))
                              )
                          ),
                          Center(
                              child: Icon(FontAwesomeIcons.bell, color: Colors.white, size: 25))
                        ],)
                    ),
                  ),

                  // chats Page
                  IconButton(
                      onPressed: ()=> pageController.jumpToPage(3),
                      icon: _pageIndex ==3?
                      Icon(FontAwesomeIcons.userAlt, color: Colors.white, size: 28):
                      Icon(FontAwesomeIcons.user, color: Colors.white, size: 25)
                  ),
                  SizedBox(width: 0.001),
                ],
              ),
            ),
          )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return isLoading == true? loading():buildAuthScreen();
  }
}
