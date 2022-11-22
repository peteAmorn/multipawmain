import 'package:flutter/material.dart';
import 'package:multipawmain/support/handleGettingImage.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:multipawmain/pages/myPets/myPets.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:multipawmain/authCheck.dart';
import 'package:uuid/uuid.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:sizer/sizer.dart';

final DateTime timestamp = DateTime.now();

class addPhotoAddPet extends StatefulWidget {
  final String?
  currentUserId,
      selected,
      selectedBreed,
      selectedColour,
      selectedPattern,
      selectedGender,
      selectedPed,
      nameController,
      originController,
      descriptionController,
      userPlatform;
  final int?
  birthDay,
      birthMonth,
      birthYear,
      priceController;
  final double?
  weightController,
      heightController;
  final File?
  coverFile,
      familyTreeFile;
  addPhotoAddPet({
    this.currentUserId,
    this.selected,
    this.selectedBreed,
    this.selectedColour,
    this.selectedPattern,
    this.selectedGender,
    this.birthDay,
    this.birthMonth,
    this.birthYear,
    this.selectedPed,
    this.nameController,
    this.originController,
    this.weightController,
    this.heightController,
    this.priceController,
    this.descriptionController,
    this.coverFile,
    this.familyTreeFile,
    this.userPlatform
  });

  @override
  _addPhotoAddPetState createState() => _addPhotoAddPetState();
}

class _addPhotoAddPetState extends State<addPhotoAddPet> {
  String postId = Uuid().v4();
  String a = '';
  String? city,location1,location2;
  double? lat,lng;
  bool isTablet = false;

  File? file,fileCover,filePro1,filePro2,filePro3,filePro4,filePro5;
  late String profileCoverImg,profile1Img,profile2Img,profile3Img,profile4Img,profile5Img;
  bool isLoading = false;
  bool isUploading = false;
  bool isChecking = false;

  dynamic picker = ImagePicker();

  clearImage(File? file) {
    if (file == null) return;
    File? tmp_file = File(file.path);
    tmp_file = null;

    setState(() {
      file = tmp_file;
    });
    return tmp_file;
  }

