import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/features/home/model/song_model.dart';
import 'package:client/features/home/viewModel/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MusicPlayer extends ConsumerWidget {
  const MusicPlayer({super.key, required this.song});

  final SongModel song;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songInstance = ref.watch(currentSongNotifierProvider);
    final songStateInstance = ref.watch(currentSongNotifierProvider.notifier);
    if (songInstance == null) {
      return const SizedBox();
    }

    final screenHeight = MediaQuery.of(context).size.height;
    //final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      //backgroundColor: Pallete.gradient2,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Pallete.gradient2,
              Pallete.gradient3,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                height: screenHeight * 0.1,
                width: double.infinity,
                child: InkWell(
                  highlightColor: Pallete.transparentColor,
                  focusColor: Pallete.transparentColor,
                  splashColor: Pallete.transparentColor,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Image.asset(
                    'assets/images/pull-down-arrow.png',
                    width: 50,
                    height: 50,
                    alignment: Alignment.centerLeft,
                    color: Pallete.whiteColor,
                  ),
                ),
              ),
              Hero(
                tag: 'image-transition',
                child: Container(
                  width: double.infinity,
                  height: screenHeight * 0.4,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(songInstance.image_url),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        songInstance.song_name,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        songInstance.artist,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  IconButton(
                      onPressed: () async {
                        await ref
                            .read(homeViewModelProvider.notifier)
                            .isSongFavorite(songId: songInstance.id);
                      },
                      icon: ref.watch(
                        curentUserNotifierProvider.select((value) => value!
                            .favoriteSongs
                            .where((fav) => fav.song_id == songInstance.id)
                            .toList()
                            .isNotEmpty),
                      )
                          ? const Icon(
                              Icons.favorite_rounded,
                              color: Pallete.whiteColor,
                              size: 25,
                            )
                          : const Icon(
                              Icons.favorite_border_rounded,
                              color: Pallete.whiteColor,
                              size: 25,
                            ),),
                ],
              ),
              SizedBox(
                height: screenHeight * 0.03,
              ),

              //music Progress widget
              StreamBuilder(
                stream: songStateInstance.audioPlayer!
                    .positionStream, //stream will rebuild the ui everytime the position gets updated i.e every second
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                  }
                  final position = snapshot.data;
                  final duration = songStateInstance.audioPlayer!.duration;
                  double slidervalue = 0.0;
                  if (position != null && duration != null) {
                    slidervalue = position.inMilliseconds /
                        duration
                            .inMilliseconds; //position here is constantly updating as n when data enters the stream and gives us the curr position of song
                  } //and we divide it by tot duration as slidervalue takes a val bw 0 and 1
                  return Column(
                    children: [
                      StatefulBuilder(
                        //adding this as we needed setState but as we are in a consumerWidget and not consumerStatefulWidget class.
                        builder: (context, StateSetter setState) {
                          return SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Pallete.whiteColor,
                                inactiveTrackColor:
                                    Pallete.whiteColor.withOpacity(0.117),
                                thumbColor: Pallete.whiteColor,
                                trackHeight: 4,
                                overlayShape: SliderComponentShape.noOverlay),
                            child: Slider.adaptive(
                              value: slidervalue,
                              min: 0.0,
                              max: 1.0,
                              onChanged: (val) {
                                //called while dragging the slider
                                setState(() {
                                  slidervalue = val;
                                });
                              },
                              onChangeEnd: (val) {
                                //called when the drag is done
                                //seek method
                                songStateInstance.seek(val);
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${songStateInstance.audioPlayer!.position.inMinutes}:${(songStateInstance.audioPlayer!.position.inSeconds % 60).toString().padLeft(2, '0')}',
                            style: const TextStyle(
                                color: Pallete.whiteColor, fontSize: 15),
                          ),

                          //Expanded(child: SizedBox()),
                          Text(
                              '${songStateInstance.audioPlayer!.duration!.inMinutes}:${(songStateInstance.audioPlayer!.duration!.inSeconds % 60).toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                  color: Pallete.whiteColor, fontSize: 15)),
                        ],
                      )
                    ],
                  );
                },
              ),

              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/images/shuffle.png',
                      width: 50,
                      height: 50,
                    ),
                    Image.asset(
                      'assets/images/previus-song.png',
                      width: 50,
                      height: 50,
                    ),
                    IconButton(
                      onPressed: () {
                        songStateInstance.playPauseInMusic();
                      },
                      icon: songStateInstance.isPlaying
                          ? const Icon(
                              Icons.pause_circle,
                              size: 65,
                              color: Pallete.whiteColor,
                            )
                          : const Icon(
                              Icons.play_circle,
                              size: 65,
                              color: Pallete.whiteColor,
                            ),
                    ),
                    GestureDetector(
                      onTap: () {
                        //songStateInstance.updateSong(song);
                      },
                      child: Image.asset('assets/images/next-song.png',
                          width: 50, height: 50),
                    ),
                    Image.asset('assets/images/repeat.png',
                        width: 50, height: 50),
                  ],
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/images/connect-device.png',
                        width: 50, height: 50),
                    Image.asset('assets/images/playlist.png',
                        width: 50, height: 50),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
