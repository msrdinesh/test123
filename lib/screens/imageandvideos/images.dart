// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:carousel_pro/carousel_pro.dart';
import 'package:cornext_mobile/screens/imageandvideos/data.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ImageCarousel extends StatefulWidget {
  _ImageCarouselState createState() => new _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  String currentImage = "";
  VideoPlayerController _controller;
  // Future<void> _initializeVideoPlayerFuture;
  @override
  void initState() {
    super.initState();
    setState(() {
      // print('image');
      // print(currentImage);
      _controller = VideoPlayerController.network('https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4')
        ..initialize().then((val) {
          setState(() {});
        });
      // _initializeVidyeoPlayerFuture = _controller.initialize();
      _controller.setLooping(true);
      _controller.setVolume(1.0);
      super.initState();
    });
    setState(() {
      currentImage = flowers[0].imageURL;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  List<Container> _buildListItemsFromFlowers() {
    // int index = 0;
    return flowers.map((flower) {
      var container = Container(
        child: new Row(
          children: <Widget>[
            GestureDetector(
                onTap: () {
                  setState(() {
                    currentImage = flower.imageURL;
                  });
                },
                child: new Container(
                    margin: new EdgeInsets.all(5.0),
                    child: flower.imageURL.indexOf('mp4') == -1
                        ? Image(
                            image: NetworkImage(flower.imageURL),
                            height: 40.0,
                            width: 40.0,
                          )
                        : _controller.value.isInitialized
                            ? Container(
                                height: 40.0,
                                width: 40.0,
                                child: Stack(children: [
                                  Center(child: AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller))),
                                  Center(
                                      child: Icon(
                                    _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                    // label: ,
                                    color: Colors.white,
                                    size: 10,
                                  ))
                                ]),
                              )
                            : Container()))
          ],
        ),
      );
      // index = index + 1;
      return container;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (currentImage.indexOf('mp4') == -1) {
      _controller.pause();
    }
    return Container(
        decoration: BoxDecoration(color: Colors.white),
        height: MediaQuery.of(context).size.height / 4,
        margin: EdgeInsets.only(top: 40),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            flex: 5,
            child: currentImage.indexOf('mp4') == -1
                ? Image(
                    image: NetworkImage(currentImage),
                    fit: BoxFit.cover,
                    // height: 250,
                    // width: MediaQuery.of(context).size.width - 100,
                  )
                : GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_controller.value.isPlaying) {
                          _controller.pause();
                        } else {
                          _controller.play();
                        }
                      });
                    },
                    child: _controller.value.isInitialized
                        ? Container(
                            // flex: 5,
                            // height: 300,
                            constraints: BoxConstraints(maxHeight: 250),
                            child: Stack(children: [
                              Center(child: AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller))),
                              Center(
                                  child: Icon(
                                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                // label: ,
                                color: Colors.white,
                                size: 40,
                              ))
                            ]),
                          )
                        : Container()),
          ),
          Expanded(
              flex: 1,
              // height: 200,
              child: Container(
                  height: 250,
                  child: new ListView(
                    padding: EdgeInsets.only(top: 0),
                    scrollDirection: Axis.horizontal,
                    children: _buildListItemsFromFlowers(),
                  ))),
        ]));
  }
}