  Future<String> uploadImagePedCover(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('petPedCover_$postId.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }
    return a;
  }

  Future<String> uploadImagePedFamily(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('petPedFamily_$postId.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }
    return a;
  }

  Future<String> uploadImageCover(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('petProfileCover_$postId.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }
    return a;
  }

  Future<String> uploadImageProfile1(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('petProfile1_$postId.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }
    return a;
  }

  Future<String> uploadImageProfile2(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('petProfile2_$postId.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }
    return a;
  }

  Future<String> uploadImageProfile3(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('petProfile3_$postId.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }
    return a;
  }

  Future<String> uploadImageProfile4(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('petProfile4_$postId.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }
    return a;
  }

  Future<String> uploadImageProfile5(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('petProfile5_$postId.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }
    return a;
  }

  createPostInFirestore
      ({
    final coverPedigree,
    final familyTreeFilePedigree,
    final coverProfile,
    final profile1,
    final profile2,
    final profile3,
    final profile4,
    final profile5,
    final ownername,
    final ownerprofile
  }){
    petsRef.doc(postId).set({
      'id' : widget.currentUserId,
      'postid': postId,
      'name': widget.nameController,
      'type': widget.selected,
      'breed': widget.selectedBreed,
      'colour': widget.selectedColour,
      'pattern':widget.selectedPattern != null?widget.selectedPattern:'สีเดียวทั่วทั้งตัว(Solid colour)',
      'gender': widget.selectedGender,
      'birthDay': widget.birthDay,
      'birthMonth': widget.birthMonth,
      'birthYear': widget.birthYear,
      'pedigree': widget.selectedPed,
      'weight': widget.weightController,
      'height': widget.heightController,
      'originFarm': widget.originController,
      'aboutPet': widget.descriptionController,

      'price': widget.priceController,
      'targetDistance': 100,
      'targetAgeStart':1,
      'targetAgeEnd': 6,

      'coverPedigree': coverPedigree,
      'familyTreePedigree': familyTreeFilePedigree,
      'coverProfile': coverProfile,
      'profile1': profile1,
      'profile2': profile2,
      'profile3': profile3,
      'profile4': profile4,
      'profile5': profile5,

      'active': 'Yes',
      'timestamp': timestamp.millisecondsSinceEpoch,

      'lat':lat,
      'lng':lng,
      'city':city,
      'location1':location1,
      'location2': location2,
      'ownerName': ownername,
      'ownerProfile': ownerprofile != null?ownerprofile:""
    });

    petsIndexRef.doc(widget.selectedBreed).collection(widget.selectedBreed.toString()).doc(postId).set(
        {
          'postid': postId,
          'id':widget.currentUserId,
          'timestamp': timestamp.millisecondsSinceEpoch
        });

    myPetsIndex.doc(widget.currentUserId).collection(widget.currentUserId.toString()).doc(postId).set(
        {
          'postid': postId,
          'id':widget.currentUserId,
          'timestamp': timestamp.millisecondsSinceEpoch
        });
  }

  handleSubmit() async{
    List<String?> images = ['coverPed','familyTree','cover','profile1','profile2','profile3','profile4','profile5'];

    List<File?> path = [widget.coverFile,widget.familyTreeFile,fileCover,filePro1,filePro2,filePro3,filePro4,filePro5];

    setState((){
      isLoading = true;
    });

    path[0] == null? null: images[0] = await uploadImagePedCover(path[0]);
    path[1] == null? null: images[1] = await uploadImagePedFamily(path[1]);
    path[2] == null? null: images[2] = await uploadImageCover(path[2]);
    path[3] == null? null: images[3] = await uploadImageProfile1(path[3]);
    path[4] == null? null: images[4] = await uploadImageProfile2(path[4]);
    path[5] == null? null: images[5] = await uploadImageProfile3(path[5]);
    path[6] == null? null: images[6] = await uploadImageProfile4(path[6]);
    path[7] == null? null: images[7] = await uploadImageProfile5(path[7]);

    await usersRef.doc(widget.currentUserId).get().then((snapshot) {
      createPostInFirestore(
          coverPedigree: images[0]!.isEmpty?'None':images[0].toString(),
          familyTreeFilePedigree: images[1]!.isEmpty?'None':images[1].toString(),
          coverProfile: images[2]!.isEmpty?'None':images[2].toString(),
          profile1: images[3]!.isEmpty?'None':images[3].toString(),
          profile2: images[4]!.isEmpty?'None':images[4].toString(),
          profile3: images[5]!.isEmpty?'None':images[5].toString(),
          profile4: images[6]!.isEmpty?'None':images[6].toString(),
          profile5: images[7]!.isEmpty?'None':images[7].toString(),
          ownername: snapshot.data()!['name'],
          ownerprofile: snapshot.data()!['urlProfilePic']
      );
    });
    for(var i = 0; i<path.length;i++){
      if(path[i]!=null){
        await path[i]!.delete();
      }
    }

    setState(() {
      for(var i=0;path.length>i;i++){
        path[i] = null;
        postId = Uuid().v4();
      }
      isLoading = false;
    });

    Navigator.push(
        context,
        MaterialPageRoute(builder: (context)=> myPets(currentUserId: widget.currentUserId.toString())
        )
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      SizerUtil.deviceType == DeviceType.tablet?isTablet = true:isTablet = false;
    });
    getUserData();

    profileCoverImg = 'cover';
    profile1Img = 'profile1';
    profile2Img = 'profile2';
    profile3Img = 'profile3';
    profile4Img = 'profile4';
    profile5Img = 'profile5';
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: appbarPetProfile('','เสร็จสิ้น',isTablet,()=>handleSubmit()),
      body: isLoading == true?loading():Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 0.001),
                buildUploadImg(context,profileCoverImg,fileCover,'cover'),
                buildUploadImg(context,profile1Img,filePro1,'profile1'),
                buildUploadImg(context,profile2Img,filePro2,'profile2'),
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
                buildUploadImg(context,profile3Img,filePro3,'profile3'),
                buildUploadImg(context,profile4Img,filePro4,'profile4'),
                buildUploadImg(context,profile5Img,filePro5,'profile5'),
                SizedBox(width: 0.001),
              ],
            ),
          ),
        ],
      ),
    );

  }

  Future<dynamic> getUserData(){
    return usersRef.doc(widget.currentUserId).get().then((snapshot){
      city = snapshot.data()!['city'];
      lat = snapshot.data()!['lat'];
      lng = snapshot.data()!['lng'];
      location1 = snapshot.data()!['location1'];
      location2 = snapshot.data()!['location2'];
    });
  }

  buildUploadImg(BuildContext context,String? img, File? file, String category){
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
                          fit: BoxFit.cover,
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
              fileCover = await Navigator.push(context, MaterialPageRoute(builder: (context)=>handleGettingImage(file: file)));

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
          width: MediaQuery.of(context).size.width * 0.3,
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
                            if(file == fileCover){
                              fileCover = clearImage(file);

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
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('หน้าปก',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
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
