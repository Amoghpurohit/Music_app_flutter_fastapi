import 'dart:io';
import 'dart:ui';

import 'package:client/core/models/fav_song_model.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/utils.dart';
import 'package:client/features/home/model/song_model.dart';
import 'package:client/features/home/repositories/home_local_repo.dart';
import 'package:client/features/home/repositories/home_repo.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_viewmodel.g.dart';

@riverpod
Future<List<SongModel>> getSongs(GetSongsRef ref) async {
  // final res = await ref.watch(homeRepositoryProvider).getAllSongs(
  //     token: ref
  //         .watch(curentUserNotifierProvider)!
  //         .token);
  //                                       IMPORTANT------>    // here y are we watching the entire UserModel via the notifierProvider when all we need is token property
  final res = await ref.watch(homeRepositoryProvider).getAllSongs(
        token: ref.watch(
          curentUserNotifierProvider.select((value) => value!
              .token), //this way we are only listening to changes in token and nothing else
        ),
      );
  //we are using ref.watch() for token instead if ref.read() because if the user changes, that must be known here, so that we can list all the songs of that user
  //and we can use homeRepositoryProvider here without worrying about the init of HomeRepository instance.
  return switch (res) {
    Left(value: final l) => throw l
        .message, //when an error is thrown in this future it is handled by the .when((error){}) state in view
    Right(value: final r) => r,
  };
}

//similar provider method as above getAllFavSongs -

@riverpod
Future<List<SongModel>> getFavSongs(GetFavSongsRef ref) async {
  //this method is made a provider because it returns a list and we have to constantly watch this list to update data
  final res = await ref.watch(homeRepositoryProvider).listOfAllFavSongs(
        token: ref.watch(
          curentUserNotifierProvider.select((value) => value!.token),                 //making same changes as previous future provider, to only listen to token changes
        ),
      );
  print(res);
  return switch (res) {
    Left(value: final l) => throw l
        .message, // "throw" in case of error so that we dont have to adhere to the return type and failure is handled gracefully
    Right(value: final r) => r, //return list i.r "r".
  };
}

@riverpod
class HomeViewModel extends _$HomeViewModel {
  //this class is gonna be a riverpod notifier(we are going to handle state here), as it is a viewmodel class

  //final HomeRepository _homeRepository = HomeRepository();   //this cant be done as we dont know the state of HomeRepository, we have to watch for the state or instance of HomeRepo
  //before using it elsewhere        and another reason it cant be initialized as HomeRepo is dependent on its instance variables and on the result of the backend call
  late HomeRepository _homeRepository;
  late HomeLocalRepository _homeLocalRepository;

  @override
  AsyncValue? build() {
    _homeRepository = ref.watch(
        homeRepositoryProvider); //initialized by watching the provided state by HomeRepository and can now be used in methods in this file

    _homeLocalRepository = ref.watch(homeLocalRepositoryProvider);
    return null; //Providers -
    //Definition: In the context of Riverpod (or other state management solutions), providers are mechanisms to supply instances of classes or manage their lifecycle.
    //Example: homeRepositoryProvider is a Riverpod provider that supplies an instance of HomeRepository.
  }

  Future<void> songUpload({
    required File audioFile,
    required File imageFile,
    required String artist,
    required String songName,
    required Color hexCode,
  }) async {
    state = const AsyncValue.loading(); //

    final apiResp = await _homeRepository.uploadSong(
        audioFile: audioFile,
        imageFile: imageFile,
        artist: artist,
        songName: songName,
        hexCode: rgbToHex(hexCode),
        token: ref
            .read(curentUserNotifierProvider)!
            .token); // 2 return types i.e for success and for failure

    final val = switch (apiResp) {
      Left(value: final l) => state =
          AsyncValue.error(l.message, StackTrace.current),
      Right(value: final r) => state = AsyncValue.data(r),
    };
    print(val);
  }

  List<SongModel> getAllSongsFromLocal() {
    //return ref.read(homeLocalRepositoryProvider).loadAllSongs();
    return _homeLocalRepository.loadAllSongs();
  }

  Future<void> isSongFavorite({
    //no need to specify any return type, both pass and fail cases are handled in the switch stmt
    required String songId,
  }) async {
    state = const AsyncValue.loading();

    final apiResp = await _homeRepository.favASong(
      token: ref
          .read(curentUserNotifierProvider)!
          .token, //the state has already been set to 'user' at this point in time, we can take token from there
      songId: songId,
    );
    final val = switch (apiResp) {
      Left(value: final l) => state =
          AsyncValue.error(l.message, StackTrace.current),
      Right(value: final r) => state = _isFavorited(r, songId), // it will often be needed to create a function here to update models with data rather than just saying state = data
    };
    print(val);
  }

  AsyncValue _isFavorited(bool isFav, String songId) {
    //update the userModel's favSongs property with data and this data is of type FavsongModel IF isFav is TRUE
    final userFavSongs = ref.read(curentUserNotifierProvider.notifier);
    if (isFav) {
      userFavSongs.addUser(
        ref.read(curentUserNotifierProvider)!.copyWith(
          favoriteSongs: [
            //favoriteSongs is of type List<FavsongModel>
            ...ref
                .read(curentUserNotifierProvider)!
                .favoriteSongs, // adding a new FavsongModel to list along with existing ones using the spread operator
            FavsongModel(id: '', song_id: songId, user_id: ''), //
          ],
        ),
      );
    } else {
      userFavSongs.addUser(
        ref.read(curentUserNotifierProvider)!.copyWith(
              favoriteSongs: ref
                  .read(curentUserNotifierProvider)!
                  .favoriteSongs
                  .where((fav) => fav.song_id != songId)
                  .toList(),
            ),
      );
    }
    ref.invalidate(getFavSongsProvider);
    return AsyncValue.data(isFav);
  }
}
