import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:multipawmain/accountDelete.dart';
import 'package:multipawmain/pages/myPets/infoFormAddPet.dart';
import 'package:multipawmain/pages/profile/profile.dart';
import 'package:multipawmain/setting/editProfilePictures.dart';
import 'package:multipawmain/setting/profileInfo/address/address.dart';
import 'package:multipawmain/setting/profileInfo/deliveryOptionAndStoreAddress.dart';
import 'package:multipawmain/setting/profileInfo/editProfileUserInfo.dart';
import 'package:multipawmain/setting/profileInfo/payment/payment.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/authCheck.dart';
import 'package:multipawmain/support/handleGettingImage.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io' show File, Platform;
import 'package:image/image.dart' as Im;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../changeUserName.dart';
import 'contactUs.dart';

double? lat,lng;
String? locality,postCode,country,name,error,current_location1,current_location2,current_city;
String? userUrl,userName;
String? dummy_a,dummy_b;
bool? isAppleSignIn;

String _location1 = '';
String _location2 = '';
String city = '';
late dynamic _distance;
late double _age;
int index = 0;
late String _active;
late bool isLoading;
late String imageId;
File? file;
bool isShowLoading = false;
bool toShow = true;
bool isTablet = false;

// PET's INFO
String? petName,breed,colour,pattern,gender,pedigree,pedCover,pedFamilyTree,farmOfOrigin,aboutPet,profileCover,profile1,profile2,profile3,profile4,profile5,selected;
int? birthDate,birthMonth,birthYear;
double? weight,height;
int? matingPrice;
File? fileCover,fileFamilytree;
DateTime? returnBirthDay;
var imgList;

Position? _currentPosition;
TextEditingController controller =TextEditingController();
TextEditingController nameController = TextEditingController();
TextEditingController originController = TextEditingController();   // Farm of origin
TextEditingController weightController = TextEditingController();
TextEditingController heightController = TextEditingController();
TextEditingController descriptionController = TextEditingController();

late bool isShow, isShowPedCover,isShowPedFamily;
String? selectedBreed,selectedColour,selectedPattern,selectedGender,selectedPed,userPlatform,pedCoverImg,pedFamilyTreeImg,new_pedCoverImg,new_pedFamilyTreeImg;
int? birthdayy,birthMonthh,birthYearr;
String cover = 'cover';
String family_tree = 'family_tree';

final DateTime timestamp = DateTime.now();

// ######################  BASE SETTING ######################

class baseSetting extends StatefulWidget {
  final String? userid,profileId,active,price,location1,location2,city;
  final dynamic age,distance;
  final double? lat,lng;


  baseSetting({required this.userid,required this.profileId,this.active,this.price,this.age,this.distance,required this.lat,required this.lng,this.location1,this.location2,this.city});

  @override
  _baseSettingState createState() => _baseSettingState();
}

class _baseSettingState extends State<baseSetting> with SingleTickerProviderStateMixin{
  late TabController tabController;
  final _formKey = GlobalKey<FormState>();
  String postId = Uuid().v4();
  bool isUploading = false;
  String a = '';

