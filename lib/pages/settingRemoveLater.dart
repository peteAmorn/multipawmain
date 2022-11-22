import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sizer/sizer.dart';
import '../authCheck.dart';
import '../questionsAndConditions/conditionsLibrary.dart';
import '../setting/baseSetting.dart';
import '../support/constants.dart';
import 'myPets/myPets.dart';

class settingPageTemp extends StatefulWidget {
final String userId,profileId,profileOwnerId;
settingPageTemp({required this.userId, required this.profileId,required this.profileOwnerId});
  @override
  _settingPageTempState createState() => _settingPageTempState();
}

class _settingPageTempState extends State<settingPageTemp> {
  late dynamic _distance;
  late dynamic _age;
  late String _active;
  double? lat,lng;
  late String price, city,location1,location2;
  late String _getToken,type;
  List<String> imagesList = [];
  List<String> pedigreeList = [];
  String? userImg,userName,token;
  String? peerImg,peerName;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  retrieveToken()async{
    _getToken = (await FirebaseMessaging.instance.getToken())!;
  }

  logOut()async{
    await usersRef.doc(widget.userId).collection('token').doc(_getToken).delete();

    try{
      await googleSignIn.signOut();
      await _auth.signOut();
    }catch(e){}
    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>home()));
  }

  getImg()async{
    imagesList.clear();
    await petsRef.where('postid',isEqualTo: widget.profileId).get().then((snapshot){
      snapshot.docs.forEach((doc) {
        type = doc['type'];

        if(doc['coverProfile']!= 'cover'){
          imagesList.add(doc['coverProfile']);
        }
        if(doc['coverPedigree']!= 'coverPed'){
          pedigreeList.add(doc['coverPedigree']);
        }
        if(doc['familyTreePedigree']!= 'familyTree'){
          pedigreeList.add(doc['familyTreePedigree']);
        }
        if(doc['profile1']!= 'profile1'){
          imagesList.add(doc['profile1']);
        }
        if(doc['profile2']!= 'profile2'){
          imagesList.add(doc['profile2']);
        }
        if(doc['profile3']!= 'profile3'){
          imagesList.add(doc['profile3']);
        }
        if(doc['profile4']!= 'profile4'){
          imagesList.add(doc['profile4']);
        }
        if(doc['profile5']!= 'profile5'){
          imagesList.add(doc['profile5']);
        }
      });
    });

    await usersRef.doc(widget.profileOwnerId).get().then((snapshot){
      peerImg = snapshot.data()!['urlProfilePic'];
      peerName = snapshot.data()!['name'];
    });

    await usersRef.where('id',isEqualTo: widget.userId).get().then((snapshot){
      snapshot.docs.forEach((doc) {
        userImg = doc['urlProfilePic'];
        userName = doc['name'];
      });
    });
  }

  ListTile buildListTileSignOut() {
    return ListTile(
      title: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10,right: 30),
            child: Icon(FontAwesomeIcons.powerOff,color: themeColour),
          ),
          Text('ล็อคเอ้า',style: topicStyle.apply(color: themeColour)),
        ],
      ),
    );
  }

  Future<dynamic> getUserData()async{
    return await petsRef.doc(widget.profileId).get().then((snapshot){
      lat = snapshot.data()!['lat'];
      lng = snapshot.data()!['lng'];
      _age = snapshot.data()!['targetAgeEnd'];
      _distance = snapshot.data()!['targetDistance'];
      price = snapshot.data()!['price'].toString();
      _active = snapshot.data()!['active'];
      city = snapshot.data()!['location1'] == ""? snapshot.data()!['location2'] : snapshot.data()!['location1'];
      location1 = snapshot.data()!['location1'];
      location2 = snapshot.data()!['location2'];
    });
  }

  InkWell buildListTile(String topic, Icon icon,Function() onTap) {
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color:Colors.grey.shade200)
            )
        ),
        child: ListTile(
          title: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10,right: 30),
                child: icon,
              ),
              Text(topic,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold))
            ],
          ),
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      isLoading = true;
      SizerUtil.deviceType == DeviceType.tablet?isTablet = true:isTablet = false;
    });

    retrieveToken();
    getImg();
    getUserData();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: themeColour,
          title: Text('ตั้งค่า')
      ),
      body: Column(
        children: [
          SizedBox(height: 15),
          Expanded(
            child: Column(
              children: [
                buildListTile('สัตว์เลี้ยงของฉัน',Icon(FontAwesomeIcons.dog,color: Colors.black),(){
                  Navigator.push(context, MaterialPageRoute(builder: (contetxt)=>myPets(currentUserId: widget.userId.toString())));
                }),
              ],
            ),
          ),
          Container(
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: Column(
                children: [
                  buildDivider(),
                  buildListTile('ตั้งค่า', Icon(FontAwesomeIcons.cog,color: Colors.black),()=> Navigator.push(context, MaterialPageRoute(
                      builder: (context)=>
                          baseSetting(
                            userid: widget.userId,
                            profileId: widget.profileId,
                            lat: lat,
                            lng: lng,
                            age: _age,
                            distance: _distance,
                            price: price,
                            active: _active,
                            location1: location1,
                            location2: location2,
                            city: city,
                          )))
                      .then((value){
                    setState(() {
                      isLoading = true;
                    });
                    getImg();
                    getUserData();

                    setState(() {
                      isLoading = false;
                    });
                  })),
                  buildListTile('เงือนไขและคำถามที่พบบ่อย',Icon(FontAwesomeIcons.solidQuestionCircle,size: 20,color: Colors.black),(){
                    Navigator.push(context, MaterialPageRoute(builder: (contetxt)=> conditionLibrary(userId: widget.userId)));
                  }),
                  SizedBox(height: 10),
                  InkWell(child: buildListTileSignOut(),onTap: ()=> logOut()),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
