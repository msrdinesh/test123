// import 'package:cornext_mobile/constants/appcolors.dart';
import 'package:cornext_mobile/constants/appstyles.dart';
import 'package:cornext_mobile/services/homescreenservices/homescreenservices.dart';
import 'package:cornext_mobile/services/productsearchandfilterservice/productsearchandfilterservice.dart';
import 'package:flutter/material.dart';
import 'package:cornext_mobile/services/productdetailsservice/productdetailsservice.dart';
import 'package:cornext_mobile/components/widgets/appbarwidget.dart';
import 'package:video_player/video_player.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cornext_mobile/components/widgets/loadingbutton.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:hardware_buttons/hardware_buttons.dart';
// import 'dart:io';
import 'dart:async';

final searchFieldController = TextEditingController();
final searchFieldKey = GlobalKey<FormFieldState>();
final searchFocusNode = FocusNode();
final scaffoldkey = GlobalKey<ScaffoldState>();

class ProductDetailsImagesAndVideosPage extends StatefulWidget {
  @override
  ProductDetailsImagesAndVideos createState() => ProductDetailsImagesAndVideos();
}

class ProductDetailsImagesAndVideos extends State<ProductDetailsImagesAndVideosPage> {
  int currentImageOrVideo;
  List _iconVideoController = [];
  List _controller = [];
  CarouselSlider carouselSlider;
  // StreamSubscription _volumeButtonSubscription;
  final DefaultCacheManager _cacheManager = DefaultCacheManager();

  void initState() {
    showOrHideSearchAndFilter = false;
    setState(() {
      currentImageOrVideo = 0;

      // removeVideoFromImages();

      // Uncomment this when ever video required
      initializeVideo();
    });

    super.initState();
  }

  removeVideoFromImages() {
    productGalleryList.forEach((val) {
      if (val['resourceUrl'].toString().indexOf("mp4") != -1) {
        productGalleryList.removeAt(productGalleryList.indexOf(val));
      }
    });
  }

  initializeVideo() {
    // setState(() {
    //   currentImage = productGallery[0]['resourceUrl'];
    // });
    bool isVideoIntialized = false;
    productGalleryList.forEach((res) {
      if (res['resourceUrl'].toString().indexOf('mp4') != -1) {
        _cacheManager.getSingleFile(res['resourceUrl']).then((cacheVideo) {
          final file = cacheVideo;
          if (file != null) {
            setState(() {
              // print('image');
              // print(currentImage);
              VideoPlayerController _videoController;
              VideoPlayerController _iconController;
              _videoController = VideoPlayerController.file(file)
                ..initialize().then((val) {
                  if (!isVideoIntialized) {
                    setState(() {
                      _videoController.play();
                      isVideoIntialized = true;
                    });
                  }
                });
              _iconController = VideoPlayerController.file(file)
                ..initialize().then((val) {
                  setState(() {
                    _iconController.pause();
                    _iconController.seekTo(Duration(seconds: 8));
                  });
                });
              _videoController.setLooping(true);
              // _videoController.setVolume(0.0);
              Map obj = {
                'controller': _videoController,
                'url': res['resourceUrl']
              };
              Map iconObj = {
                'controller': _iconController,
                'url': res['resourceUrl']
              };
              // _volumeButtonSubscription =
              //     volumeButtonEvents.listen((VolumeButtonEvent event) {
              //   if (_controller != null) {
              //     if (event == VolumeButtonEvent.VOLUME_UP) {
              //       // voulmeController = voulmeController + 1;
              //       setState(() {
              //         _videoController.setVolume(1.0);
              //       });
              //     }
              //   }
              // });
              _controller.add(obj);
              _iconVideoController.add(iconObj);
              // _controller.
              // super.initState();
              // _controller = VideoPlayerController.network(res['resourceUrl']);
              // chewieController = ChewieController(
              //     videoPlayerController: _controller,
              //     aspectRatio: 4 / 3,
              //     allowFullScreen: false,
              //     looping: false);
            });
          }
        });
      } else {
        setState(() {
          // print('image');
          // print(currentImage);
          VideoPlayerController _videoController;
          VideoPlayerController _iconController;
          _videoController = VideoPlayerController.network(res['resourceUrl'])
            ..initialize().then((val) {
              if (!isVideoIntialized) {
                setState(() {
                  _videoController.play();
                  isVideoIntialized = true;
                });
              }
            });
          // File newFile = new File(res['resourceUrl']);
          //     _cacheManager.putFile(
          //         res['resourceUrl'], newFile.readAsBytesSync());

          _iconController = VideoPlayerController.network(res['resourceUrl'])
            ..initialize().then((val) {
              setState(() {
                _iconController.pause();
                _iconController.seekTo(Duration(seconds: 8));
              });
            });
          _videoController.setLooping(true);
          // _videoController.setVolume(0.0);
          // _volumeButtonSubscription =
          //     volumeButtonEvents.listen((VolumeButtonEvent event) {
          //   if (_controller != null) {
          //     if (event == VolumeButtonEvent.VOLUME_UP) {
          //       // voulmeController = voulmeController + 1;
          //       setState(() {
          //         _videoController.setVolume(1.0);
          //       });
          //     }
          //   }
          // });
          Map obj = {
            'controller': _videoController,
            'url': res['resourceUrl']
          };
          Map iconObj = {
            'controller': _iconController,
            'url': res['resourceUrl']
          };
          _controller.add(obj);
          _iconVideoController.add(iconObj);
          // _controller.
          // super.initState();
          // _controller = VideoPlayerController.network(res['resourceUrl']);
          // chewieController = ChewieController(
          //     videoPlayerController: _controller,
          //     aspectRatio: 4 / 3,
          //     allowFullScreen: false,
          //     looping: false);
        });
      }
    });
    if (_controller.length > 0) {
      setState(() {
        allControllers = {
          'productCarouselVideoControllers': _controller
        };
      });
    }
  }

