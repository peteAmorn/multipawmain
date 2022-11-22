import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multipawmain/support/constants.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:multipawmain/support/handleGettingImage.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:sizer/sizer.dart';
import 'authCheck.dart';

class guaranteeClaim extends StatefulWidget {
  final String userId,ticket_postId, storeName, imgurl,brand,topic;
  final int price, total;
  guaranteeClaim({
    required this.userId,
    required this.ticket_postId,
    required this.storeName,
    required this.imgurl,
    required this.brand,
    required this.topic,
    required this.price,
    required this.total
  });

  @override
  _guaranteeClaimState createState() => _guaranteeClaimState();
}

class _guaranteeClaimState extends State<guaranteeClaim> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController symptomController = TextEditingController();
  var f = new NumberFormat("#,###", "en_US");
  File? vetDescriptionFile,guaranteeClaimedFile01,guaranteeClaimedFile02;
  String vetDescriptionImg = 'vetDescription';
  String guaranteeClaimedImg01 = 'evidence01';
  String guaranteeClaimedImg02 = 'evidence02';
  bool isLoading = false;
  bool isTablet = false;
  DateTime now = DateTime.now();
  String a = '';

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
    final compressedImageFile = File('$path/claim_${widget.ticket_postId}.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile!,quality:35));
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadVetDescription(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('vetDescription_${widget.ticket_postId}.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }
    return a;
  }

  Future<String> evidenceImg01(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('guaranteeClaimed01_${widget.ticket_postId}.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }
    return a;
  }

  Future<String> evidenceImg02(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('guaranteeClaimed02_${widget.ticket_postId}.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }
    return a;
  }

  createPostInFirestore
      ({
    final vetCertificate,
    final guaranteeClaimed01,
    final guaranteeClaimed02,
  }){
    buyerOnGuaranteeRef.doc(widget.ticket_postId).update({
      'vetCertificate' : vetCertificate,
      'evident01': guaranteeClaimed01,
      'evident02': guaranteeClaimed02,
      'symptom': symptomController.text,
      'status': 'กำลังตรวจสอบ',
      'Timestamp_guarantee_ticket_end_time': now.add(Duration(days: 30)).millisecondsSinceEpoch,
      'Timestamp_guarantee_claimed_time': now
    });
  }

  handleSubmit() async{
    List<String?> images = ['vetDescription','guaranteeClaimed01','guaranteeClaimed02'];

    List<File?> path = [vetDescriptionFile,guaranteeClaimedFile01,guaranteeClaimedFile02];

    setState(() {
      isLoading = true;
    });

    for(var i=0;path.length>i;i++) {
      path[i] == null ? null : await compressImage(path[i]);
    }

    path[0] == null? null: images[0] = await uploadVetDescription(path[0]);
    path[1] == null? null: images[1] = await evidenceImg01(path[1]);
    path[2] == null? null: images[2] = await evidenceImg02(path[2]);


    await postsPuppyKittenRef.doc(widget.ticket_postId).get().then((snapshot) {
      createPostInFirestore(
        vetCertificate: images[0]!.isEmpty?'None':images[0].toString(),
        guaranteeClaimed01: images[1]!.isEmpty?'None':images[1].toString(),
        guaranteeClaimed02: images[2]!.isEmpty?'None':images[2].toString(),
      );
    });

    paymentIndexRef.doc(widget.ticket_postId).update({
      'status': 'claimOnProgress'
    });

    for(var i = 0; i<path.length;i++){
      if(path[i]!=null){
        await path[i]!.delete();
      }
    }

    setState(() {
      for(var i=0;path.length>i;i++){
        path[i] = null;
      }
      isLoading = false;
    });
    Navigator.pop(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      SizerUtil.deviceType == DeviceType.tablet?isTablet = true:isTablet = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: themeColour,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios),onPressed: ()=>Navigator.pop(context)),
        title: Text('เคลมสินค้า',style: TextStyle(color: Colors.white,fontSize: isTablet?20:16)),
        actions: [
          vetDescriptionFile == null?SizedBox():Center(
            child: InkWell(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text('เสร็จสิ้น',style: TextStyle(fontSize: isTablet?20:16),),
              ),
              onTap: (){
                if(_formKey.currentState!.validate()) {
                  handleSubmit();
                }
              },
            ),
          )
        ],
      ),
      body: isLoading == true? loading():Form(
        key: _formKey,
        child: InkWell(
          onTap: (){
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: ListView(
            children: [
              upperSection(context),
              Padding(padding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),child: Divider(color: themeColour)),
              Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                    padding: EdgeInsets.only(left: 10,right: 10,top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('   กรุณาอัพโหลดรูปภาพเพื่อเป็นหลักฐาน',style: TextStyle(fontWeight: FontWeight.bold,fontSize: isTablet?20:16)),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(),
                          buildUploadImgProfile(context, vetDescriptionImg, vetDescriptionFile, 'vetDescription'),
                          buildUploadImgProfile(context, guaranteeClaimedImg01, guaranteeClaimedFile01, 'evidence01'),
                          buildUploadImgProfile(context, guaranteeClaimedImg02, guaranteeClaimedFile02, 'evidence02'),
                          SizedBox(),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text('* กรณีปัญหาเกี่ยวกับสุขภาพ จำเป็นต้องมีใบรับรองที่ออกโดยสัตวแพทย์ พร้อมตราคลินิกและลายเซ็นแพทย์',style: TextStyle(color: themeColour,fontSize: isTablet?20:16),maxLines: 4),
                      SizedBox(height: 10)
                    ],
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),child: Divider(color: themeColour)),
              Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ชี้แจงเพิ่มเติม',style: TextStyle(fontWeight: FontWeight.bold,fontSize: isTablet?20:16)),
                    SizedBox(height: 5),
                    buildTextFormField('กรุณาชี้แจงเพิ่มเติม หากเกี่ยวกับสุขภาพกรุณาระบุชื่อน้อง(ที่ลงทะเบียนกับคลินิก) และอธิบายอาการ รวมถึงวันที่เริ่มป่วยเป็นต้น',symptomController),
                  ],
                ),
              )
            ],
          ),
        ),
      )
    );
  }

  TextFormField buildTextFormField(String hintText ,TextEditingController controller) {
    return TextFormField(
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      minLines: 1,
      maxLines: null,
      controller: controller,
      decoration: InputDecoration(
          hintText: hintText,
          hintMaxLines: 4,
          hintStyle: TextStyle(fontSize: isTablet?18: 14),
          focusedBorder: const UnderlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFD35757),width: 3)
          ),
          labelStyle: TextStyle(color:themeColour)
      ),
      validator: (value){
        if(value!.isEmpty){
          return 'โปรดใส่ข้อมูล';
        }else if(value.length>200)
        {
          return 'โปรดใส่ข้อมูลไม่เกิน 200 ตัวอักษร';
        }
        return null;
      },
    );
  }

  Container upperSection(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color:Colors.grey.shade300),
            ),
            color: Colors.white
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Row(
                      children: [
                        Icon(FontAwesomeIcons.store,size: 20,color: Colors.black),
                        SizedBox(width: 15),
                        Text(widget.storeName,style: TextStyle(fontSize: isTablet?20:16))
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    flex: 3,
                    child: Image.network(widget.imgurl,height: 100)
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 8,
                  child: Container(
                    height: 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.topic,style: topicStyle,maxLines: 2),
                        Text(widget.brand,style: TextStyle(color: Colors.grey.shade800,fontSize: isTablet?20:16)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('฿ ${f.format(widget.price)}',style: TextStyle(fontSize: isTablet?20:16)),
                              ],
                            ),
                            Text('')
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('ยอดรวมสินค้า :',style: TextStyle(fontSize: isTablet?20:16)),
                Text('฿ ${f.format(widget.total)}',style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold,color: themeColour))
              ],
            ),
          ],
        )
    );
  }

  buildUploadImgProfile(BuildContext context,String? img, File? file, String category){
    return Column(
      children: [
        Container(
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
                  child: Container(
                    height: isTablet?380:143,
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
                if(img == 'vetDescription'){
                  vetDescriptionFile = await Navigator.push(context, MaterialPageRoute(builder: (context)=>handleGettingImage(file: file)));

                }else if(img == 'evidence01'){
                  guaranteeClaimedFile01 = await Navigator.push(context, MaterialPageRoute(builder: (context)=>handleGettingImage(file: file)));

                }else if(img == 'evidence02'){
                  guaranteeClaimedFile02 = await Navigator.push(context, MaterialPageRoute(builder: (context)=>handleGettingImage(file: file)));
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
                                if(file == vetDescriptionFile){
                                  vetDescriptionFile = clearImage(file);

                                }else if(file == guaranteeClaimedFile01){
                                  guaranteeClaimedFile01 = clearImage(file);

                                }else if(file == guaranteeClaimedFile02){
                                  guaranteeClaimedFile02 = clearImage(file);
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
        ),
        category == 'vetDescription'
            ? Container(
          width: MediaQuery.of(context).size.width*0.3,
          color: themeColour,
            child: Center(
              child: Text(' หลักฐาน ',style: TextStyle(color: Colors.white,fontSize: isTablet?20:16)),
            )
        )
            :Text('')
      ],
    );
  }
}
