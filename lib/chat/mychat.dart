import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multipawmain/chat/chatroom.dart';
import 'package:multipawmain/authCheck.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class mychat extends StatefulWidget {
  final String userId;
  mychat({required this.userId});

  @override
  _mychatState createState() => _mychatState();
}


class _mychatState extends State<mychat> {
  bool isLoading = false;
  String? userName,userImg;
  bool isTablet = false;

  getInfo()async{
    setState(() {
      isLoading = true;
    });
    await usersRef.doc(widget.userId).get().then((snapshot){
      userName = snapshot['name'];
      userImg = snapshot['urlProfilePic'] == null || snapshot['urlProfilePic'] == ''?'':snapshot['urlProfilePic'];

    });
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
    getInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bg_colour,
        appBar: appBarWithBackArrow('ห้องพูดคุย',isTablet),
        body: isLoading == true? loading():StreamBuilder(
            stream: usersRef.doc(widget.userId).collection('chattingWith').orderBy('timeStamp',descending: true).snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
              if(!snapshot.hasData){
                return loading();
              }

              return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: InkWell(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white
                        ),
                        child: ListTile(
                            leading:Container(
                              height: MediaQuery.of(context).size.height,
                              width: 70,
                              child: Stack(
                                  children:[
                                    Center(
                                      child:
                                      data['profile'] == "" || data['profile'] == null
                                ? CircleAvatar(
                                        radius: 25.0,
                                        child: Icon(FontAwesomeIcons.userAlt,color: Colors.black,),
                                        backgroundColor: Colors.transparent,
                                      ):CircleAvatar(
                                        radius: 25.0,
                                        backgroundImage: NetworkImage(data['profile']),
                                        backgroundColor: Colors.transparent,
                                      ),
                                    ),
                                    Positioned(
                                        top: 0,right: 0,
                                        child: data['isRead']== true?
                                        Container(
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white),
                                          child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.red.shade900),
                                                child: Padding(
                                                  padding: EdgeInsets.all(7),
                                                  child: Text('+',style: TextStyle(fontSize: 12,color: Colors.red.shade900,fontWeight: FontWeight.bold)),
                                                )),
                                          ),
                                        ): Text(''))
                                  ]
                              ),
                            ),
                            title: Text(data['name'],style: TextStyle(fontSize: isTablet?20:16)),
                            subtitle: Text(data['message'],style: TextStyle(fontSize: isTablet?20:16),maxLines: 1),
                            trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                sendingTime(data['timeStamp']),
                                SizedBox(),
                              ],
                            )
                        ),
                      ),
                      onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>
                          chatroom(
                              userid: widget.userId,
                              peerid: data['peerId'],
                              peerImg: data['profile'],
                              userImg: userImg,
                              peerName: data['name'],
                              userName: userName
                          )
                      )),
                    ),
                  );
                }).toList(),
              );
            }
        ));
  }
  Text sendingTime(Timestamp dateTime) {
    var now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    bool isToday = dateTime.toDate().isBefore(today.subtract(Duration(days: 1)));
    bool isYest = dateTime.toDate().isBefore(today);

    return isToday?
    Text("${DateFormat.yMMMd().format(dateTime.toDate())} ${DateFormat.Hm().format(dateTime.toDate())}",style: TextStyle(
        fontSize: isTablet?16:12,
        color: Colors.grey.shade700
    ),)
        :
    isYest?Text("Yesterday ${DateFormat.Hm().format(dateTime.toDate())}",style: TextStyle(
        fontSize: isTablet?16:12,
        color: Colors.grey.shade700
    ),)
        :Text("${DateFormat.Hm().format(dateTime.toDate())}",style: TextStyle(
        fontSize: isTablet?16:12,
        color: Colors.grey.shade700
    ),);
  }
}
