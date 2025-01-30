import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:split/model/usermodel.dart';

class UserRepository {
  static final UserRepository _singleton = UserRepository._internal();

  static UserRepository get instance => _singleton;

  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  String? currentUser = FirebaseAuth.instance.currentUser?.uid;

  DocumentSnapshot? allUserLastDocument;

  /*
  * private constructor to make a singleton object
  * */
  UserRepository._internal();

  /*static UserRepository getInstance() {
    return _singleton;
  }*/

  Future<UserModel> createNewUser(UserModel user) async {
    final newDocRef = _usersCollection.doc(user.id);
    UserModel newUser = user.copyWith(id: newDocRef.id);
    await newDocRef.set(newUser.toMap());
    return newUser;
  }

  Future<void> updateUser(UserModel user) async {
    await _usersCollection.doc(user.id).update(user.toMap());
  }

  Future<UserModel?> getUserById(String? id) async {
    if (id == null) {
      return null;
    }
    DocumentReference documentReference = _usersCollection.doc(id);
    DocumentSnapshot documentSnapshot = await documentReference.get();
    if (documentSnapshot.data() == null) {
      return null;
    }
    return UserModel.fromMap(documentSnapshot.data()! as Map<String, dynamic>);
  }

  Future<UserModel?> getUserByPhone(String phone) async {
    final querySnapshot =
        await _usersCollection.where('mobileNo', isEqualTo: phone).get();
    if (querySnapshot.docs.isNotEmpty) {
      return UserModel.fromMap(
          querySnapshot.docs.first.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<UserModel>?> getUsersByIds(List<String?> userIds) async {
    final querySnapshot =
        await _usersCollection.where('id', whereIn: userIds).get();
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs
          .map((e) => UserModel.fromMap(e.data() as Map<String, dynamic>))
          .toList();
    }
    return null;
  }

  Future<UserModel> fetchUser(String id) async {
    DocumentSnapshot documentSnapshot = await _usersCollection.doc(id).get();
    return UserModel.fromMap(documentSnapshot.data()! as Map<String, dynamic>);
  }

  Stream<List<UserModel>> streamAllUser() {
    return _usersCollection.snapshots().map((querySnapshot) {
      return querySnapshot.docs
          .map((documentSnapshot) => UserModel.fromMap(
              documentSnapshot.data()! as Map<String, dynamic>))
          .toList();
    });
  }

  Stream<List<UserModel>> allUserExceptCurrentUser() {
    return _usersCollection.snapshots().map((querySnapshot) {
      return querySnapshot.docs.where((document) {
        return document.id != currentUser;
      }).map((map) {
        return UserModel.fromDocumentSnapshot(map);
      }).toList();
    });
  }

  Stream<UserModel> streamUser(String id) {
    return _usersCollection.doc(id).snapshots().map((documentSnapshot) =>
        UserModel.fromMap(documentSnapshot.data()! as Map<String, dynamic>));
  }

  void handleUI() {
    streamUser('id').listen((event) {
      print(event);
    });
  }

  Future<bool> isUserExist(String uid) {
    return _usersCollection.doc(uid).get().then((value) => value.exists);
  }
}
