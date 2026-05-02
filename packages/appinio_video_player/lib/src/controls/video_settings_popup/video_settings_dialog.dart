import 'package:appinio_video_player/src/controls/video_settings_popup/video_settings_dialog_item.dart';
import 'package:appinio_video_player/src/controls/video_settings_popup/video_settings_playback_speed_dialog.dart';
import 'package:appinio_video_player/src/controls/video_settings_popup/video_settings_quality_dialog.dart';
import 'package:appinio_video_player/src/custom_video_player_controller.dart';
import 'package:flutter/material.dart';

import 'package:appinio_video_player/appinio_video_player.dart';

class VideoSettingsDialog extends StatelessWidget {
  final CustomVideoPlayerController customVideoPlayerController;
  final Function updateViewOnClose;
  const VideoSettingsDialog({
    Key? key,
    required this.customVideoPlayerController,
    required this.updateViewOnClose,
  }) : super(key: key);

  BuildContext? _resolveNavigatorContext(BuildContext context) {
    final configuredContext =
        customVideoPlayerController.customVideoPlayerSettings.navigatorContext;

    return Navigator.maybeOf(context, rootNavigator: true)?.context ??
        (configuredContext != null
            ? Navigator.maybeOf(configuredContext, rootNavigator: true)?.context
            : null) ??
        Navigator.maybeOf(context)?.context ??
        (configuredContext != null
            ? Navigator.maybeOf(configuredContext)?.context
            : null);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: customVideoPlayerController.customVideoPlayerSettings
                .customVideoPlayerPopupSettings.popupDecoration.borderRadius ??
            BorderRadius.zero,
      ),
      child: Container(
        padding: customVideoPlayerController.customVideoPlayerSettings
            .customVideoPlayerPopupSettings.popupPadding,
        width: customVideoPlayerController.customVideoPlayerSettings
            .customVideoPlayerPopupSettings.popupWidth,
        decoration: customVideoPlayerController.customVideoPlayerSettings
            .customVideoPlayerPopupSettings.popupDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              customVideoPlayerController.customVideoPlayerSettings
                  .customVideoPlayerPopupSettings.popupTitle,
              style: customVideoPlayerController.customVideoPlayerSettings
                  .customVideoPlayerPopupSettings.popupTitleTextStyle,
            ),
            const SizedBox(
              height: 8,
            ),
            Column(
              children: [
                if (customVideoPlayerController.additionalVideoSources != null)
                  if (customVideoPlayerController
                      .additionalVideoSources!.isNotEmpty)
                    VideoSettingsDialogItem(
                      title: customVideoPlayerController
                          .customVideoPlayerSettings
                          .customVideoPlayerPopupSettings
                          .popupQualityTitle,
                      popupSettings: customVideoPlayerController
                          .customVideoPlayerSettings
                          .customVideoPlayerPopupSettings,
                      onPressed: () => _openSubSettingsDialog(
                        context: context,
                        isQuality: true,
                      ),
                    ),
                VideoSettingsDialogItem(
                  title: customVideoPlayerController.customVideoPlayerSettings
                      .customVideoPlayerPopupSettings.popupPlaybackSpeedTitle,
                  popupSettings: customVideoPlayerController
                      .customVideoPlayerSettings.customVideoPlayerPopupSettings,
                  onPressed: () => _openSubSettingsDialog(
                    context: context,
                    isQuality: false,
                  ),
                ),
                if (customVideoPlayerController
                        .customVideoPlayerSettings.onSwitchToAudioVideoTapped !=
                    null)
                  VideoSettingsDialogItem(
                    title: customVideoPlayerController
                            .customVideoPlayerSettings.isAudioMode
                        ? customVideoPlayerController.customVideoPlayerSettings
                            .customVideoPlayerPopupSettings.popupSwitchToVideoTitle
                        : customVideoPlayerController.customVideoPlayerSettings
                            .customVideoPlayerPopupSettings.popupSwitchToAudioTitle,
                    popupSettings: customVideoPlayerController
                        .customVideoPlayerSettings
                        .customVideoPlayerPopupSettings,
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      customVideoPlayerController
                          .customVideoPlayerSettings.onSwitchToAudioVideoTapped!();
                    },
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  _openSubSettingsDialog({
    required BuildContext context,
    required bool isQuality,
  }) async {
    final dialogContext = _resolveNavigatorContext(context);
    if (dialogContext == null) {
      debugPrint(
        'VideoSettingsDialog: Unable to open sub-settings dialog because no Navigator was found.',
      );
      return;
    }

    Navigator.of(context, rootNavigator: true).pop(); //close old popup
    await showGeneralDialog(
        context: dialogContext,
        useRootNavigator: true,
        barrierDismissible: true,
        barrierLabel: "custom_video_player_controls_barrier2",
        pageBuilder: (context, _, __) {
          return isQuality
              ? VideoSettingsQualityDialog(
                  customVideoPlayerController: customVideoPlayerController,
                  updateView: updateViewOnClose,
                )
              : VideoSettingsPlaybackSpeedDialog(
                  customVideoPlayerController: customVideoPlayerController,
                );
        });
    updateViewOnClose();
  }
}
