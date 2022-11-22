import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/src/intl/date_format.dart';

var now = new DateTime.now();

DateFormat monthformatter = DateFormat('MM');
String monthString = monthformatter.format(now);
int currentMonth = int.parse(monthString);

class discoveryList{
  late final String profileOwnerId;
  late final String postId;
  late final String breed;
  final String profileCover;
  final price;
  final String city;
  final String name;
  final String type;
  final String gender;
  final userLat;
  final userLng;
  final String active;
  final String pedigree;
  final double distance;
  final int age;

  discoveryList(
      {
        required this.profileOwnerId,
        required this.postId,
        required this.price,
        required this.city,
        required this.breed,
        required this.profileCover,
        required this.name,
        required this.type,
        required this.gender,
        required this.userLat,
        required this.userLng,
        required this.active,
        required this.pedigree,
        required this.distance,
        required this.age
      });
}

class myShopList{
  late final String postId;
  String ownerid;
  final String profileCover;
  final String topicName;
  final int view;
  final String breed;
  final price;
  final String pedigree;
  final String dadImg;
  final String mumImg;
  final String profile1;
  final String profile2;
  final String profile3;
  final String profile4;
  final String profile5;
  final Timestamp timeStamp;

  myShopList({
    required this.postId,
    required this.profileCover,
    required this.topicName,
    required this.view,
    required this.breed,
    required this.price,
    required this.pedigree,
    required this.dadImg,
    required this.mumImg,
    required this.profile1,
    required this.profile2,
    required this.profile3,
    required this.profile4,
    required this.profile5,
    required this.timeStamp,
    required this.ownerid
  });
}

class postList{
  late final String ownerId;
  late final String postId;
  final String profileCover;
  final String gender;
  final price;
  final age;
  final breed;
  final colour;
  final pattern;
  final String topicName;
  final String type;
  final String pedigree;
  final int views;
  late final active;

  postList(
      {
        required this.ownerId,
        required this.topicName,
        required this.profileCover,
        required this.gender,
        required this.postId,
        required this.price,
        required this.age,
        required this.breed,
        required this.colour,
        this.pattern,
        required this.type,
        required this.pedigree,
        required this.views,
        required this.active
      });
  factory postList.fromDocument(DocumentSnapshot doc){
    return postList(
      topicName: doc['topicName'],
      postId: doc['postid'],
      ownerId: doc['id'],
      gender: doc['gender'],
      price: doc['price'],
      age: currentMonth - doc['birthMonth'],
      breed: doc['breed'],
      colour: doc['colour'],
      pattern: doc['pattern'],
      type: doc['type'],
      pedigree: doc['pedigree'],
      profileCover: doc['coverProfile'],
      views: doc['view'],
      active: doc['active']
    );
  }
}


class foodList{
  late final String postId;
  final String profileCover;
  final String profile1;
  final String profile2;
  final String profile3;
  final String profile4;
  final String profile5;
  final String topicName;
  final int view;
  final String brand;
  final priceMin;


  final Timestamp timeStamp;

  foodList({
    required this.postId,
    required this.profileCover,
    required this.profile1,
    required this.profile2,
    required this.profile3,
    required this.profile4,
    required this.profile5,
    required this.topicName,
    required this.view,
    required this.brand,
    required this.priceMin,
    required this.timeStamp
  });
}

class foodListForShow{
  late final String postId;
  final String profileCover;
  final String topicName;
  final int view;
  final String brand;
  final priceMin;
  final priceMax;
  final promo_priceMin;
  final promo_priceMax;
  final type;
  final bool isPromo;
  final Timestamp timeStamp;
  final int stock1;
  final int stock2;
  final int stock3;
  final int stock4;
  final int stock5;
  final int stock6;

  foodListForShow({
    required this.postId,
    required this.profileCover,
    required this.topicName,
    required this.view,
    required this.brand,
    required this.priceMin,
    required this.priceMax,
    required this.promo_priceMin,
    required this.promo_priceMax,
    required this.isPromo,
    this.type,
    required this.timeStamp,
    required this.stock1,
    required this.stock2,
    required this.stock3,
    required this.stock4,
    required this.stock5,
    required this.stock6,
  });

