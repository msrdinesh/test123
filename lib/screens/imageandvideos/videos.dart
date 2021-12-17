// import 'package:cornext_mobile/screens/imageandvideos/samplevideos.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoDetailsPage extends StatefulWidget {
  @override
  VideoDetails createState() => VideoDetails();
}

class VideoDetails extends State<VideoDetailsPage> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    _controller = VideoPlayerController.network(
        "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4");
    //_controller = VideoPlayerController.asset("videos/sample_video.mp4");
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
    _controller.setVolume(1.0);
    super.initState();
  }

//first

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Video Demo"),
        ),
        body: GestureDetector(
            onTap: () {
              setState(() {
                if (_controller.value.isPlaying) {
                  _controller.pause();
                } else {
                  _controller.play();
                }
              });
            },
            child: Stack(children: [
              FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Center(
                        child: AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller)));
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
              Center(
                  child: IconButton(
                icon: Icon(_controller.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow),
                onPressed: () {},
                // label: ,
              ))
              // floatingActionButton: FloatingActionButton(
              //   onPressed: () {
              //     setState(() {
              //       if (_controller.value.isPlaying) {
              //         _controller.pause();
              //       } else {
              //         _controller.play();
              //       }
              //     });
              //   },
              //   child:
              //       Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
              // ),
            ])));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// class FlightImageAsset extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     AssetImage assetImage = AssetImage('assets/images/cornext-logo-1.jpg');
//     Image image = Image(
//       image: assetImage,
//       width: 22.0,
//       height: 2.0,
//     );
//     return Container(
//       child: image,
//     );
//   }
// }

//second
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Video Player'),
//       ),
//       body: ListView(
//         children: <Widget>[
//           // ChewieListItem(
//           //   videoPlayerController: VideoPlayerController.asset(
//           //     'videos/IntroVideo.mp4',
//           //   ),
//           //   looping: true,
//           // ),
//           // ChewieListItem(
//           //   videoPlayerController: VideoPlayerController.network(
//           //     'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
//           //   ),
//           // ),
//           ChewieListItem(
//             // This URL doesn't exist - will display an error
//             videoPlayerController: VideoPlayerController.network(
//                 "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4"),
//           ),
//         ],
//       ),
//     );
//   }
// }
