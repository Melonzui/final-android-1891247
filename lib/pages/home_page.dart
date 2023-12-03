import 'package:chatappfirebase/helper/helper_function.dart';
import 'package:chatappfirebase/pages/auth/login_page.dart';
import 'package:chatappfirebase/pages/postup.dart';
import 'package:chatappfirebase/pages/profile_page.dart';
import 'package:chatappfirebase/service/auth_service.dart';
import 'package:chatappfirebase/service/database_service.dart';
import 'package:chatappfirebase/widgets/group_tile.dart';
import 'package:chatappfirebase/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showOnlyAvailable = false;
  String userName = "";
  String email = "";
  AuthService authService = AuthService();
  Stream? groups;
  bool _isLoading = false;
  String groupName = "";

  @override
  void initState() {
    super.initState();
    gettingUserData();
  }

  // string manipulation
  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  gettingUserData() async {
    await HelperFunctions.getUserEmailFromSF().then((value) {
      setState(() {
        email = value!;
      });
    });
    await HelperFunctions.getUserNameFromSF().then((val) {
      setState(() {
        userName = val!;
      });
    });
    // getting the list of snapshots in our stream
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Switch(
            value: _showOnlyAvailable,
            onChanged: (value) {
              setState(() {
                _showOnlyAvailable = value;
              });
            },
          ),
        ],
        elevation: 0,
        centerTitle: true,
        backgroundColor: Color(0xFF0c4da2),
        title: const Text(
          "판매목록",
          style: TextStyle(color: Colors.white, fontSize: 27),
        ),
      ),
      drawer: Drawer(
          child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 50),
        children: <Widget>[
          Icon(
            Icons.account_circle,
            size: 150,
            color: Colors.grey[700],
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            userName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 30,
          ),
          const Divider(
            height: 2,
          ),
          ListTile(
            onTap: () {},
            selectedColor: Theme.of(context).primaryColor,
            selected: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: const Icon(Icons.group, color: Color(0xFF0c4da2)),
            title: const Text(
              "게시물",
              style: TextStyle(color: Colors.black),
            ),
          ),
          ListTile(
            onTap: () {
              nextScreenReplace(
                  context,
                  ProfilePage(
                    userName: userName,
                    email: email,
                  ));
            },
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: const Icon(Icons.group, color: Color(0xFF0c4da2)),
            title: const Text(
              "프로필",
              style: TextStyle(color: Colors.black),
            ),
          ),
          ListTile(
            onTap: () async {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("로그아웃"),
                      content: const Text("로그아웃하시겠습니까?"),
                      actions: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.cancel,
                            color: Color.fromARGB(255, 149, 34, 26),
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            await authService.signOut();
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()),
                                (route) => false);
                          },
                          icon:
                              const Icon(Icons.done, color: Color(0xFF0c4da2)),
                        ),
                      ],
                    );
                  });
            },
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: const Icon(Icons.exit_to_app,
                color: Color.fromARGB(255, 149, 34, 26)),
            title: const Text(
              "로그아웃",
              style: TextStyle(color: Colors.black),
            ),
          )
        ],
      )),
      body: postList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          popUpDialog(context);
        },
        elevation: 0,
        backgroundColor: Color(0xFF0c4da2),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  void popUpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("게시물 만들기"),
          content: const Text("새 게시물을 만드시겠습니까?"),
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
                nextScreenReplace(
                    context,
                    PostUpLayout(
                      userName: userName,
                    ));
              },
              child: const Text(
                "만들기",
                style: TextStyle(color: Color(0xFF0c4da2)),
              ),
            ),
          ],
        );
      },
    );
  }

  //그룹리스트(변경해야함)
  Widget postList() {
    final currentUserID = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder(
      stream: DatabaseService().getAllPosts(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }
        if (snapshot.hasData) {
          var posts = snapshot.data!.docs.where((doc) {
            if (_showOnlyAvailable) {
              return (doc.data() as Map)['_isSold'] == false;
            }
            return true;
          }).toList();

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              var postData = posts[index].data() as Map;
              var postId = snapshot.data!.docs[index].id;
              var postTitle = postData['title'];
              var postPrice = postData['price'];
              var postImageUrl = postData['imageUrl'];
              var content = postData['content'];
              var postuserNickname = postData['userName'];
              var postuserUID = postData['creator'];
              bool sold = postData['_isSold']; // 새로운 타일 위젯 반환
              return PostLayout(
                currentUserNickname: userName,
                postuserUID: postuserUID,
                postuserNickname: postuserNickname,
                PostId: postId,
                PostTitle: postTitle,
                price: postPrice,
                imageUrl: postImageUrl,
                content: content, // 현재 사용자 이름
                currentUserID: currentUserID,
                isSold: sold,
              );
            },
          );
        }
        return Text("No Posts Found");
      },
    );
  }

  noGroupWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              popUpDialog(context);
            },
            child: Icon(
              Icons.add_circle,
              color: Colors.grey[700],
              size: 75,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "You've not joined any groups, tap on the add icon to create a group or also search from top search button.",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
