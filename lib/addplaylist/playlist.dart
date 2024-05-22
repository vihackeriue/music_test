import 'dart:convert';

class Playlist {
  String name;
  String description;
  String urlAvatar;

  Playlist({required this.name, required this.description, this.urlAvatar = ""});

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      name: json['name'],
      description: json['description'],
      urlAvatar: json['urlAvatar'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'urlAvatar': urlAvatar,
    };
  }

  String toJsonString() => json.encode(toJson());
}
