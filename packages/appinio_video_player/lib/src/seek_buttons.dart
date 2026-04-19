import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:flutter/material.dart';

class SeekButtons extends StatefulWidget {
  final CustomVideoPlayerController customVideoPlayerController;

  const SeekButtons({Key? key, required this.customVideoPlayerController})
      : super(key: key);

  @override
  State<SeekButtons> createState() => _SeekButtonsState();
}

class _SeekButtonsState extends State<SeekButtons> {
  bool _areControlsVisible = true;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _areControlsVisible =
        widget.customVideoPlayerController.areControlsVisible.value;
    _isPlaying = widget
        .customVideoPlayerController.videoPlayerController.value.isPlaying;
    widget.customVideoPlayerController.areControlsVisible.addListener(() {
      if (!mounted) return;
      setState(() {
        _areControlsVisible =
            widget.customVideoPlayerController.areControlsVisible.value;
      });
    });
    widget.customVideoPlayerController.videoPlayerController
        .addListener(_onVideoChanged);
  }

  @override
  void dispose() {
    widget.customVideoPlayerController.videoPlayerController
        .removeListener(_onVideoChanged);
    super.dispose();
  }

  void _onVideoChanged() {
    if (!mounted) return;
    final playing = widget
        .customVideoPlayerController.videoPlayerController.value.isPlaying;
    if (playing != _isPlaying) {
      setState(() {
        _isPlaying = playing;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 300),
      child: _areControlsVisible
          ? Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCircularButton(
                    icon: Icons.fast_rewind_rounded,
                    onTap: onSeekForward,
                    size: 48,
                    iconSize: 32,
                  ),
                  const SizedBox(width: 32),
                  _buildCircularButton(
                    icon: _isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    onTap: () => _playPause(_isPlaying),
                    size: 64,
                    iconSize: 42,
                  ),
                  const SizedBox(width: 32),
                  _buildCircularButton(
                    icon: Icons.fast_forward_rounded,
                    onTap: onSeekBack,
                    size: 48,
                    iconSize: 32,
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onTap,
    required double size,
    required double iconSize,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color.fromRGBO(0, 0, 0, 0.35),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: iconSize,
        ),
      ),
    );
  }

  Future<void> _playPause(bool isPlaying) async {
    if (isPlaying) {
      await widget.customVideoPlayerController.videoPlayerController.pause();
    } else {
      if (widget.customVideoPlayerController.customVideoPlayerSettings
              .playOnlyOnce &&
          widget.customVideoPlayerController.playedOnceNotifier.value) {
        return;
      }
      await widget.customVideoPlayerController.videoPlayerController.play();
    }
  }

  void onSeekBack() async {
    Duration? currentPosition =
        await widget.customVideoPlayerController.videoPlayerController.position;
    Duration seekDuration = widget
        .customVideoPlayerController.customVideoPlayerSettings.seekDuration;
    if (currentPosition != null) {
      Duration seekResult = Duration(
          microseconds:
              currentPosition.inMicroseconds + seekDuration.inMicroseconds);
      widget.customVideoPlayerController.videoPlayerController
          .seekTo(seekResult);
    }
  }

  void onSeekForward() async {
    Duration? currentPosition =
        await widget.customVideoPlayerController.videoPlayerController.position;
    Duration seekDuration = widget
        .customVideoPlayerController.customVideoPlayerSettings.seekDuration;
    if (currentPosition != null) {
      Duration seekResult = Duration(
          microseconds:
              currentPosition.inMicroseconds - seekDuration.inMicroseconds);
      widget.customVideoPlayerController.videoPlayerController
          .seekTo(seekResult);
    }
  }
}