  factory foodListForShow.fromDocument(DocumentSnapshot doc){
    return foodListForShow(
      postId: doc['postid'],
      profileCover: doc['coverProfile'],
      topicName: doc['topicName'],
      view: doc['view'],
      brand: doc['brand'],
      priceMin: doc['minPrice'],
      priceMax: doc['maxPrice'],
      promo_priceMin: doc['minPromo'],
      promo_priceMax: doc['maxPromo'],
      isPromo: doc['isPromo'],
      type: doc['type'],
      timeStamp: Timestamp.fromMillisecondsSinceEpoch(doc['timestamp']),
      stock1: doc['stock1'],
      stock2: doc['stock2'],
      stock3: doc['stock3'],
      stock4: doc['stock4'],
      stock5: doc['stock5'],
      stock6: doc['stock6'],
    );
  }
}

class foodListPage{
  late final String postId;
  final String profileCover;
  final String profile1;
  final String profile2;
  final String profile3;
  final String profile4;
  final String profile5;

  final String topicName;

  final int view;
  final String brand;

  final weight1;
  final price1;
  final promo_price1;

  final weight2;
  final price2;
  final promo_price2;

  final weight3;
  final price3;
  final promo_price3;

  final weight4;
  final price4;
  final promo_price4;

  final weight5;
  final price5;
  final promo_price5;

  final weight6;
  final price6;
  final promo_price6;

  final String medicationFunctions;
  final String specialtyDiet;
  final String selectedAge;
  final String description;
  final Timestamp timeStamp;

  foodListPage({
    required this.postId,
    required this.profileCover,
    required this.profile1,
    required this.profile2,
    required this.profile3,
    required this.profile4,
    required this.profile5,
    required this.topicName,
    required this.view,
    required this.brand,

    required this.weight1,
    required this.price1,
    required this.promo_price1,

    required this.weight2,
    required this.price2,
    required this.promo_price2,

    required this.weight3,
    required this.price3,
    required this.promo_price3,

    required this.weight4,
    required this.price4,
    required this.promo_price4,

    required this.weight5,
    required this.price5,
    required this.promo_price5,

    required this.weight6,
    required this.price6,
    required this.promo_price6,

    required this.medicationFunctions,
    required this.specialtyDiet,
    required this.selectedAge,
    required this.timeStamp,
    required this.description
  });
}

class myPetsList{
  final String postId;
  final String ownerId;
  final String type;
  final String pedCover;
  final String pedFamily;
  final String profileCover;
  final String profile1;
  final String profile2;
  final String profile3;
  final String profile4;
  final String profile5;
  final String gender;
  final String name;
  final String breed;
  String active;

  myPetsList(
      {
        required this.postId,
        required this.ownerId,
        required this.type,
        required this.pedCover,
        required this.pedFamily,
        required this.profileCover,
        required this.profile1,
        required this.profile2,
        required this.profile3,
        required this.profile4,
        required this.profile5,
        required this.gender,
        required this.name,
        required this.breed,
        required this.active,
      });
  factory myPetsList.fromDocument(DocumentSnapshot doc){
    return myPetsList(
      postId: doc['postid'],
      ownerId: doc['id'],
      type: doc['type'],
      pedCover: doc['coverPedigree'],
      pedFamily: doc['familyTreePedigree'],
      profileCover: doc['coverProfile'],
      profile1: doc['profile1'],
      profile2: doc['profile2'],
      profile3: doc['profile3'],
      profile4: doc['profile4'],
      profile5: doc['profile5'],
      gender: doc['gender'],
      name: doc['name'],
      breed: doc['breed'],
      active: doc['active'],
    );
  }
}

class bankAccountPaymentMethod{
  late final String accountName;
  final accountNumber;
  final bankName;

  bankAccountPaymentMethod({
    required this.accountName,
    this.accountNumber,
    this.bankName,
  });
  factory bankAccountPaymentMethod.fromDocument(DocumentSnapshot doc){
    return bankAccountPaymentMethod(
      accountName: doc['title']+' '+doc['accountFirstName']+' '+doc['accountLastName'],
      accountNumber: doc['accountNumber'],
      bankName: doc['bankName'],
    );
  }
}

