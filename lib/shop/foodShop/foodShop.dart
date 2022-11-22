import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/src/intl/number_format.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:multipawmain/database/posts.dart';
import 'package:multipawmain/shop/myCart.dart';
import 'package:multipawmain/shop/preview/foodPreview.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:sizer/sizer.dart';
import 'package:multipawmain/authCheck.dart';
import 'brandPage.dart';
import 'dogcatFoodShop.dart';

int _current = 0;

class foodShop extends StatefulWidget {
  final String? userId;

  foodShop({required this.userId});

  @override
  _foodShopState createState() => _foodShopState();
}

class _foodShopState extends State<foodShop> {

  TextEditingController searchController = TextEditingController();
  CarouselController carController = CarouselController();
  ScrollController _scrollController = ScrollController();


  int item_in_cart = 0;
  int _perPage = 100;
  var _lastDocument;
  bool msgShow = false;
  bool statusMsg = true;
  bool isLoading = false;
  bool isSearching = false;
  bool isTablet = false;

  List<bannersList> imageList = [];

  List<foodListForShow> dataList = [];
  List<foodListForShow> filterList = [];
  List<foodListForShow> searchList = [];

  getBanner()async{
    Query q = bannersRef.doc('123456789').collection('PetSupplyStore');
    QuerySnapshot querySnapshot = await q.get();
    querySnapshot.docs.forEach((doc) {imageList.add(bannersList.fromDocument(doc));});
  }

