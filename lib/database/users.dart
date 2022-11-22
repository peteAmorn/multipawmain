class Users {
  late final id;
  late final name;
  late final location1;
  late final location2;
  late final city;
  late final lat;
  late final lng;
  late final loyaltyPoints;
  late final urlProfilePic;
  late final admin;
  late final timestamp;

  Users({
    this.id,
    this.name,
    this.location1,
    this.location2,
    this.city,
    this.lat,
    this.lng,
    this.loyaltyPoints,
    this.urlProfilePic,
    this.admin,
    this.timestamp
  });

  factory Users.fromDocument(doc){
    return Users(
        id: doc.data()['id'],
        name: doc.data()['name'],
        location1: doc.data()['location1'],
        location2: doc.data()['location2'],
        city: doc.data()['city'],
        lat: doc.data()['lat'],
        lng: doc.data()['lng'],
        loyaltyPoints: doc.data()['loyaltyPoints'],
        urlProfilePic: doc.data()['urlProfilePic'],
        admin: doc.data()['admin'],
        timestamp: doc.data()['timestamp']
    );
  }
}
