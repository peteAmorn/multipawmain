import 'dart:convert';

const secretID = 'U97JMHS6Q287ZOB5CTZ2';
const secretKey = '1mJUokuxC3qrBIfWzA40q0AceQ62nG4VQFkARWeM6v1g10WM5v7w5n2w50TjOKyhNJ5ah2YGJmc4rDf3';
const url = 'https://multipaws.co.th/#/transaction_success';
const msFeeType = 'include';


// ********  Create Transaction CreditCard/QR Code (API) to Json
class msPaymentModelData{
  msPaymentModelData({
    this.secret_id = secretID,
    this.secret_key = secretKey,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.amount,
    this.feeType = msFeeType,
    required this.order_id,
    this.payment_type = 'qrnone',
    this.success_Url = url,
    this.fail_Url = url,
    this.cancel_Url = url,
    this.agreement = '5',
  });
  String secret_id;
  String secret_key;
  String firstname;
  String lastname;
  String email;
  String amount;  // 2 decimal point
  String feeType;
  String order_id;
  String payment_type;
  String success_Url;
  String fail_Url;
  String cancel_Url;
  String agreement;

  factory msPaymentModelData.fromRawJson(String str)=> msPaymentModelData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory msPaymentModelData.fromJson(Map<String,dynamic> json) => msPaymentModelData(
      secret_id: json['secret_id'],
      secret_key: json['secret_key'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      email: json['email'],
      amount: json['amount'],
      feeType: json['feeType'],
      order_id: json['order_id'],
      payment_type: json['payment_type'],
      success_Url: json['success_Url'],
      fail_Url: json['fail_Url'],
      cancel_Url: json['cancel_Url'],
      agreement: json['agreement']
  );

  Map<String,dynamic> toJson()=>{
    'secret_id': secretID,
    'secret_key': secretKey,
    'firstname': firstname,
    'lastname' : lastname,
    'email': email,
    'amount': amount,
    'feeType' : feeType,
    'order_id': order_id,
    'payment_type': payment_type,
    'success_Url': success_Url,
    'fail_Url' : fail_Url,
    'cancel_Url' : cancel_Url,
    'agreement' : agreement,
  };

  String msPaymentData(){
    String bodyData =
        "secret_id=" + secretID + "&" +
            "secret_key=" + secret_key + "&" +
            "firstname=" + firstname + "&" +
            "lastname=" + lastname + "&" +
            "email=" + email + "&" +
            "amount=" + amount + "&" +
            "feeType=" + feeType + "&" +
            "order_id=" + order_id + "&" +
            "payment_type=" + payment_type + "&" +
            "success_Url=" + success_Url + "&" +
            "fail_Url=" + fail_Url + "&" +
            "cancel_Url=" + cancel_Url + "&" +
            "agreement=" + agreement;
    return bodyData;
  }
}


// Cancel payment request
class msCancelQRtoJson {
  msCancelQRtoJson({
    this.secret_id = secretID,
    this.secret_key = secretKey,
    required this.transaction_ID,
  });
  String secret_id;
  String secret_key;
  String transaction_ID;

  Map<String,dynamic> toJson()=>{

    'secret_id': secretID,
    'secret_key': secretKey,
    'transaction_ID': transaction_ID,
  };

  String msCancelPaymentData(){
    String bodyData =
        "secret_id=" + secretID + "&" +
            "secret_key=" + secretKey + "&" +
            "transaction_ID=" + transaction_ID;
    return bodyData;
  }
}

class FetchCancelPaymentResponse {
  FetchCancelPaymentResponse({
    required this.status,
    required this.message,
  });

  String status;
  String message;

