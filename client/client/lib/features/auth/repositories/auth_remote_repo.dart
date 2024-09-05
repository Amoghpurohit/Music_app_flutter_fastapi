import 'dart:convert';

import 'package:client/core/app_failure.dart';
import 'package:client/core/app_server_constants/android_server_constant.dart';
import 'package:client/features/auth/model/user_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_remote_repo.g.dart';

@riverpod
AuthRemoteRepo authRemoteRepo(AuthRemoteRepoRef ref) {
  return AuthRemoteRepo();
}

class AuthRemoteRepo {
  Future<Either<AppFailure, UserModel>> signup(
      {required String name,
      required String email,
      required String password}) async {
    try {
      final signUpResponse = await http.post(
        Uri.parse('${AndroidServerConstant.androidLocalHost}auth/signup'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {'name': name, 'email': email, 'password': password},
        ),
      );

      final signUpRespMap =
          jsonDecode(signUpResponse.body) as Map<String, dynamic>;
      if (signUpResponse.statusCode != 201) {
        return Left(AppFailure(signUpRespMap['detail']));
      }

      //print(signUpResponse.body);
      print(signUpResponse.statusCode);
      return Right(UserModel.fromMap(signUpRespMap));
    } catch (e) {
      //print(e);
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, UserModel>> login(
      {required String email, required String password}) async {
    try {
      final loginResp = await http.post(
        Uri.parse(
            '${AndroidServerConstant.androidLocalHost}auth/login'), //our custom api route
        headers: {
          'Content-Type': 'application/json'
        }, //we are basically saying that the req body will be in json format
        body: jsonEncode({
          //our req body
          'email': email,
          'password': password
        }),
      );

      final loginRespMap = jsonDecode(loginResp.body) as Map<String, dynamic>;
      if (loginResp.statusCode != 200) {
        return Left(AppFailure(loginRespMap['detail']));
      }

      print(loginResp.statusCode);
      return Right(UserModel.fromMap(loginRespMap['user']).copyWith(
          token: loginRespMap[
              'token'])); //we have to pass user part of resp to fromMap for usermodel along with that the token as well
    } //this token will help us identify the user and authenticate them before making any requests/actions
    catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, UserModel>> getCurrentUserData(
      {required String token}) async {
    try {
      final authTokenResp = await http.get(
        Uri.parse('${AndroidServerConstant.androidLocalHost}auth/'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );
      final tokenRespMap = jsonDecode(authTokenResp.body) as Map<String,dynamic>; //immediately convert response to map by using jsonDecode()
      if (authTokenResp.statusCode != 200) {
        return Left(AppFailure(tokenRespMap['detail']));
      }
      return Right(UserModel.fromMap(tokenRespMap).copyWith(token: token));
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }
}
