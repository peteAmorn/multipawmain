import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/support/methods.dart';
import 'dart:io';
import 'authCheck.dart';
import 'database/breedDatabase.dart';
import 'package:firebase_storage/firebase_storage.dart';

class accountDelete extends StatefulWidget {
  final String userId,name;
  accountDelete({required this.userId,required this.name});

  @override
  _accountDeleteState createState() => _accountDeleteState();
}

class _accountDeleteState extends State<accountDelete> {
  String selectReason = '';
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Scaffold(
        backgroundColor: Colors.grey.shade300,
        appBar: AppBar(
          backgroundColor: themeColour,
          title: Text('ลบบัญชี',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
          leading: InkWell(
            child: Icon(Icons.arrow_back_ios,color: Colors.white),
            onTap: (){
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              color: Colors.white
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                    child: Text('สวัสดี, คุณ ${widget.name}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
                  ),
                  buildDivider(),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                    child: Text('พวกเรารู้สึกเสียใจมากที่ได้รู้ว่าคุณต้องการลบบัญชี\nก่อนลบบัญชีขอความกรุณาแจ้งเหตุผลในการลบบัญชี'),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10,left: 20,right: 20),
                    child: Text('เหตุผลในการลบบัญชี',style: TextStyle(fontWeight: FontWeight.bold,color: themeColour)),
                  ),
                  buildRowField('', selectReason, ()async{
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (context)=>deleteAccountOption()));
                    setState(() {
                      selectReason = result;
                    });
                  }),

                  selectReason == 'เหตุผลอื่น'
                      ?Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextFormField(
                      controller: _controller,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'กรุณาระบุเหตุผล',
                      ),
                    ),
                      ):SizedBox(),
                  buildDivider(),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20,horizontal: 20),
                    child: Text('หากคุณกดปุ่ม "ลบบัญชีถาวร" รูปภาพ และข้อมูลทั้งหมดจะถูกลบ หากคุณต้องการกลับมาใช้งาน MultiPaws ในอนาคต คุณจะไม่สามารถเข้าระบบด้วยบัญชีเดิมได้',
                    style: TextStyle(color: themeColour)),
                  ),
                  selectReason == '' || selectReason == 'เหตุผลอื่น' && _controller.text == ''
                      ?Container(
                    decoration: BoxDecoration(
                        color: Colors.grey
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Text('ลบบัญชีถาวร',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ) :InkWell(
                    child: Container(
                      decoration: BoxDecoration(
                        color: themeColour
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Text('ลบบัญชีถาวร',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    onTap: ()=>deleteAlertDialog(context, widget.userId,selectReason,_controller.text),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding buildRowField(String topic, String? name,Function() ontap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(topic,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
          InkWell(
            child: Container(
                width: MediaQuery.of(context).size.width,
                child: name==null?
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${topic}',style: TextStyle(color: Colors.grey.shade600,fontSize: 16),),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Divider(color: Colors.black,height:2),
                    )
                  ],
                ):Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,style: TextStyle(color: Colors.black,fontSize: 16),),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Divider(color: Colors.black,height:2),
                    )
                  ],
                )
            ),
            onTap: ontap,
          ),
          SizedBox(height: 10)
        ],
      ),
    );
  }
}

class deleteAccountOption extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithOutBackArrow('เหตุผลในการลบแอป',false),
      body: ListView.builder(
        itemCount: deleteAccountList.length,
        itemBuilder: (context,i){
          return InkWell(
            child: Card(
              child: ListTile(
                title: Text(deleteAccountList[i],style: TextStyle(fontSize: 16)),
              ),
            ),
            onTap: ()=> Navigator.pop(context,deleteAccountList[i]),
          );
        },
      ),
    );
  }
}

