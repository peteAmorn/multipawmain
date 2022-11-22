import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/src/intl/number_format.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:multipawmain/chat/chatroom.dart';
import 'package:multipawmain/authCheck.dart';
import 'package:multipawmain/database/posts.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:multipawmain/shop/checkOut.dart';
import 'package:multipawmain/shop/myCart.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:multipawmain/support/showNetworkImage.dart';
import 'package:sizer/sizer.dart';
import '../../ratingAndReviewEdit.dart';
import '../showComments.dart';

int? price,promo_price,priceMin,priceMax,pricePromoMin,pricePromoMax;
late int stock,qty;
bool toShow = true;

final DateTime timestamp = DateTime.now();

class foodPreview extends StatefulWidget {
  final userId,postId,postType;

  foodPreview({
    required this.postId,
    required this.userId,
    this.postType,
  });

  @override
  _foodPreviewState createState() => _foodPreviewState();
}

class _foodPreviewState extends State<foodPreview> {
  final CarouselController _controller = CarouselController();
  String? userUrl,userName,userId;
  String? ownerUrl, ownerName, ownerId;
  String? profile,topicName, brand;
  String? selectedWeight;
  int prev_qty = 0;
  bool isLoading = false;
  int item_in_cart = 0;
  bool isCheck = false;
  late bool select1,select2,select3,select4,select5,select6;

  Color color1 = Colors.black;
  Color color2 = Colors.black;
  Color color3 = Colors.black;
  Color color4 = Colors.black;
  Color color5 = Colors.black;
  Color color6 = Colors.black;


  List<String> imagesList = [];
  List<String> pedigreeList = [];
  List<int> priceList = [];
  List<int> promoList = [];
  List<double> scores = [];
  List<reviewDetail> commentList = [];
  int? average_score, commentsNum;
  bool isDeviceConnected = false;

  bool isTablet = false;

  checkInternetConnection()async{
    bool result = await InternetConnectionChecker().hasConnection;
    result == true? isDeviceConnected = true: isDeviceConnected = false;
  }

  Scaffold noInternetPage(){
    return Scaffold(
      appBar: appBarWithBackArrow('',isTablet),
      body: Center(
        child: Text('No internet Connection'),
      ),
    );
  }


  getCart()async{
    await usersRef.doc(widget.userId).collection('myCart').get().then((snap){
      item_in_cart = snap.size;
    });
  }

  resetStock(){
    setState(() {
      stock = 0;
    });
  }

  getStar()async{
    scores.clear();
    await commentsRef.where('type',isEqualTo: 'food').get().then((snapshot){
      snapshot.docs.forEach((data) {
        commentsRef.doc(data.id).get().then((snap){
          scores.add(snap.data()!['score']);
        });
      });
    });
  }

  getComment(bool isStopLoading)async{
    commentList.clear();
    await postsFoodRef.doc(widget.postId).get().then((snapshot){
      ownerId = snapshot.data()!['id'];
    });

    Query q = commentsRef.where('sellerId',isEqualTo: ownerId).where('type',isEqualTo: 'food').limit(2);
    QuerySnapshot querySnapshot = await q.get();
    querySnapshot.docs.forEach((doc) {commentList.add(reviewDetail.fromDocument(doc));});
    commentList.sort((a,b)=>a.timestamp.compareTo(b.timestamp));


    await commentsRef..where('sellerId',isEqualTo: ownerId).where('type',isEqualTo: 'food').get().then((snap) => commentsNum = snap.size);
    setState(() {
      isStopLoading == true?isLoading = false:null;
    });
  }

  viewUpdate()async{
    int? current_views;
    await postsFoodRef.doc(widget.postId).get().then((snapshot) => {
      if(snapshot.data()!.length>0){
        current_views = snapshot.data()!['view'],

        postsFoodRef.doc(widget.postId).update({
          'view':current_views!+1
        })
      }
    });
  }

  getUserData()async{
    await usersRef.doc(widget.userId).get().then((snapshot){
      userUrl = snapshot.data()!['urlProfilePic'];
      userName = snapshot.data()!['name'];
    });

    await postsFoodRef.doc(widget.postId).get().then((snapshot){
      ownerId = snapshot.data()!['id'];

      usersRef.doc(ownerId).get().then((snap){
        ownerUrl = snap.data()!['urlProfilePic'];
        ownerName = snap.data()!['name'];
      });
    });
  }

  getImg()async{
    await postsFoodRef.doc(widget.postId).get().then((snapshot){
      if(snapshot.data()!['coverProfile']!= 'cover'){
        imagesList.add(snapshot.data()!['coverProfile']);
      }
      if(snapshot.data()!['profile1']!= 'profile1'){
        imagesList.add(snapshot.data()!['profile1']);
      }
      if(snapshot.data()!['profile2']!= 'profile2'){
        imagesList.add(snapshot.data()!['profile2']);
      }
      if(snapshot.data()!['profile3']!= 'profile3'){
        imagesList.add(snapshot.data()!['profile3']);
      }
      if(snapshot.data()!['profile4']!= 'profile4'){
        imagesList.add(snapshot.data()!['profile4']);
      }
      if(snapshot.data()!['profile5']!= 'profile5'){
        imagesList.add(snapshot.data()!['profile5']);
      }
    });
  }

  addToCart(String img,String title,String weight,int price,int pricePromo,int qty, String brand, String subType)async{
    await usersRef.doc(widget.userId).collection('myCart').where('weight',isEqualTo:weight).where('postid',isEqualTo: widget.postId).get().then((snapshot){
      if(snapshot.size>0){
        snapshot.docs.forEach((snap) {
          snap.data()['quantity'] != null?prev_qty = snap.data()['quantity']:prev_qty = 0;
        });
      }
    });

    usersRef.doc(widget.userId).collection('myCart').doc(widget.postId + weight).set({
      'id':ownerId,
      'postid_cart':widget.postId + weight,
      'postid': widget.postId,
      'check':isCheck,
      'imageUrl': img,
      'topicName': title,
      'weight': weight == ''?0:double.parse(weight),
      'price': price,
      'promo': pricePromo == ''?0:pricePromo,
      'quantity': qty+prev_qty > stock?stock:qty+prev_qty,
      'type':widget.postType,
      'subType': subType,
      'subTotal': pricePromo == 0? price*qty:pricePromo,
      'timestamp':timestamp,
      'stock': stock,
      'sellerName': ownerName,
      'dispatchDate': 0,
      'dispatchMonth': 0,
      'dispatchYear': 0,
      'brand': brand,
      'airPickUpShow': false,
      'forbidAirTransport': false
    });
  }

