import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatappfirebase/service/database_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:chatappfirebase/helper/helper_function.dart';

class PostUpLayout extends StatefulWidget {
  final String userName;
  final String? initialTitle;
  final String? initialContent;
  final double? initialPrice;
  final String? postId; // 수정할 게시글 ID (수정 모드인 경우)
  PostUpLayout({
    Key? key,
    required this.userName,
    this.initialTitle,
    this.initialContent,
    this.initialPrice,
    this.postId,
  }) : super(key: key);
  @override
  _PostUpLayoutState createState() => _PostUpLayoutState();
}

class _PostUpLayoutState extends State<PostUpLayout> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _priceController;
  bool _isLoading = false;
  File? _image;
  String userName = '';
  String postId = '';

  @override
  void initState() {
    super.initState();
    //gettingUserData(); // 사용자 데이터 가져오기
    _titleController = TextEditingController(text: widget.initialTitle);
    _contentController = TextEditingController(text: widget.initialContent);
    _priceController =
        TextEditingController(text: widget.initialPrice?.toStringAsFixed(2));
  }

  gettingUserData() async {
    await HelperFunctions.getUserNameFromSF().then((val) {
      setState(() {
        userName = val!;
      });
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("게시물 만들기"),
        centerTitle: true,
        backgroundColor: Color(0xFF0c4da2),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "제목",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _image == null
                  ? GestureDetector(
                      onTap: getImage,
                      child: Container(
                        height: 200,
                        width: 700,
                        color: Colors.grey[300],
                        child: Icon(Icons.camera_alt, color: Colors.grey[700]),
                      ),
                    )
                  : Image.file(_image!),
              SizedBox(height: 20),
              TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: "내용:",
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: "가격",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF0c4da2),
                ),
                onPressed: () => createPost(
                    FirebaseAuth.instance.currentUser?.displayName ??
                        "Unknown User"),
                child:
                    _isLoading ? CircularProgressIndicator() : Text("게시물 업로드"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('이미지가 선택되지 않았습니다.');
      }
    });
  }

  void createPost(String userName) async {
    if (_titleController.text.isEmpty ||
        _contentController.text.isEmpty ||
        _image == null) {
      print("제목, 내용, 이미지가 필요합니다.");
      return;
    }

    if (_image == null) {
      print("이미지가 필요합니다.");
      return;
    }

    double? price = double.tryParse(_priceController.text);
    if (price == null) {
      print("가격 설정에 문제가 있습니다.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .createPost(
        userName: widget.userName,
        title: _titleController.text,
        content: _contentController.text,
        imageFile: _image!,
        price: price,
        postId: postId,
      )
          .whenComplete(() {
        Navigator.of(context).pop(); // 현재 PostUpLayout 화면 닫기
      });
    } catch (e) {
      print("게시물을 생성하는 중 오류가 발생했습니다: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _priceController.dispose();

    super.dispose();
  }
}
