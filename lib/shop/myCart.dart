import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:multipawmain/authCheck.dart';
import 'package:multipawmain/shop/checkOut.dart';
import 'package:multipawmain/shop/preview/foodPreview.dart';
import 'package:multipawmain/shop/preview/petPreview.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:intl/src/intl/number_format.dart';
import 'package:sizer/sizer.dart';

var f = new NumberFormat("#,###", "en_US");

class myCart extends StatefulWidget {
  final String? userId;

  myCart({required this.userId});

  @override
  _myCartState createState() => _myCartState();
}

class _myCartState extends State<myCart> {
  bool isLoading = false;
  int? total;
  String? userName;
  bool isTablet = false;
  List<int> lst = [];

  getUserName()async{
    await usersRef.doc(widget.userId).get().then((snapshot){
      userName = snapshot.data()!['name'];
    });
  }

  checkIfItemStillExist()async{
    await usersRef.doc(widget.userId).collection('myCart').get().then((snapshot){
      snapshot.docs.forEach((doc) {
        usersRef.doc(widget.userId).collection('myCart').doc(doc.id).get().then((snap){
          if(snap.data()!['type'] == 'pet'){
            postsPuppyKittenRef.doc(snap.data()!['postid']).get().then((fetch){
              if(!fetch.exists){
                usersRef.doc(widget.userId).collection('myCart').doc(doc.id).delete();
              }
            });
          }else{
            postsFoodRef.doc(snap.data()!['postid']).get().then((fetch){
              if(!fetch.exists){
                usersRef.doc(widget.userId).collection('myCart').doc(doc.id).delete();
              }
            });
          }
        });
      });
    });
  }

