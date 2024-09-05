// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$getSongsHash() => r'c98f187ca365d647fdacebd2b0b2dea6769ea1c8';

/// See also [getSongs].
@ProviderFor(getSongs)
final getSongsProvider = AutoDisposeFutureProvider<List<SongModel>>.internal(
  getSongs,
  name: r'getSongsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$getSongsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetSongsRef = AutoDisposeFutureProviderRef<List<SongModel>>;
String _$getFavSongsHash() => r'37e5224e4b79f15f5aebe1b249e8d1af7ecec993';

/// See also [getFavSongs].
@ProviderFor(getFavSongs)
final getFavSongsProvider = AutoDisposeFutureProvider<List<SongModel>>.internal(
  getFavSongs,
  name: r'getFavSongsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$getFavSongsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetFavSongsRef = AutoDisposeFutureProviderRef<List<SongModel>>;
String _$homeViewModelHash() => r'38199665e2374c462f1ad016d241982fd5ab672d';

/// See also [HomeViewModel].
@ProviderFor(HomeViewModel)
final homeViewModelProvider =
    AutoDisposeNotifierProvider<HomeViewModel, AsyncValue?>.internal(
  HomeViewModel.new,
  name: r'homeViewModelProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$homeViewModelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HomeViewModel = AutoDisposeNotifier<AsyncValue?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
