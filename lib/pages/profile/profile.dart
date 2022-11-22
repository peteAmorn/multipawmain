import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:multipawmain/chat/chatroom.dart';
import 'package:multipawmain/myshop/petShop/myPetShop.dart';
import 'package:multipawmain/myshop/storeManagement.dart';
import 'package:multipawmain/questionsAndConditions/conditionsLibrary.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/authCheck.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:multipawmain/pages/myPets/myPets.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:multipawmain/support/showNetworkImage.dart';
import 'package:multipawmain/support/showPedigreePetImages.dart';
import 'package:multipawmain/setting/baseSetting.dart';

import '../../authScreenWithoutPet.dart';

late dynamic _distance;
late dynamic _age;
late String _active;
double? lat,lng;
late String price, city,location1,location2;
int? priceMin;
bool? isAuth;


class profile extends StatefulWidget {
  final String? profileId,userId,profileOwnerId,isAdmin;
  final bool isOwner;
  profile({required this.profileId, required this.userId, required this.isOwner,required this.profileOwnerId,this.isAdmin});

  @override
  _profileState createState() => _profileState();
}

class _profileState extends State<profile> {
  List<String> imagesList = [];
  List<String> pedigreeList = [];
  late String profileid,type,_getToken;
  String? userImg,userName,token;
  String? peerImg,peerName;
  late bool isLoading;
  int? itemToPrepare,itemDispatched,itemGuarantee, totalCounter;
  int _itemIndex =0;
  bool isTablet = false;

