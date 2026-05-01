import 'package:appinio_video_player/src/custom_video_player_controller.dart';
import 'package:flutter/material.dart';
import 'package:appinio_video_player/src/controls/fullscreen_button.dart';

class CustomVideoPlayerControlBar extends StatelessWidget {
  final CustomVideoPlayerController customVideoPlayerController;
  final Function updateVideoState;
  final Function fadeOutOnPlay;
  const CustomVideoPlayerControlBar({
    Key? key,
    required this.customVideoPlayerController,
    required this.updateVideoState,
    required this.fadeOutOnPlay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: customVideoPlayerController
          .customVideoPlayerSettings.controlBarPadding,
      decoration: customVideoPlayerController
          .customVideoPlayerSettings.controlBarDecoration,
      child: Row(
        children: [
          if (customVideoPlayerController
              .customVideoPlayerSettings.showDurationPlayed)
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: ValueListenableBuilder<Duration>(
                valueListenable:
                    customVideoPlayerController.videoProgressNotifier,
                builder: ((context, progress, child) {
                  return Text(
                    "${getDurationAsString(progress)} / ${getDurationAsString(customVideoPlayerController
                            .videoPlayerController.value.duration)}",
                    style: customVideoPlayerController
                        .customVideoPlayerSettings.durationPlayedTextStyle,
                  );
                }),
              ),
            ),
          const Spacer(),
          if (customVideoPlayerController
              .customVideoPlayerSettings.showFullscreenButton)
            CustomVideoPlayerFullscreenButton(
              customVideoPlayerController: customVideoPlayerController,
            ),
        ],
      ),
    );
  }

  String getDurationAsString(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String twoDigitHours = twoDigits(duration.inHours);
    if (int.parse(twoDigitMinutes) < 0) twoDigitMinutes = "00";
    if (int.parse(twoDigitSeconds) < 0) twoDigitSeconds = "00";
    if (int.parse(twoDigitHours) < 0) twoDigitHours = "00";
    if (duration > const Duration(hours: 1)) {
      return "$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$twoDigitMinutes:$twoDigitSeconds";
    }
  }
}