  Future<String> uploadImage(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('userProfile_$imageId.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }
    return a;
  }

  Future<String> uploadImagePedCover(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('postPedCover_$postId.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }
    return a;
  }

  Future<String> uploadImagePedFamily(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('postPedFamily_$postId.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }
    return a;
  }

  compressImage(File? file) async{
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image? imageFile = Im.decodeImage(file!.readAsBytesSync());
    final compressedImageFile = File('$path/userProfile_$imageId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile!,quality:15));
    setState(() {
      file = compressedImageFile;
    });
  }

  handleSubmitUserImg() async{
    String? imgUrl;

    // Remove old profile picture
    await usersRef.doc(widget.userid).get().then((snapshot){
      final oldImg = snapshot.data()!['urlProfilePic'];
      if(oldImg == null || oldImg == ''){

      }else{
        try{
          FirebaseStorage.instance.refFromURL(oldImg.toString()).delete();
        }catch(e){};}
    });

    // Compress and upload new profile picture
    file == null? null: await compressImage(file);
    file == null? null: imgUrl = await uploadImage(file);


    if(file != null){
      // Update a new profile picture
      await usersRef.doc(widget.userid).update({
        'urlProfilePic': imgUrl
      });

      // Update a new profile picture in pets profile
      await petsRef.where('id',isEqualTo: widget.userid).get().then((snapshot){
        snapshot.docs.forEach((data) {
          petsRef.doc(data.id).update({
            'ownerProfile': imgUrl
          });
        });
      });

      // Update a new profile picture in sell post
      await postsPuppyKittenRef.where('id',isEqualTo: widget.userid).get().then((snapshot){
        if(snapshot.size >0){
          snapshot.docs.forEach((data) {
            postsPuppyKittenRef.doc(data.id).update({
              'postOwnerprofileUrl': imgUrl
            });
          });
        }
      });

      // Update a new profile picture in chat
      await usersRef.where('id',isNotEqualTo: widget.userid).get()
          .then((snap) => {
        snap.docs.forEach((docId) {
          usersRef.doc(docId.id).collection('chattingWith').doc(widget.userid).update(
              {
                'profile': imgUrl
              });
        })
      });

      // Update a new profile picture in reviews (comments)
      await commentsRef.where('buyerId',isEqualTo: widget.userid).get()
          .then((snap){
        snap.docs.forEach((docId) {
          commentsRef.doc(docId.id).update(
              {
                'buyerProfile': imgUrl
              });
        });
      });
    }

    file != null? await file!.delete():null;
  }

  handleSubmitPedigreeImg()async{
    setState((){
      isUploading = true;
      isUploading== true? loading(): null;
    });



    fileCover == null? null: await compressImage(fileCover);
    fileFamilytree == null? null: await compressImage(fileFamilytree);


    fileCover == null? null: new_pedCoverImg = await uploadImagePedCover(fileCover);
    fileFamilytree == null? null: new_pedFamilyTreeImg = await uploadImagePedFamily(fileFamilytree);

    await petsRef.doc(widget.profileId).update({
      'coverPedigree': fileCover == null?pedCoverImg:new_pedCoverImg,
      'familyTreePedigree': fileFamilytree == null? pedFamilyTreeImg: new_pedFamilyTreeImg
    });

    dummy_a == null?null:FirebaseStorage.instance.refFromURL(dummy_a.toString()).delete();
    dummy_b == null?null:FirebaseStorage.instance.refFromURL(dummy_b.toString()).delete();


    fileCover != null? fileCover!.delete():null;
    fileFamilytree != null? fileFamilytree!.delete():null;

    setState(() {
      fileCover = null;
      fileFamilytree = null;
      postId = Uuid().v4();

      isUploading = false;
      isUploading== true? loading(): null;
    });
  }

  handleIndex()async{
    petsIndexRef.doc(selectedBreed).collection(selectedBreed.toString()).doc(widget.profileId).set(
        {
          'id':widget.userid,
          'postid' : widget.profileId,
          'timestamp': timestamp.millisecondsSinceEpoch
        });
    petsIndexRef.doc(breed).collection(breed.toString()).doc(widget.profileId).delete();
  }

  handleSubmit(){
    setState(() {
      isLoading = true;
    });
    if(index == 0)
    {
      if(_formKey.currentState!.validate()){
        petsRef.doc(widget.profileId).update(
            {
              'price': int.parse(controller.text),
              'active': _active
            });
      }

      petsRef.where('id',isEqualTo: widget.userid).get().then((snapshot){
        if(snapshot.size>0){
          snapshot.docs.forEach((docId) {
            petsRef.doc(docId.id).update({
              'location1': _location1.isEmpty?current_location1:_location1,
              'location2': _location2.isEmpty?current_location2:_location2,
              'city': city.isEmpty?current_city:city,
              'lat':lat,
              'lng':lng,
              'targetAgeEnd': _age,
              'targetDistance': _distance,
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            });
          });
        }
      });
      usersRef.doc(widget.userid).update({
        'location1': _location1.isEmpty?current_location1:_location1,
        'location2': _location2.isEmpty?current_location2:_location2,
        'city': city.isEmpty?current_city:city,
        'lat':lat,
        'lng':lng,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      setState(() {
        isLoading = false;
        if(_formKey.currentState!.validate()){
          Navigator.pop(context);
        }

      });
    }else if(index == 1){
      handleSubmitUserImg();
      setState(() {
        isLoading = false;
        // Navigator.pop(context);
      });
    }else if(index == 2){
      selectedColour == null? selectedColour = 'ขาว':null;

      if(_formKey.currentState!.validate()){
        birthdayy = returnBirthDay!.day;
        birthMonthh = returnBirthDay!.month;
        birthYearr = returnBirthDay!.year;

        petsRef.doc(widget.profileId).update(
            {
              'name': petName!=nameController.text?nameController.text: petName,
              'breed': breed != selectedBreed? selectedBreed:breed,
              'colour': colour != selectedColour ? selectedColour : colour,
              'pattern': pattern != selectedPattern ? selectedPattern : pattern,
              'gender': gender != selectedGender ? selectedGender : gender,
              'birthDay': birthDate != birthdayy? birthdayy:birthDate,
              'birthMonth' : birthMonth != birthMonthh? birthMonthh:birthMonth,
              'birthYear': birthYear != birthYearr ? birthYearr: birthYear,
              'pedigree' : pedigree != selectedPed ? selectedPed : pedigree,
              'originFarm' : farmOfOrigin!= originController.text ? originController.text: farmOfOrigin,
              'weight': weight.toString() != weightController.text ? double.parse(weightController.text):weight,
              'height': height.toString() != heightController.text ? double.parse(heightController.text):height,
              'aboutPet': aboutPet != descriptionController.text?descriptionController.text:aboutPet
            });
        handleSubmitPedigreeImg();
        handleIndex();
        setState(() {
          isLoading = false;
          Navigator.pop(context);
        });
      }
    }
  }

  Future<dynamic> getEditUser()async{
    isLoading = true;
    return usersRef.doc(widget.userid).get().then((snapshot){
      userUrl = snapshot.data()!['urlProfilePic'];
      userName = snapshot.data()!['name'];
      isAppleSignIn = snapshot.data()!['appleSignIn'];
    });
  }

  Future<dynamic> getEditPet()async{
    isLoading = true;
    return petsRef.doc(widget.profileId).get().then((snapshot){
      selected = snapshot.data()!['type'];
      petName = snapshot.data()!['name'];
      breed = snapshot.data()!['breed'];
      colour = snapshot.data()!['colour'];
      pattern = snapshot.data()!['pattern'];
      gender = snapshot.data()!['gender'];
      pedigree = snapshot.data()!['pedigree'];
      pedCover = snapshot.data()!['coverPedigree'];
      pedFamilyTree = snapshot.data()!['familyTreePedigree'];
      farmOfOrigin = snapshot.data()!['originFarm'];
      aboutPet = snapshot.data()!['aboutPet'];
      matingPrice = snapshot.data()!['price'];
      birthDate = snapshot.data()!['birthDay'];
      birthMonth = snapshot.data()!['birthMonth'];
      birthYear = snapshot.data()!['birthYear'];
      weight = snapshot.data()!['weight'];
      height = snapshot.data()!['height'];

      profileCover = snapshot.data()!['coverProfile'];
      profile1 = snapshot.data()!['profile1'];
      profile2 = snapshot.data()!['profile2'];
      profile3 = snapshot.data()!['profile3'];
      profile4 = snapshot.data()!['profile4'];
      profile5 = snapshot.data()!['profile5'];

      setState(() {
        returnBirthDay = DateTime(birthYear!,birthMonth!,birthDate!);
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    file = null;
    tabController = new TabController(length: 3, vsync: this);
    getEditUser();
    getEditPet();

    _age = double.parse(widget.age.toString());
    _distance = double.parse(widget.distance.toString());
    _active = widget.active.toString();
    controller.text = widget.price.toString();
    lat = widget.lat;
    lng = widget.lng;
    current_city = widget.city;
    current_location1 = widget.location1;
    current_location2 = widget.location2;

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    tabController.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: true,
          actions: [
            Padding(
              padding: EdgeInsets.only(top: 20,right: 15),
              child: InkWell(
                  child: toShow == false && index == 1 || index == 2
                      ? SizedBox()
                      :Text('เสร็จสิ้น',style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: (){
                    setState(() {
                      toShow = false;
                    });

                    handleSubmit();
                  }
              ),
            )
          ],
          backgroundColor: themeColour,
          title: Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text('ตั้งค่า',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18)
            ),
          ),
        ),
        body: DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(50),
                child: Container(
                  height: 50,
                  child: TabBar(
                    indicatorColor: themeColour,
                    unselectedLabelColor: Colors.grey,
                    labelColor: Colors.black,
                    tabs: [
                      Tab(text: 'ข้อมูลทั่วไป'),
                      Tab(text: 'โปรไฟล์'),
                      Tab(text: 'ข้อมูลสัตว์เลี้ยง'),
                    ],
                  ),
                ),
              ),
              body: TabBarView(
                children: [
                  setting(currentUserId: widget.userid,postId: widget.profileId),
                  editUser(userid: widget.userid),
                  editPets(
                    profileId: widget.profileId,
                    petName: petName,
                    breed: breed,
                    colour: colour,
                    pattern: pattern,
                    gender: gender,
                    pedigree: pedigree,
                    pedCover: pedCover,
                    pedFamilyTree: pedFamilyTree,
                    farmOfOrigin: farmOfOrigin,
                    aboutPet: aboutPet,
                    birthDate: birthDate,
                    birthMonth: birthMonth,
                    birthYear: birthYear,
                    weight: weight,
                    height: height,
                    profileCover: profileCover,
                    profile1: profile1,
                    profile2: profile2,
                    profile3: profile3,
                    profile4: profile4,
                    profile5: profile5,
                  )
                ],
              ),
            )
        ),
      ),
    );
  }
}

// ######################  SETTING PAGE ######################

class setting extends StatefulWidget {
  final String? currentUserId,postId;
  setting({this.currentUserId,this.postId});

  @override
  _settingState createState() => _settingState();
}

class _settingState extends State<setting> {
  late double Containerheight;

  _getAddressFromLatLng() async{
    try{
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition!.latitude,
          _currentPosition!.longitude
      );

      Placemark place = placemarks[0];

      setState(() {
        _location1 = "${place.name}";
        _location2 = '${place.locality},${place.administrativeArea}, ${place.postalCode}';
        city = place.name!.isEmpty?'${place.locality}':'${place.name}';

      });

    } catch(e){
      print(e);
    }
  }

  _getCurrentPosition() async{
    await Geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.medium,
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

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    Containerheight = 60;
    index = 0;
    setState(() {
      toShow = true;
    });
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
          body: isLoading == true || isShowLoading == true?loading():InkWell(
            onTap: (){
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: ListView(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                        padding: EdgeInsets.symmetric(vertical: 20,horizontal: 20),
                        child: Text('ที่อยู่สัตว์เลี้ยง',style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold,color: Colors.black))
                    ),
                    Padding(
                        padding: EdgeInsets.only(bottom: 10,left: 20,right: 20),
                        child: Container(
                          width: MediaQuery.of(context).size.width-45,
                          height: _location1==''?Containerheight = isTablet?80:70:Containerheight = 120,
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                              border: Border.all(color: Color(0xFF707070))
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        flex: 1,
                                        child: Text('ที่อยู่:',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: isTablet?20:16))
                                    ),
                                    Expanded(
                                        flex: 3,
                                        child: InkWell(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(20)),
                                              color: Colors.grey.shade200,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Icon(FontAwesomeIcons.mapMarkerAlt,color: themeColour),
                                                  SizedBox(width: 10),
                                                  Text('ค้นหาที่อยู่ปัจจุบัน',style: TextStyle(fontSize: isTablet?20:16))
                                                ],),
                                            ),
                                          ),
                                          onTap: ()async{
                                            setState(() {
                                              isShowLoading = true;
                                            });
                                            await _getCurrentPosition();

                                            setState(() {
                                              isShowLoading = false;
                                            });
                                          },
                                        )
                                    )],
                                ),
                                Visibility(
                                    visible: _location1.isNotEmpty,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: Text(
                                        '${_location1},${_location2}',
                                        style: TextStyle(fontSize: isTablet?16:12,color: Colors.grey.shade600),
                                        maxLines: 2,
                                      ),
                                    )
                                )
                              ],
                            ),
                          ),
                        )
                    ),

                    Padding(
                        padding: EdgeInsets.symmetric(vertical: 20,horizontal: 20),
                        child: Text('ค่าผสมพันธุ์',style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold,color: Colors.black))
                    ),
                    Padding(
                        padding: EdgeInsets.only(bottom: 10,left: 20,right: 20),
                        child: Container(
                          width: MediaQuery.of(context).size.width-45,
                          height: isTablet?90:80,
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                              border: Border.all(color: Color(0xFF707070))
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                            child: Row(
                              children: [
                                Expanded(flex: 2,child: Text('ราคา (บาท):',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: isTablet?20:16))),
                                Expanded(flex: 4,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: TextFormField(
                                        controller: controller,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                            hintText: 'ค่าผสมพันธุ์',
                                            hintStyle: TextStyle(fontSize: isTablet?20:16),
                                            focusedBorder: const UnderlineInputBorder(
                                                borderSide: const BorderSide(color: Color(0xFFD35757),width: 3)
                                            ),
                                            labelStyle: TextStyle(color:themeColour)
                                        ),
                                        validator: (value){
                                          if(value!.isEmpty){
                                            return 'กรุณาใส่ข้อมูล';
                                          }else if(double.parse(value)>1000000){
                                            return 'ราคาสูงสุดคือ 1 ล้านบาท';
                                          }
                                        },
                                      ),
                                    ))

                              ],
                            ),
                          ),
                        )
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40,vertical: 20),
                        child: Divider(color: themeColour,thickness: 2)),

                    Padding(
                        padding: EdgeInsets.only(bottom: 10,left: 20,right: 20),
                        child: Text('ตั้งค่าการค้นหา',style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold,color: Colors.black))
                    ),

                    Padding(
                      padding: EdgeInsets.only(bottom: 10,left: 20,right: 20),
                      child: Container(
                        width: MediaQuery.of(context).size.width-45,
                        height: isTablet?110:100,
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFF707070))
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('อายุ',style: TextStyle(fontWeight: FontWeight.bold,fontSize: isTablet?20:16)),
                              SizedBox(height: 5),
                              Slider(
                                  min: 1,
                                  max: 10,
                                  activeColor: themeColour,
                                  inactiveColor: Color(0xFFD59D9D),
                                  divisions: 9,
                                  value: _age,
                                  label: '$_age',
                                  onChanged: (dynamic val){
                                    setState(() {
                                      _age = val;
                                    });
                                  })
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    Padding(
                      padding: EdgeInsets.only(bottom: 10,left: 20,right: 20),
                      child: Container(
                        width: MediaQuery.of(context).size.width-45,
                        height: isTablet?110:100,
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFF707070))
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('ระยะทางในการค้นหา (กิโลเมตร)',style: TextStyle(fontWeight: FontWeight.bold,fontSize: isTablet?20:16)),
                              SizedBox(height: 5),
                              Slider(
                                  min: 0.00,
                                  max: 600,
                                  activeColor: themeColour,
                                  inactiveColor: Color(0xFFD59D9D),
                                  value: _distance,
                                  divisions: 12,
                                  label: '$_distance',
                                  onChanged: (dynamic val){
                                    setState(() {
                                      _distance = val;
                                    });
                                  })
                            ],
                          ),
                        ),
                      ),
                    ),

                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40,vertical: 20),
                        child: Divider(color: themeColour,thickness: 2)
                    ),

                    Padding(
                        padding: EdgeInsets.only(bottom: 10,left: 20,right: 20),
                        child: Text('ต้องการหาคู่อยู่หรือไม่ ?',style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold,color: Colors.black))
                    ),

                    Padding(
                      padding: EdgeInsets.only(left: 20,top: 5),
                      child: Row(
                        children: [
                          Text('Active : ',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: isTablet?20:16)),
                          IconButton(
                            iconSize: 40,
                            icon: _active == 'Yes'
                                ? Icon(Icons.toggle_on,color: Colors.green,)
                                :Icon(Icons.toggle_off,color: Colors.red),
                            onPressed: () {
                              setState(() {
                                if(_active == 'Yes')
                                {
                                  _active = 'No';
                                }
                                else if(_active == 'No')
                                {
                                  _active = 'Yes';
                                }
                              });
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          )

      ),
    );
  }
}

