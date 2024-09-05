import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/theme/theme.dart';
import 'package:client/features/auth/view/pages/sign_up.dart';
import 'package:client/features/auth/viewModel/auth_viewmodel.dart';
import 'package:client/features/home/view/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized(); //ensures that the Flutter engine and bindings are initialized before executing any further code. useful for initialization tasks
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  final dir = await getApplicationDocumentsDirectory();
  Hive.defaultDirectory = dir.path;
  final container = ProviderContainer();    //we can access ref anywhere by using ProviderContainer() which stores the state of providers
                                          //and allows for manipulate the state of any one of its providers outside the widget tree
  await container
      .read(authViewModelProvider.notifier)
      .initSharedPreferences();        //sharedPreferences is initialized before the app starts

  final user = await container.read(authViewModelProvider.notifier).getUserData();
  print(user);    
  //print(usermodel);
  //await container.read(authRemoteRepoProvider);    
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(curentUserNotifierProvider);       //updates this variable with the either user data or null
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music App ',
      theme: AppTheme.darkModeTheme,
      home: currentUser == null ? const SignUpPage() : const HomePage(),
    );
  }
}
