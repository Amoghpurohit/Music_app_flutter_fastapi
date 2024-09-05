// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names

import 'dart:convert';

class SongModel {
  final String id;
  final String audio_url;
  final String image_url;          //the names of these instance vars must match keys in api resp as we will be converting them to map from model
  final String artist;
  final String song_name;
  final String hex_code;
  SongModel({
    required this.id,
    required this.audio_url,
    required this.image_url,
    required this.artist,
    required this.song_name,
    required this.hex_code,
  });

  SongModel copyWith({
    String? id,
    String? audio_url,
    String? image_url,
    String? artist,
    String? song_name,
    String? hex_code,
  }) {
    return SongModel(
      id: id ?? this.id,
      audio_url: audio_url ?? this.audio_url,
      image_url: image_url ?? this.image_url,
      artist: artist ?? this.artist,
      song_name: song_name ?? this.song_name,
      hex_code: hex_code ?? this.hex_code,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'audio_url': audio_url,
      'image_url': image_url,
      'artist': artist,
      'song_name': song_name,
      'hex_code': hex_code,
    };
  }

  factory SongModel.fromMap(Map<String, dynamic> map) {
    return SongModel(
      id: map['id'] as String,
      audio_url: map['audio_url'] as String,
      image_url: map['image_url'] as String,
      artist: map['artist'] as String,
      song_name: map['song_name'] as String,
      hex_code: map['hex_code'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory SongModel.fromJson(String source) => SongModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SongModel(id: $id, audio_url: $audio_url, image_url: $image_url, artist: $artist, song_name: $song_name, hex_code: $hex_code)';
  }

  @override
  bool operator ==(covariant SongModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.audio_url == audio_url &&
      other.image_url == image_url &&
      other.artist == artist &&
      other.song_name == song_name &&
      other.hex_code == hex_code;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      audio_url.hashCode ^
      image_url.hashCode ^
      artist.hashCode ^
      song_name.hashCode ^
      hex_code.hashCode;
  }
}
