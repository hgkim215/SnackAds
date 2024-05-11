import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:snack_ads/controller/feed_controller.dart';
import 'package:snack_ads/model/shortform.dart';
import 'package:snack_ads/view/feed/feed_column_buttons.dart';
import 'package:snack_ads/view/feed/feed_view_description.dart';
import 'package:video_player/video_player.dart';

import 'feed_report_buttons_component.dart';

class FeedView extends StatefulWidget {
  final FeedController feedProvider;
  const FeedView({super.key, required this.feedProvider});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView>
    with SingleTickerProviderStateMixin {
  ShortForm tempVideo = ShortForm(
      description: ' ', name: ' ', videoURL: ' ', videoVid: ' ', likes: 0);

  bool _isVisible = false;

  void _togglePlayAndPauseVisibility() {
    setState(() {
      _isVisible = !_isVisible;
      if (_isVisible) {
        Future.delayed(const Duration(milliseconds: 750), () {
          setState(() {
            _isVisible = false;
          });
        });
      }
    });
  }

  @override
  void initState() {
    widget.feedProvider.loadVideos();
    super.initState();
  }

  @override
  void dispose() {
    widget.feedProvider.disposeAllController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        //  TODO: 새로고침시 새로운 영상 불러오기 추가
        onRefresh: () async {
          // setState(() {
          //   widget.feedProvider.loadVideos();
          // });
        },
        color: Colors.black,
        child: (widget.feedProvider.videoList.isNotEmpty)
            ? feedScreen(
                widget.feedProvider, _isVisible, _togglePlayAndPauseVisibility)
            : SafeArea(
                child: Stack(
                  children: [
                    const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                    buttonUITemp(tempVideo),
                  ],
                ),
              ),
      ),
    );
  }
}

Widget feedScreen(FeedController feedProvider, bool isVisible,
    Function togglePlayAndPauseVisibility) {
  PageController pageController = PageController(
    initialPage: 0,
    viewportFraction: 1,
  );

  return PageView.builder(
    controller: pageController,
    itemCount: feedProvider.videoList.length,
    scrollDirection: Axis.vertical,
    onPageChanged: (index) {
      index = index % (feedProvider.videoList.length);
      feedProvider.changeVideo(index);
      if (index == feedProvider.videoList.length - 1) {
        //  TODO: 마지막 영상에 이르면 추가 로딩 기능 구현
      }
    },
    itemBuilder: (context, index) {
      index = index % (feedProvider.videoList.length);
      return videoScreen(feedProvider.videoList[index], isVisible,
          togglePlayAndPauseVisibility, context, pageController);
    },
  );
}

Widget videoScreen(
    ShortForm video,
    bool isVisible,
    Function togglePlayAndPauseVisibility,
    BuildContext context,
    PageController pageController) {
  return SafeArea(
    child: Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              video.controller != null
                  ? GestureDetector(
                      onTap: () {
                        togglePlayAndPauseVisibility();
                        if (video.controller!.value.isPlaying) {
                          video.controller?.pause();
                        } else {
                          video.controller?.play();
                        }
                      },
                      child: SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: SizedBox(
                            width: video.controller?.value.size.width ?? 0,
                            height: video.controller?.value.size.height ?? 0,
                            child: VideoPlayer(video.controller!),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.black,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    ),
              video.controller != null
                  ? Center(
                      child: AnimatedOpacity(
                        opacity: isVisible ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 500),
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                          ),
                          child: Center(
                            child: Icon(
                              (video.controller!.value.isPlaying)
                                  ? FontAwesomeIcons.circlePlay
                                  : FontAwesomeIcons.circlePause,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              buttonUI(video, context, pageController),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget buttonUI(
    ShortForm video, BuildContext context, PageController pageController) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 5),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            reportButtonComponent(context, video, pageController),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FeedViewDescription(
              videoRestaurantName: video.name,
              videoDescription: video.description,
            ),
            FeedColumnButtons(
              likes: video.likes,
            ),
          ],
        ),
      ],
    ),
  );
}

Widget buttonUITemp(ShortForm video) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 5),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(FontAwesomeIcons.ellipsisVertical,
                size: 25, color: Colors.grey[300]),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FeedViewDescription(
              videoRestaurantName: video.name,
              videoDescription: video.description,
            ),
            FeedColumnButtons(
              likes: video.likes,
            ),
          ],
        ),
      ],
    ),
  );
}
