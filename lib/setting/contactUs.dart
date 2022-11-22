import 'dart:async';
import 'dart:io';
import 'dart:io' show Platform;

import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:light_compressor/light_compressor.dart';

import 'package:multipawmain/authCheck.dart';
import 'package:multipawmain/setting/baseSetting.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:multipawmain/support/constants.dart';

import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as Im;
import 'package:multipawmain/support/videoPreview.dart';
import 'package:multipawmain/support/videoPreviewForUpload.dart';

import 'package:video_compress/video_compress.dart' as vc;
import 'package:light_compressor/light_compressor.dart' as lc;
import 'package:multipawmain/support/showNetworkImage.dart';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:intl/intl.dart';

DateTime timestamp = DateTime.now();
var now = DateTime.now();
var lastnight = DateTime(now.year,now.month,now.day);

class contactUs extends StatefulWidget {
  final userId,userImage,userName;
  contactUs({required this.userId, required this.userImage, required this.userName});

  @override
  _contactUsState createState() => _contactUsState();
}

class _contactUsState extends State<contactUs> {
  TextEditingController _controller = TextEditingController();
  String imageId = Uuid().v4();
  dynamic picker = ImagePicker();

  bool isTablet = false;
  late bool show;
  late bool isLoading;
  late String _desFile;
  bool isUploading = false;
  File? file,compressedFile;
  vc.MediaInfo? mediaFile;
  String a = '';
  String peerId = 'ioL4BlHFnxaUZ7zDtSbWMgjjKJs2';
  late String peerImage;
  late String peerName;
  Position? _currentPosition;
  late double pageHeight;
  List<File?> resultList = [];

  getMultipawsInfo()async{
    await usersRef.doc(peerId).get().then((snapshot){
      peerImage = snapshot.data()!['urlProfilePic'];
      peerName = snapshot.data()!['name'];
    });
    setState(() {
      isLoading = false;
    });
  }
//multipawsthailand@gmail.com
  //Bkk1234!
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

