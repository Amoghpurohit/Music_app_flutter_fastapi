import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/widgets/progress_loader.dart';
import 'package:client/features/home/view/pages/upload_song.dart';
import 'package:client/features/home/viewModel/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SongsPage extends ConsumerWidget {
  const SongsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final currSong = ref.watch(currentSongNotifierProvider);
    final localSongs = ref.watch(homeViewModelProvider.notifier).getAllSongsFromLocal();
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=> const UploadSongPage(),),);
      },
      hoverColor: currSong != null ? hexToColor(currSong.hex_code) : Colors.orangeAccent,
      splashColor: currSong != null ? hexToColor(currSong.hex_code) : Colors.greenAccent,
      child: const Icon(Icons.add),
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: currSong==null ? null : BoxDecoration(
          gradient: LinearGradient(colors: [hexToColor(currSong.hex_code), Pallete.transparentColor,], begin: Alignment.topLeft, end: Alignment.bottomRight, stops: const [0.0, 0.4])
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 36),
              child: SizedBox(
                height: screenHeight * 0.280,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 250,
                      childAspectRatio: 2.7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 9,
                      ),
                  itemCount: localSongs.length,
                  itemBuilder: (context, index) {
                    final song = localSongs[index];
                    return GestureDetector(
                      onTap: () {
                        ref
                            .read(currentSongNotifierProvider.notifier)
                            .updateSong(song);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Pallete.borderColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.only(right: 20),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(song.image_url),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  bottomLeft: Radius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              child: Text(
                                song.song_name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Latest Today',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ref.watch(getSongsProvider).when(
              //ref.watch(someprovider).when() is used when we need to rebuild the widget tree and ref.listen is used when we need to perform an action/react by nav or showing dialog(no ui rebuilding)
              //since we are in a consumerWidget where ref is available to use
              data: (songs) {
                return SizedBox(
                  height:
                      270, //set a height limit for the ListView else it will try to take all the space available in the given direction
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          ref
                              .read(currentSongNotifierProvider.notifier)
                              .updateSong(
                                songs[index],
                              );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: NetworkImage(songs[index].image_url),
                                      fit: BoxFit.cover),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              SizedBox(
                                width: 180,
                                child: Text(
                                  songs[index].song_name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              SizedBox(
                                width: 180,
                                child: Text(
                                  songs[index].artist,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              error: (error, st) {
                return Center(
                  child: Text(error.toString()),
                );
              },
              loading: () {
                return const Center(child: ProgressLoader());
              },
            ),
          ],
        ),
      ),
    );
  }
}
