import 'package:appinio_video_player/src/custom_video_player_controller.dart';
import 'package:flutter/material.dart';
import 'package:cached_video_player/cached_video_player.dart';

class CustomVideoPlayerProgressBar extends StatefulWidget {
  final CustomVideoPlayerController customVideoPlayerController;

  const CustomVideoPlayerProgressBar({
    Key? key,
    required this.customVideoPlayerController,
  }) : super(key: key);

  @override
  _VideoProgressIndicatorState createState() => _VideoProgressIndicatorState();
}

class _VideoProgressIndicatorState extends State<CustomVideoPlayerProgressBar> {
  bool _areControlsVisible = true;
  bool _videoPlaying = false;

  @override
  void initState() {
    super.initState();
    widget.customVideoPlayerController.videoPlayerController
        .addListener(_updateWidgetListener);
    _areControlsVisible =
        widget.customVideoPlayerController.areControlsVisible.value;
    widget.customVideoPlayerController.areControlsVisible.addListener(_onControlsVisibilityChanged);
  }

  @override
  void dispose() {
    widget.customVideoPlayerController.videoPlayerController
        .removeListener(_updateWidgetListener);
    widget.customVideoPlayerController.areControlsVisible
        .removeListener(_onControlsVisibilityChanged);
    super.dispose();
  }

  void _onControlsVisibilityChanged() {
    if (!mounted) return;
    setState(() {
      _areControlsVisible =
          widget.customVideoPlayerController.areControlsVisible.value;
    });
  }

  void _updateWidgetListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.customVideoPlayerController.customVideoPlayerSettings
        .customVideoPlayerProgressBarSettings;

    if (!settings.showProgressBar) {
      return const SizedBox(width: double.infinity);
    }

    if (!widget.customVideoPlayerController.videoPlayerController.value
        .isInitialized) {
      return LinearProgressIndicator(
        value: null,
        valueColor: AlwaysStoppedAnimation<Color>(settings.progressColor),
        backgroundColor: settings.backgroundColor,
      );
    }

    final int duration = widget.customVideoPlayerController
        .videoPlayerController.value.duration.inMilliseconds;
    if (duration == 0) return const SizedBox(width: double.infinity);

    int maxBuffering = 0;
    for (DurationRange range in widget
        .customVideoPlayerController.videoPlayerController.value.buffered) {
      final int end = range.end.inMilliseconds;
      if (end > maxBuffering) {
        maxBuffering = end;
      }
    }
    final double bufferedFraction = maxBuffering / duration;

    return ValueListenableBuilder<Duration>(
      valueListenable: widget.customVideoPlayerController.videoProgressNotifier,
      builder: (context, progress, child) {
        final double progressFraction = progress.inMilliseconds / duration;

        return LayoutBuilder(
          builder: (context, constraints) {
            final double totalWidth = constraints.maxWidth;
            final double thumbSize = _areControlsVisible ? 12.0 : 0.0;
            final double barHeight = settings.progressBarHeight;
            // Total height includes space for the thumb to extend above/below
            // final double totalHeight = _areControlsVisible ? thumbSize + 4 : barHeight;
            final double totalHeight = barHeight;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: settings.allowScrubbing
                  ? (details) => _seekToPosition(details.localPosition.dx, totalWidth)
                  : null,
              onHorizontalDragStart: settings.allowScrubbing
                  ? (details) {
                      _videoPlaying = widget.customVideoPlayerController
                          .videoPlayerController.value.isPlaying;
                      if (_videoPlaying) {
                        widget.customVideoPlayerController.videoPlayerController
                            .pause();
                      }
                    }
                  : null,
              onHorizontalDragUpdate: settings.allowScrubbing
                  ? (details) => _seekToPosition(details.localPosition.dx, totalWidth)
                  : null,
              onHorizontalDragEnd: settings.allowScrubbing
                  ? (details) {
                      if (_videoPlaying) {
                        widget.customVideoPlayerController.videoPlayerController
                            .play();
                      }
                    }
                  : null,
              child: SizedBox(
                width: totalWidth,
                height: totalHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.centerLeft,
                  children: [
                    // Background bar
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: settings.backgroundColor,
                          borderRadius: BorderRadius.circular(settings.progressBarBorderRadius),
                        ),
                      ),
                    ),
                    // Buffered bar
                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: Container(
                        width: totalWidth * bufferedFraction.clamp(0.0, 1.0),
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: settings.bufferedColor,
                          borderRadius: BorderRadius.circular(settings.progressBarBorderRadius),
                        ),
                      ),
                    ),
                    // Progress bar
                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: Container(
                        width: totalWidth * progressFraction.clamp(0.0, 1.0),
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: settings.progressColor,
                          borderRadius: BorderRadius.circular(settings.progressBarBorderRadius),
                        ),
                      ),
                    ),
                    // Draggable red circle thumb
                    if (_areControlsVisible)
                      Positioned(
                        left: (totalWidth * progressFraction.clamp(0.0, 1.0)) - thumbSize / 2,
                        bottom: (barHeight - thumbSize) / 2,
                        child: Container(
                            width: thumbSize,
                            height: thumbSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: settings.progressColor,
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _seekToPosition(double localX, double totalWidth) {
    final double relative = (localX / totalWidth).clamp(0.0, 1.0);
    final Duration position = widget
            .customVideoPlayerController.videoPlayerController.value.duration *
        relative;
    widget.customVideoPlayerController.videoPlayerController.seekTo(position);
    widget.customVideoPlayerController.videoProgressNotifier.value = position;
  }
}
