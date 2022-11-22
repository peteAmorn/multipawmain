import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:multipawmain/database/posts.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:multipawmain/support/showNetworkImage.dart';
import 'package:sizer/sizer.dart';
import '../authCheck.dart';
import '../ratingAndReviewEdit.dart';

class showComments extends StatefulWidget {
  final ownerId, coverProfile,topic, userId;
  String type;
  showComments({required this.ownerId, required this.type,required this.coverProfile,required this.topic, required this.userId});

  @override
  _showCommentsState createState() => _showCommentsState();
}

class _showCommentsState extends State<showComments> {
  List<reviewDetail> commentList = [];
  bool isLoading = false;
  String? searchingType;
  int? _select;
  bool isTablet = false;

  getComment()async{
    setState(() {
      isLoading = true;
    });
    if(widget.type == 'Cat Food' || widget.type == 'Dog Food'){
      searchingType = 'food';
    }else if(widget.type == 'สุนัข' || widget.type == 'แมว'){
      searchingType = 'pet';
    }

    Query q = commentsRef.where('sellerId',isEqualTo: widget.ownerId).where('type',isEqualTo: searchingType).limit(100);
    QuerySnapshot querySnapshot = await q.get();
    querySnapshot.docs.forEach((doc) {commentList.add(reviewDetail.fromDocument(doc));});
    commentList.sort((a,b)=>a.timestamp.compareTo(b.timestamp));
    commentList.reversed;
    setState(() {
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
    getComment();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: appBarWithBackArrow('รีวิวสินค้า',isTablet),
      body: isLoading == true?loading():ListView.builder(
          itemCount: commentList.length,
          itemBuilder: (context,i){

            var now = DateTime.now();
            var lastnight = DateTime(now.year,now.month,now.day);
            final DateFormat formatter = DateFormat('dd-MMM-yyyy');

            return Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        radius: isTablet?30:20,
                        backgroundColor: themeColour,
                        backgroundImage: NetworkImage(commentList.reversed.elementAt(i).buyerImgUrl),
                      ),
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(commentList.reversed.elementAt(i).buyerName,style: TextStyle(fontSize: isTablet?20:16),),
                                  Text(commentList.reversed.elementAt(i).breed.toString(),style: TextStyle(color: Colors.grey.shade600,fontSize: isTablet?18:14)),
                                  SizedBox(height: 10)
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  RatingBarIndicator(
                                    rating: commentList.reversed.elementAt(i).score,
                                    itemCount: 5,
                                    itemSize: isTablet?24:16.0,
                                    itemBuilder: (context,_)=>Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  commentList.reversed.elementAt(i).timestamp.toDate().isBefore(lastnight)
                                      ?Row(
                                    children: [
                                      Text(formatter.format(commentList.reversed.elementAt(i).timestamp.toDate()),style: buildTextStyleDateTime()),
                                      SizedBox(width: 5),
                                      Text(DateFormat.Hm().format(commentList.reversed.elementAt(i).timestamp.toDate()),style: buildTextStyleDateTime())
                                    ],
                                  ):Row(
                                    children: [
                                      Text('Today',style: buildTextStyleDateTime()),
                                      SizedBox(width: 5),
                                      Text(DateFormat.Hm().format(commentList.reversed.elementAt(i).timestamp.toDate()),style: buildTextStyleDateTime())
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(commentList.reversed.elementAt(i).comment,style: TextStyle(fontSize: isTablet?20:16)),
                          Row(
                            children: [
                              commentList.reversed.elementAt(i).reviewImg01 == 'reviewImage1'? SizedBox():imageContainer(i,commentList.reversed.elementAt(i).reviewImg01.toString()),
                              commentList.reversed.elementAt(i).reviewImg02 == 'reviewImage2'? SizedBox():imageContainer(i,commentList.reversed.elementAt(i).reviewImg02.toString()),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              widget.userId == commentList.reversed.elementAt(i).buyerId
                                  ?InkWell(child: Row(
                                children: [
                                  Icon(LineAwesomeIcons.tools,color: Colors.grey.shade600,size: isTablet?22:18.0,),
                                  SizedBox(width: 5),
                                  Text('แก้ไข',style: TextStyle(color: Colors.grey.shade600,fontSize: isTablet?16:12))
                                ],
                              ),onTap:(){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                    rateAndReviewEdit(
                                      commentId: commentList.reversed.elementAt(i).commentId,
                                      imageUrl: widget.coverProfile,
                                      topic: widget.topic,
                                      breed: commentList.reversed.elementAt(i).breed,
                                      score: commentList.reversed.elementAt(i).score,
                                      reviewImage01: commentList.reversed.elementAt(i).reviewImg01,
                                      reviewImage02: commentList.reversed.elementAt(i).reviewImg02,
                                      comment: commentList.reversed.elementAt(i).comment,
                                    ))).then((data){
                                      commentList.clear();
                                      getComment();
                                });
                              }
                              )
                                  :SizedBox()
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Divider(color: Colors.grey.shade500),
                    )
                  ],
                ),
              ),
            );
          }
      )
    );
  }

  Padding buildPaddingFilterAll() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.grey.shade200
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('ทั้งหมด',style: TextStyle(fontSize: isTablet?20:16),),
        ),
      ),
    );
  }

  Padding buildPaddingFilter(double score,int itemCount) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        alignment: Alignment.center,
        height: 40,
        width: 65,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.grey.shade200
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: RatingBarIndicator(
            rating: score,
            itemCount: itemCount,
            itemSize: 10,
            itemBuilder: (context,_)=>Icon(
              Icons.star,
              color: Colors.amber,
            ),
          ),
        ),
      ),
    );
  }

  TextStyle buildTextStyleDateTime() => TextStyle(fontSize: isTablet?16:10,color: Colors.grey.shade600);

  Padding imageContainer(int i,String imgUrl) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0,top: 10),
      child: InkWell(
        child: Container(
            height: isTablet?150:80,
            width: isTablet?150:80,
            child: Image.network(imgUrl,fit: BoxFit.fitHeight,)
        ),
        onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>showNetworkImage(image: imgUrl))),
      ),
    );
  }
}