Future<dynamic> deleteAlertDialog(BuildContext context, String userId,String selectedReason,String other) {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  return showDialog(
      context: context,
      builder: (BuildContext context) =>
      Platform.isIOS ?
      CupertinoAlertDialog(
        title: Text('คุณต้องการลบบัญชี ใช่หรือไม่?',style: TextStyle(fontSize:16)),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text('ยกเลิก',style: TextStyle(color: Colors.green.shade800,fontSize: 16)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            child: Text('ยืนยัน',style: TextStyle(color: Colors.red,fontSize: 16),),
            onPressed: () async
            {
              await accountDeleteRef.doc(userId).set({
                'reason': selectedReason,
                'other': other
              });

              petsRef.where('id',isEqualTo: userId).get().then((doc){
                if(doc.size !=0){
                  doc.docs.forEach((snapshot) {
                    String breed = snapshot.data()['breed'];
                    String postId = snapshot.data()['postid'];

                    String coverPed_url = snapshot.data()['coverPedigree'];
                    String coverFam_url = snapshot.data()['familyTreePedigree'];

                    String cover_url = snapshot.data()['coverProfile'];
                    String profile1_url = snapshot.data()['profile1'];
                    String profile2_url = snapshot.data()['profile2'];
                    String profile3_url = snapshot.data()['profile3'];
                    String profile4_url = snapshot.data()['profile4'];
                    String profile5_url = snapshot.data()['profile5'];

                    petsIndexRef.doc(breed).collection(breed).doc(postId).delete();

                    try{
                      coverPed_url != 'coverPed'?FirebaseStorage.instance.refFromURL(coverPed_url).delete():null;
                      coverFam_url != 'familyTree'?FirebaseStorage.instance.refFromURL(coverFam_url).delete():null;

                      cover_url != 'cover'?FirebaseStorage.instance.refFromURL(cover_url).delete():null;
                      profile1_url != 'profile1'?FirebaseStorage.instance.refFromURL(profile1_url).delete():null;
                      profile2_url != 'profile2'?FirebaseStorage.instance.refFromURL(profile2_url).delete():null;
                      profile3_url != 'profile3'?FirebaseStorage.instance.refFromURL(profile3_url).delete():null;
                      profile4_url != 'profile4'?FirebaseStorage.instance.refFromURL(profile4_url).delete():null;
                      profile5_url != 'profile5'?FirebaseStorage.instance.refFromURL(profile5_url).delete():null;
                    }catch(e){}
                    petsRef.doc(postId).delete();
                  });
                }
                
                postsPuppyKittenRef.where('id',isEqualTo: userId).get().then((doc){
                  doc.docs.forEach((snapshot){
                    String breed = snapshot.data()['breed'];
                    String postId = snapshot.data()['postid'];
                    String profile1 = snapshot.data()['profile1'];
                    String profile2 = snapshot.data()['profile2'];
                    String profile3 = snapshot.data()['profile3'];
                    String profile4 = snapshot.data()['profile4'];
                    String profile5 = snapshot.data()['profile5'];
                    String dad = snapshot.data()['dadImg'];
                    String mum = snapshot.data()['mumImg'];

                    dad == 'dad'? null:FirebaseStorage.instance.refFromURL(dad).delete();
                    mum == 'mum'? null:FirebaseStorage.instance.refFromURL(mum).delete();

                    profile1 == 'profile1'? null : FirebaseStorage.instance.refFromURL(profile1).delete();
                    profile2 == 'profile2'? null : FirebaseStorage.instance.refFromURL(profile2).delete();
                    profile3 == 'profile3'? null : FirebaseStorage.instance.refFromURL(profile3).delete();
                    profile4 == 'profile4'? null : FirebaseStorage.instance.refFromURL(profile4).delete();
                    profile5 == 'profile5'? null : FirebaseStorage.instance.refFromURL(profile5).delete();

                    postsPuppyKittenIndexRef.doc(breed).collection(breed).doc(postId).delete();
                    postsPuppyKittenRef.doc(snapshot.id).delete();
                  });
                });
                
                usersRef.doc(userId).collection('token').get().then((doc){
                  doc.docs.forEach((snap) {
                    usersRef.doc(userId).collection('token').doc(snap.id).delete();
                  });
                });
                usersRef.doc(userId).delete();

                try{
                  googleSignIn.signOut();
                  _auth.signOut();
                }catch(e){}

                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>home()));
              });
            }
          )
        ],
      ) :
      AlertDialog(
        backgroundColor: Colors.grey.shade100,
        content: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.blue.shade50,
          ),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Text('คุณต้องการลบบัญชี\nใช่หรือไม่ ?',style: TextStyle(color: Colors.black,fontSize: 16)),
          ),
        ),
        actions: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: [
                SizedBox(width: 20),
                Expanded(
                  flex: 1,
                  child: InkWell(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.green,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Center(child: Text('ยืนยัน',style: TextStyle(color: Colors.white,fontSize: 16),)),
                      ),
                    ),
                    onTap: ()async
                    {
                      await accountDeleteRef.doc(userId).set({
                        'reason': selectedReason,
                        'other': other
                      });

                      petsRef.where('id',isEqualTo: userId).get().then((doc){
                        if(doc.size !=0){


                        doc.docs.forEach((snapshot) {
                          String breed = snapshot.data()['breed'];
                          String postId = snapshot.data()['postid'];

                          String coverPed_url = snapshot.data()['coverPedigree'];
                          String coverFam_url = snapshot.data()['familyTreePedigree'];

                          String cover_url = snapshot.data()['coverProfile'];
                          String profile1_url = snapshot.data()['profile1'];
                          String profile2_url = snapshot.data()['profile2'];
                          String profile3_url = snapshot.data()['profile3'];
                          String profile4_url = snapshot.data()['profile4'];
                          String profile5_url = snapshot.data()['profile5'];

                          petsIndexRef.doc(breed).collection(breed).doc(postId).delete();

                          try{
                            coverPed_url != 'coverPed'?FirebaseStorage.instance.refFromURL(coverPed_url).delete():null;
                            coverFam_url != 'familyTree'?FirebaseStorage.instance.refFromURL(coverFam_url).delete():null;

                            cover_url != 'cover'?FirebaseStorage.instance.refFromURL(cover_url).delete():null;
                            profile1_url != 'profile1'?FirebaseStorage.instance.refFromURL(profile1_url).delete():null;
                            profile2_url != 'profile2'?FirebaseStorage.instance.refFromURL(profile2_url).delete():null;
                            profile3_url != 'profile3'?FirebaseStorage.instance.refFromURL(profile3_url).delete():null;
                            profile4_url != 'profile4'?FirebaseStorage.instance.refFromURL(profile4_url).delete():null;
                            profile5_url != 'profile5'?FirebaseStorage.instance.refFromURL(profile5_url).delete():null;
                          }catch(e){}
                          petsRef.doc(postId).delete();
                        });
                        }
                        usersRef.doc(userId).delete();

                        try{
                          googleSignIn.signOut();
                          _auth.signOut();
                        }catch(e){}

                        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>home()));
                      });
                    }
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  flex: 1,
                  child: InkWell(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.red.shade900,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Center(child: Text('ยกเลิก',style: TextStyle(color: Colors.white,fontSize: 16))),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                SizedBox(width: 20),
              ],
            ),
          )

        ],
      )
  );
}