class itemInCart{
  late final sellerName;
  late final sellerId;
  late final postId;
  late final topicName;
  late final breed;
  late final imageUrl;
  late final price;
  late final promo;
  late final quantity;
  late final dispatchDate;
  late final dispatchMonth;
  late final dispatchYear;
  late final type;
  late final subType;
  late String deliMethod;
  late final deliFee;
  late int discount;
  late final brand;
  late final airPickUpShow;
  late String destination;
  late bool forbidAirTransport;

  itemInCart({
    required this.sellerName,
    required this.sellerId,
    required this.postId,
    required this.topicName,
    required this.breed,
    required this.imageUrl,
    required this.price,
    required this.promo,
    required this.quantity,
    required this.dispatchDate,
    required this.dispatchMonth,
    required this.dispatchYear,
    required this.type,
    required this.subType,
    required this.deliMethod,
    required this.deliFee,
    required this.discount,
    required this.brand,
    required this.airPickUpShow,
    required this.destination,
    required this.forbidAirTransport,
});
}

class creditCardPaymentMethod{
  late final String cardName;
  late final String cardNumber;
  late final String cardType;
  late final String exDate;
  late final String cvv;
  late final String issueBank;

  creditCardPaymentMethod({
    required this.cardName,
    required this.cardNumber,
    required this.cardType,
    required this.exDate,
    required this.cvv,
    required this.issueBank,
  });
  factory creditCardPaymentMethod.fromDocument(DocumentSnapshot doc){
    return creditCardPaymentMethod(
        cardName: doc['cardName'],
        cardNumber: doc['cardNumber'],
        cardType: doc['cardType'],
        exDate: doc['exDate'],
        cvv: doc['cvv'],
        issueBank: doc['issueBank']
    );
  }
}


class foodBrand{
  final String name;
  final double cal;

  foodBrand({
    required this.name,
    required this.cal
  });
}

class dogIdealWeight{
  final String breed;
  final double minMale;
  final double maxMale;
  final double minFemale;
  final double maxFemale;

  dogIdealWeight({
    required this.breed,
    required this.minMale,
    required this.maxMale,
    required this.minFemale,
    required this.maxFemale
  });
}

class reviewDetail{
  final String buyerName;
  final String buyerImgUrl;
  String? reviewImg01;
  String? reviewImg02;
  String? breed;
  final String comment;
  final double score;
  final timestamp;
  final buyerId;
  final commentId;

  reviewDetail({
    required this.buyerName,
    required this.buyerImgUrl,
    this.reviewImg01,
    this.reviewImg02,
    this.breed,
    required this.comment,
    required this.score,
    required this.timestamp,
    required this.buyerId,
    required this.commentId
  });
  factory reviewDetail.fromDocument(DocumentSnapshot doc){
    return reviewDetail(
        buyerName: doc['buyerName'],
        buyerImgUrl: doc['buyerProfile'],
        comment: doc['comment'],
        reviewImg01: doc['reviewImg01'],
        reviewImg02: doc['reviewImg02'],
        score: doc['score'].toDouble(),
        timestamp: doc['timestamp'],
        buyerId: doc['buyerId'],
        commentId: doc['commentId'],
        breed: doc['breed']
    );
  }
}

class bannersList{
  final bannerImage;
  final linkType;
  final payLoad;

  bannersList({
    required this.bannerImage,
    required this.linkType,
    required this.payLoad,
  });
  factory bannersList.fromDocument(DocumentSnapshot doc){
    return bannersList(
      bannerImage: doc['bannerImage'],
      linkType: doc['linkType'],
      payLoad: doc['payLoad'],
    );
  }
}


class toPrepareList{
  final status;
  final userName;
  final userId;
  final seller;
  final delivery_method;
  final image;
  final topic;
  final breed;
  final price;
  final promo;
  final quantity;
  final discount;
  final total;
  final dispatchDate;
  final dispatchMonth;
  final dispatchYear;
  final Timestamp_dueToDeliveryAlert;
  final ticket_postId;
  final postId;
  final sellerId;
  final type;
  final deliPrice;
  final Timestamp_received_ticket_time;
  final weight;