// ######################  EDIT USER PAGE ######################

class editUser extends StatefulWidget {
  final String? userid;
  editUser({required this.userid});

  @override
  _editUserState createState() => _editUserState();
}

class _editUserState extends State<editUser> {
  dynamic picker = ImagePicker();
  
  updateLiveChatStatus()async{
    await allHelpChatRef.doc(widget.userid).get().then((snapshot){
      if(!snapshot.exists){}else{
        if(snapshot.data()!['isDone'] == true){
          allHelpChatRef.doc(widget.userid).update({
            'isShow': false
          });

          helpChatRef.doc(widget.userid).collection(widget.userid.toString()).where('toShow',isEqualTo: true).get().then((snapshot){
            snapshot.docs.forEach((doc){
              helpChatRef.doc(widget.userid).collection(widget.userid.toString()).doc(doc.id).update(
                  {
                    'toShow': false
                  });
            });
          });
        }
      }
    });
  }

  clearImage(File? file) {
    if (file == null) return;
    File? tmp_file = File(file.path);
    tmp_file = null;

    setState(() {
      file = tmp_file;
    });
    return tmp_file;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateLiveChatStatus();
    index = 1;
    setState(() {
      toShow = true;
    });
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade300,
        body: isLoading == true? loading():ListView(
          children: [
            Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height*4/15,
              child: Stack(
                children: [
                  Positioned.fill(
                    top: MediaQuery.of(context).size.height*1/14,
                    child: Align(
                      alignment: Alignment.center,
                      child:

                      file == null && userUrl != ""
                          ?CircleAvatar(
                        radius: isTablet?120:90.0,
                        backgroundImage: NetworkImage(userUrl.toString()),
                        backgroundColor: Colors.transparent,
                      )

                          :file == null && userUrl == ""
                          ?Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black)
                        ),
                        child: CircleAvatar(
                          radius: isTablet?120:90.0,
                          child: Center(child: Icon(FontAwesomeIcons.userAlt,color: Colors.black,size: 80)),
                          backgroundColor: Colors.transparent,
                        ),
                      )

                          :CircleAvatar(
                        radius: isTablet?120:90.0,
                        backgroundImage: FileImage(file!),
                        backgroundColor: Colors.transparent,
                      ),

                    ),
                  ),

                  Positioned(
                      bottom: isTablet?MediaQuery.of(context).size.height*1/90:0,
                      right: isTablet?MediaQuery.of(context).size.width*5/13:MediaQuery.of(context).size.width*3/11,
                      child: InkWell(
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                color: Colors.grey.shade300
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                children: [
                                  Icon(Icons.edit,color: Colors.black),
                                  SizedBox(width: 5),
                                  Text('แก้ไข',style: TextStyle(color: Colors.black,fontSize: isTablet?20:16))
                                ],
                              ),
                            ),
                          ),
                          onTap: ()async{
                            file = await Navigator.push(context, MaterialPageRoute(builder: (context)=>handleGettingImage(file: file)));
                            setState(() {

                            });
                          }
                      )
                  )
                ],
              ),
            ),
            isAppleSignIn == true?InkWell(
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 10),
                      Text(userName.toString(),style: TextStyle(fontSize: isTablet?25:15,fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Text('(เปลี่ยนชื่อ)',style: TextStyle(color: Colors.grey))
                    ],
                  )
              ),
              onTap: ()=>Navigator.push(context, MaterialPageRoute(
                  builder: (context)=>
                      changeUserName(
                          userId: widget.userid.toString(),
                          name: userName.toString()
                      )
              )).then((snapshot)async{
                await usersRef.doc(widget.userid.toString()).get().then((snap){
                  setState(() {
                    userName = snap.data()!['name'];
                    isAppleSignIn = snap.data()!['appleSignIn'];
                  });
                });
              }),
            )
                :Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 60,
                color: Colors.white,
                  child: Center(
                    child: Text(userName.toString(),style: TextStyle(fontSize: isTablet?30:25,fontWeight: FontWeight.bold)
                    ),
                  )
              ),
            ),

            buildPaymentAddressButton(context,'โปรไฟล์',()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>editProfileUserInfo(userId: widget.userid)))),
            //######################################
            // Uncommented if want to show shop
            buildPaymentAddressButton(context,'ที่อยู่เพื่อจัดส่ง',()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>address(userId: widget.userid)))),
            buildPaymentAddressButton(context,'บัญชีธนาคาร',()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>payment(userId: widget.userid)))),
            buildPaymentAddressButton(context,'ที่ตั้งร้านค้าและการจัดส่ง',()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>deliveryOptionAndStoreAddress(userId: widget.userid,type: 'ที่ตั้งร้านค้าและการจัดส่ง')))),
            //######################################

            buildPaymentAddressButton(context,'ติดต่อเรา',()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>contactUs(userId: widget.userid, userImage: userUrl, userName: userName))).then((value){
              updateLiveChatStatus();
            })),
          ],
        ),
      ),
    );
  }

  InkWell buildPaymentAddressButton(BuildContext context,String topic, Function() ontap) {
    return InkWell(
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(bottom: 3),
        decoration: BoxDecoration(
          color: Colors.white,
            border: Border.all(color: Colors.grey.shade200)
        ),
        child: ListTile(
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0,vertical: 15),
            child: Text(topic,style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold)),
          ),
          trailing: Icon(Icons.arrow_forward_ios_outlined),
        ),
      ),
      onTap: ontap,
    );
  }
}

