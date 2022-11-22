import 'package:flutter/material.dart';
import 'constants.dart';

AppBar appBarWithOutBackArrow(String title1,bool isTablet){
  return AppBar(
      centerTitle: false,
      backgroundColor: themeColour,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: EdgeInsets.only(left: 20),
        child: Text(title1,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isTablet?25:20)
        ),
      ),
  );
}

AppBar appBarAuth(BuildContext context,String title1,Function()? ontap){
  return AppBar(
    centerTitle: false,
    backgroundColor: themeColour,
    automaticallyImplyLeading: false,
    title: Padding(
      padding: EdgeInsets.only(left: 20),
      child: Text(title1,
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20)
      ),
    ),
    actions: [
      Padding(
        padding: EdgeInsets.only(right: 20),
        child: Center(
          child: InkWell(
            child: Text('ยกเลิก',style: TextStyle(color: Colors.white)),
            onTap: ontap,
          ),
        ),
      )
    ],);
}

AppBar appBarWithBackArrow(String title1,bool isTablet){
  return AppBar(
      centerTitle: true,
      backgroundColor: themeColour,
      automaticallyImplyLeading: true,
      title: Padding(
        padding: EdgeInsets.only(left: 20),
        child: Text(title1,
            style: TextStyle(
                color: Colors.white,
                fontSize: isTablet?25:18)
        ),
      ));
}

AppBar appbarPetProfile(String title1,String text,bool isTablet, Function() tap){
  return AppBar(
    automaticallyImplyLeading: true,
    centerTitle: false,
    backgroundColor: themeColour,
    title: Padding(
      padding: EdgeInsets.only(left: 20),
      child: Text(title1,
          style: TextStyle(
              color: Colors.white,
              fontSize: isTablet?20:16)
      ),
    ),
    actions: [
      Center(
        child: InkWell(
            child: Padding(
              padding: EdgeInsets.only(right: 15),
              child: Text(text,style: TextStyle(color: Colors.white,fontSize: isTablet== true?20:16),),
            ),
            onTap: tap
        ),
      )
    ],
  );
}

Padding iconbutton(IconData icon,double size,Function() ontap) {
  return Padding(
    padding: const EdgeInsets.only(right: 8.0),
    child: InkWell(
      child: Icon(
        icon,
        color: themeColour,
        size: size,
      ),
      onTap: ontap,
    ),
  );
}

Padding iconbuttonForCart(int inCart,IconData icon,double size,Function() ontap) {
  return Padding(
    padding: const EdgeInsets.only(right: 5.0),
    child: InkWell(
      child: inCart == 0?
      Container(
        width: 40,
        height: 30,
        child: Stack(
            children:[
              Positioned(
                bottom: 14,
                right: 8,
                child: Icon(
                  icon,
                  color: Colors.red.shade900,
                  size: size,
                ),
              ),
            ]
        ),
      ):Container(
        width: 40,
        height: 30,
        child: Stack(
          children: [
            Positioned(
              bottom: 15,
              right: 8,
              child: Icon(
                icon,
                color: Colors.red.shade900,
                size: size,
              ),
            ),
            Positioned(
                top: 0,
                right: 3,
                child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.shade900
                  ),
                  child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 5.0,left: 5.0,right: 5.0,top: 8),
                        child: Text(inCart.toString(),style: TextStyle(color: Colors.white,fontSize: 12,fontWeight: FontWeight.bold)),
                      )),
                )
            )
          ],
        ),
      ),
      onTap: ontap,
    ),
  );
}

loading(){
  return Center(
    child: Container(
      width: 50,
      height: 50,
      child: CircularProgressIndicator(color: themeColour),
    ),
  );
}

loadingForLocation(BuildContext context){
  return Center(
    child: Container(
      width: 200,
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          CircularProgressIndicator(color: themeColour),
          SizedBox(height: 20),
          Text('โปรดรอสักครู่',style: TextStyle(fontWeight: FontWeight.bold,color: themeColour)),
        ],
      ),
    ),
  );
}

loadingWithReturn(BuildContext context){
  return Center(
    child: Container(
      width: 200,
      height: 200,
      child: InkWell(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            CircularProgressIndicator(color: themeColour),
            SizedBox(height: 20),
            Text('แตะเพื่อย้อนกลับ',style: TextStyle(fontWeight: FontWeight.bold,color: themeColour)),
          ],
        ),
        onTap: ()=>Navigator.pop(context),
      ),
    ),
  );
}

loadingWhite(){
  return Center(
    child: Container(
      width: 50,
      height: 50,
      child: CircularProgressIndicator(color: Colors.white),
    ),
  );
}

loadingWhiteWithReturn(BuildContext context){
  return Center(
    child: Container(
      width: 200,
      height: 200,
      child: InkWell(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 20),
            Text('แตะเพื่อย้อนกลับ',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
          ],
        ),
        onTap: ()=>Navigator.pop(context),
      ),
    ),
  );
}