  toPrepareList({
    required this.status,
    required this.userId,
    required this.userName,
    required this.seller,
    required this.delivery_method,
    required this.image,
    required this.topic,
    required this.breed,
    required this.price,
    required this.promo,
    required this.quantity,
    required this.discount,
    required this.total,
    required this.dispatchDate,
    required this.dispatchMonth,
    required this.dispatchYear,
    required this.Timestamp_dueToDeliveryAlert,
    required this.ticket_postId,
    required this.postId,
    required this.sellerId,
    required this.type,
    required this.deliPrice,
    required this.Timestamp_received_ticket_time,
    required this.weight,
  });
  factory toPrepareList.fromDocument(DocumentSnapshot doc){
    return toPrepareList(
        status: doc['status'],
        userId: doc['userId'],
        userName: doc['userName'],
        seller: doc['seller'],
        delivery_method: doc['delivery_method'],
        image: doc['image'],
        topic: doc['topic'],
        breed: doc['breed'],
        price: doc['price'],
        promo: doc['promo'],
        quantity: doc['quantity'],
        discount: doc['discount'],
        total: doc['total'],
        dispatchDate: doc['dispatchDate'],
        dispatchMonth: doc['dispatchMonth'],
        dispatchYear: doc['dispatchYear'],
        Timestamp_dueToDeliveryAlert: doc['Timestamp_dueToDeliveryAlert'],
        ticket_postId: doc['ticket_postId'],
        postId: doc['postId'],
        sellerId: doc['sellerId'],
        type: doc['type'],
        deliPrice: doc['deliPrice'],
        Timestamp_received_ticket_time: doc['Timestamp_received_ticket_time'],
        weight: doc['weight']
    );}
}

class toNotiList{
  final status;
  final userName;
  final userId;
  final ticket_postId;
  final sellerId;
  final type;
  final delivery_method;
  final topic;
  final image;
  final seller;
  final breed;
  final weight;
  final price;
  final promo;
  final quantity;
  final deliPrice;
  final discount;
  final total;
  final postId;
  final airline;
  final flightNumber;
  final flightDepartureTime;
  final flightArrivalTime;
  final Timestamp_received_ticket_time;
  final Timestamp_dispatched_time;
  final Timestamp_guarantee_ticket_start_time;
  final Timestamp_guarantee_ticket_end_time;

  toNotiList({
    required this.status,
    required this.userId,
    required this.userName,
    required this.ticket_postId,
    required this.sellerId,
    required this.type,
    required this.delivery_method,
    required this.topic,
    required this.image,
    required this.seller,
    required this.breed,
    required this.weight,
    required this.price,
    required this.promo,
    required this.quantity,
    required this.deliPrice,
    required this.discount,
    required this.total,
    required this.postId,
    required this.airline,
    required this.flightNumber,
    required this.flightDepartureTime,
    required this.flightArrivalTime,
    required this.Timestamp_received_ticket_time,
    required this.Timestamp_dispatched_time,
    required this.Timestamp_guarantee_ticket_start_time,
    required this.Timestamp_guarantee_ticket_end_time
  });
  factory toNotiList.fromDocument(DocumentSnapshot doc){
    return toNotiList(
      status: doc['status'],
      userId: doc['userId'],
      userName: doc['userName'],
      ticket_postId: doc['ticket_postId'],
      sellerId: doc['sellerId'],
      type: doc['type'],
      delivery_method: doc['delivery_method'],
      topic: doc['topic'],
      image: doc['image'],
      seller: doc['seller'],
      breed: doc['breed'],
      weight: doc['weight'],
      price: doc['price'],
      promo: doc['promo'],
      quantity: doc['quantity'],
      deliPrice: doc['deliPrice'],
      discount: doc['discount'],
      total: doc['total'],
      postId: doc['postId'],
      airline: doc['airline'],
      flightNumber: doc['flightNumber'],
      flightDepartureTime: doc['flightDepartureTime'],
      flightArrivalTime: doc['flightArrivalTime'],
      Timestamp_received_ticket_time: doc['Timestamp_received_ticket_time'],
      Timestamp_dispatched_time: doc['Timestamp_dispatched_time'],
      Timestamp_guarantee_ticket_start_time: doc['Timestamp_guarantee_ticket_start_time'],
      Timestamp_guarantee_ticket_end_time: doc['Timestamp_guarantee_ticket_end_time'],
    );}
}

