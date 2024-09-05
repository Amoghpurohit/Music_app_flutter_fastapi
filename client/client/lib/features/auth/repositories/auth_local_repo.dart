
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_local_repo.g.dart';

@Riverpod(keepAlive: true)
AuthLocalRepo authLocalRepo(AuthLocalRepoRef ref){
  return AuthLocalRepo();   //returning this instance under the annotation riverpod as it helps the file.g.dart to analyse the contents of this file and create a provider under func name
}


class AuthLocalRepo{
   late SharedPreferences _sharedPreferences;

  Future<void> sharedPreferencesInit() async {
    _sharedPreferences = await SharedPreferences.getInstance();         //getInstance() is a static method, hence accssing it by class name
  }                                                                //Static methods cannot directly access instance variables or instance methods because 
                                                                  //they are not tied to a specific instance. They can only access other static variables or static methods.

  void setToken(String? token){                  //this is a instance method
    //_sharedPreferences.setString('x-auth-token', token!);
    if(token != null){
      _sharedPreferences.setString('x-auth-token', token);
    }
  }

  String? getToken(){                      //for new user (no token) hence it can be null
    return _sharedPreferences.getString('x-auth-token');
  }
}