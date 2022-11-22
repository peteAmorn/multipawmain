import 'dart:async';
import 'dart:io';
import 'dart:io' show Platform;

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
import 'package:sizer/sizer.dart';
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

var now = DateTime.now();
var lastnight = DateTime(now.year,now.month,now.day);
late bool isRead;
late bool isReadNotice;
bool isTablet = false;

class chatroom extends StatefulWidget {
  final String? userid,peerid,peerImg,userImg,peerName,userName,postid,dtype;
  final bool? sold;
  final int? priceMin,priceMax,pricePromoMin,pricePromoMax,priceSelling;
  chatroom({
    required this.userid,
    required this.peerid,
    required this.peerImg,
    required this.userImg,
    required this.peerName,
    required this.userName,
    this.postid,
    this.priceMin,
    this.priceMax,
    this.pricePromoMin,
    this.pricePromoMax,
    this.priceSelling,
    this.dtype,
    this.sold
  });


  @override
  _chatroomState createState() => _chatroomState();
}

class _chatroomState extends State<chatroom> {
  TextEditingController _controller = TextEditingController();
  String imageId = Uuid().v4();
  dynamic picker = ImagePicker();

  late String groupChatId,imgUrl,topic;
  late bool show;
  late bool isLoading;
  late String _desFile;
  late bool isUploading;
  String a = '';
  File? file,compressedFile;
  vc.MediaInfo? mediaFile;
  double? lat,lng;
  Position? _currentPosition;
  late double pageHeight;
  List<File?> resultList = [];

