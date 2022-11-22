import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:multipawmain/authCheck.dart';
import 'package:multipawmain/database/breedDatabase.dart';
import 'package:multipawmain/database/posts.dart';
import 'package:multipawmain/pages/qrprom_payment.dart';
import 'package:multipawmain/setting/profileInfo/address/address.dart';
import 'package:multipawmain/setting/profileInfo/address/editAddress.dart';
import 'package:multipawmain/setting/profileInfo/payment/payment.dart';
import 'package:multipawmain/pages/thankyou.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:intl/intl.dart';
import 'package:date_format/date_format.dart';
import 'package:multipawmain/support/payment/api_request.dart';
import 'package:multipawmain/support/payment/moneyspace_model.dart';
import 'package:multipawmain/support/payment/service.dart';
import 'package:nanoid/nanoid.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

DateTime now = DateTime.now();
int now_MilliEpoch = now.millisecondsSinceEpoch;
bool isTablet = false;
bool okToProceed = false;

class checkOut extends StatefulWidget {
  final String userId,userName;
  final fromPage,type,sellerId,postId,dispatchDate,dispatchMonth,dispatchYear,forbidAirTransport,subType;

  final sellerName,imageUrl,topicName,breed,price,promo,quantity,deliMethod,deliPrice,brand;
  final weight;
  checkOut({
    required this.userId,
    required this.userName,
    this.fromPage,
    this.type,
    this.subType,
    this.sellerId,
    this.postId,

    this.sellerName,
    this.imageUrl,
    this.topicName,
    this.breed,
    this.price,
    this.promo,
    this.quantity,
    this.deliMethod,
    this.deliPrice,
    this.dispatchDate,
    this.dispatchMonth,
    this.dispatchYear,

    this.weight,
    this.brand,

    this.forbidAirTransport,
  });

  @override
  _checkOutState createState() => _checkOutState();
}

class _checkOutState extends State<checkOut> {
  TextEditingController promoController = new TextEditingController();
  bool isLoading = false;
  String? name,houseNo,moo,road,subdistrict,district,city,postCode,phoneNo,destination;
  String? paymentType, sensor_craditCard,senser_bankAccount,email;
  int? deliFee;
  bool destinationCheck = true;
  bool pomoToshow = true;

  String? deliMethod_BuyNow;
  int deliPrice_BuyNow = 0;

  String? cardName,cardNumber,cardType,cvv,exDate,issueBank;
  List<String> deliList = [];
  int deliPrice = 0;
  int total = 0;
  int final_price = 0;
  int totalDeliFee_Pets = 0;
  int totalDeliFee_Foods = 0;
  int minSpending = 0;
  int maxDiscount = 0;
  int pctDiscount = 0;
  String? type;
  int campaignStartTime = 0;
  int campaignEndTime = 0;
  int comm = 20;

  List<int> lst_deli_Pets = [];
  List<int> lst_deli_Foods = [];
  List<int> lst_total = [];
  List<int> lst_discount = [];
  List<String> cartType = [];
  List<itemInCart> itemCart = [];
  String reason = '';
  int discount = 0;

  List<bankAccountPaymentMethod> registedBankAccountList= [];
  List<creditCardPaymentMethod> registedCreditCardList = [];

  // Create Payment
  late APIRequest<List<CreateTransactionStatusChecking>> _responseFromCreatePayment;
  // Check Payment Status by orderID
  late APIRequest<List<TransStatChck_MultiPaws_Response>> _responseFromPaymentCheckingorderID;



  getBasicInfo()async{
    await usersRef.doc(widget.userId).get().then((snpashot){
      email = snpashot.data()!['email'];
    });
  }

  getPostIdAndPostType()async{
    await usersRef.doc(widget.userId).collection('myCart').where('check',isEqualTo: true).get().then((snapshot){
      snapshot.docs.forEach((doc) {

        cartType.add(doc.data()['type']);

        if(doc.data()['type'] == 'pet'){
          postsPuppyKittenRef.doc(doc.data()['postid']).get().then((snapshot){
            if(snapshot.data()!['active'] == false || !snapshot.exists){
              usersRef.doc(widget.userId).collection('myCart').doc(doc.data()['postid']).delete();
              cartType.removeLast();
              setState(() {
                showAlertDialog(context);
              });
            }
          });
        }

        if(doc.data()['type'] == 'Cat Food' || doc.data()['type'] == 'Dog Food'){

          postsFoodRef.doc(doc.data()['postid']).get().then((snapshot1){
            if(doc.data()['weight'] == snapshot1.data()!['weight1'] && snapshot1.data()!['stock1'] - doc.data()['quantity'] <0){
              cartType.removeLast();
              usersRef.doc(widget.userId).collection('myCart').doc('${doc.data()['postid']}${doc.data()['weight']}').delete();
              setState(() {
                showAlertDialog(context);
              });
            }else if(doc.data()['weight'] == snapshot1.data()!['weight2'] && snapshot1.data()!['stock2'] - doc.data()['quantity']<0){
              cartType.removeLast();
              usersRef.doc(widget.userId).collection('myCart').doc('${doc.data()['postid']}${doc.data()['weight']}').delete();
              setState(() {
                showAlertDialog(context);
              });
            }else if(doc.data()['weight'] == snapshot1.data()!['weight3'] && snapshot1.data()!['stock3'] - doc.data()['quantity']<0){
              cartType.removeLast();
              usersRef.doc(widget.userId).collection('myCart').doc('${doc.data()['postid']}${doc.data()['weight']}').delete();
              setState(() {
                showAlertDialog(context);
              });
            }else if(doc.data()['weight'] == snapshot1.data()!['weight4'] && snapshot1.data()!['stock4'] - doc.data()['quantity']<0){
              cartType.removeLast();
              usersRef.doc(widget.userId).collection('myCart').doc('${doc.data()['postid']}${doc.data()['weight']}').delete();
              setState(() {
                showAlertDialog(context);
              });
            }else if(doc.data()['weight'] == snapshot1.data()!['weight5'] && snapshot1.data()!['stock5'] - doc.data()['quantity']<0){
              cartType.removeLast();
              usersRef.doc(widget.userId).collection('myCart').doc('${doc.data()['postid']}${doc.data()['weight']}').delete();
              setState(() {
                showAlertDialog(context);
              });
            }else if(doc.data()['weight'] == snapshot1.data()!['weight6'] && snapshot1.data()!['stock6'] - doc.data()['quantity']<0){
              cartType.removeLast();
              usersRef.doc(widget.userId).collection('myCart').doc('${doc.data()['postid']}${doc.data()['weight']}').delete();
              setState(() {
                showAlertDialog(context);
              });
            }
          });
        }
      });
    });
  }

  updateActive(String postId, String type)async{
    if(type == 'pet'){
      await postsPuppyKittenRef.doc(postId).update({
        'active':false,
      });
    }
  }

  checkStock(String type,String postId, double weight, int qty)async{
    int residual;
    if(type == 'foods'){
      await postsFoodRef.doc(postId).get().then((snapshot){
        if(weight == snapshot.data()!['weight1']){
          residual = snapshot.data()!['stock1'] - qty;
          if(residual<0){
            setState(() {
              showAlertDialog(context);
            });
          }
        }else if(weight == snapshot.data()!['weight2']){
          residual = snapshot.data()!['stock2'] - qty;
          if(residual<0){
            setState(() {
              showAlertDialog(context);
            });
          }
        }else if(weight == snapshot.data()!['weight3']){
          residual = snapshot.data()!['stock3'] - qty;
          if(residual<0){
            setState(() {
              showAlertDialog(context);
            });
          }
        }else if(weight == snapshot.data()!['weight4']){
          residual = snapshot.data()!['stock4'] - qty;
          if(residual<0){
            setState(() {
              showAlertDialog(context);
            });
          }
        }else if(weight == snapshot.data()!['weight5']){
          residual = snapshot.data()!['stock5'] - qty;
          if(residual<0){
            setState(() {
              showAlertDialog(context);
            });
          }
        }else if(weight == snapshot.data()!['weight6']){
          residual = snapshot.data()!['stock6'] - qty;
          if(residual<0){
            setState(() {
              showAlertDialog(context);
            });
          }
        }else{
          okToProceed = true;
        }
      });
    }
  }

