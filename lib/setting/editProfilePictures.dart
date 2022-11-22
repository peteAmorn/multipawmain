import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multipawmain/setting/baseSetting.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/support/handleGettingImage.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:uuid/uuid.dart';
import 'package:multipawmain/authCheck.dart';

class editProfilePicture extends StatefulWidget {
  final String? profileCover,profile1,profile2,profile3,profile4,profile5,profileId;
  editProfilePicture({this.profileCover,this.profile1,this.profile2,this.profile3,this.profile4,this.profile5,this.profileId});

  @override
  _editProfilePictureState createState() => _editProfilePictureState();
}

class _editProfilePictureState extends State<editProfilePicture> {
  late String profileCoverImg, profile1Img,profile2Img,profile3Img,profile4Img,profile5Img;
  String? new_profileCoverImg, new_profile1Img,new_profile2Img,new_profile3Img,new_profile4Img,new_profile5Img;
  File? fileCover,filePro1,filePro2,filePro3,filePro4,filePro5;
  List<dataList> imgList = [];
  late bool isLoading;
  String postId = Uuid().v4();
  String a ='';

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      imageCache.clear();
      isLoading = false;

      profileCoverImg = profileCover.toString();
      profile1Img = profile1.toString();
      profile2Img = profile2.toString();
      profile3Img = profile3.toString();
      profile4Img = profile4.toString();
      profile5Img = profile5.toString();

    });

  }

  Future<String> uploadImageCover(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('postCover_$postId.jpg').putFile(imgFile);
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


  handleSubmit() async{
    List<File?> fileInfo = [fileCover,filePro1,filePro2,filePro3,filePro4,filePro5];
    setState((){
      isLoading = true;
    });

    for(var i=0;imgList.length>i;i++){

      if(imgList[i].name == 'cover'){
        new_profileCoverImg =await uploadImageCover(fileCover);

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
      }
    }

    await petsRef.doc(widget.profileId).update({
      'coverProfile':fileCover == null?profileCoverImg:new_profileCoverImg,
      'profile1': filePro1 == null?profile1Img:new_profile1Img,
      'profile2': filePro2 == null?profile2Img:new_profile2Img,
      'profile3': filePro3 == null?profile3Img:new_profile3Img,
      'profile4': filePro4 == null?profile4Img:new_profile4Img,
      'profile5': filePro5 == null?profile5Img:new_profile5Img,
    });

    for(var i = 0;i<fileInfo.length;i++){
      if(fileInfo[i]!= null){
        await fileInfo[i]!.delete();
      }
    }

    setState(() {
      for(var i=0;imgList.length>i;i++){
        imgList[i].info = null;
        postId = Uuid().v4();
      }
      isLoading = false;
    });
    Navigator.pop(context);
    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColour,
        title: Text('แก้ไขรูปโปรไฟล์สัตว์เลี้ยง',style: TextStyle(color: Colors.white,fontSize: isTablet?21:17)),
        leading: InkWell(child: Icon(Icons.arrow_back_ios),onTap: (){
          handleSubmit();
        }),
      ),
      body: isLoading == true?loading():Column(
        children: [
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 0.001),
                buildUploadImg(context,
                    profileCoverImg,
                    fileCover,
                    'cover'
                ),
                buildUploadImg(context,
                    profile1Img,
                    filePro1,
                    'profile1'
                ),
                buildUploadImg(context,
                    profile2Img,
                    filePro2,
                    'profile2'
                ),
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
                buildUploadImg(context,
                    profile3Img,
                    filePro3,
                    'profile3'
                ),
                buildUploadImg(context,
                    profile4Img,
                    filePro4,
                    'profile4'
                ),
                buildUploadImg(context,
                    profile5Img,
                    filePro5,
                    'profile5'
                ),
                SizedBox(width: 0.001),
              ],
            ),
          ),
        ],
      ),
    );
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
            )
          ),
        ),
        onTap: ()async{
          if(img == 'cover'){
            fileCover = await Navigator.push(context, MaterialPageRoute(builder: (context)=>handleGettingImage(file: file)));
            imgList.add(dataList(name: 'cover', info: fileCover));
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
          }
          setState(() {});
        },
      ):
      img != category && file == null?
      InkWell(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.30,
          child: Stack(
            children: [
              Positioned(
                child: AspectRatio(
                  aspectRatio: 8 / 10.5,
                  child: Container(
                    height: isTablet?380:143,
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
                          fileCover = clearImage(file);

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

                        }
                      });
                    },
                  )
              ),category == 'cover'?Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                      color: themeColour,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Text('หน้าปก',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: isTablet?20:16)),
                      )
                  )
              ):Text(''),
            ],
          ),
        ),

      ):
      file != null && img == category?
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
                            profileCoverImg = 'cover';

                          }else if(file == filePro1){
                            filePro1 = clearImage(file);
                            profile1Img = 'profile1';

                          }else if(file == filePro2){
                            filePro2 = clearImage(file);
                            profile2Img = 'profile2';

                          }else if(file == filePro3){
                            filePro3 = clearImage(file);
                            profile3Img = 'profile3';

                          }else if(file == filePro4){
                            filePro4 = clearImage(file);
                            profile4Img = 'profile4';

                          }else if(file == filePro5){
                            filePro5 = clearImage(file);
                            profile5Img = 'profile5';

                          }
                        });
                      },
                    )
                ),Positioned(
                    bottom: 0,
                    left: 0,
                    child: category == 'COVER'?Container(
                        color: themeColour,
                        child: Text('หน้าปก',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold))
                    ): Text('')
                ),
              ],
            ),
          ],
        ),
      ): Text(''),
    );
  }
}

class dataList{
  final String name;
  File? info;

  dataList({required this.name,required this.info});
}