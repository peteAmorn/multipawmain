import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multipawmain/database/breedDatabase.dart';
import 'package:multipawmain/authCheck.dart';
import 'dart:io';
import 'package:image/image.dart' as Im;
import 'package:multipawmain/profileWIthoutPet.dart';
import 'package:multipawmain/setting/profileInfo/deliveryOptionAndStoreAddress.dart';
import 'package:multipawmain/setting/profileInfo/payment/addBankAccount.dart';
import 'package:sizer/sizer.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/support/handleGettingImage.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../authScreenWithoutPet.dart' as PP;
import '../../questionsAndConditions/conditionSeller.dart';

final DateTime timestamp = DateTime.now();
bool isTablet = false;

class addSellPost extends StatefulWidget {
  final String userId;
  addSellPost({required this.userId});

  @override
  _addSellPostState createState() => _addSellPostState();
}

class _addSellPostState extends State<addSellPost> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController topicController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  String? selectedType,selectedBreed,selectedColour,selectedPattern,selectedGender,selectedPed,uploadParentImg,pedType;
  String? selectedBreed_dummy,selectedColour_dummy,selected_age_dummy;
  String profileCoverImg = 'cover';
  String profile1Img = 'profile1';
  String profile2Img = 'profile2';
  String profile3Img = 'profile3';
  String profile4Img = 'profile4';
  String profile5Img = 'profile5';
  String dad = 'dad';
  String mum = 'mum';
  File? file,fileProCover,filePro1,filePro2,filePro3,filePro4,filePro5,fileDad,fileMum;
  String a = '';

  late bool isShowPed,isShowParent;
  bool isLoading = false;
  bool toDeliverDetail = true;
  bool canSubmit = false;
  bool active = true;
  String? postOwnerName,coverProfile,postOwnerprofileUrl,city,location1,location2;
  bool isBankAccountExist = false;

  DateTime? returnBirthDay,returnReadyToDispatch;

  String postId = Uuid().v4();
  dynamic picker = ImagePicker();

  checkSellerAccount()async{
    await usersRef.doc(widget.userId).collection('payment').doc(widget.userId).collection('bankAccount').get().then((snapshot){
      if(snapshot.size == 0){
        setState(() {
          isBankAccountExist = false;
        });
      }else{
        setState(() {
          isBankAccountExist = true;
        });
      }
    });
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
                    Text(formatter.format(name),style: TextStyle(color: Colors.black,fontSize: isTablet?20:16),),
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

  checkSellerAddress()async{
    usersRef.doc(widget.userId).collection('storeLocationAndDeliveryOption').doc(widget.userId).get().then((snapshot){
      if(snapshot.exists){
        setState(() {
          toDeliverDetail = false;
          canSubmit = true;
        });
      }
    });
  }

  Future<dynamic> getUserData()async{

    setState(() {
      isLoading = true;
    });

    await usersRef.doc(widget.userId).get().then((snapshot){
      postOwnerName = snapshot.data()!['name'];
      postOwnerprofileUrl = snapshot.data()!['urlProfilePic'];
      city = snapshot.data()!['city'];
      location1 = snapshot.data()!['location1'];
      location2 = snapshot.data()!['location2'];
    });

    setState(() {
      isLoading = false;
    });

  }

  createPostInFirestore
      ({
    final coverProfile,
    final profile1,
    final profile2,
    final profile3,
    final profile4,
    final profile5,
    final dad,
    final mum
  }){
    postsPuppyKittenRef.doc(postId).set({
      'postid': postId,
      'topicName': topicController.text,
      'type': selectedType,
      'breed': selectedBreed,
      'colour': selectedColour,
      'pattern': selectedPattern,
      'gender': selectedGender,

      'birthDay': returnBirthDay!.day,
      'birthMonth': returnBirthDay!.month,
      'birthYear': returnBirthDay!.year,

      'pedigree': selectedPed,
      'pedType': pedType,
      'parentImg': dad == 'dad' && mum == 'mum'?'No':uploadParentImg,
      'description': descriptionController.text,
      'price': int.parse(priceController.text),

      'dispatchDate': returnReadyToDispatch!.day,
      'dispatchMonth': returnReadyToDispatch!.month,
      'dispatchYear': returnReadyToDispatch!.year,
      'coverProfile': coverProfile,
      'profile1': profile1,
      'profile2': profile2,
      'profile3': profile3,
      'profile4': profile4,
      'profile5': profile5,
      'dadImg': dad,
      'mumImg': mum,

      'timestamp': timestamp.millisecondsSinceEpoch,

      'city':city,
      'location1':location1,
      'location2': location2,
      'postOwnerName': postOwnerName,
      'id' : widget.userId,
      'postOwnerprofileUrl': postOwnerprofileUrl!=null?postOwnerprofileUrl:'',
      'view':0,
      'comment': 'none',
      'active': active
    });

    postsPuppyKittenIndexRef.doc(selectedBreed).collection(selectedBreed.toString()).doc(postId).set(
        {
          'id':widget.userId,
          'postid':postId,
          'timestamp': timestamp.millisecondsSinceEpoch
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

  compressImage(File? file) async{
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image? imageFile = Im.decodeImage(file!.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile!,quality:35));
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImageCover(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('postProfileCover_$postId.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }
    return a;
  }

  Future<String> uploadImageProfile1(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('postProfile1_$postId.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }
    return a;
  }

  Future<String> uploadImageProfile2(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('postProfile2_$postId.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }
    return a;
  }

  Future<String> uploadImageProfile3(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('postProfile3_$postId.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }
    return a;
  }

  Future<String> uploadImageProfile4(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('postProfile4_$postId.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }
    return a;
  }

  Future<String> uploadImageProfile5(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('postProfile5_$postId.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }
    return a;
  }

  Future<String> uploadImageDad(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('postDad_$postId.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }
    return a;
  }

  Future<String> uploadImageMum(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('postMum_$postId.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }
    return a;
  }

  handleSubmit() async{
    List<String?> images = ['cover','profile1','profile2','profile3','profile4','profile5','dad','mum'];

    List<File?> path = [fileProCover,filePro1,filePro2,filePro3,filePro4,filePro5,fileDad,fileMum];

    setState(() {
      isLoading = true;
    });

    for(var i=0;path.length>i;i++) {
      path[i] == null ? null : await compressImage(path[i]);
    }

    path[0] == null? null: images[0] = await uploadImageCover(path[0]);
    path[1] == null? null: images[1] = await uploadImageProfile1(path[1]);
    path[2] == null? null: images[2] = await uploadImageProfile2(path[2]);
    path[3] == null? null: images[3] = await uploadImageProfile3(path[3]);
    path[4] == null? null: images[4] = await uploadImageProfile4(path[4]);
    path[5] == null? null: images[5] = await uploadImageProfile5(path[5]);
    path[6] == null? null: images[6] = await uploadImageDad(path[6]);
    path[7] == null? null: images[7] = await uploadImageMum(path[7]);



    await postsPuppyKittenRef.doc(postId).get().then((snapshot) {
      createPostInFirestore(
        coverProfile: images[0]!.isEmpty?'None':images[0].toString(),
        profile1: images[1]!.isEmpty?'None':images[1].toString(),
        profile2: images[2]!.isEmpty?'None':images[2].toString(),
        profile3: images[3]!.isEmpty?'None':images[3].toString(),
        profile4: images[4]!.isEmpty?'None':images[4].toString(),
        profile5: images[5]!.isEmpty?'None':images[5].toString(),
        dad: images[6]!.isEmpty?'None':images[6].toString(),
        mum: images[7]!.isEmpty?'None':images[7].toString(),
      );
    });
    for(var i=0;path.length>i;i++){
      if(path[i]!=null){
        await path[i]!.delete();
      }
      path[i] = null;
      postId = Uuid().v4();
    }
    setState(() {
      isLoading = false;
    });

    Navigator.push(context, MaterialPageRoute(builder: (context)=>PP.authScreenWithoutPet(currentUserId: widget.userId,pageIndex: 3)));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      isLoading = true;
      SizerUtil.deviceType == DeviceType.tablet?isTablet = true:isTablet = false;
    });

    checkSellerAccount();
    checkSellerAddress();
    getUserData();
    selectedPattern = 'none';

    setState(() {
      isShowPed = false;
      isShowParent = false;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    topicController.dispose();
    priceController.dispose();
    descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading == true?loading():Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: false,
        backgroundColor: themeColour,
        title: Center(
          child: Text('สร้างรายการขาย',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet?30:20)
          ),
        ),
        actions: [
          selectedType != null
              && selectedBreed != null
              && selectedColour != null
              && selectedGender != null
              && returnBirthDay != null
              && selectedPed == 'Yes'
              && pedType != null
              && uploadParentImg != null
              && fileProCover != null
              && returnReadyToDispatch != null
              && canSubmit == true
              && isBankAccountExist == true
              ?InkWell(
              child: Padding(
                padding: EdgeInsets.only(right: 15,top: isTablet?15:20),
                child: Text('เสร็จสิ้น',style: TextStyle(color: Colors.white,fontSize: isTablet?20:16),)
              ),
              onTap: (){
                if(_formKey.currentState!.validate()) {
                  handleSubmit();
                }
              }
          ):selectedType != null
              && selectedBreed != null
              && selectedColour != null
              && selectedGender != null
              && returnBirthDay != null
              && selectedPed == 'No'
              && uploadParentImg != null
              && fileProCover != null
              && returnReadyToDispatch != null
              && canSubmit == true
              && isBankAccountExist == true
              ?InkWell(
              child: Padding(
                  padding: EdgeInsets.only(right: 15,top: isTablet?15:20),
                  child: Text('เสร็จสิ้น',style: TextStyle(color: Colors.white,fontSize: isTablet?20:16),)
              ),
              onTap: (){
                if(_formKey.currentState!.validate()) {
                  handleSubmit();
                }
              }
          ):Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: InkWell(
              child:Icon(FontAwesomeIcons.solidQuestionCircle,color: Colors.white),
              onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>conditionSeller())),
            ),
          )
        ],
      ),


      body: Form(
        key: _formKey,
        child: InkWell(
          onTap: (){
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: ListView(
            children: [
              Card(
                color: Colors.white,
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(width: 0.001),
                          buildUploadImgProfile(context,profileCoverImg,fileProCover,'cover'),
                          buildUploadImgProfile(context,profile1Img,filePro1,'profile1'),
                          buildUploadImgProfile(context,profile2Img,filePro2,'profile2'),
                          SizedBox(width: 0.001),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(width: 0.001),
                          buildUploadImgProfile(context,profile3Img,filePro3,'profile3'),
                          buildUploadImgProfile(context,profile4Img,filePro4,'profile4'),
                          buildUploadImgProfile(context,profile5Img,filePro5,'profile5'),
                          SizedBox(width: 0.001),
                        ],
                      ),
                    ),
                  ],
                ) ,
              ),
              buildDivider(),
              Card(
                color: Colors.white,
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildTextFormField('ชื่อหัวข้อ','',topicController),
                        buildTextFormFieldNumber('ราคา (บาท)','',priceController),
                      ],
                    )
                ),
              ),
              buildDivider(),
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal:20,vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Text('ข้อมูลทั่วไป',style: TextStyle(fontSize: isTablet?30:20,fontWeight: FontWeight.bold)),
                      ),
                      buildRowField(
                          'ประเภท',
                          selectedType, () async{
                        final result = await Navigator.push(context, MaterialPageRoute(builder: (context)=>typePage()));
                        setState(() {
                          selectedType = result.toString();
                        });
                      }),
                      Visibility(
                        visible: selectedType != null,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: buildRowField('สายพันธุ์:',selectedBreed,()async{
                            final result = await Navigator.push(context, MaterialPageRoute(builder: (context)=>breedPage(selected: selectedType)));
                            setState(() {
                              selectedBreed = result;
                              selectedBreed_dummy = result;
                              selectedColour = null;
                            });
                          }),
                        ),
                      ),
                      Visibility(
                        visible: selectedBreed != null,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: buildRowField('สี',selectedColour,()async{
                            final result = await Navigator.push(context, MaterialPageRoute(builder: (context)=>colourPage(selected: selectedType,selectedbreed: selectedBreed_dummy)));
                            setState(() {
                              selectedColour = result;
                            });
                          }),
                        ),
                      ),
                      Visibility(
                        visible: selectedColour != null,
                        child: selectedType == 'แมว'?Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: buildRowField('แพทเทิร์นของขน',selectedPattern,()async{
                            final result = await Navigator.push(context, MaterialPageRoute(builder: (context)=>catPattern()));
                            setState(() {
                              selectedPattern = result;
                            });
                          }),
                        ):SizedBox(),
                      ),

                      buildRowField('เพศ', selectedGender, ()async{
                        final result = await Navigator.push(context, MaterialPageRoute(builder: (context)=>genderPage()));
                        setState(() {
                          selectedGender = result;
                        });
                      }),
                    ],
                  ),
                ),
              ),
              buildDivider(),
              Card(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Text('วัน/เดือน/ปีเกิด', style: TextStyle(fontSize: isTablet?30:20,fontWeight: FontWeight.bold)),
                      ),
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
                            currentTime: DateTime.now(),
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
                        child: Text('ข้อมูลเพิ่มเติม',style: TextStyle(fontSize: isTablet?30:20,fontWeight: FontWeight.bold)),
                      ),
                      buildRowField('เพ็ดดีกรี', selectedPed== 'Yes'?'มี':selectedPed== 'No'?'ไม่มี':'', ()async{
                        final result1 = await Navigator.push(context, MaterialPageRoute(builder: (context)=>pedigreePage(topic: 'มีใบเพ็ดดีกรีหรือไม่')));
                        setState(() {
                          selectedPed = result1;
                          selectedPed == 'Yes'?isShowPed = true:isShowPed = false;
                        });
                      }),

                      Visibility(
                          visible: isShowPed,
                          child: Padding(
                              padding: const EdgeInsets.only(top:10,bottom: 10,left: 0,right:20),
                              child: buildRowField('ประเภทของใบเพ็ดดีกรี', pedType, ()async{
                                final result = await Navigator.push(context, MaterialPageRoute(builder: (context)=>selectedPage(text: 'ประเภทของใบเพ็ดดีกรี', list: pedTypeList)));
                                setState(() {
                                  pedType = result;
                                });
                              }),
                          )
                      ),

                      uploadParentImg == 'Yes'?SizedBox(height: 20):SizedBox(),
                      buildRowField('มีรูปพ่อ-แม่ของน้องหรือไม่', uploadParentImg == 'Yes'?'มี':uploadParentImg == 'No'?'ไม่มี':'', ()async{
                        final result2 = await Navigator.push(context, MaterialPageRoute(builder: (context)=>pedigreePage(topic: 'มีรูปพ่อ-แม่ของน้องหรือไม่')));
                        setState(() {
                          uploadParentImg = result2;
                          uploadParentImg == 'Yes'?isShowParent = true:isShowParent = false;
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
                                child: Text('กรุณาอัพโหลดรูป พ่อ-แม่ของน้อง',style: TextStyle(fontWeight: FontWeight.bold,fontSize: isTablet?20:16),),
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
                                        buildUploadImgParents(context, dad, fileDad, 'dad'),
                                        Text('รูปพ่อพันธุ์',style: TextStyle(fontSize: isTablet?20:16))
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
                                            buildUploadImgParents(context, mum, fileMum, 'mum'),
                                            Text('รูปแม่พันธุ์',style: TextStyle(fontSize: isTablet?20:16))
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
                            ],
                          ),
                        ),
                        visible: isShowParent,
                      ),
                    ],
                  ),
                ),
              ),
              buildDivider(),
              Card(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Text('วันที่พร้อมส่งมอบ', style: TextStyle(fontSize: isTablet?30:20,fontWeight: FontWeight.bold)),
                      ),

                      buildRowFieldDateTime('วันที่พร้อมส่งมอบ', returnReadyToDispatch, (){
                        DatePicker.showDatePicker(context,
                            showTitleActions: true,
                            minTime: now,
                            maxTime: now.add(Duration(days: 120)),
                            theme: const DatePickerTheme(
                                doneStyle: TextStyle(
                                    color: themeColour
                                )
                            ),
                            onConfirm: (date) {
                              setState(() {
                                returnReadyToDispatch = date;
                              });
                            },
                            currentTime: DateTime.now(),
                            locale: LocaleType.th
                        );
                      }),
                    ],
                  ),
                ),
              ),
              isBankAccountExist == false || toDeliverDetail == true?buildDivider():SizedBox(),
              isBankAccountExist == false?InkWell(
                child: Card(
                  color: Colors.red.shade900,
                  child: Container(
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FontAwesomeIcons.coins,color: Colors.white,size: 20),
                        SizedBox(width: 10),
                        Text('เพิ่มบัญชีรับเงินจากการขาย',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: isTablet?20:16))
                      ],
                    ),
                  ),
                ),
                onTap: ()async{
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context)=> bankAccount(userId: widget.userId,type: 'เพิ่มบัญชีธนาคาร',fromCheckOut: false))
                  ).then((value){
                    checkSellerAccount();
                  });
                },
              ):SizedBox(),
              toDeliverDetail == true?InkWell(
                child: Card(
                  color: Colors.red.shade900,
                  child: Container(
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FontAwesomeIcons.locationArrow,color: Colors.white,size: 20),
                        SizedBox(width: 10),
                        Text('ระบุที่ตั้งฟาร์มและการจัดส่ง',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: isTablet?20:16))
                      ],
                    ),
                  ),
                ),
                onTap: ()async{
                  await Navigator.push(context, MaterialPageRoute(builder: (context)=>deliveryOptionAndStoreAddress(userId: widget.userId,type: 'ที่ตั้งร้านค้าและการจัดส่ง')));
                  checkSellerAddress();
                },
              ):SizedBox(),
              buildDivider(),
              Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text('คำอธิบายเพิ่มเติม',style: TextStyle(fontSize: isTablet?30:20,fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        color: Colors.white,
                        child: TextFormField(
                            controller: descriptionController,
                            maxLines: null,
                            decoration: InputDecoration(
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
                      SizedBox(height: 20)
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

  // METHOD HELPER  ########################################################################

  Column buildTextFormField(String topic, String hintText ,TextEditingController controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(topic,style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold),),
        Container(
          color: Colors.transparent,
          height: 80,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
                hintText: hintText,
                focusedBorder: const UnderlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFD35757),width: 3)
                ),
                labelStyle: TextStyle(color:themeColour)
            ),
            validator: (value){
              if(value!.isEmpty){
                return 'Required';
              }else if(value.length>120)
              {
                return 'โปรดใส่ข้อมูลไม่เกิน 120 ตัวอักษร';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Column buildTextFormFieldNumber(String topic, String hintText ,TextEditingController controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(topic,style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold),),
        Container(
          color: Colors.transparent,
          height: 60,
          child: TextFormField(
            keyboardType: TextInputType.number,
            controller: controller,
            decoration: InputDecoration(
                hintText: hintText,
                focusedBorder: const UnderlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFD35757),width: 3)
                ),
                labelStyle: TextStyle(color:themeColour)
            ),
            validator: (value){
              if(value!.isEmpty){
                return 'กรุณาใส่ราคา';
              }else if(int.parse(value)>150000)
              {
                return 'ราคาสูงสุดที่ตั้งได้คือ 150,000 บาท';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Column buildRowFieldMonth(String topic, String? name,Function() ontap) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(topic,style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold)),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: InkWell(
            child: Container(
                width: MediaQuery.of(context).size.width,
                child: name==null?
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('',style: TextStyle(color: Colors.grey.shade600,fontSize: isTablet?20:16),),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Divider(color: Colors.black,height:2),
                    )
                  ],
                ):Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name == '1'?'มกราคม'
                        :name == '2'?'กุมภาพันธ์'
                        :name == '3'?'มีนาคม'
                        :name == '4'?'เมษายน'
                        :name == '5'?'พฤษภาคม'
                        :name == '6'?'มิถุนายน'
                        :name == '7'?'กรกฎาคม'
                        :name == '8'?'สิงหาคม'
                        :name == '9'?'กันยายน'
                        :name == '10'?'ตุลาคม'
                        :name == '11'?'พฤศจิกายน'
                        :name == '12'?'ธันวาคม'
                        :name.toString()
                        ,style: TextStyle(color: Colors.black,fontSize: isTablet?20:16)
                    ),
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
          padding: const EdgeInsets.only(top: 10),
          child: InkWell(
            child: Container(
                width: MediaQuery.of(context).size.width,
                child: name==null?
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('',style: TextStyle(color: Colors.grey.shade600,fontSize: isTablet?20:16),),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Divider(color: Colors.black,height:2),
                    )
                  ],
                ):Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,style: TextStyle(color: Colors.black,fontSize: isTablet?20:16),),
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
      ],
    );
  }

  buildUploadImgParents(BuildContext context,String? img, File? file, String category){
    return Container(
        child: file == null?
        InkWell(
          child: Container(
            height: isTablet?380:143,
            width: MediaQuery.of(context).size.width * 0.3,
            decoration: BoxDecoration(
                border:  Border.all(color: Colors.black)
            ),
            child: AspectRatio(
              aspectRatio: 8 / 10.5,
              child: Container(
                height: isTablet?380:143,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.fitHeight,
                      image:AssetImage('assets/PetCover.png')
                  ),
                ),
              ),
            ),
          ),
          onTap: ()async{
            if(img == 'dad'){
              fileDad = await Navigator.push(context, MaterialPageRoute(builder: (context)=>handleGettingImage(file: file)));
            }else if(img == 'mum'){
              fileMum = await Navigator.push(context, MaterialPageRoute(builder: (context)=>handleGettingImage(file: file)));
            }
            setState(() {

            });
          },
        ):
        Container(
          width: MediaQuery.of(context).size.width * 0.30,
          child: Column(
            children: [
              Stack(
                children: [
                  Positioned(
                    child: AspectRatio(
                      aspectRatio: 8 / 10.5,
                      child: Container(
                        height: isTablet?380:143,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(file),
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
                            if(file == fileDad){
                              fileDad = clearImage(file);

                            }else if(file == fileMum){
                              fileMum = clearImage(file);
                            }
                          });
                        },
                      )
                  )
                ],
              ),
            ],
          ),
        )
    );
  }

  buildUploadImgProfile(BuildContext context,String? img, File? file, String category){
    return Container(
        child: img == category && file == null?
        InkWell(
          child: Container(
            height: isTablet?380:143,
            width: MediaQuery.of(context).size.width * 0.3,
            decoration: BoxDecoration(
                border:  Border.all(color: Colors.black)
            ),
            child: AspectRatio(
              aspectRatio: 8 / 10.5,
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: isTablet?380:143,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.fitHeight,
                            image:AssetImage('assets/PetCover.png')
                        ),
                      ),
                    ),
                  ),
                  category == 'cover'?Positioned(
                      bottom: 0,
                      child: Container(
                        color: themeColour,
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: Center(child: Text('หน้าปก',style: TextStyle(color: Colors.white,fontSize: isTablet?20:16))),
                      )
                  ):SizedBox()
                ],
              ),
            ),
          ),
          onTap: ()async{
            if(img == 'cover'){
              fileProCover = await Navigator.push(context, MaterialPageRoute(builder: (context)=>handleGettingImage(file: file)));

            }else if(img == 'profile1'){
              filePro1 = await Navigator.push(context, MaterialPageRoute(builder: (context)=>handleGettingImage(file: file)));

            }else if(img == 'profile2'){
              filePro2 = await Navigator.push(context, MaterialPageRoute(builder: (context)=>handleGettingImage(file: file)));

            }else if(img == 'profile3'){
              filePro3 = await Navigator.push(context, MaterialPageRoute(builder: (context)=>handleGettingImage(file: file)));

            }else if(img == 'profile4'){
              filePro4 = await Navigator.push(context, MaterialPageRoute(builder: (context)=>handleGettingImage(file: file)));

            }else if(img == 'profile5'){
              filePro5 = await Navigator.push(context, MaterialPageRoute(builder: (context)=>handleGettingImage(file: file)));
            }

            setState(() {

            });
          },
        ):
        Container(
          width: MediaQuery.of(context).size.width * 0.30,
          child: Column(
            children: [
              Stack(
                children: [
                  Positioned(
                    child: AspectRatio(
                      aspectRatio: 8 / 10.5,
                      child: Container(
                        height: isTablet?380:143,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.fitHeight,
                            image: FileImage(file!),
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
                            if(file == fileProCover){
                              fileProCover = clearImage(file);

                            }else if(file == filePro1){
                              filePro1 = clearImage(file);

                            }else if(file == filePro2){
                              filePro2 = clearImage(file);

                            }else if(file == filePro3){
                              filePro3 = clearImage(file);

                            }else if(file == filePro4){
                              filePro4 = clearImage(file);

                            }else if(file == filePro5){
                              filePro5 = clearImage(file);
                            }
                          });
                        },
                      )
                  ),Positioned(
                      bottom: 0,
                      left: 0,
                      child: category == 'cover'?Container(
                          color: themeColour,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Text('หน้าปก',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: isTablet?20:16)),
                          )
                      ): Text('')
                  ),
                ],
              ),
            ],
          ),
        )
    );
  }

}

