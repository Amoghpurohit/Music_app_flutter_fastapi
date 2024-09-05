//import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/features/home/view/pages/library.dart';
import 'package:client/features/home/view/pages/songs.dart';
import 'package:client/features/home/widgets/music_slab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int selectedIndex = 0;

  final navBarPages = const [
    SongsPage(),
    LibraryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    // final userdata = ref.watch(curentUserNotifierProvider); //by doing this we can access user data from any place in the app
    // print(userdata);

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('home page'),
      // ),
      body: Stack(
        children:[ navBarPages[selectedIndex],
        const Positioned(bottom: 0, child: MusicSlab(),),                //using musicslab in home as it must be visible on all pages
        ],
      ), //created a list of widgets and passed the index of display
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (value) => setState(() {
          selectedIndex = value;
        }),
        items: [
          BottomNavigationBarItem(
              icon: selectedIndex == 0
                  ? Image.asset('assets/images/home_filled.png')
                  : Image.asset('assets/images/home_unfilled.png'),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Image.asset('assets/images/library.png'), label: 'Library'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
