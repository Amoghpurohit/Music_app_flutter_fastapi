import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/utils.dart';
import 'package:client/features/home/viewModel/home_viewmodel.dart';
import 'package:client/features/home/widgets/music_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MusicSlab extends ConsumerWidget {
  const MusicSlab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currSong = ref.watch(
        currentSongNotifierProvider); //with this notifier we are watching the SongModel it will provide us the state of songModel

    final currSongNotifier = ref.watch(currentSongNotifierProvider
        .notifier); //access the notifier object which allows us call methods that can modify the state of the SongModel
    final userFav = ref.watch(
      curentUserNotifierProvider.select((value) => value!.favoriteSongs),
    );
    //final favSongs = ref.watch(homeViewModelProvider);

    if (currSong == null) {
      return const SizedBox();
    }
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MusicPlayer(song: currSong),
          ),
        );
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: MediaQuery.of(context).size.width - 10,
              height: 70,
              decoration: BoxDecoration(
                color: hexToColor(currSong.hex_code),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          Hero(
                            tag: 'image-transition',
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(currSong.image_url),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currSong.song_name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                currSong.artist,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      //mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                            onPressed: () async {
                              await ref
                                  .read(homeViewModelProvider.notifier)
                                  .isSongFavorite(songId: currSong.id);
                            },
                            icon: userFav
                                    .where((fav) => fav.song_id == currSong.id)            //looping through our fav songs list and checking if the song.id of fav is same as curr songs id
                                    .toList()                                              //then convert it to a list and check if its empty or not, if empty its not favorited else it is.
                                    .isNotEmpty
                                ? const Icon(
                                    Icons.favorite_rounded,
                                    color: Color.fromARGB(255, 100, 98, 98),
                                  )
                                : const Icon(
                                    Icons.favorite_border_rounded,
                                    color: Color.fromARGB(255, 100, 98, 98),
                                  )),
                        const SizedBox(
                          width: 7,
                        ),
                        IconButton(
                          onPressed: currSongNotifier.playPauseInMusic,
                          icon: currSongNotifier.isPlaying
                              ? const Icon(
                                  Icons.pause,
                                  color: Color.fromARGB(255, 114, 113, 113),
                                )
                              : const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Color.fromARGB(255, 114, 113, 113),
                                ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 8,
            child: Container(
              height: 2,
              width: MediaQuery.of(context).size.width - 22,
              decoration: const BoxDecoration(
                color: Colors.grey,
              ),
            ),
          ),
          StreamBuilder(
              stream: currSongNotifier.audioPlayer!.positionStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox();
                }
                final position = snapshot.data;
                final duration = currSongNotifier.audioPlayer!.duration;
                double slidervalue = 0.0;
                if (position != null && duration != null) {
                  slidervalue =
                      position.inMilliseconds / duration.inMilliseconds;
                }
                return Positioned(
                  bottom: 0,
                  left: 8,
                  child: Container(
                    height: 2,
                    width:
                        slidervalue * (MediaQuery.of(context).size.width - 22),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }
}