// PAGE SELECTION ########################################################################

class typePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithBackArrow('ประเภท',false),
      body: ListView.builder(
        itemCount: typeList.length,
        itemBuilder: (context,i){
          return InkWell(
            child: Card(
              child: ListTile(
                title: Text(typeList[i].toString(),style: TextStyle(fontSize: isTablet?20:16)),
              ),
            ),
            onTap: ()=> Navigator.pop(context,typeList[i]),
          );
        },
      ),
    );
  }
}

class breedPage extends StatelessWidget {
  final String? selected;
  breedPage({this.selected});

  @override
  Widget build(BuildContext context) {
    List<String> breedList =[];
    selected == 'สุนัข'? breedList= dogBreedMapping.keys.toList():breedList= catBreedMapping.keys.toList();

    return Scaffold(
      appBar: appBarWithBackArrow('สายพันธุ์',isTablet),
      body: ListView.builder(
        itemCount: breedList.length,
        itemBuilder: (context,i){
          return InkWell(
            child: Card(
              child: ListTile(
                title: Text(breedList[i].toString(),style: TextStyle(fontSize: isTablet?20:16)),
              ),
            ),
            onTap: ()=> Navigator.pop(context,breedList[i]),
          );
        },
      ),
    );
  }
}

class colourPage extends StatelessWidget {
  late final String? selectedbreed, selected;
  colourPage({this.selectedbreed,this.selected});


