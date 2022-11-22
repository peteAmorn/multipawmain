import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sizer/sizer.dart';

class showIPedmage extends StatelessWidget {
  final String pedCover, pedFamilytree;
  showIPedmage({required this.pedCover,required this.pedFamilytree});
  bool isTablet = false;

  @override
  Widget build(BuildContext context) {
    SizerUtil.deviceType == DeviceType.tablet?isTablet = true:isTablet = false;
    final PageController controller = PageController(initialPage: 0);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PageView(
              scrollDirection: Axis.horizontal,
              controller: controller,
              children: [
                pedCover == 'coverPed' || pedCover == 'dad'
                    ?Center(child: Text('Image not found',style: TextStyle(color: Colors.white,fontSize: 20)))
                    :PhotoView(
                  minScale: PhotoViewComputedScale.contained,
                  imageProvider: NetworkImage(pedCover),
                ),
                pedFamilytree == 'familyTree' || pedFamilytree == 'mum'?Center(child: Text('Image not found',style: TextStyle(color: Colors.white,fontSize: 20))):Center(
                    child: PhotoView(
                      minScale: PhotoViewComputedScale.contained,
                      imageProvider: NetworkImage(pedFamilytree),
                    )
                )
              ],
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
                onTap: ()=> Navigator.pop(context),
              ),
            )
          ],
        ),
      ),
    );
  }
}