  void _addToStorage(List<String> lst) async {
    const storage = FlutterSecureStorage();
    List<String> listviewerbulderstring = lst;
    await storage.write(key: 'listOfItem', value: jsonEncode(listviewerbulderstring));
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
                    'userId': widget.userId,
                    'comm': comm,
                    'paymentName': registedBankAccountList.length == 0? registedCreditCardList[0].cardName: registedBankAccountList[0].accountName,
                    'issueBank': registedBankAccountList.length == 0? registedCreditCardList[0].issueBank: registedBankAccountList[0].bankName,
                    'paymentNumber' : registedBankAccountList.length == 0? registedCreditCardList[0].cardNumber: registedBankAccountList[0].accountNumber,
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
                    'toAddress_name':name,
                    'toAddress_houseNo':houseNo == null?'0':houseNo,
                    'toAddress_moo':moo == null? '0': moo,
                    'toAddress_road':road == null? '0': road,
                    'toAddress_subdistrict':subdistrict,
                    'toAddress_district':district,
                    'toAddress_city':city,
                    'toAddress_postCode':postCode,
                    'toAddress_phoneNo':phoneNo,
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

    await usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('bankAccount').where('refundAccount',isEqualTo: true).get().then((snapshot){
      snapshot.docs.forEach((doc) {
        usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('bankAccount').doc(doc.id).get().then((snap){
          buyerOnPrepareRef.doc(new_postId).set(
              {
                'type': type,
                'seller': seller,
                'sellerId': sellerId,
                'userId': widget.userId,
                //username == BuyerName
                'userName': widget.userName,
                'topic': topic,
                'breed': type == 'pet'? breed:brand,
                'image': img,
                'price': price,
                'promo': promo,
                'weight': weight,
                'quantity':quantity,
                'deliPrice': deliPrice,
                'discount': discount,
                'promotionCode': promoController.text,
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
                'rp_BankName': registedBankAccountList.length == 0? snap.data()!['bankName']:registedBankAccountList[0].bankName,
                'rp_AccountName': registedBankAccountList.length == 0? snap.data()!['title']+' '+snap.data()!['accountFirstName']+' '+snap.data()!['accountLastName']:registedBankAccountList[0].accountName,
                'rp_AccountNumber': registedBankAccountList.length == 0? snap.data()!['accountNumber']: registedBankAccountList[0].accountNumber,

                'toAddress_name':name,
                'toAddress_houseNo':houseNo == null?'0':houseNo,
                'toAddress_moo':moo == null? '0': moo,
                'toAddress_road':road == null? '0': road,
                'toAddress_subdistrict':subdistrict,
                'toAddress_district':district,
                'toAddress_city':city,
                'toAddress_postCode':postCode,
                'toAddress_phoneNo':phoneNo,
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
          'message': '${widget.userName} ได้ซื้อสัตว์เลี้ยงพันธุ์${breed}ของคุณแล้ว กรุณาเตรียมจัดส่งน้องในวันที่ ${date} ${monthList[month]} ${year}-${topic}',
          'type': 'alert',
          'timestamp': DateTime.now()
          });
        });
      });
    }
  }

  getDeliveryAddress()async{
    await usersRef.doc(widget.userId).collection('deliveryAddress').where('default',isEqualTo: true).get().then((snapshot){
      if(snapshot.size>0){
        snapshot.docs.forEach((snap) {
          name = snap.data()['name'];
          houseNo = snap.data()['houseNo'];
          moo = snap.data()['moo'];
          road = snap.data()['road'];
          subdistrict = snap.data()['subdistrict'];
          district = snap.data()['district'];
          city = snap.data()['city'];
          postCode = snap.data()['postCode'];
          phoneNo = snap.data()['phoneNo'];
        });
        refreshTotalDeliveryFeeForFoods();
      }else{
        usersRef.doc(widget.userId).collection('deliveryAddress').get().then((snap){
          if(snap.size>0){
            var documentId = snap.docs.first;
            usersRef.doc(widget.userId).collection('deliveryAddress').doc(documentId.id).update(
                {
                  'default': true
                });
          }else{
            Navigator.push(context, MaterialPageRoute(builder: (context)=>editAddress(userId: widget.userId,type: 'เพิ่มสถานที่จัดส่ง')));
          }
        });

      }
    });
  }

  getInfoFromCart()async{
    await usersRef.doc(widget.userId).collection('myCart').get().then((snapshot){
      snapshot.docs.forEach((doc) {
        doc.data()['check'] == true?itemCart.add(
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
            )):null;
      });
    });
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

  deliveryPriceCalculator(double weight){
    double fee;
    fee = (0.0199 * pow(weight,2))+(13.759 * weight)-13.444;
    fee<35?fee = 35: fee = fee;
    return fee;
  }
  
  getPaymentMethod()async{
    await usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('bankAccount').get().then((snapshot1){
      if(snapshot1.size == 0){
        usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('creditCard').get().then((snapshot2){
          if(snapshot2.size == 0){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>payment(userId: widget.userId,fromCheckOut: true)));
          }
        });
      }
    });

    await usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('bankAccount').where('refundAccount',isEqualTo: true).get().then((snap1){
      if(snap1.size > 0){
        snap1.docs.forEach((doc) {
          registedBankAccountList.add(bankAccountPaymentMethod.fromDocument(doc));
        });
        paymentType = 'bankAccount';
        senser_bankAccount = registedBankAccountList[0].accountNumber.toString();
        senser_bankAccount = senser_bankAccount!.substring(senser_bankAccount!.length - 4);
      }
    });