  @override
  Widget build(BuildContext context) {
    var colourList = selected == 'สุนัข'?dogBreedMapping[selectedbreed]:catBreedMapping[selectedbreed];

    return Scaffold(
      appBar: appBarWithBackArrow('สี',isTablet),
      body: ListView.builder(
        itemCount: colourList!.length,
        itemBuilder: (context,i){
          return InkWell(
            child: Card(
              child: ListTile(
                title: Text(colourList[i],style: TextStyle(fontSize: isTablet?20:16)),
              ),
            ),
            onTap: ()=> Navigator.pop(context,colourList[i]),
          );
        },
      ),
    );
  }
}

class genderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithBackArrow('เพศ',isTablet),
      body: ListView.builder(
        itemCount: gendersList.length,
        itemBuilder: (context,i){
          return InkWell(
            child: Card(
              child: ListTile(
                title: Text(gendersList[i],style: TextStyle(fontSize: isTablet?20:16)),
              ),
            ),
            onTap: ()=> Navigator.pop(context,gendersList[i]),
          );
        },
      ),
    );
  }
}

class catPattern extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithOutBackArrow('แพทเทิร์นของขน',isTablet),
      body: ListView.builder(
        itemCount: catPatternList.length,
        itemBuilder: (context,i){
          return InkWell(
            child: Card(
              child: ListTile(
                title: Text(catPatternList[i],style: TextStyle(fontSize: isTablet?20:16)),
              ),
            ),
            onTap: ()=> Navigator.pop(context,catPatternList[i]),
          );
        },
      ),
    );
  }
}

