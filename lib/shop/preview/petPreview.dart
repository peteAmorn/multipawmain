import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/src/intl/number_format.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:multipawmain/chat/chatroom.dart';
import 'package:multipawmain/authCheck.dart';
import 'package:multipawmain/database/breedDatabase.dart';
import 'package:multipawmain/database/posts.dart';
import 'package:multipawmain/questionsAndConditions/conditionBuyer.dart';
import 'package:multipawmain/shop/showComments.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:multipawmain/support/showNetworkImage.dart';
import 'package:multipawmain/support/showPedigreePetImages.dart';
import 'package:sizer/sizer.dart';
import '../../authScreenWithoutPet.dart';
import '../../ratingAndReviewEdit.dart';
import '../checkOut.dart';
import '../myCart.dart';

int? pet_price;
String? patternToShow;

final DateTime timestamp = DateTime.now();

class petPreview extends StatefulWidget {
  final userId,postId,ownerId,isOwner;

  petPreview({
    required this.postId,
    required this.ownerId,
    required this.userId,
    required this.isOwner
  });

  @override
  _petPreviewState createState() => _petPreviewState();
}

class _petPreviewState extends State<petPreview> {
  final CarouselController _controller = CarouselController();
  String? userUrl, userName, userId,houseNo,moo,road,subdistrict,district,city,postCode;
  String? ownerUrl, ownerName, ownerId,sellerName,subType;
  bool isLoading = false;
  bool selfPickup = true;
  bool airDelivery = false;
  String? img,topic,breed;
  int? price,birthDate,birthMonth,birthYear,dispatchDate,dispatchMonth,dispatchYear;
  List<double> scores = [];
  List<reviewDetail> commentList = [];
  int? average_score, commentsNum;
  int item_in_cart = 0;

  Color bottomNavigationColor = Colors.white;

  bool select1 = false;
  bool select2 = false;

  Color color1 = Colors.black;
  Color color2 = Colors.black;

  String? seller;
  bool isDeviceConnected = false;
  bool isTablet = false;

  checkInternetConnection()async{
    bool result = await InternetConnectionChecker().hasConnection;
    result == true? isDeviceConnected = true: isDeviceConnected = false;
  }

  Center noInternetPage(){
    return Center(
      child: InkWell(
        child: Text('No internet Connection'),
        onTap: (){
          Navigator.pop(context);
        },
      ),
    );
  }

  List<String> imagesList = [];
  List<String> pedigreeList = [];

  getUserInfo()async{
    await usersRef.doc(widget.userId).get().then((snapshot) => {
      userUrl = snapshot.data()!['urlProfilePic'],
      userName = snapshot.data()!['name'],
      userId = snapshot.data()!['id'],
    });
    await postsPuppyKittenRef.doc(widget.postId).get().then((snapshot){
      sellerName = snapshot.data()!['postOwnerName'];
      img = snapshot.data()!['coverProfile'];
      topic = snapshot.data()!['topicName'];
      price = snapshot.data()!['price'];
      breed = snapshot.data()!['breed'];
      img = snapshot.data()!['coverProfile'];
      subType = snapshot.data()!['type'];

      birthDate = snapshot.data()!['birthDay'];
      birthMonth = snapshot.data()!['birthMonth'];
      birthYear = snapshot.data()!['birthYear'];

      dispatchDate = snapshot.data()!['dispatchDate'];
      dispatchMonth = snapshot.data()!['dispatchMonth'];
      dispatchYear = snapshot.data()!['dispatchYear'];
    });
    await usersRef.doc(widget.ownerId).collection('storeLocationAndDeliveryOption').doc(widget.ownerId).get().then((snapshot) => {
      if(snapshot.exists){
        houseNo = snapshot.data()!['houseNo'],
        moo = snapshot.data()!['moo'],
        road = snapshot.data()!['road'],
        subdistrict = snapshot.data()!['subdistrict'],
        district = snapshot.data()!['district'],
        city = snapshot.data()!['city'],
        postCode = snapshot.data()!['postCode'].toString(),

        selfPickup = snapshot.data()!['selfPickup'],
        airDelivery = snapshot.data()!['airDelivery'],
      }
    });
  }

