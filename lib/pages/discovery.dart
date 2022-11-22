import 'dart:async';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:multipawmain/questionsAndConditions/questionAboutCat.dart';
import 'package:multipawmain/questionsAndConditions/questionsAboutCanine.dart';
import 'package:multipawmain/shop/myCart.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/authCheck.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:multipawmain/database/posts.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:multipawmain/chat/mychat.dart';
import 'package:multipawmain/pages/profile/profile.dart';

DateTime now = DateTime.now();
DateFormat yearformatter = DateFormat('yyyy');
String yearString = yearformatter.format(now);
int currentYear = int.parse(yearString);

DateFormat monthformatter = DateFormat('MM');
String monthString = monthformatter.format(now);
int currentMonth = int.parse(monthString);
bool isTablet = false;

late bool _checkboxPed;
int? minPrice,maxPrice;

class discovery extends StatefulWidget {
  final String? currentUserId,postId,breed,profile,type,profileOwnerId,gender;
  final double userLat,userLng;
  discovery(
      {
        this.currentUserId,
        this.postId,
        this.breed,
        this.profile,
        this.type,
        this.profileOwnerId,
        this.gender,

        required this.userLat,
        required this.userLng,
      });

  @override
  _discoveryState createState() => _discoveryState();
}

class _discoveryState extends State<discovery> with SingleTickerProviderStateMixin{
  bool isLoading = false;
  String? location, targetGender, userId;
  late String filter;
  List<discoveryList> dataList = [];
  List<discoveryList> filterList = [];
  bool isRead = true;
  int _perPage = 50;
  int item_in_cart = 0;
  var _lastDocument;
  bool msgShow = false;
  var targetAgeStart,targetAgeEnd;
  var targetDistance;

  TextEditingController maxPriceController = TextEditingController();
  TextEditingController minPriceController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  getUserData()async{
    await petsRef.doc(widget.postId).get().then((snapshot){
      targetDistance = snapshot.data()!['targetDistance'];
      targetAgeStart = snapshot.data()!['targetAgeStart'];
      targetAgeEnd = snapshot.data()!['targetAgeEnd'];
    });
  }

  getCart()async{
    await usersRef.doc(widget.currentUserId).collection('myCart').get().then((snap){
      item_in_cart = snap.size;
    });
  }

  getData()async{

    Query q = petsIndexRef.doc(widget.breed).collection(widget.breed.toString()).orderBy('timestamp', descending: true).limit(_perPage);
    try{
      QuerySnapshot querySnapshot = await q.get();
      querySnapshot.docs.forEach((data) {
        petsRef.doc(data.id).get().then((doc){
          dataList.add(discoveryList(
              profileOwnerId: doc.data()!['id'],
              postId: doc.data()!['postid'],
              price: doc.data()!['price'],
              city: doc.data()!['city'],
              breed: doc.data()!['breed'],
              profileCover: doc.data()!['coverProfile'],
              name: doc.data()!['name'],
              type: doc.data()!['type'],
              gender: doc.data()!['gender'],
              userLat: doc.data()!['lat'],
              userLng: doc.data()!['lng'],
              active: doc.data()!['active'],
              pedigree: doc.data()!['pedigree'],
              age: (( (currentYear - (1+doc.data()!['birthYear'])) *12 + (12- doc.data()!['birthMonth']) + currentMonth) )~/12.floor(),
              distance: Geolocator.distanceBetween(widget.userLat, widget.userLng, doc.data()!['lat'], doc.data()!['lng'])/1000
          ));
        });
        _lastDocument = querySnapshot.docs[querySnapshot.docs.length-1];
      });
    }catch(e){
      print(e);
      setState(() {
        msgShow = true;
      });
    };

    buildFilter();

    await usersRef.doc(widget.currentUserId).collection('chattingWith').where('isRead',isEqualTo: true).get().then((snapshot) => {
      if(snapshot.size>0){
        isRead = false
      }else{
        isRead = true
      }
    });
    setState(() {
      isLoading = false;
    });
  }

