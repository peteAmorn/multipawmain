import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:sizer/sizer.dart';

bool? isMute;
class videoPreview extends StatefulWidget {
  final String url;
  videoPreview({required this.url});

  @override
  _videoPreviewState createState() => _videoPreviewState();
}

class _videoPreviewState extends State<videoPreview> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    setState(() {
      isMute = true;
    });

    _controller = VideoPlayerController.network(
        widget.url);
    _controller.addListener(() {
      setState(() {});
    });
    _controller.initialize().then((_) => setState(() {}));
    _controller.setVolume(0.0);
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
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  _ControlsOverlay({Key? key, required this.controller})
      : super(key: key);
  static const List<double> _playSpeed = <double>[
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
  ];
  bool isTablet = false;
  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    SizerUtil.deviceType == DeviceType.tablet?isTablet = true:isTablet = false;
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
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(

              vertical: isTablet?40:20,
              horizontal: isTablet?40:20,
            ),
            child: InkWell(
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade500
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ),
              onTap: () => Navigator.pop(context),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: isTablet?40:20,
                horizontal: isTablet?40:20,
            ),
            child: InkWell(
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade500
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Icon(
                    isMute == true?FontAwesomeIcons.volumeMute:FontAwesomeIcons.volumeUp,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ),
              onTap: () {
                isMute == true?controller.setVolume(1.0):controller.setVolume(0.0);
                isMute == true?isMute = false: isMute = true;
              },
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (double speed) {
              controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<double>>[
                for (final double speed in _playSpeed)
                  PopupMenuItem<double>(
                    value: speed,
                    child: Text('${speed}x',style: TextStyle(fontSize: 15,color: Colors.black)),
                  )
              ];
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: isTablet?40:20,
                horizontal: isTablet?40:20,
              ),
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade500
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text('${controller.value.playbackSpeed}x',style: TextStyle(fontSize: 15,color: Colors.white)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