  final CarouselController _controller = CarouselController();

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
    setState(() {
      isAuth = false;
    });
    Navigator.push(context, MaterialPageRoute(builder: (context)=> authScreenWithoutPet(pageIndex: 3,currentUserId: null)));
  }

  getNotiCounter()async{
    await buyerOnPrepareRef.where('sellerId',isEqualTo: widget.userId).get().then((snap){
      snap.size > 0? itemToPrepare = snap.size:itemToPrepare = 0;
    });
    await buyerOnDispatchRef.where('sellerId',isEqualTo: widget.userId).get().then((snap){
      snap.size > 0? itemDispatched = snap.size:itemDispatched = 0;
    });
    await buyerOnGuaranteeRef.where('sellerId',isEqualTo: widget.userId).get().then((snap){
      snap.size > 0? itemGuarantee = snap.size:itemGuarantee = 0;
    });
    totalCounter = itemToPrepare! + itemDispatched! + itemGuarantee!;

    Future.delayed(const Duration(milliseconds: 150), () {
      setState(() {
        isLoading = false;
      });
    });
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

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    setState(() {
      isLoading = true;
      SizerUtil.deviceType == DeviceType.tablet?isTablet = true:isTablet = false;
    });

    retrieveToken();
    getImg();
    getUserData();
    getNotiCounter();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String? patternToShow;


    DateFormat yearformatter = DateFormat('yyyy');
    String yearString = yearformatter.format(now);
    int currentYear = int.parse(yearString);

    DateFormat monthformatter = DateFormat('MM');
    String monthString = monthformatter.format(now);
    int currentMonth = int.parse(monthString);

    GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight =MediaQuery.of(context).size.height;
    var f = new NumberFormat("#,###", "en_US");


    return isLoading == true && widget.isOwner == false?
    loadingWithReturn(context)
        :isLoading == true && widget.isOwner == true?
    loading():
    Scaffold(
      key: _scaffoldState,
      // #############################################
      // Uncomment this section when want to show shop
      drawer: buildDrawer(),
      // #############################################
      body: isLoading == true && widget.isOwner == false?loadingWithReturn(context):FutureBuilder<DocumentSnapshot>(
          future: petsRef.doc(widget.profileId).get(),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot)
          {
            if (!snapshot.hasData)
            {
              return loadingWithReturn(context);
            }else if(snapshot.hasData)
            {
              int birthYr = snapshot.data!['birthYear'];
              int birthMn = snapshot.data!['birthMonth'];

              var ageYear = (( (currentYear - (1+birthYr)) *12 + (12- birthMn) + currentMonth) )~/12.floor();
              var ageMonth =(( (currentYear - (1+birthYr))) *12 + (12- birthMn) + currentMonth)%12;

              Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;

              priceMin = data['price'];

              data['pattern'] == 'สีเดียวทั่วทั้งตัว(Solid colour)'? patternToShow = 'Solid colour'
                  : data['pattern'] == 'สีขาวพื้นบนตัวมีแถบสีอื่น(Bi-Colour)'? patternToShow = 'Bi-Colour'
                  : data['pattern'] == 'ลายแมว(Tabby)'? patternToShow = 'Tabby'
                  : data['pattern'] == 'สีผสม 2 สีบนตัว(Tortoiseshell)'? patternToShow = 'Tortoiseshell'
                  : data['pattern'] == 'สีผสม 3 สีบนตัว(Calico)'? patternToShow = 'Calico'
                  : data['pattern'] == 'สีเข้มบริเวณใบหน้า,ขาและหาง(Colour Point)'? patternToShow = 'Colour Point':null;

              return ListView(
                children: [
                  Stack(
                      children:[
                        Column(
                          children: [
                            // Profile picture
                            CarouselSlider(
                              carouselController: _controller,
                              options: CarouselOptions(
                                height: isTablet?screenHeight*2.15/3:screenHeight*1.9/3,
                                viewportFraction: 1.0,
                                enlargeCenterPage: false,
                                enableInfiniteScroll: false,
                              ),
                              items: imagesList.map((item) => Container(
                                  width: screenWidth,
                                  height: isTablet?screenHeight*2.15/3:screenHeight*1.9/3,
                                  child: InkWell(
                                    child: Image.network(item,fit: BoxFit.cover,width: screenWidth,errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                      return Text('');}),
                                    onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>showNetworkImage(image: item,test: imagesList,index: imagesList.indexOf(item)))),
                                  ))).toList(),
                            ),
                            // Section below profile
                            Container(
                              width: screenWidth,
                              height: screenHeight*0.03,
                              color: themeColour,
                            ),
                          ],
                        ),
                        // Back arrow
                        Positioned(
                          top: isTablet?40:20,
                          left: isTablet?40:20,
                          child:
                          widget.userId == data['id']
                              ?InkWell(
                            child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey.shade500
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.menu,
                                      color: Colors.white,
                                      size: isTablet == true?35:25,
                                    ),
                                  ),
                                )
                            ),
                            onTap: (){
                              _scaffoldState.currentState!.openDrawer();
                            },
                          ):
                          //############################
                          InkWell(
                            child: Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade500
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  LineAwesomeIcons.arrow_left,
                                  color: Colors.white,
                                  size: isTablet?30:25,
                                ),
                              ),
                            ),
                            onTap: (){
                              Navigator.pop(context);
                            },
                          ),
                        ),


                        totalCounter! == 0 || widget.isOwner == false
                            ? SizedBox()
                            :Positioned(
                            top: isTablet?25:10,
                            left: isTablet?80:50,
                            child: notiAlert(totalCounter!)
                        ),

                        // Top box basic info
                        Positioned(
                            bottom: 0,
                            child: Container(
                                alignment: Alignment.centerLeft,
                                width: screenWidth,
                                height: isTablet?60:50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30)),
                                    color: themeColour
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(left:isTablet?30:20.0,top: isTablet?10:0,bottom: isTablet?10:0),
                                  child: Text(data['breed'].toString(),
                                    style: TextStyle(fontSize: isTablet?30:20,fontWeight: FontWeight.bold,color: Colors.white),
                                  ),
                                )
                            )
                        )
                      ]
                  ),
                  Container(
                    color: Colors.white,
                    width: screenWidth,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          basicInfo(screenWidth, data, screenHeight, context),
                        ],
                      ),
                    ),
                  ),

                  Container(color: Colors.grey.shade300,width: screenWidth,height: 10),

                  Container(
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.only(left: 40),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            data['ownerProfile'] == "" || data['ownerProfile'] == null?Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                radius: isTablet?50:30,
                                backgroundColor: Colors.white,
                                child: Center(child: Icon(FontAwesomeIcons.userAlt,color: Colors.black,)),
                              ),
                            ):CircleAvatar(
                              radius: isTablet?50:30,
                              backgroundColor: Colors.white,
                              backgroundImage: NetworkImage(data['ownerProfile'])
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0,top: 5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data['ownerName'],style: TextStyle(fontSize: isTablet?20:15,fontWeight: FontWeight.bold)),
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on_sharp,color: themeColour,size: isTablet?20:10),
                                      SizedBox(width: 5),
                                      Text('สถานที่อยู่อาศัย',style: TextStyle(fontSize: isTablet?18:12,color: Colors.black,fontWeight: FontWeight.bold),maxLines: 2),
                                    ],
                                  ),
                                  Container(
                                    alignment: Alignment.topLeft,
                                    width: MediaQuery.of(context).size.width*4/6,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(data['location1'],style: TextStyle(fontSize: isTablet?16:10,color: Colors.black),maxLines: 2),
                                        Text(data['location2'],style: TextStyle(fontSize: isTablet?16:10,color: Colors.black),maxLines: 2)
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  Container(color: Colors.grey.shade300,width: screenWidth,height: 10),

                  Container(
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.only(left: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 10),
                          Text('ข้อมูลทั่วไป',style: TextStyle(color: Colors.grey.shade600,fontSize: isTablet?30:20,fontWeight: FontWeight.bold)),
                          SizedBox(height: 20),
                          buildRow(data,Icon(FontAwesomeIcons.solidClock,color: themeColour),'อายุ: ','${ageYear.toString()} ปี ${ageMonth.toString()} เดือน'),
                          builddivider(),
                          buildRow(data,Icon(FontAwesomeIcons.palette,color: themeColour),'สี: ',data['colour']),
                          builddivider(),

                          data['type'] == 'แมว'?buildRow(data,Icon(FontAwesomeIcons.fill,color: themeColour),'แพทเทิร์น: ',patternToShow.toString()):SizedBox(),
                          data['type'] == 'แมว'?builddivider():SizedBox(),

                          buildRowNumber(data,Icon(FontAwesomeIcons.ruler,color: themeColour),'ความสูง: ',data['height'],'cm'),
                          builddivider(),
                          buildRowNumber(data,Icon(FontAwesomeIcons.weight,color: themeColour),'น้ำหนัก: ',data['weight'],'kg'),
                          builddivider(),
                          data['aboutPet'] == ''
                              ?SizedBox(height: 0.000001)
                              :Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 20),
                              Text('ข้อมูลเพิ่มเติม ',style: TextStyle(fontSize: isTablet?30:20,fontWeight: FontWeight.bold)),
                              SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.only(right: 40.0),
                                child: Divider(color: themeColour,thickness: 3),
                              )
                            ],
                          ),
                          data['aboutPet'] == ''?SizedBox(height: 20):Padding(
                            padding: EdgeInsets.only(right: 20.00,top: 20,bottom: 20),
                            child: Text(data['aboutPet'],style: TextStyle(fontSize: 16),),
                          ),
                          SizedBox(height: 40),
                        ],
                      ),
                    ),
                  )
                ],);
            }
            return Text('Loading');
          }
      ),
      floatingActionButton: isLoading == true?SizedBox():widget.isOwner == true
          ? null
          :
      FloatingActionButton(
          backgroundColor: themeColour,
          child: Icon(FontAwesomeIcons.commentDots),
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>
                chatroom(
                  userid: widget.userId,
                  peerid: widget.profileOwnerId,
                  peerImg: peerImg,
                  userImg: userImg,
                  peerName: peerName,
                  userName: userName,
                  dtype: 'profile',
                  priceMin: priceMin,
                  priceMax: 0,
                  pricePromoMin: 0,
                  pricePromoMax: 0,
                  postid: widget.profileId,
                )
            ));
          }
      ),
    );
  }

  Padding builddivider() => Padding(padding: EdgeInsets.only(right: 40),child: Divider(color: Colors.grey));

  Container basicInfo(double screenWidth, Map<String, dynamic> data, double screenHeight, BuildContext context) {

    var f = new NumberFormat("#,###", "en_US");

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        color: Colors.white,
      ),
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          data['pedigree'] == 'Yes'
              ? Padding(
            padding: const EdgeInsets.only(top: 25.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: isTablet?4:2,
                  child: Text('${data['name'].toString()} '
                      ,style: TextStyle(fontWeight: FontWeight.bold,fontSize: isTablet?35:25),maxLines: 2)
                ),
                Expanded(
                  flex: 1,
                  child: InkWell(
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right:isTablet?15:35.0,top: isTablet?0:15),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Pedigree',style: TextStyle(color: themeColour,fontWeight: FontWeight.bold,fontSize: isTablet?8:20)),
                                SizedBox(height: isTablet?2:10),
                                Text('แตะเพื่อดูใบเพ็ตดีกรี',style: TextStyle(color: Colors.grey.shade700,fontSize: isTablet?4:12))
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>showIPedmage(pedCover: data['coverPedigree'],pedFamilytree: data['familyTreePedigree'])));
                    },
                  ),
                ),
              ],
            ),
          ):Padding(
            padding: const EdgeInsets.only(top: 25.0),
            child: Text('${data['name'].toString()} '
                ,style: TextStyle(fontWeight: FontWeight.bold,fontSize: isTablet?35:25),maxLines: 2),
          ),
          Padding(
              padding: EdgeInsets.only(right: 40),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('ค่าผสมพันธุ์: ',style: TextStyle(fontSize: isTablet?25:16)),
                      data['gender'] == 'ตัวผู้' ?Icon(Icons.male,color: Colors.blue,size: 30):Icon(Icons.female,color: Colors.pinkAccent,size: 30)
                    ],
                  ),
                  Divider(color: Colors.grey),
                ],
              )
          ),
          Padding(
            padding: const EdgeInsets.only(left: 0.0),
            child: Text(data['price'] != 0?'฿ ${f.format(data['price'])}':"ฟรี",style: TextStyle(fontSize: isTablet?40:30,color: themeColour,fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }

  Padding buildRow(Map<String, dynamic> data, Icon icon ,String topic, String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children:
        [
          icon,
          SizedBox(width: isTablet == true?40:20),
          Text(topic,style: topicStyle.copyWith(fontSize: isTablet?25:16)),
          Text(detail,style: topicStyle.copyWith(fontSize: isTablet?25:16,fontWeight: FontWeight.normal)),
          SizedBox(height: isTablet == true?50:40)
        ],
      ),
    );
  }

  Padding buildRowNumber(Map<String, dynamic> data, Icon icon ,String topic, double detail,String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children:
        [
          icon,
          SizedBox(width: isTablet == true?40:20),
          Text(topic,style: topicStyle.copyWith(fontSize: isTablet?25:16)),
          Text('${detail.toStringAsFixed(1)} ${unit}',style: topicStyle.copyWith(fontSize: isTablet?20:16,fontWeight: FontWeight.normal)),
          SizedBox(height: isTablet == true?50:40)
        ],
      ),
    );
  }

  Drawer buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/drawerProfile.jpg'),
                    fit: BoxFit.cover)
            ),
            child: null,
          ),
          Expanded(
            child: Column(
              children: [
                buildListTile('สัตว์เลี้ยงของฉัน',Icon(FontAwesomeIcons.dog,color: Colors.black),0,(){
                  Navigator.push(context, MaterialPageRoute(builder: (contetxt)=>myPets(currentUserId: widget.userId.toString())));
                }),
                // buildListTile('ประเมินน้ำหนัก',Icon(FontAwesomeIcons.book),0,(){
                //   Navigator.push(context, MaterialPageRoute(builder: (contetxt)=>weightAssessment(userId: widget.userId.toString(),postId: widget.profileId.toString(),type: type)));
                // }),
                buildListTile('ขายสัตว์เลี้ยง',Icon(FontAwesomeIcons.briefcase,size: 20,color: Colors.black),0,(){
                  Navigator.push(context, MaterialPageRoute(builder: (contetxt)=> myShop(userId: widget.userId.toString())));
                }),
                buildListTile('จัดการออเดอร์',Icon(FontAwesomeIcons.store,size: 20,color: Colors.black),5,(){
                  Navigator.push(context, MaterialPageRoute(builder: (contetxt)=>
                      storeManagement(
                        userId: widget.userId,
                        itemToPrepare: itemToPrepare!.toInt(),
                        itemDispatched: itemDispatched!.toInt(),
                        itemGuarantee: itemGuarantee!.toInt(),
                      )));
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
                  buildListTile('ตั้งค่า', Icon(FontAwesomeIcons.cog,color: Colors.black),0,()=> Navigator.push(context, MaterialPageRoute(
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
                  buildListTile('เงือนไขและคำถามที่พบบ่อย',Icon(FontAwesomeIcons.solidQuestionCircle,size: 20,color: Colors.black),0,(){
                    Navigator.push(context, MaterialPageRoute(builder: (contetxt)=> conditionLibrary(userId: widget.userId.toString())));
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

  InkWell buildListTile(String topic, Icon icon,int notiCount, Function() onTap) {
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
              topic != 'จัดการออเดอร์'?
              Text(topic,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)):
              totalCounter == 0 || widget.isOwner == false
                  ? Text(topic,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold))
                  :Row(
                mainAxisAlignment:MainAxisAlignment.start ,
                children: [
                  Text(topic,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                  SizedBox(width: 5),
                  notiAlert(totalCounter!)
                ],
              ),
            ],
          ),
        ),
      ),
      onTap: onTap,
    );
  }

  Container notiAlert(int notiCount) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red.shade900,
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet?10.0:8.0),
        child: Text(notiCount >99?'99+':notiCount.toString(),style: TextStyle(fontSize: isTablet?20.0:16.0,color: Colors.white),),
      ),
    );
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
}