class toReviewList{
  final status;
  final userId;
  final userName;
  final ticket_postId;
  final sellerId;
  final type;
  final delivery_method;
  final topic;
  final image;
  final seller;
  final breed;
  final weight;
  final price;
  final promo;
  final quantity;
  final deliPrice;
  final discount;
  final total;
  final postId;
  final airline;
  final flightNumber;
  final Timestamp_received_ticket_time;
  final Timestamp_dispatched_time;
  final Timestamp_guarantee_ticket_start_time;
  final Timestamp_guarantee_ticket_end_time;
  final flightDepartureTime;
  final flightArrivalTime;

  toReviewList({
    required this.status,
    required this.userId,
    required this.userName,
    required this.ticket_postId,
    required this.sellerId,
    required this.type,
    required this.delivery_method,
    required this.topic,
    required this.image,
    required this.seller,
    required this.breed,
    required this.weight,
    required this.price,
    required this.promo,
    required this.quantity,
    required this.deliPrice,
    required this.discount,
    required this.total,
    required this.postId,
    required this.airline,
    required this.flightNumber,
    required this.Timestamp_received_ticket_time,
    required this.Timestamp_dispatched_time,
    required this.Timestamp_guarantee_ticket_start_time,
    required this.Timestamp_guarantee_ticket_end_time,
    required this.flightDepartureTime,
    required this.flightArrivalTime,
  });
  factory toReviewList.fromDocument(DocumentSnapshot doc){
    return toReviewList(
      status: doc['status'],
      userId: doc['userId'],
      userName: doc['userName'],
      ticket_postId: doc['ticket_postId'],
      sellerId: doc['sellerId'],
      type: doc['type'],
      delivery_method: doc['delivery_method'],
      topic: doc['topic'],
      image: doc['image'],
      seller: doc['seller'],
      breed: doc['breed'],
      weight: doc['weight'],
      price: doc['price'],
      promo: doc['promo'],
      quantity: doc['quantity'],
      deliPrice: doc['deliPrice'],
      discount: doc['discount'],
      total: doc['total'],
      postId: doc['postId'],
      airline: doc['airline'],
      flightNumber: doc['flightNumber'],
      Timestamp_received_ticket_time: doc['Timestamp_received_ticket_time'],
      Timestamp_dispatched_time: doc['Timestamp_dispatched_time'],
      Timestamp_guarantee_ticket_start_time: doc['Timestamp_guarantee_ticket_start_time'],
      Timestamp_guarantee_ticket_end_time: doc['Timestamp_guarantee_ticket_end_time'],
      flightDepartureTime: doc['delivery_method'] == 'ส่งทางอากาศ (รับที่สนามบิน)'?doc['flightDepartureTime']:'0',
      flightArrivalTime: doc['delivery_method'] == 'ส่งทางอากาศ (รับที่สนามบิน)'?doc['flightArrivalTime']:'0'
    );}
}

class toDispatchedList{
  final ticket_postId;
  final userName;
  final userId;
  final sellerId;
  final type;
  final delivery_method;
  final topic;
  final image;
  final seller;
  final breed;
  final weight;
  final price;
  final promo;
  final quantity;
  final deliPrice;
  final discount;
  final total;
  final postId;
  final airline;
  final flightNumber;
  final flightDepartureTime;
  final flightArrivalTime;
  final Timestamp_received_ticket_time;
  final Timestamp_dispatched_time;
  final Timestamp_expected_dispatched_time;