class editPets extends StatefulWidget {

  String? petName,breed,colour,pattern,gender,pedigree,pedCover,pedFamilyTree,farmOfOrigin,aboutPet,profileCover,profile1,profile2,profile3,profile4,profile5;
  int? birthDate,birthMonth,birthYear;
  double? weight,height;

  final String? profileId;
  editPets({
    required this.profileId,
    this.petName,
    this.breed,
    this.colour,
    this.pattern,
    this.gender,
    this.pedigree,
    this.pedCover,
    this.pedFamilyTree,
    this.farmOfOrigin,
    this.aboutPet,
    this.profileCover,
    this.profile1,
    this.profile2,
    this.profile3,
    this.profile4,
    this.profile5,
    this.birthDate,
    this.birthMonth,
    this.birthYear,
    this.weight,
    this.height
  });

  @override
  _editPetsState createState() => _editPetsState();
}

class _editPetsState extends State<editPets> {
  final _formKey = GlobalKey<FormState>();
  dynamic picker = ImagePicker();
  String postId = Uuid().v4();
  String a = '';


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      SizerUtil.deviceType == DeviceType.tablet?isTablet = true:isTablet = false;
    });
    index = 2;


    setState(() {
      pedigree == 'No'?isShow = false:isShow = true;
      pedCoverImg = pedCover;
      pedFamilyTreeImg = pedFamilyTree;
      toShow = true;
    });

    nameController.text = petName.toString();
    selectedBreed = breed;
    selectedColour = colour;
    selectedPattern = pattern;
    selectedGender = gender;
    birthdayy = birthDate;
    birthMonthh = birthMonth;
    birthYearr = birthYear;
    selectedPed = pedigree;

    weightController.text = weight.toString();
    heightController.text = height.toString();
    descriptionController.text = aboutPet.toString();
  }

  clearImage(File? file) {
    if (file == null) return;
    File? tmp_file = File(file.path);
    tmp_file = null;

    setState(() {
      file = tmp_file;
    });
    return tmp_file;
  }

  @override
  Widget build(BuildContext context) {

    Column buildTextFormField(String topic, TextEditingController controller) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(topic,style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold),),
          Container(
            color: Colors.white,
            height: 60,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                  hintText: 'ชื่อสัตว์เลี้ยง',
                  hintStyle: TextStyle(fontSize: isTablet?20:16),
                  focusedBorder: const UnderlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFD35757),width: 3)
                  ),
                  labelStyle: TextStyle(color:themeColour)
              ),
              validator: (value){
                if(value!.isEmpty){
                  return 'กรุณาใส่ข้อมูล';
                }else if(value.length>15)
                {
                  return 'ชื่อยาวสุดคือ 14 ตัวอักษร';
                }
                return null;
              },
            ),
          ),
        ],
      );
    }

    Column buildRowField(String topic, String? name,Function() ontap) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(topic,style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: InkWell(
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: name==null?
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('',style: TextStyle(color: Colors.grey.shade600,fontSize: 15),),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Divider(color: Colors.black,height:2),
                      )
                    ],
                  ):Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,style: TextStyle(color: Colors.black,fontSize: isTablet?21:17),),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Divider(color: Colors.black,height:2),
                      )
                    ],
                  )
              ),
              onTap: ontap,
            ),
          ),
          SizedBox(height: 10)
        ],
      );
    }

    return SafeArea(
        child:Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: InkWell(
        onTap: (){
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: ListView(
          children: [
            Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height*0.9/4,
              alignment: Alignment.center,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: CircleAvatar(
                        radius: isTablet?120:90.0,
                        backgroundImage: NetworkImage(profileCover.toString()),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: isTablet?MediaQuery.of(context).size.height*1/40:10,
                    right: isTablet?MediaQuery.of(context).size.width*5/13:MediaQuery.of(context).size.width*3/11,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: Colors.grey.shade300
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: InkWell(
                            child: Row(
                              children: [
                                Icon(Icons.edit,color: Colors.black),
                                SizedBox(width: 3),
                                Text('แก้ไข',style: TextStyle(color: Colors.black,fontSize: isTablet?20:16))
                              ],
                            ),
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context)=>editProfilePicture(
                                    profileCover: widget.profileCover,
                                    profile1: widget.profile1,
                                    profile2: widget.profile2,
                                    profile3: widget.profile3,
                                    profile4: widget.profile4,
                                    profile5: widget.profile5,
                                    profileId: widget.profileId,
                                  )
                              ));

                            }
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            buildDivider(),
            Card(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                child: buildTextFormField('ชื่อของสัตว์เลี้ยง:',nameController),
              ),
            ),
            buildDivider(),
            Card(
              child: Padding(
                padding: EdgeInsets.only(top:10, bottom: 10,left: 20,right: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text('ข้อมูลทั่วไป',style: TextStyle(fontSize: isTablet?30:20,fontWeight: FontWeight.bold)),
                    ),
                    buildRowField('สายพันธุ์:',selectedBreed,()async{
                      final result = await Navigator.push(context, MaterialPageRoute(builder: (context)=>breedPage(selected: selected)));
                      setState(() {
                        selectedBreed = result;
                        selectedColour = null;
                      });
                    }),
                    buildRowField('สี',selectedColour,()async{
                      final result = await Navigator.push(context, MaterialPageRoute(builder: (context)=>colourPage(selected: selected,selectedbreed: selectedBreed)));
                      setState(() {
                        selectedColour = result;
                      });
                    }),

                    selected == 'แมว'? buildRowField('แพทเทิร์นของขน',selectedPattern,()async{
                      final result = await Navigator.push(context, MaterialPageRoute(builder: (context)=>catPattern()));
                      setState(() {
                        selectedPattern = result;
                      });
                    }):SizedBox(),

                    buildRowField('เพศ', selectedGender, ()async{
                      final result = await Navigator.push(context, MaterialPageRoute(builder: (context)=>genderPage()));
                      setState(() {
                        selectedGender = result;
                      });
                    }),
                    buildRowFieldDateTime('วันเดือนปีเกิด', returnBirthDay, (){
                      DatePicker.showDatePicker(context,
                          showTitleActions: true,
                          minTime: now.subtract(Duration(days: 3650)),
                          maxTime: now,
                          theme: const DatePickerTheme(
                              doneStyle: TextStyle(
                                  color: themeColour
                              )
                          ),
                          onConfirm: (date) {
                            setState(() {
                              returnBirthDay = date;
                            });
                          },
                          currentTime: returnBirthDay,
                          locale: LocaleType.th
                      );
                    }),


                  ],
                ),
              ),
            ),
            buildDivider(),
            Card(
              child: Padding(
                padding: EdgeInsets.only(top:10, bottom: 0,left: 20,right: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text('ข้อมูลสัตว์เลี้ยง',style: TextStyle(fontSize: isTablet?30:20,fontWeight: FontWeight.bold)),
                    ),
                    buildRowField('มีใบเพ็ดดีกรีหรือไม่', selectedPed == 'Yes'?'มี':'ไม่มี', ()async{
                      final result = await Navigator.push(context, MaterialPageRoute(builder: (context)=>pedigreePage()));
                      setState(() {
                        selectedPed = result;
                        selectedPed == 'Yes'?isShow = true:isShow = false;
                      });
                    }),
                    Visibility(
                      child: Padding(
                        padding: const EdgeInsets.only(top:0,bottom: 10,left: 0,right:20),
                        child:
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: Text('กรุณาอัพโหลด หน้าปกเพ็ดดีกรี และ ข้อมูลด้านใน',style: TextStyle(fontWeight: FontWeight.bold,fontSize: isTablet?20:16),),
                            ),
                            Row(
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: SizedBox()
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Column(
                                    children: [
                                      Container(
                                        child: pedCoverImg == 'coverPed' && fileCover == null?
                                        InkWell(
                                          child: Container(
                                            height: isTablet?380:110,
                                            width: MediaQuery.of(context).size.width * 0.3,
                                            decoration: BoxDecoration(
                                                border:  Border.all(color: Colors.black)
                                            ),
                                            child: AspectRatio(
                                              aspectRatio: 8 / 10.5,
                                              child: Container(
                                                height: isTablet?380:110,
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image:AssetImage('assets/PetCover.png')
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          onTap: ()async{
                                            fileCover = await Navigator.push(context, MaterialPageRoute(builder: (context)=>handleGettingImage(file: fileCover)));
                                          },
                                        )
                                            
                                            
                                            :pedCoverImg != 'coverPed' && fileCover == null?
                                        InkWell(
                                          child: Container(
                                            width: MediaQuery.of(context).size.width * 0.30,
                                            padding: EdgeInsets.symmetric(horizontal: 10),
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  child: AspectRatio(
                                                    aspectRatio: 8 / 10.5,
                                                    child: Container(
                                                      height: isTablet?380:110,
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: NetworkImage(pedCoverImg.toString()),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                    bottom: 0,
                                                    right: 0,
                                                    child: InkWell(
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            color: Colors.white
                                                        ),
                                                        child: Icon(
                                                            Icons.close,color: Colors.red
                                                        ),
                                                      ),
                                                      onTap: (){
                                                        setState(() {
                                                          dummy_a = pedCoverImg;
                                                          pedCoverImg = 'coverPed';
                                                        });
                                                      },
                                                    )
                                                )
                                              ],
                                            ),
                                          ),

                                        ):
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.30,
                                          padding: EdgeInsets.symmetric(horizontal: 10),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                child: AspectRatio(
                                                  aspectRatio: 8 / 10.5,
                                                  child: Container(
                                                    height: isTablet?380:110,
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: FileImage(fileCover!),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                  bottom: 0,
                                                  right: 0,
                                                  child: InkWell(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: Colors.white
                                                      ),
                                                      child: Icon(
                                                          Icons.close,color: Colors.red
                                                      ),
                                                    ),
                                                    onTap: (){
                                                      setState(() {
                                                        fileCover = clearImage(fileCover);
                                                        pedCoverImg = 'coverPed';
                                                      });
                                                    },
                                                  )
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Text('หน้าปกเพ็ดดีกรี',style: TextStyle(fontSize: isTablet?20:16))
                                    ],
                                  ),
                                ),
                                Expanded(
                                    flex: 1,
                                    child: SizedBox()
                                ),

                                Expanded(
                                  flex: 5,
                                  child: Column(
                                    children: [
                                      Column(
                                        children: [
                                          Container(
                                            child: pedFamilyTreeImg == 'familyTree' && fileFamilytree == null?
                                            InkWell(
                                              child: Container(
                                                height: isTablet?380:110,
                                                width: MediaQuery.of(context).size.width * 0.3,
                                                decoration: BoxDecoration(
                                                    border:  Border.all(color: Colors.black)
                                                ),
                                                child: AspectRatio(
                                                  aspectRatio: 8 / 10.5,
                                                  child: Container(
                                                    height: isTablet?380:110,
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image:AssetImage('assets/PetCover.png')
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              onTap: ()async{
                                                fileFamilytree = await Navigator.push(context, MaterialPageRoute(builder: (context)=>handleGettingImage(file: fileFamilytree)));
                                              },
                                            ):pedFamilyTreeImg != 'familyTree' && fileFamilytree == null?
                                            InkWell(
                                              child: Container(
                                                width: MediaQuery.of(context).size.width * 0.30,
                                                padding: EdgeInsets.symmetric(horizontal: 10),
                                                child: Stack(
                                                  children: [
                                                    Positioned(
                                                      child: AspectRatio(
                                                        aspectRatio: 8 / 10.5,
                                                        child: Container(
                                                          height: isTablet?380:110,
                                                          decoration: BoxDecoration(
                                                            image: DecorationImage(
                                                              fit: BoxFit.cover,
                                                              image: NetworkImage(pedFamilyTreeImg.toString()),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                        bottom: 0,
                                                        right: 0,
                                                        child: InkWell(
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                shape: BoxShape.circle,
                                                                color: Colors.white
                                                            ),
                                                            child: Icon(
                                                                Icons.close,color: Colors.red
                                                            ),
                                                          ),
                                                          onTap: (){
                                                            setState(() {
                                                              dummy_b = pedFamilyTreeImg;
                                                              pedFamilyTreeImg = 'familyTree';
                                                            });
                                                          },
                                                        )
                                                    )
                                                  ],
                                                ),
                                              ),

                                            ):
                                            Container(
                                              width: MediaQuery.of(context).size.width * 0.30,
                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                              child: Stack(
                                                children: [
                                                  Positioned(
                                                    child: AspectRatio(
                                                      aspectRatio: 8 / 10.5,
                                                      child: Container(
                                                        height: isTablet?380:110,
                                                        decoration: BoxDecoration(
                                                          image: DecorationImage(
                                                            fit: BoxFit.cover,
                                                            image: FileImage(fileFamilytree!),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                      bottom: 0,
                                                      right: 0,
                                                      child: InkWell(
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              shape: BoxShape.circle,
                                                              color: Colors.white
                                                          ),
                                                          child: Icon(
                                                              Icons.close,color: Colors.red
                                                          ),
                                                        ),
                                                        onTap: (){
                                                          setState(() {
                                                            fileFamilytree = clearImage(fileFamilytree);
                                                            pedFamilyTreeImg = 'familyTree';
                                                          });
                                                        },
                                                      )
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          Text('ข้อมูลเพ็ดดีกรี',style: TextStyle(fontSize: isTablet?20:16))
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                    flex: 1,
                                    child: SizedBox()),
                              ],
                            ),

                            SizedBox(height: 15)
                          ],
                        ),
                      ),
                      visible: isShow,
                    )
                  ],
                ),
              ),
            ),
            buildDivider(),
            Card(
              child: Padding(
                padding: EdgeInsets.only(top:10, bottom: 10,left: 20,right: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text('สัดส่วน',style: TextStyle(fontSize: isTablet?30:20,fontWeight: FontWeight.bold)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Weight section
                        Expanded(
                            flex:3,
                            child: Text('น้ำหนัก (kg):',style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold),)
                        ),
                        Expanded(
                            flex: 5,
                            child: Container(
                              color: Colors.white,
                              height: 40,
                              child: TextFormField(
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                controller: weightController,
                                decoration: InputDecoration(
                                    focusedBorder: const UnderlineInputBorder(
                                        borderSide: const BorderSide(color: Color(0xFFD35757),width: 3)
                                    ),
                                    labelStyle: TextStyle(color:themeColour)
                                ),
                                validator: (value){
                                  if(value!.isEmpty){
                                    return 'โปรดใส่ข้อมูล';
                                  }
                                  else if(double.parse(value)>=100.0)
                                  {
                                    return 'ข้อมูลไม่ถูกต้อง';
                                  }
                                  return null;
                                },
                              ),
                            )
                        ),
                        Expanded(
                            flex: 1,
                            child: SizedBox()
                        ),
                        // Height Section
                        Expanded(
                            flex:3,
                            child: Text('ส่วนสูง (cm):',style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold),)
                        ),
                        Expanded(
                            flex: 5,
                            child: Container(
                              color: Colors.white,
                              height: 40,
                              child: TextFormField(
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                controller: heightController,
                                decoration: InputDecoration(
                                    focusedBorder: const UnderlineInputBorder(
                                        borderSide: const BorderSide(color: Color(0xFFD35757),width: 3)
                                    ),
                                    labelStyle: TextStyle(color:themeColour)
                                ),
                                validator: (value){
                                  if(value!.isEmpty){
                                    return 'กรุณาใส่ข้อมูล';
                                  }
                                  else if(double.parse(value)>=100.0)
                                  {
                                    return 'ข้อมูลไม่ถูกต้อง';
                                  }
                                  return null;
                                },
                              ),
                            )
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Text('** ความสูงวัดจากพื้นถึงหัวไหล่',style: TextStyle(color: Colors.red.shade900,fontWeight: FontWeight.bold,fontSize: isTablet?20:16),maxLines: 2),
                    SizedBox(height: 20)
                  ],
                ),
              ),
            ),

            buildDivider(),
            Card(
                child: Padding(
                  padding: EdgeInsets.only(top:10, bottom: 10,left: 20,right: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text('ข้อมูลเพิ่มเติม',style: TextStyle(fontSize: isTablet?30:20,fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        color: Colors.white,
                        child: TextFormField(
                            controller: descriptionController,
                            maxLines: null,
                            decoration: InputDecoration(
                                hintText: "ข้อมูลเพิ่มเติม",
                                hintStyle: TextStyle(fontSize: isTablet?20:16),
                                enabledBorder: const OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.black,width: 1)
                                ),
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: const BorderSide(color: Color(0xFFD35757),width: 3)
                                ),
                                labelStyle: TextStyle(color:themeColour)

                            )
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                )
            )
          ],
        ),
      ),
    ));
  }

  Column buildRowFieldDateTime(String topic, DateTime? name,Function() ontap) {
    final DateFormat formatter = DateFormat('dd MMM yyyy');
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(topic,style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: InkWell(
            child: Container(
                width: MediaQuery.of(context).size.width,
                child: name==null?
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('กรุณาเลือก ${topic}',style: TextStyle(color: Colors.grey.shade600,fontSize: isTablet?20:16),),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Divider(color: Colors.black,height:2),
                    )
                  ],
                ):Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(formatter.format(name),style: TextStyle(color: Colors.black,fontSize: isTablet?21:17),),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Divider(color: Colors.black,height:2),
                    )
                  ],
                )
            ),
            onTap: ontap,
          ),
        ),
        SizedBox(height: 10)
      ],
    );
  }
}