  getTotal()async{
    await usersRef.doc(widget.userId).collection('myCart').where('check',isEqualTo: true).get().then((snap){
      snap.size == 0? total = 0: snap.docs.forEach((data){
        if(data.data()['promo'] == 0){
          int subTotal = data.data()['price'] * data.data()['quantity'];
          lst.add(subTotal);
        }else{
          int subTotal = data.data()['promo'] * data.data()['quantity'];
          lst.add(subTotal);
        }

      });});
    if(lst.length!=0){
      setState(() {
        total = lst.reduce((a, b) => a+b);
      });
    }else{
      setState(() {
        total = 0;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      isLoading = true;
      SizerUtil.deviceType == DeviceType.tablet?isTablet = true:isTablet = false;
    });

    getUserName();
    getTotal();
    checkIfItemStillExist();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder(
        stream: usersRef.doc(widget.userId).collection('myCart').orderBy('timestamp',descending: true).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
          if(!snapshot.hasData)
          {
            return loading();
          }
          var dataSize = snapshot.data!.docs.where((data) => data['check'] == true);


          return Scaffold(
            backgroundColor: Colors.grey.shade100,
            appBar: AppBar(
                centerTitle: true,
                backgroundColor: themeColour,
                leading: IconButton(onPressed: ()=>Navigator.pop(context), icon: Icon(Icons.arrow_back_ios)),
                title: Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text('รถเข็น',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet == true?25:18)
                  ),
                )),
            body: isLoading == true?loading():Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: ListView(
                    children: snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: data['type']=='Dog Food' || data['type']=='Cat Food'?buildInkWellPetFood(
                            data['postid'],
                            data['postid_cart'],
                            data['check'],
                            data['imageUrl'],
                            data['topicName'],
                            data['weight'],
                            data['price'],
                            data['promo'],
                            data['quantity'],
                            data['stock'],
                            data['type']
                        ):buildInkWellPet(
                            data['id'],
                            data['postid'],
                            data['check'],
                            data['imageUrl'],
                            data['topicName'],
                            data['price'],
                            data['quantity'],
                            data['stock'],
                            data['type'],
                            data['isOwner']
                        ),
                      );}).toList()
                )
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              height: isTablet == true?100:80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('ยอดรวม: ',style: TextStyle(fontSize: isTablet == true?25:16)),
                  total == null?Text(''):Text('฿ ${f.format(total)}',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red.shade900,fontSize: isTablet == true?25:18)),
                  Padding(
                    padding:  EdgeInsets.symmetric(vertical: 10.0,horizontal: isTablet == true?20:10),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        color: dataSize.length == 0? Colors.grey:Colors.red.shade900,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: isTablet == true?50:15.0),
                        child: dataSize.length == 0?
                        Text("ชำระเงิน", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: isTablet == true?25:15)):
                        InkWell(
                            child: Text("ชำระเงิน", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: isTablet == true?25:15)),
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>checkOut(userId: widget.userId.toString(),fromPage: 'fromCart',userName: userName.toString())));
                          }
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  InkWell buildInkWellPetFood(
      String postid,
      String postid_cart,
      bool check,
      String imgUrl,
      String topicName,
      double weight,
      int price,
      int pricePromo,
      int qty,
      int stock,
      String postType
      ) {
    return InkWell(
      child: Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.15,
        child: Container(
          color: Colors.white,
          height: isTablet == true?150:110,
          child: ListTile(
            leading: Checkbox(
              checkColor: Colors.white,
              activeColor: themeColour,
              value: check,
              onChanged: (value)async{
                if(check == false){
                  await usersRef.doc(widget.userId).collection('myCart').doc(postid_cart).update({
                    'check':true,
                  });
                  lst.clear();
                  getTotal();

                }else{
                  await usersRef.doc(widget.userId).collection('myCart').doc(postid_cart).update({'check':false});
                  lst.clear();
                  getTotal();
                }
              },
            ),
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                    height: isTablet == true?120:80,
                    width: isTablet == true?80:50,
                    child: Image.network(imgUrl,fit: BoxFit.fitHeight)),
                Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width*0.4,
                          child: Padding(
                            padding: EdgeInsets.only(top: isTablet == true?10:0),
                            child: Text('${topicName} ${weight.toString()} kg',maxLines: 2,style: TextStyle(fontSize: isTablet == true?20:13)),
                          )),
                      Row(
                        children: [
                          Text('฿ ${f.format(price)}',style: pricePromo == 0?TextStyle(color: themeColour,fontWeight: FontWeight.bold):TextStyle(color: Colors.grey,decoration: TextDecoration.lineThrough,fontSize: isTablet == true?20:14)),
                          SizedBox(width: 5),
                          Visibility(
                              visible: pricePromo !=0,
                              child: Text('฿ ${f.format(pricePromo)}',style:TextStyle(color: themeColour,fontWeight: FontWeight.bold,fontSize: isTablet == true?23:16)))
                        ],
                      ),
                      Row(
                        children: [
                          InkWell(
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300)
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 3,vertical: 2),
                                child: Icon(Icons.remove,color: Colors.grey.shade600,size: isTablet == true?25:18),
                              ),
                            ),
                            onTap: ()async{
                              qty>1?await usersRef.doc(widget.userId).collection('myCart').doc(postid_cart).update({
                                'quantity':qty-1,
                                'subTotal': pricePromo == 0? price * (qty-1): pricePromo * (qty-1)
                              }):null;
                              lst.clear();
                              getTotal();

                            },
                          ),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300)
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 2),
                                child: Text(qty.toString(),style: TextStyle(fontSize: isTablet == true?17:12)),
                              ),
                            ),
                          ),
                          InkWell(
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300)
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 3,vertical: 2),
                                child: Icon(Icons.add,color: Colors.grey.shade600,size: isTablet == true?25:18),
                              ),
                            ),
                            onTap: ()async{
                              await usersRef.doc(widget.userId).collection('myCart').doc(postid_cart).update({
                                'quantity':qty<stock?qty+1:qty,
                                'subTotal': pricePromo == 0? price * (qty+1): pricePromo * (qty+1)
                              });
                              lst.clear();
                              getTotal();
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 5)
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        secondaryActions: [
          IconSlideAction(
            caption: 'ลบ',
            color: Colors.red.shade900,
            icon: LineAwesomeIcons.trash,
            onTap: ()async{
              await usersRef.doc(widget.userId).collection('myCart').doc(postid_cart).delete();
              showAlertDialog(context);
              lst.clear();
              getTotal();
            },
          )
        ],
      ),
      onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>foodPreview(postId: postid, userId: widget.userId,postType: postType))),
    );
  }

  InkWell buildInkWellPet(
      String ownerId,
      String postid,
      bool check,
      String imgUrl,
      String topicName,
      int price,
      int qty,
      int stock,
      String postType,
      bool isOwner
      ) {
    return InkWell(
      child: Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.15,
        child: Container(
          color: Colors.white,
          height: isTablet == true?150:110,
          child: Center(
            child: ListTile(
              leading: Checkbox(
                checkColor: Colors.white,
                activeColor: themeColour,
                value: check,
                onChanged: (value)async{
                  if(check == false){
                    await usersRef.doc(widget.userId).collection('myCart').doc(postid).update({
                      'check':true,
                    });
                    lst.clear();
                    getTotal();

                  }else{
                    await usersRef.doc(widget.userId).collection('myCart').doc(postid).update({'check':false});
                    lst.clear();
                    getTotal();
                  }
                },
              ),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      height: isTablet == true?120:80,
                      width: isTablet == true?80:50,
                      child: Image.network(imgUrl,fit: BoxFit.fitHeight)),
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            width: MediaQuery.of(context).size.width*0.4,
                            child: Padding(
                              padding: EdgeInsets.only(top: isTablet == true?10:0),
                              child: Text('${topicName}',maxLines: 2,style: TextStyle(fontSize: isTablet == true?20:13)),
                            )),
                        Row(
                          children: [
                            Text('฿ ${f.format(price)}',style: TextStyle(color: themeColour,fontWeight: FontWeight.bold,fontSize: isTablet?23:16)),
                            SizedBox(width: 5),
                          ],
                        ),
                        Row(
                          children: [
                            InkWell(
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300)
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 3,vertical: 2),
                                  child: Icon(Icons.remove,color: Colors.grey.shade600,size: isTablet == true?25:18),
                                ),
                              ),
                              onTap: (){},
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300)
                              ),
                              child: Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 2),
                                  child: Text(qty.toString(),style: TextStyle(fontSize: isTablet == true?17:12)),
                                ),
                              ),
                            ),
                            InkWell(
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300)
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 3,vertical: 2),
                                  child: Icon(Icons.add,color: Colors.grey.shade600,size: isTablet == true?25:18),
                                ),
                              ),
                              onTap: (){},
                            ),
                          ],
                        ),
                        SizedBox(height: 5)
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        secondaryActions: [
          IconSlideAction(
            caption: 'ลบ',
            color: Colors.red.shade900,
            icon: LineAwesomeIcons.trash,
            onTap: ()async{
              await usersRef.doc(widget.userId).collection('myCart').doc(postid).delete();
              showAlertDialog(context);
              lst.clear();
              getTotal();
            },
          )
        ],
      ),
      onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>
          petPreview(
              postId: postid,
              ownerId: ownerId,
              userId: widget.userId,
              isOwner: isOwner
          )
      )),
    );
  }

  showAlertDialog(BuildContext context) {

    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.transparent,
      title: Center(
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              color: Colors.white
          ),
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(FontAwesomeIcons.trash,color: themeColour,size: 40),
                  SizedBox(height: 20),
                  Text("ลบรายการเรียบร้อย",style: TextStyle(color: Colors.red.shade900,fontSize: 15)),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future.delayed(Duration(milliseconds: 500),()=> Navigator.of(context).pop());
        return alert;
      },
    );
  }
}

