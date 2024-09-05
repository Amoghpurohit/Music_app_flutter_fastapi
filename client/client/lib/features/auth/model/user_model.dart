// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:client/core/models/fav_song_model.dart';

//data models are classes that hold data

class UserModel {
  final String name;
  final String email;
  final String id;
  final String token;
  final List<FavsongModel> favoriteSongs;
  
  UserModel({
    required this.name,
    required this.email,
    required this.id,
    required this.token,
    required this.favoriteSongs,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? id,
    String? token,
    List<FavsongModel>? favoriteSongs,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      id: id ?? this.id,
      token: token ?? this.token,
      favoriteSongs: favoriteSongs ?? this.favoriteSongs,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'id': id,
      'token': token,
      'favoriteSongs': favoriteSongs.map((x) => x.toMap()).toList(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      id: map['id'] ?? '',
      token: map['token'] ?? '',
      favoriteSongs: List<FavsongModel>.from((map['favoriteSongs'] ?? []).map<FavsongModel>((x) => FavsongModel.fromMap(x as Map<String,dynamic>),),),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.name == name &&
      other.email == email &&
      other.id == id &&
      other.token == token &&
      listEquals(other.favoriteSongs, favoriteSongs);
  }

  @override
  int get hashCode {
    return name.hashCode ^
      email.hashCode ^
      id.hashCode ^
      token.hashCode ^
      favoriteSongs.hashCode;
  }

  @override
  String toString() {
    return 'UserModel(name: $name, email: $email, id: $id, token: $token, favoriteSongs: $favoriteSongs)';
  }
}