// ######################   PREVIEW POSTING IMAGE PAGE ######################

class prevAndUploadImg extends StatefulWidget {
  final File? file;
  prevAndUploadImg({required this.file});

  @override
  _prevAndUploadImgState createState() => _prevAndUploadImgState();
}

class _prevAndUploadImgState extends State<prevAndUploadImg> {
  File? cropedFile,showFile;

  cropSquareImage() async{
    cropedFile = await  ImageCropper().cropImage(
        sourcePath: widget.file!.path,
        maxHeight: 1080,
        maxWidth: 1080
    );
    if(cropedFile != null){
      setState(() {
        showFile = cropedFile;

      });
    }else{
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      cropSquareImage();
    });
  }

  @override
  Widget build(BuildContext context) {
    imageId = Uuid().v4();

    return SafeArea(
      child: showFile == null? loading():Scaffold(
          backgroundColor: Colors.grey.shade900,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: MediaQuery.of(context).size.height*7/10,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fitWidth,
                    image: FileImage(showFile!),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                      padding: EdgeInsets.only(left: 20,top: isTablet?10:20),
                      child: InkWell(
                          child: Text('ยกเลิก',style: TextStyle(color: Colors.blue.shade100,fontSize: 18,fontWeight: FontWeight.bold)),
                          onTap: () {
                            file = null;
                            Navigator.pop(context);
                          }
                      )
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 20,top: isTablet?10:20),
                    child: InkWell(child: Text('เสร็จสิ้น',style: TextStyle(color: Colors.yellow.shade600,fontSize: isTablet?20:16,fontWeight: FontWeight.bold)),
                        onTap: (){
                          Navigator.pop(context,showFile);
                          Navigator.pop(context,showFile);
                        }
                    ),
                  ),
                ],
              )
            ],
          )
      ),
    );
  }
}

