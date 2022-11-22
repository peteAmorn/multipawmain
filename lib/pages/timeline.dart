import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/support/methods.dart';
import 'package:sizer/sizer.dart';
import '../authCheck.dart';

DateTime now = DateTime.now();

class timeline extends StatefulWidget {
  final imgUrl,status,deliMethod,ticket_postId;
  final Timestamp_received_ticket_time,Timestamp_dispatched_time,Timestamp_delivered_time,Timestamp_guarantee_ticket_end_time,Timestamp_onComplete_time,Timestamp_onCancel_time,reason;
  final flightNo,airline;
  timeline({
    required this.ticket_postId,
    required this.imgUrl,
    required this.status,
    required this.deliMethod,
    this.Timestamp_received_ticket_time,
    this.Timestamp_dispatched_time,
    this.Timestamp_delivered_time,
    this.Timestamp_guarantee_ticket_end_time,
    this.Timestamp_onComplete_time,
    this.Timestamp_onCancel_time,
    this.airline,
    this.flightNo,
    this.reason,
  });

  @override
  _timelineState createState() => _timelineState();
}

class _timelineState extends State<timeline> {
  String? airport;
  bool isLoading = false;
  bool isTablet = false;

  Future getDeliveryAddress()async{
    await paymentIndexRef.doc(widget.ticket_postId).get().then((snapshot){
      if(snapshot.exists){
        airport = snapshot.data()!['toAirport'];
      }
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
      isLoading = true;
      SizerUtil.deviceType == DeviceType.tablet?isTablet = true:isTablet = false;
    });
    getDeliveryAddress();

  }

