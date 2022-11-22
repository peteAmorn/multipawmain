import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:multipawmain/setting/baseSetting.dart';

class handleGettingImage extends StatefulWidget {
  File? file;
  handleGettingImage({this.file});

  @override
  _handleGettingImageState createState() => _handleGettingImageState();
}

class _handleGettingImageState extends State<handleGettingImage> {
  File? result,compressedFile;

  dynamic picker = ImagePicker();

  handleTakePhoto(File? file) async{

    final XFile pickedFile = await picker.pickImage(
        source: ImageSource.camera,
    );
    setState(() {
      file = File(pickedFile.path);
    });
    int? quality;

    final filePath = file!.absolute.path;

    final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";

    if( file!.lengthSync()>0 && file!.lengthSync()<=1200000){
      quality = ((20000000)/ file!.lengthSync()).round();
    }else if(file!.lengthSync()>1200000){
      quality = 20;
    } else{
      quality = 100;
    }

    File? compressedResult;

      compressedResult = await FlutterImageCompress.compressAndGetFile(
          file!.absolute.path,
          outPath,
          quality: quality,
          format: CompressFormat.jpeg
      );

    return compressedResult;
  }

  handleChooseFromGallery(File? file) async{
    File? compressedResult;

    // getImage now returns a PickedFile instead of a File (form dart:io)
    final XFile pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
    );
    setState(() {
      file = File(pickedFile.path);
    });

    int? quality;
    late final lastIndex;

    final filePath = file!.absolute.path;

    filePath.lastIndexOf('.jp') != -1?lastIndex = filePath.lastIndexOf('.jp'):lastIndex = filePath.lastIndexOf('.png');

    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";


    if( file!.lengthSync()>50000 && file!.lengthSync()<=1200000){
      quality = ((20000000)*0.1/ file!.lengthSync()).round();
    }else if(file!.lengthSync()>1200000){
      quality = 20;
    } else{
      quality = 100;
    }

    try{
      compressedResult = await FlutterImageCompress.compressAndGetFile(
          file!.absolute.path,
          outPath,
          quality: quality,
          format: CompressFormat.jpeg
      );
    }catch(e){
      compressedResult = await FlutterImageCompress.compressAndGetFile(
          file!.absolute.path,
          outPath,
          quality: quality,
          format: CompressFormat.png
      );
    }
    return compressedResult;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Image.asset('assets/getImg.jpg',
            height: screenHeight,
            width: screenWidth,
            fit: BoxFit.cover),

        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.transparent,
            elevation: 0,
            leading: InkWell(child: Icon(Icons.arrow_back_ios,color: Colors.white),onTap: ()=>Navigator.pop(context),),
          ),
          body:Container(
            width: screenWidth,
            child: ListView(

              children: [
                SizedBox(height: 30),
                InkWell(
                  child: Container(
                      width: screenWidth,
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 2),
                        child: Image.asset('assets/takePhoto.jpg'),
                      )
                  ),
                  onTap: ()async{
                    result = await handleTakePhoto(file);
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>prevAndUploadImg(file: result)));
                  },
                ),
                SizedBox(height: 20),
                InkWell(
                  child: Container(
                      width: screenWidth,
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 2),
                        child: Image.asset('assets/fromGallery.jpg',fit: BoxFit.fitHeight),
                      )
                  ),
                  onTap: ()async{
                    result = await handleChooseFromGallery(file);
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> prevAndUploadImg(file: result)));
                  },
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
