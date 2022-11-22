import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/src/intl/number_format.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:multipawmain/authScreenWithoutPet.dart';
import 'package:multipawmain/chat/mychat.dart';
import 'package:multipawmain/database/posts.dart';
import 'package:multipawmain/shop/petShop/petShop.dart';
import 'package:multipawmain/shop/preview/petPreview.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:multipawmain/authCheck.dart';
import 'package:sizer/sizer.dart';
import 'myCart.dart';

int _current = 0;

class shop extends StatefulWidget {
  final String? userid;
  shop({this.userid});

  @override
  _shopState createState() => _shopState();
}

class _shopState extends State<shop> {
  bool isLoading = false;
  bool isRead = true;
  bool lastStatus = true;
  String? location, targetGender;
  int item_in_cart = 0;
  late String filter;
  late String isAdmin;
  var top = 0.0;
  var scrollCon = 0.0;
  int _perPage = 100;
  var _lastDocument;
  bool msgShow = false;
  bool statusMsg = true;
  bool isSearching = false;
  bool isTablet = false;

  List<postList> dataList = [];
  List<postList> filterList = [];
  List<postList> searchList = [];
  List<bannersList> imageList = [];

  TextEditingController searchController = TextEditingController();
  CarouselController carController = CarouselController();

  getBanner()async{
    Query q = bannersRef.doc('123456789').collection('CentralShop');
    QuerySnapshot querySnapshot = await q.get();
    querySnapshot.docs.forEach((doc) {imageList.add(bannersList.fromDocument(doc));});
  }