    await usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('creditCard').where('default',isEqualTo: true).get().then((snap2){
      if(snap2.size > 0){
        snap2.docs.forEach((doc) {
          registedCreditCardList.add(creditCardPaymentMethod.fromDocument(doc));
        });
        paymentType = 'creditCard';
        sensor_craditCard = registedCreditCardList[0].cardNumber.toString();
        sensor_craditCard = sensor_craditCard!.substring(sensor_craditCard!.length - 4);
      }
    });
  }

  getDeliMethod(String sellerId)async{
    await usersRef.doc(sellerId).collection('storeLocationAndDeliveryOption').doc(sellerId).get().then((snap){
      if(snap.exists){
        snap.data()!['selfPickup'] == true? deliList.add('รับเองที่ฟาร์ม'):null;
        snap.data()!['airDelivery'] == true? deliList.add('ส่งทางอากาศ (รับที่สนามบิน)'):null;
      }
    });
  }

  refreshTotalDeliveryFeeForFoods()async{
    lst_deli_Foods.clear();
    await usersRef.doc(widget.userId).collection('myCart').where('check',isEqualTo: true).where('type',isEqualTo: 'Dog Food').get().then((snapshot){
      snapshot.docs.forEach((snap) {
        double deliFee_forCal = deliveryPriceCalculator(snap.data()['weight'] * snap.data()['quantity']);
        deliFee = deliFee_forCal.round();
        usersRef.doc(widget.userId).collection('myCart').doc(snap.id).update(
            {
              'deliPrice': deliFee
            });
        lst_deli_Foods.add(deliFee!);
      });
    });


    await usersRef.doc(widget.userId).collection('myCart').where('check',isEqualTo: true).where('type',isEqualTo: 'Cat Food').get().then((snapshot){
      snapshot.docs.forEach((snap) {
        double deliFee_forCal = deliveryPriceCalculator(snap.data()['weight'] * snap.data()['quantity']);
        deliFee = deliFee_forCal.round();
        usersRef.doc(widget.userId).collection('myCart').doc(snap.id).update(
            {
              'deliPrice': deliFee
            });
        lst_deli_Foods.add(deliFee!);
      });
    });

    totalDeliFee_Foods = lst_deli_Foods.reduce((a, b) => a+b);
  }

  getDeliveryFeeForFoodsBuyNow(){
    double deliFee_forCal = deliveryPriceCalculator(double.parse(widget.weight) * widget.quantity);
    deliPrice_BuyNow = deliFee_forCal.round();
  }

  refreshTotalDeliveryFeeForPets()async{
    lst_deli_Pets.clear();
    await usersRef.doc(widget.userId).collection('myCart').where('check',isEqualTo: true).where('type',isEqualTo: 'pet').get().then((snapshot){
      snapshot.docs.forEach((snap) {
        lst_deli_Pets.add(snap.data()['deliPrice']);
      });
      totalDeliFee_Pets = lst_deli_Pets.reduce((a, b) => a+b);
    });
  }

  getSubTotal()async{
    lst_total.clear();
    await usersRef.doc(widget.userId).collection('myCart').where('check',isEqualTo: true).get().then((snapshot){
      snapshot.docs.forEach((snap) {
        if(snap.data()['promo'] == 0){
          int subTotal = snap.data()['price']*snap.data()['quantity'];
          lst_total.add(subTotal);
        }else{
          int subTotal = snap.data()['promo']*snap.data()['quantity'];
          lst_total.add(subTotal);
        }
      });
    });
    total = lst_total.reduce((a, b) => a+b);
  }

  getSubTotalFromCart(int pctDiscount,int maxDiscount, String type)async{
    lst_discount.clear();
    int toDiscount = 0;
    int sumDiscount = 0;

    await usersRef.doc(widget.userId).collection('myCart').where('check',isEqualTo: true).get().then((snapshot){
      snapshot.docs.forEach((snap) {
        String dtype = snap.data()['type'] == 'Cat Food' || snap.data()['type'] == 'Dog Food'?'foods':'pet';
        sumDiscount = lst_discount.length == 0?0:lst_discount.reduce((a,b) => a+b);

        if(dtype == type){
          int subTotal = snap.data()['promo'] == 0
              ? snap.data()['price']*snap.data()['quantity']
              : snap.data()['promo']*snap.data()['quantity'];

          subTotal*0.01* pctDiscount > maxDiscount
              ? toDiscount = maxDiscount
              : toDiscount = (subTotal*0.01* pctDiscount).round();

          if(reason == 'coupon' && sumDiscount + toDiscount <= maxDiscount){
            lst_discount.add(toDiscount);
          }else if(reason == 'coupon' && sumDiscount + toDiscount > maxDiscount){
            int residual = maxDiscount - sumDiscount;
            lst_discount.add(residual);
          }
        }else{
          lst_discount.add(0);
        }
      });

      if(lst_discount.isNotEmpty){
        setState(() {
          discount = lst_discount.reduce((a,b) => a+b);
          discount > maxDiscount.toInt()? discount = maxDiscount.toInt():discount = lst_discount.reduce((a,b) => a+b);
          setState(() {
            final_price = total + totalDeliFee_Pets + totalDeliFee_Foods - discount;
          });
        });
      }
    });
  }

  deleteItemInCart()async{
    await usersRef.doc(widget.userId).collection('myCart').where('check',isEqualTo: true).get().then((snapshot){
      snapshot.docs.forEach((doc) {
        usersRef.doc(widget.userId).collection('myCart').doc(doc.id).delete();
      });
    });
    Navigator.push(context, MaterialPageRoute(builder: (context)=>thankyou(userId: widget.userId,amount: final_price.toStringAsFixed(2))));
  }
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      isLoading = true;
      SizerUtil.deviceType == DeviceType.tablet?isTablet = true:isTablet = false;
    });

    getBasicInfo();
    widget.fromPage == 'fromCart'? getPostIdAndPostType():null;
    widget.fromPage == 'fromCart' ? getSubTotal():null;

    widget.fromPage != 'fromCart'? deliMethod_BuyNow = widget.deliMethod:null;
    widget.fromPage != 'fromCart' && widget.type == 'foods' ?getDeliveryFeeForFoodsBuyNow():null;

    getPaymentMethod();
    getDeliveryAddress();
    widget.fromPage == 'fromCart'?refreshTotalDeliveryFeeForPets():null;

    Future.delayed(const Duration(milliseconds: 1000), () {
      widget.fromPage == 'fromCart'?getInfoFromCart():null;
      setState(() {
        widget.fromPage == 'fromCart'
            ?final_price = total + totalDeliFee_Pets + totalDeliFee_Foods - discount

            :widget.fromPage == 'buyNow' && widget.type == 'pet'
            ?final_price = widget.price - discount

            :widget.fromPage == 'buyNow' && widget.type == 'foods' && widget.promo == 0
            ?final_price = widget.quantity * widget.price + deliPrice_BuyNow - discount

            :widget.fromPage == 'buyNow' && widget.type == 'foods' && widget.promo != 0
            ?final_price = widget.quantity * widget.promo + deliPrice_BuyNow - discount
            :null;

        isLoading = false;
      });
    });
  }

  checkOutMethodFood(String firstName,String lastName,String transactionId)async{
    setState(() {
      isLoading = true;
    });
    _responseFromCreatePayment = await Service().createPaymentClass(
        firstName,
        lastName,
        email!,
        final_price.toStringAsFixed(2),
        transactionId
    );
    setState(() {
      isLoading = false;
    });
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context)=>paymentPage(
      qrprom_url: _responseFromCreatePayment.body![0].image_qrprom,
      transactionID: _responseFromCreatePayment.body![0].transactionId,
      final_price: final_price.toStringAsFixed(2),
    )));

    // If payment success, can proceed this part
    // return TRUE = transaction completed return FALSE = the user cxl payment.
    if(result == true){
      updateStock(widget.type,widget.postId, double.parse(widget.weight), widget.quantity);
      pushToPurchase(
        widget.userId,
        widget.sellerName.toString(),
        widget.sellerId,
        widget.postId ,
        widget.topicName,
        '${widget.weight}kg',
        widget.imageUrl,
        widget.price,
        widget.promo,
        widget.quantity,
        deliPrice_BuyNow,
        discount,
        widget.promo!=0 ? (widget.promo * widget.quantity) + deliPrice_BuyNow - discount
            : (widget.price * widget.quantity) + deliPrice_BuyNow - discount,
        0,
        0,
        0,
        'Standard Delivery',
        widget.type,
        widget.subType,
        widget.brand,
        widget.weight,
        '0',
        transactionId,
        _responseFromCreatePayment.body![0].transactionId,
      );

      discount == 0?null: updateCouponUsed(
        promoController.text,
        pctDiscount,
        type.toString(),
        discount,
        minSpending,
        maxDiscount,
        final_price,
        campaignStartTime,
        campaignEndTime,
      );

      Navigator.push(context, MaterialPageRoute(builder: (context)=>thankyou(userId: widget.userId,amount: final_price.toStringAsFixed(2))));
    }
  }

  updateCouponUsed(
      String couponId,
      int pctDiscount,
      String type,
      int discount,
      int minSpending,
      int maxDiscount,
      int totalSpending,
      int startTime,
      int endTime
      )async{
    await promotionIndexRef.doc(couponId+widget.userId).set({
      'timestamp': now_MilliEpoch,
      'postId': couponId,
      'type': type,
      'userId': widget.userId,
      'discount' : discount,
      'pctDiscount': pctDiscount,
      'minSpending': minSpending,
      'maxDiscount': maxDiscount,
      'final_price': totalSpending,
      'startTime': startTime,
      'endTime': endTime
    });
    
    await promotionRef.doc('123456789').collection('FoodPromotion').doc(couponId).get().then((snapshot){
      if(snapshot.exists){
        int remained = snapshot.data()!['remain'];
        promotionRef.doc('123456789').collection('FoodPromotion').doc(couponId).update(
            {
              'remain' : remained - 1
            });
      }else{
        promotionRef.doc('123456789').collection('PetPromotion').doc(couponId).get().then((snapshot){
          int remained = snapshot.data()!['remain'];
          promotionRef.doc('123456789').collection('PetPromotion').doc(couponId).update(
              {
                'remain' : remained - 1
              });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    checkDiscount(String code)async{
      await promotionIndexRef.where('postId',isEqualTo: code).where('userId',isEqualTo: widget.userId).get().then((snp){
        if(snp.size>0){
          setState(() {
            reason = 'คุณใช้ code นี้ไปแล้ว';
            discount = 0;
          });
        }else{
          promotionRef.doc('123456789').collection('PetPromotion').where('postid',isEqualTo: code).get().then((snapshot){
            if(snapshot.size>0){
              snapshot.docs.forEach((data) {
                promotionRef.doc('123456789').collection('PetPromotion').doc(data.id).get().then((snap1){
                  if(snap1.data()!['endTime']>now_MilliEpoch && snap1.data()!['startTime'] < now_MilliEpoch && snap1.data()!['remain']>0){
                    reason = 'coupon';
                    minSpending = snap1.data()!['minSpend'];
                    maxDiscount = snap1.data()!['maxDiscount'];
                    pctDiscount = snap1.data()!['pctDiscount'];
                    campaignStartTime = snap1.data()!['startTime'];
                    campaignEndTime = snap1.data()!['endTime'];
                    type = 'pet';

                    // ====================================================================
                    if(widget.fromPage == 'buyNow' && widget.type == type){
                      if(widget.price > minSpending){
                        int total  = widget.promo!=0? widget.promo * widget.quantity: widget.price * widget.quantity;
                        if(total > minSpending){
                          setState(() {
                            discount = (total * 0.01 * pctDiscount).round();
                            if(discount > maxDiscount){
                              discount = maxDiscount;

                            }
                          });
                        }
                      }

                    }else if(widget.fromPage == 'fromCart'){
                      getSubTotalFromCart(pctDiscount, maxDiscount, type.toString());
                    }else{
                      setState(() {
                        reason = 'ไม่พบ code นี้ในระบบ';
                        discount = 0;
                      });
                    }
                  }else if(snap1.data()!['remain'] == 0){
                    setState(() {
                      reason = 'code หมดแล้ว';
                      discount = 0;
                    });
                  }else{
                    setState(() {
                      reason = 'ไม่พบ code นี้ในระบบ';
                      discount = 0;
                    });
                  }
                });
              });
            }else{
              promotionRef.doc('123456789').collection('FoodPromotion').where('postid',isEqualTo: code).get().then((snapshot){
                if(snapshot.size>0){
                  snapshot.docs.forEach((data) {
                    promotionRef.doc('123456789').collection('FoodPromotion').doc(data.id).get().then((snap1){
                      if(snap1.data()!['endTime']>now_MilliEpoch && snap1.data()!['startTime'] < now_MilliEpoch && snap1.data()!['remain']>0){
                        reason = 'coupon';
                        minSpending = snap1.data()!['minSpend'];
                        maxDiscount = snap1.data()!['maxDiscount'];
                        pctDiscount = snap1.data()!['pctDiscount'];
                        campaignStartTime = snap1.data()!['startTime'];
                        campaignEndTime = snap1.data()!['endTime'];
                        type = 'foods';

                        // ====================================================================
                        if(widget.fromPage == 'buyNow' && widget.type == type){
                          if(widget.price > minSpending){
                            int total  = widget.promo!=0? widget.promo * widget.quantity: widget.price*widget.quantity;

                            if(total > minSpending){
                              setState(() {
                                discount = (total * 0.01 * pctDiscount).round();
                                if(discount > maxDiscount){
                                  discount = maxDiscount;
                                }
                              });
                            }
                          }
                        }else if(widget.fromPage == 'fromCart'){
                          getSubTotalFromCart(pctDiscount, maxDiscount, type.toString());
                        }
                      }else if(snap1.data()!['remain'] == 0){
                        setState(() {
                          reason = 'code หมดแล้ว';
                          discount = 0;
                        });
                      }else{
                        setState(() {
                          reason = 'ไม่พบ code นี้ในระบบ';
                          discount = 0;
                        });
                      }
                    });
                  });
                }else{
                  setState(() {
                    reason = 'ไม่พบ code นี้ในระบบ';
                    discount = 0;
                  });
                }
              });
            }
          });
        }
      });

      Future.delayed(const Duration(milliseconds: 200), () {

        if(widget.type == 'foods' && widget.promo != 0){
          setState(() {
            final_price = widget.promo * widget.quantity +  totalDeliFee_Foods - discount;
          });
        }else if(widget.type == 'foods' && widget.promo == 0){
          setState(() {
            final_price = widget.price * widget.quantity +  totalDeliFee_Foods - discount;
          });
        }else if(widget.type == 'pet'){
          setState(() {
            final_price = widget.price * widget.quantity +  totalDeliFee_Pets - discount;
          });
        }
      });
    }


    var f = new NumberFormat("#,###", "en_US");

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: appBarWithBackArrow('ชำระเงิน',isTablet),
        body: isLoading == true?loading():ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15,vertical: 15),
              child: InkWell(
                child: isLoading == true?loading():Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    border: Border.all(color: Colors.grey.shade600),
                    color: Colors.white
                  ),
                  child: ListTile(
                    leading: Icon(FontAwesomeIcons.houseUser,color: themeColour,size: 30),
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name.toString(),style: TextStyle(color: Colors.black,fontSize: isTablet?20:15)),
                        Text(phoneNo.toString(),style: TextStyle(color: Colors.grey.shade800,fontSize: isTablet?20:15)),
                        SizedBox(height: isTablet?20:10)
                      ],
                    ),
                    subtitle: moo == '' || moo == '-'?
                    Text('${houseNo} ถ.${road} ต.${subdistrict} อ.${district} จ.${city} ${postCode}',style: TextStyle(fontSize: isTablet?18:13,color: Colors.black),maxLines: 3) :
                    road == '' || road == '-'?
                    Text('${houseNo} ม.${moo} ต.${subdistrict} อ.${district} จ.${city} ${postCode}',style: TextStyle(fontSize: isTablet?18:13,color: Colors.black),maxLines: 3):
                    moo == '' && road == '' || moo == '-' && road == '-'?
                    Text('${houseNo} ต.${subdistrict} อ.${district} จ.${city} ${postCode}',style: TextStyle(fontSize: isTablet?18:13,color: Colors.black),maxLines: 3):
                    Text('${houseNo} ม.${moo} ถ.${road} ต.${subdistrict} อ.${district} จ.${city} ${postCode}',style: TextStyle(fontSize: isTablet?18:13,color: Colors.black),maxLines: 3),
                    trailing: Icon(Icons.arrow_forward_ios,color: themeColour)
                  ),
                ),
                onTap: ()async{
                  final loc = await Navigator.push(context, MaterialPageRoute(builder: (context)=>address(userId: widget.userId)));
                  setState(() {
                    name = loc[0];
                    houseNo = loc[1];
                    moo = loc[2];
                    road = loc[3];
                    subdistrict = loc[4];
                    district = loc[5];
                    city = loc[6];
                    postCode = loc[7];
                    phoneNo = loc[8];

                    Future.delayed(const Duration(milliseconds: 200), () {
                      if(widget.fromPage == 'fromCart'){
                        setState(() {
                          final_price = total + totalDeliFee_Pets + totalDeliFee_Foods - discount;
                        });
                      }else{
                        if(widget.type == 'foods' && widget.promo != 0){
                          setState(() {
                            final_price = widget.promo * widget.quantity +  totalDeliFee_Foods - discount;
                          });
                        }else if(widget.type == 'foods' && widget.promo == 0){
                          setState(() {
                            final_price = widget.price * widget.quantity +  totalDeliFee_Foods - discount;
                          });
                        }else if(widget.type == 'pet'){
                          setState(() {
                            final_price = widget.price * widget.quantity +  totalDeliFee_Pets - discount;
                          });
                        }
                      }
                    });
                  });
                }
              ),
            ),
            widget.fromPage == 'fromCart' ? Column(
                children: [
                StreamBuilder<QuerySnapshot>(
                  stream: usersRef.doc(widget.userId).collection('myCart').where('check',isEqualTo: true).snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

                    if(!snapshot.hasData){
                      return Text('');
                    }
                    return ListView(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        children: snapshot.data!.docs.map((DocumentSnapshot document) {
                          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                          if(data['type']!='pet'){
                            double deliFee_forCal = deliveryPriceCalculator(data['weight'] * data['quantity']);
                            deliFee = deliFee_forCal.round();
                          }
                          return data['type'] == 'pet'
                          //############### PET Section ################

                              ?Container(
                            color: Colors.white,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  color: Colors.white,
                                  width: MediaQuery.of(context).size.width,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 15.0,right: 15,top: 10),
                                    child: Row(
                                      children: [
                                        Icon(FontAwesomeIcons.store,size: 20,color: Colors.black),
                                        SizedBox(width: 20),
                                        Text(data['sellerName'],style: TextStyle(fontSize: isTablet?20:16))
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
                                        flex: 3,
                                        child: Image.network(data['imageUrl'],height: 100)
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
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(data['topicName'],style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold),maxLines: 2),
                                                Text(data['breed'],style: TextStyle(color: Colors.grey.shade900,fontSize: isTablet?20:16,),maxLines: 2),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    Text('฿ ${f.format(data['price'])}',style: data['promo'] != 0
                                                        ?TextStyle(decoration:TextDecoration.lineThrough):TextStyle()),
                                                    Visibility(
                                                      visible: data['promo']!=0,
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(left: 5.0),
                                                        child: Text('฿ ${f.format(data['promo'])}',style: TextStyle(color: themeColour)),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 15.0),
                                                  child: Text('จำนวน ${data['stock']}',style: TextStyle(fontSize: isTablet?20:16)),
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
                                Container(
                                  alignment: Alignment.centerLeft,
                                  height: isTablet?50:30,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: themeColour),
                                    color: themeColour
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                    child: Text('ตัวเลือกการขนส่ง',style: TextStyle(color: Colors.white,fontSize: isTablet?20:16)),
                                  ),
                                ),
                                InkWell(
                                  child: Container(
                                    color: Colors.red.shade50,
                                    height: 60,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 15.0),
                                          child: Text(data['deliMethod'],style: TextStyle(color: Colors.black,fontSize: isTablet?20:16)),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(right: 15),
                                          child: Row(
                                            children: [
                                              data['deliPrice'] == 0? Text('ไม่มีค่าใช้จ่าย',style: TextStyle(fontSize: isTablet?20:16)):Text('฿ ${data['deliPrice']}',style: TextStyle(fontSize: isTablet?20:16)),
                                              SizedBox(width: 10),
                                              data['price'] == 0 || data['forbidAirTransport'] == true?SizedBox():Icon(Icons.arrow_forward_ios,color: themeColour)
                                            ],
                                          ),
                                        )
                                      ],
                                    )
                                  ),
                                  onTap: data['price'] == 0 || data['forbidAirTransport'] == true?(){}:()async{
                                    await getDeliMethod(data['id']);
                                    final result = await Navigator.push(context, MaterialPageRoute(builder: (context)=>selectedPage(text: 'ตัวเลือกการจัดส่ง', list: deliList)));
                                    deliList.clear();
                                    setState(() {
                                      if(result == 'รับเองที่ฟาร์ม'){
                                        destination = '0';
                                        usersRef.doc(widget.userId).collection('myCart').doc(data['postid']).update(
                                            {
                                              'deliMethod' : result == null? 'รับเองที่ฟาร์ม':result,
                                              'deliPrice' : result == null ? 0:0,
                                              'airPickUpShow': false,
                                              'deliAirport': '0'
                                            });
                                        for(var i = 0; i<itemCart.length; i++){
                                          if(itemCart[i].postId == data['postid'] && itemCart[i].type == 'pet'){
                                            itemCart[i].deliMethod = result;
                                            itemCart[i].destination = '0';
                                            destination = '0';
                                          }
                                        }
                                        refreshTotalDeliveryFeeForPets();
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
                                        Future.delayed(const Duration(milliseconds: 200), () {
                                          setState(() {
                                            final_price = total + totalDeliFee_Pets + totalDeliFee_Foods - discount;
                                          });
                                        });
                                      }else{
                                        usersRef.doc(widget.userId).collection('myCart').doc(data['postid']).update(
                                            {
                                              'deliMethod' : result == null? 'รับเองที่ฟาร์ม':result,
                                              'deliPrice' : 1500,
                                              'airPickUpShow': true,
                                            });
                                        for(var i = 0; i<itemCart.length; i++){
                                          if(itemCart[i].postId == data['postid'] && itemCart[i].type == 'pet'){
                                            itemCart[i].deliMethod = result;
                                          }
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
                                        refreshTotalDeliveryFeeForPets();
                                        Future.delayed(const Duration(milliseconds: 200), () {
                                          setState(() {
                                            final_price = total + totalDeliFee_Pets + totalDeliFee_Foods - discount;
                                          });
                                        });
                                      }
                                    });
                                    deliList = [];
                                  },
                                ),
                                data['airPickUpShow'] == true ?Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                  child: Divider(color: themeColour),
                                ):SizedBox(),
                                data['airPickUpShow'] == true?InkWell(
                                  child: Container(
                                      color: Colors.red.shade50,
                                      height: 60,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(left: 15.0,top: 10,bottom: 10),
                                                child: destination == null || data['deliAirport'] == '0' || data['deliAirport'] == ''
                                      ?Text('โปรดเลือดสนามบินปลายทาง',style: TextStyle(color: Colors.black,fontSize: isTablet?20:16))
                                                    :Text(destination.toString(),style: TextStyle(color: Colors.black,fontSize: isTablet?20:16)),
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(right: 15),
                                                child: Icon(Icons.arrow_forward_ios,color: themeColour),
                                              )
                                            ],
                                          ),
                                        ],
                                      )
                                  ),
                                  onTap: ()async {
                                    final result = await Navigator.push(context,
                                        MaterialPageRoute(builder: (context) =>
                                            selectedPageCheckOut(
                                                text: 'เลือกท่าอากาศยานปลายทาง',
                                                list: airportList)));
                                    setState(() {
                                      destination = result;
                                    });
                                    if (data['deliMethod'] == 'ส่งทางอากาศ (รับที่สนามบิน)') {
                                      usersRef.doc(widget.userId).collection('myCart').doc(data['postid']).update({
                                        'deliAirport': destination
                                      });
                                      for (var i = 0; i < itemCart.length; i++) {
                                        if (itemCart[i].postId == data['postid'] && itemCart[i].type == 'pet')
                                        {
                                          itemCart[i].destination = result;
                                        }
                                      }
                                      setState(() {
                                        List<bool> checker = [];
                                        for(var i = 0; i<itemCart.length; i++){
                                          if(itemCart[i].destination == '0'  && itemCart[i].deliMethod == 'ส่งทางอากาศ (รับที่สนามบิน)'
                                              || itemCart[i].destination == null  && itemCart[i].deliMethod == 'ส่งทางอากาศ (รับที่สนามบิน)'){
                                            checker.add(false);
                                          }
                                        }
                                        checker.length > 0 || destination == '0'? destinationCheck = false: destinationCheck = true;
                                      });
                                    }
                                  }):SizedBox(),
                                Padding(
                                  padding: const EdgeInsets.only(right: 15.0,top: 15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text('ยอดรวมสิ้นค้า :',style: TextStyle(fontSize:isTablet?20:16)),
                                      Text('฿ ${f.format(data['stock']*data['price']+data['deliPrice'])}',style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold,color: themeColour))
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                  child: Divider(color: themeColour),
                                )
                              ],
                            ),
                          )

                          //############### FOOD Section ################
                              :Container(
                            color: Colors.white,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  color: Colors.white,
                                  width: MediaQuery.of(context).size.width,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 15.0,right: 15,top: 10),
                                    child: Row(
                                      children: [
                                        Icon(FontAwesomeIcons.store,size: 20,color: Colors.black),
                                        SizedBox(width: 10),
                                        Text(data['sellerName'],style: TextStyle(fontSize: isTablet?20:16))
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
                                        flex: 3,
                                        child: Image.network(data['imageUrl'],height: 100)
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
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(data['topicName'],style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold),maxLines: 2),
                                                Text('${data['weight'].toString()} kg',style: TextStyle(color: Colors.grey.shade900,fontSize: isTablet?20:16),maxLines: 2),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    Text('฿ ${f.format(data['price'])}',style: data['promo'] != 0
                                                        ?TextStyle(decoration:TextDecoration.lineThrough,fontSize: isTablet?20:16):TextStyle(fontSize: isTablet?20:16)),
                                                    Visibility(
                                                      visible: data['promo']!=0,
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(left: 5.0),
                                                        child: Text('฿ ${f.format(data['promo'])}',style: TextStyle(color: themeColour,fontSize: isTablet?20:16)),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 15.0),
                                                  child: Text('จำนวน ${data['quantity']}',style: TextStyle(fontSize: isTablet?20:16)),
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
                                Container(
                                  alignment: Alignment.centerLeft,
                                  height: isTablet?50:30,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: themeColour),
                                      color: themeColour
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 15.0),
                                    child: Text('ตัวเลือกการขนส่ง',style: TextStyle(color: Colors.white,fontSize: isTablet?20:16)),
                                  ),
                                ),
                                Container(
                                    color: Colors.red.shade50,
                                    height: 70,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 15.0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('ขนส่งแบบธรรมดา',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: isTablet?20:16)),
                                              Text('1-3 วันทำการ',style: TextStyle(fontSize: isTablet?20:16))
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(right: 15),
                                          child: Row(
                                            children: [
                                              Text('฿ ${deliFee}',style: TextStyle(fontSize: isTablet?20:16)),
                                            ],
                                          ),
                                        )
                                      ],
                                    )
                                ),
                                SizedBox(height: 15),
                                Padding(
                                  padding: const EdgeInsets.only(right: 15.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text('ยอดรวมสิ้นค้า :',style: TextStyle(fontSize: isTablet?20:16)),
                                      data['promo'] == 0
                                          ?Text('฿ ${f.format(data['quantity']*data['price']+ deliFee)}',style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold,color: themeColour))
                                          :Text('฿ ${f.format(data['quantity']*data['promo']+deliFee)}',style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold,color: themeColour))
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                  child: Divider(color: themeColour),
                                )
                              ],
                            ),
                          );

                        }).toList()
                    );
                  },
                ),
              ],
            )
                :widget.type == 'pet'?
            Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15.0,right: 15,top: 10),
                      child: Row(
                        children: [
                          Icon(FontAwesomeIcons.store,size: 20,color: Colors.black),
                          SizedBox(width: 10),
                          Text(widget.sellerName,style: TextStyle(fontSize: isTablet?20:16))
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
                          flex: 3,
                          child: Image.network(widget.imageUrl,height: 100)
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
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.topicName,style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold),maxLines: 2),
                                  Text(widget.breed,style: TextStyle(color: Colors.grey.shade900,fontSize: isTablet?20:16),maxLines: 2),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text('฿ ${f.format(widget.price)}',style: widget.promo != 0
                                          ?TextStyle(decoration:TextDecoration.lineThrough,fontSize: isTablet?20:16):TextStyle(fontSize: isTablet?20:16)),
                                      Visibility(
                                        visible: widget.promo!=0,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 5.0),
                                          child: Text('฿ ${f.format(widget.promo)}',style: TextStyle(color: themeColour,fontSize: isTablet?20:16)),
                                        ),
                                      )
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15.0),
                                    child: Text('จำนวน ${widget.quantity}',style: TextStyle(fontSize: isTablet?20:16)),
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
                  Container(
                    alignment: Alignment.centerLeft,
                    height: isTablet?50:30,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        border: Border.all(color: themeColour),
                        color: themeColour
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text('ตัวเลือกการขนส่ง',style: TextStyle(color: Colors.white,fontSize: isTablet?20:16)),
                    ),
                  ),
                  InkWell(
                    child: Container(
                        color: Colors.red.shade50,
                        height: 70,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Text(deliMethod_BuyNow!,style: TextStyle(color: Colors.black,fontSize: isTablet?20:16)),
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 15),
                              child: Row(
                                children: [
                                  deliPrice_BuyNow == 0 || deliPrice_BuyNow == null? Text('ไม่มีค่าใช้จ่าย',style: TextStyle(fontSize: isTablet?20:16)):Text('฿ ${deliPrice_BuyNow}',style: TextStyle(fontSize: isTablet?20:16)),
                                  SizedBox(width: 10),
                                  widget.forbidAirTransport == true || widget.price == 0?SizedBox():Icon(Icons.arrow_forward_ios,color: themeColour)
                                ],
                              ),
                            )
                          ],
                        )
                    ),
                    onTap: widget.forbidAirTransport == true || widget.price == 0?(){}:()async{
                      await getDeliMethod(widget.sellerId);
                      final result = await Navigator.push(context, MaterialPageRoute(builder: (context)=>selectedPage(text: 'ตัวเลือกการจัดส่ง', list: deliList)));
                      setState(() {
                        if(result == 'รับเองที่ฟาร์ม'){
                          destination = '0';
                          result == null?deliMethod_BuyNow = 'รับเองที่ฟาร์ม':deliMethod_BuyNow = result;
                          result == null?deliPrice_BuyNow = 0:deliPrice_BuyNow = 0;
                          Future.delayed(const Duration(milliseconds: 200), () {
                            setState(() {
                              destinationCheck = true;
                              final_price = widget.price + deliPrice_BuyNow - discount;
                            });
                          });

                        }else{
                          result == null? deliMethod_BuyNow = 'รับเองที่ฟาร์ม':deliMethod_BuyNow = result;
                          if(deliMethod_BuyNow == 'ส่งทางอากาศ (รับที่สนามบิน)'){
                            setState(() {
                              destinationCheck = false;
                            });
                          }
                          deliPrice_BuyNow = 1500;
                          Future.delayed(const Duration(milliseconds: 200), () {
                            setState(() {
                              final_price = widget.price + deliPrice_BuyNow - discount;
                            });
                          });
                        }
                      });
                      deliList = [];
                    },
                  ),
                  deliMethod_BuyNow == 'ส่งทางอากาศ (รับที่สนามบิน)' ?Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Divider(color: themeColour),
                  ):SizedBox(),
                  deliMethod_BuyNow == 'ส่งทางอากาศ (รับที่สนามบิน)' ?InkWell(
                    child: Container(
                        color: Colors.red.shade50,
                        height: 60,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0,top: 10,bottom: 10),
                                  child: destination == null || destination == '0'
                                      ?Text('โปรดเลือดสนามบินปลายทาง',style: TextStyle(color: Colors.black,fontSize: isTablet?20:16))
                                      :Text(destination.toString(),style: TextStyle(color: Colors.black,fontSize: isTablet?20:16)),
                                ),
                                Container(
                                  margin: EdgeInsets.only(right: 15),
                                  child: Icon(Icons.arrow_forward_ios,color: themeColour),
                                )
                              ],
                            ),
                          ],
                        )
                    ),
                    onTap: ()async{
                      final result = await Navigator.push(context, MaterialPageRoute(builder: (context)=>selectedPageCheckOut(text: 'เลือกท่าอากาศยานปลายทาง', list: airportList)));
                      if(deliMethod_BuyNow == 'ส่งทางอากาศ (รับที่สนามบิน)'){
                        setState(() {
                          destination = result;
                          destinationCheck = true;
                        });
                      }
                    },
                  ):SizedBox(),
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('ยอดรวมสิ้นค้า :',style: TextStyle(fontSize: isTablet?20:16)),
                        Text('฿ ${f.format(final_price)}',style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold,color: themeColour))
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Divider(color: themeColour),
                  )
                ],
              ),
            ): widget.type == 'foods'?

            Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15.0,right: 15,top: 10),
                      child: Row(
                        children: [
                          Icon(FontAwesomeIcons.store,size: 20,color: Colors.black),
                          SizedBox(width: 10),
                          Text(widget.sellerName,style: TextStyle(fontSize: isTablet?20:16))
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
                          flex: 3,
                          child: Image.network(widget.imageUrl,height: 100)
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
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.topicName,style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold),maxLines: 2),
                                  Text('${widget.weight.toString()} kg',style: TextStyle(color: Colors.grey.shade900,fontSize: isTablet?20:16),maxLines: 2),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text('฿ ${f.format(widget.price)}',style: widget.promo != 0
                                          ?TextStyle(decoration:TextDecoration.lineThrough,fontSize: isTablet?20:16):TextStyle(fontSize: isTablet?20:16)),
                                      Visibility(
                                        visible: widget.promo!=0,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 5.0),
                                          child: Text('฿ ${f.format(widget.promo)}',style: TextStyle(color: themeColour,fontSize: isTablet?20:16)),
                                        ),
                                      )
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15.0),
                                    child: Text('จำนวน ${widget.quantity}',style: TextStyle(fontSize: isTablet?20:16)),
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
                  Container(
                    alignment: Alignment.centerLeft,
                    height: isTablet?50:30,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        border: Border.all(color: themeColour),
                        color: themeColour
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text('ตัวเลือกการขนส่ง',style: TextStyle(color: Colors.white,fontSize: isTablet?20:16)),
                    ),
                  ),
                  Container(
                      color: Colors.red.shade50,
                      height: 70,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ขนส่งแบบธรรมดา',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: isTablet?20:16)),
                                Text('1-3 วันทำการ',style: TextStyle(fontSize: isTablet?20:16))
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(right: 15),
                            child: Row(
                              children: [
                                Text('฿ ${deliPrice_BuyNow.toString()}',style: TextStyle(fontSize: isTablet?20:16)),
                              ],
                            ),
                          )
                        ],
                      )
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('ยอดรวมสิ้นค้า :',style: TextStyle(fontSize: isTablet?20:16)),
                        Text('฿ ${f.format(final_price)}',style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Divider(color: themeColour),
                  )
                ],
              ),
            ):Container(),
            // widget.fromPage == "fromCart"?SizedBox():
            Padding(
                padding: EdgeInsets.only(top: 10),
              child: Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15.0,right: 15,top: 10,bottom: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(FontAwesomeIcons.receipt,color: themeColour),
                          SizedBox(width: 5),
                          Text('โค้ดส่วนลด',style: TextStyle(color: Colors.black,fontSize: isTablet?20:16)),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            height: isTablet?40:30,
                            width: isTablet?200:150,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: TextFormField(
                                controller: promoController,
                                decoration: InputDecoration(
                                  border: InputBorder.none
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 20),

                          discount!=0?InkWell(
                            child: Icon(FontAwesomeIcons.timesCircle,color: themeColour),
                            onTap: (){
                              setState(() {
                                discount = 0;
                                reason = '';
                                promoController.clear();
                              });
                              lst_discount.clear();
                              getSubTotal();
                              Future.delayed(const Duration(milliseconds: 50), () {
                                widget.fromPage == 'fromCart'?getInfoFromCart():null;
                                setState(() {
                                  widget.fromPage == 'fromCart'
                                      ?final_price = total + totalDeliFee_Pets + totalDeliFee_Foods - discount

                                      :widget.fromPage == 'buyNow' && widget.type == 'pet'
                                      ?final_price = widget.price - discount

                                      :widget.fromPage == 'buyNow' && widget.type == 'foods' && widget.promo == 0
                                      ?final_price = widget.quantity * widget.price + deliPrice_BuyNow - discount

                                      :widget.fromPage == 'buyNow' && widget.type == 'foods' && widget.promo != 0
                                      ?final_price = widget.quantity * widget.promo + deliPrice_BuyNow - discount
                                      :null;
                                });
                              });
                            },
                          ):InkWell(
                            child: Container(
                              color: themeColour,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('ยืนยัน',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: isTablet?20:16)
                                  ),
                                )
                            ),
                            onTap: (){
                              checkDiscount(promoController.text);
                            },
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),

            discount == 0 && reason == ''?SizedBox():Container(
              color: Colors.white,
              alignment: Alignment.topRight,
              width: MediaQuery.of(context).size.width,
              child: reason != 'coupon'?
              Padding(
                  padding: EdgeInsets.only(right: 90),
                  child: Text(reason,
                      style: TextStyle(color: themeColour))
              ):
              Padding(
                  padding: EdgeInsets.only(right: 60),
                  child: Text('- ${f.format(discount)} บาท',
                      style: TextStyle(color: themeColour))
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: InkWell(
                child: Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            child: Row(
                              children: [
                                Icon(LineAwesomeIcons.comments_dollar,color: themeColour),
                                paymentType == 'bankAccount'?Text(' บัญชีสำหรับคืนเงิน',style: TextStyle(fontSize: isTablet?20:16)):SizedBox()
                              ],
                            )),

                        Container(child: Row(
                          children: [
                            paymentType == 'bankAccount'?
                            registedBankAccountList[0].bankName == 'ทหารไทยธนชาต จำกัด (มหาชน)'
                                ?Text('ทหารไทยธนชาต *${senser_bankAccount}',style: TextStyle(fontSize: isTablet?20:16))
                                :registedBankAccountList[0].bankName == 'สแตนดาร์ดชาร์เตอร์ด (ไทย)'
                                ?Text('สแตนดาร์ดชาร์เตอร์ด *${senser_bankAccount}',style: TextStyle(fontSize: isTablet?20:16))
                                :Text('${registedBankAccountList[0].bankName} *${senser_bankAccount}',style: TextStyle(fontSize: isTablet?20:16)):
                            paymentType == 'creditCard'?
                            Text('Credit/Debit Card *${sensor_craditCard}',style: TextStyle(fontSize: isTablet?20:16)):
                            Text('บัญชีสำหรับคืนเงินหากสินค้ามีปัญหา',style: TextStyle(fontSize: isTablet?20:16)),
                            SizedBox(width: 5),
                            Icon(Icons.arrow_forward_ios),
                          ],
                        )),
                      ],
                    ),
                  ),
                ),
                onTap: ()async{
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (context)=>payment(userId: widget.userId,fromCheckOut: true)));
                  paymentType = result[0];
                  if(paymentType == 'creditCard'){
                    registedCreditCardList.clear();
                    registedCreditCardList.add(
                        creditCardPaymentMethod(
                          cardName: result[1],
                          cardNumber: result[2],
                          cardType: result[3],
                          cvv: result[4],
                          exDate: result[5],
                          issueBank: result[6]
                        )
                    );
                    setState(() {
                      sensor_craditCard = registedCreditCardList[0].cardNumber.toString();
                      sensor_craditCard = sensor_craditCard!.substring(sensor_craditCard!.length - 4);
                    });
                  }else if(paymentType == 'bankAccount'){
                    registedBankAccountList.clear();
                    registedBankAccountList.add(
                        bankAccountPaymentMethod(
                            accountName: result[1],
                            accountNumber: result[2],
                            bankName: result[3]
                        )
                    );
                    setState(() {
                      senser_bankAccount = registedBankAccountList[0].accountNumber.toString();
                      senser_bankAccount = senser_bankAccount!.substring(senser_bankAccount!.length - 4);
                    });
                  }
                },
              ),
            )
          ],
        ),
        bottomNavigationBar: Container(
            height: isTablet == true?80:50,
            alignment: Alignment.centerRight,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ยอดรวม',style: TextStyle(fontSize: isTablet?20:16)),
                        Text('฿ ${f.format(final_price)}',style: TextStyle(color: themeColour,fontWeight: FontWeight.bold,fontSize: isTablet?20:16))
                      ],
                    ),
                  ),
                ),
                isLoading == false && paymentType != null && destinationCheck == true && name !=null?
                InkWell(
                  child: Container(
                    color: themeColour,
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: isTablet == true?55:45.0),
                      child: Text('ชำระเงิน',style: TextStyle(color: Colors.white,fontSize: isTablet == true?20:15)),
                    ),
                  ),
                  onTap: ()async{
                    var transactionId = customAlphabet('ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789', 10);
                    final info = registedBankAccountList[0].accountName.split(' ');

                    // Free  == bypassed payment process
                    if(final_price == 0 && widget.price == 0 && discount ==0 && widget.fromPage == 'buyNow'){
                      updateActive(widget.postId, widget.type);
                      pushToPurchase(
                          widget.userId,
                          widget.sellerName.toString(),
                          widget.sellerId,
                          widget.postId ,
                          widget.topicName,
                          widget.breed,
                          widget.imageUrl,
                          widget.price,
                          widget.promo,
                          widget.quantity,
                          deliPrice_BuyNow,
                          discount,
                          widget.price + deliPrice_BuyNow - discount,
                          widget.dispatchDate,
                          widget.dispatchMonth,
                          widget.dispatchYear,
                          deliMethod_BuyNow.toString(),
                          widget.type,
                          widget.subType,
                          widget.breed,
                          '0',
                          destination.toString(),
                          transactionId,
                          transactionId
                      );
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>thankyou(userId: widget.userId,amount: final_price.toStringAsFixed(2))));
                      // Free == bypassed payment method
                    }else if(final_price == 0 && itemCart.length == 1 && widget.fromPage == 'fromCart'){
                      for(var i = 0; i<itemCart.length; i++){
                        if(itemCart[i].type == 'pet'){
                          updateActive(itemCart[i].postId, itemCart[i].type);
                          pushToPurchase(
                            widget.userId,
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
                            transactionId,
                            transactionId,
                          );
                        }
                      }
                      deleteItemInCart();
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>thankyou(userId: widget.userId,amount: final_price.toStringAsFixed(2))));
                    }else if(widget.type == 'pet' && widget.fromPage == 'buyNow' && final_price >0){

                      await postsPuppyKittenRef.doc(widget.postId).get().then((snapshot) async {
                        if(snapshot['active'] == true){
                          setState(() {
                            isLoading = true;
                          });
                          _responseFromCreatePayment = await Service().createPaymentClass(
                              info[1],
                              info[2],
                              email!,
                              final_price.toStringAsFixed(2),
                              transactionId
                          );

                          await usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('bankAccount').where('refundAccount',isEqualTo: true).get().then((snapshot){
                            snapshot.docs.forEach((doc) {
                              usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('bankAccount').doc(doc.id).get().then((snap){
                                usersRef.doc(widget.userId).collection('cart').doc(widget.userId).set({
                                  'fromPage':'buyNow',
                                  'MoneySpaceTransactionId':_responseFromCreatePayment.body![0].transactionId,
                                  'transactionId':transactionId,
                                  'postId':widget.postId,
                                  'userId':widget.userId,
                                  'sellerName':widget.sellerName.toString(),
                                  'sellerId':widget.sellerId,
                                  'topicName': widget.topicName,
                                  'breed':widget.breed,
                                  'imageUrl':widget.imageUrl,
                                  'price':widget.price,
                                  'promo':widget.promo,
                                  'quantity':  widget.quantity,
                                  'deliPrice_BuyNow': deliPrice_BuyNow,
                                  'discount': discount,
                                  'total': widget.price + deliPrice_BuyNow - discount,
                                  'dispatchDate': widget.dispatchDate,
                                  'dispatchMonth': widget.dispatchMonth,
                                  'dispatchYear': widget.dispatchYear,
                                  'deliMethod_BuyNow': deliMethod_BuyNow.toString(),
                                  'type': widget.type,
                                  'paymentType':paymentType,
                                  'subType': widget.subType,
                                  'brand': widget.breed,
                                  'weight':'0',
                                  'destination':destination != null? destination.toString(): '0',
                                  'paymentName': registedBankAccountList.length == 0? registedCreditCardList[0].cardName: registedBankAccountList[0].accountName,
                                  'issueBank': registedBankAccountList.length == 0? registedCreditCardList[0].issueBank: registedBankAccountList[0].bankName,
                                  'paymentNumber' : registedBankAccountList.length == 0? registedCreditCardList[0].cardNumber: registedBankAccountList[0].accountNumber,
                                  'userName': widget.userName,
                                  'promoCode': promoController.text,

                                  'rp_BankName': registedBankAccountList.length == 0? snap.data()!['bankName']:registedBankAccountList[0].bankName,
                                  'rp_AccountName': registedBankAccountList.length == 0? snap.data()!['title']+' '+snap.data()!['accountFirstName']+' '+snap.data()!['accountLastName']:registedBankAccountList[0].accountName,
                                  'rp_AccountNumber': registedBankAccountList.length == 0? snap.data()!['accountNumber']: registedBankAccountList[0].accountNumber,

                                  'toAddress_name':name,
                                  'toAddress_houseNo':houseNo == null?'0':houseNo,
                                  'toAddress_moo':moo == null? '0': moo,
                                  'toAddress_road':road == null? '0': road,
                                  'toAddress_subdistrict':subdistrict,
                                  'toAddress_district':district,
                                  'toAddress_city':city,
                                  'toAddress_postCode':postCode,
                                  'toAddress_phoneNo':phoneNo,
                                });
                              });
                            });
                          });

                          setState(() {
                            isLoading = false;
                          });
                          final result = await Navigator.push(context, MaterialPageRoute(builder: (context)=>paymentPage(
                            qrprom_url: _responseFromCreatePayment.body![0].image_qrprom,
                            transactionID: _responseFromCreatePayment.body![0].transactionId,
                            final_price: final_price.toStringAsFixed(2),
                          )));

                          // If payment success, can proceed
                          // return TRUE = transaction completed return FALSE = the user cxl payment.
                          if(result == true){
                            updateActive(widget.postId, widget.type);
                            pushToPurchase(
                                widget.userId,
                                widget.sellerName.toString(),
                                widget.sellerId,
                                widget.postId ,
                                widget.topicName,
                                widget.breed,
                                widget.imageUrl,
                                widget.price,
                                widget.promo,
                                widget.quantity,
                                deliPrice_BuyNow,
                                discount,
                                widget.price + deliPrice_BuyNow - discount,
                                widget.dispatchDate,
                                widget.dispatchMonth,
                                widget.dispatchYear,
                                deliMethod_BuyNow.toString(),
                                widget.type,
                                widget.subType,
                                widget.breed,
                                '0',
                                destination.toString(),
                                transactionId,
                                _responseFromCreatePayment.body![0].transactionId
                            );

                            usersRef.doc(widget.userId).collection('cart').doc(widget.userId).delete();

                            discount == 0?null: updateCouponUsed(
                              promoController.text,
                              pctDiscount,
                              type.toString(),
                              discount,
                              minSpending,
                              maxDiscount,
                              final_price,
                              campaignStartTime,
                              campaignEndTime,
                            );

                            Navigator.push(context, MaterialPageRoute(builder: (context)=>thankyou(userId: widget.userId,amount: final_price.toStringAsFixed(2))));
                          }
                        }else{
                          setState(() {
                            showAlertDialog(context);
                          });
                        }
                      });

                    }else if(widget.type == 'foods' && widget.fromPage == 'buyNow'){
                      int residual;
                      await postsFoodRef.doc(widget.postId).get().then((snapshot) async {
                        if(double.parse(widget.weight) == snapshot.data()!['weight1']){
                          residual = snapshot.data()!['stock1'] - widget.quantity;
                          if(residual<0){
                            setState(() {
                              showAlertDialog(context);
                            });
                          }else{
                            checkOutMethodFood(info[0], info[1], transactionId);
                          }
                        }else if(double.parse(widget.weight) == snapshot.data()!['weight2']){
                          residual = snapshot.data()!['stock2'] -  widget.quantity;
                          if(residual<0){
                            setState(() {
                              showAlertDialog(context);
                            });
                          }else{
                            checkOutMethodFood(info[0], info[1], transactionId);
                          }
                        }else if(double.parse(widget.weight) == snapshot.data()!['weight3']){
                          residual = snapshot.data()!['stock3'] -  widget.quantity;
                          if(residual<0){
                            setState(() {
                              showAlertDialog(context);
                            });
                          }else{
                            checkOutMethodFood(info[0], info[1], transactionId);
                          }
                        }else if(double.parse(widget.weight) == snapshot.data()!['weight4']){
                          residual = snapshot.data()!['stock4'] - widget.quantity;
                          if(residual<0){
                            setState(() {
                              showAlertDialog(context);
                            });
                          }else{
                            checkOutMethodFood(info[0], info[1], transactionId);
                          }
                        }else if(double.parse(widget.weight) == snapshot.data()!['weight5']){
                          residual = snapshot.data()!['stock5'] - widget.quantity;
                          if(residual<0){
                            setState(() {
                              showAlertDialog(context);
                            });
                          }else{
                            checkOutMethodFood(info[0], info[1], transactionId);
                          }
                        }else if(double.parse(widget.weight) == snapshot.data()!['weight6']){
                          residual = snapshot.data()!['stock6'] - widget.quantity;
                          if(residual<0){
                            setState(() {
                              showAlertDialog(context);
                            });
                          }else{
                            checkOutMethodFood(info[0], info[1], transactionId);
                          }
                        }
                      });
                    }else if(widget.fromPage == 'fromCart' && final_price >0){
                      String allPostId = '';
                      setState(() {
                        isLoading = true;
                      });
                      List<int> discountTotal = [];

                      for(var i =0;i<itemCart.length;i++){
                        allPostId = allPostId + itemCart[i].postId.toString()+',';
                      }

                      _responseFromCreatePayment = await Service().createPaymentClass(
                          info[0],
                          info[1],
                          email!,
                          final_price.toStringAsFixed(2),
                          transactionId
                      );

                      await usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('bankAccount').where('refundAccount',isEqualTo: true).get().then((snapshot){
                        snapshot.docs.forEach((doc) {
                          usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('bankAccount').doc(doc.id).get().then((snap){
                            usersRef.doc(widget.userId).collection('cart').doc(widget.userId).set({
                              'fromPage':'fromCart',
                              'MoneySpaceTransactionId':_responseFromCreatePayment.body![0].transactionId,
                              'transactionId': transactionId,
                              'paymentName': registedBankAccountList.length == 0? registedCreditCardList[0].cardName: registedBankAccountList[0].accountName,
                              'issueBank': registedBankAccountList.length == 0? registedCreditCardList[0].issueBank: registedBankAccountList[0].bankName,
                              'paymentNumber' : registedBankAccountList.length == 0? registedCreditCardList[0].cardNumber: registedBankAccountList[0].accountNumber,
                              'paymentType':paymentType,
                              'userName': widget.userName,
                              'promoCode': promoController.text,

                              'rp_BankName': registedBankAccountList.length == 0? snap.data()!['bankName']:registedBankAccountList[0].bankName,
                              'rp_AccountName': registedBankAccountList.length == 0? snap.data()!['title']+' '+snap.data()!['accountFirstName']+' '+snap.data()!['accountLastName']:registedBankAccountList[0].accountName,
                              'rp_AccountNumber': registedBankAccountList.length == 0? snap.data()!['accountNumber']: registedBankAccountList[0].accountNumber,

                              'toAddress_name':name,
                              'toAddress_houseNo':houseNo == null?'0':houseNo,
                              'toAddress_moo':moo == null? '0': moo,
                              'toAddress_road':road == null? '0': road,
                              'toAddress_subdistrict':subdistrict,
                              'toAddress_district':district,
                              'toAddress_city':city,
                              'toAddress_postCode':postCode,
                              'toAddress_phoneNo':phoneNo,
                              'itemCart': allPostId
                            });
                          });
                        });
                      });


                      setState(() {
                        isLoading = false;
                      });
                      final result = await Navigator.push(context, MaterialPageRoute(builder: (context)=>paymentPage(
                        qrprom_url: _responseFromCreatePayment.body![0].image_qrprom,
                        transactionID: _responseFromCreatePayment.body![0].transactionId,
                        final_price: final_price.toStringAsFixed(2),
                      )));

                      // If payment success, can proceed this part
                      // return TRUE = transaction completed return FALSE = the user cxl payment.
                      if(result == true){
                        if(lst_discount.length>0){
                          for(var i = 0; i<itemCart.length; i++){
                            itemCart[i].discount = lst_discount[i];
                          }
                        }else{
                          for(var i = 0; i<itemCart.length; i++){
                            itemCart[i].discount = 0;
                          }
                        }
                        for(var i = 0; i<itemCart.length; i++){
                          if(itemCart[i].type == 'pet'){
                            updateActive(itemCart[i].postId, itemCart[i].type);
                            pushToPurchase(
                              widget.userId,
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
                              transactionId,
                              _responseFromCreatePayment.body![0].transactionId,
                            );
                          }else{
                            updateStock(itemCart[i].type,itemCart[i].postId,double.parse(itemCart[i].breed),itemCart[i].quantity);

                            int total = itemCart[i].promo != 0
                                ? (itemCart[i].promo * itemCart[i].quantity) + itemCart[i].deliFee
                                : (itemCart[i].price * itemCart[i].quantity) + itemCart[i].deliFee;

                            pushToPurchase(
                              widget.userId,
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
                              transactionId,
                              _responseFromCreatePayment.body![0].transactionId,
                            );
                          }
                        }

                        usersRef.doc(widget.userId).collection('cart').doc(widget.userId).delete();

                        discount == 0?null: updateCouponUsed(
                          promoController.text,
                          pctDiscount,
                          type.toString(),
                          discount,
                          minSpending,
                          maxDiscount,
                          final_price,
                          campaignStartTime,
                          campaignEndTime,
                        );
                        deleteItemInCart();
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>thankyou(userId: widget.userId,amount: final_price.toStringAsFixed(2))));
                      }

                    }
                  },
                ):Container(
                  color: Colors.grey,
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 45.0),
                    child: Text('ชำระเงิน',style: TextStyle(color: Colors.white,fontSize: 15)),
                  ),
                )
              ],
            )
        ),
      ),
    );
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

  Future<dynamic> showAlertInternetDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) =>
        Platform.isIOS ?
        CupertinoAlertDialog(
          title: Text('แจ้งเตือน'),
          content: Text('กรุณาเชื่อต่ออินเตอร์เน็ต'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('รับทราบ',style: TextStyle(color: Colors.blueAccent)),
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
                padding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 20),
                child: Text('กรุณาเชื่อต่ออินเตอร์เน็ต',style: TextStyle(color: Colors.black,fontSize: 15)),
              )
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
                  },
                )
            )
          ],
        )
    );
  }

}


class selectedPage extends StatelessWidget {
  String text;
  List list;
  selectedPage({required this.text,required this.list});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithOutBackArrow(text,isTablet),
      body: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context,i){
          return InkWell(
            child: Card(
              child: ListTile(
                title: Text(list[i].toString()),
                trailing: list[i] == 'รับเองที่ฟาร์ม'?Text('ไม่มีค่าใช้จ่าย',style: TextStyle(fontSize: isTablet?20:16)):Text('฿ 1,500'),
              ),
            ),
            onTap: (){
              Navigator.pop(context,list[i]);
              list.clear();
            },
          );
        },
      ),
    );
  }
}

class selectedPageCheckOut extends StatelessWidget {
  String text;
  List list;
  selectedPageCheckOut({required this.text,required this.list});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithBackArrow(text,false),
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
    );
  }
}