  _getMoreData()async{
    Query q = petsIndexRef.doc(widget.breed).collection(widget.breed.toString()).orderBy('timestamp', descending: true).startAfterDocument(_lastDocument).limit(_perPage);

    try{
      QuerySnapshot querySnapshot = await q.get();
      querySnapshot.docs.forEach((data) {
        petsRef.doc(data.id).get().then((doc){
          dataList.add(discoveryList(
              profileOwnerId: doc.data()!['id'],
              postId: doc.data()!['postid'],
              price: doc.data()!['price'],
              city: doc.data()!['city'],
              breed: doc.data()!['breed'],
              profileCover: doc.data()!['coverProfile'],
              name: doc.data()!['name'],
              type: doc.data()!['type'],
              gender: doc.data()!['gender'],
              userLat: doc.data()!['lat'],
              userLng: doc.data()!['lng'],
              active: doc.data()!['active'],
              pedigree: doc.data()!['pedigree'],
              age: (( (currentYear - (1+doc.data()!['birthYear'])) *12 + (12- doc.data()!['birthMonth']) + currentMonth) )~/12.floor(),
              distance: Geolocator.distanceBetween(widget.userLat, widget.userLng, doc.data()!['lat'], doc.data()!['lng'])/1000
          ));
        });
        _lastDocument = querySnapshot.docs[querySnapshot.docs.length-1];
      });
    }catch(e){
      setState(() {
        msgShow = true;
      });
    }
    buildFilter();
  }

  updatePetsIndex()async{
    final monthChecker = formatDate(now,[mm]);
    petsIndexRef.doc(widget.breed).collection(widget.breed.toString()).doc(widget.postId).get().then((snapshot){
      if(!snapshot.exists){
        petsIndexRef.doc(widget.breed).collection(widget.breed.toString()).doc(widget.postId).set(
            {
              'id': widget.currentUserId,
              'postid': widget.postId,
              'timestamp': now.millisecondsSinceEpoch
            });
      }else if(currentMonth != monthChecker){
        final currentMonth = formatDate(DateTime.fromMillisecondsSinceEpoch(snapshot.data()!['timestamp']),[mm]);
        petsIndexRef.doc(widget.breed).collection(widget.breed.toString()).doc(widget.postId).update(
            {
              'timestamp': now.millisecondsSinceEpoch
            });
      }
    });
  }

  void initState(){
    super.initState();
    widget.gender == 'ตัวผู้'? targetGender = 'ตัวเมีย': targetGender = 'ตัวผู้';
    userId = widget.currentUserId;

    setState(() {
      _checkboxPed = false;
      isLoading = true;
      SizerUtil.deviceType == DeviceType.tablet?isTablet = true:isTablet = false;
    });

    getCart();
    getUserData();
    getData();
    updatePetsIndex();

    setState(() {
      _scrollController.addListener(() async{
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.position.pixels;
        double delta = MediaQuery.of(context).size.height;

        if(maxScroll - currentScroll == 0){
          //  Do something
          msgShow == true?null: _getMoreData();
        }
      });
    });
  }

