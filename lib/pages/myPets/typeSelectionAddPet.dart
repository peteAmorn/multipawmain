import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/pages/myPets/infoFormAddPet.dart';
import '../../support/methods.dart';
import 'package:sizer/sizer.dart';

class typeSelectionAddPet extends StatefulWidget {
  final String? currentUserId;
  typeSelectionAddPet({this.currentUserId});

  @override
  _typeSelectionAddPetState createState() => _typeSelectionAddPetState();
}

class _typeSelectionAddPetState extends State<typeSelectionAddPet> {
  String selected = 'สุนัข';
  String image = 'assets/dogOption.png';
  bool _doghasBeenPressed = true;
  bool _cathasBeenPressed = false;
  bool isTablet = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      SizerUtil.deviceType == DeviceType.tablet?isTablet = true:isTablet = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appbarPetProfile('','ต่อไป',isTablet,(){
        Navigator.push(
            context, MaterialPageRoute(
            builder: (context)=>infoFormAddPet(currentUserId: widget.currentUserId,selected: selected))
        );
      }),

      body: Center(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: Text('กรุณาเลือกประเภทสัตว์เลี้ยง',
                  style: TextStyle(
                      color: themeColour,
                      fontSize: isTablet?30:20,
                      fontWeight: FontWeight.bold
                  ),),
              ),
            ),
            SizedBox(height: 50),
            selected == 'สุนัข'
                ?Container(
              width: MediaQuery.of(context).size.width*0.8,
              height: MediaQuery.of(context).size.width*0.6,
              child: Image.asset(image),
            )
                :Container(
              width: MediaQuery.of(context).size.width*0.8,
              height: MediaQuery.of(context).size.width*0.6,
              child: Image.asset(image),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 40,top: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      child: _doghasBeenPressed?buildSelectedButton('สุนัข'):buildUnselectedButton('สุนัข'),
                      onTap: (){
                        setState(() {
                          if(selected == 'สุนัข')
                          {
                            _doghasBeenPressed =_doghasBeenPressed;
                          }
                          else{
                            _doghasBeenPressed =!_doghasBeenPressed;
                            _cathasBeenPressed =! _cathasBeenPressed;
                          }
                          image = 'assets/dogOption.png';
                          selected = 'สุนัข';
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: GestureDetector(
                      child: _cathasBeenPressed?buildSelectedButton('แมว'):buildUnselectedButton('แมว'),
                      onTap: (){
                        setState(() {
                          if(selected == 'แมว')
                          {
                            _cathasBeenPressed = _cathasBeenPressed;
                          }
                          else{
                            _doghasBeenPressed =!_doghasBeenPressed;
                            _cathasBeenPressed =! _cathasBeenPressed;
                          }
                          image = 'assets/catOption.png';
                          selected = 'แมว';
                        });
                      },
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Container buildSelectedButton(String select) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: themeColour
      ),
      child: Text(select,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: isTablet?38:28
          )),
    );
  }

  Container buildUnselectedButton(String select) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(select,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTablet?38:28
          )),
    );
  }
}
