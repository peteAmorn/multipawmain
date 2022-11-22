import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:multipawmain/database/posts.dart';
import 'package:multipawmain/questionsAndConditions/conditionBuyer.dart';
import 'package:multipawmain/shop/preview/petPreview.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:intl/src/intl/number_format.dart';
import 'package:sizer/sizer.dart';
import 'package:multipawmain/authCheck.dart';

import '../../authScreenWithoutPet.dart';
import '../myCart.dart';

late bool _checkboxPed,_checkboxMale,_checkboxFemale;
int? minPrice,maxPrice;
String? selectedGender;

class petShopByBreed extends StatefulWidget {
  final String breed,userId,type;
  petShopByBreed({required this.breed,required this.userId,required this.type});

  @override
  _petShopByBreedState createState() => _petShopByBreedState();
}

class _petShopByBreedState extends State<petShopByBreed> {

  List<postList> dataList = [];
  List<postList> filterList = [];
  List<postList> searchList = [];

  String? selectedPedigree,selectedGender,selectedColour;
  bool statusMsg = true;
  bool isLoading = false;
  bool isSearching = false;
  var _lastDocument;
  bool msgShow = false;
  int item_in_cart = 0;
  int _perPage = 100;
  bool isTablet = false;

  ScrollController _scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  TextEditingController maxPriceController = TextEditingController();
  TextEditingController minPriceController = TextEditingController();

  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  getCart()async{
    await usersRef.doc(widget.userId).collection('myCart').get().then((snap){
      item_in_cart = snap.size;
    });
  }

