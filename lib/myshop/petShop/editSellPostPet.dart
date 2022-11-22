import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multipawmain/database/breedDatabase.dart';
import 'package:multipawmain/authCheck.dart';
import 'dart:io';
import 'package:image/image.dart' as Im;
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:sizer/sizer.dart';

import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/support/handleGettingImage.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../authScreenWithoutPet.dart' as PP;

final DateTime timestamp = DateTime.now();
bool isTablet = false;

class editSellPost extends StatefulWidget {
  final String postId;
  final String userId;
  editSellPost({required this.postId, required this.userId});

  @override
  _editSellPostState createState() => _editSellPostState();
}

class _editSellPostState extends State<editSellPost> {
  final _formKey = GlobalKey<FormState>();
  List<dataList> imgList = [];

  TextEditingController topicController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  String? selectedType,selectedBreed,selectedColour,selectedPattern,selectedGender,selectedPed,uploadParentImg;
  int? birthday,birthMonth,birthYear,dispatchday,dispatchMonth,dispatchYear;
  String? selectedBreed_dummy,selectedColour_dummy,selected_age_dummy,selectedBreedInitially;
  String? new_profileCoverImg,new_profile1Img,new_profile2Img,new_profile3Img,new_profile4Img,new_profile5Img,new_dad,new_mum;
  String? dadImg,mumImg,profileCoverImg,profile1Img,profile2Img,profile3Img,profile4Img,profile5Img,dad,mum,pedType;
  File? file,fileProCover,filePro1,filePro2,filePro3,filePro4,filePro5,fileDad,fileMum;
  String a = '';
  DateTime? returnBirthDay,returnReadyToDispatch;

  late bool isShowPed,isShowParent;
  bool isLoading = false;
  String? postOwnerName,coverProfile,postOwnerprofileUrl,city,location1,location2;

  String postId = Uuid().v4();
  dynamic picker = ImagePicker();


