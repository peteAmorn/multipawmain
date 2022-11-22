import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multipawmain/support/handleGettingImage.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/database/breedDatabase.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'addPhotoAddPet.dart';
import 'package:sizer/sizer.dart';

bool isTablet = false;


class infoFormAddPet extends StatefulWidget {
  final String? currentUserId,selected;
  infoFormAddPet({this.currentUserId,this.selected});

  @override
  _infoFormAddPetState createState() => _infoFormAddPetState();
}

class _infoFormAddPetState extends State<infoFormAddPet> {
  final _formKey = GlobalKey<FormState>();
  String? selectedColour,selectedPed,userPlatform,selectedGender,selected_age_dummy,pick,selectedPattern;
  String cover = 'coverPed';
  String family_tree = 'familyTree';
  File? file, fileCover,fileFamilytree;
  String a = '';
  String? selectedBreed_dummy,_handleError;
  String? selectedBreed;
  DateTime now = DateTime.now();
  DateTime? returnBirthDay;

  late bool isShow;
  bool isLoading = false;
  bool isUploading = false;
  bool isChecking = false;
  bool isUploaded_cover = false;
  bool isUploaded_familytree = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController breedController = TextEditingController();
  TextEditingController originController = TextEditingController();   // Farm of origin
  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
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