  StreamBuilder appbarPet() {
    double screenHeight = MediaQuery.of(context).size.height;

    return StreamBuilder(
        stream: usersRef.doc(widget.userId).collection('myCart').snapshots(),
        builder: (context,snapshot){
          getCart();
          return AppBar(
            elevation: 10,
            backgroundColor: !isSearching?Colors.white:themeColour,
            centerTitle: true,
            leading: InkWell(
                child: Icon(Icons.arrow_back_ios,color: themeColour),
                onTap: ()=> Navigator.pop(context)),
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
                              height: isTablet?60:40,
                              child: Text('ค้นหา',style: TextStyle(color: Colors.grey.shade600,fontSize: isTablet?20:16)),
                            ),
                          ),
                        ],
                      ),
                      onTap: (){
                        setState(() {
                          isSearching = true;
                        });
                      },
                    ):Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Icon(FontAwesomeIcons.search,color: Colors.grey,size: 15),
                        ),
                        Expanded(
                          child: Container(
                            height: isTablet?60:40,
                            child: TextField(
                              controller: searchController,
                              decoration: new InputDecoration(
                                  contentPadding:EdgeInsets.only(bottom: isTablet?8:10),
                                  hintText: 'ค้นหา',
                                  hintStyle: TextStyle(fontSize: isTablet?20:16),
                                  border: InputBorder.none,
                                  suffixIcon: IconButton(
                                    alignment: Alignment.center,
                                    onPressed: searchController.clear,
                                    icon: Icon(FontAwesomeIcons.timesCircle,color: themeColour,size: 14),
                                  )),
                              onChanged: onSearchTextChanged,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
            actions: [
              !isSearching
                  ?Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 5.0),
                    child: InkWell(
                      child:Icon(FontAwesomeIcons.solidQuestionCircle,color: Colors.red.shade900),
                      onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>conditionBuyer())),
                    ),
                  ),
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
                      onTap: ()=>widget.userId=='null'?
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>authScreenWithoutPet(pageIndex: 3))):
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>myCart(userId: widget.userId))),
                    ),
                  ),
                  iconbutton(LineAwesomeIcons.filter, 28,(){_scaffoldState.currentState!.openEndDrawer();}),
                ],
              )
                  :Row(
                children: [
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
        });
  }

  onSearchTextChanged(String value) {
    setState(() {
      searchList = filterList.where((topic) => topic.topicName.toLowerCase().contains(value.toLowerCase())).toList();
    });
  }

  getData()async{
    Query q = postsPuppyKittenIndexRef.doc(widget.breed).collection(widget.breed).orderBy('timestamp',descending: true).limit(_perPage);

    try{
      QuerySnapshot querySnapshot = await q.get();
      querySnapshot.docs.forEach((data) {
        postsPuppyKittenRef.doc(data.id).get().then((doc){
          try{
            dataList.add(postList.fromDocument(doc));
          }catch(e){
            print(e);
          }
        });
      });
      _lastDocument = querySnapshot.docs[querySnapshot.docs.length-1];

    }catch(e){
      setState(() {
        msgShow = true;
      });
    }
    buildFilter();
  }

  _getMoreData()async{
    Query q = postsPuppyKittenIndexRef.doc(widget.breed).collection(widget.breed).orderBy('timestamp',descending: true).startAfterDocument(_lastDocument).limit(_perPage);

    try{
      QuerySnapshot querySnapshot = await q.get();
      querySnapshot.docs.forEach((data) {
        postsPuppyKittenRef.doc(data.id).get().then((doc){
          dataList.add(postList.fromDocument(doc));
        });
      });
      _lastDocument = querySnapshot.docs[querySnapshot.docs.length-1];
    }catch(e){
      setState(() {
        msgShow = true;
      });
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        filterList = dataList.where((i){
          if(selectedColour == null && selectedGender == null && selectedPedigree == null){
            filterList = dataList;
          }return true;
        }).toList();
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      isLoading = true;
      _checkboxPed = false;
      _checkboxMale = false;
      _checkboxFemale = false;
      maxPrice = null;
      minPrice = null;
      selectedGender = null;
      SizerUtil.deviceType == DeviceType.tablet?isTablet = true:isTablet = false;
    });

    getData();

    setState(() {
      isLoading = false;
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
    Future.delayed(Duration(seconds: 20),(){
      setState(() {
        statusMsg = false;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    _scrollController.dispose();
    searchController.dispose();
    maxPriceController.dispose();
    minPriceController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldState,
      endDrawer: buildBackDrawer(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: appbarPet(),
      ),
      body: isLoading == true? loading():isSearching && searchList.length>0?
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
                        userId: widget.userId,
                        isOwner: widget.userId == searchList[index].ownerId,
                      )));
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
                                      Image.network(searchList[index].profileCover,fit: BoxFit.fitHeight):
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
                                          child: Text(filterList[index].breed,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: isTablet?18:14)),
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
                                    Text(searchList[index].topicName,style: TextStyle(fontSize: isTablet?20:14),maxLines: 1),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        searchList[index].price == 0?Text('ฟรี',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: isTablet?20:16)):Text('฿ ${f.format(searchList[index].price)}',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: isTablet?20:16)),
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
      ):isSearching && searchList.length==0? Container():ListView(
        shrinkWrap: true,
        children: [
          Container(
            color: Colors.red.shade900,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 8),
              child: Row(
                children: [
                  Icon(FontAwesomeIcons.paw,color: Colors.white,size: 20),
                  SizedBox(width: 10),
                  Text('${widget.breed}',
                      style: TextStyle(
                          fontSize: isTablet?20:14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                      ),maxLines: 2),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          filterList.isEmpty && statusMsg == true
              ?Container(
              height: MediaQuery.of(context).size.height*0.7,
              child: loading()
          )
              :filterList.isEmpty && statusMsg == false
              ?Container(
            height: MediaQuery.of(context).size.height*0.7,
            child: Center(
                child:Text('No result found',style:TextStyle(color: Colors.grey,fontSize: 15,fontWeight: FontWeight.bold))),
          ):GridView.builder(
              shrinkWrap: true,
              controller: _scrollController,
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
                                    Image.network(filterList[index].profileCover,fit: BoxFit.fitHeight):
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
                                        child: Text(filterList[index].breed,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: isTablet?18:14)),
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
                                      filterList[index].price == 0?Text('ฟรี',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: isTablet?20:16)):Text('฿ ${f.format(filterList[index].price)}',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: isTablet?20:16)),
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
                      userId: widget.userId,
                      isOwner: widget.userId == filterList[index].ownerId,
                    )));
                  },
                );
              }
          ),
          SizedBox(height: 20)
        ],
      ),
    );
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
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.only(left:20,top: 10),
                      child: Text('เพ็ดดีกรี',style: TextStyle(color: themeColour,fontWeight: FontWeight.bold,fontSize: isTablet?20:16)),
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
                          Text('เพ็ดดีกรี',style: TextStyle(fontSize: isTablet?20:16))
                        ],
                      ),),
                    buildDivider(),
                    Padding(
                      padding: EdgeInsets.only(left:20,top: 10),
                      child: Text('เพศ',style: TextStyle(color: themeColour,fontWeight: FontWeight.bold,fontSize: isTablet?20:16)),
                    ),
                    Row(
                      children: [
                        Padding(padding: EdgeInsets.only(left: 20,top: 10),
                          child: Row(
                            children: [
                              Checkbox(
                                  activeColor: themeColour,
                                  value: _checkboxMale,
                                  onChanged: (val){
                                    setState(() {
                                      if(_checkboxMale == false){
                                        _checkboxMale = true;
                                        _checkboxFemale = false;
                                      }else{
                                        _checkboxMale = false;
                                        _checkboxFemale = true;
                                      }
                                    });
                                  }),
                              SizedBox(width: 10),
                              Text('ตัวผู้',style: TextStyle(fontSize: isTablet?20:16))
                            ],
                          ),),
                        Padding(padding: EdgeInsets.only(left: 20,top: 10),
                          child: Row(
                            children: [
                              Checkbox(
                                  activeColor: themeColour,
                                  value: _checkboxFemale,
                                  onChanged: (val){
                                    setState(() {
                                      if(_checkboxFemale == false){
                                        _checkboxMale = false;
                                        _checkboxFemale = true;
                                      }else{
                                        _checkboxMale = true;
                                        _checkboxFemale = false;
                                      }
                                    });
                                  }),
                              SizedBox(width: 10),
                              Text('ตัวเมีย',style: TextStyle(fontSize: isTablet?20:16))
                            ],
                          ),),
                      ],
                    ),
                    buildDivider(),
                    Padding(
                      padding: EdgeInsets.only(left:20,top: 10),
                      child: Text('ราคา',style: TextStyle(color: themeColour,fontWeight: FontWeight.bold,fontSize: isTablet?20:16)),
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
                                  hintStyle: TextStyle(fontSize: isTablet?20:16),
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
                                  hintStyle: TextStyle(fontSize: isTablet?20:16),
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
                              child: Center(child: Text('รีเซ็ต',style: TextStyle(color: themeColour,fontSize: isTablet?20:16))),
                            ),
                            onTap: (){
                              setState(() {
                                _checkboxPed = false;
                                _checkboxMale = false;
                                _checkboxFemale = false;
                                minPriceController.clear();
                                maxPriceController.clear();
                                selectedGender = null;
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
                              child: Center(child: Text('เสร็จสิ้น',style: TextStyle(color: Colors.white,fontSize: isTablet?20:16))),
                            ),
                            onTap: (){
                              setState(() {
                                maxPriceController.text.isEmpty? maxPrice = null:maxPrice = int.parse(maxPriceController.text);
                                minPriceController.text.isEmpty? minPrice = null:minPrice = int.parse(minPriceController.text);

                                if(_checkboxMale == true && _checkboxFemale == false)
                                {
                                  selectedGender = 'ตัวผู้';
                                }else if(_checkboxMale == false && _checkboxFemale == true)
                                {
                                  selectedGender = 'ตัวเมีย';
                                }else{
                                  selectedGender = null;
                                }

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

  void buildFilter() {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        if(widget.type == 'สุนัข'){
          filterList = dataList.where((i)=>
          _checkboxPed == false && selectedGender == null && maxPrice == null && minPrice == null ? i.type == 'สุนัข' && i.active == true

              :_checkboxPed  == false && selectedGender == null && maxPrice != null && minPrice == null  ? i.type == 'สุนัข' && i.price <= maxPrice && i.active == true

              :_checkboxPed == false && selectedGender == null && maxPrice == null && minPrice != null ? i.type == 'สุนัข' && i.price >= minPrice && i.active == true

              :_checkboxPed == false && selectedGender == null && maxPrice != null && minPrice != null ? i.type == 'สุนัข' && i.price >= minPrice && i.price <= maxPrice && i.active == true

              :_checkboxPed == false && selectedGender != null && maxPrice == null && minPrice == null ? i.type == 'สุนัข' && i.gender == selectedGender && i.active == true

              :_checkboxPed == false && selectedGender != null && maxPrice != null && minPrice == null ? i.type == 'สุนัข' && i.gender == selectedGender && i.price <= maxPrice && i.active == true

              :_checkboxPed == false && selectedGender != null && maxPrice == null && minPrice != null ? i.type == 'สุนัข' && i.gender == selectedGender && i.price >= minPrice && i.active == true

              :_checkboxPed == false && selectedGender != null && maxPrice != null && minPrice != null ? i.type == 'สุนัข' && i.gender == selectedGender && i.price >= minPrice && i.price <= maxPrice && i.active == true

              :_checkboxPed == true && selectedGender == null && maxPrice == null && minPrice == null ? i.type == 'สุนัข' && i.pedigree == 'Yes' && i.active == true

              :_checkboxPed == true && selectedGender == null && maxPrice != null && minPrice == null ? i.type == 'สุนัข' && i.pedigree == 'Yes' && i.price <= maxPrice && i.active == true

              :_checkboxPed == true && selectedGender == null && maxPrice == null && minPrice != null ? i.type == 'สุนัข' && i.pedigree == 'Yes' && i.price >= minPrice && i.active == true

              :_checkboxPed == true && selectedGender == null && maxPrice != null && minPrice != null ? i.type == 'สุนัข' && i.pedigree == 'Yes' && i.price >= minPrice && i.price <= maxPrice && i.active == true

              :_checkboxPed == true && selectedGender != null && maxPrice == null && minPrice == null ? i.type == 'สุนัข' && i.pedigree == 'Yes' && i.gender == selectedGender && i.active == true

              :_checkboxPed == true && selectedGender != null && maxPrice != null && minPrice == null ? i.type == 'สุนัข' && i.pedigree == 'Yes' && i.gender == selectedGender && i.price <= maxPrice && i.active == true

              :_checkboxPed == true && selectedGender != null && maxPrice == null && minPrice != null ? i.type == 'สุนัข' && i.pedigree == 'Yes' && i.gender == selectedGender && i.price >= minPrice && i.active == true

              :_checkboxPed == true && selectedGender != null && maxPrice != null && minPrice != null ? i.type == 'สุนัข' && i.pedigree == 'Yes' && i.gender == selectedGender && i.price >= minPrice && i.price <= maxPrice && i.active == true

              :i.pedigree != null && i.active == true

          ).toList();
        }else{
          filterList = dataList.where((i)=>
          _checkboxPed == false && selectedGender == null && maxPrice == null && minPrice == null ? i.type == 'แมว' && i.active == true

              :_checkboxPed  == false && selectedGender == null && maxPrice != null && minPrice == null  ? i.type == 'แมว' && i.price <= maxPrice && i.active == true

              :_checkboxPed == false && selectedGender == null && maxPrice == null && minPrice != null ? i.type == 'แมว' && i.price >= minPrice && i.active == true

              :_checkboxPed == false && selectedGender == null && maxPrice != null && minPrice != null ? i.type == 'แมว' && i.price >= minPrice && i.price <= maxPrice && i.active == true

              :_checkboxPed == false && selectedGender != null && maxPrice == null && minPrice == null ? i.type == 'แมว' && i.gender == selectedGender && i.active == true

              :_checkboxPed == false && selectedGender != null && maxPrice != null && minPrice == null ? i.type == 'แมว' && i.gender == selectedGender && i.price <= maxPrice && i.active == true

              :_checkboxPed == false && selectedGender != null && maxPrice == null && minPrice != null ? i.type == 'แมว' && i.gender == selectedGender && i.price >= minPrice && i.active == true

              :_checkboxPed == false && selectedGender != null && maxPrice == null && minPrice != null ? i.type == 'แมว' && i.gender == selectedGender && i.price >= minPrice && i.price <= maxPrice

              :_checkboxPed == true && selectedGender == null && maxPrice == null && minPrice == null ? i.type == 'แมว' && i.pedigree == 'Yes' && i.active == true

              :_checkboxPed == true && selectedGender == null && maxPrice != null && minPrice == null ? i.type == 'แมว' && i.pedigree == 'Yes' && i.price <= maxPrice && i.active == true

              :_checkboxPed == true && selectedGender == null && maxPrice == null && minPrice != null ? i.type == 'แมว' && i.pedigree == 'Yes' && i.price >= minPrice && i.active == true

              :_checkboxPed == true && selectedGender == null && maxPrice != null && minPrice != null ? i.type == 'แมว' && i.pedigree == 'Yes' && i.price >= minPrice && i.price <= maxPrice && i.active == true

              :_checkboxPed == true && selectedGender != null && maxPrice == null && minPrice == null ? i.type == 'แมว' && i.pedigree == 'Yes' && i.gender == selectedGender && i.active == true

              :_checkboxPed == true && selectedGender != null && maxPrice != null && minPrice == null ? i.type == 'แมว' && i.pedigree == 'Yes' && i.gender == selectedGender && i.price <= maxPrice && i.active == true

              :_checkboxPed == true && selectedGender != null && maxPrice == null && minPrice != null ? i.type == 'แมว' && i.pedigree == 'Yes' && i.gender == selectedGender && i.price >= minPrice && i.active == true

              :_checkboxPed == true && selectedGender != null && maxPrice != null && minPrice != null ? i.type == 'แมว' && i.pedigree == 'Yes' && i.gender == selectedGender && i.price >= minPrice && i.price <= maxPrice && i.active == true

              :i.pedigree != null && i.active == true

          ).toList();
        }


      });
    });
  }
}
