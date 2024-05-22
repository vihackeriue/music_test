import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

class AddMusicScreen extends StatefulWidget {
  @override
  _AddMusicScreenState createState() => _AddMusicScreenState();
}

class _AddMusicScreenState extends State<AddMusicScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _author;
  String? _description;
  int? _genreId;
  int? _artistId;
  String? _imagePath;
  String? _audioPath;
  List<Map<String, dynamic>> _genres = [];
  List<Map<String, dynamic>> _artist = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchGenres(context);
      fetchArtist(context);
    });
  }

  Future<void> fetchGenres(BuildContext context) async {
    final response = await http.get(Uri.parse('http://192.168.1.2:8081/api/genre'));

    if (response.statusCode == 200) {
      setState(() {
        var jsonResponse = json.decode(response.body);
        _genres = List<Map<String, dynamic>>.from(
            jsonResponse['listResult'].map((genre) => {
              'id': genre['id'],
              'name': genre['name'],
            })
        );
      });

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load genres')),
      );
    }
  }

  Future<void> fetchArtist(BuildContext context) async {
    final response = await http.get(Uri.parse('http://192.168.1.2:8081/api/artist/1'),
      headers: {
        'token': 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZG1pbjEyM0BnbWFpbC5jb20iLCJpYXQiOjE3MTYzNTI5NjIsImV4cCI6MTcxNjM5NjE2Mn0.2umI4KFOIhLATqLbIJu8hOxuYUyK1XH4J3jTDdojUa9svHFfcBuMsx0EzsRY31zTkYRfocBo5ZxFJiPpvJRktA',
      },

    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      setState(() {
        _artist = List<Map<String, dynamic>>.from(
            jsonResponse.map((artist) => {
              'id': artist['id'],
              'name': artist['name'],
            })
        );
      });
      print(_artist);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load artists')),
      );
    }
  }


  Future<void> uploadMusic(BuildContext context) async {
    if (_imagePath == null || _audioPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng chọn cả hình ảnh và file âm thanh')),
      );
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.1.2:8081/api/song'),
    );

    request.fields['info'] = json.encode({

      'title': _name,
      'description': _description,
      'url_thumbnail': '',
      'url_audio': '',
      'genreID': _genreId,
      'artistID': _artistId,
      'views': 0,
    });

    var imageFile = await http.MultipartFile.fromPath(
      'fileImage',
      _imagePath!,
      filename: p.basename(_imagePath!),
    );
    request.files.add(imageFile);

    var audioFile = await http.MultipartFile.fromPath(
      'fileAudio',
      _audioPath!,
      filename: p.basename(_audioPath!),
    );
    request.files.add(audioFile);

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload thành công!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload thất bại.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Music'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Tên'),
                onSaved: (value) => _name = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên bài hát';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: 'Tác Giả'),
                items: _artist.map((artist) {
                  return DropdownMenuItem<int>(
                    value: artist['id'],
                    child: Text(artist['name']),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _artistId = value),
                validator: (value) {
                  if (value == null) {
                    return 'Vui lòng chọn tác giả';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Mô tả'),
                onSaved: (value) => _description = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mô tả';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: 'Thể loại'),
                items: _genres.map((genre) {
                  return DropdownMenuItem<int>(
                    value: genre['id'],
                    child: Text(genre['name']),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _genreId = value),
                validator: (value) {
                  if (value == null) {
                    return 'Vui lòng chọn thể loại';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.image,
                  );
                  if (result != null) {
                    setState(() {
                      _imagePath = result.files.single.path;
                    });
                  }
                },
                child: Text(_imagePath == null ? 'Chọn hình ảnh' : 'Hình ảnh đã chọn'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.audio,
                  );
                  if (result != null) {
                    setState(() {
                      _audioPath = result.files.single.path;
                    });
                  }
                },
                child: Text(_audioPath == null ? 'Chọn file âm thanh' : 'File âm thanh đã chọn'),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    uploadMusic(context);
                    print('aaaaaaaaaaaaaa');
                  }
                },
                child: Text('Lưu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
