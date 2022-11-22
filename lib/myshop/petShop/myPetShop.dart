import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multipawmain/database/posts.dart';
import 'package:multipawmain/authCheck.dart';
import 'package:multipawmain/myshop/petShop/addSellPostPet.dart';
import 'package:multipawmain/myshop/petShop/editSellPostPet.dart';
import 'package:multipawmain/questionsAndConditions/conditionSeller.dart';
import 'package:multipawmain/shop/preview/petPreview.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class myShop extends StatefulWidget {
  final String userId;
  myShop({required this.userId});

  @override
  _myShopState createState() => _myShopState();
}

class _myShopState extends State<myShop> with SingleTickerProviderStateMixin{
  late bool isLoading;
  String? selectedPostId;
  int _selectedIndex = 0;
  late TabController controller;
  List<myShopList> liveList = [];
  List<myShopList> soldList = [];
  List<myShopList> cxlList = [];
  bool isTablet = false;

  int liveCount = 0;
  int soldCount = 0;
  int cxlCount = 0;

  getData()async{
    setState(() {
      isLoading = true;
    });

    await postsPuppyKittenRef.where('id',isEqualTo: widget.userId).where('type',whereIn: ['สุนัข','แมว']).get().then((snapshot) => {
      if(snapshot.size>0)
        {
          snapshot.docs.forEach((doc) {
            if(doc.data()['active'] == true){
              liveList.add(myShopList(
                  postId: doc.data()['postid'],
                  profileCover: doc.data()['coverProfile'],
                  topicName: doc.data()['topicName'],
                  view: doc.data()['view'],
                  breed: doc.data()['breed'],
                  price: doc.data()['price'],
                  pedigree: doc.data()['pedigree'],
                  dadImg: doc.data()['dadImg'],
                  mumImg: doc.data()['mumImg'],
                  profile1: doc.data()['profile1'],
                  profile2: doc.data()['profile2'],
                  profile3: doc.data()['profile3'],
                  profile4: doc.data()['profile4'],
                  profile5: doc.data()['profile5'],
                  ownerid: doc.data()['id'],
                  timeStamp: Timestamp.fromMillisecondsSinceEpoch(doc.data()['timestamp'])
              ));
            }else{
              if(doc.data()['comment'] == 'sold' && doc.data()['active'] == false || doc.data()['comment'] == 'none' && doc.data()['active'] == false){
                soldList.add(myShopList(
                    postId: doc.data()['postid'],
                    profileCover: doc.data()['coverProfile'],
                    topicName: doc.data()['topicName'],
                    view: doc.data()['view'],
                    breed: doc.data()['breed'],
                    price: doc.data()['price'],
                    pedigree: doc.data()['pedigree'],
                    dadImg: doc.data()['dadImg'],
                    mumImg: doc.data()['mumImg'],
                    profile1: doc.data()['profile1'],
                    profile2: doc.data()['profile2'],
                    profile3: doc.data()['profile3'],
                    profile4: doc.data()['profile4'],
                    profile5: doc.data()['profile5'],
                    ownerid: doc.data()['id'],
                    timeStamp: Timestamp.fromMillisecondsSinceEpoch(doc.data()['timestamp'])
                ));
              }else{
                cxlList.add(myShopList(
                    postId: doc.data()['postid'],
                    profileCover: doc.data()['coverProfile'],
                    topicName: doc.data()['topicName'],
                    view: doc.data()['view'],
                    breed: doc.data()['breed'],
                    price: doc.data()['price'],
                    pedigree: doc.data()['pedigree'],
                    dadImg: doc.data()['dadImg'],
                    mumImg: doc.data()['mumImg'],
                    profile1: doc.data()['profile1'],
                    profile2: doc.data()['profile2'],
                    profile3: doc.data()['profile3'],
                    profile4: doc.data()['profile4'],
                    profile5: doc.data()['profile5'],
                    ownerid: doc.data()['id'],
                    timeStamp: Timestamp.fromMillisecondsSinceEpoch(doc.data()['timestamp'])
                ));
              }
            }
          }),
        }
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        liveCount = liveList.length;
        soldCount = soldList.length;
        cxlCount = cxlList.length;

        liveList.sort((b,a)=>a.timeStamp.compareTo(b.timeStamp));
        soldList.sort((b,a)=>a.timeStamp.compareTo(b.timeStamp));
        cxlList.sort((b,a)=>a.timeStamp.compareTo(b.timeStamp));
        isLoading = false;
      });
    });

  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      SizerUtil.deviceType == DeviceType.tablet?isTablet = true:isTablet = false;
    });
    getData();

    controller = TabController(length: 3, vsync: this);
    controller.addListener(() {
      setState(() {
        _selectedIndex = controller.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          leading: InkWell(child: Icon(Icons.arrow_back_ios,color: Colors.red.shade900),
              onTap: ()=> Navigator.pop(context)
          ),
        title: Text('ร้านค้าของฉัน',style: TextStyle(color: Colors.black,fontSize: isTablet?20:16)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25.0),
            child: InkWell(
              child:Icon(FontAwesomeIcons.solidQuestionCircle,color: Colors.red.shade900),
              onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>conditionSeller())),
            ),
          ),
        ],
        bottom: TabBar(
          labelColor: themeColour,
          unselectedLabelColor: Colors.black,
          controller: controller,
          indicatorColor: Colors.red.shade900,
          tabs: [
            Column(
              children: [
                Tab(child: Text('กำลังขาย (${liveCount.toString()})',style: TextStyle(fontSize: isTablet?20:14),)),
              ],
            ),
            Column(
              children: [
                Tab(child: Text('ขายแล้ว (${soldCount.toString()})',style: TextStyle(fontSize: isTablet?20:14))),
              ],
            ),
            Column(
              children: [
                Tab(child: Text('ยกเลิก (${cxlCount.toString()})',style: TextStyle(fontSize: isTablet?20:14))),
              ],
            ),
          ],
        ),
        ),
      body: isLoading == true?loading():TabBarView(
          controller: controller,
          children:<Widget>[

            GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet?4:2,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.7
                ),
                itemCount: liveList.length,
                itemBuilder: (context,index){
                  return InkWell(
                      child: BuildContentBox(context,
                        liveList[index].profileCover,
                        liveList[index].breed,
                        liveList[index].topicName,
                        liveList[index].price,
                        liveList[index].view,
                        liveList[index].pedigree,
                        liveList[index].postId,
                        liveList[index].dadImg,
                        liveList[index].mumImg,
                        liveList[index].profile1,
                        liveList[index].profile2,
                        liveList[index].profile3,
                        liveList[index].profile4,
                        liveList[index].profile5,
                        true,
                      ),
                      onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>
                          petPreview(
                              postId: liveList[index].postId,
                              ownerId: liveList[index].ownerid,
                              userId: widget.userId,
                              isOwner: widget.userId == liveList[index].ownerid
                          )),
                      ));
                }
            ),

            GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet?4:2,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.7
                ),
                itemCount: soldList.length,
                itemBuilder: (context,index){
                  return InkWell(
                      child: BuildContentBox(context,
                        soldList[index].profileCover,
                        soldList[index].breed,
                        soldList[index].topicName,
                        soldList[index].price,
                        soldList[index].view,
                        soldList[index].pedigree,
                        soldList[index].postId,
                        soldList[index].dadImg,
                        soldList[index].mumImg,
                        soldList[index].profile1,
                        soldList[index].profile2,
                        soldList[index].profile3,
                        soldList[index].profile4,
                        soldList[index].profile5,
                        false,
                      ),
                      onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>
                          petPreview(
                              postId: soldList[index].postId,
                              ownerId: soldList[index].ownerid,
                              userId: widget.userId,
                              isOwner: widget.userId == soldList[index].ownerid
                          )),
                      ));
                }
            ),

            GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet?4:2,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.7
                ),
                itemCount: cxlList.length,
                itemBuilder: (context,index){
                  return InkWell(
                      child: BuildContentBox(context,
                        cxlList[index].profileCover,
                        cxlList[index].breed,
                        cxlList[index].topicName,
                        cxlList[index].price,
                        cxlList[index].view,
                        cxlList[index].pedigree,
                        cxlList[index].postId,
                        cxlList[index].dadImg,
                        cxlList[index].mumImg,
                        cxlList[index].profile1,
                        cxlList[index].profile2,
                        cxlList[index].profile3,
                        cxlList[index].profile4,
                        cxlList[index].profile5,
                        false,
                      ),
                      onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>
                          petPreview(
                              postId: cxlList[index].postId,
                              ownerId: cxlList[index].ownerid,
                              userId: widget.userId,
                              isOwner: widget.userId == cxlList[index].ownerid
                          )),
                      ));
                }
            ),
          ]
      ),
      floatingActionButton: _selectedIndex == 0?FloatingActionButton(
          backgroundColor: themeColour,
          child: Icon(Icons.add),
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>addSellPost(userId: widget.userId)));
          }
      ):SizedBox(),
    );
  }

  Padding BuildContentBox(BuildContext context,
          String cover,
          String breed,
          String topic,
          int price,
          int view,
          String pedigree,
          String postId,
          String dadImg,
          String mumImg,
          String profile1,
          String profile2,
          String profile3,
          String profile4,
          String profile5,
      bool editable,
      ) {
    var f = new NumberFormat("#,###", "en_US");

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                    flex: isTablet == true?40:60,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        children: [
                          Positioned.fill(
                              top: 0,
                              left: 0,
                              child: Image.network(cover,fit: BoxFit.fitHeight)
                          ),
                          editable == true?Positioned(
                              top: 5,
                              right: 0,
                              child: Container(
                                alignment: Alignment.centerRight,
                                decoration: BoxDecoration(
                                    color: themeColour
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                  child: Row(
                                    children: [
                                      InkWell(child: Icon(FontAwesomeIcons.solidEdit,size: 20,color: Colors.white),onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>editSellPost(postId: postId, userId: widget.userId)))),
                                      SizedBox(width: 20),
                                      InkWell(child: Icon(FontAwesomeIcons.trash,size: 20,color: Colors.white),onTap: ()=>deleteAlertDialog(context,postId,breed,dadImg,mumImg,cover,profile1,profile2,profile3,profile4,profile5)),
                                    ],
                                  ),
                                ),
                              )
                          ):SizedBox(),
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(topic,style: TextStyle(fontSize: isTablet?20:14,fontWeight: FontWeight.bold),maxLines: 1),
                              Text(breed,style: TextStyle(fontSize: isTablet?18:12,color: Colors.grey.shade600),maxLines: 1),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('฿ ${f.format(price)}',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: isTablet?20:15)),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  pedigree == 'Yes'?Text('Pedigree',style: TextStyle(color: Colors.red.shade900,fontSize: isTablet?20:16),):SizedBox(),
                                  Text('${view} views',style: TextStyle(fontSize: isTablet?16:13)),
                                ],
                              )
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
            )
        ),
        onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>
            petPreview(
              userId: widget.userId, postId: postId,isOwner: true, ownerId: widget.userId,
            ))),
      ),
    );
  }


  deletePost(String postId,String breed){
    postsPuppyKittenRef.doc(postId).delete();
    postsPuppyKittenIndexRef.doc(breed).collection(breed).doc(postId).delete();
  }


  Future<dynamic> deleteAlertDialog(BuildContext context,
      String postId,
      breed,
      dadImg,
      mumImg,
      coverprofile,
      profile1,
      profile2,
      profile3,
      profile4,
      profile5) {

    return showDialog(
        context: context,
        builder: (BuildContext context) =>
        Platform.isIOS ?
        CupertinoAlertDialog(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('คุณต้องการลบรายการนี้',style: TextStyle(fontSize: isTablet?20:16)),
              Text('ใช่หรือไม่ ?',style: TextStyle(fontSize: isTablet?20:16))
            ],
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('ยืนยัน',style: TextStyle(color: Colors.red,fontSize: isTablet?20:16),),
              onPressed: () async {

                dadImg == 'dad'? null:FirebaseStorage.instance.refFromURL(dadImg).delete();
                mumImg == 'mum'? null:FirebaseStorage.instance.refFromURL(mumImg).delete();
                // coverprofile == 'cover'? null : FirebaseStorage.instance.refFromURL(coverprofile).delete();
                profile1 == 'profile1'? null : FirebaseStorage.instance.refFromURL(profile1).delete();
                profile2 == 'profile2'? null : FirebaseStorage.instance.refFromURL(profile2).delete();
                profile3 == 'profile3'? null : FirebaseStorage.instance.refFromURL(profile3).delete();
                profile4 == 'profile4'? null : FirebaseStorage.instance.refFromURL(profile4).delete();
                profile5 == 'profile5'? null : FirebaseStorage.instance.refFromURL(profile5).delete();

                deletePost(postId,breed.toString());

                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              child: Text('ยกเลิก',style: TextStyle(color: Colors.green.shade800,fontSize:isTablet?20:16)),
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
              child: Text('คุณต้องการลบรายการนี้\nใช่หรือไม่',style: TextStyle(color: Colors.black,fontSize: isTablet?20:16)),
            ),
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
                      onTap: () async {
                        deletePost(postId,breed);

                        dadImg == 'dad'? null:FirebaseStorage.instance.refFromURL(dadImg).delete();
                        mumImg == 'mum'? null:FirebaseStorage.instance.refFromURL(mumImg).delete();
                        coverprofile == 'cover'? null : FirebaseStorage.instance.refFromURL(coverprofile).delete();
                        profile1 == 'profile1'? null : FirebaseStorage.instance.refFromURL(profile1).delete();
                        profile2 == 'profile2'? null : FirebaseStorage.instance.refFromURL(profile2).delete();
                        profile3 == 'profile3'? null : FirebaseStorage.instance.refFromURL(profile3).delete();
                        profile4 == 'profile4'? null : FirebaseStorage.instance.refFromURL(profile4).delete();
                        profile5 == 'profile5'? null : FirebaseStorage.instance.refFromURL(profile5).delete();

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
                  SizedBox(width: 20)
                ],
              ),
            )
          ],
        )
    );
  }
}
