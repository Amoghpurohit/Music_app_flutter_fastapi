import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/widgets/progress_loader.dart';
import 'package:client/features/home/view/pages/upload_song.dart';
import 'package:client/features/home/viewModel/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final likedSongsList = ref.watch(getFavSongsProvider); //this is a future provider

    return ref.watch(getFavSongsProvider).when(
      data: (data) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Your Liked Songs'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: data.length + 1,
              itemBuilder: (context, index) {
                if(index == data.length){
                  return ListTile(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> const UploadSongPage(),),);
                    },
                    leading: const Icon(Icons.add),
                    title: const Text('Upload New Song'),
                    //trailing: const Icon(Icons.more_horiz),
                  );
                }
                final song = data[index];
                return GestureDetector(
                  onTap: () {
                    ref
                        .watch(currentSongNotifierProvider.notifier)
                        .updateSong(song);
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(song.image_url),
                      radius: 24,
                    ),
                    title: Text(song.song_name),
                    subtitle: Text(song.artist),
                    trailing: const Icon(Icons.more_horiz),
                  ),
                );
              },
            ),
          ),
        );
      },
      error: (error, st) {
        return Center(
          child: Text(
            error.toString(),
          ),
        );
      },
      loading: () {
        return const Center(
          child: ProgressLoader(),
        );
      },
    );
  }
}
