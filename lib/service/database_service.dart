import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // reference for our collections
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");
  final CollectionReference postCollection =
      FirebaseFirestore.instance.collection("posts");

  Stream<QuerySnapshot> getGroupsStream() {
    return groupCollection.snapshots();
  }

  Future<void> updatePost({
    required String postId,
    required String title,
    required String content,
    required double price,
    File? imageFile, // 이미지가 있다면 추가로 처리
  }) async {
    // 이미지 업로드 로직 (선택 사항)
    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await uploadImageToStorage(imageFile);
    }

    // Firestore 문서 업데이트
    return FirebaseFirestore.instance.collection('posts').doc(postId).update({
      'title': title,
      'content': content,
      'price': price,
      if (imageUrl != null) 'imageUrl': imageUrl, // 이미지 URL 업데이트 (선택 사항)
    });
  }

  //중요코드
  Future<String> getOrCreateChatGroup(String postId, String postTitle,
      String currentUserId, String postCreatorId) async {
    QuerySnapshot existingGroup =
        await groupCollection.where('postId', isEqualTo: postId).get();

    if (existingGroup.docs.isNotEmpty) {
      // 기존 그룹이 존재하는 경우, 그룹 ID 반환
      return existingGroup.docs.first.id;
    } else {
      // 새 그룹 생성
      DocumentReference groupDocumentReference = await groupCollection.add({
        "groupName": postTitle,
        "admin": postCreatorId,
        "members": [currentUserId, postCreatorId], // 현재 사용자와 게시물 작성자 추가
        "groupId": "",
        "recentMessage": "",
        "recentMessageSender": "",
        "postId": postId,
      });

      await groupDocumentReference.update({
        "groupId": groupDocumentReference.id,
      });

      await postCollection.doc(postId).update({
        "linkedGroupId": groupDocumentReference.id,
      });

      return groupDocumentReference.id; // 새로 생성된 그룹 ID 반환
    }
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    String fileName =
        'posts/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
    Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

    UploadTask uploadTask = storageRef.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;
    String imageUrl = await taskSnapshot.ref.getDownloadURL();
    return imageUrl;
  }

  Future savingUserData(String fullName, String email) async {
    return await userCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "groups": [],
      "profilePic": "",
      "uid": uid,
    });
  }

  // 게시물 생성용
  Future<void> createPost(
      {required String userName,
      required String title,
      required String content,
      required File imageFile,
      required String postId,
      required double price}) async {
    String imageUrl = await uploadImageToStorage(imageFile);
    bool _isSold = false;
    await FirebaseFirestore.instance.collection('posts').add({
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'price': price,
      'creator': uid,
      'userName': userName,
      '_isSold': _isSold,
      'postID': postId,
      'timestamp': FieldValue.serverTimestamp(),
      // 기타 필요한 필드 추가
    });
  }

  Stream<QuerySnapshot> getAllPosts() {
    return FirebaseFirestore.instance.collection('posts').snapshots();
  }

  Future<DocumentSnapshot> getPost(String postId) async {
    return await postCollection.doc(postId).get();
  }

  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

  Future createGroup(String userName, String id, String groupName) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });

    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId": groupDocumentReference.id,
    });

    DocumentReference userDocumentReference = userCollection.doc(uid);
    return await userDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
    });
  }

  getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  Future getGroupAdmin(String groupId) async {
    DocumentReference d = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['admin'];
  }

  getGroupMembers(groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = await documentSnapshot['groups'];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  sendMessage(String groupId, Map<String, dynamic> chatMessageData) async {
    groupCollection.doc(groupId).collection("messages").add(chatMessageData);
    groupCollection.doc(groupId).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString(),
    });
  }
}
