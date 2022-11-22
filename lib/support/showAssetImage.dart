import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sizer/sizer.dart';

class showAssetImage extends StatelessWidget {
  final String image;
  showAssetImage({required this.image});
  bool isTablet = false;

  @override
  Widget build(BuildContext context) {
    SizerUtil.deviceType == DeviceType.tablet?isTablet = true:isTablet = false;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PhotoView(
              minScale: PhotoViewComputedScale.contained,
              imageProvider: AssetImage(image),
            ),
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