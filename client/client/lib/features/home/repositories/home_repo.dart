import 'dart:convert';
import 'dart:io';
import 'package:client/core/app_failure.dart';
import 'package:client/core/app_server_constants/android_server_constant.dart';
import 'package:client/features/home/model/song_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_repo.g.dart';

@riverpod
HomeRepository homeRepository(HomeRepositoryRef ref) {
  // creating a provider to provide state and will be watched in viewmodel file
  return HomeRepository();
}

class HomeRepository {
  Future<Either<AppFailure, String>> uploadSong({
    required File audioFile,
    required File imageFile,
    required String artist,
    required String songName,
    required String hexCode,
    required String token,
  }) async {
    try {
      final request = http.MultipartRequest('POST',
          Uri.parse('${AndroidServerConstant.androidLocalHost}song/upload'));
      // so multipart req allows us to add files to the req body and also send form field attributes(k-v pairs) and also attact headers to the req

      request
        ..files.addAll([
          //appending files to req(meaning we are sending files along with the req), ..files.addAll() takes a dict
          //or a list wherein we add the files through MultipartFile.fromPath(takes field name, path of the resource)
          await http.MultipartFile.fromPath('song', audioFile.path),
          await http.MultipartFile.fromPath('thumbnail', imageFile.path),
        ])
        ..fields.addAll(
          // .. is a cascade expresssion used to attach multiple attributes to the request
          {
            //..fields.addAll() takes a map to pass k-v pairs like how we normally pass in a body
            'artist': artist, //taking in form fields
            'name': songName,
            'hex_code': hexCode,
          },
        )
        ..headers.addAll(
          {
            //takes a map for header name and value, here using for user auth
            'x-auth-token': token,
            //'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjxmdW5jdGlvbiB1dWlkNCBhdCAweDAwMDAwMjc0MkQ1NzM3RTA-In0.wJttuvWmBDX-KT6-G1D_PRbNB8l9XH0SVBGv23pEggQ'
          },
        );

      final res = await request.send();
      if (res.statusCode != 201) {
        return Right(await res.stream.bytesToString());
      }
      print(res);
      return Left(AppFailure(await res.stream.bytesToString()));
      //print(request);
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, List<SongModel>>> getAllSongs(
      {required String token}) async {
    try {
      final resp = await http.get(
        Uri.parse('${AndroidServerConstant.androidLocalHost}song/list'),
        headers: {
          'x-auth-token': token,
        },
      );
      var resBodyMap = jsonDecode(resp.body);

      if (resp.statusCode != 200) {
        resBodyMap = resBodyMap as Map<String,
            dynamic>; //in case of failure convert it to map so that we are get the value of key 'detail' as we dont get a list in resp
        return Left(
          AppFailure(
            resBodyMap['detail'],
          ),
        );
      }
      resBodyMap =
          resBodyMap as List; //else convert it to a List and iterate through it
      final List<SongModel> listOfMaps = [];
      for (final map in resBodyMap) {
        listOfMaps.add(SongModel.fromMap(map));
      }
      print(listOfMaps);
      return Right(listOfMaps);
    } catch (e) {
      return Left(
        AppFailure(
          e.toString(),
        ),
      );
    }
  }

  Future<Either<AppFailure, bool>> favASong({
    required String token,
    required String songId,
  }) async {
    try {
      //hit the endpoint, wrap it in try-catch block, give header and body, decode resp and return
      final resp = await http.post(
        Uri.parse('${AndroidServerConstant.androidLocalHost}song/favorite'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode(
          {
            'song_id': songId,
          },
        ),
      );
      print(resp.body);
      final decodedResp = json.decode(resp.body) as Map<String, dynamic>;
      if (resp.statusCode != 201) {
        return Left(
          AppFailure(
            decodedResp['detail'],
          ),
        );
      } else {
        return Right(decodedResp['message']);
      }
    } catch (e) {
      return Left(
        AppFailure(
          e.toString(),
        ),
      );
    }
  }

  //listAllFavSongs method -
  Future<Either<AppFailure, List<SongModel>>> listOfAllFavSongs(
      {required String token}) async {
    try {
      final resp = await http.get(
        Uri.parse('${AndroidServerConstant.androidLocalHost}song/list/favorite'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );
      var convResp = jsonDecode(resp.body);
      if (resp.statusCode != 200) {
        return Left(
          AppFailure(
            convResp['detail'],
          ),
        );
      }
      convResp = convResp as List; //converting it to a list as we might get multiple json values
      List<SongModel> allFavSongs = [];
      for (final song in convResp) {
        allFavSongs.add(
          SongModel.fromMap(
            song['song'],
          ),
        );
      }
      return Right(allFavSongs);
    } catch (e) {
      return Left(
        AppFailure(
          e.toString(),
        ),
      );
    }
  }
}
