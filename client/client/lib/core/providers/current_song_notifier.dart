import 'package:client/features/home/model/song_model.dart';
import 'package:client/features/home/repositories/home_local_repo.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:just_audio/just_audio.dart';

part 'current_song_notifier.g.dart';

@riverpod
class CurrentSongNotifier extends _$CurrentSongNotifier {
  AudioPlayer? audioPlayer;
  bool isPlaying = false;
  late HomeLocalRepository _homeLocalRepository;

  @override
  SongModel? build() {
    _homeLocalRepository = ref.watch(homeLocalRepositoryProvider);
    //return type is SongModel and we dont have any song to play initially   (notifier for songModel)
    return null;
  }

  void updateSong(SongModel song) async {
    await audioPlayer?.stop();        //if no song is playing then this wont run(because audioPlayer is null), else the already playing song(old instance) will stop and a new instance will be created.
    audioPlayer = AudioPlayer(); //new instance for a new song

    final audioSource = AudioSource.uri(            //load the audio source
      Uri.parse(song.audio_url),
      tag: MediaItem(id: song.id, title: song.song_name, artist: song.artist, artUri: Uri.parse(song.image_url),),
    );
    await audioPlayer!.setAudioSource(audioSource);
    //audioPlayer!.positionStream;

    audioPlayer!.playerStateStream.listen(
      //using a stream here because we need to listen every state of the audio player ,not the only time this code is run but also after
      //as state can be changed after is line is executed too
      (player) {
        if (player.processingState == ProcessingState.completed) {
          audioPlayer!.seek(Duration
              .zero); //reset the duration upon completion and pause the audio and update the state to update the icon button
          audioPlayer!.pause();
          isPlaying = false;
          state = state?.copyWith(hex_code: state?.hex_code);
        }
      },
    );
    _homeLocalRepository.uploadSongToLocal(song);
    audioPlayer!.play();
    isPlaying = true;
    state = song; //very imp. line as this sets the song globally and from here on we can get access to currentSongNotifierProvider (SongModel attributes) anywhere else
  }

  void playPauseInMusic() async {
    if (isPlaying) {
      audioPlayer!.pause();
    } else {
      audioPlayer!.play();
    }
    isPlaying = !isPlaying;
    state = state?.copyWith(
        hex_code: state
            ?.hex_code); //tricking riverpod into rebuilding the ui, cant do state = state
  }

  void seek(double val) {
    audioPlayer!.seek(
      Duration(
        milliseconds: (val * audioPlayer!.duration!.inMilliseconds).toInt(),   
      ),
    );
  }
}
