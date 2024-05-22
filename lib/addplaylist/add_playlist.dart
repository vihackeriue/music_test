import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

class AddPlaylistScreen extends StatefulWidget {
  @override
  _AddPlaylistScreenState createState() => _AddPlaylistScreenState();
}

class _AddPlaylistScreenState extends State<AddPlaylistScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _description;
  String? _imagePath;

  Future<void> uploadPlaylist(BuildContext context) async {
    if (_imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng chọn hình ảnh')),
      );
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.1.2:8081/api/playlist'),
    );
    request.headers.addAll({
      'token': 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZG1pbjEyM0BnbWFpbC5jb20iLCJpYXQiOjE3MTYzNTI5NjIsImV4cCI6MTcxNjM5NjE2Mn0.2umI4KFOIhLATqLbIJu8hOxuYUyK1XH4J3jTDdojUa9svHFfcBuMsx0EzsRY31zTkYRfocBo5ZxFJiPpvJRktA',
    });

    request.fields['info'] = json.encode({
      'name': _name,
      'description': _description,
      'urlAvatar': '',
      'songIds': []
    });

    var imageFile = await http.MultipartFile.fromPath(
      'fileImage',
      _imagePath!,
      filename: p.basename(_imagePath!),
    );
    request.files.add(imageFile);

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tạo playlist thành công!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tạo playlist thất bại.')),
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
        title: Text('Thêm Playlist'),
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
                    return 'Vui lòng nhập tên playlist';
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
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    uploadPlaylist(context);
                  }
                },
                child: Text('Tạo Playlist'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