  handleTakePhoto(File? sub_file) async{

    final XFile pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        maxHeight: 500.0,
        maxWidth: 200.0
    );
    if (file != null) {
      setState(() {
        file = File(pickedFile.path);
      });
    }
    return file;
  }

  handleChooseFromGallery(File? file) async{
    // getImage now returns a PickedFile instead of a File (form dart:io)
    final XFile pickedFile = await picker.pickImage(source: ImageSource.gallery);
    // 3. Check if an image has been picked or take with the camera.
    if (pickedFile != null) {
      setState(() {
        file = File(pickedFile.path);
      });
    }
    return file;
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
    final compressedImageFile = File('$path/img_$widget.postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile!,quality:35));
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImageDadImg(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('postDadImg_$widget.postId.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }
    return a;
  }

  Future<String> uploadImageMumImg(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('postMumImg_$widget.postId.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }
    return a;
  }

  Future<String> uploadImageCover(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('postProfileCover_$widget.postId.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }
    return a;
  }

  Future<String> uploadImageProfile1(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('postProfile1_$widget.postId.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }
    return a;
  }

  Future<String> uploadImageProfile2(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('postProfile2_$widget.postId.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }
    return a;
  }

  Future<String> uploadImageProfile3(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('postProfile3_$widget.postId.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }
    return a;
  }

  Future<String> uploadImageProfile4(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('postProfile4_$widget.postId.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }
    return a;
  }

  Future<String> uploadImageProfile5(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('postProfile5_$widget.postId.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }
    return a;
  }

  Future<String> uploadImageDad(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('postDad_$widget.postId.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }
    return a;
  }

  Future<String> uploadImageMum(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('postMum_$widget.postId.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }
    return a;
  }

  handleSubmit() async{

    setState((){
      isLoading = true;
    });


    for(var i=0;imgList.length>i;i++){

      if(imgList[i].name == 'cover'){
        imgList[i].info = await compressImage(imgList[i].info);
      }else if(imgList[i].name == 'profile1'){
        imgList[i].info  = await compressImage(imgList[i].info);
      }else if(imgList[i].name == 'profile2'){
        imgList[i].info  = await compressImage(imgList[i].info);
      }else if(imgList[i].name == 'profile3'){
        imgList[i].info = await compressImage(imgList[i].info);
      }else if(imgList[i].name == 'profile4'){
        imgList[i].info = await compressImage(imgList[i].info);
      }else if(imgList[i].name == 'profile5'){
        imgList[i].info = await compressImage(imgList[i].info);
      }else if(imgList[i].name == 'dad'){
        imgList[i].info = await compressImage(imgList[i].info);
      }else if(imgList[i].name == 'mum'){
        imgList[i].info = await compressImage(imgList[i].info);
      }


      if(imgList[i].name == 'cover'){
        new_profileCoverImg =await uploadImageCover(fileProCover);

      }else if(imgList[i].name == 'profile1'){
        new_profile1Img =await uploadImageProfile1(filePro1);

      }else if(imgList[i].name == 'profile2'){
        new_profile2Img =await uploadImageProfile2(filePro2);

      }else if(imgList[i].name == 'profile3'){
        new_profile3Img =await uploadImageProfile3(filePro3);

      }else if(imgList[i].name == 'profile4'){
        new_profile4Img =await uploadImageProfile4(filePro4);

      }else if(imgList[i].name == 'profile5'){
        new_profile5Img =await uploadImageProfile5(filePro5);

      }else if(imgList[i].name == 'dad'){
        new_dad =await uploadImageDad(fileDad);

      }else if(imgList[i].name == 'mum'){
        new_mum =await uploadImageMum(fileMum);
      }
    }

    await postsPuppyKittenRef.doc(widget.postId).update({
      'topicName': topicController.text,
      'type': selectedType,
      'breed': selectedBreed,
      'colour': selectedColour,
      'pattern' : selectedPattern,
      'gender': selectedGender,
      'birthDay': returnBirthDay!.day,
      'birthMonth': returnBirthDay!.month,
      'birthYear': returnBirthDay!.year,
      'pedigree': selectedPed,
      'pedType': pedType,
      'parentImg': uploadParentImg,
      'description': descriptionController.text,
      'price': int.parse(priceController.text),
      'dispatchDate' : returnReadyToDispatch!.day,
      'dispatchMonth': returnReadyToDispatch!.month,
      'dispatchYear': returnReadyToDispatch!.year,

      'timestamp': timestamp.millisecondsSinceEpoch,
    });

    await postsPuppyKittenRef.doc(widget.postId).update({
      'coverProfile':fileProCover == null?profileCoverImg:new_profileCoverImg,
      'profile1': filePro1 == null?profile1Img:new_profile1Img,
      'profile2': filePro2 == null?profile2Img:new_profile2Img,
      'profile3': filePro3 == null?profile3Img:new_profile3Img,
      'profile4': filePro4 == null?profile4Img:new_profile4Img,
      'profile5': filePro5 == null?profile5Img:new_profile5Img,
      'dadImg': fileDad == null? dad:new_dad,
      'mumImg': fileMum == null? mum: new_mum
    });

    await postsPuppyKittenIndexRef.doc(selectedBreed).collection(selectedBreed.toString()).doc(widget.postId).set(
        {
          'id':widget.userId,
          'postid':widget.postId,
          'timestamp': timestamp.millisecondsSinceEpoch
        });

    List<File?> fileInfo = [fileProCover,filePro1,filePro2,filePro3,filePro4,filePro5,fileDad,fileMum];

    for(var i = 0; i<fileInfo.length;i++){
      if(fileInfo[i]!=null){
        try{
          await fileInfo[i]!.delete();
        }catch(e){
          print(e);
        }
      }
    }
      setState(() {
      for(var i=0;imgList.length>i;i++){
        imgList[i].info = null;
        postId = Uuid().v4();
      }
      isLoading = false;
    });

    Navigator.push(context, MaterialPageRoute(builder: (context)=>PP.authScreenWithoutPet(currentUserId: widget.userId,pageIndex: 3)));
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
                    Text(formatter.format(name),style: TextStyle(color: Colors.black,fontSize: 17),),
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

  Future<dynamic> getUserData() async{

    setState(() {
      isLoading = true;
    });

    await postsPuppyKittenRef.doc(widget.postId).get().then((snapshot) => {

      topicController.text = snapshot.data()!['topicName'],
      priceController.text = snapshot.data()!['price'].toString(),
      selectedType = snapshot.data()!['type'],
      selectedBreed = snapshot.data()!['breed'],
      selectedBreed_dummy = snapshot.data()!['breed'],
      selectedBreedInitially = snapshot.data()!['breed'],
      selectedColour = snapshot.data()!['colour'],
      selectedPattern = snapshot.data()!['pattern'],
      selectedGender = snapshot.data()!['gender'],
      birthday = snapshot.data()!['birthDay'],
      birthMonth = snapshot.data()!['birthMonth'],
      birthYear = snapshot.data()!['birthYear'],
      selectedPed = snapshot.data()!['pedigree'],
      pedType = snapshot.data()!['pedType'],
      uploadParentImg = snapshot.data()!['parentImg'],
      descriptionController.text = snapshot.data()!['description'],
      profileCoverImg = snapshot.data()!['coverProfile'],
      profile1Img = snapshot.data()!['profile1'],
      profile2Img = snapshot.data()!['profile2'],
      profile3Img = snapshot.data()!['profile3'],
      profile4Img = snapshot.data()!['profile4'],
      profile5Img = snapshot.data()!['profile5'],
      dad = snapshot.data()!['dadImg'],
      mum = snapshot.data()!['mumImg'],
      dispatchday = snapshot.data()!['dispatchDate'],
      dispatchMonth = snapshot.data()!['dispatchMonth'],
      dispatchYear = snapshot.data()!['dispatchYear']
    });
    setState(() {
      selectedPed == 'Yes'?isShowPed = true: isShowPed = false;
      uploadParentImg == 'Yes'?isShowParent = true: isShowParent = false;
      returnBirthDay = DateTime(birthYear!,birthMonth!,birthday!);
      returnReadyToDispatch = DateTime(dispatchYear!,dispatchMonth!,dispatchday!);

      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      SizerUtil.deviceType == DeviceType.tablet?isTablet = true:isTablet = false;
    });
    getUserData();
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

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: themeColour,
          leading: InkWell(child: Icon(Icons.arrow_back_ios,color: Colors.white),onTap:(){
            Navigator.pop(context);
          }),
          title: Text('',),
        actions: [
          Row(
            children: [
              selectedBreed == null || selectedColour == null || selectedType == 'แมว' && selectedPattern == null || selectedPed == 'Yes' && pedType == null? SizedBox():Center(
                child: InkWell(
                    child: Text('เสร็จสิ้น',style: TextStyle(color: Colors.white,fontSize: isTablet?20:16)),
                    onTap: (){
                      if(_formKey.currentState!.validate()) {
                        if(selectedBreed != selectedBreedInitially){
                          postsPuppyKittenIndexRef.doc(selectedBreedInitially).collection(selectedBreedInitially.toString()).where('postid',isEqualTo: widget.postId).get().then((snapshot){
                            snapshot.docs.forEach((snap) {
                              postsPuppyKittenIndexRef.doc(selectedBreedInitially).collection(selectedBreedInitially.toString()).doc(snap.id).delete();
                            });
                          });
                        }
                        handleSubmit();
                      }
                    }),
              ),
              SizedBox(width: 25)
            ],
          )
        ],
      ),

      body: isLoading == true?loading():Form(
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
                    SizedBox(height: 20),
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
              Visibility(child: loading(),visible: isLoading),
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
                          selectedBreed = null;
                          selectedColour = null;
                          selectedPattern = null;
                        });
                      }),
                      buildRowField('สายพันธุ์:',selectedBreed,()async{
                        final result = await Navigator.push(context, MaterialPageRoute(builder: (context)=>breedPage(selected: selectedType)));
                        setState(() {
                          selectedBreed = result;
                          selectedBreed_dummy = result;
                          selectedColour = null;
                        });
                      }),
                      buildRowField('สี',selectedColour,()async{
                        final result = await Navigator.push(context, MaterialPageRoute(builder: (context)=>colourPage(selected: selectedType,selectedbreed: selectedBreed_dummy)));
                        setState(() {
                          selectedColour = result;
                        });
                      }),

                      selectedType == 'แมว'? buildRowField('แพทเทิร์นของขน',selectedPattern,()async{
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
                        child: Text('ข้อมูลเพิ่มเติม',style: TextStyle(fontSize: isTablet?30:20,fontWeight: FontWeight.bold)),
                      ),
                      buildRowField('มีใบเพ็ดดีกรีหรือไม่', selectedPed == 'Yes'?'มี':'ไม่มี', ()async{
                        final result1 = await Navigator.push(context, MaterialPageRoute(builder: (context)=>pedigreePage(topic: 'มีใบเพ็ดดีกรีหรือไม่')));
                        setState(() {
                          selectedPed = result1;
                          selectedPed == 'Yes'?isShowPed = true:isShowPed = false;
                          selectedPed == 'No'?pedType = null:null;
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

                      uploadParentImg == 'Yes'?SizedBox(height: 5):SizedBox(),
                      buildRowField('มีรูปพ่อ-แม่ของน้องหรือไม่', uploadParentImg == 'Yes'?'มี':'ไม่มี', ()async{
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
          height: 60,
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
                    Text(name.toString()
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


  buildUploadImgParents(BuildContext context,String? img, File? file, String category){
    return Container(
        child: img == category && file == null?
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
            if(img == 'dad'){
              fileDad = await Navigator.push(context, MaterialPageRoute(builder: (context)=>handleGettingImage(file: file)));
              imgList.add(dataList(name: 'dad', info: fileDad));
              dad = 'dad';

            }else if(img == 'mum'){
              fileMum = await Navigator.push(context, MaterialPageRoute(builder: (context)=>handleGettingImage(file: file)));
              imgList.add(dataList(name: 'mum', info: fileMum));
              mum = 'mum';
            }
            setState(() {});
          },
        ):img != category && file == null?
        InkWell(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.30,
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
                          image: NetworkImage(img.toString()),
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
                          if(img == dad){
                            dad = 'dad';
                            FirebaseStorage.instance.refFromURL(img.toString()).delete();
                            fileDad = clearImage(file);

                          }else if(img == mum){
                            mum = 'mum';
                            FirebaseStorage.instance.refFromURL(img.toString()).delete();
                            fileMum = clearImage(file);
                          }
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
          child: Column(
            children: [
              Stack(
                children: [
                  Positioned(
                    child: AspectRatio(
                      aspectRatio: 8 / 10.5,
                      child: Container(
                        height: isTablet?380:110,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
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
                  Container(
                    height: isTablet?380:143,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.fitHeight,
                          image:AssetImage('assets/PetCover.png')
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
              imgList.add(dataList(name: 'cover', info: fileProCover));
              profileCoverImg = 'cover';

            }else if(img == 'profile1'){
              filePro1 = await Navigator.push(context, MaterialPageRoute(builder: (context)=>handleGettingImage(file: file)));
              imgList.add(dataList(name: 'profile1', info: filePro1));
              profile1Img = 'profile1';

            }else if(img == 'profile2'){
              filePro2 = await Navigator.push(context, MaterialPageRoute(builder: (context)=>handleGettingImage(file: file)));
              imgList.add(dataList(name: 'profile2', info: filePro2));
              profile2Img = 'profile2';

            }else if(img == 'profile3'){
              filePro3 = await Navigator.push(context, MaterialPageRoute(builder: (context)=>handleGettingImage(file: file)));
              imgList.add(dataList(name: 'profile3', info: filePro3));
              profile3Img = 'profile3';

            }else if(img == 'profile4'){
              filePro4 = await Navigator.push(context, MaterialPageRoute(builder: (context)=>handleGettingImage(file: file)));
              imgList.add(dataList(name: 'profile4', info: filePro4));
              profile4Img = 'profile4';

            }else if(img == 'profile5'){
              filePro5 = await Navigator.push(context, MaterialPageRoute(builder: (context)=>handleGettingImage(file: file)));
              imgList.add(dataList(name: 'profile5', info: filePro5));
              profile5Img = 'profile5';
            }else if(img == 'dad'){
              fileDad = await Navigator.push(context, MaterialPageRoute(builder: (context)=>handleGettingImage(file: file)));
              imgList.add(dataList(name: 'dad', info: fileDad));
              dad = 'dad';

            }else if(img == 'mum'){
              fileMum = await Navigator.push(context, MaterialPageRoute(builder: (context)=>handleGettingImage(file: file)));
              imgList.add(dataList(name: 'mum', info: fileMum));
              mum = 'mum';
            }

            setState(() {

            });
          },
        ):img != category && file == null?
        InkWell(
          child: Container(
            height: isTablet?380:143,
            width: MediaQuery.of(context).size.width * 0.3,
            child: Stack(
              children: [
                Positioned(
                  child: AspectRatio(
                    aspectRatio: 8 / 10.5,
                    child: Container(
                      height: isTablet?380:143,
                      width: MediaQuery.of(context).size.width * 0.3,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(img.toString()),
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
                          if(img == profileCoverImg){
                            profileCoverImg = 'cover';
                            FirebaseStorage.instance.refFromURL(img.toString()).delete();
                            fileProCover = clearImage(file);

                          }else if(img == profile1Img){
                            profile1Img = 'profile1';
                            FirebaseStorage.instance.refFromURL(img.toString()).delete();
                            filePro1 = clearImage(file);

                          }else if(img == profile2Img){
                            profile2Img = 'profile2';
                            FirebaseStorage.instance.refFromURL(img.toString()).delete();
                            filePro2 = clearImage(file);

                          }else if(img == profile3Img){
                            profile3Img = 'profile3';
                            FirebaseStorage.instance.refFromURL(img.toString()).delete();
                            filePro3 = clearImage(file);

                          }else if(img == profile4Img){
                            profile4Img = 'profile4';
                            FirebaseStorage.instance.refFromURL(img.toString()).delete();
                            filePro4 = clearImage(file);

                          }else if(img == profile5Img){
                            profile5Img = 'profile5';
                            FirebaseStorage.instance.refFromURL(img.toString()).delete();
                            filePro5 = clearImage(file);

                          } else if(img == dad){
                            dad = 'dad';
                            FirebaseStorage.instance.refFromURL(img.toString()).delete();
                            fileDad = clearImage(file);

                          }else if(img == mum){
                            mum = 'mum';
                            FirebaseStorage.instance.refFromURL(img.toString()).delete();
                            fileMum = clearImage(file);

                          }
                        });
                      },
                    )
                ),category == 'cover'?Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                        alignment: Alignment.center,
                        color: themeColour,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Text(' หน้าปก ',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: isTablet?20:16)),
                        )
                    )
                ):Text(''),
              ],
            ),
          ),
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

                            }else if(file == fileDad){
                              dad = clearImage(file);

                            }else if(file == fileMum){
                              fileMum = clearImage(file);

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
      appBar: appBarWithOutBackArrow('ประเภท',isTablet),
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
      appBar: appBarWithOutBackArrow('สายพันธุ์',isTablet),
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
      appBar: appBarWithOutBackArrow('สี',isTablet),
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
      appBar: appBarWithOutBackArrow('เพศ',isTablet),
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
                title: Text(pedigreeList[i] == 'Yes'?'มี':'ไม่มี',style: TextStyle(fontSize: isTablet?20:16)),
              ),
            ),
            onTap: ()=> Navigator.pop(context,pedigreeList[i]),
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

class dataList{
  final String name;
  File? info;

  dataList({required this.name,required this.info});
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
                    :list[i].toString(),style: TextStyle(fontSize: isTablet?20:16)
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