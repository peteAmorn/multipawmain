import 'dart:io';

class Petlist{

  // Profile Picture
  late final cover;
  late final photo1;
  late final photo2;
  late final photo3;
  late final photo4;
  late final photo5;

  // Pet Name
  late final name;

  // Overview
  late final type;          // Dog or Cat
  late final breed;
  late final gender;
  late final colour;
  late int age;

  // Information
  late bool pedigree;        // bool
  late final pedigreeCover;
  late final familyTree;
  late final origin;        // Farm of origin

  // Measure
  late double weight;
  late double height;

  // Price
  late double price;
  late bool active;

  // Comment
  late final comment;

  Petlist({
    this.cover,
    this.photo1,
    this.photo2,
    this.photo3,
    this.photo4,
    this.photo5,
    this.name,
    this.type,
    this.breed,
    this.gender,
    this.colour,
    required this.age,
    required this.pedigree,
    this.pedigreeCover,
    this.familyTree,
    this.origin,
    required this.weight,
    required this.height,
    required this.price,
    required this.active,
    this.comment
  });

  factory Petlist.fromDocument(doc){
    return Petlist(
        cover: doc.data()['cover'],
        photo1: doc.data()['photo1'],
        photo2: doc.data()['photo2'],
        photo3: doc.data()['photo3'],
        photo4: doc.data()['photo4'],
        photo5: doc.data()['photo5'],
        name: doc.data()['name'],
        type: doc.data()['type'],
        breed: doc.data()['breed'],
        colour: doc.data()['colour'],
        age: doc.data()['age'],
        pedigree: doc.data()['pedigree'],
        pedigreeCover: doc.data()['pedigreeCover'],
        familyTree: doc.data()['familyTree'],
        origin: doc.data()['origin'],
        weight: doc.data()['weight'],
        height: doc.data()['height'],
        price: doc.data()['price'],
        active: doc.data()['active'],
        comment: doc.data()['comment']
    );
  }
}

class dataList{
  final String name;
  File? info;

  dataList({required this.name,required this.info});
}