  Future<void> getLostData(File file) async {
    final LostData response =
    await picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      if (response.type == RetrieveType.video) {
        await handleTakePhoto(response.file as File);
      } else {
        setState(() {
          file = response.file as File;
        });
      }
    } else{
      _handleError = response.exception!.code;
    }
  }

  @override
  void initState(){
    super.initState();
    setState(() {
      isShow = false;
      SizerUtil.deviceType == DeviceType.tablet?isTablet = true:isTablet = false;
    });

    widget.selected == 'สุนัข'?selectedPattern = 'none':selectedPattern = null;

  }

  @override
  void dispose() {
    // TODO: implement dispose
    nameController.dispose();
    originController.dispose();
    weightController.dispose();
    heightController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg_colour,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: false,
        backgroundColor: themeColour,
        title: Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text('',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet?30:20)
          ),
        ),
        actions: [
          selectedBreed != null
              && selectedColour != null
              && selectedGender != null
              && selectedPed != null
              && returnBirthDay != null
              ? Center(
                child: InkWell(
                child: Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 15),
                  child: Text('ต่อไป',style: TextStyle(
                      color: Colors.white
                      ,fontSize: isTablet?20:16),),
                ),
                onTap: () {
                  if (_formKey.currentState!.validate()
                      && selectedBreed != null
                      && selectedColour != null
                      && selectedGender != null
                      && selectedPed != null
                      && returnBirthDay != null) {
                    Navigator.push(
                        context, MaterialPageRoute(
                        builder: (context) =>
                            addPhotoAddPet(
                              currentUserId: widget.currentUserId,
                              selected: widget.selected,
                              nameController: nameController.text,
                              selectedBreed: selectedBreed,
                              selectedColour: selectedColour,
                              selectedPattern: widget.selected == 'สุนัข'?'None':selectedPattern,
                              selectedGender: selectedGender,
                              birthDay: returnBirthDay!.day,
                              birthMonth: returnBirthDay!.month,
                              birthYear: returnBirthDay!.year,
                              selectedPed: fileCover == null && fileFamilytree == null?"No":selectedPed,
                              originController: originController.text,
                              weightController: double.parse(
                                  weightController.text),
                              heightController: double.parse(
                                  heightController.text),
                              priceController: int.parse(priceController.text),
                              descriptionController: descriptionController.text,
                              coverFile: fileCover,
                              familyTreeFile: fileFamilytree,
                              userPlatform: userPlatform,
                            ))
                    );
                  } else {}
                }),
              ) :Text('')
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
              verticalBox,
              Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                  child: buildTextFormField('ชื่อของสัตว์เลี้ยง',nameController),
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
                        child: Text('ค่าผสมพันธุ์',style: TextStyle(fontSize: isTablet?30:20,fontWeight: FontWeight.bold)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Weight section
                          Expanded(
                              flex:3,
                              child: Row(
                                children: [
                                  Text('ราคา (บาท)',style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold),),
                                  SizedBox(width: 5),
                                  Text('**',style: TextStyle(color: Colors.red.shade900,fontSize: isTablet?20:16))
                                ],
                              )
                          ),
                          Expanded(
                              flex: 5,
                              child: Container(
                                color: Colors.white,
                                height: 40,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: priceController,
                                  decoration: InputDecoration(
                                      hintText: 'ค่าผสมพันธ์ุ',
                                      hintStyle: TextStyle(fontSize: isTablet?20:16),
                                      focusedBorder: const UnderlineInputBorder(
                                          borderSide: const BorderSide(color: Color(0xFFD35757),width: 3)
                                      ),
                                      labelStyle: TextStyle(color:themeColour,fontSize: isTablet?20:16)
                                  ),
                                  validator: (value){
                                    if(value!.isEmpty){
                                      return 'กรุณาใส่ข้อมูล';
                                    }
                                    else if(double.parse(value)>1000000)
                                    {
                                      return 'ราคาสูงสุดคือ 1 ล้านบาท';
                                    }
                                    return null;
                                  },
                                ),
                              )
                          ),
                        ],
                      ),
                      SizedBox(height: 10)
                    ],
                  ),
                ),
              ),
              // Divider
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
                        final result = await Navigator.push(context, MaterialPageRoute(builder: (context)=>breedPage(selected: widget.selected)));
                        setState(() {
                          selectedBreed = result;
                          selectedBreed_dummy = result;
                          selectedColour = null;
                        });
                      }),
                      selectedBreed != null?buildRowField('สี',selectedColour,()async{
                        final result = await Navigator.push(context, MaterialPageRoute(builder: (context)=>colourPage(selected: widget.selected,selectedbreed: selectedBreed_dummy)));
                        setState(() {
                          selectedColour = result;
                        });
                      }):SizedBox(),
                      selectedBreed != null && widget.selected == 'แมว'?buildRowField('แพทเทิร์นของขน',selectedPattern,()async{
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
                        child: Text('ข้อมูลสัตว์เลี้ยง',style: TextStyle(fontSize: isTablet?30:20,fontWeight: FontWeight.bold)),
                      ),
                      buildRowField('มีใบเพ็ดดีกรีหรือไม่', selectedPed == 'Yes'?'มี':selectedPed == 'No'?'ไม่มี':null, ()async{
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
                                        buildUploadImg(context, cover, fileCover, 'coverPed'),
                                        Text('หน้าปกเพ็ดดีกรี',style: TextStyle(fontSize: isTablet?20:16),)
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
                                            buildUploadImg(context, family_tree, fileFamilytree, 'familyTree'),
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
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: buildTextFormFieldWithoutValidate('ชื่อฟาร์ม: ',originController),
                              )
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
                              flex:5,
                              child: Row(
                                children: [
                                  Text('น้ำหนัก(kg)',style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold),),
                                  SizedBox(width: 3),
                                  Text('**',style: TextStyle(color: Colors.red.shade900,fontSize: isTablet?20:16))
                                ],
                              )
                          ),
                          Expanded(
                              flex: 2,
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
                                      labelStyle: TextStyle(color:themeColour,fontSize: isTablet?20:16)
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
                              flex:5,
                              child: Row(
                                children: [
                                  Text('ส่วนสูง(cm)',style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold),),
                                  SizedBox(width: 5),
                                  Text('**',style: TextStyle(color: Colors.red.shade900,fontSize: isTablet?20:16))
                                ],
                              )
                          ),
                          Expanded(
                              flex: 2,
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
                      SizedBox(height: 10),
                      Text('** ความสูงวัดจากพื้นถึงหัวไหล่',style: TextStyle(color: Colors.red.shade900,fontWeight: FontWeight.bold,fontSize: isTablet?20:16),maxLines: 2),
                      SizedBox(height: 10)
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
                      SizedBox(height: 20)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  buildUploadImg(BuildContext context,String? img, File? file, String category){
    return Container(
        child: file == null?
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
            if(img == 'coverPed'){
              fileCover = await Navigator.push(context, MaterialPageRoute(builder: (context)=>handleGettingImage(file: file)));
            }else if(img == 'familyTree'){
              fileFamilytree = await Navigator.push(context, MaterialPageRoute(builder: (context)=>handleGettingImage(file: file)));
            }
            setState(() {

            });
          },
        ):
        Container(
          width: MediaQuery.of(context).size.width * 0.30,
          padding: EdgeInsets.symmetric(horizontal: 10),
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
                            if(file == fileCover){
                              fileCover = clearImage(file);

                            }else if(file == fileFamilytree){
                              fileFamilytree = clearImage(file);
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

  Column buildRowField(String topic, String? name,Function() ontap) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(topic,style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold)),
            SizedBox(width: 5),
            Text('**',style: TextStyle(color: Colors.red.shade900,fontSize: isTablet?20:16))
          ],
        ),
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

  Column buildRowFieldDateTime(String topic, DateTime? name,Function() ontap) {
    final DateFormat formatter = DateFormat('dd MMM yyyy');
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(topic,style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold)),
            SizedBox(width: 5),
            Text('**',style: TextStyle(fontSize: isTablet?20:16,color: Colors.red.shade900))
          ],
        ),
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




  Column buildTextFormField(String topic, TextEditingController controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(topic,style: TextStyle(fontSize: isTablet?20:16,fontWeight: FontWeight.bold),),
            SizedBox(width: 5),
            Text('**',style: TextStyle(color: Colors.red.shade900,fontSize: isTablet?20:16))
          ],
        ),
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

  Column buildTextFormFieldWithoutValidate(String topic, TextEditingController controller) {
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
              hintText: 'ชื่อฟาร์มที่ปรากฎบนใบเพ็ดดีกรี',
                focusedBorder: const UnderlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFD35757),width: 3)
                ),
                labelStyle: TextStyle(color:themeColour),
              hintStyle: TextStyle(fontSize: isTablet?20:16)
            ),
          ),
        ),
      ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithOutBackArrow('มีใบเพ็ดดีกรีหรือไม่',isTablet),
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
