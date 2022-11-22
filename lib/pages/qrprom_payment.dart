import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:multipawmain/support/payment/service.dart';
import 'package:multipawmain/support/payment/api_request.dart';
import 'package:multipawmain/support/payment/moneyspace_model.dart';
import 'package:intl/intl.dart';
import 'package:multipawmain/support/showNetworkImage.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:io';
import 'package:sizer/sizer.dart';

var f = new NumberFormat("#,##0.00", "en_US");

class paymentPage extends StatefulWidget {
  final String qrprom_url;
  final String transactionID;
  final String final_price;
  paymentPage({required this.qrprom_url,required this.transactionID,required this.final_price});

  @override
  _paymentPageState createState() => _paymentPageState();
}

class _paymentPageState extends State<paymentPage>{
  bool _isLoading = false;
  Timer? timer;
  Uint8List? _imageFile;
  String? os;
  bool isTablet = false;

  ScreenshotController screenshotController = ScreenshotController();

  captureScreenAndSaveToGallery(){
    screenshotController.capture(delay: Duration(milliseconds: 5)).then((Uint8List? image){
      setState(() {
        _imageFile = image;
      });
      ImageGallerySaver.saveImage(_imageFile!,name: widget.transactionID);
      showAlertDialog(context);
    });
  }

  // Cancel Payment
  late APIRequest<List<FetchCancelPaymentResponse>> _responseFromCancelPayment;
  // Check Payment Status by TransactionID
  late APIRequest<List<TransStatChck_MoneySpace_Response>> _responseFromPaymentCheckingTransactionID;

  isTransactionCompleted()async{

    // Get Payment Status by TransactionID

    _responseFromPaymentCheckingTransactionID = await Service().paymentCheckingMoneySpaceClass(widget.transactionID).then((data) async {
      if(data.body![0].transactionId.status == 'pending'){

      }else{
        timer?.cancel();
        Navigator.pop(context,true);
        // pop to somewhere
      }
      return APIRequest<List<TransStatChck_MoneySpace_Response>>(
          error: true,
          errorMessage: 'Create Payment fail'
      );
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      SizerUtil.deviceType == DeviceType.tablet?isTablet = true:isTablet = false;
    });
    os = Platform.operatingSystem;
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) => isTransactionCompleted());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  cancelPayment()async{
    setState(() {
      _isLoading = true;
    });

    _responseFromCancelPayment = await Service().cancelPaymentRequestClass(
        widget.transactionID
    );

    setState(() {
      _isLoading = false;
    });
    Navigator.pop(context,false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: themeColour,
        body: _isLoading == true?loadingWhiteWithReturn(context)
            :ListView(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 38,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 10,
                        left: 20,
                        child: InkWell(
                          child: Icon(Icons.arrow_back,color: Colors.white),
                          onTap: ()=>cancelPayment(),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                          child: Text('ชำระเงินผ่าน QR พร้อมเพย์',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTablet?22:18,
                                  fontWeight: FontWeight.bold
                              )
                          )
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Text('** หากชำระเงินแล้วอย่ากดย้อนกลับ',
                          style: TextStyle(
                              color: Colors.white,
                            fontSize: isTablet?17:15
                          )
                      ),
                    )
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 10),
                  child: Screenshot(
                    controller: screenshotController,
                    child: Container(
                      height: 540,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Column(
                                children: [
                                  Container(
                                    width: isTablet?400:200,
                                    height: isTablet?140:70,
                                    child: Image.asset('assets/promptpay.png',fit: BoxFit.fitWidth),
                                  ),
                                  Container(
                                    width: isTablet?400:200,
                                    height: isTablet?400:200,
                                    child: Image.network(widget.qrprom_url,fit: BoxFit.fitHeight),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text('** กรุณาเปิดหน้านี้ทิ้งไว้ขณะชำระเงิน',style: TextStyle(color: themeColour,fontWeight: FontWeight.bold,fontSize: isTablet?20:16)),
                          buildDividerGrey(),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0,bottom: 5,top: 5),
                            child: buildRow(
                                FontAwesomeIcons.fileInvoiceDollar,
                                Colors.yellow.shade900,
                                'ยอดชำระ',
                                '${f.format(double.parse(widget.final_price))} บาท',
                                Colors.red.shade900
                            ),
                          ),
                          buildDividerGrey(),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0,bottom: 5,top: 5),
                            child: buildRow(
                                FontAwesomeIcons.barcode,
                                Colors.blue.shade800,
                                'หมายเลขการชำระเงิน',
                                widget.transactionID,
                                Colors.black
                            ),
                          ),
                          buildDividerGrey(),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
        bottomNavigationBar: os == 'android'?SizedBox():Padding(
          padding: const EdgeInsets.only(left: 10.0,right: 10,bottom: 25,top: 10),
          child: InkWell(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(FontAwesomeIcons.camera,color: themeColour),
                  SizedBox(width: 10),
                  Text('บันทึกรูป QR Code',style: TextStyle(fontWeight: FontWeight.bold,fontSize: isTablet?20:16))
                ],
              ),
            ),
            onTap: ()=>captureScreenAndSaveToGallery(),
          ),
        ),
      ),
    );
  }

  Row buildRow(IconData icon,Color iconColor, String topic, String detail,Color textColor) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0,right: 40,bottom: 10,top: 8),
          child: Icon(icon,
            color: iconColor,
            size: 25,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(topic,style: TextStyle(fontWeight: FontWeight.bold,fontSize: isTablet?20:16)),
            SizedBox(height: 5),
            Text(detail,style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: topic == 'ยอดชำระ'?17:14
            ))
          ],
        )
      ],
    );
  }
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FontAwesomeIcons.checkCircle,color: Colors.green,size: 40),
                SizedBox(height: 20),
                Text("บันทึกรูป QR code",style: TextStyle(color: Colors.green.shade900,fontSize: 15)),
                Text("เรียบร้อย",style: TextStyle(color: Colors.green.shade900,fontSize: 15)),
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
      Future.delayed(Duration(milliseconds: 2000),()=> Navigator.of(context).pop());
      return alert;
    },
  );
}