  AppBar appbarDiscovery(String? postid,profile,type,Function() ontapFilter, Function() ontapChat) {
    double screenHeight = MediaQuery.of(context).size.height;

    return AppBar(
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      leading: IconButton(icon: Icon(Icons.arrow_back_ios,color: Colors.red.shade900),onPressed: ()=> Navigator.pop(context)),
      title: Text('หาคู่ผสมพันธุ์',style: TextStyle(color: Colors.black,fontSize: 17)),
      actions: [
        Row(
          children: [
            minPriceController.text == '' && maxPriceController.text == '' && _checkboxPed == false?
            Padding(
                padding: const EdgeInsets.only(right: 5,top: 2),
              child: InkWell(
                child: Icon(LineAwesomeIcons.filter,color: themeColour,size: 25),
                onTap: ()=> _scaffoldState.currentState!.openEndDrawer(),
              ),
            ):

            Padding(
              padding: const EdgeInsets.only(right: 5,top: 2),
              child: InkWell(
                child: Container(
                  width: 25,
                  height: 20,
                  child: Stack(
                    children: [
                      Center(child: Icon(LineAwesomeIcons.filter,color: Colors.red.shade900,size: 25)),
                      Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green
                            ),
                              child: Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Icon(Icons.check,size: 10,color: Colors.white,),
                              )
                          )
                      )
                    ],
                  ),
                ),
                onTap: ()=> _scaffoldState.currentState!.openEndDrawer(),
              ),
            ),

            // #############################################
            // Uncomment this section when want to show shop
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
                      size: 30,
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
                          size: 30,
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
                    ],
                  ),
                ),
                onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>myCart(userId: widget.currentUserId))),
              ),
            ),
            // #############################################


            isRead == true?
            Center(child: iconbutton(LineAwesomeIcons.rocket_chat, 28,ontapChat)):
            Container(
              height: MediaQuery.of(context).size.height,
              color: Colors.white,
              child: Stack(
                children: [
                  Center(
                      child: iconbutton(LineAwesomeIcons.rocket_chat,28,ontapChat)),
                  Positioned(
                      top: 7,right: 2,
                      child: isRead == false?
                      Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red.shade900
                        ),
                        child: Center(child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text('1',style: TextStyle(fontSize: 12,color: Colors.red.shade900,fontWeight: FontWeight.bold)),
                        )),
                      ): Text(''))
                ],
              ),
            ),
            SizedBox(width: 7)
          ],
        )
      ],
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    maxPriceController.dispose();
    minPriceController.dispose();
    _scrollController.dispose();
  }
  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy');
    String yearString = formatter.format(now);
    int currentYear = int.parse(yearString);

    return StreamBuilder<QuerySnapshot>(
        stream: petsRef.snapshots(),
        builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Text('error');
          }
          return Scaffold(
            backgroundColor: Colors.grey.shade200,
            key: _scaffoldState,
            endDrawer: buildBackDrawer(),
            appBar: appbarDiscovery(widget.postId,widget.profile,widget.type,(){_scaffoldState.currentState!.openEndDrawer();},()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>mychat(userId: widget.currentUserId.toString())))),
            body: isLoading == true? loading():
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                      controller: _scrollController,
                      itemCount: filterList.length,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: screenWidth>700?4:2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.7
                      ),
                      itemBuilder: (context,index){

                        // To calculate the distance (in meters) between two geocoordinates you can use the distanceBetween
                        double distance = Geolocator.distanceBetween(widget.userLat, widget.userLng, filterList[index].userLat, filterList[index].userLng)/1000;
                        var f = new NumberFormat("#,###", "en_US");
                        String d = f.format(distance);

                        return InkWell(
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  color: Colors.white
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                      flex: 80,
                                      child: Container(
                                        width: screenWidth,
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              top: 0,
                                              left: 0,
                                              child: filterList[index].profileCover!= 'cover'?
                                              Image.network(filterList[index].profileCover,fit: BoxFit.fitHeight,errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                                return Text('');}):
                                              Container(color: Colors.grey.shade300),
                                            ),

                                            Visibility(
                                              visible: filterList[index].pedigree ==  'Yes',
                                              child: Positioned(
                                                  top: 5,
                                                  left: 0,
                                                  child: Container(
                                                    alignment: Alignment.centerRight,
                                                    decoration: BoxDecoration(
                                                        color: themeColour
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(left: 12.0,right: 3),
                                                      child: Text('Pedigree',style: TextStyle(color: Colors.white,fontSize: isTablet?20:16)),
                                                    ),
                                                  )
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                  ),

                                  Expanded(
                                      flex: 40,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(filterList[index].name,style: TextStyle(fontSize: isTablet?20:16),maxLines: 1),

                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Text('${d} km away',style: TextStyle(color: Colors.red,fontSize: isTablet?14:13)),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        filterList[index].price == 0? Text('ฟรี',style: TextStyle(color: themeColour,fontWeight: FontWeight.bold,fontSize:isTablet?18:16)):Text('฿ ${f.format(filterList[index].price)}',style: TextStyle(color: Colors.red.shade900,fontWeight: FontWeight.bold,fontSize:isTablet?18:16)),
                                                      ],
                                                    ),
                                                    filterList[index].gender == 'ตัวผู้'?Icon(FontAwesomeIcons.mars,color: Colors.blue):Icon(FontAwesomeIcons.venus,color: Colors.pink)
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                  ),
                                  Expanded(
                                    flex: 1,
                                      child: SizedBox()
                                  )
                                ],
                              ),
                            ),
                            onTap: (){
                              Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context)=>
                                      profile(
                                        profileId: filterList[index].postId,
                                        userId: widget.currentUserId,
                                        isOwner: false,
                                        profileOwnerId: filterList[index].profileOwnerId,
                                      )
                                  )
                              );
                            }
                        );
                      }
                  ),
                ),
                Visibility(
                  visible: msgShow,
                  child: Container(
                      width: screenWidth,
                      height: 20,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          filterList.isEmpty?Text(""):Text('End of Feed',style: TextStyle(color: Colors.grey)),
                        ],
                      )
                  ),
                )
              ],
            )
          );
        });
  }

  Drawer buildBackDrawer() {
    return Drawer(
      child: SafeArea(
        child: InkWell(
          onTap: (){
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 50),
                    Padding(
                      padding: EdgeInsets.only(left:20,top: 10),
                      child: Text('เพ็ดดีกรี',style: TextStyle(color: themeColour,fontWeight: FontWeight.bold,fontSize:isTablet?20:16)),
                    ),
                    Padding(padding: EdgeInsets.only(left: 20,top: 10),
                      child: Row(
                        children: [
                          Checkbox(
                              activeColor: themeColour,
                              value: _checkboxPed,
                              onChanged: (val){
                                setState(() {
                                  _checkboxPed == false?_checkboxPed = true:_checkboxPed = false;
                                });
                              }),
                          SizedBox(width: 10),
                          Text('เพ็ดดีกรี',style: TextStyle(fontSize:isTablet?20:16))
                        ],
                      ),),
                    buildDivider(),
                    Padding(
                      padding: EdgeInsets.only(left:20,top: 10),
                      child: Text('ราคา',style: TextStyle(color: themeColour,fontWeight: FontWeight.bold,fontSize:isTablet?20:16)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0,left: 20),
                      child: Row(
                        children: [
                          Container(
                            width: 100,
                            color: Colors.white,
                            child: TextField(
                              controller: minPriceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  hintText: 'ต่ำสุด',
                                  hintStyle: TextStyle(fontSize:isTablet?20:16),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide:  BorderSide(color: themeColour)
                                  )
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(' - '),
                          SizedBox(width: 10),
                          Container(
                            width: 100,
                            color: Colors.white,
                            child: TextField(
                              controller: maxPriceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  hintText: 'สูงสุด',
                                  hintStyle: TextStyle(fontSize:isTablet?20:16),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide:  BorderSide(color: themeColour)
                                  )
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Row(
                    children: [
                      Expanded(
                          flex:1,
                          child: InkWell(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  border: Border.all(color: Colors.grey.shade300)
                              ),
                              child: Center(child: Text('รีเซ็ต',style: TextStyle(color: themeColour,fontSize:isTablet?20:16))),
                            ),
                            onTap: (){
                              setState(() {
                                _checkboxPed = false;
                                minPriceController.clear();
                                maxPriceController.clear();
                                maxPrice = null;
                                minPrice = null;

                              });
                            },
                          )
                      ),
                      Expanded(
                          flex:1,
                          child: InkWell(
                            child: Container(
                              height: 50,
                              color: themeColour,
                              child: Center(child: Text('เสร็จสิ้น',style: TextStyle(color: Colors.white,fontSize:isTablet?20:16))),
                            ),
                            onTap: (){
                              setState(() {
                                maxPriceController.text.isEmpty? maxPrice = null:maxPrice = int.parse(maxPriceController.text);
                                minPriceController.text.isEmpty? minPrice = null:minPrice = int.parse(minPriceController.text);


                                dataList.clear();
                                filterList.clear();
                                getData();
                                Navigator.pop(context);
                              });
                            },
                          )
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  buildFilter(){
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        filterList = dataList.where((i)=>
        _checkboxPed == false && maxPrice == null && minPrice == null && i.type == 'สุนัข' ? i.type == 'สุนัข' && i.gender == targetGender && i.profileOwnerId != userId && i.distance<targetDistance && i.age>=targetAgeStart && i.age<=targetAgeEnd && i.active == 'Yes'
            :_checkboxPed == false && maxPrice == null && minPrice == null && i.type == 'แมว' ? i.type == 'แมว' && i.gender == targetGender && i.profileOwnerId != userId && i.distance<targetDistance && i.age>=targetAgeStart && i.age<=targetAgeEnd && i.active == 'Yes'

            :_checkboxPed  == false && maxPrice != null && minPrice == null && i.type == 'สุนัข' ? i.type == 'สุนัข' && i.price <= maxPrice && i.gender == targetGender && i.profileOwnerId != userId && i.distance<targetDistance && i.age>=targetAgeStart && i.age<=targetAgeEnd && i.active == 'Yes'
            :_checkboxPed  == false && maxPrice != null && minPrice == null && i.type == 'แมว' ? i.type == 'แมว' && i.price <= maxPrice && i.gender == targetGender && i.profileOwnerId != userId && i.distance<targetDistance && i.age>=targetAgeStart && i.age<=targetAgeEnd && i.active == 'Yes'

            :_checkboxPed == false && maxPrice == null && minPrice != null && i.type == 'สุนัข' ? i.type == 'สุนัข' && i.price >= minPrice && i.gender == targetGender && i.profileOwnerId != userId && i.distance<targetDistance && i.age>=targetAgeStart && i.age<=targetAgeEnd && i.active == 'Yes'
            :_checkboxPed == false && maxPrice == null && minPrice != null && i.type == 'แมว' ? i.type == 'แมว' && i.price >= minPrice && i.gender == targetGender && i.profileOwnerId != userId && i.distance<targetDistance && i.age>=targetAgeStart && i.age<=targetAgeEnd && i.active == 'Yes'

            :_checkboxPed == false && maxPrice != null && minPrice != null && i.type == 'สุนัข' ? i.type == 'สุนัข' && i.price >= minPrice && i.price <= maxPrice && i.gender == targetGender && i.profileOwnerId != userId && i.distance<targetDistance && i.age>=targetAgeStart && i.age<=targetAgeEnd && i.active == 'Yes'
            :_checkboxPed == false && maxPrice != null && minPrice != null && i.type == 'แมว' ? i.type == 'แมว' && i.price >= minPrice && i.price <= maxPrice && i.gender == targetGender && i.profileOwnerId != userId && i.distance<targetDistance && i.age>=targetAgeStart && i.age<=targetAgeEnd && i.active == 'Yes'

            :_checkboxPed == true && maxPrice == null && minPrice == null && i.type == 'สุนัข' ? i.type == 'สุนัข' && i.pedigree == 'Yes' && i.gender == targetGender && i.profileOwnerId != userId && i.distance<targetDistance && i.age>=targetAgeStart && i.age<=targetAgeEnd && i.active == 'Yes'
            :_checkboxPed == true && maxPrice == null && minPrice == null && i.type == 'แมว' ? i.type == 'แมว' && i.pedigree == 'Yes' && i.gender == targetGender && i.profileOwnerId != userId && i.distance<targetDistance && i.age>=targetAgeStart && i.age<=targetAgeEnd && i.active == 'Yes'

            :_checkboxPed == true && maxPrice != null && minPrice == null && i.type == 'สุนัข' ? i.type == 'สุนัข' && i.pedigree == 'Yes' && i.price <= maxPrice && i.gender == targetGender && i.profileOwnerId != userId && i.distance<targetDistance && i.age>=targetAgeStart && i.age<=targetAgeEnd && i.active == 'Yes'
            :_checkboxPed == true && maxPrice != null && minPrice == null && i.type == 'แมว' ? i.type == 'แมว' && i.pedigree == 'Yes' && i.price <= maxPrice && i.gender == targetGender && i.profileOwnerId != userId && i.distance<targetDistance && i.age>=targetAgeStart && i.age<=targetAgeEnd && i.active == 'Yes'

            :_checkboxPed == true && maxPrice == null && minPrice != null && i.type == 'สุนัข' ? i.type == 'สุนัข' && i.pedigree == 'Yes' && i.price >= minPrice && i.gender == targetGender && i.profileOwnerId != userId && i.distance<targetDistance && i.age>=targetAgeStart && i.age<=targetAgeEnd && i.active == 'Yes'
            :_checkboxPed == true && maxPrice == null && minPrice != null && i.type == 'แมว' ? i.type == 'แมว' && i.pedigree == 'Yes' && i.price >= minPrice && i.gender == targetGender && i.profileOwnerId != userId && i.distance<targetDistance && i.age>=targetAgeStart && i.age<=targetAgeEnd && i.active == 'Yes'

            :_checkboxPed == true && maxPrice != null && minPrice != null && i.type == 'สุนัข' ? i.type == 'สุนัข' && i.pedigree == 'Yes' && i.price >= minPrice && i.price <= maxPrice && i.gender == targetGender && i.profileOwnerId != userId && i.distance<targetDistance && i.age>=targetAgeStart && i.age<=targetAgeEnd && i.active == 'Yes'
            :_checkboxPed == true && maxPrice != null && minPrice != null && i.type == 'แมว' ? i.type == 'แมว' && i.pedigree == 'Yes' && i.price >= minPrice && i.price <= maxPrice && i.gender == targetGender && i.profileOwnerId != userId && i.distance<targetDistance && i.age>=targetAgeStart && i.age<=targetAgeEnd && i.active == 'Yes'

            :i.pedigree != null && i.gender == targetGender && i.profileOwnerId != userId && i.distance<targetDistance && i.age>=targetAgeStart && i.age<=targetAgeEnd && i.active == 'Yes'

        ).toList();
      });
    });
  }
}
