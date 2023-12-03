import 'package:chatappfirebase/pages/auth/login_page.dart';
import 'package:chatappfirebase/pages/home_page.dart';
import 'package:chatappfirebase/service/auth_service.dart';
import 'package:chatappfirebase/widgets/widgets.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  String userName;
  String email;
  ProfilePage({Key? key, required this.email, required this.userName})
      : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0c4da2),
        elevation: 0,
        title: const Text(
          "프로필",
          style: TextStyle(
            color: Colors.white,
            fontSize: 27,
          ),
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
            widget.userName,
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
            onTap: () {
              nextScreen(context, const HomePage());
            },
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: const Icon(Icons.group, color: Color(0xFF0c4da2)),
            title: const Text(
              "게시물",
              style: TextStyle(color: Colors.black),
            ),
          ),
          ListTile(
            onTap: () {},
            selected: true,
            selectedColor: Theme.of(context).primaryColor,
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
                          icon: const Icon(
                            Icons.done,
                            color: Color(0xFF0c4da2),
                          ),
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
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 170),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.account_circle,
              size: 200,
              color: Colors.grey[700],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("이름", style: TextStyle(fontSize: 17)),
                Text(widget.userName, style: const TextStyle(fontSize: 17)),
              ],
            ),
            const Divider(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("이메일", style: TextStyle(fontSize: 17)),
                Text(widget.email, style: const TextStyle(fontSize: 17)),
              ],
            ),
            const Divider(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("앱 제작", style: TextStyle(fontSize: 17)),
                Text("1891247 유현우\n1891248 유현호",
                    style: const TextStyle(fontSize: 17)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