  checkStock()async{
    await postsFoodRef.doc(widget.postId).get().then((snapshot){
      if(snapshot['stock1'] == 0
          && snapshot['stock2'] == 0
          && snapshot['stock3'] == 0
          && snapshot['stock4'] == 0
          && snapshot['stock5'] == 0
          && snapshot['stock6'] == 0){
        setState(() {
          toShow = false;
        });
      }else{
        toShow = true;
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkStock();
    setState(() {
      stock = 0;
      qty = 1;
      isLoading = true;
      price = null;
      promo_price = null;
      SizerUtil.deviceType == DeviceType.tablet?isTablet = true:isTablet = false;
    });

    checkInternetConnection();
    getCart();
    getUserData();
    viewUpdate();
    getImg();
    getStar();
    setState(() {
      select1 = false;
      select2 = false;
      select3 = false;
      select4 = false;
      select5 = false;
    });
    getComment(false);

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        commentList.length == 0?average_score = 0:average_score = (scores.reduce((a, b) => a+b)/scores.length).toInt();
        isLoading = false;
      });

    });
  }

  Color bottomNavigationColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.grey.shade300,
            body: isLoading == true?loadingWithReturn(context):FutureBuilder<DocumentSnapshot>(
            future: postsFoodRef.doc(widget.postId).get(),
            builder: (BuildContext context,AsyncSnapshot<DocumentSnapshot> snapshot){
              if(!snapshot.hasData){
                return loadingWithReturn(context);
              }else if(snapshot.hasData){
                Map<String,dynamic> data = snapshot.data!.data() as Map<String,dynamic>;

                profile = data['coverProfile'];
                topicName = data['topicName'];
                brand = data['brand'];

                ownerId = data['id'];
                ownerName = data['postOwnerName'];
                ownerUrl = data['postOwnerprofileUrl'];

                data['price1']!=0 && data['stock1'] !=0 ?priceList.add(data['price1']):null;
                data['price2']!=0 && data['stock2'] !=0 ?priceList.add(data['price2']):null;
                data['price3']!=0 && data['stock3'] !=0 ?priceList.add(data['price3']):null;
                data['price4']!=0 && data['stock4'] !=0 ?priceList.add(data['price4']):null;
                data['price5']!=0 && data['stock5'] !=0 ?priceList.add(data['price5']):null;
                data['price6']!=0 && data['stock6'] !=0 ?priceList.add(data['price6']):null;
                data['stock1']==0 && data['stock2']==0 &&data['stock3']==0 &&data['stock4']==0 &&data['stock5']==0 && data['stock6'] ==0 ?priceList.add(1):null;

                data['promo_price1']!=0 && data['stock1'] !=0 ?promoList.add(data['promo_price1']):data['price1']!=0 && data['stock1'] !=0 ?promoList.add(data['price1']):null;
                data['promo_price2']!=0 && data['stock2'] !=0 ?promoList.add(data['promo_price2']):data['price2']!=0 && data['stock2'] !=0 ?promoList.add(data['price2']):null;
                data['promo_price3']!=0 && data['stock3'] !=0 ?promoList.add(data['promo_price3']):data['price3']!=0 && data['stock3'] !=0 ?promoList.add(data['price3']):null;
                data['promo_price4']!=0 && data['stock4'] !=0 ?promoList.add(data['promo_price4']):data['price4']!=0 && data['stock4'] !=0 ?promoList.add(data['price4']):null;
                data['promo_price5']!=0 && data['stock5'] !=0 ?promoList.add(data['promo_price5']):data['price5']!=0 && data['stock5'] !=0 ?promoList.add(data['price5']):null;
                data['promo_price6']!=0 && data['stock6'] !=0 ?promoList.add(data['promo_price6']):data['price6']!=0 && data['stock6'] !=0 ?promoList.add(data['price6']):null;


                priceList == null?priceMin = 0:priceMin = priceList.reduce(min);
                priceList == null?priceMax = 0:priceMax = priceList.reduce(max);

                pricePromoMin = promoList.isEmpty?0:promoList.reduce(min);
                pricePromoMax = promoList.isEmpty?0:promoList.reduce(max);

                return ListView(
                  children: [
                    StreamBuilder(
                        stream: usersRef.doc(widget.userId).collection('myCart').snapshots(),
                        builder: (context,snapshot){
                          getCart();
                          return Container(
                            color: Colors.white,
                            child: Stack(
                                children:[
                                  Column(
                                    children: [
                                      // Profile picture
                                      CarouselSlider(
                                        carouselController: _controller,
                                        options: CarouselOptions(
                                          height: isTablet?screenHeight*1.9/3:screenHeight*1.6/3,
                                          viewportFraction: 1.0,
                                          enlargeCenterPage: false,
                                          enableInfiniteScroll: false,
                                        ),
                                        items: imagesList.map((item) => Container(
                                            width: screenWidth,
                                            height: isTablet?screenHeight*1.9/3:screenHeight*1.6/3,
                                            child: InkWell(
                                                child: Image.network(item,fit: BoxFit.fitHeight,width: screenWidth),
                                              onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>showNetworkImage(image: item,test: imagesList,index: imagesList.indexOf(item)))),
                                            ))).toList(),
                                      ),
                                    ],
                                  ),
                                  // Back arrow
                                  Positioned(
                                    top: isTablet?40:20,
                                    left: isTablet?40:20,
                                    child:
                                    InkWell(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey.shade500
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            LineAwesomeIcons.arrow_left,
                                            color: Colors.white,
                                            size: isTablet == true?35:25,
                                          ),
                                        ),
                                      ),
                                      onTap: (){
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    top: isTablet?40:20,
                                    right: isTablet?40:20,
                                    child:
                                    InkWell(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.grey.shade500
                                          ),
                                          child:Padding(
                                            padding: EdgeInsets.all(10.0),
                                            child: Icon(
                                              LineAwesomeIcons.shopping_cart,
                                              size: isTablet == true?35:25,
                                              color: Colors.white,
                                            ),
                                          )
                                        ),
                                        onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>myCart(userId: widget.userId))).then((value){
                                          setState(() {
                                            getCart();
                                          });
                                        })
                                    ),
                                  ),
                                  item_in_cart != 0
                                      ?Positioned(
                                      top: isTablet?25:5,
                                      right: isTablet?32:10,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.red.shade900
                                        ),
                                        child: Center(child: Padding(
                                          padding: EdgeInsets.all(isTablet?10.0:8.0),
                                          child: Text(item_in_cart.toString(),style: TextStyle(color: Colors.white,fontSize: isTablet?20:16)),
                                        )),
                                      )
                                  ):SizedBox()
                                ]
                            ),
                          );
                        }
                    ),
                    Container(
                      color: Colors.white,
                      width: screenWidth,
                      child: Padding(
                          padding: EdgeInsets.only(left: isTablet == true?25:15,top:isTablet == true?25:15),
                          child: basicInfo(
                              screenWidth,
                              data,
                              screenHeight,
                              context,
                              priceMin!.toInt(),
                              priceMax!.toInt(),
                              pricePromoMin!.toInt(),
                              pricePromoMax!.toInt(),
                              price,
                              promo_price
                          )
                      ),
                    ),

                    Container(color: Colors.grey.shade300,width: screenWidth,height: 10),

                    toShow == false?SizedBox():Container(
                      alignment: Alignment.centerLeft,
                      width: screenWidth,
                      height: 120,
                      color: Colors.white,
                      child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: isTablet == true?25:15.0),
                                child: Text('ตัวเลือก',style: TextStyle(fontSize: isTablet == true?25:20,fontWeight: FontWeight.bold)),
                              ),
                              SizedBox(height: 15),
                              Container(
                                height: 50,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    data['weight1']!=0 && data['stock1']!=0?buildWeightChoices(data['weight1'].toString(),color1,select1,(){
                                      setState(() {
                                        select1 = true;
                                        select2 = false;
                                        select3 = false;
                                        select4 = false;
                                        select5 = false;
                                        select6 = false;

                                        select1 == true?color1 = Colors.red.shade900:color1 = Colors.black;
                                        select2 == true?color2 = Colors.red.shade900:color2 = Colors.black;
                                        select3 == true?color3 = Colors.red.shade900:color3 = Colors.black;
                                        select4 == true?color4 = Colors.red.shade900:color4 = Colors.black;
                                        select5 == true?color5 = Colors.red.shade900:color5 = Colors.black;
                                        select6 == true?color6 = Colors.red.shade900:color6 = Colors.black;

                                        selectedWeight = data['weight1'].toString();

                                        promo_price = data['promo_price1'];
                                        price = data['price1'];
                                      });
                                    }):Text(''),
                                    data['weight2']!=0 && data['stock2']!=0?buildWeightChoices(data['weight2'].toString(),color2,select2,(){
                                      setState(() {
                                        select2 = true;
                                        select1 = false;
                                        select3 = false;
                                        select4 = false;
                                        select5 = false;
                                        select6 = false;

                                        select1 == true?color1 = Colors.red.shade900:color1 = Colors.black;
                                        select2 == true?color2 = Colors.red.shade900:color2 = Colors.black;
                                        select3 == true?color3 = Colors.red.shade900:color3 = Colors.black;
                                        select4 == true?color4 = Colors.red.shade900:color4 = Colors.black;
                                        select5 == true?color5 = Colors.red.shade900:color5 = Colors.black;
                                        select6 == true?color6 = Colors.red.shade900:color6 = Colors.black;

                                        selectedWeight = data['weight2'].toString();

                                        promo_price = data['promo_price2'];
                                        price = data['price2'];
                                      });
                                    }):Text(''),
                                    data['weight3']!=0 && data['stock3']!=0?buildWeightChoices(data['weight3'].toString(),color3,select3,(){
                                      setState(() {
                                        select3 = true;
                                        select1 = false;
                                        select2 = false;
                                        select4 = false;
                                        select5 = false;
                                        select6 = false;

                                        select1 == true?color1 = Colors.red.shade900:color1 = Colors.black;
                                        select2 == true?color2 = Colors.red.shade900:color2 = Colors.black;
                                        select3 == true?color3 = Colors.red.shade900:color3 = Colors.black;
                                        select4 == true?color4 = Colors.red.shade900:color4 = Colors.black;
                                        select5 == true?color5 = Colors.red.shade900:color5 = Colors.black;
                                        select6 == true?color6 = Colors.red.shade900:color6 = Colors.black;

                                        selectedWeight = data['weight3'].toString();

                                        promo_price = data['promo_price3'];
                                        price = data['price3'];
                                      });
                                    }):Text(''),
                                    data['weight4']!=0 && data['stock4']!=0?buildWeightChoices(data['weight4'].toString(),color4,select4,(){
                                      setState(() {
                                        select4 = true;
                                        select1 = false;
                                        select2 = false;
                                        select3 = false;
                                        select5 = false;
                                        select6 = false;

                                        select1 == true?color1 = Colors.red.shade900:color1 = Colors.black;
                                        select2 == true?color2 = Colors.red.shade900:color2 = Colors.black;
                                        select3 == true?color3 = Colors.red.shade900:color3 = Colors.black;
                                        select4 == true?color4 = Colors.red.shade900:color4 = Colors.black;
                                        select5 == true?color5 = Colors.red.shade900:color5 = Colors.black;
                                        select6 == true?color6 = Colors.red.shade900:color6 = Colors.black;

                                        selectedWeight = data['weight4'].toString();

                                        promo_price = data['promo_price4'];
                                        price = data['price4'];
                                      });
                                    }):Text(''),
                                    data['weight5']!=0 && data['stock5']!=0?buildWeightChoices(data['weight5'].toString(),color5,select5,(){
                                      setState(() {
                                        select5 = true;
                                        select1 = false;
                                        select2 = false;
                                        select3 = false;
                                        select4 = false;
                                        select6 = false;

                                        select1 == true?color1 = Colors.red.shade900:color1 = Colors.black;
                                        select2 == true?color2 = Colors.red.shade900:color2 = Colors.black;
                                        select3 == true?color3 = Colors.red.shade900:color3 = Colors.black;
                                        select4 == true?color4 = Colors.red.shade900:color4 = Colors.black;
                                        select5 == true?color5 = Colors.red.shade900:color5 = Colors.black;
                                        select6 == true?color6 = Colors.red.shade900:color6 = Colors.black;

                                        selectedWeight = data['weight5'].toString();

                                        promo_price = data['promo_price5'];
                                        price = data['price5'];
                                      });
                                    }):Text(''),
                                    data['weight6']!=0 && data['stock6']!=0?buildWeightChoices(data['weight6'].toString(),color6,select6,(){
                                      setState(() {
                                        select6 = true;
                                        select1 = false;
                                        select2 = false;
                                        select3 = false;
                                        select4 = false;
                                        select5 = false;

                                        select1 == true?color1 = Colors.red.shade900:color1 = Colors.black;
                                        select2 == true?color2 = Colors.red.shade900:color2 = Colors.black;
                                        select3 == true?color3 = Colors.red.shade900:color3 = Colors.black;
                                        select4 == true?color4 = Colors.red.shade900:color4 = Colors.black;
                                        select5 == true?color5 = Colors.red.shade900:color5 = Colors.black;
                                        select6 == true?color6 = Colors.red.shade900:color6 = Colors.black;

                                        selectedWeight = data['weight6'].toString();

                                        promo_price = data['promo_price6'];
                                        price = data['price6'];
                                      });
                                    }):Text(''),
                                  ],
                                ),
                              ),
                            ],
                          )
                      ),
                    ),

                    toShow == false?SizedBox():Container(color: Colors.grey.shade300,width: screenWidth,height: 10),

                    Container(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.only(left: isTablet == true?30:20),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: isTablet == true?20:10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: isTablet == true?45:30,
                                backgroundColor: themeColour,
                                backgroundImage: NetworkImage(data['postOwnerprofileUrl']),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: isTablet == true?25:15.0,top: 5),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(data['postOwnerName'],style: TextStyle(fontSize: isTablet == true?25:15,fontWeight: FontWeight.bold)),
                                    SizedBox(height: 5),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(Icons.location_on_sharp,color: themeColour,size: isTablet?20:15),
                                        SizedBox(width: 5),
                                        Text('สถานที่ตั้งร้าน',style: TextStyle(fontSize: isTablet == true?18:12,color: Colors.black,fontWeight: FontWeight.bold),maxLines: 2),
                                      ],
                                    ),
                                    Container(
                                      alignment: Alignment.topLeft,
                                      width: MediaQuery.of(context).size.width*4/6,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(data['location1'],style: TextStyle(fontSize: isTablet == true?15:10,color: Colors.black),maxLines: 2),
                                          Text(data['location2'],style: TextStyle(fontSize: isTablet == true?15:10,color: Colors.black),maxLines: 2)
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),

                    data['description'] == ''?SizedBox():Container(color: Colors.grey.shade300,width: screenWidth,height: 10),

                    data['description'] == ''?SizedBox():Container(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: isTablet?20:10),
                            Text('ข้อมูลทั่วไป',style: TextStyle(color: Colors.black,fontSize: isTablet == true?30:20,fontWeight: FontWeight.bold)),
                            builddivider(),
                            data['description'] == ''?SizedBox(height: isTablet?20:20):Padding(
                              padding: EdgeInsets.only(right: 20.00,top: 20,bottom: 20),
                              child: Text(data['description'],style: TextStyle(fontSize: isTablet == true?20:16),),
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),

                    Container(color: Colors.grey.shade300,width: screenWidth,height: 10),
                    commentList.isEmpty?SizedBox():Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('รีวิวสินค้า',style: TextStyle(color: Colors.grey.shade600,fontSize: isTablet?30:20.0,fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    RatingBarIndicator(
                                      rating: average_score!.toDouble(),
                                      itemCount: 5,
                                      itemSize: isTablet?30:20.0,
                                      itemBuilder: (context,_)=>Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Text('(${average_score}/5)',style: TextStyle(color: Colors.grey.shade600))
                                  ],
                                ),
                                InkWell(
                                  child: Text('อ่านทั้งหมด (${commentsNum}) >',style: TextStyle(color: themeColour,fontSize: isTablet?20:16)),
                                  onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                      showComments(
                                        ownerId: ownerId,
                                        type: data['type'],
                                        coverProfile: data['coverProfile'],
                                        topic: topicName,
                                        userId: widget.userId,
                                      ))),
                                )
                              ],
                            ),
                            Divider(color: themeColour),
                            ListView.builder(
                                shrinkWrap: true,
                                itemCount: commentList.length,
                                itemBuilder: (context,i){
                                  var now = DateTime.now();
                                  var lastnight = DateTime(now.year,now.month,now.day);
                                  final DateFormat formatter = DateFormat('dd-MMM-yyyy');

                                  return Column(
                                    children: [
                                      ListTile(
                                        leading: CircleAvatar(
                                          radius: isTablet?30:20.0,
                                          backgroundColor: commentList.reversed.elementAt(i).buyerImgUrl != ""?themeColour:Colors.white,
                                          backgroundImage: commentList.reversed.elementAt(i).buyerImgUrl != ""?NetworkImage(commentList.reversed.elementAt(i).buyerImgUrl):null,
                                          child: commentList.reversed.elementAt(i).buyerImgUrl == ""
                                              ?Center(
                                              child: Icon(FontAwesomeIcons.userAlt,color: Colors.black),
                                              )
                                              :null,
                                        ),
                                        title: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(commentList.reversed.elementAt(i).buyerName,style: TextStyle(fontSize: isTablet?20:16.0)),
                                                    Text(commentList.reversed.elementAt(i).breed.toString(),style: TextStyle(color: Colors.grey.shade600,fontSize: isTablet?18:14.0)),
                                                    SizedBox(height: 10)
                                                  ],
                                                ),
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    RatingBarIndicator(
                                                      rating: commentList.reversed.elementAt(i).score,
                                                      itemCount: 5,
                                                      itemSize: isTablet?24:16.0,
                                                      itemBuilder: (context,_)=>Icon(
                                                        Icons.star,
                                                        color: Colors.amber,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    commentList.reversed.elementAt(i).timestamp.toDate().isBefore(lastnight)
                                                        ?Row(
                                                      children: [
                                                        Text(formatter.format(commentList.reversed.elementAt(i).timestamp.toDate()),style: buildTextStyleDateTime()),
                                                        SizedBox(width: 5),
                                                        Text(DateFormat.Hm().format(commentList.reversed.elementAt(i).timestamp.toDate()),style: buildTextStyleDateTime())
                                                      ],
                                                    ):Row(
                                                      children: [
                                                        Text('Today',style: buildTextStyleDateTime()),
                                                        SizedBox(width: 5),
                                                        Text(DateFormat.Hm().format(commentList.reversed.elementAt(i).timestamp.toDate()),style: buildTextStyleDateTime())
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Text(commentList.reversed.elementAt(i).comment,style: TextStyle(fontSize: isTablet?20:16.0,)),

                                            commentList.reversed.elementAt(i).reviewImg01 == 'reviewImage1' && commentList[i].reviewImg02 == 'reviewImage2' ?SizedBox():Row(
                                              children: [
                                                commentList.reversed.elementAt(i).reviewImg01 == 'reviewImage1'? SizedBox():imageContainer(i,commentList.reversed.elementAt(i).reviewImg01.toString()),
                                                commentList.reversed.elementAt(i).reviewImg02 == 'reviewImage2'? SizedBox():imageContainer(i,commentList.reversed.elementAt(i).reviewImg02.toString()),
                                              ],
                                            ),
                                            SizedBox(height: 5),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                widget.userId == commentList.reversed.elementAt(i).buyerId
                                                    ?InkWell(child: Row(
                                                  children: [
                                                    Icon(LineAwesomeIcons.tools,color: Colors.grey.shade600,size: isTablet?22:18.0,),
                                                    SizedBox(width: 5),
                                                    Text('แก้ไข',style: TextStyle(color: Colors.grey.shade600,fontSize: isTablet?16:12.0,))
                                                  ],
                                                ),onTap:()=>
                                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                                    rateAndReviewEdit(
                                                      commentId: commentList.reversed.elementAt(i).commentId,
                                                      imageUrl: data['coverProfile'],
                                                      topic: data['topicName'],
                                                      breed: commentList.reversed.elementAt(i).breed,
                                                      score: commentList.reversed.elementAt(i).score,
                                                      reviewImage01: commentList.reversed.elementAt(i).reviewImg01,
                                                      reviewImage02: commentList.reversed.elementAt(i).reviewImg02,
                                                      comment: commentList.reversed.elementAt(i).comment,
                                                    ))).then((value){
                                                      setState(() {
                                                        setState(() {
                                                          isLoading = true;
                                                        });
                                                        getStar();
                                                        getComment(true);
                                                      });
                                                    }))
                                                    :SizedBox()
                                              ],
                                            ),

                                          ],
                                        ),
                                      ),
                                      Divider(color: Colors.grey.shade500)
                                    ],
                                  );
                                }
                            )
                          ],
                        ),
                      ),
                    ),
                  ],);
              }
              return Text('Loading');
            }
      ),
      bottomNavigationBar: isLoading == true || toShow == false
          ?SizedBox()
          :SizedBox(
          height: isTablet == true?80:60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(color: bottomNavigationColor,width: 10),
              InkWell(
                child: Container(
                  height: isTablet == true?80:60,
                  width: isTablet == true?200:70,
                  color: bottomNavigationColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(FontAwesomeIcons.commentDots, color: themeColour,size: isTablet == true?30:20),
                      SizedBox(height: 7),
                      Text("แชท", style: TextStyle(color: Colors.grey.shade900,fontSize:  isTablet == true?15:10))
                    ],
                  ),
                ),
                onTap: ()=>
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>chatroom(
                      userid: widget.userId,
                      peerid: ownerId,
                      peerImg: ownerUrl,
                      userImg: userUrl,
                      peerName: ownerName,
                      userName: userName,
                      postid: widget.postId,
                      priceMin: priceMin!>0?priceMin:0,
                      priceMax: priceMax!>0?priceMax:0,
                      pricePromoMin: pricePromoMin!>0?pricePromoMin:0,
                      pricePromoMax: pricePromoMax!>0?pricePromoMax:0,
                    ))),
              ),
              Container(
                color: bottomNavigationColor,
                height: isTablet == true?80:60,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: VerticalDivider(color: Colors.grey),
                ),
              ),
              InkWell(
                child: Container(
                  width: isTablet == true?200:100,
                  height: isTablet == true?80:60,
                  color: bottomNavigationColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.shopping_cart_outlined, color: themeColour,size: isTablet == true?35:25),
                      SizedBox(height: 5),
                      Text("เพิ่มลงในรถเข็น", style: TextStyle(color: Colors.grey.shade900,fontSize: isTablet == true?15:10))],
                  ),
                ),
                onTap: (){
                  resetStock();
                  _showBottomSheet(context,'addToCart');
                  prev_qty = 0;
                  qty = 1;
                },
              ),
              Container(height: isTablet == true?80:60,color: bottomNavigationColor,width: 10),
              Expanded(
                child: Container(
                  color: bottomNavigationColor,
                  child: InkWell(
                    child: Container(
                      height: isTablet == true?80:60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        color: Colors.red.shade900,
                      ),
                      child: Text("ซื้อเลย", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: isTablet == true?23:18)),
                    ),
                    onTap: (){
                      _showBottomSheet(context,'buyNow');
                    },
                  ),
                ),
              ),
              Container(color: bottomNavigationColor,width: 10),
            ],
          ),
      ),
    ),
        );
  }

  TextStyle buildTextStyleDateTime() => TextStyle(fontSize: isTablet?16:10,color: Colors.grey.shade600);

  Padding imageContainer(int i,String imgUrl) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0,top: 10),
      child: InkWell(
        child: Container(
            height: isTablet?150:80,
            width: isTablet?150:80,
            child: Image.network(imgUrl,fit: BoxFit.fitHeight,)
        ),
        onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>showNetworkImage(image: imgUrl))),
      ),
    );
  }

  Padding buildWeightChoices(String text,Color color,bool select,Function() ontap) {
    return text != ''?Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet == true?5.0:3.0),
      child: InkWell(
          child: Container(
            width: isTablet == true? 120:70,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                border: Border.all(color: select == false? Colors.grey: Colors.red.shade900,width: select == true? 2:1)
            ),
            child: Text('${text} kg',style: TextStyle(color: color,fontWeight:color == Colors.red.shade900?FontWeight.bold:FontWeight.normal,fontSize: isTablet == true?23:15 )),
          ),
          onTap: ontap
      ),
    ):Padding(padding: EdgeInsets.all(0),child: Text(''));
  }

  Padding builddivider() => Padding(padding: EdgeInsets.only(right: 40),child: Divider(color: Colors.grey));

  Padding buildRow(String topic, String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children:
        [
          Text(topic,style: topicStyle.copyWith(fontSize: isTablet == true?25:15)),
          Text(detail,style: topicStyle.copyWith(fontSize: isTablet == true?25:15,fontWeight: FontWeight.normal)),
          SizedBox(height: 40)
        ],
      ),
    );
  }

  showAlertDialog(BuildContext context) {

    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.transparent,
      title: Center(
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              color: Colors.white
          ),
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Center(
              child: Column(
                children: [
                  Icon(FontAwesomeIcons.cartPlus,color: Colors.green,size: 40),
                  SizedBox(height: 20),
                  Text("เพิ่มรายการเรียบร้อย",style: TextStyle(color: Colors.green.shade900,fontSize: isTablet == true?20:15)),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future.delayed(Duration(milliseconds: 500),()=> Navigator.of(context).pop());
        return alert;
      },
    );
  }

  Future<dynamic> showSoldOutAlertDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) =>
        Platform.isIOS ?
        CupertinoAlertDialog(
          title: Text('แจ้งเตือน'),
          content: Text('ขออภัย สิ้นค้าบางรายการในตระกร้าถูกขายหมดแล้ว'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('รับทราบ',style: TextStyle(color: Colors.blueAccent)),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        ) :
        AlertDialog(
          title: Text('แจ้งเตือน'),
          content: Text('ขออภัย สิ้นค้าบางรายการในตระกร้าถูกขายหมดแล้ว'),
          actions: <Widget>[
            InkWell(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text('รับทราบ',style: TextStyle(color: Colors.blueAccent)),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        )
    );
  }

  _showBottomSheet(context,String type){
    showModalBottomSheet(context: context,backgroundColor: Colors.transparent ,builder: (BuildContext bc){
      var f = new NumberFormat("#,###", "en_US");
      stock = 0;

      return FutureBuilder<DocumentSnapshot>(
          future: postsFoodRef.doc(widget.postId).get(),
          builder: (context,snapshot){
            if(!snapshot.hasData){
              return loadingWithReturn(context);
            }else if(snapshot.hasData){
              Map<String,dynamic> data = snapshot.data!.data() as Map<String,dynamic>;

              return StatefulBuilder(
                  builder: (BuildContext context,setState){
                    return Container(
                        height: MediaQuery.of(context).size.height*0.5,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
                            color: Colors.white
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: MediaQuery.of(context).size.height*0.20,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.network(data['coverProfile'],fit: BoxFit.fitHeight),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          promo_price == 0? Text(''):promo_price == null && data['maxPromo'] == 0 && data['minPromo'] == 0? Text('')
                                              : promo_price == null && data['maxPromo'] != 0 && data['minPromo'] != 0
                                              ? Text('฿ ${f.format(data['minPromo'])} - ${f.format(data['maxPromo'])}',style: textStyle())
                                              :promo_price == null && data['maxPromo'] != 0 && data['minPromo'] == 0
                                              ? Text('฿ ${f.format(data['maxPromo'])}',style: textStyle())
                                              :promo_price == null && data['maxPromo'] == 0 && data['minPromo'] != 0
                                              ? Text('฿ ${f.format(data['minPromo'])}',style: textStyle())
                                              :Text('฿ ${f.format(promo_price)}',style: textStyle()),

                                          SizedBox(height: 10),
                                          price == null && data['maxPrice'] != 0 && data['maxPrice'] != 0
                                              ? Text('฿ ${f.format(data['maxPrice'])} - ${f.format(data['maxPrice'])}',style: data['maxPrice'] != 0 ?textStyleLineThrough():textStyle())
                                              :price == null && data['maxPrice'] != 0 && data['minPrice'] == 0
                                              ? Text('฿ ${f.format(data['maxPrice'])}',style: promo_price != 0?textStyleLineThrough():textStyle())
                                              :promo_price == null && data['maxPrice'] == 0 && data['minPrice'] != 0
                                              ? Text('฿ ${f.format(data['minPrice'])}',style: promo_price != 0?textStyleLineThrough():textStyle())
                                              :Text('฿ ${f.format(price)}',style: promo_price != 0?textStyleLineThrough():textStyle()),
                                          SizedBox(height: 10),
                                          stock == 0 ? Text(''):Text('คงเหลือ: ${stock.toString()}',style: TextStyle(fontSize: isTablet == true?20:15))
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: isTablet == true?20.0:0),
                                child: Text('ตัวเลือก',style: TextStyle(fontSize: isTablet == true?21:15)),
                              ),
                              Container(
                                height: 50,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    data['weight1']!=0 && data['stock1']!=0?buildWeightChoices(data['weight1'].toString(),color1,select1,(){
                                      setState(() {
                                        select1 = true;
                                        select2 = false;
                                        select3 = false;
                                        select4 = false;
                                        select5 = false;
                                        select6 = false;

                                        select1 == true?color1 = Colors.red.shade900:color1 = Colors.black;
                                        select2 == true?color2 = Colors.red.shade900:color2 = Colors.black;
                                        select3 == true?color3 = Colors.red.shade900:color3 = Colors.black;
                                        select4 == true?color4 = Colors.red.shade900:color4 = Colors.black;
                                        select5 == true?color5 = Colors.red.shade900:color5 = Colors.black;
                                        select6 == true?color6 = Colors.red.shade900:color6 = Colors.black;

                                        selectedWeight = data['weight1'].toString();

                                        promo_price = data['promo_price1'];
                                        price = data['price1'];
                                        stock = data['stock1'];

                                        if(qty > stock){
                                          setState(() {
                                            qty = stock;
                                          });
                                        }
                                      });
                                    }):Text(''),
                                    data['weight2']!=0 && data['stock2']!=0?buildWeightChoices(data['weight2'].toString(),color2,select2,(){
                                      setState(() {
                                        select2 = true;
                                        select1 = false;
                                        select3 = false;
                                        select4 = false;
                                        select5 = false;
                                        select6 = false;

                                        select1 == true?color1 = Colors.red.shade900:color1 = Colors.black;
                                        select2 == true?color2 = Colors.red.shade900:color2 = Colors.black;
                                        select3 == true?color3 = Colors.red.shade900:color3 = Colors.black;
                                        select4 == true?color4 = Colors.red.shade900:color4 = Colors.black;
                                        select5 == true?color5 = Colors.red.shade900:color5 = Colors.black;
                                        select6 == true?color6 = Colors.red.shade900:color6 = Colors.black;

                                        selectedWeight = data['weight2'].toString();

                                        promo_price = data['promo_price2'];
                                        price = data['price2'];
                                        stock = data['stock2'];

                                        if(qty > stock){
                                          setState(() {
                                            qty = stock;
                                          });
                                        }
                                      });
                                    }):Text(''),
                                    data['weight3']!=0 && data['stock3']!=0?buildWeightChoices(data['weight3'].toString(),color3,select3,(){
                                      setState(() {
                                        select3 = true;
                                        select1 = false;
                                        select2 = false;
                                        select4 = false;
                                        select5 = false;
                                        select6 = false;

                                        select1 == true?color1 = Colors.red.shade900:color1 = Colors.black;
                                        select2 == true?color2 = Colors.red.shade900:color2 = Colors.black;
                                        select3 == true?color3 = Colors.red.shade900:color3 = Colors.black;
                                        select4 == true?color4 = Colors.red.shade900:color4 = Colors.black;
                                        select5 == true?color5 = Colors.red.shade900:color5 = Colors.black;
                                        select6 == true?color6 = Colors.red.shade900:color6 = Colors.black;

                                        selectedWeight = data['weight3'].toString();

                                        promo_price = data['promo_price3'];
                                        price = data['price3'];
                                        stock = data['stock3'];

                                        if(qty > stock){
                                          setState(() {
                                            qty = stock;
                                          });
                                        }
                                      });
                                    }):Text(''),
                                    data['weight4']!=0 && data['stock4']!=0?buildWeightChoices(data['weight4'].toString(),color4,select4,(){
                                      setState(() {
                                        select4 = true;
                                        select1 = false;
                                        select2 = false;
                                        select3 = false;
                                        select5 = false;
                                        select6 = false;

                                        select1 == true?color1 = Colors.red.shade900:color1 = Colors.black;
                                        select2 == true?color2 = Colors.red.shade900:color2 = Colors.black;
                                        select3 == true?color3 = Colors.red.shade900:color3 = Colors.black;
                                        select4 == true?color4 = Colors.red.shade900:color4 = Colors.black;
                                        select5 == true?color5 = Colors.red.shade900:color5 = Colors.black;
                                        select6 == true?color6 = Colors.red.shade900:color6 = Colors.black;

                                        selectedWeight = data['weight4'].toString();

                                        promo_price = data['promo_price4'];
                                        price = data['price4'];
                                        stock = data['stock4'];

                                        if(qty > stock){
                                          setState(() {
                                            qty = stock;
                                          });
                                        }
                                      });
                                    }):Text(''),
                                    data['weight5']!=0 && data['stock5']!=0?buildWeightChoices(data['weight5'].toString(),color5,select5,(){
                                      setState(() {
                                        select5 = true;
                                        select1 = false;
                                        select2 = false;
                                        select3 = false;
                                        select4 = false;
                                        select6 = false;

                                        select1 == true?color1 = Colors.red.shade900:color1 = Colors.grey;
                                        select2 == true?color2 = Colors.red.shade900:color2 = Colors.grey;
                                        select3 == true?color3 = Colors.red.shade900:color3 = Colors.grey;
                                        select4 == true?color4 = Colors.red.shade900:color4 = Colors.grey;
                                        select5 == true?color5 = Colors.red.shade900:color5 = Colors.grey;
                                        select6 == true?color6 = Colors.red.shade900:color6 = Colors.grey;

                                        selectedWeight = data['weight5'].toString();

                                        promo_price = data['promo_price5'];
                                        price = data['price5'];
                                        stock = data['stock5'];

                                        if(qty > stock){
                                          setState(() {
                                            qty = stock;
                                          });
                                        }
                                      });
                                    }):Text(''),
                                    data['weight6']!=0 && data['stock6']!=0?buildWeightChoices(data['weight6'].toString(),color6,select6,(){
                                      setState(() {
                                        select6 = true;
                                        select1 = false;
                                        select2 = false;
                                        select3 = false;
                                        select4 = false;
                                        select5 = false;

                                        select1 == true?color1 = Colors.red.shade900:color1 = Colors.grey;
                                        select2 == true?color2 = Colors.red.shade900:color2 = Colors.grey;
                                        select3 == true?color3 = Colors.red.shade900:color3 = Colors.grey;
                                        select4 == true?color4 = Colors.red.shade900:color4 = Colors.grey;
                                        select5 == true?color5 = Colors.red.shade900:color5 = Colors.grey;
                                        select6 == true?color6 = Colors.red.shade900:color6 = Colors.grey;

                                        selectedWeight = data['weight6'].toString();

                                        promo_price = data['promo_price6'];
                                        price = data['price6'];
                                        stock = data['stock6'];

                                        if(qty > stock){
                                          setState(() {
                                            qty = stock;
                                          });
                                        }
                                      });
                                    }):Text(''),
                                  ],
                                ),
                              ),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: isTablet == true?20.0:0),
                                    child: Text('จำนวน',style: TextStyle(fontSize: isTablet == true?21:15)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: isTablet == true?20.0:0),
                                    child: Row(
                                      children: [
                                        InkWell(
                                          child: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey.shade300)
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: isTablet == true?15:5,vertical: isTablet == true?10:3),
                                              child: Icon(Icons.remove,color: Colors.grey.shade600,size: isTablet == true?22:18),
                                            ),
                                          ),
                                          onTap: (){
                                            setState(() {
                                              qty>1?qty-=1:qty = qty;
                                            });
                                          },
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(color: Colors.grey.shade300)
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: isTablet == true?25:15,vertical: isTablet == true?7:1),
                                            child: Text(qty.toString(),style: TextStyle(fontSize: isTablet == true?20:15)),
                                          ),
                                        ),
                                        InkWell(
                                          child: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey.shade300)
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: isTablet == true?15:5,vertical: isTablet == true?9:3),
                                              child: Icon(Icons.add,color: Colors.grey.shade600,size: isTablet == true?24:18,),
                                            ),
                                          ),
                                          onTap: (){
                                            setState(() {
                                              qty<stock?qty+=1:qty = qty;
                                            });
                                          },
                                        ),
                                        SizedBox(width: 10)
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.0,vertical: 20),
                                child: InkWell(
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: isTablet == true?80:40,
                                    width: MediaQuery.of(context).size.width,
                                    color: stock == 0? Colors.grey:themeColour,
                                    child: type == 'buyNow'?Text('ซื้อเลย',style: TextStyle(color: Colors.white,fontSize: isTablet == true?23:16)):Text('เพิ่มลงในรถเข็น',style: TextStyle(color: Colors.white,fontSize: isTablet == true?23:16)),
                                  ),
                                  onTap: (){
                                    if(stock == 0){}else if(stock != 0 && type == 'addToCart'){
                                      addToCart(profile.toString(), topicName.toString(),selectedWeight.toString() ,price!, promo_price! , qty, brand.toString(),data['type']);
                                      prev_qty = 0;
                                      qty = 1;
                                      showAlertDialog(context);
                                      Future.delayed(const Duration(milliseconds: 500), () {
                                        setState(() {
                                          getCart();
                                        });
                                      });
                                    }else{
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                          checkOut(
                                            userId: widget.userId,
                                            postId: widget.postId,
                                            fromPage: 'buyNow',
                                            userName: userName.toString(),
                                            type: 'foods',
                                            subType: data['type'],
                                            sellerId: ownerId,
                                            sellerName: ownerName,
                                            imageUrl: imagesList[0],
                                            topicName: topicName,
                                            weight: selectedWeight,
                                            price: price,
                                            promo: promo_price,
                                            quantity: qty,
                                            brand: brand,
                                          )
                                      )).then((value){
                                        getCart();
                                      });
                                    }
                                  },
                                ),
                              )
                            ],
                          ),
                        )
                    );
                  });
            }return Text('a');
          });
    });
  }

  Container basicInfo(double screenWidth, Map<String, dynamic> data, double screenHeight, BuildContext context,int priceMin,int priceMax,int promo_priceMin,int promo_priceMax,int? price,int? promo_price) {

    var f = new NumberFormat("#,###", "en_US");
    List<String> months = ['ม.ค.','ก.พ.','มี.ค.','เม.ษ.','พ.ค.','มิ.ย.','ก.ค.','ส.ค.','ก.ย.','ต.ค.','พ.ย.','ธ.ค.'];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        color: Colors.white,
      ),
      alignment: Alignment.topLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isTablet == true?20:10),
          Text('${data['topicName'].toString()} '
              ,style: TextStyle(fontWeight: FontWeight.bold,fontSize: isTablet == true?30:15),maxLines: 3),
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Visibility(
                        visible: data['isPromo'] == true,
                        child: promo_price != null && promo_price != 0
                            ? Text('฿ ${f.format(promo_price)}',style: textStyle())
                            :promo_priceMax!=promo_priceMin && price == null
                            ? Text('฿ ${f.format(promo_priceMin)}-${f.format(promo_priceMax)}',
                            style: textStyle())
                            :promo_priceMax !=0 && price == null
                            ? Text('฿ ${f.format(promo_priceMax)}',
                            style: textStyle()):SizedBox()
                        ),

                    SizedBox(height: 5),

                    toShow == false?Text('Out of stock',style: TextStyle(color: themeColour,fontWeight: FontWeight.bold,fontSize: isTablet?30:20)):
                    price != null && price != 0? Text('฿ ${f.format(price)}',style: data['isPromo'] == true && promo_price !=0 ? textStyleLineThrough():textStyle()):priceMax!=priceMin?
                    Text('฿ ${f.format(priceMin)}-${f.format(priceMax)}',
                        style: data['isPromo'] == true
                            ? textStyleLineThrough()
                            : textStyle())
                        :Text('฿ ${f.format(priceMax)}',
                        style: data['isPromo'] == true
                            ?textStyleLineThrough()
                            :textStyle()
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Row(
                    children: [
                      // Icon(FontAwesomeIcons.clock,color: Colors.grey,size: 15),
                      // SizedBox(width: 10),
                      // Text('วันหมดอายุ : ${months[data['expiryMonth']]} ${data['expiryYear']}'),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle textStyleLineThrough() => TextStyle(fontWeight: FontWeight.bold,color: Colors.grey,fontSize: isTablet == true?18:13,decoration: TextDecoration.lineThrough);

  TextStyle textStyle() => TextStyle(color: Colors.red.shade900,fontSize: isTablet == true?25:20,fontWeight: FontWeight.bold);

}