  reset() {
    searchFieldController.clear();
    searchFieldKey.currentState?.reset();
  }

  getSearchedData() {
    if (searchFieldController.text.trim() != '') {
      productSearchData['productSearchData'] = searchFieldController.text.trim();
      List filterProductsData = [];
      filterProducts.forEach((val) {
        if (val['isSelected']) {
          Map obj = {
            'productCategoryId': val['productCategoryId']
          };
          filterProductsData.add(obj);
        }
      });
      if (filterProductsData.length > 0) {
        productSearchData['productCategoryInfo'] = filterProductsData;
      }
      reset();
      _controller.add((videoController) {
        if (videoController['controller'] != null && videoController['controller'].value.initialized) {
          videoController['controller'].pause();
        }
      });
      setState(() {
        showOrHideSearchAndFilter = false;
      });
      Navigator.of(context).pushNamed('/search');
    }
  }

  Future<bool> onBackButtonPressed() async {
    setState(() {
      searchFieldKey.currentState?.reset();
      showOrHideSearchAndFilter = false;
    });

    return true;
  }

  @override
  void dispose() {
    _controller.forEach((videoController) {
      if (videoController['controller'] != null) {
        videoController['controller'].dispose();
      }
    });
    _iconVideoController.forEach((videoController) {
      if (videoController['controller'] != null) {
        videoController['controller'].dispose();
      }
    });
    // _volumeButtonSubscription?.cancel();
    super.dispose();
  }