  StreamBuilder appbarPet() {
    return StreamBuilder(
        stream: usersRef.doc(widget.userId).collection('myCart').snapshots(),
        builder: (context,snapshot){
          getCart();
          return AppBar(
            elevation: 10,
            backgroundColor: !isSearching?Colors.white:themeColour,
            centerTitle: true,
            leading: !isSearching?InkWell(
              child: Icon(Icons.arrow_back_ios,color: themeColour),
              onTap: ()=> Navigator.pop(context),
            ):Text(''),
            title: Padding(
              padding: const EdgeInsets.only(right: 5.0),
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
                                  border: InputBorder.none),
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
                  ?iconbuttonForCart(item_in_cart,LineAwesomeIcons.shopping_cart,32, ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>myCart(userId: widget.userId))))
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
                  )
                ],
              ),
              SizedBox(width: 25)
            ],
          );
        }
    );
  }

  getData()async{
    Query q = postsFoodRef.orderBy('timestamp', descending: true).limit(_perPage);
    try{
      QuerySnapshot querySnapshot = await q.get();

      querySnapshot.docs.forEach((doc) {
        dataList.add(foodListForShow.fromDocument(doc));
      });
      _lastDocument = querySnapshot.docs[querySnapshot.docs.length-1];

    }catch(e){
      setState(() {
        msgShow = true;
        print(e);
      });
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        filterList = dataList;
      });
    });
  }

  _getMoreData()async{
    try{
      Query q = postsFoodRef.orderBy('timestamp', descending: true).startAfterDocument(_lastDocument).limit(_perPage);
      QuerySnapshot querySnapshot = await q.get();
      querySnapshot.docs.forEach((doc) {dataList.add(foodListForShow.fromDocument(doc));});
      _lastDocument = querySnapshot.docs[querySnapshot.docs.length-1];
    }catch(e){
      setState(() {
        msgShow = true;
      });
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        filterList = dataList;
      });
    });
  }

  onSearchTextChanged(String value) {
    setState(() {
      searchList = filterList.where((topic) => topic.topicName.toLowerCase().contains(value.toLowerCase())).toList();
    });
  }

  getCart()async{
    await usersRef.doc(widget.userId).collection('myCart').get().then((snap){
      item_in_cart = snap.size;
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

    getBanner();
    getData();

    setState(() {
      isLoading = false;
    });
    _scrollController.addListener(() async{
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height;

      if(maxScroll - currentScroll == 0){
        //  Do something
        msgShow == true?null: _getMoreData();
      }
    });

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    searchController.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: appbarPet(),
      ),
      body: isSearching && searchList.length>0?
      Column(
        children: [
          SizedBox(height: 20),
          Expanded(
              child: GridView.builder(
                  shrinkWrap: true,
                  controller: _scrollController,
                  itemCount: searchList.length,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTablet == true?4:2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.7
                  ),
                  itemBuilder: (context,index)
                  {
                    var f = new NumberFormat("#,###", "en_US");
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
                                flex: 50,
                                child: Container(
                                  width: screenWidth,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        top: 0,
                                        left: 0,
                                        child: searchList[index].profileCover!= 'cover'?
                                        Image.network(
                                            searchList[index].profileCover,
                                            fit: BoxFit.fitHeight,
                                            colorBlendMode: BlendMode.modulate,
                                            color: searchList[index].stock1 ==0
                                                && searchList[index].stock2 ==0
                                                && searchList[index].stock3 ==0
                                                && searchList[index].stock4 ==0
                                                && searchList[index].stock5 ==0
                                                && searchList[index].stock6 ==0?Colors.white.withOpacity(0.3):null,
                                            errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                          return Text('');}):
                                        Container(color: Colors.grey.shade300),
                                      ),
                                    ],
                                  ),
                                )
                            ),

                            Expanded(
                                flex: 50,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 5.0,right: 5,top: 20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(searchList[index].topicName,style: TextStyle(
                                          fontSize: 16,
                                          color: searchList[index].stock1 ==0
                                              && searchList[index].stock2 ==0
                                              && searchList[index].stock3 ==0
                                              && searchList[index].stock4 ==0
                                              && searchList[index].stock5 ==0
                                              && searchList[index].stock6 ==0
                                              ?Colors.black.withOpacity(0.3)
                                              :Colors.black
                                      ),maxLines: 1),

                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Visibility(
                                            visible: searchList[index].isPromo == true || searchList[index].stock1 !=0
                                                && searchList[index].stock2 !=0
                                                && searchList[index].stock3 !=0
                                                && searchList[index].stock4 !=0
                                                && searchList[index].stock5 !=0
                                                && searchList[index].stock6 !=0,
                                            child: searchList[index].promo_priceMin != searchList[index].promo_priceMax
                                                ?Text('฿ ${f.format(searchList[index].promo_priceMin)}-${f.format(searchList[index].promo_priceMax)}',
                                                style: buildTextStyle())
                                                :Text('฿ ${f.format(searchList[index].promo_priceMin)}',
                                                style: buildTextStyle()),
                                          ),


                                          searchList[index].stock1 ==0
                                              && searchList[index].stock2 ==0
                                              && searchList[index].stock3 ==0
                                              && searchList[index].stock4 ==0
                                              && searchList[index].stock5 ==0
                                              && searchList[index].stock6 ==0
                                              ?Text('Out of stock',style: TextStyle(color: Colors.red.shade900,fontSize: isTablet?20:16,fontWeight: FontWeight.bold))
                                              :searchList[index].priceMin != searchList[index].priceMax
                                              ?Text('฿ ${f.format(searchList[index].priceMin)}-${f.format(searchList[index].priceMax)}',
                                              style: searchList[index].isPromo == true
                                                  ?buildTextStyleLineThrough()
                                                  :buildTextStyle())
                                              :Text('฿ ${f.format(searchList[index].priceMin)}',
                                              style: searchList[index].isPromo == true
                                                  ?buildTextStyleLineThrough()
                                                  :buildTextStyle()),
                                          SizedBox(height: 5)
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
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>foodPreview(
                          postId: searchList[index].postId,
                          userId: widget.userId,
                          postType: searchList[index].type,
                        )));
                      },
                    );
                  }
              )
          ),
        ],
      ):isSearching && searchList.length == 0?Container()

          :ListView(
        shrinkWrap: true,
        children: [
          InkWell(
            child: buildCarouselSlider(screenWidth),
            onTap: (){
              // if(_current == 0){
              //   Navigator.push(context, MaterialPageRoute(builder: (context)=>myPets()));
              // }
            },
          ),
          buildCarouselSliderIndicator(),

          Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                    child: buildContainer(Colors.orange.shade900,'อาหารสุนัข',screenWidth/2),
                    onTap: ()=> Navigator.push(context,
                        MaterialPageRoute(builder: (context)=>
                            dogcatFoodShop(
                                userId:widget.userId.toString(),
                                type: 'สุนัข'
                            )
                        )
                    )
                ),
                InkWell(
                    child: buildContainer(Colors.blue.shade900,'อาหารแมว',screenWidth/2),
                    onTap: ()=> Navigator.push(context,
                        MaterialPageRoute(builder: (context)=>
                            dogcatFoodShop(
                                userId:widget.userId.toString(),
                                type: 'แมว'
                            )
                        )
                    )
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          GridView.builder(
              shrinkWrap: true,
              controller: _scrollController,
              itemCount: filterList.length,
              padding: EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isTablet == true?4:2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.7
              ),
              itemBuilder: (context,index)
              {
                var f = new NumberFormat("#,###", "en_US");
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
                            flex: 50,
                            child: Container(
                              width: screenWidth,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    top: 0,
                                    left: 0,
                                    child: filterList[index].profileCover!= 'cover'?
                                    Image.network(
                                        filterList[index].profileCover,
                                        fit: BoxFit.fitHeight,
                                        colorBlendMode: BlendMode.modulate,
                                        color: filterList[index].stock1 ==0
                                            && filterList[index].stock2 ==0
                                            && filterList[index].stock3 ==0
                                            && filterList[index].stock4 ==0
                                            && filterList[index].stock5 ==0
                                            && filterList[index].stock6 ==0?Colors.white.withOpacity(0.3):null,

                                        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                      return Text('');}):
                                    Container(color: Colors.grey.shade300),
                                  ),
                                ],
                              ),
                            )
                        ),

                        Expanded(
                            flex: 50,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5.0,right: 5,top: 20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(filterList[index].topicName,
                                      style: TextStyle(
                                          fontSize: 16,
                                        color: filterList[index].stock1 ==0
                                            && filterList[index].stock2 ==0
                                            && filterList[index].stock3 ==0
                                            && filterList[index].stock4 ==0
                                            && filterList[index].stock5 ==0
                                            && filterList[index].stock6 ==0
                                            ?Colors.black.withOpacity(0.3)
                                            :Colors.black
                                      ),maxLines: 1),

                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Visibility(
                                        visible: filterList[index].isPromo == true || filterList[index].stock1 !=0
                                            && filterList[index].stock2 !=0
                                            && filterList[index].stock3 !=0
                                            && filterList[index].stock4 !=0
                                            && filterList[index].stock5 !=0
                                            && filterList[index].stock6 !=0,
                                        child: filterList[index].promo_priceMin != filterList[index].promo_priceMax
                                            ?Text('฿ ${f.format(filterList[index].promo_priceMin)}-${f.format(filterList[index].promo_priceMax)}',
                                            style: buildTextStyle())
                                            :Text('฿ ${f.format(filterList[index].promo_priceMin)}',
                                            style: buildTextStyle()),
                                      ),


                                      filterList[index].stock1 ==0
                                          && filterList[index].stock2 ==0
                                          && filterList[index].stock3 ==0
                                          && filterList[index].stock4 ==0
                                          && filterList[index].stock5 ==0
                                          && filterList[index].stock6 ==0
                                          ?Text('Out of stock',style: TextStyle(color: Colors.red.shade900,fontSize: isTablet?20:16,fontWeight: FontWeight.bold))
                                          :filterList[index].priceMin != filterList[index].priceMax
                                          ?Text('฿ ${f.format(filterList[index].priceMin)}-${f.format(filterList[index].priceMax)}',
                                          style: filterList[index].isPromo == true
                                              ?buildTextStyleLineThrough()
                                              :buildTextStyle())
                                          :Text('฿ ${f.format(filterList[index].priceMin)}',
                                          style: filterList[index].isPromo == true
                                              ?buildTextStyleLineThrough()
                                              :buildTextStyle()),
                                      SizedBox(height: 5)
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
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>foodPreview(
                      postId: filterList[index].postId,
                      userId: widget.userId,
                      postType: filterList[index].type,
                    )));
                  },
                );
              }
          ),
          SizedBox(height: 20),
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
          ),
          SizedBox(height: 20)
        ],
      ),
    );
  }

  Container buildContainer(Color color,String topic,double width) {
    return Container(
      decoration: BoxDecoration(
          color: color,
      ),
      alignment: Alignment.center,
      width: width,
      height: isTablet?60:45,
      child: Text(topic,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 16)),
    );
  }

  TextStyle buildTextStyleLineThrough() => TextStyle(color: Colors.grey,fontWeight: FontWeight.bold,fontSize: 13,decoration: TextDecoration.lineThrough);

  TextStyle buildTextStyle() => TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: isTablet?16:14);

  Row buildCarouselSliderIndicator() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: imageList.map((urlOfItem)
        {
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
        }).toList()
    );
  }

  InkWell buildCarouselSlider(double screenWidth) {
    return InkWell(
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
            height: 200,
            child: Image.network(item.bannerImage,fit: BoxFit.fitWidth,width: screenWidth,errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
              return Text('');}))).toList()
      ),
      onTap: (){
        if(imageList[_current].linkType == 'toPost'){
          Navigator.push(context,
              MaterialPageRoute(builder: (context)=>
                  foodPreview(
                    postId: imageList[_current].payLoad,
                    userId: widget.userId,
                    postType: 'Dog Food',
                  )));

        }else if(imageList[_current].linkType == 'toPage'){
          if(imageList[_current].payLoad == ''){
            Navigator.push(context,
                MaterialPageRoute(builder: (context)=>
                    foodShop(
                      userId: widget.userId,
                    )));
          }else{
            Navigator.push(context,
                MaterialPageRoute(builder: (context)=>
                    dogcatFoodShop(
                      userId: widget.userId.toString(),
                      type: imageList[_current].payLoad,
                    )));
          }
        }else if(imageList[_current].linkType == 'toSpecificCategory'){
          Navigator.push(context,
              MaterialPageRoute(builder: (context)=>
                  brandPage(
                    userId: widget.userId.toString(),
                    brand: imageList[_current].payLoad,
                  )));
        }else{}
      },
    );
  }
}

