import 'package:flutter/material.dart';
import 'package:multipawmain/support/methods.dart';
import '../database/breedDatabase.dart';

class policyAndCondition extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithBackArrow('เงื่อนไขการใช้งาน',false),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 20),
        child: ListView(
          children: [
            Text('ข้อกำหนดและเงื่อนไขการใช้งานแอปพลิเคชัน',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
            SizedBox(height: 10),
            Text(
              condition,
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              maxLines: 1000,
              style: TextStyle(
                color: Colors.black
              ),
            )
          ],
        ),
      ),
    );
  }
}
