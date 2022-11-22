import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sizer/sizer.dart';


class showNetworkImage extends StatelessWidget {
  final String image;
  List<String>? test;
  int? index;
  bool isTablet = false;
  showNetworkImage({required this.image,this.test,this.index});

  @override
  Widget build(BuildContext context) {
    SizerUtil.deviceType == DeviceType.tablet?isTablet = true:isTablet = false;
    final double height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
             test == null
                 ?PhotoView(
               minScale: PhotoViewComputedScale.contained,
               imageProvider: NetworkImage(image),
             ) :CarouselSlider.builder(
                itemCount: test!.length,
                itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex){
                  return PhotoView(
                    minScale: PhotoViewComputedScale.contained,
                    imageProvider: NetworkImage(test![itemIndex]),
                  );
                }, options: CarouselOptions(
              autoPlay: false,
              height: height,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              enableInfiniteScroll: false,
              initialPage: index == null? 0: index!.toInt(),
            )),

            Positioned(
              top: isTablet?40:20,
              left: isTablet?40:20,
              child: InkWell(
                child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade500
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ),
                onTap: () => Navigator.pop(context),
              ),
            )
          ],
        ),
      ),
    );
  }}