    File? compressedResult = await FlutterImageCompress.compressAndGetFile(
      file!.absolute.path,
      outPath,
      quality: quality,
    );
    return compressedResult;
  }

  Future<String> get _destinationFile async {
    String directory;
    final String videoName = '${DateTime.now().millisecondsSinceEpoch}.mp4';
    if (Platform.isAndroid) {
      // Handle this part the way you want to save it in any directory you wish.
      final List<Directory>? dir = await getExternalStorageDirectories(
          type: StorageDirectory.movies);
      directory = dir!.first.path;
      return File('$directory/$videoName').path;
    } else {
      final Directory dir = await getLibraryDirectory();
      directory = dir.path;

      return File('$directory/$videoName').path;
    }
  }

  handleChooseVideoFromGallery(File? file) async{
    List<File?> fileList = [];
    // getImage now returns a PickedFile instead of a File (form dart:io)
    final XFile pickedFile = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(seconds: 60),
    );

    // 3. Check if an image has been picked or take with the camera.
    setState(() {
      file = File(pickedFile.path);
    });

    final filePath = file!.absolute.path;
    setState(() {
      isUploading = true;
    });

    File? compressedThumbnailResult = await vc.VideoCompress.getFileThumbnail(
      filePath,
      quality: 20,
    );
    fileList.add(compressedThumbnailResult);

    if(Platform.isIOS){
      vc.MediaInfo? compressedResultiOS = await vc.VideoCompress.compressVideo(
          filePath,
          quality: vc.VideoQuality.MediumQuality,
          includeAudio: true
      );
      fileList.add(compressedResultiOS!.file);
    }else if(Platform.isAndroid){
      _desFile = await _destinationFile;

      final lc.LightCompressor _lightCompressor = lc.LightCompressor();
      final dynamic compressResultAndroid = await _lightCompressor.compressVideo(
          path: filePath,
          destinationPath: _desFile,
          videoQuality: lc.VideoQuality.medium,
          isMinBitrateCheckEnabled: false,
          frameRate: 30 );

      if (compressResultAndroid is OnSuccess) {
        _desFile = compressResultAndroid.destinationPath;
        compressedFile = new File(_desFile);
        fileList.add(compressedFile);
      }
    }
    setState(() {
      isUploading = false;
    });
    return fileList;
  }

  handleChooseFromGallery(File? file) async{
    // getImage now returns a PickedFile instead of a File (form dart:io)
    final XFile pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    // 3. Check if an image has been picked or take with the camera.
    setState(() {
      file = File(pickedFile.path);
    });
    int? quality;

    final filePath = file!.absolute.path;
    setState(() {
      isUploading = true;
    });

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

    File? compressedResult = await FlutterImageCompress.compressAndGetFile(
      file!.absolute.path,
      outPath,
      quality: quality,
    );
    setState(() {
      isUploading = false;
    });
    return compressedResult;
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
    final compressedImageFile = File('$path/imgChat_$imageId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile!,quality:20));
    setState(() {
      file = compressedImageFile;
    });
  }

  inChatUpdateInFirestore({
    final type,
    final sender,
    final receiver,
    final message,
    final url,
    final message_noti,
    final timestamp,
  }){
    helpChatRef.doc(widget.userId).collection(widget.userId).doc(DateTime.now().microsecondsSinceEpoch.toString()).set({
      'type': type,
      'sender': widget.userId,
      'receiver': peerId,
      'message': message,
      'url': url,
      'timestamp': DateTime.now(),
      'toShow' : true,
    });

    notiRef.doc().set({
      'userName': widget.userName,
      'peerName': peerName,
      'userId':widget.userId,
      'peerId': peerId,
      'userImg': widget.userImage,
      'peerImg': peerImage,
      'message': message_noti,
      'type': 'chat',
      'timestamp': DateTime.now()
    });
  }

  inUserUpdateInFireStore(String message,int type)async{
    await allHelpChatRef.doc(widget.userId).set(
        {
          'profile': widget.userImage,
          'name': widget.userName,
          'peerId': widget.userId,
          'type': type,
          'message': message,
          'timeStamp': DateTime.now(),
          'isShow': true,
          'isDone': false,
        });
  }

  _getCurrentPosition() async{
    setState(() {
      isLoading = true;
    });
    await Geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.medium,
        forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _currentPosition = position;

        lat = _currentPosition?.latitude;
        lng = _currentPosition?.longitude;

        inChatUpdateInFirestore(
            type: 2,
            message: 'https://www.google.com/maps/search/?api=1&query=${lat},${lng}',
            url: '',
            message_noti: '${widget.userName} ส่งที่อยู่ปัจจุบันให้คุณ',
            timestamp: timestamp
        );
        inUserUpdateInFireStore('${widget.userName} ส่งที่อยู่ปัจจุบันให้คุณ',2);
        lat = null;
        lng = null;
      });
    }).catchError((e){print(e);});
    setState(() {
      isLoading = false;
    });
  }

  sharedLocation()async{
    await usersRef.doc(widget.userId).get().then((snapshot){
      lat = snapshot['lat'];
      lng = snapshot['lng'];

      inChatUpdateInFirestore(
          type: 2,
          message: 'https://www.google.com/maps/search/?api=1&query=${lat},${lng}',
          url: '',
          message_noti: '${widget.userName} ส่งที่อยู่ฟาร์มให้คุณ',
          timestamp: timestamp
      );
      inUserUpdateInFireStore('${widget.userName} ส่งที่อยู่ฟาร์มให้คุณ',2);
      lat = null;
      lng = null;
    });
  }

  Future<String> uploadImage(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('imgChat_$imageId.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      inChatUpdateInFirestore(type: 1,message: downloadUrl,message_noti: 'Sent photo');
      // return downloadUrl;
    }catch(e){
      print(e);
    }
    return a;
  }

  Future<String> uploadVideo(mediaThumbnail,mediaFile) async{

    try{
      UploadTask uploadTask_thumbnail = storageRef.child('imgChatThumbnail_$imageId.jpg').putFile(mediaThumbnail);
      String downloadUrl_thumbnail = await (await uploadTask_thumbnail).ref.getDownloadURL();

      UploadTask uploadTask = storageRef.child('imgChatVideo_$imageId.mp4').putFile(mediaFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();

      inChatUpdateInFirestore(type: 3,message: downloadUrl_thumbnail,url: downloadUrl,message_noti: 'Sent video');
      return downloadUrl;
    }catch(e){
      print(e);
    }

    return a;
  }

  handleSubmit(int i) async{

    setState(() {
      isUploading = true;
      isUploading== true? Center(child: CircularProgressIndicator(color: themeColour)): null;
    });

    if(i == 1){
      file == null? null: await compressImage(file);
      file == null? null: await uploadImage(file);
      inUserUpdateInFireStore('Image',1);
    }else if(i == 2){
      resultList[0] == null? null: await uploadVideo(resultList[0],resultList[1]);
      inUserUpdateInFireStore('Video',2);
    }

    setState(() {
      file = null;
      imageId = Uuid().v4();

      isUploading = false;
      isUploading== true? Center(child: CircularProgressIndicator(color: themeColour)): null;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      show = false;
      isLoading = true;
      pageHeight = 300;
      SizerUtil.deviceType == DeviceType.tablet?isTablet = true:isTablet = false;
    });
    getMultipawsInfo();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenwidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: bg_colour,
        appBar: appBarWithBackArrow('Live Help',isTablet),
        body: isLoading == true || isUploading == true?loading():Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MessagesStream(userid: widget.userId,peerid: peerId,peerImg: peerImage),
            Container(
              color: themeColour,
              width: screenwidth,
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(top: 10,bottom: 10),
                child: Row(
                  children: [
                    SizedBox(width: screenwidth*0.045),
                    Padding(
                      padding: const EdgeInsets.only(right:20.0),
                      child: InkWell(
                        child: Icon(FontAwesomeIcons.photoVideo,color: Colors.white,size: 20),
                        onTap: ()async{
                          showMaterialModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.red.shade900,
                              builder: (context)=>Container(
                                height: pageHeight,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 10),
                                      child: Container(
                                        child: Column(
                                          children: [
                                            sharelocationOption(
                                                context,
                                                Colors.white,
                                                Colors.white,
                                                Icon(FontAwesomeIcons.camera,color: Colors.red.shade900,size: 18),
                                                Text('ถ่ายรูป',
                                                    style: TextStyle(
                                                      color: Colors.red.shade900,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    )),
                                                    ()async{
                                                  file = await handleTakePhoto(file);
                                                  file = await Navigator.push(context, MaterialPageRoute(builder: (context)=>prevAndUploadForChat(file: file)));
                                                  file == ""? null: await handleSubmit(1);
                                                  Navigator.pop(context);
                                                }
                                            ),
                                            sharelocationOption(
                                                context,
                                                Colors.white,
                                                Colors.white,
                                                Icon(FontAwesomeIcons.solidImages,color: Colors.red.shade900,size: 18),
                                                Text('รูปภาพ',
                                                    style: TextStyle(
                                                      color: Colors.red.shade900,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    )),
                                                    ()async{
                                                      file = await handleChooseFromGallery(file);
                                                      file = await Navigator.push(context, MaterialPageRoute(builder: (context)=>prevAndUploadForChat(file: file)));
                                                      file == ""? null: await handleSubmit(1);
                                                      Navigator.pop(context);
                                                }
                                            ),
                                            sharelocationOption(
                                                context,
                                                Colors.white,
                                                Colors.white,
                                                Icon(FontAwesomeIcons.video,color: Colors.red.shade900,size: 18),
                                                Text('วิดีโอ  ',
                                                    style: TextStyle(
                                                      color: Colors.red.shade900,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    )),
                                                    ()async{
                                                  resultList.clear();
                                                  resultList = await handleChooseVideoFromGallery(file);
                                                  Platform.isAndroid? resultList = await Navigator.push(context, MaterialPageRoute(builder: (context)=>videoPreviewForUpload(listData: resultList))):null;
                                                  resultList == ""? null: await handleSubmit(2);
                                                  if(Platform.isAndroid){
                                                    File removeFile = File(resultList[1]!.path);
                                                    removeFile.delete();
                                                  }
                                                  Navigator.pop(context);
                                                }
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.only(left: 10.0,right: 10,bottom: 30),
                                      child: InkWell(
                                        child: Container(
                                          width: MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.all(Radius.circular(10)),
                                              border: Border.all(color: Colors.red.shade900)
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text('ยกเลิก',
                                                    style: TextStyle(
                                                      color: Colors.red.shade900,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ))
                                              ],
                                            ),
                                          ),
                                        ),
                                        onTap: ()=>Navigator.pop(context),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right:10.0),
                      child: InkWell(
                          child: Icon(FontAwesomeIcons.mapMarkerAlt,color: Colors.white,size: 20),
                          onTap: (){
                            showMaterialModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.red.shade900,
                                builder: (context)=>Container(
                                  height: 240,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 10),
                                        child: Container(
                                          child: Column(
                                            children: [
                                              sharelocationOption(
                                                  context,
                                                  Colors.white,
                                                  Colors.white,
                                                  Icon(FontAwesomeIcons.home,color: Colors.red.shade900,size: 18),
                                                  Text('ตำแหน่งที่อยู่ฟาร์ม ',
                                                      style: TextStyle(
                                                        color: Colors.red.shade900,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      )),
                                                      (){
                                                    sharedLocation();
                                                    Navigator.pop(context);
                                                  }
                                              ),
                                              sharelocationOption(
                                                  context,
                                                  Colors.white,
                                                  Colors.white,
                                                  Icon(FontAwesomeIcons.crosshairs,color: Colors.red.shade900,size: 18),
                                                  Text('ตำแหน่งที่อยู่ปัจจุบัน',
                                                      style: TextStyle(
                                                        color: Colors.red.shade900,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      )),
                                                      (){
                                                    _getCurrentPosition();
                                                    Navigator.pop(context);
                                                  }
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.only(left: 10.0,right: 10,bottom: 30),
                                        child: InkWell(
                                          child: Container(
                                            width: MediaQuery.of(context).size.width,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                                border: Border.all(color: Colors.red.shade900)
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text('ยกเลิก',
                                                      style: TextStyle(
                                                        color: Colors.red.shade900,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      ))
                                                ],
                                              ),
                                            ),
                                          ),
                                          onTap: ()=>Navigator.pop(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                            );
                          }),
                    ),

                    SizedBox(width: screenwidth*0.025),
                    Column(
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: 100,
                          ),
                          child: Container(
                            width: screenwidth*0.70,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: screenwidth*0.55,
                                  child: TextFormField(
                                    controller: _controller,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    toolbarOptions: ToolbarOptions(
                                      copy:  true,
                                      cut:  true,
                                      paste: true,
                                      selectAll: true,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'กรุณาพิมพ์ข้อความ....',
                                      hintStyle: TextStyle(fontSize: 14),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.only(left: 15, right: 15),
                                    ),
                                    onChanged: (text){
                                      setState(() {
                                        if(text.trim().isNotEmpty){
                                          show = true;
                                        }else{
                                          show = false;
                                        }
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(width: screenwidth*0.05),
                                show?InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Icon(Icons.send,color: themeColour),
                                  ),
                                  onTap: (){
                                    inChatUpdateInFirestore(
                                        type: 0,
                                        message: _controller.text,
                                        url: '',
                                        message_noti: _controller.text,
                                        timestamp: timestamp
                                    );
                                    inUserUpdateInFireStore( _controller.text,0);
                                    _controller.clear();
                                    setState(() {
                                      show = false;
                                    });
                                  },
                                ):Text(''),
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Padding sharelocationOption(BuildContext context,Color boxColor, Color edgeColor,Icon icon,Text topic,Function() ontap) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0,right: 10,top: 10),
      child: InkWell(
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: boxColor,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              border: Border.all(color: edgeColor)
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                icon,
                SizedBox(width: 15),
                topic
              ],
            ),
          ),
        ),
        onTap: ontap,
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  MessagesStream({required this.userid, required this.peerid,required this.peerImg});
  final String? userid, peerid, peerImg;

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
        stream: helpChatRef.doc(userid).collection(userid!).where('toShow',isEqualTo: true).snapshots(),
        builder: (BuildContext context,AsyncSnapshot snapshot){
          if(!snapshot.hasData){
            return Center(child: CircularProgressIndicator(color: themeColour,)
            );
          }
          final messages = snapshot.data.docs;
          List<MessageBubble> messagesBubbles = [];
          for(var message in messages){
            final messageText = message.data()['message'];
            final messageImg = message.data()['image'];
            final url = message.data()['url'];
            final messageSender = message.data()['sender'];
            final messageTime = message.data()['timestamp'];
            final String type = message.data()['type'].toString();

            final messageBubble = MessageBubble(
                sender: messageSender,
                peerid: peerid.toString(),
                peerImg: peerImg.toString(),
                message: messageText,
                messageImg: messageImg,
                dateTime: messageTime,
                //if not working, change Duration day to 1
                isToday: messageTime.toDate().isBefore(lastnight),
                isYest: messageTime.toDate().isBefore(lastnight.subtract(Duration(days: 1))),
                isMe:  userid == messageSender,
                type: type
            );

            messagesBubbles.add(messageBubble);
            messagesBubbles.sort((a,b)=>b.dateTime.compareTo(a.dateTime));
            messagesBubbles = messagesBubbles.toList();
          }
          return Expanded(
            child: InkWell(
              onTap: (){
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: ListView.builder(
                itemCount: messagesBubbles.length,
                reverse: true,
                padding: EdgeInsets.only(top: 10.0,bottom: 20,left: 20.0,right: 20.0),
                itemBuilder: (context,i){
                  return messagesBubbles[i];
                },
              ),
            ),
          );
        }
    );
  }
}


class MessageBubble extends StatelessWidget {
  MessageBubble({required this.sender,required this.peerid,required this.message,this.url,this.messageImg,required this.dateTime,required this.isMe,required this.isToday,required this.isYest, required this.type,required this.peerImg
    ,this.priceMin,this.priceMax,this.pricePromoMin,this.pricePromoMax});

  late final String sender;
  late final String peerid;
  late final String peerImg;
  late final String message;
  final String? url;
  final String? messageImg;
  final priceMin;
  final priceMax;
  final pricePromoMin;
  final pricePromoMax;
  late final Timestamp dateTime;
  late final bool isToday;
  late final bool isYest;
  late final bool isMe;
  late final type;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: usersRef.doc(peerid).get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Text('');
        } else if (snapshot.hasData) {
          var f = new NumberFormat("#,###", "en_US");
          return Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment:
              isMe? CrossAxisAlignment.end:CrossAxisAlignment.start,
              children: [
                isMe?Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [

                        // Type == 0 is TEXT
                        type == '0'?Material(
                          borderRadius: isMe?BorderRadius.only(
                              topLeft: Radius.circular(30.0),
                              bottomLeft: Radius.circular(30.0),
                              bottomRight: Radius.circular(30.0))
                              : BorderRadius.only(
                            bottomLeft: Radius.circular(30.0),
                            bottomRight: Radius.circular(30.0),
                            topRight: Radius.circular(30.0),
                          ),
                          elevation: 3.0,
                          color: isMe?themeColour : Colors.white,
                          child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 20.0),
                              child: Container(
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width*0.5),
                                child: Text(
                                  message,
                                  maxLines: 20,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: isMe?Colors.white:Colors.black54,
                                      fontSize: 15.0
                                  ),
                                ),
                              )
                          ),

                          // Type == 2 is location
                        ):type == '2'?Material(
                          borderRadius: isMe?BorderRadius.only(
                              topLeft: Radius.circular(30.0),
                              bottomLeft: Radius.circular(30.0),
                              bottomRight: Radius.circular(30.0))
                              : BorderRadius.only(
                            bottomLeft: Radius.circular(30.0),
                            bottomRight: Radius.circular(30.0),
                            topRight: Radius.circular(30.0),
                          ),
                          elevation: 3.0,
                          color: isMe?themeColour : Colors.white,
                          child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 10.0),
                              child: InkWell(
                                child: Container(
                                  height: MediaQuery.of(context).size.height*1/8,
                                  width: MediaQuery.of(context).size.height*1/7,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.0),
                                      image: DecorationImage(
                                        fit: BoxFit.cover,image: AssetImage('assets/googlemap.jpg'),
                                      )
                                  ),
                                ),
                                onTap: () async{
                                  await canLaunch(message) ? await launch(message): throw 'Could not launch $message';
                                },
                              )
                          ),
                          // Type == 4 is the link from post
                        ):type == '4'?
                        Material(
                            borderRadius: isMe?BorderRadius.only(
                                topLeft: Radius.circular(30.0),
                                bottomLeft: Radius.circular(30.0),
                                bottomRight: Radius.circular(30.0))
                                : BorderRadius.only(
                              bottomLeft: Radius.circular(30.0),
                              bottomRight: Radius.circular(30.0),
                              topRight: Radius.circular(30.0),
                            ),
                            elevation: 3.0,
                            color: isMe?themeColour : Colors.white,child:Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 10.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width/2,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                              color: Colors.white,
                            ),
                            child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                          color: Colors.white,
                                          child: Image.network(messageImg.toString(),fit: BoxFit.cover,
                                              errorBuilder: (context,exception,stackTrace)
                                              =>Container(
                                                height: 100,
                                                child: Center(child: Text('Image not found')),
                                              )
                                          )
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width/2,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(message,style: TextStyle(fontSize: 14),maxLines: 2),
                                          SizedBox(height: 10),
                                          Column(
                                            children: [
                                              Visibility(
                                                  visible: pricePromoMin>0 && pricePromoMax>0,
                                                  child: Text('฿ ${f.format(pricePromoMin)}-${f.format(pricePromoMax)}',
                                                      style: textStyle())
                                              ),

                                              SizedBox(height: 3),

                                              priceMin>0 && pricePromoMax==0?Text('฿ ${f.format(priceMin)}',style: pricePromoMin>0 && pricePromoMax>0
                                                  ? textStyleLineThrough()
                                                  :textStyle()):
                                              priceMax > 0 && priceMin > 0?
                                              Text('฿ ${f.format(priceMin)}-${f.format(priceMax)}',
                                                  style: pricePromoMin>0
                                                      ? textStyleLineThrough()
                                                      : textStyle())
                                                  :priceMin == 0? Text('FREE',style:textStyle())

                                                  :Text('฿ ${f.format(priceMin)}',
                                                  style: pricePromoMin>0
                                                      ?textStyleLineThrough()
                                                      :textStyle()
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),

                                  ],
                                )
                            ),
                            //  type == '3' is to show video
                          ),
                        )):type == '3'?
                        InkWell(
                          child: Material(
                              borderRadius: isMe?BorderRadius.only(
                                  topLeft: Radius.circular(30.0),
                                  bottomLeft: Radius.circular(30.0),
                                  bottomRight: Radius.circular(30.0))
                                  : BorderRadius.only(
                                bottomLeft: Radius.circular(30.0),
                                bottomRight: Radius.circular(30.0),
                                topRight: Radius.circular(30.0),
                              ),
                              elevation: 3.0,
                              color: isMe?themeColour : Colors.white,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 10.0),
                                child: Container(
                                    height: MediaQuery.of(context).size.height*1/6,
                                    width: MediaQuery.of(context).size.height*1/5,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20.0),
                                        image: DecorationImage(
                                            fit: BoxFit.cover,image: NetworkImage(message)
                                        )
                                    ),
                                    child: Icon(FontAwesomeIcons.play,color: Colors.grey.shade300,size: 45)
                                ),
                              )),
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>videoPreview(url: url.toString())));
                          },
                        ):
                        InkWell(
                          child: Material(
                              borderRadius: isMe?BorderRadius.only(
                                  topLeft: Radius.circular(30.0),
                                  bottomLeft: Radius.circular(30.0),
                                  bottomRight: Radius.circular(30.0))
                                  : BorderRadius.only(
                                bottomLeft: Radius.circular(30.0),
                                bottomRight: Radius.circular(30.0),
                                topRight: Radius.circular(30.0),
                              ),
                              elevation: 3.0,
                              color: isMe?themeColour : Colors.white,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 10.0),
                                child: Container(
                                  height: MediaQuery.of(context).size.height*1/7,
                                  width: MediaQuery.of(context).size.height*1/6,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.0),
                                      image: DecorationImage(
                                        fit: BoxFit.cover,image: NetworkImage(message),
                                      )
                                  ),
                                ),
                              )),
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>showNetworkImage( image: message)));
                          },
                        ),
                        SizedBox(height: 10),
                        sendingTime(),
                      ],
                    ),
                  ],
                ):Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    peerImg == ""?CircleAvatar(
                      radius: 20.0,
                      child: Icon(FontAwesomeIcons.userAlt,color: Colors.black,),
                      backgroundColor: Colors.transparent,
                    ):CircleAvatar(
                      radius: 20.0,
                      backgroundImage: NetworkImage(peerImg),
                      backgroundColor: Colors.transparent,
                    ),
                    SizedBox(width: 10),
                    Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width*0.5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          type == '0'?Material(
                            borderRadius: isMe?BorderRadius.only(
                                topLeft: Radius.circular(30.0),
                                bottomLeft: Radius.circular(30.0),
                                bottomRight: Radius.circular(30.0))
                                : BorderRadius.only(
                              bottomLeft: Radius.circular(30.0),
                              bottomRight: Radius.circular(30.0),
                              topRight: Radius.circular(30.0),
                            ),
                            elevation: 3.0,
                            color: isMe?themeColour : Colors.white,
                            child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 20.0),
                                child: Text(
                                  message,
                                  maxLines: 20,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: isMe?Colors.white:Colors.black54,
                                      fontSize: 15.0
                                  ),
                                )
                            ),
                          ):type == '2'?Material(
                            borderRadius: isMe?BorderRadius.only(
                                topLeft: Radius.circular(30.0),
                                bottomLeft: Radius.circular(30.0),
                                bottomRight: Radius.circular(30.0))
                                : BorderRadius.only(
                              bottomLeft: Radius.circular(30.0),
                              bottomRight: Radius.circular(30.0),
                              topRight: Radius.circular(30.0),
                            ),
                            elevation: 3.0,
                            color: isMe?themeColour : Colors.white,
                            child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.0,horizontal: 5.0),
                                child: InkWell(
                                  child: Container(
                                    height: MediaQuery.of(context).size.height*1/8,
                                    width: MediaQuery.of(context).size.height*1/7,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20.0),
                                        image: DecorationImage(
                                          fit: BoxFit.cover,image: AssetImage('assets/googlemap.jpg'),
                                        )
                                    ),
                                  ),
                                  onTap: () async{
                                    await canLaunch(message) ? await launch(message): throw 'Could not launch $message';
                                  },
                                )
                            ),
                          ):type == '4'?
                          Container(
                            width: MediaQuery.of(context).size.width/2,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                              color: Colors.white,
                            ),
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child:
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                        padding: const EdgeInsets.only(top: 20.0,left: 10,right: 10,bottom: 10),
                                        child: Image.network(messageImg.toString(),fit: BoxFit.fitHeight,
                                            errorBuilder: (context,exception,stackTrace)
                                            =>Container(
                                              height: 100,
                                              child: Center(child: Text('Image not found')),
                                            )
                                        )
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width/2,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(message,style: TextStyle(fontSize: 14),maxLines: 2),
                                          SizedBox(height: 10),
                                          Column(
                                            children: [
                                              Visibility(
                                                  visible: pricePromoMin>0 && pricePromoMax>0,
                                                  child: Text('฿ ${f.format(pricePromoMin)}-${f.format(pricePromoMax)}',
                                                      style: textStyle())
                                              ),

                                              SizedBox(height: 3),

                                              priceMin>0 && pricePromoMax==0?Text('฿ ${f.format(priceMin)}',style: pricePromoMin>0 && pricePromoMax>0
                                                  ? textStyleLineThrough()
                                                  :textStyle()):
                                              priceMax > 0 && priceMin > 0?
                                              Text('฿ ${f.format(priceMin)}-${f.format(priceMax)}',
                                                  style: pricePromoMin>0
                                                      ? textStyleLineThrough()
                                                      : textStyle())
                                                  :priceMin == 0? Text('FREE',style:textStyle())

                                                  :Text('฿ ${f.format(priceMin)}',
                                                  style: pricePromoMin>0
                                                      ?textStyleLineThrough()
                                                      :textStyle()
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 10)
                                  ],
                                )
                            ),
                          ):type == '3'?
                          InkWell(
                            child: Container(
                                height: MediaQuery.of(context).size.height*1/6,
                                width: MediaQuery.of(context).size.height*1/5,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    image: DecorationImage(
                                        fit: BoxFit.cover,image: NetworkImage(message)
                                    )
                                ),
                                child: Icon(FontAwesomeIcons.play,color: Colors.grey.shade300,size: 30)
                            ),
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>videoPreview(url: url.toString())));
                            },
                          )
                              :InkWell(
                            child: Container(
                              height: MediaQuery.of(context).size.height*1/7,
                              width: MediaQuery.of(context).size.height*1/6,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,image: NetworkImage(message),
                                  )
                              ),
                            ),
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>showNetworkImage(image: message)));
                            },
                          ),
                          SizedBox(height: 10),
                          sendingTime(),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return Text('loading');
      },
    );
  }

  Text sendingTime() {
    return isToday?
    Text("${DateFormat.yMMMd().format(dateTime.toDate())} ${DateFormat.Hm().format(dateTime.toDate())}",style: TextStyle(
        fontSize: 12,
        color: Colors.black54
    ),)
        :
    isYest?Text("Yesterday ${DateFormat.Hm().format(dateTime.toDate())}",style: TextStyle(
        fontSize: 12,
        color: Colors.black54
    ),)
        :Text("${DateFormat.Hm().format(dateTime.toDate())}",style: TextStyle(
        fontSize: 12,
        color: Colors.black54
    ),);
  }

  TextStyle textStyleLineThrough() => TextStyle(fontWeight: FontWeight.bold,color: Colors.grey,fontSize: 13,decoration: TextDecoration.lineThrough);

  TextStyle textStyle() => TextStyle(fontWeight: FontWeight.bold,color: Colors.red,fontSize: 15);
}