import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:multipawmain/authCheck.dart';
import 'package:multipawmain/chat/chatroom.dart';
import 'package:multipawmain/support/constants.dart';
import 'dart:io';

import 'package:multipawmain/support/handleGettingImage.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:uuid/uuid.dart';
import 'database/petlist.dart';

final DateTime timestamp = DateTime.now();

class rateAndReview extends StatefulWidget {
  final imgUrl,topic,breed,sellerId,userId,userName,buyerImageUrl,ticket_postId,type,weight;
  rateAndReview({
    required this.imgUrl,
    required this.topic,
    required this.breed,
    required this.sellerId,
    required this.ticket_postId,
    required this.userId,
    required this.userName,
    required this.buyerImageUrl,
    required this.type,
    required this.weight,
  });

  @override
  _rateAndReviewState createState() => _rateAndReviewState();
}

class _rateAndReviewState extends State<rateAndReview> {
  List<dataList> imgList = [];
  bool isUploading = false;
  double score = 5;
  String status = 'พอใจมาก';
  Color color = Colors.green.shade600;
  File? reviewFile1, reviewFile2;
  String reviewImg1 = 'reviewImage1';
  String reviewImg2 = 'reviewImage2';
  String postId = Uuid().v4();

  final TextEditingController _controller = TextEditingController();