class prevAndUploadForChat extends StatefulWidget {
  final File? file;
  prevAndUploadForChat({required this.file});

  @override
  _prevAndUploadForChatState createState() => _prevAndUploadForChatState();
}

class _prevAndUploadForChatState extends State<prevAndUploadForChat> {
  File? cropedFile,showFile;

  cropSquareImage() async{
    cropedFile = await  ImageCropper().cropImage(
        sourcePath: widget.file!.path,
        maxHeight: 1080,
        maxWidth: 1080
    );
    if(cropedFile != null){
      setState(() {
        showFile = cropedFile;
      });
    }else{
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      cropSquareImage();
    });
  }
  @override
  Widget build(BuildContext context) {
    imageId = Uuid().v4();

    return SafeArea(
      child: showFile == null? loading():Scaffold(
          backgroundColor: Colors.grey.shade900,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: MediaQuery.of(context).size.height*7/10,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fitWidth,
                    image: FileImage(showFile!),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                      child: InkWell(
                          child: Text('ยกเลิก',style: TextStyle(color: Colors.blue.shade100,fontSize: 18,fontWeight: FontWeight.bold)),
                          onTap: () {
                            file = null;
                            Navigator.pop(context);
                          }
                      )
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                    child: InkWell(child: Text('เสร็จสิ้น',style: TextStyle(color: Colors.yellow.shade600,fontSize: 18,fontWeight: FontWeight.bold)),
                        onTap: (){
                          Navigator.pop(context,showFile);
                        }
                    ),
                  ),
                ],
              )
            ],
          )
      ),
    );
  }
}