  getComment(bool isStopLoading)async{
    commentList.clear();
    Query q = commentsRef.where('sellerId',isEqualTo: widget.ownerId).where('type',isEqualTo: 'pet').limit(2);
    QuerySnapshot querySnapshot = await q.get();
    querySnapshot.docs.forEach((doc) {
      commentList.add(reviewDetail.fromDocument(doc));

    });

    await commentsRef..where('sellerId',isEqualTo: widget.ownerId).where('type',isEqualTo: 'pet').get().then((snap) => commentsNum = snap.size);
    setState(() {
      isStopLoading == true?isLoading = false:null;
    });
  }

  addToCart(String img,int price,int qty,int dispatchDate, int dispatchMonth, int dispatchYear)async{
    bool forbidAirTransport = false;
    for(var j = 0;j<banOnPlaneTransport.length;j++){
      if(breed == banOnPlaneTransport[j]){
        forbidAirTransport = true;
      }
    }
    await usersRef.doc(widget.userId).collection('myCart').where('postid',isEqualTo: widget.postId).get().then((snapshot){
      if(snapshot.size == 0){
        usersRef.doc(widget.userId).collection('myCart').doc(widget.postId).set({
          'id':ownerId,
          'postid': widget.postId,
          'check': false,
          'imageUrl': img,
          'topicName': topic,
          'price': price,
          'quaity': 1,
          'type': 'pet',
          'subType': subType,
          'subTotal': price,
          'timestamp':timestamp,
          'stock': 1,
          'isOwner':widget.isOwner,
          'sellerName': sellerName,
          'promo': 0,
          'breed': breed,
          'deliMethod': 'รับเองที่ฟาร์ม',
          'deliPrice': 0,
          'dispatchDate': dispatchDate,
          'dispatchMonth': dispatchMonth,
          'dispatchYear': dispatchYear,
          'brand': '0',
          'airPickUpShow': false,
          'forbidAirTransport': forbidAirTransport
        });
      }else{}
    });
  }

  viewUpdate()async{
    int? current_views;
    await postsPuppyKittenRef.doc(widget.postId).get().then((snapshot) => {
      if(snapshot.data()!.length>0){
        current_views = snapshot.data()!['view'],

        postsPuppyKittenRef.doc(widget.postId).update({
          'view':current_views!+1
        })
      }
    });
  }