  toDispatchedList({
    required this.ticket_postId,
    required this.userId,
    required this.userName,
    required this.sellerId,
    required this.type,
    required this.delivery_method,
    required this.topic,
    required this.image,
    required this.seller,
    required this.breed,
    required this.weight,
    required this.price,
    required this.promo,
    required this.quantity,
    required this.deliPrice,
    required this.discount,
    required this.total,
    required this.postId,
    required this.airline,
    required this.flightNumber,
    required this.flightDepartureTime,
    required this.flightArrivalTime,
    required this.Timestamp_received_ticket_time,
    required this.Timestamp_dispatched_time,
    required this.Timestamp_expected_dispatched_time,
  });
  factory toDispatchedList.fromDocument(DocumentSnapshot doc){
    return toDispatchedList(
      ticket_postId: doc['ticket_postId'],
      userName: doc['userName'],
      userId: doc['userId'],
      sellerId: doc['sellerId'],
      type: doc['type'],
      delivery_method: doc['delivery_method'],
      topic: doc['topic'],
      image: doc['image'],
      seller: doc['seller'],
      breed: doc['breed'],
      weight: doc['weight'],
      price: doc['price'],
      promo: doc['promo'],
      quantity: doc['quantity'],
      deliPrice: doc['deliPrice'],
      discount: doc['discount'],
      total: doc['total'],
      postId: doc['postId'],
      airline: doc['airline'],
      flightNumber: doc['flightNumber'],
      flightDepartureTime: doc['flightDepartureTime'],
      flightArrivalTime: doc['flightArrivalTime'],
      Timestamp_received_ticket_time: doc['Timestamp_received_ticket_time'],
      Timestamp_dispatched_time: doc['Timestamp_dispatched_time'],
      Timestamp_expected_dispatched_time: doc['Timestamp_expected_dispatched_time'],
    );}
}

class toCompletedList{
  final status;
  final userId;
  final userName;
  final ticket_postId;
  final sellerId;
  final type;
  final delivery_method;
  final topic;
  final image;
  final seller;
  final breed;
  final weight;
  final price;
  final promo;
  final quantity;
  final deliPrice;
  final discount;
  final total;
  final postId;
  final airline;
  final flightNumber;
  final Timestamp_received_ticket_time;
  final Timestamp_dispatched_time;
  final Timestamp_guarantee_ticket_start_time;
  final Timestamp_completed;

  toCompletedList({
    required this.status,
    required this.userName,
    required this.userId,
    required this.ticket_postId,
    required this.sellerId,
    required this.type,
    required this.delivery_method,
    required this.topic,
    required this.image,
    required this.seller,
    required this.breed,
    required this.weight,
    required this.price,
    required this.promo,
    required this.quantity,
    required this.deliPrice,
    required this.discount,
    required this.total,
    required this.postId,
    required this.airline,
    required this.flightNumber,
    required this.Timestamp_received_ticket_time,
    required this.Timestamp_dispatched_time,
    required this.Timestamp_guarantee_ticket_start_time,
    required this.Timestamp_completed
  });
  factory toCompletedList.fromDocument(DocumentSnapshot doc){
    return toCompletedList(
      status: doc['status'],
      userId: doc['userId'],
      userName: doc['userName'],
      ticket_postId: doc['ticket_postId'],
      sellerId: doc['sellerId'],
      type: doc['type'],
      delivery_method: doc['delivery_method'],
      topic: doc['topic'],
      image: doc['image'],
      seller: doc['seller'],
      breed: doc['breed'],
      weight: doc['weight'],
      price: doc['price'],
      promo: doc['promo'],
      quantity: doc['quantity'],
      deliPrice: doc['deliPrice'],
      discount: doc['discount'],
      total: doc['total'],
      postId: doc['postId'],
      airline: doc['airline'],
      flightNumber: doc['flightNumber'],
      Timestamp_received_ticket_time: doc['Timestamp_received_ticket_time'],
      Timestamp_dispatched_time: doc['Timestamp_dispatched_time'],
      Timestamp_guarantee_ticket_start_time: doc['Timestamp_guarantee_ticket_start_time'],
      Timestamp_completed: doc['Timestamp_completed'],
    );}
}

class toCancelList{
  final status;
  final userId;
  final userName;
  final ticket_postId;
  final sellerId;
  final type;
  final delivery_method;
  final topic;
  final image;
  final seller;
  final breed;
  final weight;
  final price;
  final promo;
  final quantity;
  final deliPrice;
  final discount;
  final total;
  final postId;
  final Timestamp_received_ticket_time;
  final Timestamp_expected_dispatched_time;
  final cancelBySystem_time;
  final reason;

