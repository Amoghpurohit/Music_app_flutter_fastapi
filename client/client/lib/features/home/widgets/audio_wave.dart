import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class AudioWaveForm extends StatefulWidget {
  const AudioWaveForm({super.key, required this.path});

  final String path;

  @override
  State<AudioWaveForm> createState() => _AudioWaveFormState();
}

class _AudioWaveFormState extends State<AudioWaveForm> {
  final PlayerController playerController = PlayerController();

  @override
  void initState() {
    super.initState();
    toPreparePlayerContoller();
  }

  void toPreparePlayerContoller() async {
    await playerController.preparePlayer(path: widget.path);
  }

  Future<void> playNpauseAudio() async {
    if (!playerController.playerState.isPlaying) {
      await playerController.startPlayer(finishMode: FinishMode.stop);
    } else if (!playerController.playerState.isPaused) {
      playerController.pausePlayer();
    }
    setState(() {});
  }

  @override
  void dispose() {
    playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
            onPressed: playNpauseAudio,
            icon: playerController.playerState.isPlaying
                ? const Icon(Icons.pause, size: 35,)
                : const Icon(Icons.play_arrow_rounded, size: 35,)),
        Expanded(
          child: AudioFileWaveforms(
              playerWaveStyle: const PlayerWaveStyle(
                fixedWaveColor: Pallete.borderColor,
                liveWaveColor: Pallete.gradient2,
                spacing: 7,
                //showSeekLine: false,
              ),
              size: const Size(double.infinity, 100),
              playerController: playerController,
              waveformType: WaveformType.long,
          ),  
        ),
      ],
    );
  }
}
