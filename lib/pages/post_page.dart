import 'package:chatappfirebase/pages/chat_page.dart';
import 'package:chatappfirebase/pages/post_edit.dart';
import 'package:chatappfirebase/service/database_service.dart';
import 'package:chatappfirebase/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PostPage extends StatefulWidget {
  final String postId;
  final String postTitle;
  final double price;
  final String imageUrl;
  final String content;
  final String currentUserUID;
  final String currentUserNickname;
  final String postuserNickname;
  final String postuserUID;
  final bool isSold;

  const PostPage({
    Key? key,
    required this.postId,
    required this.postTitle,
    required this.price,
    required this.imageUrl,
    required this.content,
    required this.currentUserUID,
    required this.currentUserNickname,
    required this.postuserNickname,
    required this.postuserUID,
    required this.isSold,
  }) : super(key: key);

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final currencyFormatter = NumberFormat.simpleCurrency(
      locale: 'ko_KR', name: 'KRW', decimalDigits: 0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.postuserNickname + "님의 게시물"),
        centerTitle: true,
        backgroundColor: Color(0xFF0c4da2),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "제목:" + widget.postTitle,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "가격: ${currencyFormatter.format(widget.price)}원",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  //if (widget.currentUserUID == widget.postuserUID) // 판매자만 버튼 보임
                  ElevatedButton(
                    onPressed: () => popUpDialog(context),
                    child: Text(widget.isSold ? "판매 완료" : "판매 중"),
                    style: ElevatedButton.styleFrom(
                      primary: widget.isSold ? Colors.grey : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '내용:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(16.0),
                    width: double.infinity,
                    height: 200, // 박스의 고정된 높이
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        widget.content,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ... 버튼 관련 코드 ...
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _actionButtons(),
    );
  }

  void _toggleSoldStatus() async {
    if (widget.currentUserUID == widget.postuserUID) {
      if (widget.isSold == true) {
        FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postId)
            .update({
          '_isSold': false,
        });
      } else {
        FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postId)
            .update({
          '_isSold': true,
        });
      }
    } else {
      showToast(context, "본인이 작성한 게시물이 아니므로 판매상태를 바꿀 수 없습니다.");
    }
  }

  void popUpDialog(BuildContext context) {
    if (widget.currentUserUID == widget.postuserUID) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("판매상태 바꾸기"),
            content: const Text("판매 상태를 바꾸시겠습니까?"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                },
                child: const Text(
                  "아니요",
                  style: TextStyle(color: Color.fromARGB(255, 149, 34, 26)),
                ),
              ),
              TextButton(
                onPressed: () {
                  _toggleSoldStatus();
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "바꾸기",
                  style: TextStyle(color: Color(0xFF0c4da2)),
                ),
              ),
            ],
          );
        },
      );
    } else {
      showToast(context, "본인이 작성한 게시물이 아니므로 판매상태를 바꿀 수 없습니다.");
    }
  }

  Widget _actionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ActionButton(
            text: "수정하기",
            icon: Icons.edit,
            onPressed: () async {
              // '수정하기' 버튼 클릭 시, 수정 모드로 PostUpLayout 열기
              if (widget.currentUserUID == widget.postuserUID) {
                if (await confirmchange(context)) {
                  nextScreen(
                    context,
                    PostEditLayout(
                      initialContent: widget.content,
                      postId: widget.postId,
                      initialPrice: widget.price,
                      initialTitle: widget.postTitle,
                    ),
                  );
                }
              } else {
                showToast(context, "본인이 작성한 게시물이 아니므로 수정할 수 없습니다.");
              }
            },
            context: context),
        ActionButton(
          text: "삭제하기",
          icon: Icons.delete,
          onPressed: () async {
            if (widget.currentUserUID == widget.postuserUID) {
              if (await confirmDelete(context)) {
                await deletePost(widget.postId);
                Navigator.of(context).pop(); // 게시물 삭제 후 이전 화면으로 돌아가기
              }
            } else {
              showToast(context, "본인이 작성한 게시물이 아니므로 삭제할 수 없습니다.");
            }
          },
          context: context,
        ),
        ActionButton(
            text: "그룹대화",
            icon: Icons.message,
            onPressed: () async {
              DatabaseService dbService =
                  DatabaseService(uid: FirebaseAuth.instance.currentUser?.uid);
              String groupId = await dbService.getOrCreateChatGroup(
                  widget.postId,
                  widget.postTitle,
                  widget.postuserUID,
                  widget.currentUserUID);

              // ChatPage로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    groupId: groupId,
                    groupName: widget.postTitle,
                    userName: widget.currentUserNickname,
                    postuserNickname: widget.postuserNickname,
                  ),
                ),
              );
            },
            context: context),
      ],
    );
  }

  void showToast(BuildContext context, String message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontSize: 13, // 글꼴 크기 변경
            fontFamily: 'Jalnan2TTF.ttf', // 글꼴 굵기 변경
            color: Colors.white, // 글꼴 색상 변경
          ),
        ),
        backgroundColor: Color(0xFF0c4da2), // 배경색 변경
        action: SnackBarAction(
          label: '확인',
          textColor: Color.fromARGB(255, 226, 243, 255), // 버튼 텍스트 색상 변경
          onPressed: scaffold.hideCurrentSnackBar,
        ),
      ),
    );
  }
}

Future<bool> confirmchange(BuildContext context) async {
  return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("게시물 수정하기"),
          content: Text("게시물을 수정하시겠습니까?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("아니오",
                  style: TextStyle(color: Color.fromARGB(255, 149, 34, 26))),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("수정하기", style: TextStyle(color: Color(0xFF0c4da2))),
            ),
          ],
        ),
      ) ??
      false;
}

Future<bool> confirmDelete(BuildContext context) async {
  return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("게시물 삭제하기"),
          content: Text("정말 삭제하시겠습니까?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("아니오",
                  style: TextStyle(color: Color.fromARGB(255, 149, 34, 26))),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("삭제하기", style: TextStyle(color: Color(0xFF0c4da2))),
            ),
          ],
        ),
      ) ??
      false;
}

Future<void> deletePost(String postId) async {
  try {
    await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
  } catch (e) {
    print("Error deleting post: $e");
  }
}

class ActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final BuildContext context;

  const ActionButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
    required this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(text),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: Color(0xFF0c4da2),
        onPrimary: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}