  getData()async{
    Query q = postsPuppyKittenRef.orderBy('timestamp', descending: true).limit(_perPage);
    try{
      QuerySnapshot querySnapshot = await q.get();

      querySnapshot.docs.forEach((doc) {dataList.add(postList.fromDocument(doc));});
      _lastDocument = querySnapshot.docs[querySnapshot.docs.length-1];

    }catch(e){
      setState(() {
        msgShow = true;
        print(e);
      });
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        filterList = dataList.where((i) =>
        i.active == true
        ).toList();
      });
    });

    await usersRef.doc(widget.userid).collection('chattingWith').where('isRead',isEqualTo: true).get().then((snapshot) => {
      if(snapshot.size>0){
        isRead = false
      }else{
        isRead = true
      }
    });
  }

  _getMoreData()async{
    try{
      Query q = postsPuppyKittenRef.orderBy('timestamp', descending: true).startAfterDocument(_lastDocument).limit(_perPage);
      QuerySnapshot querySnapshot = await q.get();
      querySnapshot.docs.forEach((doc) {dataList.add(postList.fromDocument(doc));});
      _lastDocument = querySnapshot.docs[querySnapshot.docs.length-1];
    }catch(e){
      setState(() {
        msgShow = true;
      });
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        filterList = dataList.where((i) =>
        i.active == true
        ).toList();
      });
    });
  }

  getCart()async{
    await usersRef.doc(widget.userid).collection('myCart').get().then((snap){
      item_in_cart = snap.size;
    });
  }

  onSearchTextChanged(String value) {
    setState(() {
      searchList = filterList.where((topic) => topic.topicName.toLowerCase().contains(value.toLowerCase())).toList();
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
    dataList.clear();
    filterList.clear();

    getBanner();
    widget.userid == 'null'?null:getCart();
    getData();

    setState(() {
      isLoading = false;
      Future.delayed(Duration(seconds: 20),(){
        statusMsg = false;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    searchController.dispose();
  }

  AppBar appbarShop() {
    double screenHeight = MediaQuery.of(context).size.height;
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: !isSearching?Colors.white:themeColour,
      centerTitle: true,
      title: Padding(
        padding: const EdgeInsets.only(right: 10.0),
        child: Form(
            child: Container(
              height: 35,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.all(Radius.circular(30))
              ),
              child: !isSearching ?InkWell(
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Icon(FontAwesomeIcons.search,color: Colors.grey,size: 15),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        height: 40,
                        child: Text('ค้นหา',style: TextStyle(color: Colors.grey.shade600,fontSize: 16)),
                      ),
                    ),
                  ],
                ),
                onTap: (){
                  setState(() {
                    isSearching = true;
                  });
                },
              ):
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Icon(FontAwesomeIcons.search,color: Colors.grey,size: 15),
                  ),
                  Expanded(
                    child: Container(
                      height: 40,
                      child: TextField(
                        controller: searchController,
                        decoration: new InputDecoration(
                            contentPadding:EdgeInsets.only(bottom: 10),
                            hintText: 'ค้นหา',
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                              alignment: Alignment.center,
                              onPressed: searchController.clear,
                              icon: Icon(FontAwesomeIcons.timesCircle,color: themeColour,size: 14),
                            )
                        ),
                        onChanged: (value){
                          onSearchTextChanged(value);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ),

      actions: [
        !isSearching?Row(
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
                    ],
                  ),
                ),
                onTap: (){

                  widget.userid == 'null'?
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>authScreenWithoutPet(pageIndex: 3))):
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>myCart(userId: widget.userid))).then((value){
                    setState(() {
                      getCart();
                    });
                  });

                }
              ),
            ),
            isRead == true?
            iconbutton(LineAwesomeIcons.rocket_chat, ()
            {
              widget.userid == 'null'?
              Navigator.push(context, MaterialPageRoute(builder: (context)=>authScreenWithoutPet(pageIndex: 3))):
              Navigator.push(context, MaterialPageRoute(builder: (context)=> mychat(userId: widget.userid.toString())));
            }):
            Container(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Center(child: iconbutton(LineAwesomeIcons.rocket_chat,()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> mychat(userId: widget.userid.toString()))))),
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
        ):Row(
          children: [
            SizedBox(width: 20),
            InkWell(
              child: Text('ยกเลิก',style: TextStyle(color: Colors.white,fontSize: isTablet?20:16)),
              onTap: (){
                setState(() {
                  searchController.clear();
                  this.isSearching = false;
                  searchList = filterList;
                });
              },
            ),
            SizedBox(width: 25)
          ],
        ),
      ],
    );
  }

  Padding iconbutton(IconData icon,Function() ontap) {
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
    double screenWidth = MediaQuery.of(context).size.width;

    SliverAppBar showSliverAppBar(){
      return SliverAppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.00,
          automaticallyImplyLeading: false,
          floating: false,
          pinned: true,
          snap: false,
          expandedHeight: isTablet == true?610:380,
          flexibleSpace: LayoutBuilder(
            builder: (BuildContext context,BoxConstraints constraints){
              top = constraints.biggest.height;
              //GetMoreData here using top
              top==56?_getMoreData():null;


              return FlexibleSpaceBar(
                background: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>
                  [
                    Container(
                      color: Colors.white,
                      width: screenWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: buildInkWell('assets/icons/puppyIcon.png','ลูกสุนัข',(){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>petShop(type: 'ลูกสุนัข', userId: widget.userid))).then((value){
                                setState(() {
                                  getCart();
                                });
                              });
                            }),
                          ),
                          Expanded(
                            child: buildInkWell('assets/icons/kittenIcon.png','ลูกแมว',(){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>petShop(type: 'ลูกแมว', userId: widget.userid))).then((value){
                                setState(() {
                                  getCart();
                                });
                              });
                            }),
                          ),
                          // Expanded(
                          //     child: buildInkWell('assets/icons/petfoodIcon.png','อาหาร',(){
                          //       Navigator.push(context, MaterialPageRoute(builder: (context)=>foodShop(userId: widget.userid))).then((value){
                          //         setState(() {
                          //           getCart();
                          //         });
                          //       });
                          //     })),
                        ],
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            child: CarouselSlider(
                              carouselController: carController,
                              options: CarouselOptions(
                                  height: isTablet == true?400:200,
                                  viewportFraction: 1.0,
                                  enlargeCenterPage: false,
                                  enableInfiniteScroll: true,
                                  autoPlay: true,
                                  onPageChanged: (index,reason){
                                    setState(() {
                                      _current = index;
                                    });
                                  }
                              ),
                              items: imageList.map((item) => Container(
                                  width: screenWidth,
                                  height: isTablet == true?400:200,
                                  child: Image.network(item.bannerImage,fit: BoxFit.cover,width: screenWidth,errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                              return const Text('');}))).toList(),
                            ),
                            onTap: (){
                              // if(imageList[_current].linkType == 'toPost'){
                              //   Navigator.push(context,
                              //       MaterialPageRoute(builder: (context)=>
                              //           foodPreview(
                              //             postId: imageList[_current].payLoad,
                              //             userId: widget.userid,
                              //             postType: 'Dog Food',
                              //           )));
                              //
                              // }
                              // else if(imageList[_current].linkType == 'toPage'){
                              //   Navigator.push(context,
                              //       MaterialPageRoute(builder: (context)=>
                              //       foodShop(
                              //           userId: widget.userid,
                              //       )));
                              // }
                              // else if(imageList[_current].linkType == 'toSpecificCategory'){
                              //   Navigator.push(context,
                              //       MaterialPageRoute(builder: (context)=>
                              //       brandPage(
                              //           userId: widget.userid,
                              //           brand: imageList[_current].payLoad,
                              //       )));
                              // }else{}
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: imageList.map((urlOfItem) {
                              int index = imageList.indexOf(urlOfItem);
                              return Container(
                                width: 10.0,
                                height: 10.0,
                                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _current == index
                                      ? themeColour
                                      : Color.fromRGBO(0, 0, 0, 0.3),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          )
      );
    }

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: appbarShop(),
        body: isLoading == true? loading() :isSearching && searchList.length>0?
        Column(
          children: [
            SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: screenWidth>700?4:2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.7
                ),
                itemCount: searchList.length,
                itemBuilder: (context,index){
                  var f = new NumberFormat("#,###", "en_US");
                  var GrideViewWidth = ((MediaQuery.of(context).size.width)/2)-23;

                  return InkWell(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> petPreview(
                          postId: searchList[index].postId,
                          ownerId: searchList[index].ownerId,
                          userId: widget.userid,
                          isOwner: widget.userid == searchList[index].ownerId,
                        ))).then((value){
                          setState(() {
                            getCart();
                          });
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)
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
                                        child: searchList[index].profileCover!= 'cover'?
                                        Image.network(searchList[index].profileCover,fit: BoxFit.fitHeight,errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                          return const Text('');}):
                                        Container(color: Colors.grey.shade300),
                                      ),
                                      Visibility(
                                        visible: searchList[index].pedigree ==  'Yes',
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
                                                child: Text('Pedigree',style: TextStyle(color: Colors.white,fontSize: isTablet?20:13)),
                                              ),
                                            )
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        child: Container(
                                          width: GrideViewWidth,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
                                              color: themeColour
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 6.0,top: 5,bottom: 5),
                                            child: Text(filterList[index].breed,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: isTablet?18:13)),
                                          ),
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
                                      Text(searchList[index].topicName,style: TextStyle(fontSize: isTablet?20:15),maxLines: 1),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          searchList[index].price == 0?Text('ฟรี',style: TextStyle(color: themeColour,fontWeight: FontWeight.bold,fontSize: isTablet?20:16)) :Text('฿ ${f.format(searchList[index].price)}',style: TextStyle(color: themeColour,fontWeight: FontWeight.bold,fontSize: 16)),
                                          searchList[index].gender == 'ตัวผู้'?Icon(FontAwesomeIcons.mars,color: Colors.blue):Icon(FontAwesomeIcons.venus,color: Colors.pink)
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
                      )
                  );
                },
              ),
            ),
          ],
        ):isSearching && searchList.length==0? Container():NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                showSliverAppBar(),
              ];
            },
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                top >58
                    ? Padding(
                  padding: const EdgeInsets.only(left: 10.0,bottom: 20),
                  child: Text('รายการแนะนำ',style: TextStyle(color: themeColour,fontSize: isTablet?30:20,fontWeight: FontWeight.bold)),
                ):top<58 && top >50?Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey,
                              blurRadius: 2.0,
                              spreadRadius: 0.0,
                              offset: Offset(0.0,2.0)
                          )
                        ]
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 1,child: SizedBox()),
                        Expanded(
                          flex: 8,
                          child: buildInkWellHorizontal('assets/icons/puppyIcon.png','ลูกสุนัข',(){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>petShop(type: 'ลูกสุนัข', userId: widget.userid))).then((value){
                              setState(() {
                                getCart();
                              });
                            });
                          }),
                        ),
                        buildVerticalDivider(),
                        Expanded(
                          flex: 8,
                          child: buildInkWellHorizontal('assets/icons/kittenIcon.png','ลูกแมว',(){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>petShop(type: 'ลูกแมว', userId: widget.userid))).then((value){
                              setState(() {
                                getCart();
                              });
                            });
                          }),
                        ),
                        Expanded(flex: 1,child: SizedBox())
                        // buildVerticalDivider(),
                        // Expanded(
                        //   flex: 3,
                        //   child: buildInkWellHorizontal('assets/icons/petfoodIcon.png','อาหาร',(){
                        //     Navigator.push(context, MaterialPageRoute(builder: (context)=>foodShop(userId: widget.userid))).then((value){
                        //       setState(() {
                        //         getCart();
                        //       });
                        //     });
                        //   }),
                        // ),
                        // buildVerticalDivider(),
                        // buildInkWellHorizontal('assets/icons/toyIcon.png','Toys',(){}),
                      ],
                    )):Text(''),
                filterList.isEmpty && statusMsg == true?Expanded(child: loading()):filterList.isEmpty && statusMsg == false?Expanded(
                  child: Center(
                      child:Text('No result found',style:TextStyle(color: Colors.grey,fontSize: 15,fontWeight: FontWeight.bold))),
                ):Expanded(
                  child: GridView.builder(
                      itemCount: filterList.length,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: screenWidth>700?4:2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.7
                      ),
                      itemBuilder: (context,index)
                      {
                        var f = new NumberFormat("#,###", "en_US");
                        var GrideViewWidth = ((MediaQuery.of(context).size.width)/2)-23;
                        return  InkWell(
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
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
                                                    child: Text('Pedigree',style: TextStyle(color: Colors.white,fontSize: isTablet?20:13)),
                                                  ),
                                                )
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            child: Container(
                                              width: GrideViewWidth,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
                                                color: themeColour
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 6.0,top: 5,bottom: 5),
                                                child: Text(filterList[index].breed,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: isTablet?18:13)),
                                              ),
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
                                          Text(filterList[index].topicName,style: TextStyle(fontSize: isTablet?20:14),maxLines: 1),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              filterList[index].price == 0?Text('ฟรี',style: TextStyle(color: themeColour,fontWeight: FontWeight.bold,fontSize: isTablet?20:16)) :Text('฿ ${f.format(filterList[index].price)}',style: TextStyle(color: themeColour,fontWeight: FontWeight.bold,fontSize: isTablet?20:16)),
                                              filterList[index].gender == 'ตัวผู้'?Icon(FontAwesomeIcons.mars,color: Colors.blue):Icon(FontAwesomeIcons.venus,color: Colors.pink)
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
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>petPreview(
                              postId: filterList[index].postId,
                              ownerId: filterList[index].ownerId,
                              userId: widget.userid,
                              isOwner: widget.userid == filterList[index].ownerId,
                            ))).then((value){
                              setState(() {
                                getCart();
                              });
                            });
                          },
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
        )
    );
  }

  Padding buildVerticalDivider() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: VerticalDivider(color: themeColour,thickness: 2),
    );
  }

  InkWell buildInkWellHorizontal(String img,String text,Function() ontap) {
    return InkWell(
      child: Container(
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 15,
              backgroundImage: AssetImage(img),
              backgroundColor: Colors.transparent,
            ),
            SizedBox(width: 5),
            Text(text,style: TextStyle(color: Colors.grey.shade900,fontSize: isTablet?20:14,fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      onTap: ontap,
    );
  }

  Padding buildInkWell(String img, String text,Function() ontap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 2),
      child: InkWell(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.white,
          ),
          child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: isTablet?40:30,
                    backgroundImage: AssetImage(img),
                    backgroundColor: Colors.transparent,
                  ),
                  SizedBox(height: 10),
                  Text(text,style: TextStyle(color: Colors.grey.shade600,fontSize: isTablet?20:15))
                ],
              )
          ),
        ),
        onTap: ontap,
      ),
    );
  }

}