class pedigreePage extends StatelessWidget {
  String topic;
  pedigreePage({required this.topic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithOutBackArrow(topic,isTablet),
      body: ListView.builder(
        itemCount: pedigreeList.length,
        itemBuilder: (context,i){
          return InkWell(
            child: Card(
              child: ListTile(
                title: Text(pedigreeList[i]== 'Yes'?'มี':'ไม่มี',style: TextStyle(fontSize: isTablet?20:16)),
              ),
            ),
            onTap: ()=> Navigator.pop(context,pedigreeList[i]),
          );
        },
      ),
    );
  }
}

class selectedPageMonth extends StatelessWidget {
  String text;
  List list;
  selectedPageMonth({required this.text,required this.list});

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
                title: Text(list[i] == 1?'มกราคม'
                    :list[i] == 2?'กุมภาพันธ์'
                    :list[i] == 3?'มีนาคม'
                    :list[i] == 4?'เมษายน'
                    :list[i] == 5?'พฤษภาคม'
                    :list[i] == 6?'มิถุนายน'
                    :list[i] == 7?'กรกฎาคม'
                    :list[i] == 8?'สิงหาคม'
                    :list[i] == 9?'กันยายน'
                    :list[i] == 10?'ตุลาคม'
                    :list[i] == 11?'พฤศจิกายน'
                    :list[i] == 12?'ธันวาคม'
                    :list[i].toString(),style: TextStyle(fontSize: isTablet?20:16)),
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
                title: Text(list[i].toString(),style: TextStyle(fontSize: isTablet?20:16)
                ),
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