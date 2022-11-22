import 'package:multipawmain/profileWIthoutPet.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:multipawmain/authCheck.dart';
import 'package:multipawmain/authScreenWithoutPet.dart';
import 'package:multipawmain/database/posts.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:multipawmain/pages/myPets/typeSelectionAddPet.dart';
import '../../authScreen.dart';
import 'package:sizer/sizer.dart';
import '../../database/breedDatabase.dart';
import '../../myshop/flightDetail.dart';
import '../../support/payment/api_request.dart';
import '../../support/payment/moneyspace_model.dart';

class myPets extends StatefulWidget {
  final String? currentUserId;
  bool? toCheck;
  myPets({this.currentUserId,this.toCheck});

  @override
  _myPetsState createState() => _myPetsState();
}

class _myPetsState extends State<myPets> {
  String selectedPostId = '0';
  bool isSwitched = false;
  double? userLat,userLng;
  bool isLoading = false;
  bool isGetLoc = false;
  List<myPetsList> dataList = [];
  List<myPetsList> filterList = [];
  String? locality,postCode,country,location1,location2,city,name,error,_getToken;
  double? lat,lng;
  Position? _currentPosition;
  bool isTablet = false;





  var current = Timestamp.fromDate(DateTime.now()).millisecondsSinceEpoch;
  final GoogleSignIn googleSignIn = new GoogleSignIn();


  getLocation(){
    try{
      return usersRef.doc(widget.currentUserId).get().then((snapshot){
        userLat = snapshot.data()!['lat'];
        userLng = snapshot.data()!['lng'];
      });
    }catch(e){
      print(e);
    }
  }

