import 'package:appinio_video_player/src/controls/all_controls_overlay.dart';
import 'package:appinio_video_player/src/controls/progress_bar.dart';
import 'package:appinio_video_player/src/custom_video_player_controller.dart';
import 'package:appinio_video_player/src/seek_buttons.dart';
import 'package:appinio_video_player/src/thumbnail.dart';
import 'package:appinio_video_player/src/volume_control.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_video_player/cached_video_player.dart';

class EmbeddedVideoPlayer extends StatefulWidget {
  final CustomVideoPlayerController customVideoPlayerController;
  final bool isFullscreen;

  const EmbeddedVideoPlayer({
    Key? key,
    required this.customVideoPlayerController,
    this.isFullscreen = false,
  }) : super(key: key);

  @override
  State<EmbeddedVideoPlayer> createState() => _EmbeddedVideoPlayerState();
}

class _EmbeddedVideoPlayerState extends State<EmbeddedVideoPlayer> {
  @override
  void initState() {
    super.initState();

    if (!widget.isFullscreen) {
      widget.customVideoPlayerController.updateViewAfterFullscreen =
          _updateVideoState;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.customVideoPlayerController.videoPlayerController.value
        .isInitialized) {
      return AspectRatio(
        aspectRatio: widget.isFullscreen
            ? widget.customVideoPlayerController.videoPlayerController.value
                .aspectRatio
            : widget.customVideoPlayerController.customVideoPlayerSettings
                    .customAspectRatio ??
                widget.customVideoPlayerController.videoPlayerController.value
                    .aspectRatio,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              color: CupertinoColors.black,
            ),
            Center(
              child: AspectRatio(
                aspectRatio: widget.customVideoPlayerController
                    .videoPlayerController.value.aspectRatio,
                child: IgnorePointer(
                  child: CachedVideoPlayer(
                    widget.customVideoPlayerController.videoPlayerController,
                  ),
                ),
              ),
            ),
            Thumbnail(
              customVideoPlayerController: widget.customVideoPlayerController,
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom: widget.isFullscreen ? 38 : 0,
                left: widget.isFullscreen ? 16 : 0,
                right: widget.isFullscreen ? 16 : 0,
              ),
              child: AllControlsOverlay(
                customVideoPlayerController:
                    widget.customVideoPlayerController,
                updateVideoState: _updateVideoState,
              ),
            ),
            if (widget.customVideoPlayerController.customVideoPlayerSettings
                .showSeekButtons)
              SeekButtons(
                customVideoPlayerController: widget.customVideoPlayerController,
              ),
            VolumeControls(
              customVideoPlayerController: widget.customVideoPlayerController,
            ),
            // Progress bar at the very bottom edge — fades in/out together
            // with the rest of the controls via [areControlsVisible].
            if (widget.customVideoPlayerController.customVideoPlayerSettings
                .customVideoPlayerProgressBarSettings.showProgressBar)
              Positioned(
                left: widget.isFullscreen ? 26 : 0,
                right: widget.isFullscreen ? 26 : 0,
                bottom: widget.isFullscreen ? 36 : 0,
                child: ValueListenableBuilder<bool>(
                  valueListenable:
                      widget.customVideoPlayerController.areControlsVisible,
                  builder: (context, visible, child) {
                    return IgnorePointer(
                      ignoring: !visible,
                      child: AnimatedOpacity(
                        opacity: visible ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: child,
                      ),
                    );
                  },
                  child: CustomVideoPlayerProgressBar(
                    customVideoPlayerController:
                        widget.customVideoPlayerController,
                  ),
                ),
              ),
          ],
        ),
      );
    } else {
      return widget.customVideoPlayerController.customVideoPlayerSettings
              .placeholderWidget ??
          const SizedBox.shrink();
    }
  }

  void _updateVideoState() {
    if (mounted) {
      setState(() {});
    }
  }
}
