
import 'package:multipawmain/support/payment/api_request.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:multipawmain/support/payment/moneyspace_model.dart';

class Service{
  static const payment_API = 'https://a.moneyspace.net/payment/CreateTransaction';
  static const statusChecking_API_byOrderId = 'https://a.moneyspace.net/CheckOrderID';
  static const statusChecking_API_byTransactionId = 'https://a.moneyspace.net/CheckPayment';
  static const cancelQR_API =  'https://a.moneyspace.net/merchantapi/cancelpayment';
  static const header = {
    'Content-Type' : 'application/x-www-form-urlencoded',
  };

  // Create payment
  Future<APIRequest<List<CreateTransactionStatusChecking>>> createPaymentClass(
      String firstname,
      String lastname,
      String email,
      String amount,
      String order_id)
  {
    var paymentInfo = msPaymentModelData(
        firstname: firstname,
        lastname: lastname,
        email: email,
        amount: amount,
        order_id: order_id
    ).msPaymentData();

    return http.post(Uri.parse(payment_API),
        headers: header,
        body: paymentInfo
    ).then((connection){
      if(connection.statusCode == 200){
        var jsonData = jsonDecode(connection.body);
        var data = <CreateTransactionStatusChecking>[];

        for(var item in jsonData){
          final info = CreateTransactionStatusChecking.fromJson(item);
          data.add(info);
        }
        return APIRequest<List<CreateTransactionStatusChecking>>(
            body: data
        );
      }
      return APIRequest<List<CreateTransactionStatusChecking>>(
          error: true,
          errorMessage: 'Create Payment fail'
      );
    });
  }

  // Cancel Payment Request i.e request QR to expire
  Future<APIRequest<List<FetchCancelPaymentResponse>>> cancelPaymentRequestClass(String transaction_ID){
    var qrInfo = msCancelQRtoJson(transaction_ID: transaction_ID).msCancelPaymentData();

    return http.post(Uri.parse(cancelQR_API),
        headers: header,
        body: qrInfo)
        .then((connection){
      // print(connection.statusCode);
      if(connection.statusCode == 200){
        var jsonData = jsonDecode(connection.body);
        // print(jsonData);
        var data = <FetchCancelPaymentResponse>[];

        for(var item in jsonData){
          final info = FetchCancelPaymentResponse.fromJson(item);
          data.add(info);
        }

        return APIRequest<List<FetchCancelPaymentResponse>>(
            body: data
        );
      }
      return APIRequest<List<FetchCancelPaymentResponse>>(
          error: true,
          errorMessage: 'Cancel payment request fail'
      );
    });
  }

  // Check payment status using MultiPaws's order_id
  Future<APIRequest<List<TransStatChck_MultiPaws_Response>>> paymentCheckingMultiPawsClass(String order_id){
    var orderStatusInfo = paymentCheckingMultiPawsResponse(order_id: order_id).msOrderIDCheckData();

    return http.post(Uri.parse(statusChecking_API_byOrderId),
        headers: header,
        body: orderStatusInfo)
        .then((connection){
      if(connection.statusCode == 200){
        var jsonData = jsonDecode(connection.body);
        var data = <TransStatChck_MultiPaws_Response>[];

        for(var item in jsonData){
          final info = TransStatChck_MultiPaws_Response.fromJson(item);
          data.add(info);
        }

        return APIRequest<List<TransStatChck_MultiPaws_Response>>(
            body: data
        );
      }
      return APIRequest<List<TransStatChck_MultiPaws_Response>>(
          error: true,
          errorMessage: 'Fetching status request by orderID fail'
      );
    });
  }

  // Check payment status using MoneySpace's order_id
  Future<APIRequest<List<TransStatChck_MoneySpace_Response>>> paymentCheckingMoneySpaceClass(String transaction_ID){
    var transactionStatusInfo = paymentCheckingMoneySpaceResponse(transaction_ID: transaction_ID).msTransactionIDCheckData();

    return http.post(Uri.parse(statusChecking_API_byTransactionId),
        headers: header,
        body: transactionStatusInfo)
        .then((connection){

      if(connection.statusCode == 200){
        var jsonData = jsonDecode(connection.body);
        var data = <TransStatChck_MoneySpace_Response>[];

        for(var item in jsonData){
          final info = TransStatChck_MoneySpace_Response.fromJson(item);
          data.add(info);
        }

        return APIRequest<List<TransStatChck_MoneySpace_Response>>(
            body: data
        );
      }
      return APIRequest<List<TransStatChck_MoneySpace_Response>>(
          error: true,
          errorMessage: 'Fetching status request by transactionID fail'
      );
    });
  }
}