  getImg()async{
    await postsPuppyKittenRef.doc(widget.postId).get().then((snapshot){
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

  getCart()async{
    await usersRef.doc(widget.userId).collection('myCart').get().then((snap){
      item_in_cart = snap.size;
    });
  }

  Future<dynamic> showSoldOutAlertDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) =>
        Platform.isIOS ?
        CupertinoAlertDialog(
          title: Text('แจ้งเตือน'),
          content: Text('ขออภัย มีคนซื้อน้องไปแล้ว'),
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
          content: Text('ขออภัย มีคนซื้อน้องไปแล้ว'),
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

  getStar()async{
    scores.clear();
    await commentsRef.where('type',isEqualTo: 'pet').get().then((snapshot){
      snapshot.docs.forEach((data) {
        commentsRef.doc(data.id).get().then((snap){
          scores.add(snap.data()!['score'].toDouble());
        });
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
    checkInternetConnection();
    getStar();
    getUserInfo();
    viewUpdate();
    getCart();
    getImg();
    getComment(false);

    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() {
        commentList.length == 0?average_score = 0:average_score = (scores.reduce((a, b) => a+b)/scores.length).toInt();
        isLoading = false;
      });
    });
  }



  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    DateTime now = DateTime.now();


    DateFormat yearformatter = DateFormat('yyyy');
    String yearString = yearformatter.format(now);
    int currentYear = int.parse(yearString);

    DateFormat monthformatter = DateFormat('MM');
    String monthString = monthformatter.format(now);
    int currentMonth = int.parse(monthString);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade300,
        body: isLoading == true?loadingWithReturn(context):FutureBuilder<DocumentSnapshot>(
            future: postsPuppyKittenRef.doc(widget.postId).get(),
            builder: (BuildContext context,AsyncSnapshot<DocumentSnapshot> snapshot){
              if(!snapshot.hasData){
                return loadingWithReturn(context);
              }else if(snapshot.hasData){

                var ageYear = (( (currentYear - (1+snapshot.data!['birthYear'])) *12 + (12- snapshot.data!['birthMonth']) + currentMonth) )~/12.floor();
                var ageMonth =(( (currentYear - (1+snapshot.data!['birthYear']))) *12 + (12- snapshot.data!['birthMonth']) + currentMonth)%12;

                Map<String,dynamic> data = snapshot.data!.data() as Map<String,dynamic>;

                String disMonth = monthList.elementAt(data['dispatchMonth']-1);

                ownerId = data['id'];
                ownerName = data['postOwnerName'];
                ownerUrl = data['postOwnerprofileUrl'];

                data['pattern'] == 'สีเดียวทั่วทั้งตัว(Solid colour)'? patternToShow = 'Solid colour'
                    : data['pattern'] == 'สีขาวพื้นบนตัวมีแถบสีอื่น(Bi-Colour)'? patternToShow = 'Bi-Colour'
                    : data['pattern'] == 'ลายแมว(Tabby)'? patternToShow = 'Tabby'
                    : data['pattern'] == 'สีผสม 2 สีบนตัว(Tortoiseshell)'? patternToShow = 'Tortoiseshell'
                    : data['pattern'] == 'สีผสม 3 สีบนตัว(Calico)'? patternToShow = 'Calico'
                    : data['pattern'] == 'สีเข้มบริเวณใบหน้า เท้า และหาง(Colour Point)'? patternToShow = 'Colour Point':null;


                return ListView(
                  children: [
                    Stack(
                        children:[
                          Column(
                            children: [
                              // Profile picture
                              CarouselSlider(
                                carouselController: _controller,
                                options: CarouselOptions(
                                  height: isTablet?screenHeight*2.15/3:screenHeight*1.9/3,
                                  viewportFraction: 1.0,
                                  enlargeCenterPage: false,
                                  enableInfiniteScroll: false,
                                ),
                                items: imagesList.map((item) => Container(
                                    width: screenWidth,
                                    height: isTablet?screenHeight*2.15/3:screenHeight*1.9/3,
                                    child: InkWell(
                                        child: Image.network(item,fit: BoxFit.cover,width: screenWidth,),
                                      onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>showNetworkImage(image: item,test: imagesList,index: imagesList.indexOf(item)))),
                                    ))).toList(),
                              ),
                              // Section below profile
                              Container(
                                width: screenWidth,
                                height: screenHeight*0.03,
                                color: themeColour,
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
                                onTap: ()=>widget.userId=='null'?
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>authScreenWithoutPet(pageIndex: 3))):
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>myCart(userId: widget.userId))).then((value){
                                  setState(() {
                                    getCart();
                                  });
                                })
                            ),
                          ),
                          item_in_cart != 0?Positioned(
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
                          ):SizedBox(),

                          // Top box basic info
                          Positioned(
                              bottom: 0,
                              child: Container(
                                  alignment: Alignment.centerLeft,
                                  width: screenWidth,
                                  height: isTablet == true?80:50,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30)),
                                      color: themeColour
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left:20.0),
                                    child: Text(data['breed'],
                                      style: TextStyle(fontSize: isTablet == true?25:20,fontWeight: FontWeight.bold,color: Colors.white),
                                    ),
                                  )
                              )
                          ),
                          data['pedigree'] == 'Yes'?Positioned(
                              top: isTablet?120:80,
                              right: 0,
                              child: Container(
                                  alignment: Alignment.centerLeft,
                                  width: isTablet == true?160:80,
                                  decoration: BoxDecoration(
                                      color: themeColour,
                                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15),topLeft: Radius.circular(15))
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 3),
                                    child: Text('  Pedigree',
                                      style: TextStyle(fontSize: isTablet == true?25:15,color: Colors.white,fontWeight: FontWeight.bold),
                                    ),
                                  )
                              )
                          ):SizedBox()
                        ]
                    ),
                    Container(
                      color: Colors.white,
                      width: screenWidth,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            basicInfo(screenWidth,data,screenHeight, context),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 10),
                    InkWell(
                      child: Container(
                          color: Colors.white,
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: EdgeInsets.only(left: 20.0,right: 10,top: isTablet == true?10:0,bottom: isTablet == true?10:0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(FontAwesomeIcons.shieldAlt,color: Colors.green,size: isTablet == true?30:23,),
                                    SizedBox(width: isTablet == true?20:10),
                                    Text('รับประกัน 7 วัน',style: TextStyle(fontSize: isTablet == true?20:15))
                                  ],
                                ),
                                IconButton(
                                    onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>conditionBuyer())),
                                    icon: Icon(Icons.arrow_forward_ios))
                              ],
                            ),
                          )),
                      onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>conditionBuyer())),
                    ),
                    SizedBox(height: 10),
                    Container(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.only(left:  isTablet == true?30:20),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: isTablet == true?20:10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              data['postOwnerprofileUrl'] == "" || data['postOwnerprofileUrl'] == null?
                              CircleAvatar(
                                radius: isTablet == true?45:30,
                                backgroundColor: Colors.white,
                                child: Icon(FontAwesomeIcons.userAlt,color: Colors.black),
                              ) :CircleAvatar(
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
                                      width: MediaQuery.of(context).size.width*2/6,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          moo == null?
                                          Text('${houseNo} ถ.${road} ต.${subdistrict} อ.${district} จ.${city} ${postCode}',style: TextStyle(fontSize: isTablet == true?15:10,color: Colors.black),maxLines: 2) :
                                          road == null?
                                          Text('${houseNo} ม.${moo} ต.${subdistrict} อ.${district} จ.${city} ${postCode}',style: TextStyle(fontSize: isTablet == true?15:10,color: Colors.black),maxLines: 2):
                                          moo == null && road == null?
                                          Text('${houseNo} ต.${subdistrict} อ.${district} จ.${city} ${postCode}',style: TextStyle(fontSize: isTablet == true?15:10,color: Colors.black),maxLines: 2):
                                          Text('${houseNo} ม.${moo} ถ.${road} ต.${subdistrict} อ.${district} จ.${city} ${postCode}',style: TextStyle(fontSize: isTablet == true?15:10,color: Colors.black),maxLines: 2),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 10,),

                    Container(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0,vertical: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 10),
                            Text('ข้อมูลทั่วไป',style: TextStyle(color: Colors.grey.shade600,fontSize: isTablet == true?30:20,fontWeight: FontWeight.bold)),
                            SizedBox(height: 20),
                            ageYear != 0?buildRow(Icon(FontAwesomeIcons.solidClock,color: themeColour),'อายุ: ','${ageYear.toString()} ปี ${ageMonth.toString()} เดือน'):buildRow(Icon(FontAwesomeIcons.solidClock,color: themeColour),'อายุ: ','${ageMonth.toString()} เดือน'),
                            builddivider(),
                            buildRow(Icon(FontAwesomeIcons.palette,color: themeColour),'สี: ',data['colour']),
                            builddivider(),

                            data['type'] == 'แมว'?buildRow(Icon(FontAwesomeIcons.fill,color: themeColour),'แพทเทิร์น: ',patternToShow.toString()):SizedBox(),
                            data['type'] == 'แมว'?builddivider():SizedBox(),

                            buildRow(data['gender'] == 'ตัวผู้'?Icon(FontAwesomeIcons.mars,color: themeColour):Icon(FontAwesomeIcons.venus,color: themeColour),'เพศ: ',data['gender']),
                            data['pedigree'] == 'Yes'?builddivider():SizedBox(),
                            data['pedigree'] == 'Yes'?buildRow(Icon(FontAwesomeIcons.award,color: themeColour),'ใบเพ็ดดีกรี: ',data['pedType']):SizedBox(),
                            builddivider(),
                            buildRow(Icon(FontAwesomeIcons.calendarWeek,color: themeColour),'พร้อมจัดส่ง: ','${data['dispatchDate']} ${disMonth} ${data['dispatchYear']}'),
                            data['description'] == ''?SizedBox():builddivider(),
                            data['description'] == ''
                                ?SizedBox(height: 0.000001)
                                :Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 20),
                                Text('ข้อมูลเพิ่มเติม ',style: headerStyle),
                                SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: Divider(color: themeColour,thickness: 3),
                                )
                              ],
                            ),

                            data['description'] == ''?SizedBox():Padding(
                              padding: EdgeInsets.only(right: 20.00,top: 20,bottom: 20),
                              child: Text(data['description'],style: TextStyle(fontSize: isTablet == true?20:16),),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    commentList.isEmpty?SizedBox():Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('รีวิวสินค้า',style: TextStyle(color: Colors.grey.shade600,fontSize: isTablet == true?30:20,fontWeight: FontWeight.bold)),
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
                                        ownerId: widget.ownerId,
                                        type: data['type'],
                                        coverProfile: data['coverProfile'],
                                        topic: data['topicName'],
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

                                return ListTile(
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
                                                rating: commentList.reversed.elementAt(i).score.toDouble(),
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
                                                  Text(DateFormat.Hm().format(commentList.reversed.elementAt(i).timestamp.toDate()),style: buildTextStyleDateTime()),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Text(commentList[i].comment,style: TextStyle(fontSize: isTablet?20:16.0)),
                                      Row(
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
                                              ),onTap:()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                              rateAndReviewEdit(
                                                commentId: commentList.reversed.elementAt(i).commentId,
                                                imageUrl: data['coverProfile'],
                                                topic: data['topicName'],
                                                breed: data['breed'],
                                                score: commentList.reversed.elementAt(i).score,
                                                reviewImage01: commentList.reversed.elementAt(i).reviewImg01,
                                                reviewImage02: commentList.reversed.elementAt(i).reviewImg02,
                                                comment: commentList.reversed.elementAt(i).comment,
                                              ))).then((value){
                                                setState(() {
                                                  isLoading = true;
                                                });
                                                getStar();
                                                getComment(true);
                                          }))
                                              :SizedBox()
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                                }
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                  ],);
              }
              return Text('Loading');
            }
        ),
        bottomNavigationBar: widget.isOwner == true || isLoading == true?SizedBox():SizedBox(
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
                      Text("แชท", style: TextStyle(color: Colors.grey.shade900,fontSize: isTablet == true?15:10))
                    ],
                  ),
                ),
                onTap: ()=>
                widget.userId=='null'?
                Navigator.push(context, MaterialPageRoute(builder: (context)=>authScreenWithoutPet(pageIndex: 3))):
                Navigator.push(context, MaterialPageRoute(builder: (context)=>chatroom(
                      userid: widget.userId,
                      peerid: ownerId,
                      userImg: userUrl,
                      peerImg: ownerUrl,
                      userName: userName,
                      peerName: ownerName,
                      postid: widget.postId,
                      priceMin: pet_price,
                      priceMax:0,
                      pricePromoMin: 0,
                      pricePromoMax: 0,
                    ))),
              ),
              Container(
                height: isTablet == true?80:60,
                color: bottomNavigationColor,
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
                  if(widget.userId=='null'){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>authScreenWithoutPet(pageIndex: 3)));
                  }else{
                    addToCart(img.toString(),price!,1,dispatchDate!,dispatchMonth!,dispatchYear!);
                    showAlertDialog(context);
                    Future.delayed(const Duration(milliseconds: 500), () {
                      setState(() {
                        getCart();
                      });
                    });
                  }
                },
              ),
              Container(
                height: isTablet == true?80:60,
                color: bottomNavigationColor,
                width: 10,
              ),
              Expanded(
                child: InkWell(
                  child: Container(
                    color: bottomNavigationColor,
                    child: Container(
                      height:  isTablet == true?80:60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        color: Colors.red.shade900,
                      ),
                      child: Text("ซื้อเลย", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: isTablet == true?23:18)),
                    ),
                  ),
                  onTap: (){
                    if(widget.userId=='null'){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>authScreenWithoutPet(pageIndex: 3)));
                    }else {
                      bool forbidAirTransport = false;
                      for(var j = 0;j<banOnPlaneTransport.length;j++){
                        if(breed == banOnPlaneTransport[j]){
                          forbidAirTransport = true;
                        }
                      }
                      postsPuppyKittenRef.doc(widget.postId).get().then((snapshot){
                        if(snapshot.data()!['active'] == true){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>
                              checkOut(
                                userId: widget.userId,
                                fromPage: 'buyNow',
                                type: 'pet',
                                subType: subType,
                                postId: widget.postId,
                                userName: userName.toString(),
                                sellerId: widget.ownerId,
                                sellerName: ownerName,
                                imageUrl: img,
                                topicName: topic,
                                breed: breed,
                                price: price,
                                promo: 0,
                                quantity: 1,
                                deliMethod: 'รับเองที่ฟาร์ม',
                                deliPrice: 0,
                                dispatchDate: dispatchDate,
                                dispatchMonth: dispatchMonth,
                                dispatchYear: dispatchYear,
                                forbidAirTransport: forbidAirTransport,
                              ))).then((value){
                            setState(() {
                              getCart();
                            });
                          });
                        }else{
                          showSoldOutAlertDialog(context);
                        }
                      });
                      // pushToPurchase(ownerName.toString(),ownerId.toString() ,topic.toString(),breed.toString(),img.toString(),price,dispatchDate,dispatchMonth,dispatchYear);
                    }
                  }
                ),
              ),
              Container(color: bottomNavigationColor,width: 10)
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
      padding: const EdgeInsets.symmetric(horizontal: 3.0),
      child: InkWell(
          child: Container(
            width: 70,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                border: Border.all(color: select == false? Colors.grey: Colors.red.shade900,width: select == true? 2:1)
            ),
            child: Text(text,style: TextStyle(color: color,fontWeight:color == Colors.red.shade900?FontWeight.bold:FontWeight.normal )),
          ),
          onTap: ontap
      ),
    ):Padding(padding: EdgeInsets.all(0),child: Text(''));
  }

  Padding builddivider() => Padding(padding: EdgeInsets.only(right: 20),child: Divider(color: Colors.grey));

  Padding buildRow(Icon icon ,String topic, String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children:
        [
          icon,
          SizedBox(width: isTablet == true?40:20),
          Text(topic,style: topicStyle.copyWith(fontSize: isTablet == true?25:16)),
          Text(detail,style: topicStyle.copyWith(fontSize: isTablet == true?25:16,fontWeight: FontWeight.normal)),
          SizedBox(height: isTablet == true?50:40)
        ],
      ),
    );
  }

  Container basicInfo(double screenWidth, Map<String, dynamic> data, double screenHeight, BuildContext context) {

    var f = new NumberFormat("#,###", "en_US");

    pet_price = data['price'];
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        color: Colors.white,
      ),
      alignment: Alignment.topLeft,
      child: data['parentImg'] == 'Yes'

          ?Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: isTablet?4:2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 19),
                Text('${data['topicName'].toString()} '
                    ,style: TextStyle(fontWeight: FontWeight.bold,fontSize: isTablet == true?30:15),maxLines: 3),
                SizedBox(height: 5),
                pet_price!= 0 ?Text('฿ ${f.format(pet_price)}',style: TextStyle(fontWeight: FontWeight.bold,color: themeColour,fontSize: 25)):Text("Free",style: TextStyle(fontWeight: FontWeight.bold,color: themeColour,fontSize: 25)),
                SizedBox(height: 15),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(right:20.0,top: 15),
                      child: InkWell(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Parents',style: TextStyle(color: Color(0xFFD35757),fontWeight: FontWeight.bold,fontSize: isTablet == true?15:18)),
                            SizedBox(height: 2),
                            Text('แตะเพื่อดูรูปพ่อแม่',style: TextStyle(color: Colors.grey.shade700,fontSize: isTablet == true?10:12))
                          ],
                        ),
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>
                              showIPedmage(pedCover: data['dadImg'],pedFamilytree: data['mumImg'])));
                        },
                      )
                  )
                ],
              ),
            ),
          ),
        ],
      )
          :Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 13),
              Text('${data['topicName'].toString()} '
                  ,style: TextStyle(fontWeight: FontWeight.bold,fontSize: isTablet == true?30:15),maxLines: 3),
              SizedBox(height: 5),
              pet_price!= 0 ?Text('฿ ${f.format(pet_price)}',style: TextStyle(fontWeight: FontWeight.bold,color: themeColour,fontSize: 25)):Text("ฟรี",style: TextStyle(fontWeight: FontWeight.bold,color: themeColour,fontSize: isTablet == true?30:25)),
              SizedBox(height: 15),
            ],
          )
        ],
      ),
    );
  }
}
