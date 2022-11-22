import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:multipawmain/pages/discovery.dart';
import 'package:multipawmain/pages/profile/profile.dart';
import 'package:multipawmain/questionsAndConditions/questionAboutCat.dart';
import 'package:multipawmain/questionsAndConditions/questionsAboutCanine.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/authCheck.dart';
import 'package:multipawmain/support/methods.dart';



final GoogleSignIn googleSignIn = new GoogleSignIn();

class authScreen extends StatefulWidget {
  final String? currentUserId,postId,breed,profile,type,profileOwnerId,gender,token;
  final double userLat,userLng;
  late int pageIndex;
  authScreen(
      {
        this.currentUserId,
        this.postId,
        required this.pageIndex,
        this.breed,
        this.profile,
        this.type,
        this.profileOwnerId,
        this.gender,
        required this.token,
        required this.userLat,
        required this.userLng,
      });

  @override
  _authScreenState createState() => _authScreenState();
}

class _authScreenState extends State<authScreen> {
  late PageController pageController;
  late int pageIndex;
  bool isLoading = false;
  List<String> imagesList = [];
  String? isAdmin;
  int total_Noti = 0;
  int itemToPrepare = 0;
  int itemDispatched = 0;
  int itemGuarantee =0;
  int itemToReview = 0;


  getNotiCounter()async{
    await usersRef.doc(widget.currentUserId).collection('deliveryStatusForBuyer').where('status',isEqualTo: 'เตรียมจัดส่ง').get().then((snap){
      snap.size > 0? itemToPrepare = snap.size:itemToPrepare = 0;
    });
    await usersRef.doc(widget.currentUserId).collection('deliveryStatusForBuyer').where('status',isEqualTo: 'กำลังขนส่ง').get().then((snap){
      snap.size > 0? itemDispatched = snap.size:itemDispatched = 0;
    });
    await usersRef.doc(widget.currentUserId).collection('deliveryStatusForBuyer').where('status',isEqualTo: 'การันตี').get().then((snap){
      snap.size > 0? itemGuarantee = snap.size:itemGuarantee = 0;
    });
    await usersRef.doc(widget.currentUserId).collection('deliveryStatusForBuyer').where('status',isEqualTo: 'รอการรีวิว').get().then((snap){
      snap.size > 0? itemToReview = snap.size:itemToReview = 0;
    });
  }

  checkAdmin()async{
    setState(() {
      isLoading = true;
    });

    await usersRef.doc(widget.currentUserId).get().then((snapshot) => {
      isAdmin = snapshot.data()!['admin']
    });

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });

    checkAdmin();
    getNotiCounter();
    pageIndex = widget.pageIndex;
    pageController = PageController(initialPage: pageIndex, keepPage: true);

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        total_Noti = itemToPrepare + itemDispatched + itemGuarantee + itemToReview;
        isLoading = false;
      });
      });
    }


  logOut(){
    googleSignIn.signOut();
  }

  onPageChange(int pageIndex){
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex){
    pageController.animateToPage(
        pageIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut);
  }

  Scaffold buildAuthScreen() {
    getNotiCounter();
    return Scaffold(
        body: PageView(
          children: <Widget>[
            discovery(
              currentUserId: widget.currentUserId,
              postId: widget.postId,
              profile: widget.profile,
              type: widget.type,
              breed: widget.breed,
              profileOwnerId: widget.profileOwnerId,
              gender: widget.gender,
              userLat: widget.userLat,
              userLng: widget.userLng,
            ),

            // #############################################
            // Uncomment this section when want to show shop
            widget.type == 'สุนัข'?questionsAboutCanine(toShowBackButton: false):questionsAboutCat(toShowBackButton: false),
            // #############################################

            profile(userId: widget.currentUserId,profileId: widget.postId,isOwner: true,profileOwnerId: widget.currentUserId,isAdmin: isAdmin),
          ],
          controller: pageController,
          onPageChanged: onPageChange,
          physics: NeverScrollableScrollPhysics(),
        ),
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: 8.0,
          clipBehavior: Clip.antiAlias,
          child: Container(
            decoration: BoxDecoration(
              color: themeColour,
              border: Border(top: BorderSide(width: 0.4,color: Colors.black)
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 0.001),
                // Discovery Page
                IconButton(
                    onPressed: ()=> pageController.jumpToPage(0),
                    icon: pageIndex ==0?
                    FaIcon(FontAwesomeIcons.paw, color: Colors.white, size: 33):
                    FaIcon(LineAwesomeIcons.paw, color: Colors.white, size: 31)
                ),

                //###############################################
                // Uncomment this section whne want to show shop
                // Shopping Page
                IconButton(
                    onPressed: ()=> pageController.jumpToPage(1),
                    icon: pageIndex ==1?
                    Icon(FontAwesomeIcons.solidQuestionCircle,color: Colors.white,size: 32):
                    Icon(FontAwesomeIcons.solidQuestionCircle,color: Colors.white,size: 25)
                ),

                // chats Page
                IconButton(
                    onPressed: ()=> pageController.jumpToPage(2),
                    icon: pageIndex ==2?
                    Icon(FontAwesomeIcons.userAlt, color: Colors.white, size: 28):
                    Icon(FontAwesomeIcons.user, color: Colors.white, size: 25)
                ),
                SizedBox(width: 0.001),
              ],
            ),
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {

    return isLoading == true? loading():buildAuthScreen();
  }
}