  @override
  Widget build(BuildContext context) {

    final DateFormat formatter = DateFormat('dd-MMM');
    var lastnight = DateTime(now.year,now.month,now.day);
    bool? isTodayDispatched,isTodayDelivered,isTodayCancel;
    bool isTodayReceivedTicket = widget.Timestamp_received_ticket_time.toDate().isAfter(lastnight);
    String? dispatched_time_format,dispatched_time,delivered_time_format,dilivered_time, cancel_time_format,cancel_date;

    String received_ticket_time_format =
    isTodayReceivedTicket == true
        ? DateFormat.Hm().format(widget.Timestamp_received_ticket_time.toDate())
        :formatter.format(widget.Timestamp_received_ticket_time.toDate());
    String received_ticket_time = DateFormat.Hm().format(widget.Timestamp_received_ticket_time.toDate());

    if(widget.Timestamp_onCancel_time != null){
      isTodayCancel = widget.Timestamp_onCancel_time.isAfter(lastnight);
      cancel_time_format = DateFormat.Hm().format(widget.Timestamp_onCancel_time);
      cancel_date = formatter.format(widget.Timestamp_onCancel_time);
    }

    if(widget.Timestamp_dispatched_time != null){
      isTodayDispatched = widget.Timestamp_dispatched_time.toDate().isAfter(lastnight);
      dispatched_time_format =
      isTodayDispatched == true
          ?DateFormat.Hm().format(widget.Timestamp_dispatched_time.toDate())
          :formatter.format(widget.Timestamp_dispatched_time.toDate());
      dispatched_time = DateFormat.Hm().format(widget.Timestamp_dispatched_time.toDate());
    }

    if(widget.Timestamp_delivered_time != null){
      isTodayDelivered = widget.Timestamp_delivered_time.toDate().isAfter(lastnight);
      delivered_time_format =
      widget.Timestamp_delivered_time ==  null
          ?null
          :isTodayDelivered == true
          ?DateFormat.Hm().format(widget.Timestamp_delivered_time.toDate())
          :formatter.format(widget.Timestamp_delivered_time.toDate());
      dilivered_time = widget.Timestamp_delivered_time ==  null?null:DateFormat.Hm().format(widget.Timestamp_delivered_time.toDate());
    }

    return StreamBuilder<Object>(
      stream: null,
      builder: (context, snapshot) {
        return Scaffold(
          backgroundColor: Colors.grey.shade300,
          appBar: appBarWithBackArrow('บันทึกการจัดส่ง',isTablet),
          body: isLoading == true? loading():Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0,horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: ListTile(
                      leading: Image.network(widget.imgUrl),
                      title:  Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.status,style: TextStyle(fontWeight: FontWeight.bold,color: themeColour,fontSize: isTablet?30:20)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              widget.deliMethod == 'ส่งทางอากาศ (รับที่สนามบิน)' && widget.Timestamp_onCancel_time == null
                                  ? Text('${widget.airline} - ${widget.flightNo}',style: TextStyle(fontSize: isTablet?20:16))
                                  :widget.deliMethod == 'รับเองที่ฟาร์ม' && widget.Timestamp_onCancel_time == null
                                  ? Text('ผู้ซื้อรับสินค้าเองที่ฟาร์ม',style: TextStyle(fontSize: isTablet?20:16))
                                  : widget.deliMethod == 'Standard Delivery' && widget.Timestamp_onCancel_time == null
                                  ?Text('ส่งแบบมาตราฐานในประเทศ',style: TextStyle(fontSize: isTablet?20:16))
                                  :widget.status == 'ยกเลิก'
                                  ? Text('เงินจะถูกโอนคืนในวันที่ \n15 หรือ 25 ของเดือน',style: TextStyle(fontSize: isTablet?20:16))
                                  : Text('')
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                    height: 30
                ),

                Container(
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text('การจัดส่ง',style: TextStyle(fontWeight: FontWeight.bold,fontSize: isTablet?20:16)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Divider(color: themeColour),
                          ),


                          // Delivered Section
                          widget.Timestamp_delivered_time == null
                              ? SizedBox()
                              :Padding(
                            padding: const EdgeInsets.only(left: 8.0,right: 8.0,bottom: 12.0),
                            child: ListTile(
                                leading: isTodayDelivered == true
                                    ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('วันนี้',style:
                                        widget.Timestamp_guarantee_ticket_end_time == null
                                            ? buildBoldWithThemeColourText()
                                            :buildNormalText()),
                                        Text(delivered_time_format.toString(),style:
                                        widget.Timestamp_guarantee_ticket_end_time == null
                                            ? buildBoldWithThemeColourText()
                                            :buildNormalText()),
                                      ],
                                    )
                                    :Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        Text(delivered_time_format.toString(),style:
                                        widget.Timestamp_guarantee_ticket_end_time == null
                                            ? buildBoldWithThemeColourText()
                                            :buildBoldText()),
                                        Text(dilivered_time.toString(),style:
                                        widget.Timestamp_guarantee_ticket_end_time == null
                                            ? buildBoldWithThemeColourText()
                                            :buildBoldText())
                                      ],
                                    )
                                  ],
                                ),
                                title: Text('ได้รับสินค้าแล้ว',style: TextStyle(fontSize: isTablet?20:16,color: widget.Timestamp_dispatched_time == widget.Timestamp_dispatched_time?themeColour:Colors.black),maxLines: 2)
                            ),
                          ),

                          //  Dispatched Section
                          widget.Timestamp_dispatched_time != null?Padding(
                            padding: const EdgeInsets.only(left: 8.0,right: 8.0,bottom: 12.0),
                            child: ListTile(
                                leading: isTodayDispatched == true
                                    ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('วันนี้',style:
                                    widget.Timestamp_delivered_time == null
                                        ? buildBoldWithThemeColourText()
                                        :buildNormalText()),
                                    Text(dispatched_time_format.toString(),style:
                                    widget.Timestamp_delivered_time == null
                                        ? buildBoldWithThemeColourText()
                                        :buildNormalText())
                                  ],
                                ):Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(dispatched_time_format.toString(),style:
                                    widget.Timestamp_delivered_time == null
                                        ? buildBoldWithThemeColourText()
                                        :buildNormalText()),
                                    Text(dispatched_time.toString(),style:
                                    widget.Timestamp_delivered_time == null
                                        ? buildBoldWithThemeColourText()
                                        :buildNormalText())
                                  ],
                                ),
                                title:
                            widget.deliMethod == 'รับเองที่ฟาร์ม' ? Text('สินค้าพร้อมส่งมอบ',style: TextStyle(fontSize: isTablet?20:16,color: widget.Timestamp_delivered_time == null?themeColour:Colors.black),maxLines: 2):
                            widget.deliMethod != 'ส่งทางอากาศ (รับที่สนามบิน)' ?Text('สินค้ากำลังถูกจัดส่ง',style: TextStyle(fontSize: isTablet?20:16,color: widget.Timestamp_delivered_time == null?themeColour:Colors.black),maxLines: 2)
                                :Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('ปลายทาง :${airport}',style: TextStyle(fontSize: isTablet?20:16,color: widget.Timestamp_delivered_time == null?themeColour:Colors.black),maxLines: 2),
                              ],
                            )
                            ),
                          ):SizedBox(),

                          //  Cancel Section
                          widget.Timestamp_onCancel_time != null?Padding(
                            padding: const EdgeInsets.only(left: 8.0,right: 8.0,bottom: 12.0),
                            child: ListTile(
                                leading: isTodayCancel == true
                                    ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('วันนี้',style:
                                    buildBoldWithThemeColourText()),
                                    Text(cancel_time_format.toString(),style:
                                    buildBoldWithThemeColourText())
                                  ],
                                ):Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(cancel_date.toString(),style:
                                    buildBoldWithThemeColourText()),
                                    Text(cancel_time_format.toString(),style:
                                    buildBoldWithThemeColourText())
                                  ],
                                ),
                                title: Text(widget.reason,style: TextStyle(color: themeColour,fontSize: isTablet?20:16))
                            ),
                          ):SizedBox(),

                          //  Ticket Received Section
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0,right: 8.0,bottom: 12.0),
                            child: ListTile(
                                leading: isTodayReceivedTicket == true
                                    ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('วันนี้',style: widget.Timestamp_dispatched_time == null && widget.Timestamp_onCancel_time == null? buildBoldWithThemeColourText():buildNormalText()),
                                    Text(received_ticket_time_format,style: widget.Timestamp_dispatched_time == null && widget.Timestamp_onCancel_time == null? buildBoldWithThemeColourText():buildNormalText())
                                  ],
                                ):Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(received_ticket_time_format,style: widget.Timestamp_dispatched_time == null && widget.Timestamp_onCancel_time == null? buildBoldWithThemeColourText():buildNormalText()),
                                    Text(received_ticket_time,style: widget.Timestamp_dispatched_time == null && widget.Timestamp_onCancel_time == null? buildBoldWithThemeColourText():buildNormalText())
                                  ],
                                ),
                                title: Text('ร้านค้าได้รับคำสั่งซื้อ',style: TextStyle(fontSize: isTablet?20:16),maxLines: 2)
                            ),
                          )
                        ],
                      )
                  ),
                ),

              ],
            ),
          ),
        );
      }
    );
  }
  TextStyle buildBoldText() => TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: isTablet?16:14);
  TextStyle buildBoldWithThemeColourText() => TextStyle(fontWeight: FontWeight.bold,color: themeColour,fontSize: isTablet?16:14);
  TextStyle buildNormalText() => TextStyle(fontSize: isTablet?16:14);
}

