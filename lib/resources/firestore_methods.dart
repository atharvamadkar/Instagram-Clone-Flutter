import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //upload post
  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    String username,
    String profImage,
  ) async {
    String res = "Some error occured";
    try {
      String photoUrl = await StorageMethods().uploadImageToStorage(
        "posts",
        file,
        true,
      );
      String postId = const Uuid().v1();
      Post post = Post(
        description: description,
        uid: uid,
        username: username,
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profImage: profImage,
        likes: [],
      );

      _firestore.collection("posts").doc(postId).set(post.toJson());

      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection("posts").doc(postId).update({
          "likes": FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection("posts").doc(postId).update({
          "likes": FieldValue.arrayUnion([uid]),
        });
      }
    } catch (err) {
      print(err.toString());
    }
  }

  Future<void> postComment(
    String postId,
    String text,
    String uid,
    String name,
    String profilePic,
  ) async {
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();
        await _firestore
            .collection("posts")
            .doc(postId)
            .collection("comments")
            .doc(commentId)
            .set(
          {
            "profilePic": profilePic,
            "text": text,
            "name": name,
            "uid": uid,
            "commentId": commentId,
            "datePublished": DateTime.now(),
          },
        );
      } else {
        print(
          "Comment is empty",
        );
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection("posts").doc(postId).delete();
    } catch (err) {
      print(err.toString());
    }
  }

  Future<void> followUser(
    String uid,
    String followUid,
  ) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection("users").doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followUid)) {
        await _firestore.collection("users").doc(followUid).update(
          {
            "followers": FieldValue.arrayRemove([uid]),
          },
        );

        await _firestore.collection("users").doc(uid).update(
          {
            "following": FieldValue.arrayRemove([followUid]),
          },
        );
      } else {
        await _firestore.collection("users").doc(followUid).update(
          {
            "followers": FieldValue.arrayUnion([uid]),
          },
        );

        await _firestore.collection("users").doc(uid).update(
          {
            "following": FieldValue.arrayUnion([followUid]),
          },
        );
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