  factory FetchCancelPaymentResponse.fromJson(Map<String, dynamic> json) => FetchCancelPaymentResponse(
    status: json["status"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
  };
}

// ********  Checking Create Transaction Status ->
// if "status": "success", save "transaction_ID": "MSTRFxxxxxxxx"
// Return Format
//[
//     {
//         "status": "success",
//         "transaction_ID": "MSTRF18000000383878",
//  Note: return link_payment for pay bu credit card and return image_qrprom for QR promptpay
//         "link_payment": "https://www.moneyspace.net/merchantapi/makepayment/linkpaymentcard?locale=th&transactionID=MSTRF18000000383878&timehash=20220507050309&secreteID=3XWXO1U3N098U00D6M72&hash=525e43fc193970983e97d7db04ac5e0f6d8ee10aa732c0ac41a83a4ca15d28e6"
//     }
// ]
List<CreateTransactionStatusChecking> createTransactionStatusCheckingFromJson(String str) => List<CreateTransactionStatusChecking>.from(json.decode(str).map((x) => CreateTransactionStatusChecking.fromJson(x)));

String createTransactionStatusCheckingToJson(List<CreateTransactionStatusChecking> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CreateTransactionStatusChecking {
  CreateTransactionStatusChecking({
    required this.status,
    required this.transactionId,
    required this.image_qrprom,
  });

  String status;
  String transactionId;
  String image_qrprom;

  factory CreateTransactionStatusChecking.fromJson(Map<String, dynamic> json) => CreateTransactionStatusChecking(
    status: json["status"],
    transactionId: json["transaction_ID"],
    image_qrprom: json["image_qrprom"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "transaction_ID": transactionId,
    "image_qrprom": image_qrprom,
  };
}

// ===================================================================

// ********  Checking Payment Status using MultiPaws's TransactionID
class paymentCheckingMultiPawsResponse{
  paymentCheckingMultiPawsResponse({
    this.secret_id = secretID,
    this.secret_key = secretKey,
    required this.order_id,
  });
  String secret_id;
  String secret_key;
  String order_id;    // order_id = MultiPaws Transaction ID

  Map<String,dynamic> toJson()=>{
    'secret_id': secretID,
    'secret_key': secretKey,
    'order_id': order_id,
  };
  String msOrderIDCheckData(){
    String bodyData =
        "secret_id=" + secretID + "&" +
            "secret_key=" + secretKey + "&" +
            "order_id=" + order_id;
    return bodyData;
  }
}

// Get Return Transaction Status Using MultiPaws's Transaction ID
class TransStatChck_MultiPaws_Response {
  TransStatChck_MultiPaws_Response({
    required this.orderId,
  });
  OrderId orderId;

  factory TransStatChck_MultiPaws_Response.fromJson(Map<String, dynamic> json) => TransStatChck_MultiPaws_Response(
    orderId: OrderId.fromJson(json["order id"]),
  );

  Map<String, dynamic> toJson() => {
    "order id": orderId.toJson(),
  };
}

class OrderId {
  OrderId({
    required this.status,
    this.amount,
    required this.description,
  });

  String status;
  String? amount;
  String description;

  factory OrderId.fromJson(Map<String, dynamic> json) => OrderId(
    status: json["status"],
    amount: json["amount"],
    description: json["description"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "amount": amount,
    "description": description,
  };
}


// ********  Checking Payment Status using MoneySpace's TransactionID
class paymentCheckingMoneySpaceResponse{
  paymentCheckingMoneySpaceResponse({
    this.secret_id = secretID,
    this.secret_key = secretKey,
    required this.transaction_ID,
  });
  String secret_id;
  String secret_key;
  String transaction_ID;    // order_id = MultiPaws Transaction ID

  Map<String,dynamic> toJson()=>{
    'secret_id': secretID,
    'secret_key': secretKey,
    'order_id': transaction_ID,
  };

  String msTransactionIDCheckData(){
    String bodyData =
        "secret_id=" + secretID + "&" +
            "secret_key=" + secretKey + "&" +
            "transaction_ID=" + transaction_ID;
    return bodyData;
  }
}

// Get Return Transaction Status Using MoneySpace's Transaction ID
class TransStatChck_MoneySpace_Response {
  TransStatChck_MoneySpace_Response({
    required this.transactionId,
  });

  TransactionId transactionId;

  factory TransStatChck_MoneySpace_Response.fromJson(Map<String, dynamic> json) => TransStatChck_MoneySpace_Response(
    transactionId: TransactionId.fromJson(json["transaction id"]),
  );

  Map<String, dynamic> toJson() => {
    "transaction id": transactionId.toJson(),
  };
}

class TransactionId {
  TransactionId({
    required this.status,
    this.amount,
    this.description,
  });

  String status;
  String? amount;
  String? description;

  factory TransactionId.fromJson(Map<String, dynamic> json) => TransactionId(
    status: json["status"],
    amount: json["amount"],
    description: json["description"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "amount": amount,
    "description": description,
  };
}