  List<Container> getImagesAndVideosIcons() {
    // int index = 0;
    return productGalleryList.map((res) {
      var container = Container(
        decoration: BoxDecoration(border: productGalleryList.indexOf(res) == currentImageOrVideo ? Border.all(color: Colors.grey, width: 1) : null),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
                onTap: () {
                  setState(() {
                    currentImageIndex(productGalleryList.indexOf(res));
                  });
                },
                child: new Container(
                    margin: new EdgeInsets.all(5.0),
                    child: res['resourceUrl'].indexOf('mp4') == -1
                        ?
                        // ? Image(
                        //     image: NetworkImage(res['resourceUrl']),
                        //     height: 50.0,
                        //     width: 50.0,
                        //   )
                        CachedNetworkImage(
                            imageUrl: res['resourceUrl'],
                            height: 50.0,
                            width: 50.0,
                          )
                        :
                        // : Container()))

                        // Un comment this when ever vidoe
                        _iconVideoController.indexWhere((val) => val['url'] == res['resourceUrl']) != -1 && _iconVideoController[_iconVideoController.indexWhere((val) => val['url'] == res['resourceUrl'])]['controller'] != null && _iconVideoController[_iconVideoController.indexWhere((val) => val['url'] == res['resourceUrl'])]['controller'].value.initialized
                            ? Container(
                                height: 50.0,
                                width: 50.0,
                                child: Stack(children: [
                                  Center(child: AspectRatio(aspectRatio: _iconVideoController[_iconVideoController.indexWhere((val) => val['url'] == res['resourceUrl'])]['controller'].value.aspectRatio, child: VideoPlayer(_iconVideoController[_iconVideoController.indexWhere((val) => val['url'] == res['resourceUrl'])]['controller']))),
                                  Center(
                                      child: Icon(
                                    Icons.play_arrow,
                                    // label: ,
                                    color: Colors.white,
                                    size: 10,
                                  ))
                                ]),
                              )
                            : Center(
                                child: customizedCircularLoadingIcon(10),
                              )))
          ],
        ),
      );
      // index = index + 1;
      return container;
    }).toList();
  }

  playOrPauseVideo(String url) {
    _controller.forEach((videoController) {
      if (videoController['url'] == url && videoController['controller'].value.isPlaying) {
        setState(() {
          videoController['controller'].pause();
        });
      } else if (videoController['url'] == url && !videoController['controller'].value.isPlaying) {
        setState(() {
          videoController['controller'].play();
        });
      }
    });
  }

  List<Widget> getProductImages() {
    List<Widget> details = [];
    productGalleryList.forEach((res) {
      if (res['resourceUrl'].toString().trim().indexOf('mp4') != -1) {
        // _controller = VideoPlayerController.network(res['resourceUrl']);
        // chewieController = ChewieController(
        //     videoPlayerController: _controller,
        //     aspectRatio: 4 / 3,
        //     allowFullScreen: false,
        //     showControlsOnInitialize: false,
        //     // showControls: false,
        //     looping: false);

        // Uncomment this when ever video required
        details.add(
          GestureDetector(
              onTap: () {
                playOrPauseVideo(res['resourceUrl']);
              },
              child: _controller.indexWhere((val) => val['url'] == res['resourceUrl']) != -1 && _controller[_controller.indexWhere((val) => val['url'] == res['resourceUrl'])]['controller'] != null && _controller[_controller.indexWhere((val) => val['url'] == res['resourceUrl'])]['controller'].value.initialized
                  ? Container(
                      // flex: 5,
                      // height: 300,
                      constraints: BoxConstraints(maxHeight: 250),
                      child: Stack(children: [
                        Center(child: AspectRatio(aspectRatio: _controller[_controller.indexWhere((val) => val['url'] == res['resourceUrl'])]['controller'].value.aspectRatio, child: VideoPlayer(_controller[_controller.indexWhere((val) => val['url'] == res['resourceUrl'])]['controller']))),
                        Center(
                            child: Icon(
                          _controller[_controller.indexWhere((val) => val['url'] == res['resourceUrl'])]['controller'].value.isPlaying ? Icons.pause : Icons.play_arrow,
                          // label: ,
                          color: Colors.white,
                          size: 40,
                        ))
                      ]),
                    )
                  : Center(
                      child: customizedCircularLoadingIcon(30),
                    )),
        );
      } else {
        details.add(PhotoView(
          imageProvider: CachedNetworkImageProvider(res['resourceUrl']),
          backgroundDecoration: BoxDecoration(color: Colors.white),
        ));
      }
    });
    return details;
  }

  currentImageIndex(int index) {
    if (carouselSlider != null) {
      setState(() {
        currentImageOrVideo = index;
        carouselSlider.jumpToPage(index);
      });
    }
  }

  Widget getCarousel() {
    carouselSlider = new CarouselSlider(
      items: getProductImages(),
      initialPage: 0,
      viewportFraction: 1.0,
      aspectRatio: MediaQuery.of(context).orientation == Orientation.portrait ? 1.0 : 3.0,
      onPageChanged: (index) {
        _controller.forEach((videoController) {
          if (videoController['controller'] != null) {
            videoController['controller'].pause();
          }
        });
        setState(() {
          currentImageIndex(index);
        });
      },
    );
    return carouselSlider;
  }

  @override
  Widget build(BuildContext context) {
    if (_controller != null && productGalleryList.length > 0 && productGalleryList[currentImageOrVideo]['resourceUrl'].indexOf('mp4') == -1) {
      _controller.forEach((videoController) {
        if (videoController['controller'] != null) {
          videoController['controller'].pause();
        }
      });
    }

    return WillPopScope(
        onWillPop: onBackButtonPressed,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          key: scaffoldkey,
          appBar: appBarWidgetWithIconsAnSearchboxAndFilterIcon(context, true, this.setState, false, '/productvideosandimages', searchFieldKey, searchFieldController, searchFocusNode, scaffoldkey),
          endDrawer: showOrHideSearchAndFilter ? filterDrawer(this.setState, context, scaffoldkey, false, searchFieldController) : null,
          body: Column(children: <Widget>[
            Column(children: <Widget>[
              // AppStyles().customPadding(5),
              // margin: EdgeInsets.only(top: 55),

              AppStyles().customPadding(1),
              // showOrHideSearchAndFilter
              //     ? Container(
              //         margin: EdgeInsets.only(left: 10, top: 1),
              //         height: 40,
              //         child: Row(children: [
              //           Expanded(
              //               flex: 8,
              //               child: TextFormField(
              //                   cursorColor: mainAppColor,
              //                   controller: searchFieldController,
              //                   onFieldSubmitted: (val) {
              //                     getSearchedData();
              //                   },
              //                   key: searchFieldKey,
              //                   focusNode: searchFocusNode,
              //                   decoration: InputDecoration(
              //                       counterText: "",
              //                       // alignLabelWithHint: true,
              //                       hintText: "Search",
              //                       border: AppStyles().searchBarBorder,
              //                       // prefix: Text("+91 "),
              //                       contentPadding:
              //                           EdgeInsets.fromLTRB(14, 0, 0, 0),
              //                       focusedBorder:
              //                           AppStyles().focusedSearchBorder,
              //                       suffixIcon: IconButton(
              //                         padding: EdgeInsets.all(0),
              //                         icon: Icon(Icons.search),
              //                         onPressed: () {
              //                           getSearchedData();
              //                         },
              //                         color: mainAppColor,
              //                         tooltip: 'Search',
              //                         // iconSize: 24,
              //                       )))),
              //           Expanded(
              //               child: IconButton(
              //             padding: EdgeInsets.all(0),
              //             icon: Icon(Icons.filter_list),
              //             onPressed: () {
              //               scaffoldkey.currentState.openEndDrawer();
              //             },
              //             color: mainAppColor,

              //             tooltip: 'Filter',
              //             // iconSize: 14,
              //           )),
              //           // child: FlatButton.icon(
              //           //   icon: Icon(Icons.filter_list),
              //           //   onPressed: () {},
              //           //   label: Text("Filter"),
              //           // ),
              //           // )
              //         ]))
              //     : Container(),
            ]),
            Padding(padding: EdgeInsets.only(top: 30)),
            Container(
                decoration: BoxDecoration(color: Colors.white),
                // height: MediaQuery.of(context).size.height / 4,
                margin: EdgeInsets.only(top: 30),
                child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(alignment: Alignment.center, child: getCarousel()
                      // currentImageOrVideo.indexOf('mp4') == -1
                      //     ? Image(
                      //         image: NetworkImage(currentImageOrVideo),
                      //         fit: BoxFit.cover,
                      //         // height: 250,
                      //         // width: MediaQuery.of(context).size.width - 100,
                      //       )
                      //     : GestureDetector(
                      //         onTap: () {
                      //           setState(() {
                      //             if (_controller.value.isPlaying) {
                      //               _controller.pause();
                      //             } else {
                      //               _controller.play();
                      //             }
                      //           });
                      //         },
                      //         child: _controller.value.initialized
                      //             ? Container(
                      //                 // flex: 5,
                      //                 // height: 300,
                      //                 constraints: BoxConstraints(maxHeight: 250),
                      //                 child: Stack(children: [
                      //                   Center(
                      //                       child: AspectRatio(
                      //                           aspectRatio:
                      //                               _controller.value.aspectRatio,
                      //                           child: VideoPlayer(_controller))),
                      //                   Center(
                      //                       child: Icon(
                      //                     _controller.value.isPlaying
                      //                         ? Icons.pause
                      //                         : Icons.play_arrow,
                      //                     // label: ,
                      //                     color: Colors.white,
                      //                     size: 40,
                      //                   ))
                      //                 ]),
                      //               )
                      //             : Container()),
                      ),
                  // height: 200,
                ])),
          ]),
          floatingActionButton: Container(
              height: 50,
              margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 8),
              alignment: Alignment.center,
              child: new ListView(
                scrollDirection: Axis.horizontal,
                children: getImagesAndVideosIcons(),
              )),
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        ));
  }
}
