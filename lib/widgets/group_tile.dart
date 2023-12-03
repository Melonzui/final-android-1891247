import 'package:chatappfirebase/pages/post_page.dart';
import 'package:chatappfirebase/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//메인화면 그룹챗 위젯
class PostLayout extends StatefulWidget {
  final String PostId;
  final String PostTitle;
  final String imageUrl; // 이미지 URL
  final double price; // 가격
  final String content;
  final String currentUserID;
  final String postuserNickname;
  final String postuserUID;
  final String currentUserNickname;
  final bool isSold;

  const PostLayout({
    Key? key,
    required this.PostId,
    required this.PostTitle,
    required this.imageUrl,
    required this.price,
    required this.content,
    required this.currentUserID,
    required this.currentUserNickname,
    required this.postuserNickname,
    required this.postuserUID,
    required this.isSold,
  }) : super(key: key);

  @override
  State<PostLayout> createState() => _PostLayoutState();
}

class _PostLayoutState extends State<PostLayout> {
  final currencyFormatter = NumberFormat.simpleCurrency(
      locale: 'ko_KR', name: 'KRW', decimalDigits: 0);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        nextScreen(
          context,
          PostPage(
            isSold: widget.isSold,
            postuserUID: widget.postuserUID,
            currentUserUID: widget.currentUserID,
            content: widget.content,
            postId: widget.PostId,
            postTitle: widget.PostTitle,
            price: widget.price,
            imageUrl: widget.imageUrl,
            postuserNickname: widget.postuserNickname,
            currentUserNickname: widget.currentUserNickname,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Color(0xFFe8f1f7), // 연한 주황색 배경
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // 이미지 표시 부분
            ClipRRect(
              borderRadius: BorderRadius.circular(8), // 이미지 모서리 둥글게
              child: Image.network(
                widget.imageUrl,
                width: 100, // 이미지 크기 증가
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 16), // 이미지와 텍스트 사이의 간격
            // 텍스트 부분
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.PostTitle,
                    style: TextStyle(
                      fontSize: 16, // 폰트 크기 조정
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "${currencyFormatter.format(widget.price)}원",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold), // 폰트 크기 조정
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text(widget.isSold ? "판매 완료" : "판매 중"),
                    style: ElevatedButton.styleFrom(
                      primary: widget.isSold ? Colors.grey : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