  clearImage(File? file) {
    if (file == null) return;
    File? tmp_file = File(file.path);
    tmp_file = null;

    setState(() {
      file = tmp_file;
    });
    return tmp_file;
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
            if(img == 'reviewImage1'){
              reviewFile1 = await Navigator.push(context, MaterialPageRoute(builder: (context)=>handleGettingImage(file: file)));
              imgList.add(dataList(name: 'profile1', info: reviewFile1));

            }else if(img == 'reviewImage2'){
              reviewFile2 = await Navigator.push(context, MaterialPageRoute(builder: (context)=>handleGettingImage(file: file)));
              imgList.add(dataList(name: 'profile2', info: reviewFile2));
            }
            setState(() {

            });
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
                          if(img == reviewImg1){
                            reviewImg1 = 'reviewImage1';
                            reviewFile1 = clearImage(file);

                          }else if(img == reviewImg2){
                            reviewImg2 = 'reviewImage2';
                            reviewFile2 = clearImage(file);
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
                            if(file == reviewFile1){
                              reviewFile1 = clearImage(file);

                            }else if(file == reviewFile2){
                              reviewFile2 = clearImage(file);
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

  Future<String> uploadImageReview01(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('reviewImage01_$postId.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }return 'a';
  }

  Future<String> uploadImageReview02(imgFile) async{
    try{
      UploadTask uploadTask = storageRef.child('reviewImage02_$postId.jpg').putFile(imgFile);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }
    return 'a';
  }

  OrderReviewToComplete(
      String ticket_postId,peerId
      )async{

    await buyerOnReviewRef.doc(ticket_postId).get().then((snapshot){
      buyerOnCompleteRef.doc(ticket_postId).set({
        'type': snapshot.data()!['type'],
        'seller': snapshot.data()!['seller'],
        'sellerId': peerId,
        'userId': widget.userId,
        'userName': widget.userName,
        'topic': snapshot.data()!['topic'],
        'breed': snapshot.data()!['breed'],
        'weight': snapshot.data()!['weight'],
        'image': snapshot.data()!['image'],
        'price': snapshot.data()!['price'],
        'promo': snapshot.data()!['promo'],
        'quantity':snapshot.data()!['quantity'],
        'deliPrice': snapshot.data()!['deliPrice'],
        'discount': snapshot.data()!['discount'],
        'total': snapshot.data()!['total'],
        'postId': snapshot.data()!['postId'],
        'ticket_postId': ticket_postId,
        'delivery_method': snapshot.data()!['delivery_method'],
        'status': 'สำเร็จ',
        'airline': snapshot.data()!['airline'],
        'flightNumber': snapshot.data()!['flightNumber'],

        'Timestamp_guarantee_ticket_start_time': snapshot.data()!['Timestamp_guarantee_ticket_start_time'],
        'Timestamp_received_ticket_time':snapshot.data()!['Timestamp_received_ticket_time'],
        'Timestamp_dispatched_time':snapshot.data()!['Timestamp_dispatched_time'],
        'Timestamp_completed' : now,
      });
      buyerOnReviewRef.doc(ticket_postId).delete();
    });
  }

  handleSubmit() async{
    setState((){
      isUploading = true;
      isUploading== true? loading(): null;
    });

    reviewFile1 == null?null: reviewImg1 = await uploadImageReview01(imgList[0].info);
    reviewFile2 == null?null: reviewImg2 = await uploadImageReview02(imgList[1].info);


    await commentsRef.doc(postId).set(
        {
          'buyerName': widget.userName,
          'buyerProfile': widget.buyerImageUrl,
          'buyerId': widget.userId,
          'sellerId': widget.sellerId,
          'score': score,
          'reviewImg01': reviewImg1,
          'reviewImg02': reviewImg2,
          'comment': _controller.text,
          'timestamp': timestamp,
          'commentId': postId,
          'breed': widget.breed,
          'type': widget.type,
          'weight': widget.weight,
        });

    await usersRef.doc(widget.userId).collection('commentsIDStorage').doc(postId).set(
        {
          'commentId': postId,
          'timestamp': timestamp
        });

    await OrderReviewToComplete(widget.ticket_postId,widget.sellerId);

    reviewFile1 != null?await reviewFile1!.delete():null;
    reviewFile2 != null?await reviewFile2!.delete():null;

    setState(() {
      isUploading = false;
      isUploading== true? loading(): null;
    });
    Navigator.pop(context,true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: themeColour,
          title: Text('รีวิวสินค้า',style: TextStyle(color: Colors.white,fontSize: 18)),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: InkWell(
                    child: Text('เสร็จสิ้น',style: TextStyle(color: Colors.white)),
                  onTap: ()=> handleSubmit(),
                ),
              ),
            )
          ],
        ),
        body: isUploading == true? loading():Container(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10.0),
            child: InkWell(
              onTap: (){
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: ListView(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                            child: Image.network(widget.imgUrl,fit: BoxFit.fitHeight)
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.topic,style: TextStyle(color: Colors.black),maxLines: 2),
                              SizedBox(height: 3),
                              Text(widget.breed,style: TextStyle(color: Colors.grey.shade600),maxLines: 2)
                            ],
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0,bottom: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(color:Colors.grey.shade600),
                          Text('ประเมินความพึงพอใจ')
                        ],
                      ),
                    ),
                    Center(
                      child: RatingBar.builder(
                          initialRating: 5,
                          itemCount: 5,
                          itemSize: 45,
                          allowHalfRating: false,
                          itemPadding: EdgeInsets.symmetric(horizontal: 6),
                          itemBuilder: (context, index) {
                            switch (index) {
                              case 0:
                                return Icon(
                                  Icons.sentiment_very_dissatisfied_outlined ,
                                  color: Colors.red.shade600,
                                );
                              case 1:
                                return Icon(
                                  Icons.sentiment_very_dissatisfied,
                                  color: Colors.redAccent,
                                );
                              case 2:
                                return Icon(
                                  Icons.sentiment_neutral,
                                  color: Colors.amber,
                                );
                              case 3:
                                return Icon(
                                  Icons.sentiment_satisfied_rounded ,
                                  color: Colors.lightGreen.shade600,
                                );
                              case 4:
                                return Icon(
                                  Icons.sentiment_very_satisfied,
                                  color: Colors.green.shade600,
                                );
                            }return Text('');
                          },
                          onRatingUpdate: (rating) {
                            score = rating;
                            setState(() {
                              score == 1.0?status = 'ไม่พอใจมาก':
                              score == 2.0? status = 'ไม่พอใจ':
                              score == 3.0 ? status = 'ปานกลาง':
                              score == 4.0 ? status = 'พอใจ':
                              status = 'พอใจมาก';

                              score == 1.0?color = Colors.red.shade900:
                              score == 2.0?color = Colors.redAccent:
                              score == 3.0?color = Colors.amber.shade700:
                              score == 4.0?color = Colors.lightGreen.shade800:
                              color = Colors.green.shade900;
                            });
                          }
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(status,style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          color: color
                        )),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0,bottom: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(color:Colors.grey.shade600),
                          Text('รูปประกอบการรีวิว')
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(),
                        buildUploadImgProfile(context, reviewImg1, reviewFile1, reviewImg1),
                        buildUploadImgProfile(context, reviewImg2, reviewFile2, reviewImg2),
                        SizedBox(),
                      ],
                    ),
                    SizedBox(height: 30),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: TextFormField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          filled: true,
                            fillColor: Colors.red.shade50,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                          focusedBorder:  OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)
                          ),
                          border: OutlineInputBorder(),
                            hintText: 'รีวิวสินค้าที่นี่',
                            hintStyle: TextStyle(color: Colors.grey.shade600,fontSize: 13),
                            contentPadding: EdgeInsets.all(15.0),
                        ),
                      ),
                    )
                  ]
              ),
            ),
          ),
        ));
  }
}
