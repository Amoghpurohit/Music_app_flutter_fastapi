
import 'package:client/features/home/model/song_model.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_local_repo.g.dart';

@riverpod
HomeLocalRepository homeLocalRepository (HomeLocalRepositoryRef ref){
  return HomeLocalRepository();
}

class HomeLocalRepository{

  final Box box = Hive.box();

  void uploadSongToLocal(SongModel song){                  //this func will be called when user selects a particular song, hence we need a provider for this repo
    box.put(song.id, song.toJson());               //k-songID and v-entire songModel in json format
  }

  List<SongModel> loadAllSongs(){
    List<SongModel> allSongs = [];
    for(final key in box.keys){
      allSongs.add(SongModel.fromJson(box.get(key)));
    }
    return allSongs;
  }
}