  handleTakePhoto(File? file) async{
    final XFile pickedFile = await picker.pickImage(
        source: ImageSource.camera,
    );
    setState(() {
      file = File(pickedFile.path);
    });
    int? quality;

    final filePath = file!.absolute.path;
    setState(() {
      isUploading = true;
    });

    final lastIndex = filePath.lastIndexOf('.jp');

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
    setState(() {
      isUploading = false;
    });
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

    final lastIndex;
    filePath.lastIndexOf('.jp') != -1?lastIndex  = filePath.lastIndexOf('.jp'):lastIndex  = filePath.lastIndexOf('.png');
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";


    if( file!.lengthSync()>0 && file!.lengthSync()<=1200000){
      quality = ((20000000)/ file!.lengthSync()).round();
      if(quality<0){
        quality = 100;
      }
    }else if(file!.lengthSync()>1200000){
      quality = 20;
    } else{
      quality = 100;
    }

    File? compressedResult;

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
    final isRead
  }){
    chatsRef.doc(groupChatId).collection(groupChatId).doc(DateTime.now().microsecondsSinceEpoch.toString()).set({
      'type': type,
      'sender': widget.userid,
      'receiver': widget.peerid,
      'message': message,
      'url': url,
      'timestamp': DateTime.now(),
      'isRead' : false
    });

    notiRef.doc().set({
      'userName': widget.userName,
      'peerName': widget.peerName,
      'userId':widget.userid,
      'peerId': widget.peerid,
      'userImg': widget.userImg,
      'peerImg': widget.peerImg,
      'message': message_noti,
      'type': 'chat',
      'timestamp': DateTime.now()
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
            timestamp: now
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
    await usersRef.doc(widget.userid).get().then((snapshot){
      lat = snapshot['lat'];
      lng = snapshot['lng'];

      inChatUpdateInFirestore(
          type: 2,
          message: 'https://www.google.com/maps/search/?api=1&query=${lat},${lng}',
          url: '',
          message_noti: '${widget.userName} ส่งที่อยู่ฟาร์มให้คุณ',
          timestamp: now
      );
      inUserUpdateInFireStore('${widget.userName} ส่งที่อยู่ฟาร์มให้คุณ',2);
      lat = null;
      lng = null;
    });
  }


  selfisReadNoticeUpdate(){
    usersRef.doc(widget.userid).collection('chattingWith').doc(widget.peerid).update(
        {
          'isRead' : false
        });
  }

  inUserUpdateInFireStore(String message,int type)async{
    await chatsRef.doc(groupChatId).collection(groupChatId).where('receiver',isEqualTo: widget.peerid).where('isRead',isEqualTo: false).get()
        .then((snapshot) => {
      if(snapshot.size>0){
        usersRef.doc(widget.userid).collection('chattingWith').doc(widget.peerid).set(
            {
              'profile': widget.peerImg,
              'name': widget.peerName,
              'peerId': widget.peerid,
              'type': type,
              'message': message,
              'timeStamp': DateTime.now(),
              'isRead': false
            }),
        usersRef.doc(widget.peerid).collection('chattingWith').doc(widget.userid).set(
            {
              'profile': widget.userImg,
              'name': widget.userName,
              'peerId': widget.userid,
              'type': type,
              'message': message,
              'timeStamp': DateTime.now(),
              'isRead': true
            })
      }else{
        usersRef.doc(widget.userid).collection('chattingWith').doc(widget.peerid).set(
            {
              'profile': widget.peerImg,
              'name': widget.peerName,
              'peerId': widget.peerid,
              'type': type,
              'message': message,
              'timeStamp': DateTime.now(),
              'isRead': false
            }),
        usersRef.doc(widget.peerid).collection('chattingWith').doc(widget.userid).set(
            {
              'profile': widget.userImg,
              'name': widget.userName,
              'peerId': widget.userid,
              'type': type,
              'message': message,
              'timeStamp': DateTime.now(),
              'isRead': false
            })
      }});


  }

  Future<String> uploadImage(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('imgChat_$imageId.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      inChatUpdateInFirestore(type: 1,message: downloadUrl,url: '',message_noti: 'Sent photo');
      return downloadUrl;
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
    });
  }


  Future<void> addingPeerUserIdToChattingWith()async{
    await usersRef.doc(widget.userid).collection('chattingWith').where('receiver',isEqualTo: widget.peerid).get()
        .then((snapshot) => {
      if(snapshot.size == 0){
        snapshot.docs.forEach((docId){
          usersRef.doc(widget.userid).collection('chattingWith').doc(widget.peerid).set(
              {
                'peerId': widget.peerid
              });
        }),
      }});
  }

  // Sorted from small to large
  getGroupId(){
    if(widget.userid.hashCode <= widget.peerid.hashCode){
      groupChatId = '${widget.userid}-${widget.peerid}';
    }else{
      groupChatId = '${widget.peerid}-${widget.userid}';
    }
    addingPeerUserIdToChattingWith();
  }

  getProfile()async{
    await petsRef.doc(widget.postid).get().then((snapshot){
      if(snapshot.exists){
        imgUrl = snapshot.data()!['coverProfile'] != 'cover'
            ? snapshot.data()!['coverProfile']
            : snapshot.data()!['profile1'] != 'profile1'
            ? snapshot.data()!['profile1']
            : snapshot.data()!['profile2'] != 'profile2'
            ? snapshot.data()!['profile2']
            : snapshot.data()!['profile3'] != 'profile3'
            ? snapshot.data()!['profile3']
            : snapshot.data()!['profile4'] != 'profile4'
            ? snapshot.data()!['profile4']
            : snapshot.data()!['profile5'] != 'profile5'
            ? snapshot.data()!['profile5']
            :'';
        topic = snapshot.data()!['name'];

        chatsRef.doc(groupChatId).collection(groupChatId).doc(DateTime.now().microsecondsSinceEpoch.toString()).set({
          'type': '4',
          'sender': widget.userid,
          'receiver': widget.peerid,
          'image': imgUrl,
          'message': topic,
          'priceMin':widget.priceMin,
          'priceMax':widget.priceMax,

          'pricePromoMin':widget.pricePromoMin,
          'pricePromoMax':widget.pricePromoMax,

          'timestamp': DateTime.now(),
          'isRead' : false
        });

        inUserUpdateInFireStore('สนใจ ${topic} มาเป็น พ่อ/แม่ พันธุ์',4);
      }
    });
  }

  getPost()async{
    try{
      await postsPuppyKittenRef.doc(widget.postid).get().then((snapshot){
        if(snapshot.exists){
          try{
            postsFoodRef.doc(widget.postid).get().then((snapshot){
              imgUrl = snapshot.data()!['coverProfile'] != 'cover'
                  ? snapshot.data()!['coverProfile']
                  : snapshot.data()!['profile1'] != 'profile1'
                  ? snapshot.data()!['profile1']
                  : snapshot.data()!['profile2'] != 'profile2'
                  ? snapshot.data()!['profile2']
                  : snapshot.data()!['profile3'] != 'profile3'
                  ? snapshot.data()!['profile3']
                  : snapshot.data()!['profile4'] != 'profile4'
                  ? snapshot.data()!['profile4']
                  : snapshot.data()!['profile5'] != 'profile5'
                  ? snapshot.data()!['profile5']
                  :'';
              topic = snapshot.data()!['topicName'];


              chatsRef.doc(groupChatId).collection(groupChatId).doc(DateTime.now().microsecondsSinceEpoch.toString()).set({
                'type': '4',
                'sender': widget.userid,
                'receiver': widget.peerid,
                'image': imgUrl,
                'message': topic,
                'priceMin':widget.priceMin,
                'priceMax':widget.priceMax,

                'pricePromoMin':widget.pricePromoMin,
                'pricePromoMax':widget.pricePromoMax,

                'timestamp': DateTime.now(),
                'isRead' : false
              });

              widget.sold == true
                  ? inUserUpdateInFireStore('${widget.userName} ได้ส่งข้อความถึงคุณ',4)
                  :inUserUpdateInFireStore('${widget.userName} สนใจสินค้าของท่าน',4);
            });
          }catch(e){
            print(e);
          }
        }
        imgUrl = imgUrl = snapshot.data()!['coverProfile'] != 'cover'
            ? snapshot.data()!['coverProfile']
            : snapshot.data()!['profile1'] != 'profile1'
            ? snapshot.data()!['profile1']
            : snapshot.data()!['profile2'] != 'profile2'
            ? snapshot.data()!['profile2']
            : snapshot.data()!['profile3'] != 'profile3'
            ? snapshot.data()!['profile3']
            : snapshot.data()!['profile4'] != 'profile4'
            ? snapshot.data()!['profile4']
            : snapshot.data()!['profile5'] != 'profile5'
            ? snapshot.data()!['profile5']
            :'';
        topic = snapshot.data()!['topicName'];

        chatsRef.doc(groupChatId).collection(groupChatId).doc(DateTime.now().microsecondsSinceEpoch.toString()).set({
          'type': '4',
          'sender': widget.userid,
          'receiver': widget.peerid,
          'image': imgUrl,
          'message': topic,
          'priceMin':widget.priceMin,
          'priceMax':widget.priceMax,

          'pricePromoMin':widget.pricePromoMin,
          'pricePromoMax':widget.pricePromoMax,

          'timestamp': DateTime.now(),
          'isRead' : false
        });

        notiRef.doc().set({
          'userName': widget.userName,
          'peerName': widget.peerName,
          'userId':widget.userid,
          'peerId': widget.peerid,
          'userImg': widget.userImg,
          'peerImg': widget.peerImg,
          'message': widget.sold == true
              ?'${widget.userName} ได้ส่งข้อความถึงท่าน'
              :'${widget.userName} สนใจสินค้าของท่าน',
          'type': 'chat',
          'timestamp': DateTime.now()
        });

        widget.sold == true
            ? inUserUpdateInFireStore('${widget.userName} ได้ซื้อสินค้าของท่าน',4)
            :inUserUpdateInFireStore('${widget.userName} สนใจสินค้าของท่าน',4);
      });
    }catch(e){
      print(e);
    }
  }

  @override
  void initState() {
    setState(() {
      show = false;
      isRead = false;
      isLoading = true;
      isUploading = false;
      isReadNotice = false;
      pageHeight = 300;
      getGroupId();
      SizerUtil.deviceType == DeviceType.tablet?isTablet = true:isTablet = false;
    });

    selfisReadNoticeUpdate();
    // TODO: implement initState
    super.initState();
    widget.dtype == 'profile'?getProfile():getPost();

    setState(() {
      isLoading = false;
    });
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
        appBar: appBarWithBackArrow(widget.peerName.toString(),isTablet),
        body: isLoading == true || isUploading == true?loading():Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MessagesStream(groupChatId: groupChatId,userid: widget.userid,isRead: isRead,peerid: widget.peerid,peerImg: widget.peerImg),
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
                                                      fontSize: isTablet?20:16,
                                                      fontWeight: FontWeight.bold,
                                                    )),
                                                    ()async{
                                                      file = await handleTakePhoto(file);
                                                      file = await Navigator.push(context, MaterialPageRoute(builder: (context)=>prevAndUploadForChat(file: file)));
                                                      file == ""? null: await handleSubmit(1);
                                                      await file!.delete();
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
                                                      fontSize: isTablet?20:16,
                                                      fontWeight: FontWeight.bold,
                                                    )),
                                                    ()async{
                                                      file = await handleChooseFromGallery(file);
                                                      file = await Navigator.push(context, MaterialPageRoute(builder: (context)=>prevAndUploadForChat(file: file)));
                                                      file == ""? null: await handleSubmit(1);
                                                      await file!.delete();
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
                                                      fontSize: isTablet?20:16,
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
                                                      fontSize: isTablet?20:16,
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
                                                        fontSize: isTablet?20:16,
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
                                                        fontSize: isTablet?20:16,
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
                                                        fontSize: isTablet?20:16,
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
                                        timestamp: now
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
  MessagesStream({required this.groupChatId, required this.userid, required this.isRead,required this.peerid,required this.peerImg});
  final String? groupChatId, userid, peerid, peerImg;
  final bool isRead;

  @override
  Widget build(BuildContext context) {

    Future<void> readUpdate()async{
      await chatsRef.doc(groupChatId).collection(groupChatId.toString()).where('sender',isEqualTo: peerid).where('isRead',isEqualTo: false).get()
          .then((snapshot) => {
        if(snapshot.size>0){
          snapshot.docs.forEach((docId){
            chatsRef.doc(groupChatId).collection(groupChatId.toString()).doc(docId.id).update(
                {'isRead': true});
          }),
          usersRef.doc(userid).collection('chattingWith').doc(peerid).update(
              {
                'isRead': false
              })
        }
      });
    }


    return StreamBuilder<QuerySnapshot>(
        stream: chatsRef.doc(groupChatId).collection(groupChatId.toString()).snapshots(),
        builder: (BuildContext context,AsyncSnapshot snapshot){
          if(!snapshot.hasData){
            return loading();
          }
          final messages = snapshot.data.docs;
          List<MessageBubble> messagesBubbles = [];
          for(var message in messages){
            final messageText = message.data()['message'];
            final url = message.data()['url'];
            final messageImg = message.data()['image'];
            final priceMin = message.data()['priceMin'];
            final priceMax = message.data()['priceMax'];
            final pricePromoMin = message.data()['pricePromoMin'];
            final pricePromoMax = message.data()['pricePromoMax'];


            final messageSender = message.data()['sender'];
            final messageTime = message.data()['timestamp'];
            final bool isRead = message.data()['isRead'];
            final String type = message.data()['type'].toString();

            final messageBubble = MessageBubble(
                sender: messageSender,
                peerid: peerid.toString(),
                peerImg: peerImg.toString(),
                message: messageText,
                url: url,
                messageImg: messageImg,
                priceMin: priceMin,
                priceMax: priceMax,
                pricePromoMin: pricePromoMin,
                pricePromoMax: pricePromoMax,
                dateTime: messageTime,
                //if not working, change Duration day to 1
                isToday: messageTime.toDate().isBefore(lastnight),
                isYest: messageTime.toDate().isBefore(lastnight.subtract(Duration(days: 1))),
                isMe:  userid == messageSender,
                isRead: isRead,
                type: type
            );


            Future.delayed(const Duration(seconds: 10), () {
              readUpdate();
            });


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
  MessageBubble({required this.sender,required this.peerid,required this.message,this.url,this.messageImg,required this.dateTime,required this.isMe,required this.isToday,required this.isRead,required this.isYest, required this.type,required this.peerImg
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
  late final bool isRead;
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
                    isRead?Text('Read',style: TextStyle(color: Colors.grey,fontSize: isTablet?20:16),): Text(''),
                    SizedBox(width: 10),
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
                                      fontSize: isTablet?20:16
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
                                                height: isTablet?200:100,
                                                child: Center(child: Text('Image not found',style: TextStyle(fontSize: isTablet?20:16),)),
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
                                          Text(message,style: TextStyle(fontSize: isTablet?20:16),maxLines: 2),
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
                                                  :priceMin == 0? Text('ฟรี',style:textStyle())

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
                    peerImg == "" || peerImg == null?CircleAvatar(
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
                                      fontSize: isTablet?20:16
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
                                            height: isTablet?200:100,
                                            child: Center(child: Text('Image not found',style: TextStyle(fontSize: isTablet?20:16),)),
                                          )
                                      )
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width/2,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(message,style: TextStyle(fontSize: isTablet?20:16),maxLines: 2),
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
                                                  :priceMin == 0? Text('ฟรี',style:textStyle())

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
        fontSize: isTablet?16:12,
        color: Colors.black54
    ),)
        :
    isYest?Text("Yesterday ${DateFormat.Hm().format(dateTime.toDate())}",style: TextStyle(
        fontSize: isTablet?16:12,
        color: Colors.black54
    ),)
        :Text("${DateFormat.Hm().format(dateTime.toDate())}",style: TextStyle(
        fontSize: isTablet?16:12,
        color: Colors.black54
    ),);
  }

  TextStyle textStyleLineThrough() => TextStyle(fontWeight: FontWeight.bold,color: Colors.grey,fontSize: isTablet?16:13,decoration: TextDecoration.lineThrough);

  TextStyle textStyle() => TextStyle(fontWeight: FontWeight.bold,color: Colors.red,fontSize: isTablet?20:16);
}