  _getAddressFromLatLng() async{
    try{
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition!.latitude,
          _currentPosition!.longitude
      );

      Placemark place = placemarks[0];

      setState(() {
        location1 = "${place.name}";
        location2 = '${place.locality},${place.administrativeArea}, ${place.postalCode}';
        city = '${place.locality}';
      });

    } catch(e){
      print(e);
    }
  }

  _getCurrentPosition() async{
    await Geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best,
        forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        _getAddressFromLatLng();

        lat = _currentPosition?.latitude;
        lng = _currentPosition?.longitude;

      });
    }).catchError((e){print(e);});
  }

  // #########################################################

  getData()async{
    await myPetsIndex.doc(widget.currentUserId).collection(widget.currentUserId.toString()).orderBy('timestamp',descending: false).get()
        .then((snapshot){
      snapshot.docs.forEach((data) {
        petsRef.doc(data.id).get().then((doc)
        {
          dataList.add(myPetsList.fromDocument(doc));
        });
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          filterList = dataList;
        });
      });
    });
  }

  checkLocation()async{
    await usersRef.doc(widget.currentUserId).get().then((snapshot){
      if(
      snapshot.data()!['location1'] == null
          || snapshot.data()!['location2'] == null
          || snapshot.data()!['city']  == null
          || snapshot.data()!['lat'] == null
          || snapshot.data()!['lng']== null){
        setState(() {
          isGetLoc = true;
        });
        _getCurrentPosition();

        usersRef.doc(widget.currentUserId).update({
          'location1': location1,
          'location2': location2,
          'city': city,
          'lat':lat,
          'lng':lng,
        });
        userLat = lat!.toDouble();
        userLng = lng!.toDouble();
        setState(() {
          isGetLoc = false;
        });
      }else{}
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

    getLocation();
    getData();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(location1 == null){
      checkLocation();
    }else{}

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
          centerTitle: false,
          backgroundColor: themeColour,
        leading: InkWell(child: Icon(Icons.arrow_back_ios,color: Colors.white),
            onTap: ()=> Navigator.push(context, MaterialPageRoute(
                builder: (context)=>authScreenWithoutPet(currentUserId: widget.currentUserId,pageIndex: 3))
            )
        ),
          title: Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text('สัตว์เลี้ยงของฉัน',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet?20:16)
            ),
          ),
      ),
      body: isLoading == true || isGetLoc == true?loading():ListView.builder(
          itemCount: filterList.length,
          itemBuilder: (context,index){
            return Visibility(
              visible: filterList.isNotEmpty,
              child: buildListTile(
                  filterList[index].pedCover,
                  filterList[index].pedFamily,
                  filterList[index].profileCover,
                  filterList[index].profile1,
                  filterList[index].profile2,
                  filterList[index].profile3,
                  filterList[index].profile4,
                  filterList[index].profile5,
                  filterList[index].type,
                  filterList[index].gender,
                  filterList[index].name,
                  filterList[index].breed,
                  filterList[index].active,
                  filterList[index].postId,
                  filterList[index].ownerId
              ),
            );
          }
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(left: 30,bottom: 20),
        child: FloatingActionButton(
          backgroundColor: themeColour,
          onPressed:()async{
            widget.toCheck == true
                ?await usersRef.doc(widget.currentUserId).get().then((snapshot) {
              !snapshot.exists
                  ? Navigator.push(context, MaterialPageRoute(builder: (context)=>home()))
                  : Navigator.push(context,
                  MaterialPageRoute(builder: (context)=> typeSelectionAddPet(currentUserId: widget.currentUserId)));
            })
                :Navigator.push(context,
                MaterialPageRoute(builder: (context)=> typeSelectionAddPet(currentUserId: widget.currentUserId)));
          },
          child: Icon(
              Icons.add,
              color: Colors.white
          ),
        ),
      ),
    );
  }

  InkWell buildListTile(String pedCover,pedFamily,coverProfile,profile1,profile2,profile3,profile4,profile5, type, gender, name, breed, active, postid,ownerid) {
    return InkWell(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Slidable(
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: isTablet?0.10:0.15,
            child: Container(
              height: isTablet?90:80,
              color: Colors.white,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: ListTile(
                    leading: coverProfile == 'cover' && type == 'สุนัข'
                        ? CircleAvatar(
                      radius: isTablet?60:30.0,
                      backgroundImage: AssetImage('assets/dogProfile.jpg'),
                      backgroundColor: Colors.transparent,
                    )
                        :coverProfile == 'cover' && type == 'แมว'
                        ?CircleAvatar(
                      radius: isTablet?60:30.0,
                      backgroundImage: AssetImage('assets/catProfile.jpg'),
                      backgroundColor: Colors.transparent,
                    )
                        : CircleAvatar(
                      radius: 30.0,
                      backgroundImage: NetworkImage(coverProfile),
                      backgroundColor: Colors.transparent,
                    ),
                    title: gender == 'ตัวผู้'? Row(
                      children: [
                        Text('${name}   '
                            ,style: TextStyle(fontWeight: FontWeight.bold,fontSize: isTablet?20:16)),
                        Icon(Icons.male,color: Colors.blue,)
                      ],
                    ):Row(
                      children: [
                        Text('${name}   '
                            ,style: TextStyle(fontWeight: FontWeight.bold,fontSize: isTablet?20:16)),
                        Icon(Icons.female,color: Colors.pinkAccent,)
                      ],
                    ),
                    subtitle: Text(breed,style: TextStyle(fontSize: isTablet?18:14)),
                    trailing: IconButton(
                      iconSize: 40,
                      icon: active == 'Yes'
                          ? Icon(Icons.toggle_on,color: Colors.green,)
                          :Icon(Icons.toggle_off,color: Colors.red),
                      onPressed: () {
                        if(active == 'Yes')
                        {
                          setState(() {
                            selectedPostId = postid;
                            activePets(selectedPostId, 'No');
                            int index = filterList.indexWhere((i) => i.postId == postid);
                            filterList[index].active = 'No';
                          });
                        }
                        else if(active == 'No')
                        {
                          setState(() {
                            selectedPostId = postid;
                            activePets(selectedPostId, 'Yes');
                            int index1 = filterList.indexWhere((i) => i.postId == postid);
                            filterList[index1].active = 'Yes';
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            secondaryActions: [
              IconSlideAction(
                caption: 'Delete',
                color: themeColour,
                icon: LineAwesomeIcons.trash,
                onTap: (){
                  int index2 = filterList.indexWhere((i) => i.postId == postid);
                  selectedPostId = postid;
                  setState(() {
                    deleteAlertDialog(context,postid, pedCover, pedFamily, coverProfile, profile1, profile2, profile3, profile4, profile5,breed,index2);
                  });
                },
              )
            ],
          ),
        ),
        onTap: ()async{
          selectedPostId = postid;
          widget.toCheck == true?await usersRef.doc(widget.currentUserId).get().then((snapshot) {
            !snapshot.exists
                ? Navigator.push(context, MaterialPageRoute(builder: (context)=>home()))
                : Navigator.push(context,
                MaterialPageRoute(builder: (context)=> authScreen(
                  currentUserId: widget.currentUserId,
                  postId: selectedPostId,
                  pageIndex: 0,
                  breed: breed,
                  profile: coverProfile,
                  type: type,
                  profileOwnerId: ownerid,
                  gender: gender,
                  userLat: userLat!.toDouble(),
                  userLng: userLng!.toDouble(),
                  token: _getToken,
                ))
            );
          }):Navigator.push(context,
              MaterialPageRoute(builder: (context)=> authScreen(
                currentUserId: widget.currentUserId,
                postId: selectedPostId,
                pageIndex: 0,
                breed: breed,
                profile: coverProfile,
                type: type,
                profileOwnerId: ownerid,
                gender: gender,
                userLat: userLat!.toDouble(),
                userLng: userLng!.toDouble(),
                token: _getToken,
              ))
          );
        }
    );
  }

  Future<void> activePets(String postId, String choice){
    return petsRef.doc(postId).update({'active':choice})
        .then((value) => null)
        .catchError((error)=> print('Failed to update: $error'));
  }

  deletePet(String postId,String breed, String userId){
    petsRef.doc(postId).delete();
    petsRef.doc(postId).collection('weightAssessment').doc(userId).delete();
    petsIndexRef.doc(breed).collection(breed).doc(postId).delete();
    myPetsIndex.doc(widget.currentUserId).collection(widget.currentUserId.toString()).doc(postId).delete();
  }

  Future<dynamic> deleteAlertDialog(BuildContext context, String postId,pedigreeCover,pedigreeFamilyTree,coverprofile,profile1,profile2,profile3,profile4,profile5,breed,int index) {
    return showDialog(
        context: context,
        builder: (BuildContext context) =>
        Platform.isIOS ?
        CupertinoAlertDialog(
          title: Text('ต้องการลบรายการนี้ ใช่หรือไม่?',style: TextStyle(fontSize: isTablet?20:16)),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('ยืนยัน',style: TextStyle(color: Colors.red,fontSize: isTablet?20:16),),
              onPressed: () async {
                deletePet(postId,breed,widget.currentUserId.toString());


                setState(() {
                  for(var i = 0;i<filterList.length;i++){
                    if(filterList[i].postId == postId){
                      filterList.removeAt(i);
                    }
                  }
                });

                pedigreeCover == 'coverPed'? null:FirebaseStorage.instance.refFromURL(pedigreeCover).delete();
                pedigreeFamilyTree == 'familyTree'? null:FirebaseStorage.instance.refFromURL(pedigreeFamilyTree).delete();
                // coverprofile == 'cover'? null : FirebaseStorage.instance.refFromURL(coverprofile).delete();
                profile1 == 'profile1'? null : FirebaseStorage.instance.refFromURL(profile1).delete();
                profile2 == 'profile2'? null : FirebaseStorage.instance.refFromURL(profile2).delete();
                profile3 == 'profile3'? null : FirebaseStorage.instance.refFromURL(profile3).delete();
                profile4 == 'profile4'? null : FirebaseStorage.instance.refFromURL(profile4).delete();
                profile5 == 'profile5'? null : FirebaseStorage.instance.refFromURL(profile5).delete();

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
                child: Text('คุณต้องการลบรายการนี้\nใช่หรือไม่ ?',style: TextStyle(color: Colors.black,fontSize: isTablet?20:16)),
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
                        deletePet(postId,breed,widget.currentUserId.toString());

                        setState(() {
                          for(var i = 0;i<filterList.length;i++){
                            if(filterList[i].postId == postId){
                              filterList.removeAt(i);
                            }
                          }
                        });

                        pedigreeCover == 'coverPed'? null:FirebaseStorage.instance.refFromURL(pedigreeCover).delete();
                        pedigreeFamilyTree == 'familyTree'? null:FirebaseStorage.instance.refFromURL(pedigreeFamilyTree).delete();
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
                  SizedBox(width: 20),
                ],
              ),
            )

          ],
        )
    );
  }
}
