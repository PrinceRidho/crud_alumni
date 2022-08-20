import 'dart:convert';
import 'dart:io';
import 'package:crud_alumni/model/mahasiswa.dart';
import 'package:crud_alumni/api_mahasiswa.dart';
import 'package:crud_alumni/model/mahasiswa.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AddUpdateMahasiswaPage extends StatefulWidget {
  final String type;
  final Mahasiswa mahasiswa;
  AddUpdateMahasiswaPage({required this.type, required this.mahasiswa});
  @override
  _AddUpdateMahasiswaPageState createState() => _AddUpdateMahasiswaPageState();
}

class _AddUpdateMahasiswaPageState extends State<AddUpdateMahasiswaPage> {
  var _controllerNim = TextEditingController();
  var _controllerNama = TextEditingController();
  var _controllerJurusan = TextEditingController();
  var _controllerTanggalLahir = TextEditingController();
  var _controllerAlamat = TextEditingController();
  File _foto;
  var _formKey = GlobalKey<FormState>();
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  Future getFoto() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _foto = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  void editMahasiswa(Mahasiswa mahasiswa) async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: Colors.white,
        children: [
          Center(child: CircularProgressIndicator()),
          SizedBox(height: 10),
          Center(child: Text('Loading...')),
        ],
      ),
    );
    Future.delayed(Duration(milliseconds: 1000), () {
      Navigator.pop(context);
    });

    if (_foto != null) {
      await http.post(ApiMahasiswa.URL_DELETE_FOTO, body: {
        'nama': _fotoSebelumUpdate,
      });
      await http.post(ApiMahasiswa.URL_UPLOAD_FOTO, body: {
        'foto': base64Encode(_foto.readAsBytesSync()),
        'nama': mahasiswa.foto,
      });
    }

    var response = await http.post(ApiMahasiswa.URL_EDIT_MAHASISWA,
        body: mahasiswa.toJson());
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var message = '';
      if (responseBody['success']) {
        message = 'Berhasil Mengupadate Mahasiswa';
      } else {
        message = 'Gagal Mengupadate Mahasiswa';
      }
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(message),
        duration: Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
      ));
    } else {
      print('Request Error');
    }
  }

  void addMahasiswa(Mahasiswa mahasiswa) async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: Colors.white,
        children: [
          Center(child: CircularProgressIndicator()),
          SizedBox(height: 10),
          Center(child: Text('Loading...')),
        ],
      ),
    );
    Future.delayed(Duration(milliseconds: 1000), () {
      Navigator.pop(context);
    });
    var responseNim = await http.post(ApiMahasiswa.URL_CHECK_NIM, body: {
      'nim': mahasiswa.nim,
    });
    var check = jsonDecode(responseNim.body);
    if (check['ada']) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('NIM Sudah Terdaftar'),
        duration: Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red[700],
      ));
    } else {
      await http.post(ApiMahasiswa.URL_UPLOAD_FOTO, body: {
        'foto': base64Encode(_foto.readAsBytesSync()),
        'nama': mahasiswa.foto,
      });
      var response = await http.post(ApiMahasiswa.URL_ADD_MAHASISWA,
          body: mahasiswa.toJson());
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        var message = '';
        if (responseBody['success']) {
          message = 'Berhasil Menambahkan Mahasiswa';
        } else {
          message = 'Gagal Menambahkan Mahasiswa';
        }
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(message),
          duration: Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
        ));
      } else {
        print('Request Error');
      }
    }
  }

  @override
  void initState() {
    if (widget.mahasiswa != null) {
      _controllerNim.text = widget.mahasiswa.nim;
      _controllerNama.text = widget.mahasiswa.nama;
      _controllerJurusan.text = widget.mahasiswa.jurusan;
      _controllerTanggalLahir.text = widget.mahasiswa.tanggalLahir;
      _controllerAlamat.text = widget.mahasiswa.alamat;
      _fotoSebelumUpdate = widget.mahasiswa.foto;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('${widget.type} Mahasiswa'),
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {},
          )
        ],
      ),
    );
  }
}
