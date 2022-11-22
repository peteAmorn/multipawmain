import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class videoPreviewForUpload extends StatefulWidget {
  final List listData;
  videoPreviewForUpload({required this.listData});

  @override
  _videoPreviewForUploadState createState() => _videoPreviewForUploadState();
}

class _videoPreviewForUploadState extends State<videoPreviewForUpload> {
  late VideoPlayerController _controller;
  late File thumbnail,url;
  List<File?> resultList = [];

  @override
  void initState() {
    super.initState();

    thumbnail = widget.listData[0];
    url = widget.listData[1];

    _controller = VideoPlayerController.file(url);
    _controller.addListener(() {
      setState(() {});
    });
    _controller.initialize().then((_) => setState(() {}));
    _controller.play();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: _controller.value.isInitialized ?
            AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    VideoPlayer(_controller),
                    _ControlsOverlay(controller: _controller),
                    VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: VideoProgressColors(playedColor: Colors.red.shade900),
                    ),
                  ],
                )
            ):
            Container(),
          )
        ],
      ),
      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                child: InkWell(
                    child: Text('Cancel',style: TextStyle(color: Colors.blue.shade100,fontSize: 20,fontWeight: FontWeight.bold)),
                    onTap: () {
                      File removeFile = File(url.path);
                      removeFile.delete();
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                )
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
              child: InkWell(child: Text('Done',style: TextStyle(color: Colors.yellow.shade600,fontSize: 20,fontWeight: FontWeight.bold)),
                  onTap: (){
                    resultList.add(thumbnail);
                    resultList.add(url);
                    Navigator.pop(context,resultList);
                  }
              ),
            ),
          ],
        )
      ),
    );
  }
}


class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({Key? key, required this.controller})
      : super(key: key);

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
            color: Colors.black26,
            child: const Center(
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 100.0,
                semanticLabel: 'Play',
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}