  toCancelList({
    required this.status,
    required this.userId,
    required this.userName,
    required this.ticket_postId,
    required this.sellerId,
    required this.type,
    required this.delivery_method,
    required this.topic,
    required this.image,
    required this.seller,
    required this.breed,
    required this.weight,
    required this.price,
    required this.promo,
    required this.quantity,
    required this.deliPrice,
    required this.discount,
    required this.total,
    required this.postId,
    required this.Timestamp_received_ticket_time,
    required this.Timestamp_expected_dispatched_time,
    required this.cancelBySystem_time,
    required this.reason,
  });
  factory toCancelList.fromDocument(DocumentSnapshot doc){
    return toCancelList(
        status: doc['status'],
        userId: doc['userId'],
        userName: doc['userName'],
        ticket_postId: doc['ticket_postId'],
        sellerId: doc['sellerId'],
        type: doc['type'],
        delivery_method: doc['delivery_method'],
        topic: doc['topic'],
        image: doc['image'],
        seller: doc['seller'],
        breed: doc['breed'],
        weight: doc['weight'],
        price: doc['price'],
        promo: doc['promo'],
        quantity: doc['quantity'],
        deliPrice: doc['deliPrice'],
        discount: doc['discount'],
        total: doc['total'],
        postId: doc['postId'],
        Timestamp_received_ticket_time: doc['Timestamp_received_ticket_time'],
        Timestamp_expected_dispatched_time: doc['Timestamp_expected_dispatched_time'],
        cancelBySystem_time: doc['cancelBySystem_time'],
        reason: doc['reason']
    );}
}

class toRefundList{
  final status;
  final userId;
  final userName;
  final ticket_postId;
  final sellerId;
  final type;
  final delivery_method;
  final topic;
  final image;
  final seller;
  final breed;
  final weight;
  final price;
  final promo;
  final quantity;
  final deliPrice;
  final discount;
  final total;
  final postId;
  final airline;
  final flightNumber;
  final flightDepartureTime;
  final flightArrivalTime;
  final Timestamp_received_ticket_time;
  final Timestamp_dispatched_time;
  final Timestamp_guarantee_ticket_start_time;
  final Timestamp_product_claimed_approved_time;

  toRefundList({
    required this.status,
    required this.userId,
    required this.userName,
    required this.ticket_postId,
    required this.sellerId,
    required this.type,
    required this.delivery_method,
    required this.topic,
    required this.image,
    required this.seller,
    required this.breed,
    required this.weight,
    required this.price,
    required this.promo,
    required this.quantity,
    required this.deliPrice,
    required this.discount,
    required this.total,
    required this.postId,
    required this.airline,
    required this.flightNumber,
    required this.flightDepartureTime,
    required this.flightArrivalTime,
    required this.Timestamp_received_ticket_time,
    required this.Timestamp_dispatched_time,
    required this.Timestamp_guarantee_ticket_start_time,
    required this.Timestamp_product_claimed_approved_time
  });
  factory toRefundList.fromDocument(DocumentSnapshot doc){
    return toRefundList(
      status: doc['status'],
      userId: doc['userId'],
      userName: doc['userName'],
      ticket_postId: doc['ticket_postId'],
      sellerId: doc['sellerId'],
      type: doc['type'],
      delivery_method: doc['delivery_method'],
      topic: doc['topic'],
      image: doc['image'],
      seller: doc['seller'],
      breed: doc['breed'],
      weight: doc['weight'],
      price: doc['price'],
      promo: doc['promo'],
      quantity: doc['quantity'],
      deliPrice: doc['deliPrice'],
      discount: doc['discount'],
      total: doc['total'],
      postId: doc['postId'],
      airline: doc['airline'],
      flightNumber: doc['flightNumber'],
      flightDepartureTime: doc['flightDepartureTime'],
      flightArrivalTime: doc['flightArrivalTime'],
      Timestamp_received_ticket_time: doc['Timestamp_received_ticket_time'],
      Timestamp_dispatched_time: doc['Timestamp_dispatched_time'],
      Timestamp_guarantee_ticket_start_time: doc['Timestamp_guarantee_ticket_start_time'],
      Timestamp_product_claimed_approved_time: doc['Timestamp_product_claimed_approved_time'],
    );}
}

