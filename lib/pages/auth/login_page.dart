import 'package:chatappfirebase/helper/helper_function.dart';
import 'package:chatappfirebase/pages/auth/register_page.dart';
import 'package:chatappfirebase/pages/home_page.dart';
import 'package:chatappfirebase/service/auth_service.dart';
import 'package:chatappfirebase/service/database_service.dart';
import 'package:chatappfirebase/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  bool _isLoading = false;
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: Color(0xFF5b8fe9)),
            )
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
                child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          "한성장터",
                          style:
                              TextStyle(fontSize: 40, color: Color(0xFF0c4da2)
                                  //fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 10),
                        Image.asset("assets/login.png"),
                        TextFormField(
                          decoration: textInputDecoration.copyWith(
                              border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xFF5da3ff)),
                              ),
                              labelText: "이메일",
                              prefixIcon:
                                  Icon(Icons.email, color: Color(0xFF0c4da2))),
                          onChanged: (val) {
                            setState(() {
                              email = val;
                            });
                          },

                          // check tha validation
                          validator: (val) {
                            return RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(val!)
                                ? null
                                : "유효한 이메일을 입력해주세요.";
                          },
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          obscureText: true,
                          decoration: textInputDecoration.copyWith(
                              border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xFF5da3ff)),
                              ),
                              labelText: "비밀번호",
                              prefixIcon:
                                  Icon(Icons.lock, color: Color(0xFF0c4da2))),
                          validator: (val) {
                            if (val!.length < 6) {
                              return "비밀번호는 6자리 이상이어야 합니다.";
                            } else {
                              return null;
                            }
                          },
                          onChanged: (val) {
                            setState(() {
                              password = val;
                            });
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Color(0xFF0c4da2),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30))),
                            child: const Text(
                              "로그인",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            onPressed: () {
                              login();
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text.rich(TextSpan(
                          text: "계정이 없으신가요?  ",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 14),
                          children: <TextSpan>[
                            TextSpan(
                                text: "여기를 눌러서 회원가입하기",
                                style: const TextStyle(
                                    color: Colors.lightBlue,
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    nextScreen(context, const RegisterPage());
                                  }),
                          ],
                        )),
                      ],
                    )),
              ),
            ),
    );
  }

  login() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService
          .loginWithUserNameandPassword(email, password)
          .then((value) async {
        if (value == true) {
          QuerySnapshot snapshot =
              await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                  .gettingUserData(email);
          // saving the values to our shared preferences
          await HelperFunctions.saveUserLoggedInStatus(true);
          await HelperFunctions.saveUserEmailSF(email);
          await HelperFunctions.saveUserNameSF(snapshot.docs[0]['fullName']);
          nextScreenReplace(context, const HomePage());
        } else {
          showSnackbar(context, Colors.red, value);
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }
}
