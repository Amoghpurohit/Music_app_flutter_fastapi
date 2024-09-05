import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/features/auth/model/user_model.dart';
import 'package:client/features/auth/repositories/auth_local_repo.dart';
import 'package:client/features/auth/repositories/auth_remote_repo.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_viewmodel.g.dart';

@riverpod
class AuthViewModel extends _$AuthViewModel {
  //we are actually extending the AutoDisposeNotifier of type AsyncValue(that code is
// is auto generated for us by adding @riverpod annotation and using part file_name)

  late AuthRemoteRepo _authRemoteRepo;
  late AuthLocalRepo _authLocalRepo;
  late CurentUserNotifier _curentUserNotifier;

  @override
  AsyncValue<UserModel>? build() {                          //this build method will run when there is a change in authRemoteRepoProvider and provides that state info to viewModel
    _authRemoteRepo = ref.watch(authRemoteRepoProvider); 
    _authLocalRepo = ref.watch(authLocalRepoProvider);
    _curentUserNotifier = ref.watch(curentUserNotifierProvider.notifier);    
    return null;
  }

  Future<void> initSharedPreferences() async {     //there is a possibility that sharedPreferences might not just be used inside this auth view Model file 
    await _authLocalRepo.sharedPreferencesInit();  //but in other files as well hence we are initializing it in the main.dart file      
  }

  Future<UserModel?> getUserData() async {             //auth persistence, user has already logged in once
    state = const AsyncValue.loading();
    final token = _authLocalRepo.getToken();       //getting the token stored in local in viewmodel and passing it to remote repo for resp
    if(token != null){
      //send a req to server to get the user data from token
      final serverResp = await _authRemoteRepo.getCurrentUserData(token: token);
      final val = switch (serverResp) {
        Left(value : final l) => state = AsyncValue.error(l.message, StackTrace.current),
        Right(value: final r) => state = _getDataOnRestartingApp(r),
      };
      return val.value;
    } 
    return null;
  }

  AsyncValue<UserModel> _getDataOnRestartingApp(UserModel user){
    _curentUserNotifier.addUser(user);     //adduser method is called when user data is retrieved and since view model is watching it its state gets updated then its checked in main.dart to show respective screens
    //user being null is handled in the func above
    return state = AsyncValue.data(user);
  }

  Future<void> signUpUser(
      {required String name,
      required String email,
      required String password}) async {
    state = const AsyncValue.loading();

    final res = await _authRemoteRepo.signup(
        name: name, email: email, password: password);
    //print(res);

    final val = switch (res) {
      Left(value: final l) => state =
          AsyncValue.error(l.message, StackTrace.current),
      Right(value: final r) => state = AsyncValue.data(r) //we convert maps to user or user data classes as it is easier to work with them
    };
    print(val);
  }

  Future<void> loginUser(
      {required String email, required String password}) async {
    state = const AsyncValue.loading();

    final res = await _authRemoteRepo.login(email: email, password: password);
    //print(res);
    final val2 = switch (res) {
      Left(value: final l) => state = AsyncValue.error(l.message, StackTrace.current),
      Right(value: final r) => _onSuccessfulLogin(r)
    };
    print(val2);
  }

  AsyncValue<UserModel>? _onSuccessfulLogin(UserModel user){      //first time logging in
    _authLocalRepo.setToken(user.token);    //keeping the token in our local storage
    _curentUserNotifier.addUser(user);     //updating the state of the provider to current user so that we can use that user data in rest of the app
    return state = AsyncValue.data(user);
  }
}
