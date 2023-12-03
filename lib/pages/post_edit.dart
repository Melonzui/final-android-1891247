import 'dart:io';
import 'package:chatappfirebase/service/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PostEditLayout extends StatefulWidget {
  final String postId; // 수정할 게시글의 ID
  final String initialTitle; // 수정 전 제목
  final String initialContent; // 수정 전 내용
  final double initialPrice; // 수정 전 가격

  PostEditLayout({
    Key? key,
    required this.postId,
    required this.initialTitle,
    required this.initialContent,
    required this.initialPrice,
  }) : super(key: key);

  @override
  _PostEditLayoutState createState() => _PostEditLayoutState();
}

class _PostEditLayoutState extends State<PostEditLayout> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _priceController;
  bool _isLoading = false;
  File? _image; // 기존 이미지 처리를 위한 변수 (선택 사항)

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _contentController = TextEditingController(text: widget.initialContent);
    _priceController =
        TextEditingController(text: widget.initialPrice.toStringAsFixed(0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("게시물 수정하기"),
        centerTitle: true,
        backgroundColor: Color(0xFF0c4da2),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              // 제목 입력 필드
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "제목:",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              // 내용 입력 필드
              TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: "내용:",
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              SizedBox(height: 20),
              // 가격 입력 필드
              TextField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: "가격 설정",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              // 수정 버튼
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF0c4da2),
                ),
                onPressed: updatePost,
                child:
                    _isLoading ? CircularProgressIndicator() : Text("게시물 업데이트"),
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

  void updatePost() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      print("제목과 내용이 필요합니다.");
      return;
    }

    double? price = double.tryParse(_priceController.text);
    if (price == null) {
      print("가격 설정이 잘못됐습니다.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .updatePost(
        postId: widget.postId,
        title: _titleController.text,
        content: _contentController.text,
        price: price,
        imageFile: _image,
      )
          .whenComplete(() {
        // 업데이트가 완료된 후 홈 화면으로 돌아갑니다.
        Navigator.popUntil(context, ModalRoute.withName('/'));
      });
    } catch (e) {
      print("게시물 업데이트 중 오류가 발생했습니다: $e");
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
